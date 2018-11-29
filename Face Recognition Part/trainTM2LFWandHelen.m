function trainTM2LFWandHelen()

%% trainTM2LFWandHelen函数功能：基于部分LFW和Helen训练集的跟踪模型训练
%% 使用真实形状49个点（不包含脸轮廓）得到的人脸框训练跟踪模型TM
%% loading the setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = setupLFW66();                                       %总体参数设定
%% 加载数据
load( ['model/' options.datasetName '_ShapeModel.mat']    );  %人脸模型
load( ['model/' options.datasetName '_DataVariation.mat'] );  %扰动参数

%% 设置扰动参数数目，以及扰动平移和尺度大小
options.n_init_randoms = 5;                                   %扰动数
DataVariation.mu_trans  = [0 0];                              %平移
DataVariation.cov_trans = [20 0;0 20];                        %平移协方差
DataVariation.mu_scale  = [1 1];                              %尺度
DataVariation.cov_scale = [0.0005 0; 0 0.0005];               %尺度协方差
%% 人脸框设置 
options.usedetector = 0;                                      %不使用opencv人脸框，选用的是真实形状得到的人脸框
%% 特征的选取
options.descType  = 'xx_hog';                                 %特征类型
%% 加载训练数据集 
load('data/lfw&helen/Data');                                  %加载部分lfw和helen混合数据集（其中lfw结合人脸对齐算法和手动标定）
%% 主函数
n_cascades = options.n_cascades;                              %级数
TM{n_cascades}.R = [];                                        %主检测模型参数
rms = zeros(n_cascades,1);                                    %保存平均误差rms

for icascade = 1 : n_cascades
    
    options.current_cascade = icascade;                       %当前级
    %% learning single regressors
    if icascade == 1
        
        new_init_shape = [];
       %% 用的是真实形状49个点（剔除脸轮廓）得到的人脸框
        [R,new_init_shape,rms(icascade)] = learn_single_regressor2(ShapeModel, DataVariation, Data, new_init_shape, options );   %模型学习函数
        
        TM{icascade}.R = R;                                   %主检测模型参数
        
        %% save other parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TM{icascade}.n_cascades = n_cascades;                 %级数
        TM{icascade}.descSize   = options.descSize;           %平移大小参数
        TM{icascade}.descBins   = options.descBins;           %特征bin数
        
        disp(['icascade = ' num2str(icascade)  'finise']);
    else
        
        [R, new_init_shape,rms(icascade)] = learn_single_regressor2(ShapeModel, DataVariation, Data, new_init_shape, options );  %模型学习函数
        
        TM{icascade}.R = R;
        disp(['icascade = ' num2str(icascade)  'finise']);
    end
    
end

save('result/Trained_RMS.mat' , 'rms');                                    %保存平均误差
save([options.modelPath options.slash 'lfw&helen/TM_xxpool5b.mat'],'TM');  %保存模型

clear;
