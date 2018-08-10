clc; clear; close all;
addpath(genpath('/opt/sddf/rd-yzchen/test/CASENet'))
numCls = 30; % Number of defined semantic classes in cityscape
radius = 2; % Defined search radius for label changes (related to edge thickness, default value of the CASENet CVPR paper)
edge_type = 'regular';

% Setup Parallel Pool
%numWorker = 20; % Number of matlab workers for parallel computing
%matlabVer = version('-release');
%if( str2double(matlabVer(1:4)) > 2013 || (str2double(matlabVer(1:4)) == 2013 && strcmp(matlabVer(5), 'b')) )
   % delete(gcp('nocreate'));
   % parpool('local', numWorker);
%else
   % if(matlabpool('size')>0) %#ok<*DPOOL>
     %   matlabpool close
   % end
    %matlabpool open 8
%end

%dir to transfer the _label.png to .mat 
%  readdir='D:\cv_workspace\sbd_dataset\benchmark_RELEASE\dataset';
readdir='/opt/data/data/citiscape/gtFine/train/'
%dir contrains raw imgs
dataRoot='/opt/data/data/citiscape/leftImg8bit/train/'
%dir to put .bin and trainedgebin.txt
genDataRoot = '/opt/sddf/rd-yzchen/test/CASEnet/code_cyz';
delete([genDataRoot '/list_train.txt'])
%generate folder
       if(exist([genDataRoot '/label/train/' ], 'file')==0)
                mkdir([genDataRoot '/label/train/' ]);
       end
   %step 1, read the label list 
 fidIn = fopen([readdir  'train_label_list' '.txt']);
  fileName = fgetl(fidIn);
  fileList = cell(1,1);
  countFile = 0;
    while ischar(fileName)
        countFile = countFile + 1;
        fileList{countFile} = fileName;
        fileName = fgetl(fidIn);
        
    end
 fclose(fidIn);

 
 %step 2, transfer *_label.png to *.mat and rename it by the way
%%parfor_progress(countFile);
 for idxFile = 1:countFile
      fileName = fileList{idxFile};
      img = imread([readdir fileName  '.png']);
      %img = imread([dataRoot fileName  '.png']);
      %filefull = ['/opt/data/data/citiscape/gtFine/cls/' fileName '.mat']; 
      filefull = [  dataRoot strrep(fileName,'gtFine_labelIds','leftImg8bit')  '.mat']; 
      
      %save(file,img,'-mat');
      save (filefull ,'img');
    % parfor_progress();
 end
 %parfor_progress(0);
 %read the list contains the raw imgs
 fidIn = fopen([dataRoot  'train_raw_list' '.txt']);
 fileName = fgetl(fidIn);
 fileList = cell(1,1);
 countFile2 = 0;
   while ischar(fileName)
    countFile2 = countFile2 + 1;
       fileList{countFile2} = fileName;
       fileName = fgetl(fidIn);
       
   end
fclose(fidIn);
%parfor_progress(countFile2);
   for idxFile = 1:countFile2
    fileName = fileList{idxFile};
    %img = imread([fileName  '.png']);
    %img = imread([dataRoot fileName  '.png']);
    %filefull = ['/opt/data/data/citiscape/gtFine/cls/' fileName '.mat']; 
    filefull = [  dataRoot strrep(fileName,'gtFine_labelIds','leftImg8bit')  '.mat']; 
    %search for *.mat in the same name
    gt=load(filefull);
    seg=gt.img;
    [height, width, chn] = size(seg);
    labelEdge = zeros(height, width, 'uint32');
    for idx_cls = 1:numCls       %travel over classes
      idxSeg = seg == idx_cls;          % idxSeg is the mask of class idx_cls
      if(sum(idxSeg(:))~=0)             %class exist in .mat
          idxEdge = seg2edge(idxSeg, radius, [], edge_type);        %call segment function
          labelEdge(idxEdge) = labelEdge(idxEdge) + 2^(idx_cls-1);  
      end
    end
    %write edge to .bin
    fidLabel = fopen([genDataRoot '/label/train/' num2str(idxFile) '.bin'],'w');
    fwrite(fidLabel, labelEdge', 'uint32');
    fclose(fidLabel);
    %write *.png and *.bin to trainEdgeBin.txt
    fidListTrain = fopen([genDataRoot '/list_train.txt'], 'a+');
    fileName = fileList{idxFile};
    fprintf(fidListTrain, [  fileName '.png ' ['/label/train/' num2str(idxFile) '.bin\n']]);
    fclose(fidListTrain);
    %parfor_progress();
   end 
%parfor_progress(0);
% fclose(fidIn);
%  fidListTrain = fopen([genDataRoot '/list_train.txt'], 'w');
%  for idxFile = 1:countFile
%      fileName = fileList{idxFile};
%      fprintf(fidListTrain, [ fileName '.png ' fileName '.bin\n']);
%  end
%  fclose(fidListTrain)
