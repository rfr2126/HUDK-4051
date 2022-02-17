library(bibliometrix)
file <- ("disinformation-references.bib")
file
View(file)
M <- convert2df(file = file, dbsource = "isi", format = "bibtex")
