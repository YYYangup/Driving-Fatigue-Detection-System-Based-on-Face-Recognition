function fea=mex_sift(im,shape)
numpoints=size(shape,1);
fea=zeros(128,numpoints);
patchsize=32;
for i=1:numpoints
    patch = getpatch(im,shape(i,:),patchsize);
    f = mexDenseSIFT(patch, 3, 32); f=f(:)';
    fea(:,i) = sp_normalize_sift(f, 1)';
end


end
