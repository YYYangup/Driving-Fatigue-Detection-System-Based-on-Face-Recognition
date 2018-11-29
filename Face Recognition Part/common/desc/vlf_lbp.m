function fea=vlf_lbp(im,shape)
%% input im is double type
num_points=size(shape,1);
num_dim=58;
fea=zeros(num_dim,num_points);
patchsize=32;
for i=1:num_points
    patch=getpatch(im,shape(i,:),patchsize);
    f = vl_lbp(patch,patchsize);
    f = f(:); 
    if  isnan( f(1) )   
        f=zeros(num_dim,1);  
    end
    fea(:,i) = sp_normalize_sift(f',1)';
end
