install.packages("rENA")
library(rENA)
data <- ENAdata$new("speech_bolsonaro05052021.csv")
data
ena.plot(data)

#file:///Users/renatorusso/Downloads/Epistemic_network_analysis_A_worked_exam.pdf