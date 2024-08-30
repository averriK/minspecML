source("R/setup.R")


# Spectral data -----
# MRD274 data
ASD1<- fread("data-raw/spectra/dataset/MRD274/ASD.CSV")
DSP <- fread("data-raw/spectra/dataset/MRD274/DSP.CSV")
FOS <- fread("data-raw/spectra/dataset/MRD274/FOS.CSV")
# BalyaNorth data
ASD2<- fread("data-raw/spectra/dataset/BalyaNorth/ASD.CSV")


# Get data from spectrometers
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
# Tag and Bind tables
DATA <- rbindlist(list(
  data.table(SourceID="asd", ProjectID="mrd",ASD1),
  data.table(SourceID="asd", ProjectID="bn",ASD2),
  data.table(SourceID="dsp", ProjectID="mrd",DSP),
  data.table(SourceID="fos", ProjectID="mrd",FOS)
  
))
# Rename Wavelegth column to WL
setnames(DATA, "Wavelength_(nm)", "WL")
# Rename Reflectance to R
setnames(DATA, "Reflectance", "R")
# Remove shit tagged by TSG8
DATA[,SampleID:=sub(".*:(\\w+).*", "\\1", Sample)]
DATA[,Sample:=NULL]
# Build Index
IDX <- DATA[,.(SampleID,SourceID,ProjectID)] |> unique()



# Litogeochemistry data ----
# Dataset A
# Removed from Source duplicated Ni. We kept Ni values which most values above the DL 
# Removed from Source LithoID

LITH_A <- fread("data-raw/litho_A_v2.csv",check.names=TRUE) #1115 samples
LITH_A[,SetID:="A"] # Tag provider
# Remove spaces and dots from column names, LITH_A |> colnames() |> grep(pattern="[ .]",value=TRUE)

OLD <- colnames(LITH_A)
NEW <- OLD |> gsub(pattern ="[ .]", replacement="_")
setnames(LITH_A,OLD,NEW)

# Dataset B
# Removed from Source LithoID

LITH_B <- fread("data-raw/litho_B_v2.csv",check.names=TRUE) #951 samples 
LITH_B[,SetID:="B"] # Tag provider

# Removed from source Ni_4AES_pp with most values below detection limits. Use Ni_1DXMS_p instead. Anna double check

# Remove suffixes from features names
OLD <- colnames(LITH_B)
NEW <- OLD |> sub(pattern="(_4AES.*|_1DXMS.*)$", replacement="")
setnames(LITH_B,OLD,NEW)

# Remove spaces
OLD <- colnames(LITH_B)
NEW <- OLD |> gsub(pattern ="[ .]", replacement="_")
setnames(LITH_B,OLD,NEW)



# How many samples in A are also in B? 776.
intersect(LITH_A$SampleID,LITH_B$SampleID)


# Classify and identify which samples have lithochemistry data
IDX[,LGC:=(SampleID %in% LITH_A$SampleID & SampleID %in% LITH_B$SampleID) ]




# Check boundaries (min,max) of all spectra by SourceID, and set the boundary between max(min(WL)) and min(max(WL))
# 


# Build Training datasets ----
# Select spectral data with Lithogeochem available (733 records)
# DT <- DATA[LGC==TRUE & ProjectID=="mrd"]



# Merge IDX into DATA
# DATA <- IDX[DATA,on=.(SourceID,ProjectID,SampleID)]
# fwrite(DATA, "data/DATA.csv")

