import os
path='Assembly'#test文件所在路径
list1=os.listdir(r'{}'.format(path))
for m in list1:
    print(f'共{len(list1)}个文件夹，正在重命名第{list1.index(m)+1}个')
    list2=os.listdir(r'{}'.format(path+'/'+m))
    for i in list2:
        os.rename(r'{}/{}'.format(path+'/'+m,i),r'{}/{}'.format(path+'/'+m,m+'_'+str(list2.index(i)+1)+'.fa'))
print('转换成功')