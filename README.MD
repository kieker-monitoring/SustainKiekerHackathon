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

5. Create `config.txt` with following content

6. 
``` 
## The name of the Kieker instance.
kieker.monitoring.name=KIEKER

## Auto detect hostname for the writer
kieker.monitoring.hostname=

## Output metadata record
kieker.monitoring.metadata=true


kieker.monitoring.writer=kieker.monitoring.writer.filesystem.FileWriter

## FileWriter settings
## output path


kieker.monitoring.writer.filesystem.FileWriter.customStoragePath=/path/to/kieker/ouput


kieker.monitoring.writer.filesystem.FileWriter.charsetName=UTF-8

## Number of entries per file
kieker.monitoring.writer.filesystem.FileWriter.maxEntriesInFile=25000

## Limit of the log file size; -1 no limit
kieker.monitoring.writer.filesystem.FileWriter.maxLogSize=-1

## Limit number of log files; -1 no limit
kieker.monitoring.writer.filesystem.FileWriter.maxLogFiles=-1

## Map files are written as text files
kieker.monitoring.writer.filesystem.FileWriter.mapFileHandler=kieker.monitoring.writer.filesystem.TextMapFileHandler

## Flush map file after each record
kieker.monitoring.writer.filesystem.TextMapFileHandler.flush=true

## Do not compress the map file
kieker.monitoring.writer.filesystem.TextMapFileHandler.compression=kieker.monitoring.writer.compression.NoneCompressionFilter

## Log file pool handler
kieker.monitoring.writer.filesystem.FileWriter.logFilePoolHandler=kieker.monitoring.writer.filesystem.RotatingLogFilePoolHandler

## Text log for record data
kieker.monitoring.writer.filesystem.FileWriter.logStreamHandler=kieker.monitoring.writer.filesystem.TextLogStreamHandler

## Do not compress the log file
kieker.monitoring.writer.filesystem.TextLogStreamHandler.compression=kieker.monitoring.writer.compression.NoneCompressionFilter

## Flush log data after every record
kieker.monitoring.writer.filesystem.FileWriter.flush=true

## buffer size. The log buffer size must be big enough to hold the biggest record
kieker.monitoring.writer.filesystem.FileWriter.bufferSize=81920 

```

7. Inside `collector/target` run `java -jar collector-jar-with-dependencies -c <path/to/config.txt>`

8. To instrument a python program copy and paste python files in generated `python` folder into the location of the python program.

9. Inside the entry point of your Python program paste

`import otelInit.py`

10. To instrument a python program you can either follow standard manual approach by changing each function definition :
* 
```
def foo():
      with tracer.start_as_current_span("foo") as foo:
            func_name = foo.__name__
            module = foo.__module__
            fq = f'{module}.{func_name}'
            foo.set_attribute("operation_signature", fq)
            foo.set_attribute("session_id", "<no-session-id>")
            foo.set_attribute("hostname", "localhost")
            foo.set_attribute("ess", "0")
            
            #Implementation here

    
}
```
* Alternatively you can predefine a decorator:
```
def instrument(func):
    attributes = { "ess": 0
    }
    def instrument_func(*args, **kwargs):
        with tracer.start_as_current_span("foo", attributes=attributes) as foo:
            func_name = func.__name__
            module = func.__module__
            fq = f'{module}.{func_name}'
            foo.set_attribute("operation_signature", fq)
            foo.set_attribute("session_id", "<no-session-id>")
            foo.set_attribute("hostname", "localhost")
            result = func(*args, **kwargs)

            return result
    return instrument_func
```
This decorator can then be used to annotate functions in python
```
@instrument
def foo():
    pass
```
11. You can run your code. The results of the kieker monitoring can be found in the output destination you specified in "config.txt" above.

12. To analyze the output you can use trace analysis of kieker. 
Download the trace-analysis tool.

13. Run 
