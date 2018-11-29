function trainDMLFWandHelen()
%% trainDMLFWandHelen函数功能：基于部分LFW和Helen训练集的检测模型训练
%% 使用opencv得到的人脸框训练检测模型DM

%% loading the setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = setupLFW66();                                      %总体参数设定
options.usedetector = 1;                                     %是否使用opencv人脸检测，1表示使用，0表示不用
options.descType  = 'xx_pool';                               %特征类型

load( ['model/' options.datasetName '_ShapeModel.mat']    ); %人脸形状模型
load( ['model/' options.datasetName '_DataVariation.mat'] ); %扰动参数

%DataVariation.mu_trans  = mu_trans;
%DataVariation.cov_trans = cov_trans;
DataVariation.mu_scale  = [0.95 0.95];                       %平移扰动参数
%DataVariation.cov_scale = cov_scale;
%%options.n_init_randoms = 4; 

load('data/lfw&helen/Data');                                 %加载部分lfw和helen混合数据集（其中lfw结合人脸对齐算法和手动标定）
n_cascades = options.n_cascades;                             %级数
DM{n_cascades}.R = [];                                       %主检测模型参数
rms = zeros(n_cascades,1);                                   %保存平均误差rms

for icascade = 1 : n_cascades
    
    options.current_cascade = icascade;                      %当前级
    %% learning single regressors
    if icascade == 1
        
        new_init_shape = [];
        [R,new_init_shape,rms(icascade)] = learn_single_regressor(ShapeModel, DataVariation, Data, new_init_shape, options );  %模型学习函数
        
        DM{icascade}.R = R;                                  %主检测模型参数
        
        %% save other parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        DM{icascade}.n_cascades = n_cascades;                %级数
        DM{icascade}.descSize   = options.descSize;          %平移大小参数
        DM{icascade}.descBins   = options.descBins;          %特征bin数
        
        disp(['icascade = ' num2str(icascade)  'finise']);
    else
        
        [R, new_init_shape,rms(icascade)] = learn_single_regressor(ShapeModel, DataVariation, Data, new_init_shape, options ); %模型学习函数
        
        DM{icascade}.R = R;
        disp(['icascade = ' num2str(icascade)  'finise']);
    end
    
end

save('result/Trained_RMS.mat' , 'rms');                                    %保存平均误差
save([options.modelPath options.slash 'lfw&helen/DM_xxpool.mat'],'DM');    %保存模型

clear;
