library(data.table)
library(readxl)
# MRD274 data
ASD1<- fread("spectra/dataset/MRD274/ASD.CSV")
DSP <- fread("spectra/dataset/MRD274/DSP.CSV")
FOS <- fread("spectra/dataset/MRD274/FOS.CSV")
# BalyaNorth data
ASD2<- fread("spectra/dataset/BalyaNorth/ASD.CSV")

# Lithology
LITHOLOGY_A <- fread("data/litho_A.csv")
LITHOLOGY_B <- fread("data/litho_B.csv")


ivar <- "Wavelength_(nm)"
mvars <- colnames(ASD1)[!colnames(ASD1) %in% ivar]
melt(ASD1, id.vars = ivar, measure.vars = mvars, variable.name = "Sample", value.name = "Reflectance") -> ASD1

ivar <- "Wavelength_(nm)"
mvars <- colnames(ASD2)[!colnames(ASD2) %in% ivar]
melt(ASD2, id.vars = ivar, measure.vars = mvars, variable.name = "Sample", value.name = "Reflectance") -> ASD2

mvars <- colnames(DSP)[!colnames(DSP) %in% ivar]
melt(DSP, id.vars = ivar, measure.vars = mvars, variable.name = "Sample", value.name = "Reflectance") -> DSP

mvars <- colnames(FOS)[!colnames(FOS) %in% ivar]
melt(FOS, id.vars = ivar, measure.vars = mvars, variable.name = "Sample", value.name = "Reflectance") -> FOS

DATA <- rbindlist(list(
  data.table(SourceID="asd", ProjectID="mrd",ASD1),
  data.table(SourceID="asd", ProjectID="bn",ASD2),
  data.table(SourceID="dsp", ProjectID="mrd",DSP),
  data.table(SourceID="fos", ProjectID="mrd",FOS)
  
))

DATA[,SampleID:=sub(".*:(\\w+).*", "\\1", Sample)]
DATA[,Sample:=NULL]

IDX <- DATA[,.(SampleID,SourceID,ProjectID)] |> unique()


IDX[,Lithology:=(SampleID %in% LITHOLOGY_A$SampleID) & (SampleID %in% LITHOLOGY_B$SampleID)]
fwrite(IDX, "data/IDX.csv")

