function fea=xx_hog(im,shape)
%% input im is double type
num_points=size(shape,1);
num_dim=128;
fea=zeros(num_dim,num_points);
patchsize=32;
hogParams = [8 8 4 1 0.2];
for i=1:num_points
    patch=getpatch(im,shape(i,:),patchsize);
    f=HoG(patch,hogParams)';
    if  isnan( f(1) )   
        f=zeros(num_dim,1);  
    end
    fea(:,i) = sp_normalize_sift(f,1)';
end

function patch=getpatch(im,point,patchsize)
if size(im,3)==3
    im=rgb2gray(im);
end
[h w] = size(im);
 x_min=point(1)-round(patchsize/2);
 y_min=point(2)-round(patchsize/2);
 x_max=point(1)+round(patchsize/2);
 y_max=point(2)+round(patchsize/2);
 if (x_min<1) || (y_min<1) 
     rect=[1 1 patchsize-1 patchsize-1];
 elseif (x_max>w) || (y_max>h)
     rect=[w-patchsize+1 h-patchsize+1 patchsize patchsize];
 else
     rect=[x_min y_min patchsize-1 patchsize-1];
 end
     patch=imcrop(im,rect);
     patch=double(patch);
end

end

