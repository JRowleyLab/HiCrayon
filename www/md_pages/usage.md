
-----------------------------------------------------------------
# Usage Guide

Congratulations! You should now have the functioning HiCrayon app on your local device.

In this document you'll find step-by-step instructions on how to use HiCrayon. From loading up a Hi-C file, to adding a bunch of different features and visualizing all simultaneously, and finally downloading all the produced images.

To open HiCrayon, follow the instructions in the [Installation](/www/md_pages/installation.md) page. You can then open up a local verision of the app in your web browser.

## Landing page

You will be greeted by three sections.

**Hi-C (2D):** Loads the Hi-C 2-dimensional 'canvas' that we want to visualize.

**Features (1D):** Loads the traditionally 1-dimensional data (e.g. bigwig, bedgraph) that will 'color' the Hi-C canvas.


<div style="text-align: center;">
  <img src="../logo/usage_images/landing_page.png" alt="Landing_pge" width="400" />
</div>

-------------------------------------

## Hi-C

On the sidebar, click on the '+' to open the options. There are a few ways you can get a Hi-C file into HiCrayon. 

1) **Select HiC**: Local File Upload. 


<div style="display: inline-block;">
  <img src="../logo/usage_images/hic/hic_upload.png" alt="enc2_upld" width="200" style="vertical-align: top;" />
  <img src="../logo/usage_images/hic/hic_filesBLUR.png" alt="enc_upld" width="400" style="vertical-align: top;" />
</div>


2) **Load URL**: Paste in a Hi-C URL and click the load URL button. Details on where to get a link are below.

3) **ENCODE**: Choose a Hi-C file from a database of ENCODE-hosted files. This loads in a Hi-C *via* URL.


<div style="text-align: center;">
  <img src="../logo/usage_images/hic/ENCODE.png" alt="enc_upld" width="300" />
</div>





To begin, we will load a publicly available map from the ENCODE dataset. Either choose the ENCODE button to choose between over a hundred Hi-C maps, over enter the URL of the `.hic` file, like so:

`https://www.encodeproject.org/files/ENCFF573OPJ/@@download/ENCFF573OPJ.hic` <p>

To obtain a link to a file from ENCODE, right click and copy the link from the download button on the experiment page.

<div style="text-align: center;">
  <img src="../logo/usage_images/hic/encode_hic.png" alt="enc_upld" width="300" />
</div>

Users can also specify a local Hi-C file using the 'Select HiC' button, navigating to the desired .hic file, selecting the file and pressing the 'Select' button in the lower right corner. 

Hi-C matrices contain a vast amount of information on pairwise interacitons between genomic regions.

### Advanced Options

Click the 'Options' box at the bottom of the page for more options.

1. `Scale ChIP w/ Hi-C`. Default: True. Weight 1D feature score by Hi-C interaction score. 

2. `Distance Normalization`. Checking this box will apply a `observed/expected+1` normalization to the Hi-C map.

<div style="display: inline-block;">
  <img src="../logo/usage_images/hic/hic_distnorm.png" alt="enc_upld" width="300" style="vertical-align: top;" />
  <img src="../logo/usage_images/hic/hic_nodistnorm.png" alt="enc2_upld" width="300" style="vertical-align: top;" />
</div>

3. `HiC Threshold`: Choose the maximum value for the Hi-C interaction score. This will represent the upper limit of color range. 
**Recommended**:
*Distance-Normalized*: 2
*Raw*: Varies based on sequencing depth. Values are comparable between Juicebox and HiCrayon.
-------------------------------------

## Features 

Now we need to choose some features to color the Hi-C map by. You can choose any bigwig, bedgraph or bed file you'd like to visualize. These datatypes are typical outputs for genomic methods such as, **ChIP-seq**, **CUT&RUN**, **RNA-seq**, **ATAC-seq**. 
<p>
Here's an example of some of the things you can do:

  * Color multiple features on a single Hi-C image.
  * Color Hi-C eigenvector with A compartment, B compartment and A-B compartment interactions. 
  * Color interactions between two distinct chromatin features, such as H3K27ac and H3K9me3 interactions.

We'll go into more detail on each of these features down below.

### Bigwig

A standard output format for many genomic methods. 

### Bedgraph


### Bed


### Advanced Options

1. Log <p>
You can log transform (Log2) your data for visualization. This can be helpful for when you have a large range in 



[Return to Main Page](/README.md)
