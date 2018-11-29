function shape = face_alignment( ShapeModel, DataVariation,LearnedCascadedModel, img, shape, options )
%% setup the fixed parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
shapeDim = size(ShapeModel.MeanShape,1);
n_init_randoms_test = options.n_init_randoms_test;

MeanShape2 = vec_2_shape(ShapeModel.MeanShape);

aligned_shape = zeros(n_init_randoms_test,shapeDim);


%% detect the face region using face detectors or ground-truth %%%%%%%%%%%%
if options.usedetector==1
    bbox = step(options.faceDetector,img);
else
    bbox=[];
end

if isempty(bbox)
    %% if using ground-truth
  if options.isNoContour
     bbox = getbbox(shape(18:end,:));
  else
     bbox = getbbox(shape);
  end
  if 0
     %% scale testing 
      %bbox = increasebbox(bbox,1);
     %% translation testing
      bbox(1:2) = bbox(1:2)+[8 8];
      bbox(3:4) = bbox(3:4)*1;
  end
else
    [bmax bindex]=max(mean(bbox(:,3:4),2));
    bbox = bbox(bindex,:);
end

%% randomize n positions for initial shapes
[rbbox] = random_init_position(bbox, DataVariation, n_init_randoms_test );


%% iterations of n initial points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ir = 1 : n_init_randoms_test
    cbbox  = rbbox(ir,:);
    init_shape = resetshape(cbbox, MeanShape2);
    
    %% detect landmarks using cascaded regression
    aligned_shape(ir,:) = cascaded_regress( ShapeModel, LearnedCascadedModel, img, init_shape, options );
    
      
end

if n_init_randoms_test == 1
    shape = vec_2_shape(aligned_shape');
else
    shape = vec_2_shape(mean(aligned_shape)');
end

end
