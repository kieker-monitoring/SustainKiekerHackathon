# Tutorial

## What is it about?

Kieker is a monitoring framework that features monitoring and analysis capabilities.
OpenTelemetry on the other side provides means to monitor the program and the analysis must be performed with other tools.
In this tutorial we show how we can use OpenTelemetry to collect monitoring data and send it to Kieker Analysis endpoint.

## Instructions

### Otkt generator

1. Create a file with `.otkt` extensions.

2. Fill it with the following contents:

``` 
Span: Foo {
	trace:  trace
	parentTrace:   parentspan
	spanId:  spanId
	startT:  startT
	endT: endT

	attributes:
	type string operation_signature
	type string session_id
	type int eoi
	type int ess
	type string hostname

}	

new: CustomRecord normal {
	int numeric
	string text
	bool flag
}


Reuse: OperationExecutionRecord

default mapping Foo -> OperationExecutionRecord



collector:{
	port: 1234
	hostname: "localhost"
}

```

3. Run `java -jar otkt.jar <otkt/file > <output/destination>`

4. In the ouput folder you will find `collector` and `python` folders.
Go to `collector` and run `mvn compile` `mvn install`

5. 
