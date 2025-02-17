# Tutorial

## What is it about?

[Kieker observability framework](https://kieker-monitoring.net/) features monitoring and analysis capabilities.
OpenTelemetry, in comparison, provides means to monitor the program but analysis. Our new [Otkt DSL](https://github.com/silvergl/OtktDSL) can define a mapping from an OpenTelemetry Span to a Kieker record.
Using Otkt, we show how we can use OpenTelemetry to collect monitoring data from a Python program and send it to a Kieker Analysis endpoint.

## Prerequistes

1. Maven
   1. Install manually: [https://maven.apache.org/install.html](https://maven.apache.org/install.html)
   2. From distribution repositories:
      ```bash
      # Fedora 40, 41, 42
      sudo dnf install maven
      # Ubuntu 20.04, 22.04, 24.04, 24.10
      sudo apt install maven
      ```
3. [GNU plotutils](http://www.gnu.org/software/plotutils/)
   ```bash
   # Fedora 40, 41, 42
   sudo dnf install plotutils
   # Ubuntu 20.04, 22.04, 24.04, 24.10
   sudo apt install plotutils
   ```
3. The [graphviz](http://www.graphviz.org/) graph visualization tools
   ```bash
   # Fedora 40, 41, 42
   sudo dnf install graphviz
   # Ubuntu 20.04, 22.04, 24.04, 24.10
   sudo apt install graphviz
   ```

## Instructions

1. The following Otkt demo program defines a mapping from an OTel Span to a Kieker OperationExecutionRecord. Create a file with the code and save it with an `otkt` extension.

   ```
   Span: OTelSpan {
           // Semantic types for the default OpenTelemetry span parameters
   	trace:  trace
   	parentSpan:   parentspan
   	spanId:  spanId
   	startT:  startT
   	endT: endT

           // Additional attributes to the OpenTelemetry span
   	attributes:
   	type string operation_signature
   	type string session_id
   	type int eoi
   	type int ess
   	type string hostname

   }

   // Declare usage of existing Kieker record type
   Reuse: OperationExecutionRecord

   // Describe a mapping between the OTel span and the Kieker record
   default mapping OTelSpan -> OperationExecutionRecord

   // Declare where the collector runs and recceives the Kieker records
   collector:{
   	port: 1234
   	hostname: "localhost"
   }
   ```

2. Build the Otkt program with the below command:

   ```bash
   java -jar otkt.jar MyMapping.otkt MyOutput
   ```

   It creates three Python modules and an Otkt collector:

   ```
   MyOutput/
   ├ otkt/
   │ ├ kiekerexporter.py
   │ ├ kiekerprocessor.py
   │ └ otelinit.py
   └ collector/
     ├ src/main/java/
     │ ├ Main.java
     │ └ CollectorConfiguration.java
     └ pom.xml
   ```

3. Build the Otkt collector with maven.
   ```bash
   cd MyOutput/collector
   mvn compile
   mvn install
   ```

4. Create `config.txt` with the following content.

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

   * Make sure to change the value for `kieker.monitoring.writer.filesystem.FileWriter.customStoragePath`. This is where all kieker records are stored as files.

5. To instrument a python program, copy and paste python files from the generated `python` folder into the location of your python program.

6. Inside the entry point of your Python program paste:
    ```python
    from otkt.otelinit import tracer
    ```

7. To instrument a python program you can either follow standard manual approach by changing each function definition:
    ```python
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

    * Alternatively, you can make a Python module `OTelInstument.py` defining a decorator (recommended):
      (Mapped to Kieker's OperationExecutionMethod)
       ```python
       from opentelemetry import trace

       # Create a OTel tracer
       tracer = trace.get_tracer(__name__)
       def instrument(func):
           attributes = { "ess": 0
           }
           def instrument_func(*args, **kwargs):
               with tracer.start_as_current_span("OTelSpan", attributes=attributes) as foo:
                   func_name = func.__name__
                   module = func.__module__
                   fq = f'{module}.{func_name}'
                   foo.set_attribute("operation_signature", fq) # We use module.func_name of Python program mapped as Java's fully qualified signature
                   foo.set_attribute("session_id", "<no-session-id>")  # session_id is only relevant with Kieker agent on Java applications
                   foo.set_attribute("hostname", "localhost") # Target application should provide hostname.
                   result = func(*args, **kwargs)

                   return result
           return instrument_func
       ```
    * This decorator can then be used to annotate functions in python
       ```python
       from otkt import instrument

       @instrument
       def foo():
           pass

       // For a class method:
       @classmethod
       @instrument
       def foo():
           pass

       // For a static method:
       @staticmethod
       @instrument
       def foo():
           pass
       ```
8. Make sure you have all required dependencies. A python project usually comes with `requirements.txt`. Append the following lines:
    ```
    opentelemetry-api==1.18.0
    opentelemetry-sdk==1.18.0
    opentelemetry-exporter-otlp==1.18.0
    opentelemetry-instrumentation==0.40b0
    kiekerforpython
    ```

9. Run the Otkt collector
   ```bash
   java -jar /path/to/Collector-0.0.1-SNAPSHOT-jar-with-dependencies.jar -c /path/to/config.txt
   ```

10. Run the target program. The results of the Kieker monitoring can be found in the output destination you specified in "config.txt" above.

11. we use the Kieker Trace Analysis to analyze the target program.
