function  [img, region, bbox_facedet, cbox, sr, sc]= normalize_img(img, canvasSize, shape)

%% 输入：
%img：人脸图像
%canvasSize：人脸区域图像归一化后的统一大小
%shape：初始人脸形状
%% 输出：
%img：归一化处理后的人脸区域图像
%region：人脸区域以中心位置扩大两倍后的人脸区域
%bbox_facedet:归一化处理后的人脸区域
%cbox:原人脸图像img人脸检测得到人脸区域
%sr: 归一化尺度因子（水平）
%sc: 归一化尺度因子（垂直）

%% parameters
% width_orig: the width of the original image.
% height_orig: the height of the original image.
% img_gray: the crop image.
% height: the height of crop image.
% wdith: the width of crop image.
% shape_gt: ground-truth landmark.
% bbox_gt: bounding box of ground-truth.
% bbox_facedet: face detection region
    width_orig  = size(img,2);   %原人脸图像宽度
    height_orig = size(img,1);   %原人脸图像高度
    if exist('shape') %跟踪时，shape参数存在
       bbox = getbbox(shape);  %根据人脸形状得到人脸区域
    else              %检测时，shape参数不存在
    %人脸检测参数设置，根据人脸检测算法得到人脸区域
       detector = vision.CascadeObjectDetector();
       detector.MinSize = [100 100];
       detector.ScaleFactor = 1.2;
       detector.MergeThreshold = 2; 
       bbox = step(detector,img);
    end
    if ~isempty(bbox)
    %% enlarge region of face
    [bmax bindex]=max(mean(bbox(:,3:4),2));  %默认选择检测到的最大人脸区域
    bbox = bbox(bindex,:);
    cbox = bbox;
    region     = enlargingbbox(bbox, 2.0);   %人脸区域以中心位置扩大两倍
    region(2)  = double(max(region(2), 1));  %当扩大后左上角Y位置越界时，默认设定为1
    region(1)  = double(max(region(1), 1));  %当扩大后左上角X位置越界时，默认设定为1

    if exist('shape')
       bbox = getbbox(shape(18:end,:));      %去掉人脸轮廓
    end
    bbox(1:2) = bbox(1:2) -region(1:2);
    if 0
       figure(1),imshow(img);
       hold on;
       rectangle('position',bbox,'EdgeColor','g');
       rectangle('position',region,'EdgeColor','r');
       pause;
       close ;
    end
    %扩大后的右下角位置
    bottom_y   = double(min(region(2) + region(4) - 1, height_orig));
    right_x    = double(min(region(1) + region(3) - 1, width_orig));
    %扩大后的人脸区域图像
    img_region = img(region(2):bottom_y, region(1):right_x, :);
    
    img_gray = img_region;

    
     width    = size(img_region, 2);
     height   = size(img_region, 1);
    
  
   %% normalized the image to the mean-shape
    sr = canvasSize(1)/width;                                %尺度归一化因子（水平）
    sc = canvasSize(2)/height;                               %尺度归一化因子（垂直）
    
    img = imresize(img_gray,canvasSize);                     %人脸区域统一归一化大小为canvasSize
    
    bbox_facedet(1:2) = bsxfun(@times, bbox(1:2), [sr sc]);  %相应的人脸区域位置做调整
    bbox_facedet(3:4) = bsxfun(@times, bbox(3:4), [sr sc]);  %相应的人脸区域大小做调整

    if 0
       figure(2),imshow(img);
       set(gcf,'position',[1100 500  250 250]);
       hold on;
       gray_region = [1 1 region(3:4)];
       rectangle('position',bbox_facedet,'EdgeColor','g');
       rectangle('position',gray_region,'EdgeColor','r');
       pause;
       close ;
    end
    
    else
       region= [];
       bbox_facedet =[];
       cbox = [];
       sr = 1;
       sc = 1;
    end
  
   
  
end




function region = enlargingbbox(bbox, scale)

region(1) = floor(bbox(1) - (scale - 1)/2*bbox(3));
region(2) = floor(bbox(2) - (scale - 1)/2*bbox(4));

region(3) = floor(scale*bbox(3));
region(4) = floor(scale*bbox(4));

end

