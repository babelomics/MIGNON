---
layout: default
title: Installation
nav_order: 2
---

## Requirements

From a programmatic perspective, MIGNON is a chain of tasks written in the [Workflow Description Language](https://github.com/openwdl/wdl). Users need to install and download the following software to execute the workflow:

### [Java](https://www.java.com/es/download/)

Java is used to execute the workflow management software that interprets and launch the different tasks within the pipeline. Once installed, users can check the version with `java -version`:

```
$ java -version
openjdk version "1.8.0_275"
OpenJDK Runtime Environment (build 1.8.0_275-8u275-b01-0ubuntu1~18.04-b01)
OpenJDK 64-Bit Server VM (build 25.275-b01, mixed mode)
```

### [Docker](https://www.docker.com/)

Docker (or any engine able to run docker containers, as [Singularity](https://sylabs.io/docs/) is used to execute all the tasks of the workflow within an isolated unit of containerized software, freeing users to install each of the needed components of the pipeline. Once installed, users should be able to get the following output after executing `docker run hello-world`:

```
$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

### [Cromwell](https://github.com/broadinstitute/cromwell)

Users need to download the **cromwell-XX.jar** file that can be retrieved from the cromwell releases page. Particularly, MIGNON was tested with the release 47 of cromwell, which can be obtained in the [following link](https://github.com/broadinstitute/cromwell/releases/tag/47). Cromwell is the scientific workflow engine that interprets and executes the pipeline. It is the software why users need to have Java v1.8.0 installed.

### [MIGNON](https://github.com/babelomics/MIGNON/)

Users can download the latest MIGNON code from our Github repository. Users with [git](https://git-scm.com/) can clone the repository using:

```
$git clone https://github.com/babelomics/MIGNON.git
```
On the other hand, if you are not using git, you can get a zipped version of the code on the following link.

```