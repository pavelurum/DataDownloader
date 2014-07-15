#Downloader
library(zoo)  
require(iqfeed)
library(foreach)
library(doSNOW)
library(iterators)
iqConf()
daysBack <- 40
interval <- 300 #in seconds
sectorsPath <- "C://xts//Sectors//"
beginTime <- "093000"
endTime <-  "155959"


#Load all sectors
setwd("C://xts//")
cluster <- makeCluster(20, type = "SOCK", outfile="")
registerDoSNOW(cluster)
setwd(sectorsPath)
symbolsFile <- choose.files()
symbolsList <- list(tikers = read.csv(file = symbolsFile, check.names = FALSE, header = TRUE, sep=",",
                                      stringsAsFactors= FALSE, blank.lines.skip = TRUE)[,2])

setwd(paste("C://xts/",sub(".csv","",strsplit(symbolsFile,split="\\\\")[[1]][4]),sep="/"))
invisible(do.call(file.remove,list(list.files())`1))


invisible(foreach(tiker=t(symbolsList$tikers), .errorhandling = "remove", .inorder=FALSE) %dopar% {
  setwd(paste("C:/xts/",sub(".csv","",strsplit(symbolsFile,split="\\\\")[[1]][4]),sep="/"))
  require(iqfeed)
  iqConf()  
  symbol <- HIT(tiker,interval,start=format(Sys.Date()-daysBack,"%Y-%m-%d"),beginFilterTime = beginTime, endFilterTime = endTime)
  write.zoo(symbol, file=paste(tiker, ".csv", sep=""), sep=",")
})

# Download files with error
invisible(foreach(tiker=t(symbolsList$tikers), .errorhandling = "remove", .inorder=FALSE) %dopar% {
  setwd(paste("C:/xts/",sub(".csv","",strsplit(symbolsFile,split="\\\\")[[1]][4]),sep="/"))
  print(paste("C:/xts/",sub(".csv","",strsplit(symbolsFile,split="\\\\")[[1]][4]),sep="/"))
  browser()
  if(!file.exists(paste(getwd(),"/",tiker,".csv", sep = ""))){
    require(iqfeed)
    iqConf()
    symbol <- HIT(tiker,interval,start=format(Sys.Date()-daysBack,"%Y-%m-%d"),beginFilterTime = beginTime, endFilterTime = endTime)
    write.zoo(symbol, file=paste(tiker, ".csv", sep=""), sep=",")
  }
})  
stopCluster(cluster)