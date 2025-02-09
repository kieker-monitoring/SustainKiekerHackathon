Let's go through basics of out Otkt that you will need to complete the Coding task of our survey.

## Spans Declaration

Lets look at how Span Models are Declared:

```
Span as: {
  //here you describe how you want to refer to the standard span parameters inside of your DSL
  trace:  trace
	parentTrace:   parentspan
	spanId:  spanId
	startT:  startT
  finishT: finishT
	
  //Here you specify the custom attributes that can be added to a span by OtelUser.
  // Here it is important that the name corresponds to that used inside of you monitoring code
	attributes:
  type string message
	type bool is_off
	type int int_num
	type long long_num
	type int branch_id
	type int branching_outcome

}
```
You can specify multiple Spans.
Additionaly you can annotate the custom parameters with additional information.

```
type int num inc by 1 global
type int num2 dec by 1 parent
```
In this example, we indicate that "num" is incremented by one after each span is created. "num2" indicates that "num2" is decremented by one after each parent span is output. So if ParentSpan "num2" was 2, then the child will be 1.
This will create the necessary processors.



After you specified all Span types (each span must have a name by which we differentiate the Span Types), you can specify a custom record.
A custom span record is introduced with the new: keyword, followed by the name of your custom record. The keyword "flow" indicates that you do not need to specify the traceID, SpanId, ParentSpan ID start time, and finishTIme information.
They are added automatically.
The keyword `normal` indicates that the user has to specify everything manually.
The keyword `beforefore` refers to the fact that an additional TeeTime stage is generated that splits the user-specified record into before and after events.
```
new: ExampleRecord flow {
	int int_num
	long long_num	
}

new: ExampleRecord2 normal {
	long trace
	long spanId
	string message
	bool flag
}


new: ExampleRecord2 beforeafter {
	string coolParameter
}
```
Additionally you can simple declare that you want to reuse the predefined fixed MonitoringRecord provided by Kieker by Default: For Example
```
Reuse: BranchingRecord
```

Now you can specify a mapping:
Mapping is introduced by Keyword Mapping, followed by references of span and the Monitoring Record. We use Hasskel like operator "->" to denote the mapping types.

Within the mapping, each parameter is referenced by the structure in which it is contained, followed by a dot and the name of that parameter. The mapped parameters are separated by the "to" keyword.
```
Mapping: as -> ExampleRecord2 {
	as.trace to ExampleRecord2.trace
	as.spanId to ExampleRecord2.spanId
	as.is_off to ExampleRecord2.flag
	as.message to ExampleRecord2.message
	}

Mapping: as ->BranchingRecord{
	as.startT to BranchingRecord.timestamp
	as.branch_id to BranchingRecord.branchID
	as.branching_outcome to BranchingRecord.branchingOutcome
	}
```
You can also just rely on the default mappings. However, this mapping assumes that you have the correct attribute names.  So, it is better to use custom mappings as shown above.
```
default mapping spanName ->  OperationExecutionRecord
```
Finally, you specify a collector in the following way.
```
collector:{
		port: 4137
		hostname: localhost
}
```
To sum it up, your otkt.file will loke something like this in complete.
```
Span: spanName {
  //here you describe how you want to refer to the standard span parameters inside of your DSL
  trace:  trace
	parentTrace:   parentspan
	spanId:  spanId
	startT:  startT
  finishT: finishT
	
  //Here you specify the custom attributes that can be added to a span by OtelUser.
  // Here it is important that the name corresponds to that used inside of you monitoring code
	attributes:
  type string message
	type bool is_off
	type int int_num
	type long long_num
	type int branch_id
	type int branching_outcome
	type int num inc by 1 global
	type int num2 dec by 1 parrent

}

new: ExampleRecord flow {
	int int_num
	long long_num	
}

new: ExampleRecord2 normal {
	long trace
	long spanId
	string message
	bool flag
}


new: ExampleRecord2 beforeafter {
	string coolParameter
}
Reuse: BranchingRecord

Mapping: as -> ExampleRecord2 {
	as.trace to ExampleRecord2.trace
	as.spanId to ExampleRecord2.spanId
	as.is_off to ExampleRecord2.flag
	as.message to ExampleRecord2.message
	}

Mapping: as ->BranchingRecord{
	as.startT to BranchingRecord.timestamp
	as.branch_id to BranchingRecord.branchID
	as.branching_outcome to BranchingRecord.branchingOutcome
	}
default mapping as ->  OperationExecutionRecord

collector:{
		port: 4137
		hostname: localhost
	}

```
