
-----------------------------------------------------------------
# Installation

To use HiCrayon, we'll need to install some R and Python packages. There's a couple options for downloading these. 

1. A portable container, holding all necessary packages for you. You can use it by installing Singularity (https://docs.sylabs.io/guides/3.0/user-guide/installation.html). Then follow instructions below on using HiCrayon.
2. Download all the packages manually, or by using a Conda environment. We don't recommend this as it'll take a long time and introduces the possibility of package dependency issues. Instructions on the Conda method are below too.

## **Singularity**

Singularity allows deployment of HiCrayon using a container so you don't need to worry about software compatibility issues.

#### Build singularity image from docker image

Build a singularity container from a docker image.

1. `singularity build hicrayon.sif docker://nolandocker/hicrayon:v2`

Clone the hicrayon git repository.

2. `git clone https://github.com/JRowleyLab/HiCrayon.git`

`cd` into the HiCrayon directory and run the app inside the container

3. `singularity exec hicrayon_container.sif Rscript run.R`

-----------------------------------------------------------------
### Optional parameters:

1.  Port number for server access Eg. 3838 <p>
`--port <number>`
2. Bind server to IP address. Eg. 0.0.0.0 <p> 
`--host <host_address>`

To access HiCrayon on your device, you would then type the following host and port combination in your URL on a browser, like Chrome or Firefox: <p>
`0.0.0.0:3838`

Running these parameters together looks like this: <p>
`singularity exec hicrayon_container.sif Rscript run.R --port 3838 --host 0.0.0.0`

If you're using Singularity and want to see folders outside your user folders, you'll need to 'bind' them for Singularity to see. Here's how you do that. To attach a folder '/' and name as '/filesystem' container (visible from the file upload buttons in HiCrayon):

`singularity exec -B /:/filesystem hicrayon_container.sif Rscript run.R`

3. Finally, a parameter that runs HiCrayon in restricted mode. Used for the web-application. *You likely won't use this* <p>
`--lite-mode`



## **Conda** (Not recommended)

1. Create a conda environment with the hicrayon yaml file

`conda create -n hicrayon hicrayon.yml`

2. `conda activate hicrayon`

Clone the hicrayon git repo and `cd` into the repo

3. `git clone https://github.com/JRowleyLab/HiCrayon.git`

Run HiCrayon

4. `Rscript run.R`


----------------------------

**NOTE:** When running HiCrayon locally, disconnect local HiCrayon instance by closing the browser first. If CTRL+C on command line is used first, the app won't be able to clean up temporary directories located in www/user*. You will have to remove these manually.


[Return to Main Page](/README.md)