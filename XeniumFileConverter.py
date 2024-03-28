# this script converts the Xenium transcripts file into a format that can be read using FICTURE
import pandas as pd
import sys

path = str(sys.argv[1])
outpath = str(sys.argv[2])
df = pd.read_csv(path+'/transcripts.csv.gz', compression='gzip')

# create a transcripts.tsv.gz file that contains the X, Y, and the gene 
df_export = df[['x_location', 'y_location', 'feature_name']]
df_export.columns = ['X', 'Y', 'gene']
df_export = df_export.groupby(['X', 'Y', 'gene']).size().reset_index(name='Count')
df_export.sort_values(by='Y', inplace=True)

df_export = df_export[~df_export['gene'].str.contains('Control')]
df_export = df_export[~df_export['gene'].str.contains('Neg')]
df_export = df_export[~df_export['gene'].str.contains('Unassigned')]

df_export.to_csv(outpath+'/transcripts.tsv.gz', sep='\t', compression='gzip', index=False)

# create a feature.clean.tsv.gz file that contains a list of the genes and their counts
df_feature = df_export.drop(['X', 'Y'], axis=1).copy()
df_feature = df_feature.groupby('gene')['Count'].sum().reset_index()

df_feature.to_csv(outpath+'/feature.clean.tsv.gz', sep='\t', compression='gzip', index=False)

# create a coordinate_minmax.tsv file
# that contains xmin, xmax, ymin, ymax
xmin = df_export['X'].min()
xmax = df_export['X'].max()
ymin = df_export['Y'].min()
ymax = df_export['Y'].max()

coordinate_minmax = {'xmin': [xmin], 'xmax': [xmax], 'ymin': [ymin], 'ymax': [ymax]}
df_minmax = pd.DataFrame(coordinate_minmax).transpose()
df_minmax.to_csv(outpath+'/coordinate_minmax.tsv', sep='\t', index=True, header=False)

print("File Conversion Done")