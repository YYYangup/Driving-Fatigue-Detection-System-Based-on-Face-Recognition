function fps = do_testing ( )

%% loading the setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = setupfacewarehouse();
options.descType  = 'xx_sift';
%% loading training data
load( ['model/facewarehouse_4ShapeModel.mat']    );
load( ['model/facewarehouse_4DataVariation.mat'] );
load( [options.modelPath options.slash 'facewarehouse/DM_4xxsift4.mat'] );
MeanShapeModel=ShapeModel;
MeanDataVariation=DataVariation;
MeanDM=DM;
load( ['model/facewarehouse_openmouseShapeModel.mat']    );
load( ['model/facewarehouse_openmouseDataVariation.mat'] );
load( [options.modelPath options.slash 'facewarehouse/DM_openmousexxsift4.mat'] );
OpenmouseShapeModel=ShapeModel;
OpenmouseDataVariation=DataVariation;
OpenmouseDM=DM;
load( ['model/facewarehouse_closeeyeShapeModel.mat']    );
load( ['model/facewarehouse_closeeyeDataVariation.mat'] );
load( [options.modelPath options.slash 'facewarehouse/DM_closeeyexxsift4.mat'] );
CloseeyeShapeModel=ShapeModel;
CloseeyeDataVariation=DataVariation;
CloseeyeDM=DM;
load( ['model/facewarehouse_leyeShapeModel.mat']    );
load( ['model/facewarehouse_leyeDataVariation.mat'] );
load( [options.modelPath options.slash 'facewarehouse/DM_leyexxsift4.mat'] );
LeyeShapeModel=ShapeModel;
LeyeDataVariation=DataVariation;
LeyeDM=DM;
load( ['model/facewarehouse_reyeShapeModel.mat']    );
load( ['model/facewarehouse_reyeDataVariation.mat'] );
load( [options.modelPath options.slash 'facewarehouse/DM_reyexxsift4.mat'] );
ReyeShapeModel=ShapeModel;
ReyeDataVariation=DataVariation;
ReyeDM=DM;
% load( ['model/' options.datasetName '_rightShapeModel.mat']    );
% load( ['model/' options.datasetName '_rightDataVariation.mat'] );
% load( [options.modelPath options.slash 'facewarehouse/DM_rightxxsift4.mat'] );
% RightShapeModel=ShapeModel;
% RightDataVariation=DataVariation;
% RightDM=DM;
% load( ['model/' options.datasetName '_leftShapeModel.mat']    );
% load( ['model/' options.datasetName '_leftDataVariation.mat'] );
% load( [options.modelPath options.slash 'facewarehouse/DM_leftxxsift4.mat'] );
% LeftShapeModel=ShapeModel;
% LeftDataVariation=DataVariation;
% LeftDM=DM;
%% loading the setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% options = setupLFPW();
% options.descType  = 'vl_sift';
% %% loading training data
% load( ['model/' options.datasetName '_ShapeModel.mat']    );
% load( ['model/' options.datasetName '_DataVariation.mat'] );
% load( [options.modelPath options.slash 'LFPW/TM_vlsift.mat'] );

%% loading the setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% options = setupHelen();
% options.descType  = 'xx_pool';
% %% loading training data
% load( ['model/' options.datasetName '_ShapeModel.mat']    );
% load( ['model/' options.datasetName '_DataVariation.mat'] );
% load( [options.modelPath options.slash 'helen/TM_xxpool.mat'] );

%% test cascaded regression  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 imgDir = options.testingImageDataPath;
 ptsDir = options.testingTruthDataPath;

%% loading data
 Data  = load_all_data2( imgDir, ptsDir, options );
 nData = length(Data);
% img_path='./dataset/lfpw/testset/';
% n=200;
% img_dir=dir([img_path '*.*g']);

%% evaluating on whole data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%DataVariation.mu_scale  = [0.95 0.95];

%err = zeros(nData,1);
time=0;
for idata = 1 : n
    tic;
    disp(['Image: ' num2str(idata)]);
    
    %% information of one image
   img        = Data{idata}.img_gray;
   true_shape = Data{idata}.shape_gt;
    %% do face alignment on the image
%      img=imread([img_path img_dir(idata).name]);
     aligned_shape = face_alignment(MeanShapeModel, MeanDataVariation ,MeanDM, img, true_shape,  options ); 
     M=compute_mouse(aligned_shape);
     E=compute_eye(aligned_shape);
     L=compute_leye(aligned_shape);
     R=compute_reye(aligned_shape); 
     D=L-R;
%      B=compute_RL(aligned_shape);
    %% choose which model is the best
%      if B>30
%            aligned_shape = face_alignment(RightShapeModel, RightDataVariation ,RightDM, img, true_shape, options ) ; 
%      elseif B<-30
%            aligned_shape = face_alignment(LeftShapeModel, LeftDataVariation ,LeftDM, img, true_shape, options ) ;
     if M>70
           aligned_shape = face_alignment(OpenmouseShapeModel, OpenmouseDataVariation ,OpenmouseDM, img, true_shape, options ) ;        
     elseif E<8
           aligned_shape = face_alignment(CloseeyeShapeModel, CloseeyeDataVariation ,CloseeyeDM, img, true_shape, options ) ;        
     elseif D>2.5
           aligned_shape = face_alignment(LeyeShapeModel, LeyeDataVariation ,LeyeDM, img, true_shape, options ) ;        
     elseif D<-2.5
           aligned_shape = face_alignment(ReyeShapeModel, ReyeDataVariation ,ReyeDM, img, true_shape, options ) ;        
     end
%      if B>10
%            aligned_shape = face_alignment(RightShapeModel, RightDataVariation ,RightDM, img, true_shape, options ) ;        
%      end
%      if B<-10
%            aligned_shape = face_alignment(LeftShapeModel, LeftDataVariation ,LeftDM, img, true_shape, options ) ;        
%      end

    %% compute rms errors
%      err(idata) = rms_err( aligned_shape, true_shape, options );
     
     %%aligned_shape =    aligned_shape(18:end,:);
    if 1
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
% x = [0 : 0.001 :0.5];
% cumsum = zeros(length(x),1);
% 
% c = 0;
% 
% for thres = x
%     
%     c = c + 1;
%     idx = find(err <= thres);
%     cumsum(c) = length(idx)/nData;
%     
% end
% 
% figure(2);
% plot( x, cumsum, 'LineWidth', 2 , 'MarkerEdgeColor','r');
% 
% grid on;
% 
% axis([0 0.3 0 1]);
% 
% eval_name = ['W300_LFPW_sdm' '.mat'];
% 
% EVAL.rms = err;
% 
% save(['result/' eval_name],'EVAL');
% 
% %% displaying rms errors
% disp(['ERR average: ' num2str(mean(err))]);
end
 %% compute the distance
 function M=compute_mouse(aligned_shape)
      d1=sqrt((aligned_shape(48,1)-aligned_shape(58,1)).^2+(aligned_shape(48,2)-aligned_shape(58,2)).^2);
      d2=sqrt((aligned_shape(50,1)-aligned_shape(56,1)).^2+(aligned_shape(50,2)-aligned_shape(56,2)).^2);
      d3=sqrt((aligned_shape(52,1)-aligned_shape(54,1)).^2+(aligned_shape(52,2)-aligned_shape(54,2)).^2);
      d4=sqrt((aligned_shape(49,1)-aligned_shape(57,1)).^2+(aligned_shape(49,2)-aligned_shape(57,2)).^2);
      d5=sqrt((aligned_shape(51,1)-aligned_shape(55,1)).^2+(aligned_shape(51,2)-aligned_shape(55,2)).^2);
      M=d1+d2+d3+d4+d5;
    end
function E=compute_eye(aligned_shape)
      d1=sqrt((aligned_shape(29,1)-aligned_shape(31,1)).^2+(aligned_shape(29,2)-aligned_shape(31,2)).^2);
      d2=sqrt((aligned_shape(33,1)-aligned_shape(35,1)).^2+(aligned_shape(33,2)-aligned_shape(35,2)).^2);
      E=d1+d2;
end
 function L=compute_leye(aligned_shape)
      d1=sqrt((aligned_shape(29,1)-aligned_shape(31,1)).^2+(aligned_shape(29,2)-aligned_shape(31,2)).^2);
      d2=sqrt((aligned_shape(67,1)-aligned_shape(68,1)).^2+(aligned_shape(67,2)-aligned_shape(68,2)).^2);
      d3=sqrt((aligned_shape(69,1)-aligned_shape(70,1)).^2+(aligned_shape(69,2)-aligned_shape(70,2)).^2);
      L=d1+d2+d3;
 end
 function R=compute_reye(aligned_shape)
      d1=sqrt((aligned_shape(33,1)-aligned_shape(35,1)).^2+(aligned_shape(33,2)-aligned_shape(35,2)).^2);
      d2=sqrt((aligned_shape(71,1)-aligned_shape(72,1)).^2+(aligned_shape(71,2)-aligned_shape(72,2)).^2);
      d3=sqrt((aligned_shape(73,1)-aligned_shape(74,1)).^2+(aligned_shape(73,2)-aligned_shape(74,2)).^2);
      R=d1+d2+d3;
 end
%  function B=compute_RL(aligned_shape)
%       d1=sqrt((aligned_shape(3,1)-aligned_shape(40,1)).^2+(aligned_shape(3,2)-aligned_shape(40,2)).^2);
%       d2=sqrt((aligned_shape(13,1)-aligned_shape(40,1)).^2+(aligned_shape(13,2)-aligned_shape(40,2)).^2);
%       B=d1-d2;
%  end