
-----------------------------------------------------------------
# Usage Guide

Congratulations! You should now have the functioning HiCrayon app on your local device.

In this document you'll find step-by-step instructions on how to use HiCrayon. From loading up a Hi-C file, to adding a bunch of different features and visualizing all simultaneously, and finally downloading all the produced images.

To open HiCrayon, follow the instructions in the [Installation](/www/md_pages/installation.md) page. You can then open up a local verision of the app in your web browser.

## Landing page

You will be greeted by three sections.

**Hi-C (2D):** Loads the Hi-C 2-dimensional 'canvas' that we want to visualize.

**Features (1D):** Loads the traditionally 1-dimensional data (e.g. bigwig, bedgraph) that will 'color' the Hi-C canvas.


*image*

-------------------------------------

## Hi-C

On the sidebar, click on the '+' to open the options.

*image*

To begin, we will load a publicly available map from the ENCODE dataset. We can search by experiment, and will use the ENCSR123UVP experiment with the GRCh38 genome assembly. To select a map, click it from the list and then press the "Load" button at the bottome of the pop-up.

Users can also specify a local Hi-C file using the 'Select HiC' button, navigating to the desired .hic file, selecting the file and pressing the 'Select' button in the lower right corner.

Hi-C matrices contain a vast amount of information on pairwise interacitons between genomic regions.

### Advanced Options

1. 

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
