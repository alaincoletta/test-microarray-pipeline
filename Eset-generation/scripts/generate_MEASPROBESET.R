#==============================================================================
# generate_MEASPROBESET.R
##==============================================================================

args = commandArgs(TRUE)
gsm = args[1]
gpl = args[2]
norm = args[3]
annotDbiPkgRoot = args[4]
frmaVecPkgName = args[5]
dataValues = args[6]
name = args[7]
out.file = args[8]
script.dir = args[9]
CELfile.path = args[10]

catn = function(...){cat("LOG: ",...,"\n")};
catn("===================================================================");
catn("Running: generate_MEASPROBESET.R");
catn(paste("On host: ",system("hostname",TRUE)),sep='');
catn(paste("With R version: ",version['version.string'],sep=''));
catn("===================================================================");
catn("  call to rerun script:");
catn("    R < generate_MEASPROBESET.R --slave --args ",args[1],args[2],args[3],
                                                    args[4],args[5],args[6],
                                                    args[7],args[8],args[9],args[10]); 
catn("===================================================================");


if(is.null(annotDbiPkgRoot)) { stop("Unknown platform: ",gpl); }

load_fun = function(fun) { source(paste(script.dir,"/Functions/",fun,sep="")); }
load_fun("createORIGINALSample.R");
load_fun("createFRMASamplePkg.R");
load_fun("createSampleEset.R");
load_fun("createSCANSample.R");
load_fun("createUPCSample.R");

## Based on the normalization retrieve numerical values
data = NULL;
if(norm=="ORIGINAL")                { data = createORIGINALSample(gsm,annotDbiPkgRoot); }
if(norm=="FRMA")  					{ data = createFRMASamplePkg(CELfile.path, frmaVecPkgName); }
if(norm=="SCAN")                    { data  = createSCANSample(CELfile.path); }
if(norm=="UPC")                     { data  = createUPCSample(CELfile.path); }
if(is.null(data))                   { stop("Unknown normalization: ",norm); }

colnames(data) = gsm;

## Create ExpressionSet and add notes

eset = createSampleEset(gsm, data, annotDbiPkgRoot);

version = installed.packages()[paste(annotDbiPkgRoot,".db",sep=""),"Version"];
print(version);
notes(eset)[[paste(annotDbiPkgRoot,"Version",sep="")]] = version;
preproc(eset)<-list(normalization=list(name=norm,package=annotDbiPkgRoot,version=version));

assign(name,eset);
save(list=name, file=out.file);

catn("");
catn("Ok! File saved.");
catn("===================================================================");
