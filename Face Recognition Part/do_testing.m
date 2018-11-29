function fps = do_testing ( )
%% do_testing函数功能：在标准数据集上进行实验结果测试并计算平均误差
%% fps为返回的帧速，用来反映效率
%% loading the setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% options = setupHelen();
% options.descType  = 'xx_sift';
% %% loading training data
% load( ['model/' options.datasetName '_ShapeModel.mat']    );
% load( ['model/' options.datasetName '_DataVariation.mat'] );
% load( [options.modelPath options.slash 'helen/TM_xxsift.mat'] );

%% loading the setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = setupLFPW();
options.descType  = 'xx_sift';
%% loading training data
load( ['model/' options.datasetName '_meanShapeModel.mat']    );
load( ['model/' options.datasetName '_meanDataVariation.mat'] );
load( [options.modelPath options.slash 'lfpw/DM_meanxxsift.mat'] );

%% loading the setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% options = setupHelen();                                         %总体参数设置
% options.descType  = 'xx_pool';                                  %特征类型
% %% loading training data 加载形状模型和扰动参数以及跟踪模型TM
% load( ['model/' options.datasetName '_ShapeModel.mat']    );    
% load( ['model/' options.datasetName '_DataVariation.mat'] );
% load( [options.modelPath options.slash 'helen/TM_xxpool.mat'] );

%% test cascaded regression  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imgDir = options.testingImageDataPath;    %测试人脸图像路径
ptsDir = options.testingTruthDataPath;    %测试人脸关键点路径

%% loading data
Data  = load_all_data2( imgDir, ptsDir, options );      %加载所以测试集的图像和关键点数据，并用Data结构体保存
nData = length(Data);


%% evaluating on whole data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%DataVariation.mu_scale  = [0.95 0.95];

err = zeros(nData,1);          %保存误差
time=0;                        %计算总时间
for idata = 1 : nData
    tic;
    disp(['Image: ' num2str(idata)]);
    
    %% information of one image
     img        = Data{idata}.img_gray;     %人脸区域图像
     true_shape = Data{idata}.shape_gt;     %真实人脸形状
    
    %% do face alignment on the image
     aligned_shape = face_alignment(ShapeModel, DataVariation ,TM, img, true_shape, options );  %形状回归
   
    %% compute rms errors
     err(idata) = rms_err( aligned_shape, true_shape, options );        %计算误差
     
     %%aligned_shape =    aligned_shape(18:end,:);
    if 0
        figure(1); imshow(img); hold on;
        %draw_shape(true_shape(:,1), true_shape(:,2),'r');
        draw_shape(aligned_shape(:,1), aligned_shape(:,2),'g');
        hold off;
        pause;
    end
    time=time+toc;
    
end
fps=nData/time
close all;

%% 画CED误差统计曲线
%% displaying CED
x = [0 : 0.001 :0.5];
cumsum = zeros(length(x),1);

c = 0;

for thres = x
    
    c = c + 1;
    idx = find(err <= thres);
    cumsum(c) = length(idx)/nData;
    
end

figure(2);
plot( x, cumsum, 'LineWidth', 2 , 'MarkerEdgeColor','r');

grid on;

axis([0 0.3 0 1]);

eval_name = ['W300_LFPW_sdm' '.mat'];

EVAL.rms = err;

save(['result/' eval_name],'EVAL');

%% displaying rms errors
disp(['ERR average: ' num2str(mean(err))]);

