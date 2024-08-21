

import pandas as pd
# MRD274 data
ASD1 = pd.read_csv("spectra/dataset/MRD274/ASD.CSV")
DSP = pd.read_csv("spectra/dataset/MRD274/DSP.CSV")
FOS = pd.read_csv("spectra/dataset/MRD274/FOS.CSV")

# BalyaNorth data
ASD2 = pd.read_csv("spectra/dataset/BalyaNorth/ASD.CSV")

# Lithology
LITH_A = pd.read_csv("data/litho_A.csv")
LITH_B = pd.read_csv("data/litho_B_V2.csv")

ivar = "Wavelength_(nm)"
mvars = ASD1.columns.difference([ivar])
ASD1 = pd.melt(ASD1, id_vars=ivar, value_vars=mvars, var_name="Sample", value_name="Reflectance")

mvars = ASD2.columns.difference([ivar])
ASD2 = pd.melt(ASD2, id_vars=ivar, value_vars=mvars, var_name="Sample", value_name="Reflectance")

mvars = DSP.columns.difference([ivar])
DSP = pd.melt(DSP, id_vars=ivar, value_vars=mvars, var_name="Sample", value_name="Reflectance")

mvars = FOS.columns.difference([ivar])
FOS = pd.melt(FOS, id_vars=ivar, value_vars=mvars, var_name="Sample", value_name="Reflectance")

DATA = pd.concat([
    ASD1.assign(SourceID="asd", ProjectID="mrd"),
    ASD2.assign(SourceID="asd", ProjectID="bn"),
    DSP.assign(SourceID="dsp", ProjectID="mrd"),
    FOS.assign(SourceID="fos", ProjectID="mrd"),
], ignore_index=True)

DATA['SampleID'] = DATA['Sample'].str.extract(r'.*:(\w+).*')[0]
DATA = DATA.drop(columns='Sample')

IDX = DATA[['SampleID', 'SourceID', 'ProjectID']].drop_duplicates()

IDX['LithoGeochem_A'] = IDX['SampleID'].isin(LITH_A['SampleID']) 
IDX['LithoGeochem_B'] = IDX['SampleID'].isin(LITH_B['SampleID'])

IDX.to_csv("data/IDX.csv", index=False)
