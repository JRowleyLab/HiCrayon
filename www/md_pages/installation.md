
-----------------------------------------------------------------
# Installation

## **Singularity**

Singularity allows deployment of HiCrayon using a container so you don't need to worry about software compatibility issues.

#### Build singularity image from docker image

Build a singularity container from a docker image.

1. `singularity build hicrayon.sif docker://nolandocker/hicrayon:v2`

Clone the hicrayon git repository.

2. `git clone https://github.com/JRowleyLab/HiCrayon.git`

`cd` into the HiCrayon directory and run the app inside the container

3. `singularity exec hicrayon_container.sif Rscript run.R`

### **Conda** (Not recommended)

1. Create a conda environment with the hicrayon yaml file

`conda create -n hicrayon hicrayon.yml`

2. `conda activate hicrayon`

Clone the hicrayon git repo and `cd` into the repo

3. `git clone https://github.com/JRowleyLab/HiCrayon.git`

Run HiCrayon

4. `Rscript run.R`


[Return to Main Page](/README.md)