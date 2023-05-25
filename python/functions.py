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




def plotting(rmat,gmat,bmat,distnormmat,redname,thresh,redlist,overlayoff):

	REDMAP = "YlOrRd"

	# # Save distance normalized HiC plot and display. This is base functionality of the app and 
	# # only requires a HiC file.
	# fig, (ax1) = plt.subplots(ncols=1)
	# redmat = (np.dstack((rmat,gmat,bmat))).astype(np.uint8)
	# redimg = Image.fromarray(redmat)

	# #ax1.set_title('Hi-C')
	# ax1.matshow(distnormmat, cmap=REDMAP, vmin=0, vmax=thresh)
	# ax1.xaxis.set_visible(False)
	# ax1.yaxis.set_visible(False)
	# plt.savefig("HiC.svg", bbox_inches='tight')

	
	fig, (ax2) = plt.subplots(ncols=1)
	redmat = (np.dstack((rmat,gmat,bmat))).astype(np.uint8)
	redimg = Image.fromarray(redmat)

	ax2.set_title(redname)
	
	# allow setting of 'gray' to other colors
	ax2.imshow(distnormmat, 'gray', interpolation='none')
	ax2.imshow(redimg, interpolation='none', alpha=0.7)
	ax2.xaxis.set_visible(False)
	ax2.yaxis.set_visible(False)

	ax3 = fig.add_subplot()
	ax3.plot(redlist, color='r')
	ax3.axis('off')
	l1, b1, w1, h1 = ax2.get_position().bounds
	ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
		
		#f.set_figheight(.5)
		#fig.suptitle(str(chrom) + ":" + str(start) + "-" + str(stop))
	# else:
	# 	fig, ax = plt.subplots(2,2, figsize=(15,15))


	# 	redmat = (np.dstack((rmat,gmat,bmat))).astype(np.uint8)
	# 	redimg = Image.fromarray(redmat)

	# 	ax[0,0].set_title('Hi-C')
	# 	ax[0,0].matshow(distnormmat, cmap=REDMAP, vmin=0, vmax=thresh)
	# 	ax[0,0].xaxis.set_visible(False)
	# 	ax[0,0].yaxis.set_visible(False)
	# 	#plt.savefig("distnorm.png")

	# 	ax[1,0].set_title(redname)
	# 	if overlayoff == True:
	# 		redimg = getinversered(redimg)
	# 		ax[1,0].imshow(redimg, interpolation='none', cmap=REDMAP)
	# 	else:
	# 		ax[1,0].imshow(distnormmat, 'gray', interpolation='none')
	# 		ax[1,0].imshow(redimg, interpolation='none', alpha=0.7)
	# 	ax[1,0].xaxis.set_visible(False)
	# 	ax[1,0].yaxis.set_visible(False)
	# 	#plt.savefig("bw1_overlay.png")

	# 	#if bluebw != "NULL":
	# 	bluemat = (np.dstack((rmat2,gmat2,bmat2))).astype(np.uint8)
	# 	blueimg = Image.fromarray(bluemat)
	# 	ax[1,1].set_title(bluename)
	# 	if overlayoff == True:
	# 		blueimg = getinverseblue(blueimg)
	# 		ax[1,1].imshow(blueimg, interpolation='none')
	# 	else:
	# 		ax[1,1].imshow(distnormmat, 'gray', interpolation='none')
	# 		ax[1,1].imshow(blueimg, interpolation='none', alpha=0.7)
	# 	ax[1,1].xaxis.set_visible(False)
	# 	ax[1,1].yaxis.set_visible(False)
	# 	#plt.savefig("bw2_overlay.png")
	# 	ax[0,1].set_title(str(redname + ' + ' + bluename))
	# 	if overlayoff == True:
	# 		ax[0,1].imshow(redimg, interpolation='none', alpha=0.75)
	# 		ax[0,1].imshow(blueimg, interpolation='none', alpha=0.5)
	# 	else:
	# 		ax[0,1].imshow(distnormmat, 'gray', interpolation='none')
	# 		ax[0,1].imshow(redimg, interpolation='none', alpha=0.5)
	# 		ax[0,1].imshow(blueimg, interpolation='none', alpha=0.5)
	# 	ax[0,1].xaxis.set_visible(False)
	# 	ax[0,1].yaxis.set_visible(False)
	# 	#plt.savefig("bw1_bw2_overlay.png")
	# 	#ax[0,0].set_xlabel(str(chrom) + ":" + str(start) + "-" + str(end))
	# 	ax3 = fig.add_subplot(223)
	# 	ax3.plot(redlist, color='r')
	# 	ax3.axis('off')
	# 	l1, b1, w1, h1 = ax[1,0].get_position().bounds
	# 	ax3.set_position((l1*(.875),0.04, w1*1.095, .07))

	# 	newax4 = fig.add_subplot(224)
	# 	newax4.plot(bluelist, color='b')
	# 	newax4.axis('off')
	# 	l2, b2, w2, h2 = ax[1,1].get_position().bounds
	# 	newax4.set_position((l2*(.97),0.04, w2*1.095, .07))
	# 	#fig.suptitle(str(chrom) + ":" + str(start) + "-" + str(stop))

	#plt.tight_layout()
	#plt.subplots_adjust(top=0.85)
	directory = "www/images/"
	filename="HiCrayon.svg"
	wwwlocation = "images/" + filename
	filelocation = directory + "/" + filename
	# plt.rcParams['figure.dpi'] = 300
	# plt.rcParams['savefig.dpi'] = 300
	plt.savefig(filelocation, bbox_inches='tight')
	# n1=str(redname) + " mean,stdev in peaks is " + str(round(redbwmin,2)) + "," + str(round(redbwmax,2))
	if bluelist != "NULL":
		bluebwmin = "NULL"
		bluebwmax = "NULL"
	# 	n2=str(bluename) + " mean,stdev in peaks is " + str(round(bluebwmin,2)) + "," + str(round(bluebwmax,2))
	# 	n1=n2+n1
	#print(str(ll) + " " + str(bb) + " " + str(ww) + " " + str(hh))
	return(wwwlocation)



# Not sure if this is used, if not then DELETE
# def plot_hic_map(dense_matrix, maxcolor):
# 	# Get normalization factors
# 	REDMAP = LinearSegmentedColormap.from_list("bright_red", [(1, 1, 1), (1, 0, 0)])
# 	plt.matshow(dense_matrix, cmap=REDMAP, vmin=0, vmax=maxcolor)
# 	plt.show()


# Gets inverse of an image in RED.
def getinversered(myimg):
	r, g, b = myimg.split()
	g = r.point(lambda i: (255-i))
	b = r.point(lambda i: (255-i))
	r = r.point(lambda i: 255)
	wimg = Image.merge('RGB', (r,g,b))
	return(wimg)


# Gets inverse of an image in BLUE.
def getinverseblue(myimg):
	r, g, b = myimg.split()
	g = b.point(lambda i: (255-i))
	r = b.point(lambda i: (255-i))
	b = b.point(lambda i: 255)
	wimg = Image.merge('RGB', (r,g,b))
	return(wimg)






# def processBigwigs(bigwig,min,max,peaks,binsize,chrom,start,stop,bigwig2,min2,max2,peaks2):

# 	start=int(start)
# 	binsize=int(binsize)
# 	stop=int(stop)

# 	if bigwig2 == "NULL":

# 		redbwopen = pyBigWig.open(bigwig)		
# 		redpeaksignal = []

# 		if peaks == "NULL":
# 			redbwmin = float(min)
# 			redbwmax = float(max)
# 		else:
# 			with open(peaks, 'r') as rp:
# 				for line in rp:
# 					li = line.strip().split('\t')
# 					#myredpeakslistchr.append(str(li[0]))
# 					peakstart = float(li[1])
# 					peakend = float(li[2])
# 					peakdist = peakend - peakstart
# 					try:
# 						peakmid = (math.floor((peakstart + (peakdist/2))/binsize))*binsize
# 						#myredpeaksliststarts.append(int(mid)))
# 						redpeaksignal.append(math.log(redbwopen.stats(str(li[0]), peakmid, peakmid+binsize)[0]))
# 					except RuntimeError:
# 						continue
		
# 			#redbwmax = np.nanmean(redpeaksignal)
# 			redbwmax = np.nanmedian(redpeaksignal)
# 			redbwstd = np.nanstd(redpeaksignal)
# 			#redbwmin = redbwmax - (redbwstd*2)
# 			redbwmin = redbwmax - redbwstd
# 			redbwmax = redbwmax + redbwstd
# 		if redbwmin < 0:
# 			redbwmin = 0
# 		redbwlist = []
# 		for walker in range(start, stop+binsize, binsize):
# 			try:
# 				redbwlist.append(math.log(redbwopen.stats(chrom, walker, walker+binsize)[0]))
# 			except ValueError:
# 				redbwlist.append(0)

# 		bluebwlist="NULL"
# 		bluebwmax="NULL"
# 		bluebwmin="NULL"
				
# 	else:
		
# 		redbwopen = pyBigWig.open(bigwig)
# 		redpeaksignal = []
# 		if peaks == "NULL":
# 			redbwmin = float(min)
# 			redbwmax = float(max)
# 		else:
# 			with open(peaks, 'r') as rp:
# 				for line in rp:
# 					li = line.strip().split('\t')
# 					peakstart = float(li[1])
# 					peakend = float(li[2])
# 					peakdist = peakend - peakstart
# 					try:
# 						peakmid = (math.floor((peakstart + (peakdist/2))/binsize))*binsize
# 						redpeaksignal.append(math.log(redbwopen.stats(str(li[0]), peakmid, peakmid+binsize)[0]))
# 					except RuntimeError:
# 						continue
# 			redbwmax = np.nanmedian(redpeaksignal)
# 			redbwstd = np.nanstd(redpeaksignal)
# 			redbwmin = redbwmax - redbwstd
# 			redbwmax = redbwmax + redbwstd
# 		if redbwmin < 0:
# 			redbwmin = 0
		
# 		bluebwopen = pyBigWig.open(bigwig2)
# 		bluepeaksignal = []
# 		if peaks2 == "NULL":
# 			bluebwmin = float(min2)
# 			bluebwmax = float(max2)
# 		else:
# 			with open(peaks2, 'r') as rp:
# 				for line in rp:
# 					li = line.strip().split('\t')
# 					peakstart = float(li[1])
# 					peakend = float(li[2])
# 					peakdist = peakend - peakstart
# 					try:

# 						peakmid = (math.floor((peakstart + (peakdist/2))/binsize))*binsize
# 						bluepeaksignal.append(math.log(bluebwopen.stats(str(li[0]), peakmid, peakmid+binsize)[0]))
# 					except RuntimeError:
# 						continue
# 			#bluebwmax = np.nanmean(bluepeaksignal)
# 			bluebwmax = np.nanmedian(bluepeaksignal)
# 			bluebwstd = np.nanstd(bluepeaksignal)
# 			#bluebwmin = bluebwmax - (bluebwstd*2)
# 			bluebwmin = bluebwmax - bluebwstd
# 			bluebwmax = bluebwmax + bluebwstd
# 		if bluebwmin < 0:
# 			bluebwmin = 0

# 		#redbwopen = pyBigWig.open(redbw)
# 		redbwlist = []
# 		#bluebwopen = pyBigWig.open(bluebw)
# 		bluebwlist = []
# 		for walker in range(start, stop+binsize, binsize):
# 			#redbwlist.append(redbwopen.stats(chrom, walker, walker+binsize)[0])
# 			#bluebwlist.append(bluebwopen.stats(chrom, walker, walker+binsize)[0])
# 			try:
# 				redbwlist.append(math.log(redbwopen.stats(chrom, walker, walker+binsize)[0]))
# 			except ValueError:
# 				redbwlist.append(0)
# 			try:
# 				bluebwlist.append(math.log(bluebwopen.stats(chrom, walker, walker+binsize)[0]))
# 			except ValueError:
# 				bluebwlist.append(0)
# 	print("BW list complete")
# 	return redbwlist, redbwmax, redbwmin, bluebwlist, bluebwmax, bluebwmin










# Calculates distance matrix for hic and both chipseq sets if selected. 
# Redo to be more flexible
# def distanceMat(hicnumpy, redbwlist, redbwmax, redbwmin, bluebwlist, bluebwmax, bluebwmin,thresh):
# 	matsize = len(hicnumpy)

# 	redlist = getrelative(redbwlist, redbwmax, redbwmin)
# 	rmat = np.zeros((matsize,matsize))
# 	gmat = np.zeros((matsize,matsize))
# 	bmat = np.zeros((matsize,matsize))

# 	if bluebwlist != "NULL":
# 		rmat2 = np.zeros((matsize,matsize))
# 		gmat2 = np.zeros((matsize,matsize))
# 		bmat2 = np.zeros((matsize,matsize))
# 		bluelist = getrelative(bluebwlist, bluebwmax, bluebwmin)
	
# 	mydiags=[]
# 	for i in range(0,len(hicnumpy)):
# 		mydiags.append(np.nanmean(np.diag(hicnumpy, k=i)))

# 	distnormmat = np.zeros((matsize,matsize))
# 	for x in range(0,matsize):
# 		for y in range(x,matsize):
# 			distance=y-x
# 			hicscore = (hicnumpy[x,y] + 1)/(mydiags[distance]+1)
# 			if hicscore > thresh:
# 				distnormmat[x,y] = thresh
# 				distnormmat[y,x] = thresh
# 				satscore = 1
# 			else:
# 				distnormmat[x,y] = hicscore
# 				distnormmat[y,x] = hicscore
# 				satscore = hicscore/thresh
			
# 			newscore = (redlist[x] + redlist[y])/2
# 			rscore = 255*newscore*satscore
# 			rmat[x,y] = rscore
# 			rmat[y,x] = rscore

# 			if bluebwlist != "NULL":
# 				newscoreblue = (bluelist[x] + bluelist[y])/2
# 				bscore = 255*newscoreblue*satscore
# 				bmat2[x,y] = bscore
# 				bmat2[y,x] = bscore
# 			else:
# 				rmat2="NULL"
# 				gmat2="NULL"
# 				bmat2="NULL"
# 				bluelist="NULL"
					
# 	print("Distance complete")
# 	return rmat,gmat,bmat,distnormmat,rmat2,gmat2,bmat2,redlist,bluelist


# redistribute the below 'plotting' function into separate functions for creating plots

def plotting(rmat,gmat,bmat,distnormmat,chrom,start,stop,rmat2,gmat2,bmat2,redname,bluename,thresh,redbwmin,redbwmax,bluebwmin,bluebwmax,redlist,bluelist,overlayoff):

	#REDMAP = LinearSegmentedColormap.from_list("bright_red", [(1,1,1),(1,0,0)])
	REDMAP = "YlOrRd"

	# Save distance normalized HiC plot and display. This is base functionality of the app and 
	# only requires a HiC file.
	fig, (ax1) = plt.subplots(ncols=1)
	redmat = (np.dstack((rmat,gmat,bmat))).astype(np.uint8)
	redimg = Image.fromarray(redmat)

	#ax1.set_title('Hi-C')
	ax1.matshow(distnormmat, cmap=REDMAP, vmin=0, vmax=thresh)
	ax1.xaxis.set_visible(False)
	ax1.yaxis.set_visible(False)
	plt.savefig("HiC.svg", bbox_inches='tight')

	if bluelist == "NULL":
		fig, (ax1, ax2) = plt.subplots(1,2, sharex=False, sharey=False)
		redmat = (np.dstack((rmat,gmat,bmat))).astype(np.uint8)
		redimg = Image.fromarray(redmat)

		#ax1.set_title('Hi-C')
		ax1.matshow(distnormmat, cmap=REDMAP, vmin=0, vmax=thresh)
		ax1.xaxis.set_visible(False)
		ax1.yaxis.set_visible(False)
		#plt.savefig("distnorm.svg", bbox_inches='tight')
		#ax1.set_xlabel(str(chrom) + ":" + str(start) + "-" + str(end))

		ax2.set_title(redname)
		if overlayoff == True:
			print("overlayoff step1")
			redimg = getinversered(redimg)
			print("overlayoff step2")
			ax2.imshow(redimg, interpolation='none', cmap=REDMAP)
		else:
			ax2.imshow(distnormmat, 'gray', interpolation='none')
			ax2.imshow(redimg, interpolation='none', alpha=0.7)
		ax2.xaxis.set_visible(False)
		ax2.yaxis.set_visible(False)

		ax3 = fig.add_subplot()
		ax3.plot(redlist, color='r')
		ax3.axis('off')
		l1, b1, w1, h1 = ax2.get_position().bounds
		ax3.set_position((l1*(.97),0.18, w1*1.1, .075))
		
		#f.set_figheight(.5)
		#fig.suptitle(str(chrom) + ":" + str(start) + "-" + str(stop))
	else:
		fig, ax = plt.subplots(2,2, figsize=(15,15))


		redmat = (np.dstack((rmat,gmat,bmat))).astype(np.uint8)
		redimg = Image.fromarray(redmat)

		ax[0,0].set_title('Hi-C')
		ax[0,0].matshow(distnormmat, cmap=REDMAP, vmin=0, vmax=thresh)
		ax[0,0].xaxis.set_visible(False)
		ax[0,0].yaxis.set_visible(False)
		#plt.savefig("distnorm.png")

		ax[1,0].set_title(redname)
		if overlayoff == True:
			redimg = getinversered(redimg)
			ax[1,0].imshow(redimg, interpolation='none', cmap=REDMAP)
		else:
			ax[1,0].imshow(distnormmat, 'gray', interpolation='none')
			ax[1,0].imshow(redimg, interpolation='none', alpha=0.7)
		ax[1,0].xaxis.set_visible(False)
		ax[1,0].yaxis.set_visible(False)
		#plt.savefig("bw1_overlay.png")

		#if bluebw != "NULL":
		bluemat = (np.dstack((rmat2,gmat2,bmat2))).astype(np.uint8)
		blueimg = Image.fromarray(bluemat)
		ax[1,1].set_title(bluename)
		if overlayoff == True:
			blueimg = getinverseblue(blueimg)
			ax[1,1].imshow(blueimg, interpolation='none')
		else:
			ax[1,1].imshow(distnormmat, 'gray', interpolation='none')
			ax[1,1].imshow(blueimg, interpolation='none', alpha=0.7)
		ax[1,1].xaxis.set_visible(False)
		ax[1,1].yaxis.set_visible(False)
		#plt.savefig("bw2_overlay.png")
		ax[0,1].set_title(str(redname + ' + ' + bluename))
		if overlayoff == True:
			ax[0,1].imshow(redimg, interpolation='none', alpha=0.75)
			ax[0,1].imshow(blueimg, interpolation='none', alpha=0.5)
		else:
			ax[0,1].imshow(distnormmat, 'gray', interpolation='none')
			ax[0,1].imshow(redimg, interpolation='none', alpha=0.5)
			ax[0,1].imshow(blueimg, interpolation='none', alpha=0.5)
		ax[0,1].xaxis.set_visible(False)
		ax[0,1].yaxis.set_visible(False)
		#plt.savefig("bw1_bw2_overlay.png")
		#ax[0,0].set_xlabel(str(chrom) + ":" + str(start) + "-" + str(end))
		ax3 = fig.add_subplot(223)
		ax3.plot(redlist, color='r')
		ax3.axis('off')
		l1, b1, w1, h1 = ax[1,0].get_position().bounds
		ax3.set_position((l1*(.875),0.04, w1*1.095, .07))

		newax4 = fig.add_subplot(224)
		newax4.plot(bluelist, color='b')
		newax4.axis('off')
		l2, b2, w2, h2 = ax[1,1].get_position().bounds
		newax4.set_position((l2*(.97),0.04, w2*1.095, .07))
		#fig.suptitle(str(chrom) + ":" + str(start) + "-" + str(stop))

	#plt.tight_layout()
	#plt.subplots_adjust(top=0.85)
	directory = "www/images/"
	filename="HiCrayon.svg"
	wwwlocation = "images/" + filename
	filelocation = directory + "/" + filename
	# plt.rcParams['figure.dpi'] = 300
	# plt.rcParams['savefig.dpi'] = 300
	plt.savefig(filelocation, bbox_inches='tight')
	# n1=str(redname) + " mean,stdev in peaks is " + str(round(redbwmin,2)) + "," + str(round(redbwmax,2))
	if bluelist != "NULL":
		bluebwmin = "NULL"
		bluebwmax = "NULL"
	# 	n2=str(bluename) + " mean,stdev in peaks is " + str(round(bluebwmin,2)) + "," + str(round(bluebwmax,2))
	# 	n1=n2+n1
	#print(str(ll) + " " + str(bb) + " " + str(ww) + " " + str(hh))
	return(wwwlocation)
