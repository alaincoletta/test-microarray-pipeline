suppressMessages(library("SCAN.UPC", character.only=TRUE));

createSCANSample <- function(CELfile.path, pkgName = NA) { 
	if (!is.na(pkgName))
		suppressMessages(library(pkgName, character.only=TRUE));
	res <- SCANfast(CELfile.path, probeSummaryPackage= pkgName,verbose=FALSE);
	return(as.matrix(exprs(res)));
}
