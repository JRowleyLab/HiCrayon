import numpy as np
import hicstraw
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.pyplot as plt 
import pyBigWig
import math
from PIL import Image
import os
import glob

#random string generation
import string
import random

# Read in HiC file and output selected coordinates + binsize
# as matrix. 
def readHiCasNumpy(hicfile, chrom, start, stop, norm, binsize):
	hicdump = hicstraw.HiCFile(hicfile)
	nochr = chrom.strip('chr')
	wchr = "chr" + str(nochr)
	# Try with "1" then "chr1" if an execption is made.
	try:
		hicobject = hicdump.getMatrixZoomData(nochr, nochr, "observed", norm, "BP", binsize)
	except:
		hicobject = hicdump.getMatrixZoomData(wchr, wchr, "observed", norm, "BP", binsize)

	hicnumpy = hicobject.getRecordsAsMatrix(start, stop, start, stop)
	return hicnumpy

# Cut down version of distanceMat() to work for just HiC Map
# Obtain distance matrix of HiC map,
# Normalized using threshold value
def distanceMatHiC(hicnumpy):
	thresh = 2
	print("Beginning distance matrix HiC")
	matsize = len(hicnumpy)

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
# 
def processBigwigs(bigwig,binsize,chrom,start,stop):

	print("processing bigwigs...")
	start=int(start)
	binsize=int(binsize)
	stop=int(stop)

	nochr = chrom.strip('chr')
	wchr = "chr" + str(nochr)

	bwopen = pyBigWig.open(bigwig)		
	bwlist = []

	for walker in range(start, stop+binsize, binsize):
		try:
			bwlist.append(math.log(bwopen.stats(nochr, walker, walker+binsize)[0]))
		except RuntimeError:
			bwlist.append(math.log(bwopen.stats(wchr, walker, walker+binsize)[0]))
		except ValueError:
			bwlist.append(0)
	print("done bigwig")
	return bwlist


def calc_peak_minmax(bigwig, peaks, binsize):

    peaksignal = []
    bwopen = pyBigWig.open(bigwig)	

    with open(peaks, 'r') as rp:
        for line in rp:
            li = line.strip().split('\t')
            peakstart = float(li[1])
            peakend = float(li[2])
            peakdist = peakend - peakstart
            try:
                peakmid = (math.floor((peakstart + (peakdist/2))/binsize))*binsize
                #mypeaksliststarts.append(int(mid)))
                peaksignal.append(math.log(bwopen.stats(str(li[0]), peakmid, peakmid+binsize)[0]))
            except RuntimeError:
                continue
            

    #bwmax = np.nanmean(peaksignal)
    bwmax = np.nanmedian(peaksignal)
    bwstd = np.nanstd(peaksignal)
    #bwmin = bwmax - (bwstd*2)
    bwmin = bwmax - bwstd
    bwmax = bwmax + bwstd
    if bwmin < 0:
        bwmin = 0
        bwlist = []
    return bwmin, bwmax


def getrelative(mylist, mymin, mymax):
	relativelist = []
	for h in range(0, len(mylist)):
		myscore=mylist[h]
		relscore = ((myscore-mymin)/(mymax-mymin))
		if relscore > 1:
			relativelist.append(1)
		elif relscore < 0:
			relativelist.append(0)
		else:
			relativelist.append(relscore)
	print("Get relative")
	return relativelist


def distanceMat(hicnumpy, mymin, mymax, bwlist, strength, sample):
	thresh = 2
	print(f"Calculating {sample} distance using {mymin} and {mymax} values")
	matsize = len(hicnumpy)

	bwlist_norm = getrelative(bwlist, mymin, mymax) 
	rmat = np.zeros((matsize,matsize))
	gmat = np.zeros((matsize,matsize))
	bmat = np.zeros((matsize,matsize))
	
	mydiags=[]
	for i in range(0,len(hicnumpy)):
		mydiags.append(np.nanmean(np.diag(hicnumpy, k=i)))

	for x in range(0,matsize):
		for y in range(x,matsize):
			distance=y-x
			hicscore = (hicnumpy[x,y] + 1)/(mydiags[distance]+1)
			if hicscore > thresh:
				satscore = 1
			else:
				satscore = hicscore/thresh
			
			newscore = (bwlist_norm[x] + bwlist_norm[y])/2
			# If first ChIP-seq, increase red channel
			if(sample=="ChIP1"):
				rscore = 255*newscore*satscore*strength
				rmat[x,y] = rscore
				rmat[y,x] = rscore
			# If second ChIP-seq, increase blue channel
			elif(sample=="ChIP2"):
				bscore = 255*newscore*satscore*strength
				bmat[x,y] = bscore
				bmat[y,x] = bscore


	print("done distance")
	return rmat,gmat,bmat,bwlist_norm


def convertBlacktoTrans(image):
    # Given an image, converts all black
	# pixels to transparent, allowing the 
	# placement atop another image
    img = image.convert("RGBA")
    data = img.getdata()
    newData = []
    for item in data:
        if item[0] == 0 and item[1] == 0 and item[2] == 0:
            newData.append((0, 0, 0, 0))
        else:
            newData.append(item)

    img.putdata(newData)
    return img


# Return a list of all possible sequential
# matplotlib colormaps
def matplot_colors():
	# Add in custom colors to list
	#REDMAP = LinearSegmentedColormap.from_list("bright_red", [(1,1,1),(1,0,0)])
	return plt.colormaps()


# Produce HiC map image saved to disk 
def hic_plot(REDMAP, distnormmat):
	thresh = 2
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
	ax1.matshow(distnormmat, cmap=REDMAP, vmin=0, vmax=thresh, interpolation='none')
	ax1.xaxis.set_visible(False)
	ax1.yaxis.set_visible(False)

	# random string for name
	# using random.choices()
	# generating random strings
	res = ''.join(random.choices(string.ascii_uppercase +
								string.digits, k=8))
	figname = "HiC_" + str(res) + ".svg"
	#figname = "HiC.svg"

	directory = "images/"
	wwwlocation = "www/" + directory + figname
	notwwwlocation = directory + figname
	plt.savefig(wwwlocation, bbox_inches='tight')
	plt.close()
	return notwwwlocation
	


# Produces a matplot of the hic matrix
# inversed, with a lines representing the 
# the bigwig track AND the track underneath the
# plot
def ChIP_plot(hicmatrix, rmat, gmat, bmat, bwlist, bwlist2, hicalpha, bedalpha, opacity, sample):
	thresh = 2
	print(f"Plotting {sample}...")
	#remove previously generated images

	for f in glob.glob(f'./www/images/{sample}_*.svg'):
		print(f'Removing image: {f}')
		os.remove(f)

	fig, (ax2) = plt.subplots(ncols=1)
	redmat = (np.dstack((rmat,gmat,bmat))).astype(np.uint8)
	redimg = Image.fromarray(redmat)
	redimgtrans = convertBlacktoTrans(redimg)
	
	#########################
	#black
	r=0
	g=0
	b=0
	#########################
	background = Image.new('RGBA', (len(hicmatrix),len(hicmatrix)), (r,g,b,opacity) )
	ax2.imshow(background)
	ax2.imshow(hicmatrix, 'gray', vmin=0, vmax=thresh, interpolation='none', alpha = hicalpha)
	ax2.imshow(redimgtrans, interpolation='none', alpha = bedalpha)
	#ax2.imshow(redimg, interpolation='none', alpha = bedalpha)

	ax2.xaxis.set_visible(False)
	ax2.yaxis.set_visible(False)

	# Adding ChIP track underneath matrix
	# ChIP1 includes red track
	if(sample=="ChIP1"):
		ax3 = fig.add_subplot()
		ax3.plot(bwlist, color='r')
		#ax3.axis('off')
		l1, b1, w1, h1 = ax2.get_position().bounds
		#ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
		ax3.set_position((l1*(1),0.02, w1*1, .075))
		ax3.margins(x=0)
		ax3.xaxis.set_visible(False)
		ax3.yaxis.set_visible(False)
	#ChIP2 includes blue track
	elif(sample=="ChIP2"):
		ax3 = fig.add_subplot()
		ax3.plot(bwlist, color='b')
		#ax3.axis('off')
		l1, b1, w1, h1 = ax2.get_position().bounds
		#ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
		ax3.set_position((l1*(1),0.02, w1*1, .075))
		ax3.margins(x=0)
		ax3.xaxis.set_visible(False)
		ax3.yaxis.set_visible(False)
	#ChIP1 and ChIP2 red and blue tracks together
	elif(sample=="ChIP_combined"):
		ax3 = fig.add_subplot()
		ax3.plot(bwlist, color='r')
		ax3.plot(bwlist2, color='b')
		#ax3.axis('off')
		l1, b1, w1, h1 = ax2.get_position().bounds
		#ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
		ax3.set_position((l1*(1),0.02, w1*1, .075))
		ax3.margins(x=0)
		ax3.xaxis.set_visible(False)
		ax3.yaxis.set_visible(False)



	#write image to file
	res = ''.join(random.choices(string.ascii_uppercase +
								string.digits, k=8))
	figname = f"{sample}_" + str(res) + ".svg"

	directory = "images/"
	wwwlocation = "www/" + directory + figname
	notwwwlocation = directory + figname #this path is for 'shiny'
	plt.savefig(wwwlocation, bbox_inches='tight')
	plt.close()

	return notwwwlocation