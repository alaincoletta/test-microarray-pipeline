spliceEsetForSamples = function(seriespath,seriesName,platformName, listmeas1, listmeas2)
{
	gsename = paste(seriesName,platformName,"_RNA_FRMAGENE",sep='');
	gsepath = paste(seriespath,'/',gsename,".RData",sep='');
	if (!file.exists(gsepath)){
		gsename = paste(seriesName,platformName,"_RNA_ORIGINALGENE",sep='');
		gsepath = paste(seriespath,'/',gsename,".RData",sep='');
		if (!file.exists(gsepath)) {print(paste('dataset ',seriesName,' not found!'));return(NULL)}
	}
	# first test if the eset is already loaded
	print(paste('loading: ',gsepath))
	if(!exists(gsename)) load(gsepath);
	eset = eval(as.name(gsename))
	
	classLabel = 0*exprs(eset)[1,];
	classLabel[is.element(colnames(exprs(eset)),listmeas1)] = 1
	classLabel[is.element(colnames(exprs(eset)),listmeas2)] = 2
	classLabel = classLabel [classLabel!=0]
	
	selected = is.element(colnames(exprs(eset)),listmeas1) | is.element(colnames(exprs(eset)),listmeas2);
	eset = eset[,selected];
	
	return (list(eset=eset,classLabel=classLabel, esetname = as.name(gsename)))
}

