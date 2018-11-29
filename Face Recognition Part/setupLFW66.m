function options = setupLFW66( )

%% setupLFW66函数功能： 设置总体参数
%%  @paths    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 当前工作路径
cwd=cd;
cwd(cwd=='\')='/';

options.workDir    = cwd;
options.slash      = '/'; %% For linux

%% @library paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 添加程序默认路径
if ~isdeployed
    
    %training
    addpath([cwd '/source/train/']);
    
    %testing
    addpath([cwd '/source/test/']);
    
    %common
    addpath([cwd '/common/io/']);
    addpath([cwd '/common/align/']);
    addpath([cwd '/common/string/']);
    addpath([cwd '/common/manifold/']);
    addpath([cwd '/common/err/']);
    addpath([cwd '/common/graphic/']);
    addpath([cwd '/common/vec/']);
    addpath([cwd '/common/desc/']);
    addpath([cwd '/common/regression/']);
    addpath([cwd '/common/flip/']);
    addpath([cwd '/common/eval/']);
    addpath([cwd '/model/lfw66/']);
    addpath([cwd '/common/fea/hog/']);        %% hog feature path
    %libs
    addpath([cwd '/libs/liblinear-1.93/matlab']);
    
end

options.isNoContour=0;                             %是否包含人脸轮廓，1表示没有轮廓，0表示有轮廓
options.usedetector = 1;                           %人脸框是否用人脸检测算法，1表示使用，0表示不使用
%% 人脸检测的参数设置（Matlab2012a自带）
faceDetector = vision.CascadeObjectDetector();     
faceDetector.MinSize = [50 50];
faceDetector.ScaleFactor = 1.2;
faceDetector.MergeThreshold = 2;
options.faceDetector = faceDetector;
%%  @data preparation  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.datasetName ='lfw66';    %训练数据库名
load('pts');                     %部分LFW（简称LFW66）人脸数据库的对应的人脸关键点数据
options.pts = pts;

options.trainingImageDataPath = ['D:/Projects_Face_Detection/Datasets/' options.datasetName '/trainset/'];  %训练图像路径
options.trainingTruthDataPath = ['D:/Projects_Face_Detection/Datasets/' options.datasetName '/trainset/'];  %相应训练关键点路径
    
options.testingImageDataPath  = 'D:/Projects_Face_Detection/Datasets/helen/testset/';                       %测试图像路径
options.testingTruthDataPath  = 'D:/Projects_Face_Detection/Datasets/helen/testset/';                       %相应测试关键点路径
%options.testingImageDataPath  = ['D:/Projects_Face_Detection/Datasets/' options.datasetName '/testset/'];
%options.testingTruthDataPath  = ['D:/Projects_Face_Detection/Datasets/' options.datasetName '/testset/'];

options.learningShape     = 0;      %是否学习人脸形状，1表示学习，0表示不学习
options.learningVariation = 0;      %是否学习人脸区域扰动参数，1表示学习，0表示不学习

options.flipFlag          = 1;   % the flag of flipping 人脸形状是否左右对称翻转，1表示翻转，0表示不翻转

%%  @other folders  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.tempPath      = 'temp';    %临时数据存放路径
options.modelPath     = 'model';   %模型存放路径

            
%%  @training configuration  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.canvasSize  = [250 250];           %人脸区域图像归一化后的统一大小
options.scaleFactor = 1;                   %人脸区域大小的下降因子，默认为1
options.lambda      = [1 1 1 1] * 0.005;   %规则化参数

%%  @feature configuration  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.descType  = 'xx_hog';              %特征类型
options.descSize  = [20 20 20 20];         %特征块平移大小
options.descScale = [0.16 0.16 0.16 0.16]; %尺度因子
options.descBins  =  4;                    %特征bin数
            
%%  @cascade regression %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.n_cascades     = 4;         % the number of cascades         训练级数

options.n_init_randoms = 1;         % the number of initial randoms  训练扰动数

options.n_init_randoms_test = 1;    % the number of initial randoms  测试扰动数

%%  @evaluation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options.pts_eval = 1:66;            % 关键点索引  


%% 300-W(LFPW 68 || LFW 66) dataset (68)
options.inter_ocular_left_eye_idx  = 37:42;  %左眼点索引
options.inter_ocular_right_eye_idx = 43:48;  %右眼点索引







