function [shape,bbox] = falign( ShapeModel, DataVariation, DM, TM, shape, img, options )

%% 输入：
%ShapeModel：人脸形状模型
%DataVariation：人脸区域的扰动参数
%DM：检测模型
%TM：跟踪模型
%shape：人脸初始形状
%img：人脸图像
%options：结构体参数
%% 输出：
%shape：回归后的人脸形状
%bbox：人脸框
%% falign函数功能：人脸对齐（人脸关键点定位，即检测和跟踪）
%% if shape = [] ,using detection method 
%% if shape ~= [] ,using tracking method
if isempty(shape)
   [shape,bbox] = falign2( ShapeModel, DataVariation, DM, img, options);  % 当shape=[]时，采用检测模型进行人脸形状回归
else    % 当shape~=[]时，采用跟踪模型进行人脸形状回归
%% setup the fixed parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pre_box = getbbox(shape);                                              %根据人脸形状得到人脸区域
    shapeDim = size(ShapeModel.MeanShape,1);                               %平均人脸形状维数=人脸关键点数*2
    n_init_randoms_test = options.n_init_randoms_test;                     %测试（预测）扰动数
    MeanShape2 = vec_2_shape(ShapeModel.MeanShape);                        %向量转化为人脸形状
    canvasSize = options.canvasSize;                                       %人脸区域图像归一化后的统一大小
    aligned_shape = zeros(n_init_randoms_test,shapeDim);                   %中间预测的人脸形状
    
    [im, region, bbox_facedet,bbox,sr,sc]= normalize_img(img,canvasSize,shape);          %人脸图像的归一化处理
    [rbbox] = random_init_position(bbox_facedet, DataVariation, n_init_randoms_test );   %扰动后的人脸区域
    for ir = 1 : n_init_randoms_test 
       cbbox  = rbbox(ir,:);                                                             %人脸区域
       init_shape = resetshape(cbbox, MeanShape2);   %根据初始人脸框cbbox和平均人脸形状Meanshape2初始化人脸形状
       aligned_shape(ir,:) = cascaded_regress( ShapeModel, TM, im, init_shape, options ); %形状回归
    end    
    if n_init_randoms_test == 1
        shape = vec_2_shape(aligned_shape'); 
    else
        shape = vec_2_shape(mean(aligned_shape)');
    end
    if 0
      figure(2),imshow(im);  
      hold on;
      rectangle('position',bbox_facedet,'EdgeColor','r');
      plot(shape(:,1),shape(:,2),'g.');
      pause;
      close ;
    end
    
    shape = [shape(:,1)/sr shape(:,2)/sc];                      %人脸形状根据原尺度还原
    shape = bsxfun(@plus, region(1:2), shape);                  %相对位置重新变换
    cur_box = getbbox(shape);                                   %根据人脸形状得到当前人脸区域
    pre_center=pre_box(1:2)+pre_box(3:4)/2;                     %前一帧人脸区域位置
    cur_center=cur_box(1:2)+cur_box(3:4)/2;                     %当前帧人脸区域位置
    pre_size = mean(pre_box(3:4));                              %前一帧人脸区域大小
    cur_size = mean(cur_box(3:4));                              %当前帧人脸区域大小
    %% 当以下任何一种超出时，认为跟踪丢失，并设置shape=[],bbox=[]
    if pre_size/cur_size>1.1 || pre_size/cur_size<0.9           %%尺度超出
        shape=[]; bbox=[];
    end
    if  abs(pre_center-cur_center)>20                           %%平移超出
        shape=[]; bbox=[];
    end
    if cur_box(3)/cur_box(4)>1.6 || cur_box(3)/cur_box(4)<0.6   %%人脸框大小比例超出
        shape=[]; bbox=[];
    end
end



 
end
