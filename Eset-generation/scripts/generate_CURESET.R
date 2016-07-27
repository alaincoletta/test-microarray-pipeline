##==============================================================================
# generate_CURESET.R
##==============================================================================

args = commandArgs(TRUE);

gse 		= args[1];
gpl 		= args[2];
meas.type 	= args[3];
curid 		= args[4];
name 		= args[5];
out.file 	= args[6];
script.dir 	= args[7];
baseAddress	= args[8];
in.file 	= args[9];

catn = function(...){cat(...,"\n")};
catn("===================================================================");
catn("Running: generate_CURESET.R");
catn(paste("On host: ",system("hostname",TRUE)),sep='');
catn(paste("With R version: ",version['version.string'],sep=''));
catn("===================================================================");
catn("  call to rerun script:");
catn("    R < generate_CURESET.R --slave --args ",args[1],args[2],args[3],
                                                  args[4],args[5],args[6],
                                                  args[7],args[8]); 
catn("gse =", args[1])
catn("gpl =", args[2])
catn("meas.type =", args[3])
catn("curid =", args[4])
catn("name =", args[5])
catn("out.file =", args[6])
catn("script.dir =", args[7])
catn("baseAddress =", args[8])
catn("in.file =", args[9])

catn("===================================================================");


load_fun = function(fun) { source(paste(script.dir,"/Functions/",fun,sep="")); }

load_fun("connectDB.R");

## > in.file
## [1] "/storage/gluster/insilico/data/GenomicsData/Series/GSE8121GPL570/GSE8121GPL570_RNA_FRMAGENE.RData"

eset = get(load(in.file));


phenotypes = getAnnotations(gse, gpl, curid, baseAddress, meas.type)
## phenotypes = getAnnotations("GSE8121","GPL570","15567", baseAddress, "RNA")
## [1] "https://insilicodb.com/app/publicutilities/getannotations?gse=GSE8121&gpl=GPL570&id=15567&measType=RNA"
## An object of class 'AnnotatedDataFrame'
##   Measurements: GSM201230 GSM201231 ... GSM201304 (75 total)
##   varLabels: course of septic shock
##   varMetadata: labelDescription

if(all(is.element(colnames(exprs(eset)), rownames(phenotypes@data)))) {
	#Here we assume that colnames of exprSet and rowname of phenotypes are identical
       #Re-order the phenotypes to make sure they match the same order as the identifiers in the eset object
	matchix <- match(colnames(exprs(eset)), rownames(phenotypes@data))
	phenotypes@data <- phenotypes@data[matchix, , drop=FALSE]
	#assign the phenotypes to the eset object
} else {
	#Here we assume that colnames of exprSet matches with the column "id" in the curated sample information provided by the users
	#So column "id" MUST be present in the phenotypes!
	matchix <- match(as.character(phenotypes@data[ , "id"]), colnames(exprs(eset)))
	exprs(eset) <- exprs(eset)[ , matchix, drop=FALSE]
	colnames(exprs(eset)) <- rownames(phenotypes@data)
}

phenoData(eset) = phenotypes;


## > pData(eset)
##           course of septic shock
## GSM201230  Normal control group 
## GSM201231  Normal control group 
## GSM201232  Normal control group 

notes(eset)[["measurementType"]] = meas.type;
notes(eset)[["inSilicoCurationId"]] = curid;
eset@experimentData@preprocessing['measurementType']=meas.type;
eset@experimentData@preprocessing['inSilicoCurationId']=curid;

assign(name, eset);
save(list=name, file=out.file);

catn("");
catn("Ok! File saved.");
catn("===================================================================");
