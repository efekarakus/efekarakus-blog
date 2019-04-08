---
layout: post
title: Move function to method
categories: [refactoring, golang]
---

```go
// before
func ToCFNTemplate(t* SomeType) string { ... }

// after
func (t *SomeType) CFNTemplate() string { ... }
```

# Scenario
A few days ago, I was working on transforming a [YAML](https://yaml.org/) file that represents a microservice into a [CloudFormation](https://aws.amazon.com/cloudformation/aws-cloudformation-templates/) template.

This is roughly the code that I started with:
```go
package service

type Service struct {
	Name      string `yaml:"name"`
	ImageURL  string `yaml:"imageUrl"`
	CPU       int    `yaml:"cpu"`
	Memory    int    `yaml:"memory"`
}

func ToCFNTemplate(s *Service) string {
  return `
AWSTemplateFormatVersion: '2010-09-09'
Parameters:
  ServiceName:
    Type: String
    Default: ` + s.Name + `
  ImageUrl:
    Type: String
    Default: ` + s.ImageURL + `
  ContainerCpu:
    Type: Number
    Default: ` + s.CPU + `
  ContainerMemory:
    Type: Number
    Default: ` + s.Memory 
    // the rest of the template
}
```
