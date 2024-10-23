
-----------------------------------------------------------------
# Installation

## **Singularity**

Singularity allows deployment of HiCrayon using a container so you don't need to worry about software compatibility issues.

#### Build singularity image from docker image

Build a singularity container from a docker image.

1. `singularity build hicrayon.sif docker://nolandocker/hicrayon`

Clone the hicrayon git repository.

2. `git clone https://github.com/JRowleyLab/HiCrayon.git`

`cd` into the HiCrayon directory and run the app inside the container

3. `singularity exec ~/Containers/hicrayon.sif R -e "shiny::runApp('app.R', launch.browser=F, port = 3838)" `

Additional parameters:
- if you'd like to attach a directory outside of your own: `-B /:/filesystem/`
- host application to allow access on another device (beware security risks): `shiny::runApp(..., host="IPADDRESS")`

### **Conda** (Not recommended)

1. Create a conda environment with the hicrayon yaml file

`conda create -n hicrayon hicrayon.yml`

2. `conda activate hicrayon`

Clone the hicrayon git repo and `cd` into the repo

3. `git clone https://github.com/JRowleyLab/HiCrayon.git`

Run HiCrayon

4. `R -e 'shiny::runApp("app.R", launch.browser=F)'`


[Return to Main Page](/index.md)