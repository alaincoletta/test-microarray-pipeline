##==============================================================================
# generate_ESET.R
##==============================================================================

args = commandArgs(TRUE);
gse 		= args[1];
gpl 		= args[2];
meas.type 	= args[3];
norm 		= args[4];
data.val 	= args[5];
name 		= args[6];
dir 		= args[7];
out.file 	= args[8];
script.dir 	= args[9];
baseAddress	= args[10];
dep.paths 	= args[11];

# url to put in the dataset information field, dataset name will be appended
url		= paste(baseAddress,"/browse/",sep="")
 
catn = function(...){cat("LOG: ",...,"\n")};
catn("===================================================================");
catn("Running: generate_ESET.R");
catn(paste("On host: ",system("hostname",TRUE)),sep='');
catn(paste("With R version: ",version['version.string'],sep=''));
catn("===================================================================");
catn("  call to rerun script:");
catn("    R < generate_ESET.R --slave --args ",args[1],args[2],args[3],
                                               args[4],args[5],args[6],
                                               args[7],args[8],args[9],
                                               args[10],args[11]); 
catn("===================================================================");

load_fun = function(fun) { source(paste(script.dir,"/Functions/",fun,sep="")); }
load_fun("mergeEset.R");
load_fun("connectDB.R");

## Iterate over samples and merge them together
eset = NULL;

# check if dep.paths is a file that ends with the extension '.dep'
if(length(grep("^.+\\.dep$",dep.paths,perl=TRUE))>0){
	inputFile <- dep.paths
	con <- file(inputFile, open = "r")
	
	while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
		sample = get(load(oneLine));
		catn(oneLine);
		eset = mergeEset(eset,sample);
	} 
	close(con)
}else{
	gsmFileLst = strsplit(dep.paths,",");
	for(gsmFile in gsmFileLst[[1]])
	{
		catn(gsmFile);
		sample = get(load(gsmFile));
		eset = mergeEset(eset,sample);
	}
}

#mergeEset function can introduce NAs if probes between samples differ
#filer out rows with NA values 
# As of 20130606, this is done upstream in generate_GCT
# eset = eset[rowSums(is.na(exprs(eset)))==0,];

eset@experimentData@name=gse;
eset@experimentData@url=pp(url,gse);
tryCatch({
	info=getDatasetInfo(gse,gpl,baseAddress,norm,data.val);
	eset@experimentData@title=info[['title']];
    },
    error=function(x){ print(paste("Error setting experiment data. ",x,sep=""));}
  );

assign(name, eset);
save(list=name, file=out.file);

catn("");
catn("Ok! File saved.");
catn("===================================================================");
