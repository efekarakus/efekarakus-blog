---
layout: post
title: "If it ain't broke, fix it?"
tags: [programming, software]
---
Can you spot what’s strange about the following CloudFormation snippet? 
```yaml
AdministrationRole:
  Type: AWS::IAM::Role
  Properties:
    RoleName: !Ref AdminRoleName
    AssumeRolePolicyDocument:
      Statement:
        - Effect: Allow
          Principal:
            Service: cloudformation.amazonaws.com
          Action:
            - sts:AssumeRole
    Policies:
      - PolicyName: AssumeRole-AWSCloudFormationStackSetExecutionRole
        PolicyDocument:
          Statement:
            - Effect: Allow
              Action:
                - sts:AssumeRole
              Resource:
                - !Sub 'arn:aws:iam::*:role/${AdminRoleName}'
ExecutionRole:
  Type: AWS::IAM::Role
  Properties:
    RoleName: !Ref ExecutionRoleName
    AssumeRolePolicyDocument:
      Statement:
        - Effect: Allow
          Principal:
            AWS: !GetAtt AdministrationRole.Arn
          Action:
            - sts:AssumeRole
	#Policies...
```
The `AdministrationRole` and `ExecutionRole` are used while creating a [CloudFormation StackSet](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html) to manage stacks across multiple AWS regions. The `ExecutionRole` is supposed to be assumed by the `AdministrationRole` to perform any operations specified in the template. The strange part is that the `AdministrationRole` is giving permission to assume itself and not the `ExecutionRole`.
```yaml
Resource:
  - !Sub 'arn:aws:iam::*:role/${AdminRoleName}' # What?
```
Yet somehow, [for 2 years](https://github.com/aws/copilot-cli/blob/238fd708679d4534b2f4c58cc3b7a85e6e1a768d/templates/app/app.yml) the stack set instances were created successfully with the permissions described in the `ExecutionRole`. It turns out that if the roles are in [the same AWS account](https://serverfault.com/a/1021603),  just adding the `AdministrationRole `principal in the trust policy of the `ExecutionRole` is enough. The 2-way handshake is strictly necessary when working cross-account.

**_Given that all external observable factors indicate that a strange piece of code behaves as expected, is the effort of researching, understanding, and modifying it justified?_**

The argument for [“fixing”](https://github.com/aws/copilot-cli/commit/eb8ad5a43ac6320d3a14f00aef1b7e983ddf644a) the template above seems to be the same as removing [dead code](https://twitter.com/martinfowler/status/788827419641643009?lang=en). Assuming that code is read more times than it’s written, if we don’t reflect our latest understanding of the world to the code then on subsequent reads we will keep wasting our brain power figuring out what is going on. We must eliminate or replace confusing code to keep the read cost over time small.

Another reason for investigating strange code is that it can lead you to alternative and possibly simpler solutions.  
For example, a few weeks ago we got [an issue](https://github.com/aws/copilot-cli/issues/3984) where users trying to read an object from S3 got an access denied error. The same object gets uploaded from separate AWS accounts under the same key with the expectation that all these accounts should then be able to read the object. The bucket had a policy that granted these accounts permission to read, and the objects were uploaded with the `bucket-owner-full-control` ACL. A first submission fixed the overwrite problem by working around it: just write each object with separate keys. Yet the configuration above should have worked, so what is the real root cause? The [object ownership model](https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html) for S3 is a bit difficult to grok at first, but the default object ownership control “Object writer” didn’t leverage the bucket policy for access control. A much more natural and less costly fix turned out to be just switching a field in the bucket definition to “Bucket owner enforced”.

If the task at hand requires me to read a piece of code that I don’t understand, it’s been always rewarding to dive a bit deeper. You can walk out having learned something new and gotten to improve the codebase just a little, or even potentially find a simpler solution.