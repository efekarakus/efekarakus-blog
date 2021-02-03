---
layout: post
title: "How to Solve It: AWS Copilot's Progress Tracker"
tags: [design]
---
Towards the end of last year, I picked up [How to Solve It](https://www.amazon.com/How-Solve-Mathematical-Princeton-Science/dp/069116407X/ref=sr_1_1?dchild=1&keywords=how+to+solve+it&qid=1610911606&s=books&sr=1-1), a book that studies the methods of problem solving, by George Pólya and I fell in love with it. While most of the examples are about solving math problems, the mental operations taken apply just as well to practical problems. 
This post shows the _process_ of solving a modest practical problem, [AWS Copilot](https://github.com/aws/copilot-cli)’s progress tracker, to arrive at a design using the recommendations presented in the book.

## Background
AWS Copilot is an open source CLI to build, release and operate containerized apps on AWS. Prior to v1.2.0, customers that deployed a service with Copilot only saw a single spinner to signal that the deployment is in progress:
![old-spinner](https://user-images.githubusercontent.com/879348/106804817-bc580500-661a-11eb-8b32-093e2dc3591c.gif)

We knew that displaying only a spinner for an operation that can take several minutes did not meet the delightfulness bar for Copilot. So we started exploring how we can provide a better UX and arrived at the following solution:  
![create-svc](https://user-images.githubusercontent.com/879348/106644648-36678b80-6540-11eb-8bff-95fc5ed1ea14.gif)

## Mathematical vs. practical problems
> In a perfectly stated mathematical problem all data and all clauses of the condition are essential and must be taken into account. In practical problems we have a multitude of data and conditions; we take into account as many as we can but we are obliged to neglect some.  
\- George Pólya, [How to Solve It](https://www.amazon.com/How-Solve-Mathematical-Princeton-Science/dp/069116407X/ref=sr_1_1?dchild=1&keywords=how+to+solve+it&qid=1610911606&s=books&sr=1-1)

Take our example with the progress tracker. There are multiple APIs that we can  use to get information about resources being deployed and their state. Do we need to use [DescribeChangeSet](https://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DescribeChangeSet.html) to get a list of proposed changes or is [DescribeStackEvents](https://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_DescribeStackEvents.html) enough to display progress? Is there interesting information from [DescribeServices](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_DescribeServices.html)? How about calling `Describe` for other resources?

> In solving a practical problem, we are often obliged to start from rather hazy ideas; then, the clarification of the concepts may become an important part of the problem.  
\- George Pólya, [How to Solve It](https://www.amazon.com/How-Solve-Mathematical-Princeton-Science/dp/069116407X/ref=sr_1_1?dchild=1&keywords=how+to+solve+it&qid=1610911606&s=books&sr=1-1)

> 90% of solving really hard problems is deciding which set of constraints you should ignore. 
\- [@\_joemag\_](https://twitter.com/_joemag_/status/1321281983331250177)

Unlike math problems, we seldom have a precise definition at the start. We iterate on the requirements. As we explore the problem space, we get a better understanding of which requirements are real and which ones are “nice to have”.  For example, does the progress tracker need to render updates instantaneously or is it okay to simplify and display information periodically? The answer is pretty clear for this problem. Separating the lifecycle for fetching and rendering data significantly simplifies the problem and gets rid of an unnecessary requirement. 

## The design of design
I highlighted in _italics_ suggestions or questions from Pólya that applies to solving this practical problem.

### Understanding the problem
#### _What is the unknown?_  
A clear problem definition. 
1. What are our requirements or _constraints_? What should the progress tracker achieve?
2. What is a UI that satisfy these requirements?
3. Do we have the data to create the UI?


#### _Can you visualize the problem? Can you draw a figure? Do not concern yourself with the implementation for the moment._
Yes. Here are few [low-fidelity mocks](https://gist.github.com/efekarakus/fe4afc1ab8b54835d27e47e253f46254).  

#### _What are the conditions?_
Here are some rough requirement ideas:
1. <span class="label t">transparency</span> Indicate the operation is still _in progress_ and not stuck.
2. <span class="label t">transparency</span> Get an understanding of _what_ is being performed so that users gain confidence the right operations are happening. 
3. <span class="label t">educate</span> Explain _why_ a resource is being mutated.
As one of Copilot’s goals is to also explain the basic building blocks of AWS.

#### _Are the conditions sufficient to determine the unknown_?
No. The conditions are too vague and insufficient. For example, it's not clear whether "operation" refers to the Copilot deployment or a CloudFormation resource. There is also no condition around troubleshooting errors. Here is a second draft that's more precise:
1. <span class="label t">transparency</span> **Indicate that the operation is not stuck and is still in progress**. Copilot should signal that it is still tracking the CloudFormation stack. CloudFormation resources that take a long time to create should provide additional information.
2. <span class="label t">transparency</span> **Give an idea of how much work remains**. Users should be able to decide whether to keep paying attention to the CLI or focus on another task.
3. <span class="label t">transparency</span> **List AWS resources**. Users need to see the created resources so that they know the CLI is not allocating extra costly resources.
4. <span class="label t">education</span> **Explain AWS resources**. Our progress tracker needs to educate users on low-level AWS primitives so that they get familiar with AWS.
5. <span class="label t">transparency</span> **Clear error messages for troubleshooting**. Error messages in case of a failure should be surfaced and be as specific as possible.
6. <span class="label t">scalability</span> **Scales with new operations**. We should be able to provide the same detailed UX as new resources or workload types are added to the CLI.

#### _What is the data? Is it possible to satisfy the condition?_
Partially.  
We can get the data for the <span class="label t">transparency</span> conditions with the following APIs:
* Call `DescribeChangeSet` to get resources that will be updated. [Sample output](https://gist.github.com/efekarakus/4a25fff86552b8c870859390cd514c23).
* Call `DescribeStackEvents` to get the latest status and error messages for a resource.  [Sample output](https://gist.github.com/efekarakus/5eec8215642594ff1fc1545e29f76131).
* Call `DescribeServices` to get ECS deployment information and service events. [Sample output](https://gist.github.com/efekarakus/08a1829f4ef144b9f7141d35bcd525a1).

For the <span class="label t">education</span> and <span class="label t">scalability</span> conditions, an option is to add comments in the CloudFormation template to associate the resource with a human-friendly description.
```yaml
Service:
  # An ECS service to run and maintain your tasks in the environment cluster
```
This would provide the data for <span class="label t">education</span> and make sure that we meet <span class="label t">scalability</span> by adding a comment for new resources introduced in the templates.


However, we now have the following new unknowns:
* <span class="label t">transparency</span> How to keep the data and UI in sync while maintaining a modular codebase?
* <span class="label t">education</span> How can parse the template so that we know a comment is associated with a resource?


### Devising a plan
Now that we have a better understanding of the problem, we need to find the connection between the data and the unknown that satisfies the constraints.

#### _Look at the unknown! Think of familiar solutions having the same or similar unknown._
Here are related solutions to our <span class="label t">transparency</span> unknown:
* [AWS Amplify](https://docs.amplify.aws/cli).
* [AWS CDK](https://docs.aws.amazon.com/cdk/api/latest/).
* [Docker Compose: ECS integration](https://docs.docker.com/cloud/ecs-integration/).
* [Ink](https://www.npmjs.com/package/ink) is a Node.js library that provides React-like components for CLIs.
* The [observer](https://en.wikipedia.org/wiki/Observer_pattern) and [model-view-controller](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) patterns provide ways of keeping data and UI in sync while maintaing a modular codebase.


#### _Could you use it? Could you use its result? its method?_
Yes!

From the [CDK](https://docs.aws.amazon.com/cdk/api/latest/), we can use the _method_ for how to collect CloudFormation stack events triggered from a ChangeSet: [stack-activity-monitor.ts](https://github.com/aws/aws-cdk/blob/43f3f09cc561fd32d651b2c327e877ad81c2ddb2/packages/aws-cdk/lib/api/util/cloudformation/stack-activity-monitor.ts#L230-L234). The idea is to get the `CreationTime` of a ChangeSet and only stream events after the timestamp.

From [Docker Compose](https://docs.docker.com/cloud/ecs-integration/), we can use both a _result_ and a _method_. Compose displays a timestamp next to each operation showing how long the operation takes. This would help us indicate that Copilot is not stuck and is still watching the CloudFormation stack.
![docker-compose](https://user-images.githubusercontent.com/879348/106340294-21dc7800-624e-11eb-9146-e9f97c712ec2.png)

We can also look at [tty.go](https://github.com/docker/compose-cli/blob/8ee2286126f4ece9c65e5afaeb7b5b0c961f214c/progress/tty.go#L91) to see how Compose keeps the data and UI in sync. Compose buffers events and then writes them to the terminal every 100ms.

From [Ink](https://www.npmjs.com/package/ink), we can use the idea of components: a `tableComponent` to render task counts part of an ECS deployment, or a `textComponent` for displaying basic text info. We can build more sophisticated components from these building blocks.

We can [accomodate](https://stackoverflow.com/a/3735114/1201381) the observer pattern to use go channels so that the UI can receive events from data fetchers.

#### _Look at the unknown! Can you think of an analogous problem?_
Yes, we dealt with an analogous problem to the <span class="label t">education</span> unknown while implementing the feature for [Additional AWS Resources (addons)](https://aws.github.io/copilot-cli/docs/developing/additional-aws-resources/).

These problems are _similar_ because both of them need to parse CloudFormation YAML templates to read specific fields. We observed that the Go library provides a type, [`yaml.Node`](https://pkg.go.dev/gopkg.in/yaml.v3#Node), that stores the comments associated with a node in the template. We can use the `node.FootComment` field to retrieve the description of the resource.

_Side note: during implementation, we discovered that CloudFormation provides a [Metadata](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-metadata.html) attribute for resources. This provided a more robust and generic solution than comments for adding arbitrary information to our resources:_
```yaml
Service:
  Metadata:
    'aws:copilot:description': 'An ECS service to run and maintain your tasks in the environment cluster'
```

## Carrying out the plan
At this point we are pretty confident that we can start implementing.

## Takeaways
While working on this feature, few heuristics stood out to me as being highly effective to solving a practical problem:
* _Decompose and Recombine_, or [divide and conquer](https://en.wikipedia.org/wiki/Divide-and-conquer_algorithm). Trying to tackle all the unknowns at once can be overwhelming. Instead consider each unknown one at a time. Find out how to connect the data to the unknown while meeting the requirements, and then move bottom up until all requirements are met.
* _Analogy_, and _Do you know a related problem?_ Exploring solutions that had a similar problem, or share a similar aspect was hugely beneficial. Starting off on the shoulder of other solutions allowed us to make incremental improvements. We ended up incorporating both results from related solutions as well as their methods (implementations) in our solution. 
* _What is the unknown?_ Practical problems will have multiple unknowns. Write down each unknown every step of the way, and focus your attention on how to link the data to the unknown.