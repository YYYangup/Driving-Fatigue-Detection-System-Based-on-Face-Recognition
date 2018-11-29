function fps = testing()
%% testing函数功能：不同训练集和不同模型的测试并计算平均误差

%% loading the setup and training data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LFW test
% options = setupLFW();
% load(['data/' options.datasetName options.slash  'DataLFW']);
% Data = DataLFW;  clear DataLFW;

%% LFPW test
% options = setupLFPW();
% load(['data/' options.datasetName options.slash  'DataLFPW2']);
% Data = DataLFPW2;  clear DataLFPW2;
% for idata = 1 : length(Data)
%     Data{idata}.shape_gt = Data{idata}.shape_gt([1:60 62:64 66:end],:);
% end
% options.datasetName = 'lfw';

%% Helen test
options = setupHelen();
load(['data/' options.datasetName options.slash  'DataHelen2']);
Data = DataHelen2;  clear DataHelen2;
%% 加载模型
load( ['model/' options.datasetName '_ShapeModel.mat'] );
load( ['model/' options.datasetName '_DataVariation.mat'] );
load( [options.modelPath options.slash 'lfw&helen/TM_xxhog5b.mat'] );
%% 特征参数
options.descType  = 'xx_hog';  %%使用hog特征
%% 基本参数设置
options.inter_ocular_left_eye_idx  = 20:25;
options.inter_ocular_right_eye_idx = 26:31;
options.pts_eval = 1:49;
%% 检测和跟踪设置
options.usedetector=0;    %% 为0不使用opencv检测到的人脸框  为1使用opencv检测到的人脸框
options.isNoContour=1;    %% 为0使用真实形状66个点（包含脸轮廓）为1使用真实形状49个点（不包含脸轮廓)
%% 主函数
nData = length(Data);
err = zeros(nData,1);
time=0;
ind = 18:66;
for idata = 1 : nData
    tic;
    disp(['Image: ' num2str(idata)]);
    
    %% information of one image
    img        = Data{idata}.img_gray;
    true_shape = Data{idata}.shape_gt;
    
    %% do face alignment on the image
    aligned_shape = face_alignment(ShapeModel, DataVariation ,TM, img, true_shape, options );
   
    %% compute rms errors
    err(idata) = rms_err( aligned_shape(ind,:), true_shape(ind,:), options );   
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
close all;
