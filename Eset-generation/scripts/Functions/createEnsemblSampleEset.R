suppressMessages(library("biomaRt", character.only=TRUE));

createEnsemblSampleEset <- function(data, annot, ensemblDataset) {
	
	# create the expression set
	eset <- new("ExpressionSet", exprs=data);
	annotation(eset) <- annot;
	
	# create the matrix for feature data
	res <- matrix(nrow = length(rownames(eset)), ncol = 2);
	colnames(res) <- c("SYMBOL", "GENENAME");
	rownames(res) <- rownames(eset);
	
	#retrieve the feature data using biomaRt  
	#organism <- useMart("ensembl", dataset = ensemblDataset); 
	# ensembl version 74
	organism <- useMart( host = "dec2013.archive.ensembl.org",
						 biomart="ENSEMBL_MART_ENSEMBL", 
						 dataset = "hsapiens_gene_ensembl")
				 
	data <- getBM(attributes=c("ensembl_gene_id", "external_gene_id", "description"), 
			filters="ensembl_gene_id",values = rownames(eset), mart = organism); 
	
	# Set the feature data correctly 
	res[data[,"ensembl_gene_id"], "SYMBOL"] = data[, "external_gene_id"];
	res[data[,"ensembl_gene_id"], "GENENAME"] = data[, "description"];
	
	# Add the feature data to the eset
	featureData(eset) <- new("AnnotatedDataFrame",
			data = as.data.frame(res));
	return(eset);
}