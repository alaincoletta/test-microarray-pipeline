suppressMessages(library(frma))
suppressMessages(library(affy))

createFRMASample = function(CELfile.path, annot, norm)
{
	cdf = paste(annot, "cdf", sep="")
	abatch = ReadAffy(filenames=CELfile.path, cdfname=cdf);
	if(norm=="FRMACDF")
	{
		frmavecs = paste(annot,"frmavecs",sep="");
		lib = sub("hsentrezgfrmavecs", "frmavecs", frmavecs);
		suppressMessages(library(lib, character.only=TRUE));
		data(list=c(frmavecs));
		# jtaminau: Currently loaded in 'vecs' parameters.
		#!! vecs will be changed to specific vecs name in new release
		#eset = frma(abatch, input.vecs=vecs);
		eset = frma(abatch, input.vecs=get(frmavecs));
	}
	else
	{
		frmavecs = paste(annot,"frmavecs",sep="");
		suppressMessages(library(frmavecs, character.only=TRUE));
		eset = frma(abatch,input.vecs=data(package=frmavecs));
	}

	return(as.matrix(exprs(eset)));
}
 
