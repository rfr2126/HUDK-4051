ADL <- read.table(
  "http://publicifsv.sund.ku.dk/~kach/scaleval_IRT/ADL.txt", 
  sep=' ', 
  header = TRUE,
  na.strings = '.')
names(ADL)

comp <- complete.cases(ADL)
ADL.comp <- ADL[comp,]
items <- ADL.comp[,-1]
