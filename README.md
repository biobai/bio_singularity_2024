# Bio_Singularity_2024

## Introduction
This repository provides a step-by-step guide for creating Singularity containers tailored for bioinformatics workflows, utilizing popular tools like bioconda, FastQC, Fastp, STAR, etc.


## Getting Started


## Building the Singularity Container
```Shell
podman build -t local/test:4.4.0 . -f dockerfiles/test.Dockerfile
podman save --format oci-archive --output test_4.4.0.tar localhost/local/test:4.4.0
sudo singularity build test_4.4.0.sif oci-archive://test_4.4.0.tar
```
## Using the Container
```Shell
scp test_4.4.0.sif ${server}:/~
```
in server:
```Shell
singularity shell -B /PUBLIC:/PUBLIC test_4.4.0.sif
```