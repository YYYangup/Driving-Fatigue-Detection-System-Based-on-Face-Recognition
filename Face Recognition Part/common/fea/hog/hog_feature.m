function feahog=hog_feature(img,shape)
bbox=getbbox(shape);
shape_dim=size(shape,1);
shape=shape-repmat(bbox(1:2),shape_dim,1);
face=imcrop(img,bbox);
if size(face,3)==3
    face=rgb2gray(face);
end


face=im2double(face);
wsize=96;
face=imresize(face,[wsize wsize]);

scale=mean(bbox(3:4))/wsize;
shape=shape*(1/scale);

feahog=xx_hog(face,shape);
end