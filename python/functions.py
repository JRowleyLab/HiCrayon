import numpy as np
import hicstraw
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.pyplot as plt 
import pyBigWig
import math
import pandas as pd
import requests
import re


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

# Convert bedgraph to bigwig
def bedgraph_to_bigwig(bedgraph, output_bigwig, binsize):
    chrom_sizes = {}
    
    with open(bedgraph, 'r') as f:
        for line in f:
            # Skip comment lines or headers (if any)
            if line.startswith("#") or line.strip() == "":
                continue
            
            # Split the line into components
            components = line.strip().split()
            
            # Check if the line has exactly 4 components (chrom, start, end, value)
            if len(components) != 4:
                print(f"Skipping invalid line: {line.strip()} (Expected 4 components)")
                continue
            
            chrom, start, end, value = components
            start = int(start)
            end = int(end)
            
            # Track the largest `end` value for each chromosome
            if chrom not in chrom_sizes:
                chrom_sizes[chrom] = end
            else:
                if end > chrom_sizes[chrom]:
                    chrom_sizes[chrom] = end + binsize

    # Step 2: Create the BigWig file
    bw = pyBigWig.open(output_bigwig, "w")
    
    # Convert chrom_sizes to list of tuples and add header
    chrom_sizes_list = [(chrom, size) for chrom, size in chrom_sizes.items()]
    bw.addHeader(chrom_sizes_list)
    
    # Step 3: Read the BEDGraph again and add entries to BigWig
    with open(bedgraph, 'r') as f:
        chroml = []
        startl = []
        endsl = []
        valuesl = []
        print('starting')
        for line in f:
            if line.startswith("#") or line.strip() == "":
                continue
            
            components = line.strip().split()
            
            # Check if the line has exactly 4 components
            if len(components) != 4:
                continue
            
            chrom, start, end, value = components
            start = int(start)
            end = int(end)
            value = float(value)
            chroml.append(chrom)
            startl.append(start)
            endsl.append(end)
            valuesl.append(value)

        #print(chroml)
            
        # Add the entries to BigWig
        bw.addEntries(chroml, startl, ends=endsl, values=valuesl)

    # Step 4: Close the BigWig file
    bw.close()
    return(output_bigwig)


# Read in bigwig file and return a list of
# bigwig peak values
def processBigwigs(bigwig,binsize,chrom,start,stop):
    
    start=int(start)
    binsize=int(binsize)
    stop=int(stop)

    nochr = chrom.strip('chr')
    wchr = "chr" + str(nochr)
    
    if bigwig == "NULL":
        return("NULL", "NULL")
    
    if bigwig.endswith(('.bigwig', '.bw')):
        bwopen = pyBigWig.open(bigwig)  
    elif bigwig.endswith(('.bedgraph')):
        # convert to bigwig
        # TODO: delete when user closes the session.
        bigwigfile = "tmp.bw"
        #check that it's 4 column. If not trim to 4
        outbig = bedgraph_to_bigwig(bedgraph = bigwig, output_bigwig = bigwigfile, binsize=binsize)
        bwopen = pyBigWig.open(outbig)
    
    bwraw = []

    # Store raw bigwig values
    for walker in range(start, stop+binsize, binsize):
        try:
            bwraw.append(bwopen.stats(nochr, walker, walker+binsize)[0])
        except RuntimeError:
            bwraw.append(bwopen.stats(wchr, walker, walker+binsize)[0])
        except ValueError:
            bwraw.append(0)

    iseigen = False
    if bigwig.endswith('bedgraph') and min(bwraw) < 0:
         print("eigen file")
         iseigen = "TRUE"

    # Perform log operation on all values
    # 1e-5 added to avoid log(0)
    bwlog = []
    for i in bwraw:
        if i == None:
            i = 0
        bwlog.append(math.log(i+0.01))
        
    return bwlog, bwraw #, iseigen

# Convert bigwig values to an RGBA array
# with the A value scaled by bigwig value
# TODO: have an option to also use HiC value
# scale the alpha.
def calcAlphaMatrix(chiplist, minmaxlist, f2, disthic,showhic, r,g,b):
    # go through chip1 and chip2, but if cosignal FALSE do s1xs1
	# If cosignal is TRUE 
	# perform each chip separately
    if f2==True:
        chips = [chiplist[0], chiplist[1]]
        print(chips)
    else:
        chips = [chiplist[0]]

    # Initialize list for normalized chip tracks
    chipnorms = []
    minmaxs = []
    for n, chip in enumerate(chips):
        matsize = len(chip)
        # Normalize chip list to between 0 and 1
        chip_arr = np.array(chip)

        if(n==0): #If we're doing feature 1
            minimum = np.min(chip_arr) if math.isnan(minmaxlist[0][0]) else minmaxlist[0][0]
            minimum = round(minimum, 6)
            
            maximum = np.max(chip_arr) if math.isnan(minmaxlist[0][1]) else minmaxlist[0][1]
            maximum = round(maximum, 6) 
        else: # Or feature 2
            minimum = np.min(chip_arr) if math.isnan(minmaxlist[1][0]) else minmaxlist[1][0]
            minimum = round(minimum, 6)

            maximum = np.max(chip_arr) if math.isnan(minmaxlist[1][1]) else minmaxlist[1][1]
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
				# To have a diagonal line, 
				# uncomment the below:
				# if x==y line
                # if x==y:
                #     newscore = 255
                # else:
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
            # To have a diagonal line, 
            # uncomment the below:
            # if x==y line
            # if x==y:
            #     newscore = 255
            # else:
            if(f2==True):
                    newscore = (chipnorms[0][y] * chipnorms[1][x])*255
            else:
                    newscore = (chipnorms[0][x] * chipnorms[0][y])*255

            # Multiply by HiC distance-normalized and 0-1 scaled
            newscore = newscore * distscaled[x,y]
            #alpha value
            amat[x,y] = newscore
            #amat[x,y] = newscore

    mat = (np.dstack((rmat,gmat,bmat,amat))).astype(np.uint8)
    # print("done calclpha")
    # print("Python:, ", minmaxs) #should be 1 list of two items

    # print(chipnorms)
    # print(minmaxs)

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


def ChIP_plot(chip, mat, col1, disthic, disthic_cmap, hicalpha, bedalpha, filepathpng, filepathsvg):
    mat = mat.astype(np.uint8)
    fig = plt.figure()
    ax = fig.add_subplot()

    # Show distance normalized HiC
    ax.imshow(disthic, disthic_cmap, interpolation='none', alpha = hicalpha)
	# Show ChIP-seq matrix
    ax.imshow(mat, interpolation='none', alpha = bedalpha)

    ax.xaxis.set_visible(False)
    ax.yaxis.set_visible(False)

	#############################
	# Create bigwigs dynamically, 
	# given a vector of names, 
	# bigwigs and colors, do whatever
	# length.
	#############################
	# x-axis plot setup
    ax1 = fig.add_subplot()

	# y-axis plot setup
    ax3 = fig.add_subplot()
      
	# Dynamically add subplots
    for i in range(len(chip)):
        if len(chip[i]) == 2:
            f2 = True
        else:
            f2 = False
        print("F2:")
        print(f2)

		# x-axis track
        ax2 = ax1.twinx()
        ax2.plot(chip[i][0], color=col1[i], linewidth = 1)
		#set y-axis to custom range #NOT USED #y-axis is baked into the data range itself.
		# blim = min(chip[i]) if math.isnan(minmaxs[i][0]) else minmaxs[i][0]
		# tlim = max(chip[i]) if math.isnan(minmaxs[i][1]) else minmaxs[i][1]
        lims = [0, 1]
        ax2.set_ylim(lims)
		# y-axis track
        if f2:
            ychip = chip[i][1]
        else:
            ychip = chip[i][0]   
        print("point")     

        ax4 = ax3.twiny()
        a = [x for x in range(len(ychip))]
        ax4.plot(ychip[::-1], a, color=col1[i], linewidth = 1)
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

# check that the bedgraph binsize matches that
# of the chosen binsize of Hi-C
def checkBedBinsize(df, binsize):
    bedbinsize = df['stop'].iloc[2] - df['start'].iloc[2]
    return bedbinsize == binsize

# Add missing bins and store as 0
def addEmptyBins(df, chrom, start, stop, binsize):
	# Setup model dataframe
    starts = [x for x in range(start, stop, binsize)]
    stops = [x for x in range(start+binsize, stop+binsize, binsize)]
    chr = [chrom] * len(starts)
    value = [0] * len(starts)
    emptyval = list(zip(chr,starts,stops,value))
    dfnew = pd.DataFrame(emptyval, columns=['chrom','start', 'stop', 'value'])

    # Merge on old dataframe and take new rows as 0
    df['chrom'] = chrom
    dfmerged = df.merge(dfnew, how='right', on=['chrom', 'start', 'stop'], )
    dfmerged['value_x'][dfmerged['value_x'].apply(math.isnan)] = 0
    dfmerged.drop(['value_y'], axis=1, inplace=True)
    dfmerged.sort_values(['chrom', 'start'], inplace=True)
    dfmerged.rename({'value_x': 'value'}, axis=1, inplace=True)

    return dfmerged

def filterCompartments(comp, chrom, start, stop):
    # Filter compartments bedGraph by selected region
    comp = pd.read_csv(comp, sep="\t", header=None, dtype={0: 'string'}, on_bad_lines='skip')
    comp.columns = ['chrom', 'start', 'stop', 'value']

    nochr = chrom.strip('chr')
    wchr = "chr" + str(nochr)

    comp_filt = comp.loc[(comp['chrom'] == nochr) & (comp['start'] >= start) & (comp['stop'] <= stop)]
    
    if(len(comp_filt)==0):
        comp_filt = comp.loc[(comp['chrom'] == wchr) & (comp['start'] >= start) & (comp['stop'] <= stop)]

    return comp_filt


def scaleCompartments(disthic, comp_df, Acol, Bcol, ABcol):
    #distance normalized hic matrix
    distscaled = (disthic-np.min(disthic))/(np.max(disthic)-np.min(disthic))

    comp_arr = comp_df['value']
    Acomp = np.where(comp_arr<0, 0, comp_arr)
    Bcomp = np.where(comp_arr>0, 0, comp_arr)
    # #Normalize on IQR
    # q3, q1 = np.percentile(comp_arr, [75,25])
    # iqr = q3 - q1
    # comp_arr_IQR_norm = comp_arr / iqr
    # Normalize data to between -1 and 1
    # Scale A compartment to 0 and 1
    min = 0
    max = 1
    Anormd = (((Acomp-np.min(Acomp)) * ( (max) - (min))) / (np.max(Acomp) - np.min(Acomp))) + min
    # SCale B compartment to 0 and -1
    min = 0
    max = -1
    Bnormd = (((Bcomp-np.min(Bcomp)) * ( (min) - (max))) / (np.max(Bcomp) - np.min(Bcomp))) + max

    for i, comp in enumerate([Anormd, Bnormd]):

        matsize = len(comp)
        # RGBA
        rmat = np.zeros((matsize,matsize))
        gmat = np.zeros((matsize,matsize))
        bmat = np.zeros((matsize,matsize))
        amat = np.zeros((matsize,matsize))

        if(i==0):
            # Alter r,g,b for desired color
            rmat.fill(Acol[0])
            gmat.fill(Acol[1])
            bmat.fill(Acol[2])
        else:
            rmat.fill(Bcol[0])
            gmat.fill(Bcol[1])
            bmat.fill(Bcol[2])

        # Calculate the alpha value for each 
        for x in range(0,matsize):
            for y in range(x,matsize):

                newscore = (comp[x] * comp[y])*255
                # Multiply by HiC distance-normalized and 0-1 scaled
                newscore = newscore * distscaled[x,y]
                #alpha value
                amat[x,y] = newscore
                amat[y,x] = newscore

        if(i==0):
            Amatrix = (np.dstack((rmat,gmat,bmat,amat))).astype(np.uint8)
        else:
            Bmatrix = (np.dstack((rmat,gmat,bmat,amat))).astype(np.uint8)

    # Create A-B compartment matrix
    matsize = len(comp)
    # RGBA
    rmat = np.zeros((matsize,matsize))
    gmat = np.zeros((matsize,matsize))
    bmat = np.zeros((matsize,matsize))
    amat = np.zeros((matsize,matsize))

    rmat.fill(ABcol[0])
    gmat.fill(ABcol[1])
    bmat.fill(ABcol[2])

    # Calculate the alpha value for each 
    for x in range(0,matsize):
        for y in range(x,matsize):

            newscore = (Acomp[x] * Bcomp[y])*255
            # Multiply by HiC distance-normalized and 0-1 scaled
            newscore = newscore * distscaled[x,y]
            #alpha value
            #amat[x,y] = newscore
            amat[y,x] = newscore

    for x in range(0,matsize):
        for y in range(x,matsize):

            newscore = (Acomp[y] * Bcomp[x])*255
            # Multiply by HiC distance-normalized and 0-1 scaled
            newscore = newscore * distscaled[x,y]
            #alpha value
            amat[x,y] = newscore
            #amat[y,x] = newscore

    
    ABmatrix = (np.dstack((rmat,gmat,bmat,amat))).astype(np.uint8)

    return Amatrix, Bmatrix, ABmatrix


def plotCompartments(disthic, comp, ABmat, colA, colB, filepathpng, filepathsvg):
    
    # Plot HiC map and compartment tracks
    mat = disthic.astype(np.uint8)

    #img = Image.fromarray(mat)
                
    fig, (ax2) = plt.subplots(ncols=1)
    
    compartments = comp['value']

	# Show compartments
    ax2.imshow(ABmat, interpolation='none', alpha = 1)

    ax2.xaxis.set_visible(False)
    ax2.yaxis.set_visible(False)

    ax3 = fig.add_subplot()
    ax3.plot(compartments, color='black', linewidth = 1)
    #ax3.axis('off')
    l1, b1, w1, h1 = ax2.get_position().bounds
    #ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
    ax3.set_position((l1*(1),0.02, w1*1, .075))
    ax3.margins(x=0)
    ax3.axhline(y=0, color='black', linestyle='-')
    ax3.fill_between(compartments.index, list(compartments), where=(compartments > 0), facecolor = colA, edgecolor='none', alpha=.5, interpolate=False, hatch = None)
    ax3.fill_between(compartments.index, list(compartments), where=(compartments < 0), facecolor = colB, edgecolor='none', alpha=.5, interpolate=False, hatch = None)
    ax3.xaxis.set_visible(False)
    ax3.yaxis.set_visible(False)

    ax4 = fig.add_subplot()
    a = [x for x in range(len(compartments))]
    ax4.plot(compartments[::-1], a, color='black', linewidth = 1)

    l2, b2, w2, h2 = ax2.get_position().bounds
    ax4.set_position((l2*(.7),b2, w2*.1, h2*(1)))
    ax4.margins(y=0)
    ax4.axvline(x=0, color='black', linestyle='-')
    ax4.fill_betweenx(a, list(compartments[::-1]), where=(compartments[::-1] > 0), facecolor = colA, edgecolor='none', alpha=.5, interpolate=False, hatch = None)
    ax4.fill_betweenx(a, list(compartments[::-1]), where=(compartments[::-1] < 0), facecolor = colB, edgecolor='none', alpha=.5, interpolate=False, hatch = None)
    ax4.xaxis.set_visible(False)
    ax4.yaxis.set_visible(False)
    
    plt.savefig(filepathsvg, bbox_inches='tight')
    plt.savefig(filepathpng, bbox_inches='tight', dpi=300)
    
    plt.close()
    return filepathpng, filepathsvg