import numpy as np
import hicstraw
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.pyplot as plt 
import pyBigWig
import math
import pandas as pd
import requests
import re
from collections import defaultdict


def getHiCmetadata(hicfile):
	# Given a hic-pro file upload, return
	# multiple lists of metadata
	# Chr name, resolutions, normalizations
	try:
		hicdump = hicstraw.HiCFile(hicfile)
	except:
		return("NA")


	# Chromosome list
	chroms = hicdump.getChromosomes()[1:]
	chrlist = []
	lengths = []
	for x in chroms:
		chrlist.append(x.name)
		lengths.append(x.length)
	
	# Resolution list
	res = hicdump.getResolutions()

	return chrlist, res, lengths, hicdump


def checkURL(url, filetype):
    #check string is valid url
    url_pattern = re.compile(r"^(https?|ftp)://[^\s/$.?#].[^\s]*$")
    if(bool(url_pattern.match(url))):
		#check url is downloadable content
        r = requests.get(url, stream=True)
        isattachment = 'attachment' in r.headers.get('Content-Disposition', '')
        if(isattachment):
			#check downloadable content is correct filetype
            file = r.headers.get('Content-Disposition', '')
            string = 'attachment; filename='
            filename = re.sub(string, "", file)
            suffix = filename.split('.')[1]
            if(suffix in filetype):
                return("Valid")
    return("Not valid")

def hicMatrixZoom(hicdump, chrom, norm, binsize):
	hicobject = hicdump.getMatrixZoomData(chrom, chrom, "observed", norm, "BP", binsize)
	return hicobject

# Read in HiC file and output selected coordinates + binsize
# as matrix. 
def readHiCasNumpy(hicobject, chrom, start, stop, norm, binsize):

	#hicdump = hicstraw.HiCFile(hicfile)
	
	#hicobject = hicdump.getMatrixZoomData(chrom, chrom, "observed", norm, "BP", binsize)

	# .getRecordsAsMatrix results in a segmentation fault when a matrix of
	# too great a size is provided. ie. hicnumpy = hicobject.getRecordsAsMatrix(x1,y1,x2,y2)
	# The below method uses .getRecords which creates a list of contacts, which allows 
	# streaming of data in a way that doesn't load into memory all at once.
	hiclist = hicobject.getRecords(start, stop, start, stop)

	size = int((stop-start)/binsize)
	mat = np.zeros((size+1, size+1))	

	for cr in hiclist:
		r = int((cr.binX - start) / binsize)
		c = int((cr.binY - start) / binsize)
		mat[r,c] = cr.counts
		mat[c,r] = cr.counts

	return mat

# Cut down version of distanceMat() to work for just HiC Map
# Obtain distance matrix of HiC map,
# Normalized using threshold value
def distanceMatHiC(hicnumpy, thresh, distnorm):
	
	matsize = len(hicnumpy)

    # Distance normalize
	if distnorm == True:
		mydiags=[]
		for i in range(0,len(hicnumpy)):
			mydiags.append(np.nanmean(np.diag(hicnumpy, k=i)))
		
	distnormmat = np.zeros((matsize,matsize))
	

	for x in range(0,matsize):
		for y in range(x,matsize):
			# set hicscore as distance normalized
			if distnorm == True:
				distance=y-x
				hicscore = (hicnumpy[x,y] + 1)/(mydiags[distance]+1)
			# or don't
			else:
				hicscore = hicnumpy[x,y]
			if hicscore > thresh:
				distnormmat[x,y] = thresh
				distnormmat[y,x] = thresh
				#satscore = 1
			else:
				distnormmat[x,y] = hicscore
				distnormmat[y,x] = hicscore
				#satscore = hicscore/thresh
	return(distnormmat)

# single bed/ bedgraph input: single bigwig path output
# chromHMM input: 
# ONE [[a.bigwig], [b.bigwig]] 
# TWO [[r,g,b], [r,g,b]]
def bedgraph_to_bigwig(input_file, output_bigwig_base, binsize, chromHMM):
    chrom_sizes = {}
    
    # Step 1: Gather chromosome sizes
    with open(input_file, 'r') as f:
        for line in f:
            if line.startswith("#") or line.strip() == "":
                continue
            
            components = line.strip().split()
            if chromHMM:
                chrom, start, end, state, value, _, _, _, color = components
                value = int(value)  # Column 5
            else:
                if len(components) < 3:
                    continue
                chrom, start, end = components[:3]
                value = 1 if input_file.lower().endswith('.bed') else float(components[3])

            start, end = int(start), int(end)
            chrom_sizes[chrom] = max(chrom_sizes.get(chrom, 0), end + binsize)
    
    if chromHMM:
        # Identify unique states and colors
        state_files = defaultdict(lambda: ([], [], [], []))  # chrom, start, end, values
        state_colors = {}
        
        with open(input_file, 'r') as f:
            for line in f:
                if line.startswith("#") or line.strip() == "":
                    continue
                components = line.strip().split()
                chrom, start, end, state, value, _, _, _, color = components
                start, end = int(start), int(end)
                value = float(value)
                
                # Populate state-specific lists
                state_files[state][0].append(chrom)
                state_files[state][1].append(start)
                state_files[state][2].append(end)
                state_files[state][3].append(value)
                state_colors[state] = list(map(int, color.split(',')))  # Parse color as RGB list
        
        bigwig_files = []
        for state, (chroms, starts, ends, values) in state_files.items():
            if (len(starts) == 0):
                continue
            
            # Sanitize state name for filename
            safe_state_name = re.sub(r'[\/:*?"<>|]', '_', state)
            bigwig_path = f"{output_bigwig_base}_{safe_state_name}.bigwig"
            bigwig_files.append(bigwig_path)
            
            bw = pyBigWig.open(bigwig_path, "w")
            bw.addHeader([(chrom, size) for chrom, size in chrom_sizes.items()])
            
            try:
                bw.addEntries(chroms, starts, ends=ends, values=values, validate=False)
            except RuntimeError as e:
                print(f"Error adding entries for state {state} in {bigwig_path}: {e}")
            
            bw.close()
        
        color_list = [state_colors[state] for state in state_files]
        return bigwig_files, color_list

    # For regular BED/BedGraph processing:
    else:
        bigwig_path = f"{output_bigwig_base}.bigwig"
        bw = pyBigWig.open(bigwig_path, "w")
        # Convert chrom_sizes to list of tuples and add header
        bw.addHeader([(chrom, size) for chrom, size in chrom_sizes.items()])

        previous_components = None
        with open(input_file, 'r') as f:
                chroml = []
                startl = []
                endsl = []
                valuesl = []
                for line in f:
                    if line.startswith("#") or line.strip() == "":
                        continue
                    
                    components = line.strip().split()
                    
                    if input_file.lower().endswith(('.bed')):
                        # make the fourth entry in components, value which is 1
                        # Check if the line has exactly 4 components (chrom, start, end, value)
                        components = components[:3]
                        components.append(1)

                    if input_file.lower().endswith(('.bedgraph')):
                        if len(components) < 4:
                            continue
                        else:
                            components = components[:4]

                    if components == previous_components:
                        continue
                    previous_components = components
                    
                    chrom, start, end, value = components
                    start = int(start)
                    end = int(end)
                    value = float(value)
                    # lists 
                    chroml.append(chrom)
                    startl.append(start)
                    endsl.append(end)
                    valuesl.append(value)

                try:
                    # Your code where the RuntimeError might occur
                    # For example, some function that adds entries
                    bw.addEntries(chroml, startl, ends=endsl, values=valuesl)
                except RuntimeError as e:
                    # Check if the error message matches the specific error
                    if "The entries you tried to add are out of order" in str(e):
                        bigwig_path = "Error: The entries are out of order or have illegal values. Please check and try again."
                    else:
                        # If it's a different RuntimeError, raise it again
                        raise
                # Step 4: Close the BigWig file
                bw.close()
        
        return bigwig_path





# # Convert bedgraph to bigwig
# def bedgraph_to_bigwig(bedgraph, output_bigwig, binsize):
#     chrom_sizes = {}
    
#     with open(bedgraph, 'r') as f:
#         for line in f:
#             # Skip comment lines or headers (if any)
#             if line.startswith("#") or line.strip() == "":
#                 continue
            
#             # Split the line into components
#             components = line.strip().split()
            
#             # If bed file, make it a bedgraph with 1 as the value in every case.
            
#             if bedgraph.lower().endswith(('.bed')):
#                 # make the fourth entry in components, value which is 1
#                 # Check if the line has exactly 4 components (chrom, start, end, value)
#                 components = components[:3]
#                 components.append(1)

#             if bedgraph.lower().endswith(('.bedgraph')):
#                 if len(components) < 4:
#                     continue
#                 else:
#                     components = components[:4]
            
#             chrom, start, end, value = components
#             start = int(start)
#             end = int(end)
            
#             # Track the largest `end` value for each chromosome
#             if chrom not in chrom_sizes:
#                 chrom_sizes[chrom] = end
#             else:
#                 if end > chrom_sizes[chrom]:
#                     chrom_sizes[chrom] = end + binsize

#     # Step 2: Create the BigWig file
#     bw = pyBigWig.open(output_bigwig, "w")
    
#     # Convert chrom_sizes to list of tuples and add header
#     chrom_sizes_list = [(chrom, size) for chrom, size in chrom_sizes.items()]
#     bw.addHeader(chrom_sizes_list)
    
#     previous_components = None

#     # Step 3: Read the BEDGraph again and add entries to BigWig
#     with open(bedgraph, 'r') as f:
#         chroml = []
#         startl = []
#         endsl = []
#         valuesl = []
#         for line in f:
#             if line.startswith("#") or line.strip() == "":
#                 continue
            
#             components = line.strip().split()
            
#             if bedgraph.lower().endswith(('.bed')):
#                 # make the fourth entry in components, value which is 1
#                 # Check if the line has exactly 4 components (chrom, start, end, value)
#                 components = components[:3]
#                 components.append(1)

#             if bedgraph.lower().endswith(('.bedgraph')):
#                 if len(components) < 4:
#                     continue
#                 else:
#                     components = components[:4]

#             if components == previous_components:
#                 continue
#             previous_components = components
            
#             chrom, start, end, value = components
#             start = int(start)
#             end = int(end)
#             value = float(value)
#             # lists 
#             chroml.append(chrom)
#             startl.append(start)
#             endsl.append(end)
#             valuesl.append(value)

#         try:
#             # Your code where the RuntimeError might occur
#             # For example, some function that adds entries
#             bw.addEntries(chroml, startl, ends=endsl, values=valuesl)
#         except RuntimeError as e:
#             # Check if the error message matches the specific error
#             if "The entries you tried to add are out of order" in str(e):
#                 output_bigwig = "Error: The entries are out of order or have illegal values. Please check and try again."
#             else:
#                 # If it's a different RuntimeError, raise it again
#                 raise
#     # Step 4: Close the BigWig file
#     bw.close()
#     return(output_bigwig)


# Read in bigwig file and return a list of
# bigwig peak values
# def processBigwigs(bigwig,binsize,chrom,start,stop,num,userinfo,filetype):
    
#     start=int(start)
#     binsize=int(binsize)
#     stop=int(stop)

#     nochr = chrom.strip('chr')
#     wchr = "chr" + str(nochr)
    
#     if bigwig == "NULL":
#         return("NULL", "NULL")
    
#     if filetype == "Bigwig":
#         bwopen = pyBigWig.open(bigwig)  
#     elif filetype == "Bedgraph" or filetype == "Bed":
#         # convert to bigwig
#         bigwigfile = userinfo+"/bed"+str(num)
#         #check that it's 4 column. If not trim to 4
#         # Actually let's just split
#         outbig = bedgraph_to_bigwig(
#              input_file = bigwig, 
#              output_bigwig_base = bigwigfile, 
#              binsize=binsize, 
#              chromHMM=False)
#         if(outbig=="Error: The entries are out of order or have illegal values. Please check and try again."):
#             return("OOO")
#         elif filetype == "chromHMM":
#             # convert to bigwig
#             bigwigfile = userinfo+"/bed"+str(num)
#             # chromHMM setting outputs a list of .bigwig files one for
#             # each state, and another list that is the rgb values for
#             # each state.
#             outbig = bedgraph_to_bigwig(
#                 input_file = bigwig, 
#                 output_bigwig_base = bigwigfile, 
#                 binsize=binsize, 
#                 chromHMM=True)
#         bwopen = pyBigWig.open(outbig)
    
#     bwraw = []

#     # Store raw bigwig values
#     for walker in range(start, stop+binsize, binsize):
#         try:
#             bwraw.append(bwopen.stats(nochr, walker, walker+binsize)[0])
#         except RuntimeError:
#             bwraw.append(bwopen.stats(wchr, walker, walker+binsize)[0])
#         except ValueError:
#             bwraw.append(0)

#     bwraw = [0 if x == None else x for x in bwraw]


#     # Perform log operation on all values
#     # 1e-5 added to avoid log(0)
#     # THis operation cannot be performed on eigen values (negative)
#     bwlog = []
#     for i in bwraw:
#         if i == None or i < 0:
#             i = 0
#         bwlog.append(math.log(i+0.01))
        
#     return bwlog, bwraw



#---------------------------------------------

def prepareBigwigs(input,binsize,num,userinfo,filetype):
    # Takes input file, converts to bigwig (if needed)
    # and returns a path (or paths and colours if chromHMM)
    binsize=int(binsize)
    
    if input == "NULL":
        return("NULL")
    if filetype == "Bigwig":
        return input 
    elif filetype == "Bedgraph" or filetype == "Bed" or filetype == "Eigen":
        # convert to bigwig
        bigwigfile = userinfo+"/bed"+str(num)
        #check that it's 4 column. If not trim to 4
        # Actually let's just split
        outbig = bedgraph_to_bigwig(
             input_file = input, 
             output_bigwig_base = bigwigfile, 
             binsize=binsize, 
             chromHMM=False)
        if(outbig=="Error: The entries are out of order or have illegal values. Please check and try again."):
            return("OOO")
        return outbig
    elif filetype == "chromHMM":
        # convert to bigwig
        bigwigfile = userinfo+"/bed"+str(num)
        # chromHMM setting outputs a list of .bigwig files one for
        # each state, and another list that is the rgb values for
        # each state.
        biglist, bigcols = bedgraph_to_bigwig(
            input_file = input, 
            output_bigwig_base = bigwigfile, 
            binsize=binsize, 
            chromHMM=True)
        return biglist, bigcols 
            

def processBigwigs(bigwig,binsize,chrom,start,stop):
    # Read bigwig and output the raw and log values for
    # desired locus.
    start=int(start)
    binsize=int(binsize)
    stop=int(stop)

    nochr = chrom.strip('chr')
    wchr = "chr" + str(nochr)
    
    if bigwig == "NULL":
        return("NULL", "NULL")

    bwopen = pyBigWig.open(bigwig)
    
    bwraw = []

    # Store raw bigwig values
    for walker in range(start, stop+binsize, binsize):
        try:
            bwraw.append(bwopen.stats(nochr, walker, walker+binsize)[0])
        except RuntimeError:
            bwraw.append(bwopen.stats(wchr, walker, walker+binsize)[0])
        except ValueError:
            bwraw.append(0)

    bwraw = [0 if x == None else x for x in bwraw]


    # Perform log operation on all values
    # 1e-5 added to avoid log(0)
    # THis operation cannot be performed on eigen values (negative)
    bwlog = []
    for i in bwraw:
        if i == None or i < 0:
            i = 0
        bwlog.append(math.log(i+0.01))
        
    return bwlog, bwraw







#--------------------------------------------




def splitListintoTwo(bedg, chrom, start, stop, binsize):
    # Split a list containing both positive + negative
    # values into two separate lists, one for each.
    # Useful for compartment visualization.
    pos = []
    neg = []

    #bigw = bedgraph_to_bigwig(bedg, output_bigwig, binsize)

    nochr = chrom.strip('chr')
    wchr = "chr" + str(nochr)

    bwopen = pyBigWig.open(bedg)

    pos = []
    neg = []
    values = []

    # Store raw bigwig values
    # Make it 0, if theres a pos value in negative list or negative in positive list. 
    # Just replace after the fact. What am i doing.
    # for i in [pos, neg]:
    for walker in range(start, stop+binsize, binsize):
        try:
            value = bwopen.stats(nochr, walker, walker+binsize)[0]
            values.append(value)
        except RuntimeError:
            value = bwopen.stats(wchr, walker, walker+binsize)[0]
            values.append(value)
        except ValueError:
            pos.append(0)

    pos = [0 if x is None or x < 0 else x for x in values]
    neg = [0 if x is None or x > 0 else x * -1 for x in values]
    

    return pos, neg

# Convert bigwig values to an RGBA array
# with the A value scaled by bigwig value
def calcAlphaMatrix(chiplist, minmaxlist, f2, disthic,showhic, r,g,b):
    # go through chip1 and chip2, but if cosignal FALSE do s1xs1
	# If cosignal is TRUE 
	# perform each chip separately
     
    if f2==True:
        chips = [chiplist[0], chiplist[1]]
    else:
        chips = [chiplist[0]]
    # Initialize list for normalized chip tracks
    chipnorms = []
    minmaxs = []
    for n, chip in enumerate(chips):
        matsize = len(chip)
        # Normalize chip list to between 0 and 1
        chip_arr = np.array(chip)
        # Replace None with 0
        chip_arr = [0 if x is None else x for x in chip_arr]

        

        if(n==0): #If we're doing feature 1
            minimum = np.min(chip_arr) if math.isnan(float(minmaxlist[0][0])) else minmaxlist[0][0]
            minimum = round(minimum, 6)
            
            maximum = np.max(chip_arr) if math.isnan(float(minmaxlist[0][1])) else minmaxlist[0][1]
            maximum = round(maximum, 6) 
        else: # Or feature 2
            minimum = np.min(chip_arr) if math.isnan(float(minmaxlist[1][0])) else minmaxlist[1][0]
            minimum = round(minimum, 6)

            maximum = np.max(chip_arr) if math.isnan(float(minmaxlist[1][1])) else minmaxlist[1][1]
            maximum = round(maximum, 6)          

        minmax = [minimum, maximum]
        minmaxs.append(minmax)
        #raw values from bigwig, clipped data to specified values
        chip_clipped = np.clip(chip_arr, a_min = minimum, a_max = maximum)

        # normalized to between 0 and 1 after clipping. 0 and 1 being scaled
        # from user specified min and max
        if(n==0):   
            chip_norm1 = (chip_clipped-minimum)/(maximum-minimum)
            chipnorms.append(chip_norm1)
        else:
            chip_norm2 = (chip_clipped-minimum)/(maximum-minimum)
            chipnorms.append(chip_norm2)

    # True: scale ChIP by Hi-C
    # false: raw ChIP not weighted by Hi-C
    if(showhic==True):
        # Normalize hic matrix to between 0 and 1
        distscaled = (disthic-np.min(disthic))/(np.max(disthic)-np.min(disthic))
    else:
		 # Hi-C is all ones, therefore not impacting ChIP matrix at all
         distscaled = np.ones((len(disthic), len(disthic)))

    # RGBA
    rmat = np.zeros((matsize,matsize))
    gmat = np.zeros((matsize,matsize))
    bmat = np.zeros((matsize,matsize))
    amat = np.zeros((matsize,matsize))

    # Alter r,g,b for desired color
    rmat.fill(r)
    gmat.fill(g)
    bmat.fill(b)

    # Calculate alpha value based on chip-seq
    # intersection combined score
    # x * y * 255
    # result is a normalized range from 0-255
	
    for x in range(0,matsize):
            for y in range(x,matsize):
                if(f2==True):
                      newscore = (chipnorms[0][x] * chipnorms[1][y])*255
                else:
                      newscore = (chipnorms[0][x] * chipnorms[0][y])*255

                # Multiply by HiC distance-normalized and 0-1 scaled
                newscore = newscore * distscaled[x,y]
                #alpha value
                amat[y,x] = newscore

                if f2==False:
                     amat[x,y] = newscore
                     
    for x in range(0,matsize):
        for y in range(x,matsize):
            if(f2==True):
                    newscore = (chipnorms[0][y] * chipnorms[1][x])*255
            else:
                    newscore = (chipnorms[0][x] * chipnorms[0][y])*255

            # Multiply by HiC distance-normalized and 0-1 scaled
            newscore = newscore * distscaled[x,y]
            #alpha value
            amat[x,y] = newscore
            #amat[x,y] = newscore

    amat = np.maximum(amat, amat.T)
    mat = (np.dstack((rmat,gmat,bmat,amat))).astype(np.uint8)

    return mat, chipnorms, minmaxs

# Use Linear interpolation to calculate
# the alpha weighted color mixing ratio
def lnerp_matrices(matrices):
        
    # Extract alpha values scaled to 0-255 for each matrix
    alpha_values = [matrix[:, :, 3:4] for matrix in matrices]
    
    # Calculate the total sum of alpha values for weighting
    total_alpha = np.sum(alpha_values, axis=0)
    
    # Calculate blend ratios for each matrix
    blend_ratios = [alpha / total_alpha for alpha in alpha_values]
    
    # Initialize color channels
    color_channels = [matrix[:, :, :3] for matrix in matrices]
    
    # Perform linear interpolation for color mixing
    mixed_color_channels = np.sum([color * blend_ratio for color, blend_ratio in zip(color_channels, blend_ratios)], axis=0)
    
    # Ensure that the final alpha value is 255
    mixed_alpha = np.clip(total_alpha, 0, 255)
    
    # Combine color channels and summed alpha values
    mixed_matrix = np.dstack((mixed_color_channels, mixed_alpha)).astype(np.uint8)
    
    return mixed_matrix

# Return a list of all possible sequential
# matplotlib colormaps
def matplot_color(gradient):
    cmap = LinearSegmentedColormap.from_list('interaction', gradient)
    return cmap


# Produce HiC map image saved to disk 
def hic_plot(cmap, distnormmat, filepathpng, filepathsvg):

	# if cmap in [i for i in coolboxcmaps.keys()]:
	# 	cmap = coolboxcmaps[cmap]
	# else:
	# 	cmap
	
	# Save distance normalized HiC plot and display. This is base functionality of the app and 
	# only requires a HiC file.
	fig, (ax1) = plt.subplots(ncols=1)

	#ax1.set_title('Hi-C')
	ax1.matshow(distnormmat, cmap=cmap, interpolation='none')
	ax1.xaxis.set_visible(False)
	ax1.yaxis.set_visible(False)

    # Save figure to temp path
	plt.savefig(filepathpng, bbox_inches='tight')
	plt.savefig(filepathsvg, bbox_inches='tight', dpi=300)

	plt.close()
	return filepathpng, filepathsvg


def ChIP_plot(chip, mat, col1, trackcol, linewidth, disthic, 
              disthic_cmap, hicalpha, bedalpha, filepathpng, 
              filepathsvg, filetype):
    mat = mat.astype(np.uint8)
    fig = plt.figure()
    ax = fig.add_subplot()

    # Show distance normalized HiC
    ax.imshow(disthic, disthic_cmap, interpolation='none', alpha = hicalpha)
	# Show 1D feature matrix
    ax.imshow(mat, interpolation='none', alpha = bedalpha)

    ax.xaxis.set_visible(False)
    ax.yaxis.set_visible(False)

	#############################
	# Create bigwigs dynamically, 
	# given a vector of names, 
	# bigwigs and colors, do whatever
	# length.
	#############################
	# Convert hex to rgb 0-1 for facecolor
    tc = trackcol[0]
    h = tc.lstrip('#')
    t = tuple(int(h[i:i+2], 16) for i in (0, 2, 4))
    tcol = [x/255 for x in t]
    
    # If an eigen compartment track is uploaded,
    # have a line at 0 and plot A and B tracks above and below
    # print(iseigen)
    # print(iseigen[0])
    # x-axis plot setup
    ax1 = fig.add_subplot()
    ax1.set_facecolor(tcol)

	# y-axis plot setup
    ax3 = fig.add_subplot()
    ax3.set_facecolor(tcol)
      
	# Dynamically add subplots

    for i in range(len(chip)):
        f2 = False
        if filetype[i] != "Eigen" and filetype[i] != "chromHMM":
            if len(chip[i]) == 2:
                f2 = True

        # If it's an eigen track
        if filetype[i] == "Eigen":

            Acol = col1[i][0]
            Bcol = col1[i][1]
            ABcol = col1[i][2]

            A = chip[i][0][0][0][0]
            B = chip[i][0][0][1][0]

            ax2 = ax1.twinx()
            Ar = np.array(A)
            A_scaled = 0.5 + Ar * 0.5
            Br = np.array(B)
            B_scaled = 0.5 - Br * 0.5
            # Add fill between the lines and y=0.5
            ax2.fill_between(range(len(A_scaled)), A_scaled, 0.5, color=Acol, alpha=1)
            ax2.fill_between(range(len(B_scaled)), B_scaled, 0.5, color=Bcol, alpha=1)
            #set y-axis to custom range #NOT USED #y-axis is baked into the data range itself.
            # blim = min(chip[i]) if math.isnan(minmaxs[i][0]) else minmaxs[i][0]
            # tlim = max(chip[i]) if math.isnan(minmaxs[i][1]) else minmaxs[i][1]
            lims = [0, 1]
            ax2.set_ylim(lims)
            # y-axis track
            ychip1 = A_scaled
            ychip2 = B_scaled
            ax4 = ax3.twiny()
            a = [x for x in range(len(ychip1))]
            b = [x for x in range(len(ychip2))]
            #Plot the reversed ychip values
            # ax4.plot(ychip1[::-1], a, color='red')
            # ax4.plot(ychip2[::-1], b, color='blue')
            
            # Set x-axis limits
            ax4.set_xlim(lims)

            # Fill between the y-axis values and 0.5
            ax4.fill_betweenx(a, ychip1[::-1], 0.5, where=(ychip1[::-1] > 0.5), 
                            color=Acol, alpha=1)
            ax4.fill_betweenx(b, ychip2[::-1], 0.5, where=(ychip2[::-1] < 0.5), 
                            color=Bcol, alpha=1)
            # ax4.fill_between(range(len(A_scaled)), A_scaled, 0.5, color='blue')
            # ax4.fill_between(range(len(B_scaled)), B_scaled, 0.5, color='red')

            # x-axis Remove ticks
            ax1.set_xticks([])
            ax1.set_yticks([])
            ax2.set_xticks([])
            ax2.set_yticks([])

            # y-axis Remove ticks
            ax3.set_xticks([])
            ax3.set_yticks([])
            ax4.set_xticks([])
            ax4.set_yticks([])
        elif filetype[i] == "chromHMM":
             # x-axis track
            ax2 = ax1.twinx()
            xchip = chip[i]
            ax2.plot(xchip, color=col1[i], linewidth = linewidth[0])
            #set y-axis to custom range #NOT USED #y-axis is baked into the data range itself.
            # blim = min(chip[i]) if math.isnan(minmaxs[i][0]) else minmaxs[i][0]
            # tlim = max(chip[i]) if math.isnan(minmaxs[i][1]) else minmaxs[i][1]
            lims = [0, 1.1]
            ax2.set_ylim(lims)
            # y-axis track
            ychip = chip[i]

            ax4 = ax3.twiny()
            a = [x for x in range(len(ychip))]
            ax4.plot(ychip[::-1], a, color=col1[i], linewidth = linewidth[0])
            ax4.set_xlim(lims)

            # x-axis Remove ticks
            ax1.set_xticks([])
            ax1.set_yticks([])
            ax2.set_xticks([])
            ax2.set_yticks([])

            # y-axis Remove ticks
            ax3.set_xticks([])
            ax3.set_yticks([])
            ax4.set_xticks([])
            ax4.set_yticks([])
        else:
            # x-axis track
            ax2 = ax1.twinx()
            xchip = chip[i][0]
            ax2.plot(xchip, color=col1[i], linewidth = linewidth[0])
            #set y-axis to custom range #NOT USED #y-axis is baked into the data range itself.
            # blim = min(chip[i]) if math.isnan(minmaxs[i][0]) else minmaxs[i][0]
            # tlim = max(chip[i]) if math.isnan(minmaxs[i][1]) else minmaxs[i][1]
            lims = [0, 1.1]
            ax2.set_ylim(lims)
            # y-axis track
            if f2:
                ychip = chip[i][1]
            else:
                ychip = chip[i][0]   

            ax4 = ax3.twiny()
            a = [x for x in range(len(ychip))]
            ax4.plot(ychip[::-1], a, color=col1[i], linewidth = linewidth[0])
            ax4.set_xlim(lims)

            # x-axis Remove ticks
            ax1.set_xticks([])
            ax1.set_yticks([])
            ax2.set_xticks([])
            ax2.set_yticks([])

            # y-axis Remove ticks
            ax3.set_xticks([])
            ax3.set_yticks([])
            ax4.set_xticks([])
            ax4.set_yticks([])

	# Format plots
    l1, b1, w1, h1 = ax.get_position().bounds
	#ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
    ax1.set_position((l1*(1),0.02, w1*1, .075))
    ax1.margins(x=0)
	# ax2.xaxis.set_visible(False)
	# ax2.yaxis.set_visible(False)

    l2, b2, w2, h2 = ax.get_position().bounds
    ax3.set_position((l2*(.7),b2, w2*.1, h2*(1)))
    ax3.margins(y=0)

    plt.savefig(filepathsvg, bbox_inches='tight')
    plt.savefig(filepathpng, bbox_inches='tight', dpi=300)
    plt.close()

    return filepathpng, filepathsvg