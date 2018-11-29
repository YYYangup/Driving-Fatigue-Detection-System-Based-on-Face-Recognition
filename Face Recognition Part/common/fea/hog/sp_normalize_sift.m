function sift_arr = sp_normalize_sift(sift_arr, threshold)
% % notice: this is row vectors normalized
% % normalize SIFT descriptors (after Lowe)
% find indices of descriptors to be normalized (those whose norm is larger than threshold)  
tmp = sqrt( sum( sift_arr.^2, 2 ) );  
normalizeIndex = find( tmp >= threshold );  
  
SiftFeatureVectorNormed = sift_arr( normalizeIndex, : );  
SiftFeatureVectorNormed = SiftFeatureVectorNormed ./ repmat( tmp( normalizeIndex, : ), [ 1 size( sift_arr, 2 ) ] );  
  
% suppress large gradients  
SiftFeatureVectorNormed( SiftFeatureVectorNormed > 0.2 ) = 0.2;  
  
% finally, renormalize to unit length  
tmp = sqrt( sum( SiftFeatureVectorNormed.^2, 2 ) );  
SiftFeatureVectorNormed = SiftFeatureVectorNormed ./ repmat( tmp, [ 1 size( sift_arr, 2 ) ] );  
  
sift_arr( normalizeIndex, : ) = SiftFeatureVectorNormed; 



