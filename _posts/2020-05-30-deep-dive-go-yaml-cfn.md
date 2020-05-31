---
layout: post
title: A deep dive into the Go YAML library with CloudFormation
tags: [golang]
---

This post is a bit unusual and explores how the Go YAML library ([gopkg.in/yaml.v3](http://gopkg.in/yaml.v3)) works internally by trying to figure out why unmarshaling and marshaling back a [CloudFormation (CFN) template](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html) in Go doesn't work by default.

```go
func main() {
	var cf interface{}
	yaml.Unmarshal([]byte(`
myMadeUpResource:
  Properties:
    splitTest: !Split [ "|" , "a||c|" ]
`), &cf)
	out, _ := yaml.Marshal(&cf)
	fmt.Println(string(out))
	// Prints:
	// myMadeUpResource:
	//   Properties:
	//       splitTest:
	//         - '|'
	//         - a||c|
}
```
If you have a keen eye, you might notice that the intrinsic CFN function [!Split](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-split.html) is dropped from the output! 

The library parses the YAML document into a tree of [yaml.Node](https://github.com/go-yaml/yaml/blob/2ff61e1afc866138abf1a8adf3cc89721090ac31/yaml.go#L348-L392) objects. Nodes have a few interesting fields:
* The `Kind` represents the high-level type of a node. For example, a scalar, a map, or a sequence.   
* The `Tag` is additional information about the data type of the node that's mostly useful when the Kind is a scalar. For example, "!!str", "!!int", "!!seq", or "!!map".  
* The `Value` is only populated if a node is a scalar otherwise its empty. 
* Finally, `Content` holds the child nodes and is only populated if the Kind is a map or sequence.

To visualize this information, let's see how `splitTest` is represented in the tree:

```
├── (Kind=scalar,   Tag=!!str,  Value="splitTest", Content=nil)
└── (Kind=sequence, Tag=!Split, Value="") # 2 nodes in Content below.
    ├── (Kind=scalar, Tag="!!str", Value="|",     Content=nil)
    └── (Kind=scalar, Tag="!!str", Value="a||c|", Content=nil) 
```
From the tree, we have two observations:
1. All sequences and maps are represented as a **pair** of nodes. The fist node is a scalar and the name of the sequence, “splitTest”, and the second node holds the elements of the sequence.
2. `!Split` shows up under the second node's Tag field. Normally, nodes with a "sequence" Kind have the "!!seq" tag. However, "!" is a special character, and thanks to it `!Split` gets parsed as local tag [[1]](#1) instead.

Unfortunately, since we marshaled the template into an empty interface we lose all this rich information ([decode.go#L722-725](https://github.com/go-yaml/yaml/blob/2ff61e1afc866138abf1a8adf3cc89721090ac31/decode.go#L722-L725)).

```go
case reflect.Interface:
	// No type hints. Will have to use a generic sequence.
	iface = out
	out = settableValueOf(make([]interface{}, l))
```
The sequence gets decoded to a `[]interface{}` and doesn't hold the fact that the Tag was `!Split`.
This is why when we marshal back `cf` into a YAML document, it treats the sequence as a regular "!!seq" node and ignores the intrinsic function! Mystery solved □.

#### So what now?
Luckily, [gopkg.in/yaml.v3](http://gopkg.in/yaml.v3) is pretty awesome and we can unmarshal a YAML document directly to a `yaml.Node`.
```go
func main() {
	var cf yaml.Node
	yaml.Unmarshal([]byte(`
myMadeUpResource:
  Properties:
    splitTest: !Split [ "|" , "a||c|" ]
`), &cf)
	out, _ := yaml.Marshal(&cf)
	fmt.Println(string(out))
	// Prints:
	// myMadeUpResource:
	//   Properties:
	//     splitTest: !Split ["|", "a||c|"]
}
```
This marshals the output as we want 🙌! This is because when the library encodes a sequence node, if the tag is not the default "!!seq" it retains it ([encode.go#L451-L456](https://github.com/go-yaml/yaml/blob/2ff61e1afc866138abf1a8adf3cc89721090ac31/encode.go#L451-L456)), and then writes the local tag to the output ([encode.go#L477](https://github.com/go-yaml/yaml/blob/2ff61e1afc866138abf1a8adf3cc89721090ac31/encode.go#L477)):
```go
...
case SequenceNode:
	rtag = seqTag /* rtag = !!seq */
}
if rtag == stag { /* stag = !Split */
	tag = ""
}
...
/* tag != "" so write it */
e.must(yaml_sequence_start_event_initialize(&e.event, []byte(node.Anchor), []byte(tag), tag == "", style))
```

<span id="1">[[1]](#1)</span> [https://camel.readthedocs.io/en/latest/yamlref.html#tags](https://camel.readthedocs.io/en/latest/yamlref.html#tags)