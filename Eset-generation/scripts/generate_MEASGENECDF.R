#==============================================================================
# generate_MEASGENECDF.R
##==============================================================================

args = commandArgs(TRUE);
gsm = args[1]
gpl = args[2];
norm = args[3];
customCdfPkgRoot = args[4];
dataValues = args[5];
name = args[6];
out.file = args[7];
script.dir = args[8]
CELfile.path = args[9];

## BrainArray custom CDFs only works with SCAN

catn = function(...){cat("LOG: ",...,"\n")};
catn("===================================================================");
catn("Running: generate_MEASGENECDF.R");
catn(paste("On host: ",system("hostname",TRUE)),sep='');
catn(paste("With R version: ",version['version.string'],sep=''));
catn("===================================================================");
catn("  call to rerun script:");
catn("    R < generate_MEASGENECDF.R --slave --args ",args[1],args[2],args[3],
                                                    args[4],args[5],args[6],
                                                    args[7],args[8],args[9]); 
catn("===================================================================");


if(is.null(customCdfPkgRoot)) { stop("Unknown platform: ",gpl); }

load_fun = function(fun) { source(paste(script.dir,"/Functions/",fun,sep="")); }
load_fun("createSampleGeneEset.R");
load_fun("createSCANSample.R");
load_fun("createUPCSample.R");

## Based on the normalization retrieve numerical values
data = NULL;
if(norm=="SCAN")	{ data  = createSCANSample(CELfile.path,pkgName=paste(customCdfPkgRoot,'probe',sep='')) }
if(norm=="UPC")		{ data  = createUPCSample(CELfile.path,pkgName=paste(customCdfPkgRoot,'probe',sep='')) }
if(is.null(data))	{ stop("Unknown normalization: ",norm) }

colnames(data) = gsm;

## Create Gene-centered ExpressionSet with annotations and add notes
eset = createSampleGeneEset(gsm, data, customCdfPkgRoot);

version = installed.packages()[paste(customCdfPkgRoot,".db",sep=""),"Version"];
print(version);
notes(eset)[[paste(customCdfPkgRoot,"Version",sep="")]] = version;
preproc(eset)<-list(normalization=list(name=norm,package=customCdfPkgRoot,version=version));

assign(name,eset);
save(list=name, file=out.file);

catn("");
catn("Ok! File saved.");
catn("===================================================================");
