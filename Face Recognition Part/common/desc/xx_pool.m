function fea=xx_pool(im,shape)
numpoints=size(shape,1);
fea=zeros(128,numpoints);
patchsize=32;
hogParams = [8 8 4 1 0.2];

sift=[1:2:17 18:2:22 23:2:27 28:36 37:2:41 43:2:47 49:2:59];

if numpoints==66
  hog=[2:2:16 19 21 24 26 29:2:35 38:2:42 44:2:48 50:2:60 61:66];
elseif numpoints==68
  hog=[2:2:16 19 21 24 26 29:2:35 38:2:42 44:2:48 50:2:60 61:68];
else
    disp('have no defination');
end

hog_len=length(hog);

fea(:,sift)=xx_sift(im,shape(sift,:));

for i=1:hog_len
    index = hog(i);
    patch = getpatch(im,shape(index,:),patchsize);
    f=HoG(patch,hogParams)';
    if  isnan( f(1) )   
        f=zeros(num_dim,1);  
    end
    fea(:,index) = sp_normalize_sift(f,1)';
end
end
