import sys
import argparse
import numpy as np
import hicstraw
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.pyplot as plt 
import pyBigWig
import math
from PIL import Image


def readHiCasNumpy(hicfile, chrom, start, stop, norm, binsize):
	hicdump = hicstraw.HiCFile(hicfile)
	nochr = chrom.strip('chr')
	wchr = "chr" + str(nochr)
	try:
		hicobject = hicdump.getMatrixZoomData(nochr, nochr, "observed", norm, "BP", binsize)
	except MemoryError:
		hicobject = hicdump.getMatrixZoomData(wchr, wchr, "observed", norm, "BP", binsize)

	hicnumpy = hicobject.getRecordsAsMatrix(start, stop, start, stop)
	print("HiC Complete")
	return hicnumpy
	

# helper function for plotting

def plot_hic_map(dense_matrix, maxcolor):
	# Get normalization factors
	REDMAP = LinearSegmentedColormap.from_list("bright_red", [(1, 1, 1), (1, 0, 0)])
	plt.matshow(dense_matrix, cmap=REDMAP, vmin=0, vmax=maxcolor)
	plt.show()

def getinversered(myimg):
	r, g, b = myimg.split()
	g = r.point(lambda i: (255-i))
	b = r.point(lambda i: (255-i))
	r = r.point(lambda i: 255)
	wimg = Image.merge('RGB', (r,g,b))
	return(wimg)


def getinverseblue(myimg):
	r, g, b = myimg.split()
	g = b.point(lambda i: (255-i))
	r = b.point(lambda i: (255-i))
	b = b.point(lambda i: 255)
	wimg = Image.merge('RGB', (r,g,b))
	return(wimg)


def processBigwigs(bigwig,min,max,peaks,binsize,chrom,start,stop,bigwig2,min2,max2,peaks2):

	start=int(start)
	binsize=int(binsize)
	stop=int(stop)

	if bigwig2 == "NULL":

		redbwopen = pyBigWig.open(bigwig)		
		redpeaksignal = []

		if peaks == "NULL":
			redbwmin = float(min)
			redbwmax = float(max)
		else:
			with open(peaks, 'r') as rp:
				for line in rp:
					li = line.strip().split('\t')
					#myredpeakslistchr.append(str(li[0]))
					peakstart = float(li[1])
					peakend = float(li[2])
					peakdist = peakend - peakstart
					try:
						peakmid = (math.floor((peakstart + (peakdist/2))/binsize))*binsize
						#myredpeaksliststarts.append(int(mid)))
						redpeaksignal.append(math.log(redbwopen.stats(str(li[0]), peakmid, peakmid+binsize)[0]))
					except RuntimeError:
						continue
		
			#redbwmax = np.nanmean(redpeaksignal)
			redbwmax = np.nanmedian(redpeaksignal)
			redbwstd = np.nanstd(redpeaksignal)
			#redbwmin = redbwmax - (redbwstd*2)
			redbwmin = redbwmax - redbwstd
			redbwmax = redbwmax + redbwstd
		if redbwmin < 0:
			redbwmin = 0
		redbwlist = []
		for walker in range(start, stop+binsize, binsize):
			try:
				redbwlist.append(math.log(redbwopen.stats(chrom, walker, walker+binsize)[0]))
			except ValueError:
				redbwlist.append(0)

		bluebwlist="NULL"
		bluebwmax="NULL"
		bluebwmin="NULL"
				
	else:
		
		redbwopen = pyBigWig.open(bigwig)
		redpeaksignal = []
		if peaks == "NULL":
			redbwmin = float(min)
			redbwmax = float(max)
		else:
			with open(peaks, 'r') as rp:
				for line in rp:
					li = line.strip().split('\t')
					peakstart = float(li[1])
					peakend = float(li[2])
					peakdist = peakend - peakstart
					try:
						peakmid = (math.floor((peakstart + (peakdist/2))/binsize))*binsize
						redpeaksignal.append(math.log(redbwopen.stats(str(li[0]), peakmid, peakmid+binsize)[0]))
					except RuntimeError:
						continue
			redbwmax = np.nanmedian(redpeaksignal)
			redbwstd = np.nanstd(redpeaksignal)
			redbwmin = redbwmax - redbwstd
			redbwmax = redbwmax + redbwstd
		if redbwmin < 0:
			redbwmin = 0
		
		bluebwopen = pyBigWig.open(bigwig2)
		bluepeaksignal = []
		if peaks2 == "NULL":
			bluebwmin = float(min2)
			bluebwmax = float(max2)
		else:
			with open(peaks2, 'r') as rp:
				for line in rp:
					li = line.strip().split('\t')
					peakstart = float(li[1])
					peakend = float(li[2])
					peakdist = peakend - peakstart
					try:

						peakmid = (math.floor((peakstart + (peakdist/2))/binsize))*binsize
						bluepeaksignal.append(math.log(bluebwopen.stats(str(li[0]), peakmid, peakmid+binsize)[0]))
					except RuntimeError:
						continue
			#bluebwmax = np.nanmean(bluepeaksignal)
			bluebwmax = np.nanmedian(bluepeaksignal)
			bluebwstd = np.nanstd(bluepeaksignal)
			#bluebwmin = bluebwmax - (bluebwstd*2)
			bluebwmin = bluebwmax - bluebwstd
			bluebwmax = bluebwmax + bluebwstd
		if bluebwmin < 0:
			bluebwmin = 0

		#redbwopen = pyBigWig.open(redbw)
		redbwlist = []
		#bluebwopen = pyBigWig.open(bluebw)
		bluebwlist = []
		for walker in range(start, stop+binsize, binsize):
			#redbwlist.append(redbwopen.stats(chrom, walker, walker+binsize)[0])
			#bluebwlist.append(bluebwopen.stats(chrom, walker, walker+binsize)[0])
			try:
				redbwlist.append(math.log(redbwopen.stats(chrom, walker, walker+binsize)[0]))
			except ValueError:
				redbwlist.append(0)
			try:
				bluebwlist.append(math.log(bluebwopen.stats(chrom, walker, walker+binsize)[0]))
			except ValueError:
				bluebwlist.append(0)
	print("BW list complete")
	return redbwlist, redbwmax, redbwmin, bluebwlist, bluebwmax, bluebwmin


def getrelative(mylist, mymax, mymin):
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

# Cut down version of distanceMat() to work for just HiC Map
def distanceMatHiC(hicnumpy, thresh):
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
	print("HiC distance created")
	return(distnormmat)


# Calculates distance matrix for hic and both chipseq sets if selected. 
# Redo to be more flexible
def distanceMat(hicnumpy, redbwlist, redbwmax, redbwmin, bluebwlist, bluebwmax, bluebwmin,thresh):
	matsize = len(hicnumpy)

	redlist = getrelative(redbwlist, redbwmax, redbwmin)
	rmat = np.zeros((matsize,matsize))
	gmat = np.zeros((matsize,matsize))
	bmat = np.zeros((matsize,matsize))

	if bluebwlist != "NULL":
		rmat2 = np.zeros((matsize,matsize))
		gmat2 = np.zeros((matsize,matsize))
		bmat2 = np.zeros((matsize,matsize))
		bluelist = getrelative(bluebwlist, bluebwmax, bluebwmin)
	
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
			
			newscore = (redlist[x] + redlist[y])/2
			rscore = 255*newscore*satscore
			rmat[x,y] = rscore
			rmat[y,x] = rscore

			if bluebwlist != "NULL":
				newscoreblue = (bluelist[x] + bluelist[y])/2
				bscore = 255*newscoreblue*satscore
				bmat2[x,y] = bscore
				bmat2[y,x] = bscore
			else:
				rmat2="NULL"
				gmat2="NULL"
				bmat2="NULL"
				bluelist="NULL"
					
	print("Distance complete")
	return rmat,gmat,bmat,distnormmat,rmat2,gmat2,bmat2,redlist,bluelist


def hic_plot(REDMAP, figname, thresh, distnormmat):

	print("Plotting HiC")
	# Save distance normalized HiC plot and display. This is base functionality of the app and 
	# only requires a HiC file.
	fig, (ax1) = plt.subplots(ncols=1)

	#ax1.set_title('Hi-C')
	ax1.matshow(distnormmat, cmap=REDMAP, vmin=0, vmax=thresh)
	ax1.xaxis.set_visible(False)
	ax1.yaxis.set_visible(False)
	plt.savefig(figname, bbox_inches='tight')
	print("Plot Created")
	


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
	filename="HiCrayon.svg"
	# plt.rcParams['figure.dpi'] = 300
	# plt.rcParams['savefig.dpi'] = 300
	plt.savefig(filename, bbox_inches='tight')
	# n1=str(redname) + " mean,stdev in peaks is " + str(round(redbwmin,2)) + "," + str(round(redbwmax,2))
	if bluelist != "NULL":
		bluebwmin = "NULL"
		bluebwmax = "NULL"
	# 	n2=str(bluename) + " mean,stdev in peaks is " + str(round(bluebwmin,2)) + "," + str(round(bluebwmax,2))
	# 	n1=n2+n1
	#print(str(ll) + " " + str(bb) + " " + str(ww) + " " + str(hh))
	return(redbwmin,redbwmax,bluebwmin,bluebwmax)
