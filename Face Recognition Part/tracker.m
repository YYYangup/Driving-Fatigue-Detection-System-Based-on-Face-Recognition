%% tracker函数功能：可以演示固定给定视频和实时视频的疲劳驾驶检测
%% 固定给定视频文件路径

index=6;
load('rot/rot1.mat'); r=rot1(1+(index-1)*200:200*index,:);
params.filepath = ['D:/Program Files/MATLAB/R2012a/bin/face/avi/jam' num2str(index) '.mov'];
%params.filepath='video/myVideo3.avi';
mov=VideoReader(params.filepath);

%% 基本设置
options = setupLFW66();                                       %总体参数设定
choice=3;                                                     %不同特征选取（1为xx_sift特征，2为my_sift特征，3为xx_hog特征）
if choice==1
%% 特征的选取
options.descType  = 'xx_sift';                                %特征类型
%% 加载模型
load(['model/' options.datasetName '_ShapeModel.mat']);       %人脸形状模型
load(['model/' options.datasetName '_DataVariation.mat']);    %扰动参数
load('model/lfw&helen/DM_xxsift.mat');                        %检测模型
load('model/lfw&helen/TM_xxsift5b.mat');                      %跟踪模型
elseif choice==2
%% 特征的选取
options.descType  = 'my_sift';  
%% 加载模型
load(['model/' options.datasetName '_ShapeModel.mat']);
load(['model/' options.datasetName '_DataVariation.mat']);
load('model/lfw&helen/DM_mysift.mat');     
load('model/lfw&helen/TM_mysift5b.mat');   
elseif choice==3
%% 特征的选取
options.descType  = 'xx_hog';  
%% 加载模型
load(['model/' options.datasetName '_ShapeModel.mat']);
load(['model/' options.datasetName '_DataVariation.mat']);
load('model/lfw&helen/DM_xxhog.mat');     
load('model/lfw&helen/TM_xxhog5b.mat');
else
options.descType  = 'xx_pool';  
%% 加载模型
load(['model/' options.datasetName '_ShapeModel.mat']);
load(['model/' options.datasetName '_DataVariation.mat']);
load('model/lfw&helen/DM_xxpool.mat');     
load('model/lfw&helen/TM_xxpool5b.mat');   
    
end
params.options=options;                             %总体结构体参数
params.DM=DM;                                       %检测模型
params.TM=TM;                                       %跟踪模型
params.ShapeModel=ShapeModel;                       %人脸形状模型
params.DataVariation=DataVariation;                 %扰动参数

params.number_alarm=8;                              %报警阈值数
params.interval=10;                                 %连续帧阈值数
params.delt=30;                                     %上下平移阈值（Y轴）
params.visualization = 0;                           %是否可视化报警曲线，1是，0否
params.light=0;                                     %是否考虑光照处理
params.NumberOfFrames=mov.NumberOfFrames;           %固定视频的帧数
params.image_scale=0.2;                             %人脸图像缩放比例
isvid=1;                                            %是否为实时视频，1是，0否
%% 实时视频参数设定
if isvid 
   vid = videoinput('winvideo',1, 'YUY2_640x480');  %实时视频大小设置
   set(vid,'FramesPerTrigger',Inf);
   set(vid,'ReturnedColorSpace','rgb');             
   start(vid)  
   params.vid=vid; 
   params.NumberOfFrames=300;                       %设定视频帧数
end

params.isvid=isvid;
try 
[rt,status,fps]=faceTracker(params);                %疲劳检测检测主函数
catch
   disp('catch an error');
   flushdata(vid,'all'); delete(vid); clear vid ;
end

