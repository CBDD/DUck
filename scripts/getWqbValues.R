inputFiles=list.files(pattern="jarz.dat",recursive=T)

dataf=c()

shiftMinimum=function(d,minValue){
	localMin=min(d)
	diffToSubstract=minValue-localMin
	d=d-diffToSubstract-minValue
	return(d)
}

#read all currently created jarz.dat output files to calculate current running Wqb

for(file in inputFiles){
	r=read.table(file)
	if(length(dataf)==0) {
		dataf=as.vector(r[,4])

	}
	else {
		
		dataf=cbind(dataf,r[,4])
	}	

}


#now lets set to 0 all minima of the work curves from the SMD simulations
times=r[,1]
#get the minimum value
minValue=min(dataf)

normalizedOutput=apply(dataf,2,shiftMinimum,minValue)

#now lets get the minimum Work on all SMD curves at a particular time -> this is out Wqb value

wqb=min(normalizedOutput[which(times==4.25),])
cat(wqb)
