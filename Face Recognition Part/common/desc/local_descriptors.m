function [desc] = local_descriptors( img, xy, dsize, dbins, options )

featType = options.descType;

stage = options.current_cascade;

dsize = options.descScale(stage) * size(img,1);

if strcmp(featType,'raw')
    
    if size(img,3) == 3
        im = im2double(rgb2gray(uint8(img)));
    else
        im = im2double(uint8(img));
    end
    
    for ipts = 1 : npts
        desc(ipts,:) = raw(im,xy(ipts,:),desc_scale,desc_size);
    end
    
elseif strcmp(featType,'xx_hog')
    if size(img,3) == 3
        im = im2double(rgb2gray(uint8(img)));
    else
        im = im2double(uint8(img));
    end 
    desc=xx_hog(im,xy);
    
elseif strcmp(featType,'xx_sift')     
    if size(img,3) == 3
        im = im2double(rgb2gray(uint8(img)));
    else
        im = im2double(uint8(img));
    end
    
    
    xy = xy - repmat(dsize/2,size(xy,1),2);
    
    desc = xx_sift(im,xy,'nsb',dbins,'winsize',32);
    
elseif strcmp(featType,'mt_sift')  
     if size(img,3) == 3
        im = im2double(rgb2gray(uint8(img)));
     else
        im = im2double(uint8(img));
     end
     xy = xy - repmat(16,size(xy,1),2);
     desc = mt_sift(im,xy);
     
elseif strcmp(featType,'my_sift')  
     if size(img,3) == 3
        im = im2double(rgb2gray(uint8(img)));
     else
        im = im2double(uint8(img));
     end
     xy = xy - repmat(16,size(xy,1),2);
     desc = my_sift(im,xy);  
elseif strcmp(featType,'xx_pool')  
     if size(img,3) == 3
        im = im2double(rgb2gray(uint8(img)));
     else
        im = im2double(uint8(img));
     end
     xy = xy - repmat(16,size(xy,1),2);
     desc = xx_pool(im,xy);  
elseif strcmp(featType,'vl_sift')
    if size(img,3) == 3
        im = im2double(rgb2gray(uint8(img)));
     else
        im = im2double(uint8(img));
     end
     xy = xy - repmat(16,size(xy,1),2);
     desc = vlf_sift(single(im),xy);  
elseif strcmp(featType,'vl_lbp')
    if size(img,3) == 3
        im = im2double(rgb2gray(uint8(img)));
     else
        im = im2double(uint8(img));
     end
     xy = xy - repmat(16,size(xy,1),2);
     desc = vlf_lbp(single(im),xy);  
end


end
