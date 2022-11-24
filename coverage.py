import pandas as pd
import os
names=['Name','Length'	,'Bases'	,'Coverage'	,'Reads'	,'RPKM'	,'Frags'	,'FPKM']
def get_table(path):
  return pd.read_table(path,names=names,sep='\t',skiprows=[0,1,2,3,4],index_col =None)
def get_all_table(dir_path):
  tables={}
  for file in os.listdir(dir_path):
    if 'coverage' in file:
      dt=get_table(dir_path+'/'+file)
      tables[file.split('-')[0]]=dt

  return tables
def mk_Coverage(tables):
   dic1={}
   dic1['Name']=tables[list(tables.keys())[0]]['Name']
   for x in tables:
     dic1[x]=tables[x][names[3]].tolist()
   return dic1
def mk_RPKM(tables):
   dic={}
   dic['Name']=tables[list(tables.keys())[0]]['Name']
   for x in tables:
     dic[x]=tables[x][names[5]].tolist()
   return dic
def create_excel(dir_path,xls_name):
    tables=get_all_table(dir_path)
    Coverage=pd.DataFrame(mk_Coverage(tables))
    RPKM=pd.DataFrame(mk_RPKM(tables))
    xlsx = pd.ExcelWriter(r"%s.xlsx"%xls_name)
    Coverage.to_excel(xlsx, sheet_name="Coverage", index=False)
    RPKM.to_excel(xlsx, sheet_name="RPKM", index=False)
    print("保存完成")
    xlsx.close()

dir_path='path'
name='all_hgcA'
create_excel(dir_path,name)
