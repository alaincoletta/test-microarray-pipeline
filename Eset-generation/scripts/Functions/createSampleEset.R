# find feature information in bioconductor packages
#-------------------------------------------------------------------------------
getFromMap = function(annot, id, probes)
{
  res = mget(probes, ifnotfound=NA, get(paste(annot,id,sep="")));
  # TODO : extra check to check for one-to-one mapping ?
  return(as.vector(unlist(as.list(res))));
}

#-------------------------------------------------------------------------------
createSampleEset = function(gsm, data, annot)
{
  library(paste(annot,".db",sep=""), character.only=TRUE);
  
  eset = new("ExpressionSet", exprs=data);
  annotation(eset) = annot;
  
  #-- set featureData(eset)

  features = cbind(getFromMap(annot, "ENTREZID", rownames(data)),
                   getFromMap(annot, "SYMBOL", rownames(data)),
                   getFromMap(annot, "GENENAME", rownames(data)));
  colnames(features) = c("ENTREZID", "SYMBOL", "GENENAME");
  rownames(features) = rownames(data);

  featureData(eset) = new("AnnotatedDataFrame", 
                            data = as.data.frame(features));

  return(eset);
}
