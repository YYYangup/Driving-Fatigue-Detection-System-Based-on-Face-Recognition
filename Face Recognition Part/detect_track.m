function shape = detect_track( ShapeModel, DataVariation, DM, TM, img, shape, options )
%% 输入：
%ShapeModel：人脸形状模型
%DataVariation：人脸区域的扰动参数
%DM：检测模型
%TM：跟踪模型
%img：人脸区域图像
%shape：人脸形状
%options：结构化全局参数

%% 输出：
%shape：回归后的最终人脸形状
%% setup the fixed parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
shapeDim = size(ShapeModel.MeanShape,1);             %平均人脸形状的维数=人脸关键点数*2
n_init_randoms_test = options.n_init_randoms_test;   %测试扰动
 
MeanShape2 = vec_2_shape(ShapeModel.MeanShape);      %向量转化为人脸形状（人脸关键点数*2）

aligned_shape = zeros(n_init_randoms_test,shapeDim); %中间形状回归结果

%% detect the face region using face detectors or ground-truth %%%%%%%%%%%%
% %% if using ground-truth
if isempty(shape)  %%如果shape=[],使用检测的方法，并且使用DM
    faceDetector = vision.CascadeObjectDetector();
    bbox  = step(faceDetector, img);
    disp('shape is emtpy');
else
    bbox = getbbox(shape);    %%如果shape~=[],根据人脸形状得到人脸区域
end
%  figure(2),imshow(img);
%  hold on; 
%  if ~isempty(bbox)
%     rectangle('position',bbox(1,:));
%  end

%% get bbox by hand
%     figure(2),imshow(img);
%     hold on;
%     points=ginput(2);
%     bbox=[points(1,:) points(2,:)-points(1,:)];
%     rectangle('position',bbox);
    
%% randomize n positions for initial shapes
if ~isempty(bbox)
bbox = bbox(1,:);   
[rbbox] = random_init_position(bbox, DataVariation, n_init_randoms_test);   %根据测试时的扰动得到不同的人脸区域


%% iterations of n initial points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ir = 1 : n_init_randoms_test
    
    %% get random positions and inital shape indexs
    %idx    = rIdx(ir);
    %init_shape = Data(idx).shape; %% get randomly shape from others
    cbbox  = rbbox(ir,:);
    
    %init_shape = resetshape(cbbox, init_shape);
    init_shape = resetshape(cbbox, MeanShape2);    %形状初始化
    
    
    %% detect landmarks using cascaded regression
    if isempty(shape)
      aligned_shape(ir,:) = cascaded_regress( ShapeModel, DM, img, init_shape, options );   %shape=[]时，根据DM形状回归
    else
      aligned_shape(ir,:) = cascaded_regress( ShapeModel, TM, img, init_shape, options );   %shape=[]时，根据TM形状回归
    end
    
    
end

if n_init_randoms_test == 1
    shape = vec_2_shape(aligned_shape');
else
    shape = vec_2_shape(mean(aligned_shape)');
end
  
else
    shape=zeros(68,2);    %人脸检测失败时的异常处理
end

 
end
