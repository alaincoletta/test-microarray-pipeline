suppressMessages(library(Biobase));

mergeEset = function(eset1,eset2)
{
  if(is.null(eset1)) { return(eset2); }
  if(is.null(eset2)) { return(eset1); }
  eset = combine(eset1, eset2);
  # TODO better store intersection of notes ?
  notes(eset) = notes(eset1);
  #not doing this as it doesn't take out duplicate info
  #preproc(eset)=append(preproc(eset1),preproc(eset2));
  preproc(eset)=preproc(eset1);
  print(notes(eset));
  return(eset);
}
