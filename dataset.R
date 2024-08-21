library(data.table)
library(readxl)
ASD <- fread("data/MRD274/ASD.CSV")
DSP <- fread("data/MRD274/DSP.CSV")
FOS <- fread("data/MRD274/FOS.CSV")


ivar <- "Wavelength_(nm)"
mvars <- colnames(ASD)[!colnames(ASD) %in% ivar]
melt(ASD, id.vars = ivar, measure.vars = mvars, variable.name = "Sample", value.name = "Reflectance") -> ASD


mvars <- colnames(DSP)[!colnames(DSP) %in% ivar]
melt(DSP, id.vars = ivar, measure.vars = mvars, variable.name = "Sample", value.name = "Reflectance") -> DSP

mvars <- colnames(FOS)[!colnames(FOS) %in% ivar]
melt(FOS, id.vars = ivar, measure.vars = mvars, variable.name = "Sample", value.name = "Reflectance") -> FOS

DATA <- rbindlist(list(
  data.table(ID="asd", ASD),
  data.table(ID="dsp", DSP),
  data.table(ID="fos", FOS)
  
))

DATA[,SampleID:=sub(".*:(\\w+).*", "\\1", Sample)]
DATA[,Sample:=NULL]

SampleID <- unique(DATA$SampleID)
LTHA <- fread("data/MRD274/data_A.csv")
LTHB <- fread("data/MRD274/data_B.csv")


IDX <- data.table(SampleID=SampleID, ID=1:length(SampleID),LTHA=SampleID %in% LTHA$SampleID,LTHB=SampleID %in% LTHB$SampleID)
fwrite(IDX, "data/MRD274/IDX.csv")

IDX[LTHA==TRUE & LTHB==TRUE]
