function patch=getpatch(im,point,patchsize)
if size(im,3)==3
    im=rgb2gray(im);
end

[h w] = size(im);
 x_min=point(1);
 y_min=point(2);
 x_max=point(1)+patchsize-1;
 y_max=point(2)+patchsize-1;
 if (x_min<1) || (y_min<1) 
     rect=[1 1 patchsize-1 patchsize-1];
 elseif (x_max>w) || (y_max>h)
     rect=[w-patchsize h-patchsize patchsize-1 patchsize-1];
 else
     rect=[x_min y_min patchsize-1 patchsize-1];
 end
     patch=imcrop(im,rect);
end