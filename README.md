# SustainKieker Hackathon: Reverse Engineering of Research Software

🗓️ Thu 27/02, 13:30
<br>📍 Room SR 206, Building 30.70, Campus South (KIT)
<br>ℹ️ [Abstract](https://events.hifis.net/event/1741/contributions/14031/)
<br>🌐 [The SustainKieker Project Homepage](https://sustainkieker.kieker-monitoring.net)
<br>🔬 [The Kieker Observability Framework](https://kieker-monitoring.net)

## What is it about?

[Kieker observability framework](https://kieker-monitoring.net/) features monitoring and analysis capabilities.
OpenTelemetry, in comparison, provides means to monitor the program but analysis. Our new [Otkt DSL](https://github.com/silvergl/OtktDSL) can define a mapping from an OpenTelemetry Span to a Kieker record.
Using Otkt, we show how we can use OpenTelemetry to collect monitoring data from a Python program and send it to a Kieker Analysis endpoint.

## Prerequistes

1. Python3

3. Java (e.g., OpenJDK 21)
   ```bash
   # Fedora 40, 41, 42
   sudo dnf install java-21-openjdk-devel
   # Ubuntu 20.04, 22.04, 24.04, 24.10
   sudo apt install openjdk-21-jdk
   ```
4. Maven
   1. Install manually: [https://maven.apache.org/install.html](https://maven.apache.org/install.html)
   2. From distribution repositories:
      ```bash
      # Fedora 40, 41, 42
      sudo dnf install maven
      # Ubuntu 20.04, 22.04, 24.04, 24.10
      sudo apt install maven
      ```
5. [GNU plotutils](http://www.gnu.org/software/plotutils/)
   ```bash
   # Fedora 40, 41, 42
   sudo dnf install plotutils
   # Ubuntu 20.04, 22.04, 24.04, 24.10
   sudo apt install plotutils
   ```
6. The [graphviz](http://www.graphviz.org/) graph visualization tools
   ```bash
   # Fedora 40, 41, 42
   sudo dnf install graphviz
   # Ubuntu 20.04, 22.04, 24.04, 24.10
   sudo apt install graphviz
   ```

## Important

Instrumenting a Python software may require downloading the source code and
building a package. In this case, follow the instruction below and repackage it
yourself. It could be as simple as running `python3 -m build`. Otherwise, you
need to follow the provided build instruction.

```bash
# Instrument the target software before running the below commands
pip install build
python3 -m build
```

## Otkt DSL

* [BUILD.md](BUILD.md) describes how to build an Otkt program.
* The repository provides all artifacts from an Otkt build.

## Instructions

1. Build the Otkt collector with Maven.
   ```bash
   cd collector
   mvn clean package
   ```

2. To instrument a python program, export the parent path of the `otkt`
   directory to the `PYTHONPATH` variable:
   ```bash
   export PYTHONPATH=/path/to/parent/of/otkt:$PYTHONPATH
   ```
   i.e.,
   ```bash
   export PYTHONPATH=/path/to/hackathon/python:$PYTHONPATH
   ```

3. Prepend the following line to all Python files of the target program:
    ```python
    from otkt.otelinit import tracer
    ```

4. Prepend the following line before all Python method definitions:
   ```python
   @instrument
   ```

5. Make sure you have all required dependencies. A python project usually comes with `requirements.txt`. Append the following lines:

    ```
    opentelemetry-api==1.18.0
    opentelemetry-sdk==1.18.0
    opentelemetry-exporter-otlp==1.18.0
    opentelemetry-instrumentation==0.40b0
    kiekerforpython
    ```

6. Run the Otkt collector on a separate terminal.

   ```bash
   java -jar /path/to/Collector-0.0.1-SNAPSHOT-jar-with-dependencies.jar -c /path/to/config.txt
   ```

7. On a new terminal, run the target program (e.g., `python3 main.py` as
   below). You need the PYTHONPATH environmental variable exported to locate
   all otkt modules. See that the Otkt collector runs in the background to
   receive all created monitoring records. The collected monitoring recrods can
   be found in the output destination you specified in "config.txt" above.

    ```bash
    export PYTHONPATH=${PWD}:$PYTHONPATH
    python3 main.py
    ```

8. we use the Kieker Trace Analysis to analyze the target program.

## Options
1. The Otkt collector stores all received records under `/tmp`. E.g.,

   ```
   /tmp/kieker-20250217-181132-41826294550971-UTC--KIEKER/
   /tmp/kieker-20250218-093839-12420615078112-UTC--KIEKER/
   /tmp/kieker-20250218-114626-20087904425947-UTC--KIEKER/
   ```

   You can change the location by changing the value for
   `kieker.monitoring.writer.filesystem.FileWriter.customStoragePath` in
   [res/config.txt](res/config.txt).
