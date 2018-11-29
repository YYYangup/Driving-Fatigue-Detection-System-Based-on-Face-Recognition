function fea=vlf_sift(im,shape)
%% input im is double type
num_points=size(shape,1);
num_dim=128;
fea=zeros(num_dim,num_points);
patchsize=32;
binSize = 8 ;
%magnif = 3 ;
%im = vl_imsmooth(im, sqrt((binSize/magnif)^2 - .25)) ;
for i=1:num_points
    patch=getpatch(im,shape(i,:),patchsize);
    [f, d] = vl_dsift(patch,'step',32, 'size',binSize, 'fast', 'floatdescriptors') ;
    if  isnan( d(1) )   
        d=zeros(num_dim,1);  
    end
    fea(:,i) = sp_normalize_sift(d',1)';
end
