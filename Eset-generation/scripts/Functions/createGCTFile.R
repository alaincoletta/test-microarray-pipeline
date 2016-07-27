suppressMessages(library(Biobase))

# Writes GenePattern file (in .tgz format)
#-------------------------------------------------------------------------------
# eset = Bioconductors ExpressionSet class
# data.val = GENE or PROBE
# filename = name of .tgz file, without extension
#            (e.g. GSE27003GPL9115GENEEXPRESSIONGENE_13773)
# odir = dir where .tgz file should be written
#            (e.g. /home/insilico/data/GenomicsData/Series/GSE27003GPL9115/)
#-------------------------------------------------------------------------------
createGCTFile = function(eset, data.val, filename, odir, seriesName, platformName, measType, curid, baseAddress)
{
	#--(1)- Create dir to store .gct and .cls files
	outGctDir = paste(odir,"/",filename,sep="");
	if(file.access(outGctDir,mode=7)==-1) { dir.create(outGctDir); }
	
	#--(2)- Create .gct file
	filename = paste(outGctDir,"/",filename,".gct",sep="");
	ofile = file(filename, "w");
	on.exit(close(ofile));
	ocat = function(...) { cat(..., file=ofile, append=TRUE, sep=""); }
	
	ocat("#1.2\n");
	
	data = exprs(eset)
	ocat(nrow(data), "\t", ncol(data), "\n")
	
	ocat("Name", "\t")
	ocat("Description")
	
	names = colnames(data)
	names = gsub(" +", ".", names)
	for(name in names) { ocat("\t", name); }
	ocat("\n");
	
	m = matrix(nrow = nrow(data), ncol = ncol(data)+2)
	if(data.val=="GENE"){
		if(length(grep('ISOFORM',filename))>0){
			m[, 1]         = as.vector(fData(eset)[,"TrackingSymbol"]);
			m[, 2]         = as.vector(fData(eset)[,"GeneSymbol"]);
		}else{
			m[, 1]         = as.vector(fData(eset)[,"SYMBOL"]);
			m[, 2]         = as.vector(fData(eset)[,"GENENAME"]);
		}
	}else if(data.val=="PROBE"){
		m[, 1]         = rownames(fData(eset));
		m[, 2]         = as.vector(fData(eset)[,"SYMBOL"]);
	}else if(data.val=="USERID"){
		m[, 1]         = rownames(fData(eset));
		if(ncol(fData(eset))>1){
			m[, 2] = do.call(paste, c(fData(eset),sep=';'))
		} else if(ncol(fData(eset))==1){
			m[, 2] = as.character(fData(eset)[,1])
		} else {
			m[, 2]         = rownames(fData(eset))
		}
	}else if(data.val=="TRANSCRIPT"){
		m[, 1]         = rownames(fData(eset))
		m[, 2]         = as.vector(fData(eset)[,"SYMBOL"])
	}
	
	m[, 3:ncol(m)] = data
	
	write.table(m, file=filename, append=TRUE, quote=FALSE, sep="\t", eol="\n",
			col.names=FALSE, row.names=FALSE);
	#close(ofile);
	
	#--(3)- Create .cls files
	sampleInfo = as.data.frame(pData(eset)[colnames(data),])
        colnames(sampleInfo) <- colnames(pData(eset))
	colnames(sampleInfo) = gsub(" +",".",colnames(sampleInfo))
	colnames(sampleInfo) = gsub("/",".",colnames(sampleInfo))
	nbr_samples = nrow(sampleInfo)
	
	for(i in 1:ncol(sampleInfo))
	{
		nbr_unique = length(unique(sampleInfo[,i]));
		filename = paste(outGctDir,"/",colnames(sampleInfo)[i],".cls",sep="");
		CLSfile = file(filename,"w");
		CLScat = function(...) { cat(..., file=CLSfile, append=TRUE, sep=""); }
		CLScat(nbr_samples," ",nbr_unique," 1\n");
		CLScat("# ");
		values = unique(sort(sampleInfo[,i]));
		values = paste(gsub(" +",".",values),collapse=" ");
		CLScat(values,"\n");
		CLScat(paste(as.numeric(as.factor(sampleInfo[,i]))-1,collapse=" "),"");
		close(CLSfile);
	}
	#--(4)- Add curation to the same dir
	annotFile	= paste(outGctDir,'/',seriesName,platformName,'_cur',curid,'_annotations.txt',sep='');
	phenotypes = getAnnotations(seriesName, platformName, curid, baseAddress,  measType)
	res=pData(phenotypes)
	write.table(res,annotFile,sep="\t",quote=FALSE)
	system(paste('sed -i \'1 s/^.*$/ids\t &/\' ',annotFile,sep=""))		
	
	#--(5)- Compress dir with gct and cls files into .tgz file
	setwd(outGctDir);
	system(paste("tar -czf ",outGctDir,".tgz *",sep=""))
#	# TODO rm currently not working... :(
#	system(paste("cd .. "))
#	system(paste("rm -rf ",outGctDir))
}
