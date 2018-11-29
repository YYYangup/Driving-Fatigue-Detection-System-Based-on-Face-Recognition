function [shape,bbox] = falign1( ShapeModel, DataVariation, DM, img, options )

%% 输入：
%ShapeModel：人脸形状模型
%DataVariation：人脸区域的扰动参数
%DM：检测模型
%shape：人脸初始形状
%img：人脸图像
%options：结构体参数
%% 输出：
%shape：回归后的人脸形状
%bbox：人脸框
%% falign1函数功能：主要用于手动设置人脸检测区域的测试过程
%% setup the fixed parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
shapeDim = size(ShapeModel.MeanShape,1);
n_init_randoms_test = options.n_init_randoms_test;
MeanShape2 = vec_2_shape(ShapeModel.MeanShape);
canvasSize = options.canvasSize;
aligned_shape = zeros(n_init_randoms_test,shapeDim);

detector = vision.CascadeObjectDetector();
detector.MinSize = [50 50];
detector.ScaleFactor = 1.2;
detector.MergeThreshold = 2;

bbox = step(detector,img);
figure(2),imshow(img);
hold on;
if ~isempty(bbox)
  for j=1:size(bbox,1)
    rectangle('position',bbox(j,:),'EdgeColor','r');
  end
end
shape=ginput(2);
plot(shape(:,1),shape(:,2),'g.');

hold off;
close ;

[im, region, bbox_facedet,bbox,sr,sc]= normalize_img(img,canvasSize,shape);

if 0
  figure(2),imshow(im);  
  hold on;
  rectangle('position',bbox_facedet,'EdgeColor','g');
  pause;
  close ;
end

    
%% randomize n positions for initial shapes
if ~isempty(region)  
[rbbox] = random_init_position(bbox_facedet, DataVariation, n_init_randoms_test );

%% iterations of n initial points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ir = 1 : n_init_randoms_test
    cbbox  = rbbox(ir,:);
    if options.trainTM==1
         cbbox = increasebbox(cbbox,1.2);
    end
    init_shape = resetshape(cbbox, MeanShape2);
    
    %% detect landmarks using cascaded regression
    aligned_shape(ir,:) = cascaded_regress( ShapeModel, DM, im, init_shape, options );
     
    
end

if n_init_randoms_test == 1
    shape = vec_2_shape(aligned_shape');
else
    shape = vec_2_shape(mean(aligned_shape)');
end

    shape = [shape(:,1)/sr shape(:,2)/sc];
    shape = bsxfun(@plus, region(1:2), shape);
    
   
else
    shape = zeros(shapeDim/2,2);
    bbox = [];
end

 
end
