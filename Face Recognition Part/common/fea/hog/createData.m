function X=createData(img)

%CREATEDATAMAT Summary of this function goes here
%   Detailed explanation goes here
    
    % Oriented HOG
    addpath( genpath('code_kota_common') );
    X = [];
    N=size(img,3);
    for i=1:N       
        resizedImage = double( img(:,:,i) );
        hogParams1 = [9 8 2 1 0.2];
        hogParams2 = [9 16 2 1 0.2];
        hogParams3 = [9 32 2 1 0.2];
        feature = [HoG(resizedImage,hogParams1) ; HoG(resizedImage,hogParams2) ; HoG(resizedImage,hogParams3)]';
        
        X = [X ; feature ];
    end
end
