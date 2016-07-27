library("rjson");
library("RCurl");
library("Biobase");

pp = function(...) { paste(...,sep=""); }

#----------------------------------------------------------------------
getInSilicoJSON = function(url,baseAddress)
{
	address = paste(baseAddress,url,sep='/');
#	address = pp("https://insilicodb.com/app/",url);
#	address = pp("http://dev.isdb/~steenhoff/app/",url);
	header=basicHeaderGatherer()
	options = curlOptions(followlocation=TRUE)
	print(address);
	json = tryCatch(getURL(address,headerfunction=header$update,  .opts=options),
			HTTPError=function(e){cat("HTTP error: ", e$message, "\n");}
	);
#	print(json);
	lst = fromJSON(json);

	if(is.element("success",names(lst))) 
  	{   
		if(lst[["success"]]==FALSE) { stop(lst[["msg"]]); }
	}

	return(lst);
}

#----------------------------------------------------------------------
createPhenoFrame = function(annot)
{
	if(length(annot)==0)
	{
		stop("No annotations available.");
	}
	keywords = names(annot[[1]]);
	samples = names(annot);
	
	## Warning: all measurements must contain the same annotation terms.
	M = matrix(NA,nrow=length(samples),
			ncol=length(keywords),
			dimnames=list(samples, keywords));
	
	for(i in samples) 
	{
		M[i,keywords] <- unlist(annot[[i]])[keywords];
	}
	
	myPhenoFrame = new("AnnotatedDataFrame",
			data = as.data.frame(M, stringsAsFactors=FALSE),
			dimLabels=c("Measurements","Keywords"));
	return(myPhenoFrame);
}

#----------------------------------------------------------------------
#----------------------------------------------------------------------
getAnnotations = function(gse, gpl, id, baseAddress, measType=null)
{
	url=pp("publicutilities/getannotations?gse=",gse,"&gpl=",gpl,"&id=", id, "&measType=", measType);
	return(createPhenoFrame(getInSilicoJSON(url,baseAddress)));
}

#----------------------------------------------------------------------
#----------------------------------------------------------------------
getAnnotationsKeyword = function(gse, gpl, id, baseAddress, measType=null,keyword)
{
	url=pp("publicutilities/getannotations?gse=",gse,"&gpl=",gpl,"&id=", id, "&measType=", measType,"&format=true&cfactor=",keyword);
	return(createPhenoFrame(getInSilicoJSON(url,baseAddress)));
}

#----------------------------------------------------------------------
#----------------------------------------------------------------------
getSampleNames = function(gse, gpl, baseAddress, measType=null)
{
	url=pp("publicutilities/getmeasurements?gse=",gse,"&gpl=",gpl, "&measType=", measType);
	return(getInSilicoJSON(url,baseAddress));
}

#----------------------------------------------------------------------
getDatasetInfo = function(dataset,platform, baseAddress,norm,feature=null)
{
        url             = pp("interface/getdatasetinfo?dataset=",dataset,"&platform=",platform,"&job=false","&norm=",norm,'&features=',feature);
        json    = getInSilicoJSON(url,baseAddress);
        return(json[["dataset"]]);
}

getPlatformInfo = function(norm, baseAddress,extended=T)
{	
	url=pp("interface/getplatformlist?norm=",norm)
	if (extended){
		url = pp(url,"&extended=true")
	}
	json = getInSilicoJSON(url,baseAddress)
	return(json[["platforms"]])
}
