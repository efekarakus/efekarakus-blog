---
layout: post
title: A deep dive into the Go YAML library with CloudFormation
tags: [golang]
---

This post is a bit unusual and is a story about debugging. We explore how the Go YAML library ([gopkg.in/yaml.v3](http://gopkg.in/yaml.v3)) works internally by trying to figure out why unmarshaling and marshaling back a [CloudFormation (CFN) template](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html) in Go doesn't work by default.

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
If you have a keen eye, you might notice that the intrinsic CFN function, [!Split](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-split.html), is dropped from the output! 

The library parses the YAML document into a tree of [yaml.Node](https://github.com/go-yaml/yaml/blob/2ff61e1afc866138abf1a8adf3cc89721090ac31/yaml.go#L348-L392) objects. Nodes have a few interesting fields:
* The `Kind` represents the high-level type of a node. For example, a scalar, a map, or a sequence.   
* The `Tag` is additional information about the data type of the node that's mostly useful when the Kind is a scalar. For example, "!!str", "!!int", "!!seq", or "!!map".  
* The `Value` is only populated if a node is a scalar otherwise its empty. 
* Finally, `Content` holds the child nodes and is only populated if the Kind is a map or sequence.

To visualize this information, let's see how "splitTest" is rendered in the tree:

```
(Kind=mapping, Tag=!!map, Value="")
├── (Kind=scalar,   Tag=!!str,  Value="splitTest", Content=nil)
└── (Kind=sequence, Tag=!Split, Value="") # 2 nodes in Content below.
    ├── (Kind=scalar, Tag="!!str", Value="|",     Content=nil)
    └── (Kind=scalar, Tag="!!str", Value="a||c|", Content=nil) 
```
From the tree, we have two observations:
1. _Named_ sequences and maps are represented as a **pair** of nodes. The first node is the name of the sequence and a scalar, “splitTest”, and the second node holds the elements of the sequence.
2. "!Split" shows up under the node's Tag field. Normally, nodes with a "sequence" Kind have the "!!seq" tag. However, "!" is a special character, and thanks to it `!Split` gets parsed as local tag [[1]](#1) instead.

Unfortunately, since we marshaled the template into an empty interface we lose all this rich information.  
From [decode.go#L722-725](https://github.com/go-yaml/yaml/blob/2ff61e1afc866138abf1a8adf3cc89721090ac31/decode.go#L722-L725), the sequence `["|", "a||c|"]` gets decoded to a `[]interface{}`.
```go
case reflect.Interface:
	// No type hints. Will have to use a generic sequence.
	iface = out
	out = settableValueOf(make([]interface{}, l))
```
And then the slice gets assigned to a string map `map[string]interface{}`, where the key is the string "splitTest" and value is the slice [decode.go#L801-820](https://github.com/go-yaml/yaml/blob/2ff61e1afc866138abf1a8adf3cc89721090ac31/decode.go#L801-L820).
```go
if d.unmarshal(n.Content[i+1], e) {
	// k is "splitTest" and is unmarshaled from n.Content[i]
	// e is the []interface{} described above
	out.SetMapIndex(k, e) 
}
```

This is why when we marshal back `cf` into a YAML document, the intrinsic function is ignored! The map lost the local tag information about `!Split`. Mystery solved □.

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
This marshals the output as we want 🙌! This is because when we unmarshal to a `yaml.Node` no information is lost unlike the empty interface. Afterwards, when it marshals a sequence node, if the Tag is not the default "!!seq" ([encode.go#L451-L456](https://github.com/go-yaml/yaml/blob/2ff61e1afc866138abf1a8adf3cc89721090ac31/encode.go#L451-L456)), it writes it to the output ([encode.go#L477](https://github.com/go-yaml/yaml/blob/2ff61e1afc866138abf1a8adf3cc89721090ac31/encode.go#L477)):
```go
...
case SequenceNode:
	// rtag is set to "!!seq"
	rtag = seqTag 
}
if rtag == stag { 
	// stag is "!Split" and not equal to "!!set" 
	// so we keep the tag as "!Split" instead.
	tag = ""
}
...
// tag is not empty, so write it.
e.must(yaml_sequence_start_event_initialize(&e.event, []byte(node.Anchor), []byte(tag), tag == "", style))
```

#### Takeaways
While trying to figure out what happens when you (un)marshal a CFN template,
I found a few approaches pretty effective.

1. **Start from the entry point**.  
   Glancing at `yaml.Unmarshal`, I found out about the `yaml.Node` data structure and the
	 [d.unmarshal](https://github.com/go-yaml/yaml/blob/2ff61e1afc866138abf1a8adf3cc89721090ac31/decode.go#L475) method that holds the main decoding logic.
2. **Visualize the data**.  
   After printing the AST, I made the hypothesis that named sequences and maps are rendered as a pair of nodes.
	 That must mean that somewhere in the code there is a "+1". A quick search, led me to confirm my
	 hypothesis and understand how maps are unmarshaled.
3. **Use the debugger**.  
   The debugger is extremely helpful to figure out which code path is taken during execution and what the variables in the scope hold.

<span id="1">[[1]](#1)</span> [https://camel.readthedocs.io/en/latest/yamlref.html#tags](https://camel.readthedocs.io/en/latest/yamlref.html#tags)