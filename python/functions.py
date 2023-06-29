import numpy as np
import hicstraw
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.pyplot as plt 
import pyBigWig
import math
from PIL import Image
import os
import glob
from coolbox.core.track.hicmat.plot import cmaps as coolboxcmaps
import h5py
import cooler
import pandas as pd


#random string generation
import string
import random


def coolerMetadata(mcool):
    h5 = h5py.File(mcool, 'r')
    res = list(h5['resolutions'].keys())
    res = sorted([int(x) for x in res], reverse=True)
    cool = f"{mcool}::/resolutions/{res[0]}"
    c = cooler.Cooler(cool)
    chrlist = c.chromnames
    
    return chrlist, res

def getHiCmetadata(hicfile):
	# Given a hic-pro file upload, return
	# multiple lists of metadata
	# Chr name, resolutions, normalizations
	hicdump = hicstraw.HiCFile(hicfile)

	# Chromosome list
	chroms = hicdump.getChromosomes()[1:]
	chrlist = []
	for x in chroms:
		chrlist.append(x.name)
	
	# Resolution list
	res = hicdump.getResolutions()

	return chrlist, res


def readCoolHiC(mcool, chrom, start, stop, norm, binsize):
    print(f"{mcool} + {chrom} + {start}+ {stop}+ {binsize}")
    cool = f"{mcool}::/resolutions/{binsize}"
    print(cool)
    c = cooler.Cooler(cool)
    string = f"{chrom}:{str(start)}-{str(stop+1)}"
    print(string)
    mat = c.matrix().fetch(string)
    return mat


# Read in HiC file and output selected coordinates + binsize
# as matrix. 
def readHiCasNumpy(hicfile, chrom, start, stop, norm, binsize):

	hicdump = hicstraw.HiCFile(hicfile)
	
	hicobject = hicdump.getMatrixZoomData(chrom, chrom, "observed", norm, "BP", binsize)

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
def distanceMatHiC(hicnumpy):
	thresh = 2
	print("Beginning distance matrix HiC")
	matsize = len(hicnumpy)
	print(matsize)
	mydiags=[]
	for i in range(0,len(hicnumpy)):
		mydiags.append(np.nanmean(np.diag(hicnumpy, k=i)))

	distnormmat = np.zeros((matsize,matsize))
	for x in range(0,matsize):
		for y in range(x,matsize):
			distance=y-x
			hicscore = (hicnumpy[x,y] + 1)/(mydiags[distance]+1)
			if hicscore > thresh:
				distnormmat[x,y] = thresh
				distnormmat[y,x] = thresh
				satscore = 1
			else:
				distnormmat[x,y] = hicscore
				distnormmat[y,x] = hicscore
				satscore = hicscore/thresh
	print("done")
	return(distnormmat)


# Read in bigwig file and return a list of
# bigwig peak values
def processBigwigs(bigwig,binsize,chrom,start,stop, log):

	print("processing bigwigs...")
	start=int(start)
	binsize=int(binsize)
	stop=int(stop)

	nochr = chrom.strip('chr')
	wchr = "chr" + str(nochr)

	bwopen = pyBigWig.open(bigwig)		
	bwlist = []


	if(log==True):
		for walker in range(start, stop+binsize, binsize):
			try:
				bwlist.append(math.log(bwopen.stats(nochr, walker, walker+binsize)[0]+0.01))
			except RuntimeError:
				bwlist.append(math.log(bwopen.stats(wchr, walker, walker+binsize)[0]+0.01))
			except ValueError:
				bwlist.append(0)
	else:
		for walker in range(start, stop+binsize, binsize):
			try:
				bwlist.append(bwopen.stats(nochr, walker, walker+binsize)[0])
			except RuntimeError:
				bwlist.append(bwopen.stats(wchr, walker, walker+binsize)[0])
			except ValueError:
				bwlist.append(0)
			
	print("done bigwig")
	return bwlist

# Convert bigwig values to an RGBA array
# with the A value scaled by bigwig value
# TODO: have an option to also use HiC value
# scale the alpha.
def calcAlphaMatrix(chip,disthic,showhic,r,g,b):
    matsize = len(chip)
    # Normalize chip list to between 0 and 1
    chip_arr = np.array(chip)
    chip_norm = (chip_arr-np.min(chip_arr))/(np.max(chip_arr)-np.min(chip_arr))


    if(showhic==True):
        # Normalize hic matrix to between 0 and 1
        distscaled = (disthic-np.min(disthic))/(np.max(disthic)-np.min(disthic))
    else:
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
				# TO have a diagonal line, 
				# uncomment the below:
				# if x==y line
                # if x==y:
                #     newscore = 255
                # else:
                newscore = (chip_norm[x] * chip_norm[y])*255
                # Multiply by HiC distance-normalized and 0-1 scaled
                newscore = newscore * distscaled[x,y]
                #alpha value
                amat[x,y] = newscore
                amat[y,x] = newscore

    mat = (np.dstack((rmat,gmat,bmat,amat))).astype(np.uint8)

    return mat

# Use Linear interpolation to calculate
# the alpha weighted color mixing ratio
def lnerp_matrices(m1, m2):
    print("LNERP...")
    # Alpha values normalized to 1
    a1 = m1[:,:,3:4]/255
    a2 = m2[:,:,3:4]/255

    # Blend ratio
    br = a1 / (a1 + a2)

    # Linear interpolation for color mixing
    r = (m1[:,:,:1] * br) + (m2[:,:,:1] * (1 - br))
    g = (m1[:,:,1:2] * br) + (m2[:,:,1:2] * (1 - br))
    b = (m1[:,:,2:3] * br) + (m2[:,:,2:3] * (1 - br))
    # Calculate average alpha value
    fa = (m1[:,:,3:4] + m2[:,:,3:4])

    # Stack R,G,B,A channels
    mat = (np.dstack((r,g,b,fa))).astype(np.uint8)

    return mat

# Return a list of all possible sequential
# matplotlib colormaps
def matplot_colors():
	# Add in custom colors to list
	#REDMAP = LinearSegmentedColormap.from_list("bright_red", [(1,1,1),(1,0,0)])
	cmaps = plt.colormaps()
	cmaps = cmaps + [i for i in coolboxcmaps.keys()]
	return cmaps


# Produce HiC map image saved to disk 
def hic_plot(cmap, distnormmat, chrom, bin, start, stop, norm):

	if cmap in [i for i in coolboxcmaps.keys()]:
		cmap = coolboxcmaps[cmap]
	else:
		cmap
	
	# Remove previous versions of svg images
	# to prevent bloat in images directory.
	# NOTE: the file cannot be overwritten
	# as webpage doesn't recognise it has
	# changed if the filename hasn't changed.
	for f in glob.glob('./www/images/HiC_*.svg'):
		print(f'Removing image: {f}')
		os.remove(f)

	# Save distance normalized HiC plot and display. This is base functionality of the app and 
	# only requires a HiC file.
	fig, (ax1) = plt.subplots(ncols=1)

	#ax1.set_title('Hi-C')
	ax1.matshow(distnormmat, cmap=cmap, interpolation='none')
	ax1.xaxis.set_visible(False)
	ax1.yaxis.set_visible(False)

	# random string for name
	# using random.choices()
	# generating random strings
	res = ''.join(random.choices(string.ascii_uppercase +
								string.digits, k=8))
	figname = f"HiC_locus-{chrom}-{start}-{stop}_{bin}bp_norm-{norm}_{str(res)}.svg"

	directory = "images/"
	wwwlocation = "www/" + directory + figname
	notwwwlocation = directory + figname
	plt.savefig(wwwlocation, bbox_inches='tight')
	plt.close()
	return notwwwlocation


def ChIP_plot(chip, chip2, mat, col1, col2, disthic, disthic_cmap, sample, hicalpha, bedalpha, chrom, bin, start, stop, name, norm):
	# NOTES: the issue here is that the matrix is generated inside the plotting function with calcAlphaMatrix.
	# Before, i was passing the r,g,b matrices inside, which can be 1 chip or 2 chips depending. I need to do this again,
	# but instead having alpha value as well.
	# The chosen colour needs to be passed to calcAlphaMatrix and then I can pass the rmat ,gmat ,bmat  to this function again
	#color can be hexidecimal
	mat = mat.astype(np.uint8)

	print(f"Plotting {sample}...")
	#remove previously generated images

	for f in glob.glob(f'./www/images/{sample}-*.svg'):
		print(f'Removing image: {f}')
		os.remove(f)


	# Set up CMAP for HiC background
	if disthic_cmap in [i for i in coolboxcmaps.keys()]:
		disthic_cmap = coolboxcmaps[disthic_cmap]
	else:
		disthic_cmap


	print(f"length matrix: {len(mat)}")

	img = Image.fromarray(mat)
				
	fig, (ax2) = plt.subplots(ncols=1)
	
	print(f"check_maybe {sample}")
	
	# #########################
	# background = Image.new('RGBA', (len(disthic),len(disthic)), (0,0,0,opacity) )
	# # Show black background
	# ax2.imshow(background)
	# # Colour map for HiC underlay

	# Show distance normalized HiC
	ax2.imshow(disthic, disthic_cmap, interpolation='none', alpha = hicalpha)
	# Show ChIP-seq matrix
	ax2.imshow(img, interpolation='none', alpha = bedalpha)

	ax2.xaxis.set_visible(False)
	ax2.yaxis.set_visible(False)

	# Adding ChIP track underneath matrix
	# ChIP1 includes red track
	if(sample=="ChIP1"):
		ax3 = fig.add_subplot()
		ax3.plot(chip, color=col1, linewidth = 1)
		#ax3.axis('off')
		l1, b1, w1, h1 = ax2.get_position().bounds
		#ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
		ax3.set_position((l1*(1),0.02, w1*1, .075))
		ax3.margins(x=0)
		ax3.xaxis.set_visible(False)
		ax3.yaxis.set_visible(False)

		ax4 = fig.add_subplot()
		a = [x for x in range(len(chip))]
		ax4.plot(chip[::-1], a, color=col1, linewidth = 1)
		
		l2, b2, w2, h2 = ax2.get_position().bounds
		ax4.set_position((l2*(.7),b2, w2*.1, h2*(1)))
		ax4.margins(y=0)
		ax4.xaxis.set_visible(False)
		ax4.yaxis.set_visible(False)

	#ChIP2 includes blue track
	elif(sample=="ChIP2"):
		ax3 = fig.add_subplot()
		ax3.plot(chip2, color=col2, linewidth = 1)
		#ax3.axis('off')
		l1, b1, w1, h1 = ax2.get_position().bounds
		#ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
		ax3.set_position((l1*(1),0.02, w1*1, .075))
		ax3.margins(x=0)
		ax3.xaxis.set_visible(False)
		ax3.yaxis.set_visible(False)

		ax4 = fig.add_subplot()
		a = [x for x in range(len(chip2))]
		ax4.plot(chip2[::-1], a, color=col2, linewidth = 1)
		
		#ax3.axis('off')
		l2, b2, w2, h2 = ax2.get_position().bounds
		#ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
		ax4.set_position((l2*(.7),b2, w2*.1, h2*(1)))
		ax4.margins(y=0)
		ax4.xaxis.set_visible(False)
		ax4.yaxis.set_visible(False)

	#ChIP1 and ChIP2 red and blue tracks together
	elif(sample=="ChIP_combined"):

		ax3 = fig.add_subplot()
		ax3.plot(chip, color=col1, linewidth = 1)
		ax3.plot(chip2, color=col2, linewidth = 1)
		#ax3.axis('off')
		l1, b1, w1, h1 = ax2.get_position().bounds
		#ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
		ax3.set_position((l1*(1),0.02, w1*1, .075))
		ax3.margins(x=0)
		ax3.xaxis.set_visible(False)
		ax3.yaxis.set_visible(False)

		print("checkpoint")
		ax4 = fig.add_subplot()
		a = [x for x in range(len(chip2))]
		ax4.plot(chip[::-1], a, color=col1)
		
		#ax3.axis('off')
		l2, b2, w2, h2 = ax2.get_position().bounds
		#ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
		ax4.set_position((l2*(.7),b2, w2*.1, h2*(1)))
		ax4.margins(y=0)
		ax4.xaxis.set_visible(False)
		ax4.yaxis.set_visible(False)

		ax5 = fig.add_subplot()

		b = [x for x in range(len(chip))]
		ax5.plot(chip[::-1], b, color=col1, linewidth = 1)
		
		a = [x for x in range(len(chip2))]
		ax5.plot(chip2[::-1], a, color=col2, linewidth = 1)

		#ax3.axis('off')
		l2, b2, w2, h2 = ax2.get_position().bounds
		#ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
		ax5.set_position((l2*(.7),b2, w2*.1, h2*(1)))
		ax5.margins(y=0)
		ax5.xaxis.set_visible(False)
		ax5.yaxis.set_visible(False)




	#write image to file
	res = ''.join(random.choices(string.ascii_uppercase +
								string.digits, k=8))
	figname = f"{sample}-{name}-{chrom}-{start}-{stop}_{bin}bp_norm-{norm}_{str(res)}.svg"

	directory = "images/"
	wwwlocation = "www/" + directory + figname
	notwwwlocation = directory + figname #this path is for 'shiny'
	plt.savefig(wwwlocation, bbox_inches='tight')
	plt.close()

	return notwwwlocation



def filterCompartments(comp, chrom, start, stop):
    print("filtering compartments")
    # Filter compartments bedGraph by selected region
    comp = pd.read_csv(comp, sep="\t", header=None, dtype={0: 'string'}, on_bad_lines='skip')
    comp.columns = ['chrom', 'start', 'stop', 'value']
    comp_filt = comp.loc[(comp['chrom'] == chrom) & (comp['start'] >= start) & (comp['stop'] <= stop)]
    return comp_filt


def scaleCompartments(disthic, comp_df, Acol, Bcol):
    #distance normalized hic matrix
    distscaled = (disthic-np.min(disthic))/(np.max(disthic)-np.min(disthic))
    print("c1")

    comp_arr = comp_df['value']
    # #Normalize on IQR
    q3, q1 = np.percentile(comp_arr, [75,25])
    print("a")
    iqr = q3 - q1
    print("b")
    comp_arr_IQR_norm = comp_arr / iqr
    print("c2")
    # Normalize data to between -1 and 1
    normd = (((comp_arr_IQR_norm-np.min(comp_arr_IQR_norm)) * ( (1) - (-1))) / (np.max(comp_arr_IQR_norm) - np.min(comp_arr_IQR_norm))) + -1
    print("c3")
    # 2.
    Acomp = np.where(normd<0, 0, normd)
    Bcomp = np.where(normd>0, 0, normd)
    print("c4")

    for i, comp in enumerate([Acomp, Bcomp]):

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

    return Amatrix, Bmatrix


def plotCompartments(disthic, comp, ABmat):
    print("plotting compartments")
    
    # Remove previous images of compartments
    for f in glob.glob('./www/images/Compartments_*.svg'):
        print(f'Removing image: {f}')
        os.remove(f)

    # Plot HiC map and compartment tracks
    mat = disthic.astype(np.uint8)

    print(f"length matrix: {len(mat)}")

    img = Image.fromarray(mat)
                
    fig, (ax2) = plt.subplots(ncols=1)

    compartments = comp['value']

    # Show distance normalized HiC
    ax2.imshow(disthic, 'gray', interpolation='none', alpha = .3)
    
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
    ax3.fill_between(compartments.index, list(compartments), where=(compartments > 0), color='orange', alpha=.5)
    ax3.fill_between(compartments.index, list(compartments), where=(compartments < 0), color='blue', alpha=.5)
    ax3.xaxis.set_visible(False)
    ax3.yaxis.set_visible(False)

    ax4 = fig.add_subplot()
    a = [x for x in range(len(compartments))]
    ax4.plot(compartments[::-1], a, color='black', linewidth = 1)

    l2, b2, w2, h2 = ax2.get_position().bounds
    ax4.set_position((l2*(.7),b2, w2*.1, h2*(1)))
    ax4.margins(y=0)
    ax4.axvline(x=0, color='black', linestyle='-')
    ax4.fill_betweenx(a, list(compartments[::-1]), where=(compartments[::-1] > 0), color='orange', alpha=.5)
    ax4.fill_betweenx(a, list(compartments[::-1]), where=(compartments[::-1] < 0), color='blue', alpha=.5)
    ax4.xaxis.set_visible(False)
    ax4.yaxis.set_visible(False)
    
    # random string for name
    # using random.choices()
    # generating random strings
    res = ''.join(random.choices(string.ascii_uppercase +
                                string.digits, k=8))
    figname = "Compartments_" + str(res) + ".svg"

    directory = "images/"
    wwwlocation = "www/" + directory + figname
    notwwwlocation = directory + figname
    plt.savefig(wwwlocation, bbox_inches='tight')
    plt.close()
    return notwwwlocation