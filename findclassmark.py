import os

# list1=[x for x in os.listdir('.') if os.path.isfile(x) and os.path.splitext[1]=='jpg' ]
#currentpath='D:\\cv_workspace\\sbd_dataset\\benchmark_RELEASE\\dataset'

trainpath='/opt/data/data/citiscape/gtFine/train/'
testpath='/opt/data/data/citiscape/gtFine/test/'
valpath='/opt/data/data/citiscape/gtFine/val/'
# list0=[x for x in os.walk(r'D:\cv_workspace\sbd_dataset\benchmark_RELEASE\dataset')]
#list0=[x for x in os.walk(currentpath)]
#list1=[x for x in os.walk(currentpath) if os.path.isfile(x) and os.path.splitext(x)[1]=='.mat']

list1 =[]
for root, dirs, files in os.walk(trainpath):
    list1.extend([os.path.join(root,x) for x in files if (os.path.isfile(os.path.join(root, x)) and os.path.splitext(os.path.join(root, x))[1]=='.png' and 'label'  in os.path.splitext(os.path.join(root, x))[0])])
# print(list1)

fpath = os.path.join(trainpath,'train_file_list.txt')

with open(fpath, 'w') as f:
    for matfile in list1:
        rec=os.path.splitext(matfile)[0]
	f.truncate() 
        f.write(rec+'\n')
    
# print('list0='+str(list0))
# print('list1='+str(list1))
# listmat=[]
# for rawfilename in list0:
#     if os.path.splitext(rawfilename)[1]=='.jpg':
#         listmat.append(rawfilename)

# print(listmat)
