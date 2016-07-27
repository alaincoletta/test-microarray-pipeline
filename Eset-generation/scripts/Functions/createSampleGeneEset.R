# find feature information in bioconductor packages
#-------------------------------------------------------------------------------
getFromMap = function(annot, id, probes)
{
  res = mget(probes, ifnotfound=NA, get(paste(annot,id,sep="")));
  # TODO : extra check to check for one-to-one mapping ?
  return(as.vector(unlist(as.list(res))));
}

#-------------------------------------------------------------------------------
createSampleGeneEset = function(gsm, data.matrix, annot)
{
  suppressMessages(library(paste(annot,".db",sep=""), character.only=TRUE))
  
  # get annotations corresponding to the data
  features = cbind(getFromMap(annot, "ENTREZID", rownames(data.matrix)),
                   getFromMap(annot, "SYMBOL", rownames(data.matrix)),
                   getFromMap(annot, "GENENAME", rownames(data.matrix)));
  colnames(features) = c("ENTREZID", "SYMBOL", "GENENAME");
  rownames(features) = rownames(data.matrix);
    
  # remove "control" probesets, or probesets with no SYMBOLS from data and features ex:AFFX-PheX-3_at
  data.matrix.nonas = as.matrix(data.matrix[!is.na(features[,'SYMBOL']),])
  features.nonas = features[!is.na(features[,'SYMBOL']),]
  # set symbols as row.names
  row.names(data.matrix.nonas) = features.nonas[,'SYMBOL']
  colnames(data.matrix.nonas) = gsm
  row.names(features.nonas) = features.nonas[,'SYMBOL']
  
  # order data and features
  ordering.vec = order(row.names(data.matrix.nonas))
  data.matrix.nonas = as.matrix(data.matrix.nonas[ordering.vec,])
  colnames(data.matrix.nonas) = gsm
  features.nonas = features.nonas[ordering.vec,] 
  
  eset = new("ExpressionSet", exprs=data.matrix.nonas);
  annotation(eset) = annot;
  #-- set featureData(eset)
  featureData(eset) = new("AnnotatedDataFrame", 
                            data = as.data.frame(features.nonas));
  return(eset);
}
