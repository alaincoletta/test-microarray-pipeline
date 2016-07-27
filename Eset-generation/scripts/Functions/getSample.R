getPrefix = function(gsm)
{
	r = regexpr("[a-zA-Z]*[0-9]{2}",gsm)
	return(substr(gsm,r[1],attr(r,"match.length")));
}

getSampleName = function(dir, gsm, name)
{
	file = paste(dir,"/",getPrefix(gsm),"/",gsm,"/",name,sep="");
	print(paste("file:",file));
	return(file);
}

getSample = function(dir, gsm, name)
{
	file = getSampleName(dir, gsm, name);
	sample = get(load(file));
	return(sample);
}