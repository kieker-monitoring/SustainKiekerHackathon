# SustainKieker Hackathon: Reverse Engineering of Research Software

🗓️ Thu 27/02, 13:30
<br>📍 Room SR 206, Building 30.70, Campus South (KIT)
<br>ℹ️ [Abstract](https://events.hifis.net/event/1741/contributions/14031/)
<br>🔬 [The Kieker Observability Framework](https://kieker-monitoring.net)
<br>🌐 [The SustainKieker Project Homepage](https://sustainkieker.kieker-monitoring.net)

## Table of Contents

1. [Introduction](#introduction)
1. [Prerequisites](#prerequisites)
   * [Linux system](#linux-system)
   * [Software](#software)
1. [Instructions](#instructions)
1. [More reads](#more-reads)

## Introduction

[Kieker observability framework](https://kieker-monitoring.net/) features monitoring and analysis capabilities.
OpenTelemetry, in comparison, provides means to monitor the program but analysis. Our new [Otkt DSL](https://github.com/silvergl/OtktDSL) can define a mapping from an OpenTelemetry Span to a Kieker record.
Using Otkt, we show how we can use OpenTelemetry to collect monitoring data from a Python program and send it to a Kieker Analysis endpoint.

## Prerequisites

### Linux system
   
#### macOS
* Multipass[^1] ([latest download](https://canonical.com/multipass/download/macos))
  - [x] M1, M2, or Intel based
  - [x] macOS 10.15 Catalina or later

[^1]: [Multipass](https://github.com/canonical/multipass) is a lightweight VM manager for Linux, Windows and macOS from Canonical.

#### Windows 10/11 (two options)
* Multipass ([latest download](https://canonical.com/multipass/download/windows))
  - [x] Windows 10 Pro or Enterprise version 1803 (“April 2018 Update”) or later
* WSL Install Instructions
  * [Windows 10 2004 or higher](https://learn.microsoft.com/en-us/windows/wsl/install)
  * Old versions: [Windows 10 1903 or higher](https://learn.microsoft.com/en-us/windows/wsl/install-manual)

### Software
1. Python3

1. Java
   ```bash
   # Fedora 40, 41, 42
   sudo dnf install java-21-openjdk-devel
   # Ubuntu 20.04, 22.04, 24.04, 24.10
   sudo apt install openjdk-21-jdk
   ```
1. Maven
   ```bash
   # Fedora 40, 41, 42
   sudo dnf install maven
   # Ubuntu 20.04, 22.04, 24.04, 24.10
   sudo apt install maven
   ```
   or [install manually](https://maven.apache.org/install.html).
1. [GNU plotutils](http://www.gnu.org/software/plotutils/)
   ```bash
   # Fedora 40, 41, 42
   sudo dnf install plotutils
   # Ubuntu 20.04, 22.04, 24.04, 24.10
   sudo apt install plotutils
   ```
1. The [graphviz](http://www.graphviz.org/) graph visualization tools
   ```bash
   # Fedora 40, 41, 42
   sudo dnf install graphviz
   # Ubuntu 20.04, 22.04, 24.04, 24.10
   sudo apt install graphviz
   ```

## Instructions

1. Build the Otkt collector.
   ```bash
   # Run inside the hackathon repository:
   cd collector
   mvn clean package
   ```

1. Export the `PYTHONPATH` variable with the parent path of the `otkt`
   directory.

   ```bash
   export PYTHONPATH=/path/to/hackathon-repo/python:$PYTHONPATH
   ```

1. Instrument all python files of the target software using [`instrument-py.sh`](tools/instrument-py.sh)

   ```bash
   # Run inside the target software repository:
   /path/to/hackathon-repo/tools/instrument-py.sh
   ```

   * It is important to adhere to the indentation of each method definitions.

1. Install all required python module dependencies. A python project usually
   comes with `requirements.txt`. Append all dependencies in
   [res/requirements.txt](res/requirements.txt) to the existing (or new)
   `requirements.txt`.

   ```bash
   # Run inside the target software repository:
   pip install -r requirements.txt 
   ```

1. Run the Otkt collector on a separate terminal.

   ```bash
   java -jar /path/to/Collector-0.0.1-SNAPSHOT-jar-with-dependencies.jar -c /path/to/config.txt
   ```

1. On a new terminal, run the target program (e.g., `python3 main.py`).

    ```bash
    # Run inside the target software repository:
    python3 main.py
    ```

1. we use the Kieker Trace Analysis to analyze the target program.

## More Reads
1. The Otkt collector stores all received records under `/tmp`. E.g.,

   ```
   /tmp/kieker-20250217-181132-41826294550971-UTC--KIEKER/
   /tmp/kieker-20250218-093839-12420615078112-UTC--KIEKER/
   /tmp/kieker-20250218-114626-20087904425947-UTC--KIEKER/
   ```

   You can change the location by changing the value for
   `kieker.monitoring.writer.filesystem.FileWriter.customStoragePath` in
   [res/config.txt](res/config.txt).

1. Packaging a python software

   Instrumenting a Python software may require downloading the source code and
building a package. In this case, follow the instruction below and repackage it
yourself. It could be as simple as running `python3 -m build`. Otherwise, you
need to follow the provided build instruction.

   ```bash
   # Instrument the target software before running the below commands
   pip install build
   python3 -m build
   ```

1. Building an Otkt program

   For the Hackathon, we provide all artifacts from the Otkt build of the Otkt source code [demo.otkt](examples/demo.otkt). For more details, refer to [BUILD.md](BUILD.md).

1. Building the Otkt compiler

   The Otkt compiler is maintained in the GitHub repository [OtktDSL](https://github.com/silvergl/OtktDSL). The instruction will be uploaded soon.
