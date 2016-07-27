
#check if bioconductor is installed
if( !"BiocInstaller" %in% rownames(installed.packages())){
	stop("'Install bioconductor please'")
}	

bioconductorDeps=c("hgu133a.db","hgu133a2probe","SCAN.UPC",'frma','hgu133plus2.db','hgu133plus2probe')

for (bioDep in bioconductorDeps){
	if(!bioDep %in% rownames(installed.packages())){
		source("http://bioconductor.org/biocLite.R")
		biocLite(bioDep)
	}
}

rpackagesDeps=c("devtools”,’rjson’,’tcltk’)

for ( rDep in bioconductorDeps ){
	if(! rDep %in% rownames(installed.packages())){
		install.packages(rDep, dependencies = TRUE)
	}
}

library(devtools)

brainArrayBaseUrl = 'http://brainarray.mbni.med.umich.edu/Brainarray/Database/CustomCDF/'
brainArrayIdType='entrezg.download/'
packages.ext = c('probe','cdf','.db')
brainArrayVersion = "18.0.0"

brainArrayPkgDeps=c('hgu133ahsentrezg','hgu133plus2hsentrezg')

for (brainArrayPkgRoot in brainArrayPkgDeps){
	for (pkg.ext in packages.ext){
		brainArrayFullPkgName = paste(brainArrayPkgRoot,pkg.ext,sep='')
		if(!brainArrayFullPkgName %in% rownames(installed.packages())){
			brainArrayFullUrl = paste(brainArrayBaseUrl,brainArrayVersion,'/',brainArrayIdType,brainArrayFullPkgName,'_',brainArrayVersion,'.tar.gz',sep='')
			install_url(brainArrayFullUrl)
		}
		else{
			pkgInstallBuild = installed.packages()[brainArrayFullPkgName,'Built']
			RCurversion = paste(R.version$major,'.',R.version$minor,sep='')
			if(pkgInstallBuild!=RCurversion){
				brainArrayFullUrl = paste(brainArrayBaseUrl,brainArrayVersion,'/',brainArrayIdType,brainArrayFullPkgName,'_',brainArrayVersion,'.tar.gz',sep='')
				install_url(brainArrayFullUrl)
			}
		}
	}
}