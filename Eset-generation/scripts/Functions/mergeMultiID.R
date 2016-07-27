suppressMessages(library("plyr", character.only=TRUE))

# takes a data.frame and merge unique values that have equals values for one reference column (default 1) according to method (default concat)
# example : pp.data <- data.frame(ID = c('A','B','C','A','A'),NAME = c('SD','DD','AD','SD','AD'),VALUE = c(1,2,3,2,3))
# NOT TESTED for empty data.frame or 1 line data.frame
# merge and returns only idcolumn and mergeColumns
mergeMultiID <- function(inDf,idColumn=1,mergeColumns=2:dim(inDf)[2],multiIdMethod='concat'){
	catn = function(...){cat("LOG: ",...,"\n")};
	catn(paste("Running: mergeMultiID.R with args","idColumn=",idColumn,"- mergeColumns=",mergeColumns,"-multiIdMethod=",multiIdMethod));
	if (multiIdMethod=='mean'){
		outDf <- ddply(inDf, idColumn, function(x){
						res = NULL
						for (i in mergeColumns){
							res=cbind(res,mean(x[,i]))
						}
						return(res)
					})
	}
	else if (multiIdMethod=='max'){
		outDf <- ddply(inDf, idColumn, function(x){
						res = NULL
						for (i in mergeColumns){
							res=cbind(res,max(x[,i]))
						}
						return(res)
					})
	}
	else if (multiIdMethod=='min'){
		outDf <- ddply(inDf, idColumn, function(x){
						res = NULL
						for (i in mergeColumns){
							res=cbind(res,min(x[,i]))
						}
						return(res)
					})
	}
	else if (multiIdMethod=='concat'){
		outDf <- ddply(inDf, idColumn, function(x){
					res = NULL
					for (i in mergeColumns){
						res=cbind(res,paste(unique(x[,i]),collapse='|'))
					}
					return(res)
				})
	}
	originalColnames = colnames(inDf)
	catn(paste("originalColnames=",originalColnames))
	colnames(outDf) = originalColnames[c(idColumn,mergeColumns)]
	return(outDf)
}
