library(bibliometrix)
file <- ("disinformation-references.bib")
file
View(file)
M <- convert2df(file = file, dbsource = "isi", format = "bibtex")
biblioshiny()

View(M)

results <- biblioAnalysis(M, sep = ";")
results

options(width=100)
S <- summary(object = results, k = 10, pause = FALSE)

plot(x = results, k = 10, pause = FALSE)

#Authors’ Dominance ranking
DF_dominance <- dominance(results, k = 10)
DF_dominance


#Create keyword co-occurrences network
NetMatrix <- biblioNetwork(M, analysis = "co-occurrences", network = "keywords", sep = ";")

#Plot the network
net = networkPlot(NetMatrix, normalize="association", weighted=T, n = 30, Title = "Keyword Co-occurrences", type = "fruchterman", size=T,edgesize = 5,labelsize=0.7)

#Conceptual Structure using keywords (method="CA")
CS <- conceptualStructure(M,field="ID", method="CA", minDegree=4, clust=5, stemming=FALSE, labelsize=10, documents=10)
