function trainTMLFWandHelen()
%% trainTMLFWandHelen函数功能：基于部分LFW和Helen训练集的跟踪模型训练，可以参考trainTM2LFWandHelen函数
%% 使用真实形状66个点（包含脸轮廓）得到的人脸框训练跟踪模型TM
%% loading the setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = setupLFW66();
%% 加载数据
load( ['model/' options.datasetName '_ShapeModel.mat']    );
load( ['model/' options.datasetName '_DataVariation.mat'] );

%% 设置扰动参数数目，以及扰动平移和尺度大小
options.n_init_randoms = 5; 
DataVariation.mu_trans  = [0 0];
DataVariation.cov_trans = [10 0;0 10];
DataVariation.mu_scale  = [1 1];
DataVariation.cov_scale = [0.00025 0; 0 0.00025];
%% 人脸框设置 
options.usedetector = 0;        %不使用opencv人脸框，选用的是真实形状得到的人脸框
%% 特征的选取
options.descType  = 'xx_hog';  %使用hog特征
%% 加载训练数据集
load('data/lfw&helen/Data');
%% 主函数
n_cascades = options.n_cascades;
TM{n_cascades}.R = [];

rms = zeros(n_cascades,1);

for icascade = 1 : n_cascades
    
    options.current_cascade = icascade;
    
    %% learning single regressors
    if icascade == 1
        
        new_init_shape = [];
       %% 用的是真实形状66个点得到的人脸框
        [R,new_init_shape,rms(icascade)] = learn_single_regressor(ShapeModel, DataVariation, Data, new_init_shape, options );
        
        TM{icascade}.R = R;
        
        %% save other parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TM{icascade}.n_cascades = n_cascades;
        TM{icascade}.descSize   = options.descSize;
        TM{icascade}.descBins   = options.descBins;
        
        disp(['icascade = ' num2str(icascade)  'finise']);
    else
        
        [R, new_init_shape,rms(icascade)] = learn_single_regressor(ShapeModel, DataVariation, Data, new_init_shape, options );
        
        TM{icascade}.R = R;
        disp(['icascade = ' num2str(icascade)  'finise']);
    end
    
end

save('result/Trained_RMS.mat' , 'rms');
save([options.modelPath options.slash 'lfw&helen/TM3.mat'],'TM');

clear;
