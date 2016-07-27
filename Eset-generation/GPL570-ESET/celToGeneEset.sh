#!/bin/bash

#j.path like '%/microarray/v1.1/%SCAN%.RData'


celFileNames=('GSM263933' 'GSM263934' 'GSM263935' 'GSM263936');

norm='SCAN'
nucleo='GENE'
scriptBasePath='../scripts'


platform='GPL570'
customCdfPkgRoot='hgu133plus2hsentrezg'

ws='https://insilicodb.com/app '


dataSetName='GSE10437'
measurmentTypeName='RNA'
annotationId=3109

########################
# install R deps
#########################
Rscript $scriptBasePath/install-R-packages.R
if [ $? -ne 0 ]; then
	exit
fi


########################
# create ESET per sample
#########################
measProbeResults=()

for celFileName in "${celFileNames[@]}" 
do
	measProbeResult=$celFileName$norm$nucleo
	measProbeResultFile=$measProbeResult'.RData'
	measProbeResults+=($measProbeResultFile)

	Rscript $scriptBasePath/generate_MEASGENECDF.R $celFileName $platform $norm $customCdfPkgRoot $nucleo $measProbeResult $measProbeResultFile $scriptBasePath $celFileName.CEL
done

########################
# create ESET for the dataset
#########################
esetResult=$dataSetName$platform'_'$measurmentTypeName'_'$norm$nucleo
esetResultPath=$esetResult'.RData'

# join array separated by ,
inputFiles=$(printf ",%s" "${measProbeResults[@]}")
# remove first ,
inputFiles=${inputFiles:1}

Rscript $scriptBasePath/generate_ESET.R $dataSetName $platform $measurmentTypeName $norm $nucleo $esetResult 'dummyarg' $esetResultPath $scriptBasePath $ws $inputFiles

########################
# Add annotation to the ESET
#########################
curesetResult=$dataSetName$platform'_'$measurmentTypeName'_'$norm$nucleo$annotationId
curesetResultPath=$curesetResult'.RData'

Rscript $scriptBasePath/generate_CURESET.R dataSetName $platform $measurmentTypeName $annotationId $curesetResult $curesetResultPath $scriptBasePath $ws $esetResultPath
