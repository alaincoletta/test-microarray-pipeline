suppressMessages(library(GEOquery))

# retrieve sample from GEO and return it as a vector                                                                                                                                                                           
#-------------------------------------------------------------------------------  
MAXRETRIALS = 5
createORIGINALSample = function(gsm, annot, count=0)
{
	##EDIT ALAIN TO CHECK IF Nbr of PROBES in Sample != Nbr of PROBES in Platform                                                                                                                                              
	## Nbr of PROBES in Sample != Nbr of GENE mapped PROBES in Platform                                                                                                                                                        
	library(paste(annot,".db",sep=""), character.only=TRUE);
	
	tryCatch({
				GSM <- getGEO(gsm, destdir="/tmp");
				probes <- mappedkeys(eval(as.name(paste(annot,"ACCNUM",sep=""))));
				m <- matrix(ncol=1,nrow=length(probes),data=NA, dimnames=list(probes,"Value"))
				
				
				GSMDataTable <- GSM@dataTable@table
				#old code: idx <- match(tolower(as.character(GSM@dataTable@table[["ID_REF"]])),tolower(probes))                                                                                        
				#Find the indexes of the GSM probes in ht elist of mapped probes                                                                                                                       
				idx <- match(tolower(as.character(GSMDataTable[["ID_REF"]])),tolower(probes))
				
				#retain only non NA indeces and extract only mapped probes                                                                                                                             
				GSMDataTable = GSMDataTable[!is.na(idx),]
				idx=idx[!is.na(idx)]
				if(charmatch("VALUE",colnames(GSMDataTable), nomatch=0)){
					m[idx,] <- as.numeric(GSMDataTable[["VALUE"]])
				}else if(charmatch("ABS_CALL",colnames(GSMDataTable), nomatch=0)){
					m[idx,] <- as.numeric(GSMDataTable[["ABS_CALL"]])
				}
			}, error = function(ex) {
				cat("An error was detected.\n");
				if(count<MAXRETRIALS){
					count=count+1
					if(count<3){
						Sys.sleep(sample(15:50))
					}else{
						Sys.sleep(sample(50:100))
					}
					return(createORIGINALSample(gsm, annot, count))
				}
				else{
					stop("Too many retrials: ",ex);
				}
			})
	return(m);
}

## ORIGINAL JONATAN's CODE, FILLS ESETs WITH NA VALUES IF Nbr of PROBES                                                                                                                                                    
## in Sample != Nbr of PROBES in Platform                                                                                                                                                                                  
## Nbr of PROBES in Sample != Nbr of GENE mapped PROBES in Platform                                                                                                                                                        
## else{                                                                                                                                                                                                                   
##   library(paste(annot,".db",sep=""), character.only=TRUE);                                                                                                                                                              
##   tryCatch({                                                                                                                                                                                                            
##     GSM <- getGEO(gsm, destdir="/tmp");                                                                                                                                                                                 
##     probes <- mappedkeys(eval(as.name(paste(annot,"ACCNUM",sep=""))));                                                                                                                                                  
##     m <- matrix(ncol=1,nrow=length(probes),data=NA, dimnames=list(probes,"Value"))                                                                                                                                      
##     if(charmatch("VALUE",colnames(GSM@dataTable@table), nomatch=0)){                                                                                                                                                    
##       m[idx,] <- as.numeric(GSM@dataTable@table[["VALUE"]])                                                                                                                                                             
##       }else if(charmatch("ABS_CALL",colnames(GSM@dataTable@table), nomatch=0)){                                                                                                                                         
##         m[idx,] <- as.numeric(GSM@dataTable@table[["ABS_CALL"]])                                                                                                                                                        
##         }                                                                                                                                                                                                               
##     }, interrupt = function(ex) {                                                                                                                                                                                       
##       cat("An interrupt was detected.\n");                                                                                                                                                                              
##       print(ex);                                                                                                                                                                                                        
##       }, error = function(ex) {                                                                                                                                                                                         
##         cat("An error was detected.\n");                                                                                                                                                                                
##         print(ex);                                                                                                                                                                                                      
##         })                                                                                                                                                                                                              
##   return(m);                                                                                                                                                                                                            
##   }    