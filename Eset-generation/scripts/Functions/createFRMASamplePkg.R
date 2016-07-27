suppressMessages(library(frma))
suppressMessages(library(affy))

createFRMASamplePkg = function(CELfile.path, frmaVecPkgName)
{
	abatch = ReadAffy(filenames=CELfile.path);
	suppressMessages(library(frmaVecPkgName, character.only=TRUE));
	eset = frma(abatch,input.vecs=data(package=frmaVecPkgName));
	return(as.matrix(exprs(eset)));
}
 
