import pandas as pd

# Read the Excel files
df = pd.read_excel('HUMAN-RPKM.xlsx')
df2 = pd.read_excel('Base.xlsx', header=None)

print('文件读取成功，请稍等计算')

# Create a dictionary from df2 using a more efficient method
dicts = pd.Series(df2[1].values, index=df2[0]).to_dict()

# Normalize the values in df using vectorized operations
for m, n in dicts.items():
    df[m] = df[m] / n * 1000000000

print('计算成功，请稍等保存xlsx')

# Save the normalized dataframe to an Excel file with ZIP64 enabled
with pd.ExcelWriter('HUMAN-RPKM_NOR.xlsx', engine='xlsxwriter', options={'use_zip64': True}) as writer:
    df.to_excel(writer, index=None)

print('保存成功！')
