suppressMessages(library("SCAN.UPC", character.only=TRUE));

createUPCSample <- function(CELfile.path, pkgName = NA) { 
	if (!is.na(pkgName))  
		suppressMessages(library(pkgName, character.only=TRUE));
	
	res <- UPCfast(CELfile.path, probeSummaryPackage= pkgName);
	return(as.matrix(exprs(res)));
}