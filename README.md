<div style="text-align: center;">
  <img src="www/logo/hicrayon_logo.png" alt="HiCrayon Logo" width="750" />
</div>

------------------------------------------
# About

Welcome to HiCrayon! 

HiCrayon is a tool used to visualize the complex layering of chromatin organization across Hi-C, Micro-C, ChIP-seq, and CUT&RUN in a single image!

Use HiCrayon create beautiful images vizualizing 1D tracks on 2D matrices.

<div style="text-align: center;">
  <img src="/www/logo/Magnum_Opus.png" alt="Magnum_Opus" width="1200" />
</div>

------------------------------------------
# Quick Start

Upon successful installation of HiCrayon, the user can move into the HiCrayon directory and run the provided wrapper script with minimal parameter specifications for a streamlined experience with this command:
```Rscript run.R```

Simply navigate to the specified address and port in a web browser to begin coloring.

Optional parameters include:
```
--port <number> port number for server access Eg. 3838
--host <host_address> Bind server to IP address. Eg. 0.0.0.0
Host and port combination example: 0.0.0.0:3838
--lite-mode Web-application version. Allows restricted client side file upload.
```

For a more modular option, run with singularity:
```
singularity exec hicrayon_container.sif Rscript run.R
singularity exec /Zulu/bnolan/Containers/hicrayon_v2.sif Rscript run.R --port 8887 --host 10.49.148.30
```
Attach a folder '/' and name as '/filesystem' container (visible from file upload)
```
singularity exec -B /:/filesystem hicrayon_container.sif Rscript run.R
```

---------------------------------------------
# Documentation

Please visit [our wiki](https://github.com/JRowleyLab/HiCrayon/wiki) for a detailed explanation of installation, usage, and features of HiCrayon.

---------------------------------------------
# Web version

A *lite* version of HiCrayon is availble at:

<span style="background-color: lightgreen; font-size: 18px; padding: 2px;">
  <a href="https://jrowleylab.com/HiCrayon/" style="font-weight: bold;">jrowleylab.com/HiCrayon/</a>
</span>
</br></br>

**This version supports ONLY small file uploads.**
Small Hi-C maps or 1D tracks can be uploaded, but we have implemented a size cap. However, published Hi-C maps and bigwigs from ENCODE (https://www.encodeproject.org/) are able to be visualized in their entirety.
<!-- and locally stored small bedGraph files. -->

To fully avail of the utility of HiCrayon, please [Install](/www/md_pages/installation.md) a local version of the app.

---------------------------------------------
# Requirements for Installation
To install HiCrayon, we use containerized Singularity that allows for a portable, reproducible environment.  
* [Singularity](https://github.com/JRowleyLab/HiCrayon/wiki/installation) is our primary method has excellent [installation](https://docs.sylabs.io/guides/3.0/user-guide/installation.html) documentation.
* [Conda](https://github.com/JRowleyLab/HiCrayon/wiki/installation) is also available but **NOT** recommended.

At least 10 gigabytes of storage are recommended for installation of the application, singularity image, and storage of the large experiment files.

---------------------------------------------
# Contacts
HiCrayon is available for public use, and accompanies the publication  https://doi.org/10.1101/2024.02.11.579821.

Please address questions to the primary author: bnolan@unmc.edu



