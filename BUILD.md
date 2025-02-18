# Building an Otkt DSL program

## Introduction to the Otkt DSL

The following Otkt demo program defines a mapping from an OTel Span to a Kieker OperationExecutionRecord.

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

## Instructions

1. Build an Otkt program with the below command:

   ```bash
   java -jar tools/Otkt-1.0.jar examples/demo.otkt MyOutput
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
