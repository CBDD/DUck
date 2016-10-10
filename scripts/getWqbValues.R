##############################
# getWqbValues.R script
# Version 07/10/16
# Rscript
##############################
#read arguments (for plotting only after the last step) --> if "plot", it will make a pdf plot and a wqb_final.txt file
args <- commandArgs(trailingOnly=TRUE);
#assign default just in case no args are present
if (length(args) > 0){
	plotornot <- args[1]
} else {
	plotornot <- "noplot"
}
#read all jarz.dat files
inputFiles=list.files(pattern="jarz.dat",recursive=T)
#if the length of inputFiles is 0 --> no SMD run yet, return 100 and quit.
if (length(inputFiles) == 0){cat("100\n");quit()}

shiftMinimum=function(d,minValue){
	localMin=min(d)
	diffToSubstract=minValue-localMin
	d=d-diffToSubstract-minValue
	return(d)
}

#initiate dataf for reading files
dataf=c()
#read all currently created jarz.dat output files to calculate current running Wqb
for(file in inputFiles){
	r=read.table(file)
	if(length(dataf)==0) {
		prov=cbind(as.vector(r[,4]))
		#normalize each file when reading (set to 0 minima before half of the simulation)
		minValue=min(prov[1:2500])
		dataf=shiftMinimum(prov,minValue)
	}
	else {
		prov=cbind(as.vector(r[,4]))
		minValue=min(prov[1:2500])
		dataf=cbind(dataf,shiftMinimum(prov,minValue))
	}	
}
#times of the simulation (first column of any jarz.dat file --> from 2.5 to 5)
times=r[,1]

#now lets get the maximum work on all SMD curves
maxwork=NULL
for (d in seq(dim(dataf)[2])){
	#calculate each maximum work for all replicas
	#maximum has to be on second half, after minimum (to avoid maximum in the beginning)
	maxwork=c(maxwork,max(dataf[,d][2501:5000]))	
}


#get the minimum value among each replica maximum work --> wqb
wqb=round(min(maxwork),2)
#if wqb is lower than 0 (negative slope), set wqb to 0
if (wqb < 0){
	wqb=0
}
cat(wqb)
cat("\n")
##############################################################
#####to plot the curves for checking the results, run the following lines:
##############################################################
if (plotornot == "plot"){
    png("wqb_plot.png")
    matplot(times,dataf,type="l",xlab="HB Distance (A)",ylab="Work (kcal/mol)")
    for (d in seq(dim(dataf)[2])){
	    a=dataf[,d]
	    maxa=which(a==max(a))
	    text(times[maxa]-0.1,a[maxa],labels=round(a[maxa],2),col=d)
    }
    dev.off()
    write(wqb,file="wqb_final.txt")
}
##############################################################
