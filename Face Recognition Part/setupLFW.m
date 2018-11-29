function options = setupLFW()

%% setupLFW函数功能：LFW数据集的全局参数设置，可以参考setupLFW66
%%  @paths    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cwd=cd;
cwd(cwd=='\')='/';

options.workDir    = cwd;
options.slash      = '/'; %% For linux

%% @library paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %libs
    addpath([cwd '/libs/liblinear-1.93/matlab']);
    
end
options.usedetector = 0;
options.isNoContour = 0;
faceDetector = vision.CascadeObjectDetector();
faceDetector.MinSize = [50 50];
faceDetector.ScaleFactor = 1.2;
faceDetector.MergeThreshold = 2;
options.faceDetector = faceDetector;
%%  @data preparation  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.datasetName ='lfw';  %%'lfw_color'; %'lfpw'; %'helen'; %lfw  or 'w300'
load('pts');
options.pts = pts;

options.trainingImageDataPath = ['D:/Projects_Face_Detection/Datasets/' options.datasetName '/trainset/'];
options.trainingTruthDataPath = ['D:/Projects_Face_Detection/Datasets/' options.datasetName '/trainset/'];
    
options.testingImageDataPath  = 'D:/Projects_Face_Detection/Datasets/helen/testset/';
options.testingTruthDataPath  = 'D:/Projects_Face_Detection/Datasets/helen/testset/';
%options.testingImageDataPath  = ['D:/Projects_Face_Detection/Datasets/' options.datasetName '/testset/'];
%options.testingTruthDataPath  = ['D:/Projects_Face_Detection/Datasets/' options.datasetName '/testset/'];

options.learningShape     = 0;
options.learningVariation = 0;

options.flipFlag          = 1;   % the flag of flipping

%%  @other folders  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.tempPath      = 'temp';
options.modelPath     = 'model';

            
%%  @training configuration  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.canvasSize  = [250 250];
options.scaleFactor = 1;
options.lambda      = [1 1 1 1] * 0.005;

%%  @feature configuration  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.descType  = 'mymex_sift';
options.descSize  = [20 20 20 20];
options.descScale = [0.16 0.16 0.16 0.16];
options.descBins  =  4;
            
%%  @cascade regression %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.n_cascades     = 4;         % the number of cascades

options.n_init_randoms = 1;        % the number of initial randoms

options.n_init_randoms_test = 1;    % the number of initial randoms

%%  @evaluation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options.pts_eval = 1:66;


%% 300-W(LFPW 68 || LFW 66) dataset (68)
options.inter_ocular_left_eye_idx  = 37:42;
options.inter_ocular_right_eye_idx = 43:48;







