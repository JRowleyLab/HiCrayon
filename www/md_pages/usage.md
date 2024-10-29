
-----------------------------------------------------------------
# Usage Guide

Congratulations! You should now have the functioning HiCrayon app on your local device. Let's give it a whirl.

First, let's get a lay of the land. To open HiCrayon, follow the instructions in the [Installation](/www/md_pages/installation.md) page. You can then open up a local verision of the app in your web browser and should be greeted with the following screen: 

<div style="text-align: center;">
  <img src="/www/images/Usage_Guide/Opening_View.png" alt="Opening View" style="border: 2px solid #000000; border-radius: 10px;" width="1000" />
</div>

<!-- ![Opening View](/www/images/Usage_Guide/Opening_View.png) -->

You will be greeted by three sections.

**Hi-C:** Loads the Hi-C 'canvas' that we want to visualize.

**Features:** Loads the ChIP-seq data that will 'color' the Hi-C canvas.

### Loading your first Hi-C map

Loading a Hi-C map is simple. First, click on the '+' to open the options.

<div style="text-align: center;">
  <img src="/www/images/Usage_Guide/HiC_View.png" alt="HiC View" style="border: 2px solid #000000; border-radius: 10px;" width="600" />
</div>

<!-- ![Hi-C View](/www/images/Usage_Guide/HiC_View.png) -->
</br></br>
To begin, we will load a publicly available map from the ENCODE dataset. We can search by experiment, and will use the ENCSR123UVP experiment with the GRCh38 genome assembly. To select a map, click it from the list and then press the "Load" button at the bottome of the pop-up.

<div style="text-align: center;">
  <img src="/www/images/Usage_Guide/ENCODE_View.png" alt="ENCODE View" style="border: 2px solid #000000; border-radius: 10px;" width="1000" />
</div>

<!-- ![ENCODE View](/www/images/Usage_Guide/ENCODE_View.png) -->
</br></br>
Users can also specify a local Hi-C file using the 'Select HiC' button, navigating to the desired .hic file, selecting the file and pressing the 'Select' button in the lower right corner.

Hi-C matrices contain a vast amount of information on pairwise interacitons between genomic regions.

Choosing a locus of interest is very important when studying Hi-C data. For this example, let's start with a famous locus and CTCF loop, *Myc*. 
- It is found on chromosome 8, around position 127,740,000 bp. 
- CTCF loops often surround gene regions, so let's look at a 2.5 Mb area surrounding *Myc* from 126,000,000-128,500,000. We will select this as the start and stop range for the Hi-C.
- Finally, we must choose a resolution and normalization to vizualize at. Since we are looking at a 2.5 Mb area, let's look at the fine scale resolution of 10 kb or 10000. Normalization will affect the smoothness of the Hi-C data, but we will use NONE to visualize the raw data.

Cool! Huh?


[Return to Main Page](/README.md)
