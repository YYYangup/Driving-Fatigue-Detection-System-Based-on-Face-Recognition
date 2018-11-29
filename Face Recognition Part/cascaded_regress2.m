function aligned_shape = cascaded_regress2 (LCM, img, init_shape, options)
%% 输入：
%LCM: 模型
%img：人脸区域图像
%init_shape：初始化人脸形状
%options:结构化参数
%% 输出：
% aligned_shape： 最终回归后的形状


%% parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_cascades = LCM{1}.n_cascades;   %回归级数
desc_size  = LCM{1}.descSize;     %平移大小
desc_bins  = LCM{1}.descBins;     %特征bin数
mean_shape = LCM{1}.mean_shape;   %平均人脸模型

width = (max(mean_shape(1, :)) - min(mean_shape(1, :)));
height = (max(mean_shape(2, :)) - min(mean_shape(2, :)));

factor     = options.scaleFactor;

%% iterations of cascades %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ic = 1 : n_cascades
    
    current_scale = cascade_img_scale(factor, ic, n_cascades);  %当前尺度
    
    options.current_cascade = ic;
    
    cropIm_scale = imresize(img,current_scale);
    init_shape   = init_shape * current_scale;
    
    if 0
        figure(1); imshow(cropIm_scale); hold on;
        draw_shape(init_shape(:,1), init_shape(:,2),'g');
%        draw_shape(true_shape(:,1), true_shape(:,2),'r');
        hold off;
        pause;
    end
    bbox = getbbox(init_shape);
    
    % extract local descriptors
    desc = local_descriptors(cropIm_scale, init_shape, desc_size, desc_bins, options);  %特征提取和更新
   
    % regressing
    del_shape = regress2([desc(:)' 1], LCM{ic}.R);  %形状回归
    
    
    origin_del = bsxfun(@times, vec_2_shape(del_shape'), [width height]);
    
    % estimate the new shape
    tmp_shape = init_shape - origin_del;
    %tmp_shape = init_shape - reshape(del_shape,49,2);
    tmp_shape = tmp_shape / current_scale;
    
    init_shape    = tmp_shape;
    
    aligned_shape = shape_2_vec(tmp_shape);
    
end


if 0
    figure(1); imshow(img); hold on;
    draw_shape(aligned_shape(1:2:end),...
        aligned_shape(2:2:end),'y');
    hold off;
    %pause;
end


end

