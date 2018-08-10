clc; clear; close all;
numCls = 30; % Number of defined semantic classes in cityscape
radius = 2; % Defined search radius for label changes (related to edge thickness, default value of the CASENet CVPR paper)
edge_type = 'regular';
%  readdir='D:\cv_workspace\sbd_dataset\benchmark_RELEASE\dataset';
readdir='/opt/data/data/citiscape/gtFine/train/'
dataRoot='/opt/data/data/citiscape/leftImg8bit/train/'
genDataRoot = '/opt/sddf/rd-yzchen/test/CASEnet/code_cyz';
delete([genDataRoot '/list_train.txt'])
       if(exist([genDataRoot '/label/train/' ], 'file')==0)
                mkdir([genDataRoot '/label/train/' ]);
       end
 fidIn = fopen([dataRoot  'train_raw_list' '.txt']);
  fileName = fgetl(fidIn);
  fileList = cell(1,1);
  countFile = 0;
    while ischar(fileName)
        countFile = countFile + 1;
        fileList{countFile} = fileName;
        fileName = fgetl(fidIn);
        
    end
 fclose(fidIn);

 
 for idxFile = 1:countFile
      fileName = fileList{idxFile};
      img = imread([fileName  '.png']);
      %img = imread([dataRoot fileName  '.png']);
      %filefull = ['/opt/data/data/citiscape/gtFine/cls/' fileName '.mat']; 
      filefull = [  dataRoot strrep(fileName,'gtFine_labelIds','leftImg8bit')  '.mat']; 
      
      %save(file,img,'-mat');
      save (filefull ,'img');
      gt=load(filefull);
      seg=gt.img;
      [height, width, chn] = size(seg);
      labelEdge = zeros(height, width, 'uint32');
      for idx_cls = 1:numCls
        idxSeg = seg == idx_cls;
        if(sum(idxSeg(:))~=0)
            idxEdge = seg2edge(idxSeg, radius, [], edge_type);
            labelEdge(idxEdge) = labelEdge(idxEdge) + 2^(idx_cls-1);
        end
      end
      
      fidLabel = fopen([genDataRoot '/label/train/' num2str(idxFile) '.bin'],'w');
      fwrite(fidLabel, labelEdge', 'uint32');
      fclose(fidLabel);
      fidListTrain = fopen([genDataRoot '/list_train.txt'], 'a+');
      fileName = fileList{idxFile};
      fprintf(fidListTrain, [  fileName '.png ' ['/label/train/' num2str(idxFile) '.bin\n']]);
      fclose(fidListTrain);
 end
 
 fidListTrain = fopen([genDataRoot '/list_train.txt'], 'w');
 for idxFile = 1:countFile
     fileName = fileList{idxFile};
     fprintf(fidListTrain, [ fileName '.png ' fileName '.bin\n']);
 end
 fclose(fidListTrain)
