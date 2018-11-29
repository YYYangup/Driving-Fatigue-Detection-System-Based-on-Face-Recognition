function fea=mt_sift(im,shape)
numpoints=size(shape,1);
fea=zeros(128,numpoints);
nrml_threshold=1;
patchsize=32;
for i=1:numpoints
    patch=getpatch(im,shape(i,:),patchsize);
    fea(:,i)= CalculateSiftDescriptor(patch, patchsize, patchsize, nrml_threshold);
end


end


