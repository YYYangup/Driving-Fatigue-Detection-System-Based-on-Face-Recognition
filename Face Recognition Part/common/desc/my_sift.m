function fea=my_sift(im,shape)
numpoints=size(shape,1);
fea=zeros(128,numpoints);
patchsize=32;
for i=1:numpoints
    patch = getpatch(im,shape(i,:),patchsize);
    fea(:,i) = round(mysift(patch)*1e7)*1e-7;
end


end
