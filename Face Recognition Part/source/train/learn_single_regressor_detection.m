function [R,storage_new_init_shape,rms] = learn_single_regressor_detection(ShapeModel, DataVariation, Data, new_init_shape, options )
%%%%%%%% properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Using randomly ground-truth of image as initial shape for others.
%% 2. Using multi-scale images.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nData = length(Data);


% if flipping data
if options.flipFlag == 1
    nData = nData * 2;
end



%% the fixed parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
shape_dim  = size(ShapeModel.MeanShape,1);
MeanShape2 = vec_2_shape(ShapeModel.MeanShape);
n_points   = shape_dim/2;
n_cascades = options.n_cascades;

current_cascade = options.current_cascade;
n_init_randoms  = options.n_init_randoms;
featType = options.descType;

desc_size       = options.descSize;
desc_bins       = options.descBins;
if strcmp(featType,'xx_hog')
     desc_dim  = 4*9;
elseif strcmp(featType,'xx_sift')
     desc_dim        = 8 * desc_bins * desc_bins; % xx_sift
else
end


%% initial matrices used for storing descriptors and delta shape %%%%%%%%%%
storage_init_shape = zeros(nData*n_init_randoms,shape_dim);
storage_gt_shape   = zeros(nData*n_init_randoms,shape_dim);
storage_new_init_shape = zeros(nData*n_init_randoms,shape_dim);
storage_init_desc  = zeros(nData*n_init_randoms,desc_dim*n_points);
storage_del_shape  = zeros(nData*n_init_randoms,shape_dim);
storage_bbox       = zeros(nData*n_init_randoms,4);

%% set the current canvas size for multi-scale feature
current_scale = cascade_img_scale(options.scaleFactor,current_cascade,n_cascades);
faceDetector = options.faceDetector;

for idata = 1 : nData
    
    %% the information of i-th image
    %disp(Data(idata).img);
    disp(['Stage: ' num2str(options.current_cascade) ' - Image: ' num2str(idata)]);
    
    if options.flipFlag == 1
        % flipping the image
        flip_iimg = floor((idata+1)/2);
        nrData = nData/2;
    else
        flip_iimg = idata;
        nrData = nData;
    end
    
    img   = Data{flip_iimg}.img_gray;
    shape = Data{flip_iimg}.shape_gt;
    
    %% fipping data
    if options.flipFlag == 1
        
        if mod(idata,2) == 0
            
            if size(img,3) > 1
                img_gray   = fliplr(rgb2gray(uint8(img)));
            else
                img_gray   = fliplr(img);
            end
            
            clear img;
            img = img_gray;
            clear img_gray;
            
            shape = flipshape(shape);
            shape(:,1) = size(img,2) - shape(:, 1);
            
            
            if 0
                figure(1); imshow(img); hold on;
                draw_shape(shape(:,1),...
                    shape(:,2),'y');
                hold off;
                pause;
            end
            
        end
        
    end
    
    %% if the first cascade
    if ( current_cascade == 1 )
        
        %% if detect face using viola opencv
        %%bbox = detect_face( img , options );
        if options.usedetector 
          bbox  = step(faceDetector, img);
          if isempty(bbox)   
               disp(['image: ' num2str(idata) 'detection fail']);
             %% if bbox=[] then using ground-truth to get bbox
               bbox = getbbox(shape);
               bbox = [bbox(1:2)-10 bbox(3:4)+20]; 
          elseif size(bbox,1)>1
               disp(['image: ' num2str(idata) 'detection face number>1']);
               bbox = getbbox(shape);
               bbox = [bbox(1:2)-10 bbox(3:4)+20];
          end  
          
        else
          %% if using ground-truth 
            bbox = getbbox(shape);
        end
        
        %% predict the face box
     
%         figure(1),imshow(img);
%         hold on;
%         rectangle('position',bbox);
%         pause;
        
        %% randomize n positions for initial shapes
        [rbbox] = random_init_position(bbox, DataVariation, n_init_randoms );
        
        %% randomize which shape is used for initial position
        rIdx = randi([1,nrData],n_init_randoms);
        
        %% iterations of n initial points
        for ir = 1 : n_init_randoms
            
            %% get random positions and inital shape indexs
            idx    = rIdx(ir);
            %%true_shape = Data{idx}.shape_gt; %% get randomly shape from others
            cbbox  = rbbox(ir,:);
            
            %init_shape = resetshape(cbbox, init_shape);
            init_shape = resetshape(cbbox, MeanShape2);
 
            if 0
                figure(1); imshow(img); hold on;
                draw_shape(init_shape(:,1), init_shape(:,2),'y');
                hold off;
                pause;
            end           
            
            %% scale coarse to fine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            cropIm_scale = imresize(img,current_scale);
            init_shape = init_shape * current_scale;
            true_shape    = shape      * current_scale;
            
            if 0
                figure(1); imshow(cropIm_scale); hold on;
                draw_shape(init_shape(:,1), init_shape(:,2),'g');
                draw_shape(true_shape(:,1), true_shape(:,2),'r');
                hold off;
                pause;
            end
            
            storage_bbox((idata-1)*n_init_randoms+ir,:) = getbbox(init_shape);
            
          %% compute the descriptors and delta_shape %%%%%%%%%%%%%%%%%%%%
            
            % storing the initial shape
            storage_init_shape((idata-1)*n_init_randoms+ir,:) =  shape_2_vec(init_shape);
            
            % storing the the descriptors
            tmp = local_descriptors( cropIm_scale, init_shape,desc_size, desc_bins, options );
            tmp_true = local_descriptors( cropIm_scale, true_shape,desc_size, desc_bins, options );
            
            storage_init_desc((idata-1)*n_init_randoms+ir,:) = tmp_true(:)-tmp(:);
            
            % storing delta shape
            tmp_del = init_shape - true_shape;
            shape_residual = bsxfun(@rdivide, tmp_del, storage_bbox((idata-1)*n_init_randoms+ir,3:4));
            
            storage_del_shape((idata-1)*n_init_randoms+ir,:) = shape_2_vec(shape_residual);
             
            %storage_del_shape((idata-1)*n_init_randoms+ir,:) =  shape_2_vec(tmp_del);
            
            storage_gt_shape((idata-1)*n_init_randoms+ir,:) = shape_2_vec(shape);
                        
        end
        
    else
        
        % for higher cascaded levels
        for ir = 1 : n_init_randoms
            
            init_shape = vec_2_shape(new_init_shape((idata-1)*n_init_randoms+ir,:)');
            
            %% scale coarse to fine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% scale coarse to fine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            cropIm_scale = imresize(img,current_scale);
            init_shape = init_shape * current_scale;
            true_shape = shape      * current_scale;
            
            %% compute the descriptors and delta_shape %%%%%%%%%%%%%%%%%%%%
            
            if 0
                figure(1); imshow(cropIm_scale); hold on;
                draw_shape(init_shape(:,1), init_shape(:,2),'g');
                draw_shape(true_shape(:,1), true_shape(:,2),'r');
                hold off;
                pause;
            end            
            
            storage_bbox((idata-1)*n_init_randoms+ir,:) = getbbox(init_shape);
            
          %% compute the descriptors and delta_shape %%%%%%%%%%%%%%%%%%%%  
            % storing the initial shape
            storage_init_shape((idata-1)*n_init_randoms+ir,:) = shape_2_vec(init_shape);
            
            % storing the the descriptors
            tmp = local_descriptors( cropIm_scale, init_shape,desc_size, desc_bins, options );
            storage_init_desc((idata-1)*n_init_randoms+ir,:) = tmp(:);
            
            % storing delta shape
            tmp_del = init_shape - true_shape;
            shape_residual = bsxfun(@rdivide, tmp_del,storage_bbox((idata-1)*n_init_randoms+ir,3:4));
            storage_del_shape((idata-1)*n_init_randoms+ir,:) =  shape_2_vec(shape_residual);
           
            %storage_del_shape((idata-1)*n_init_randoms+ir,:) =  shape_2_vec(tmp_del);
            
            storage_gt_shape((idata-1)*n_init_randoms+ir,:) =   shape_2_vec(shape);
                      
        end
        
    end
    
    
    clear img;
    clear cropIm_scale;
    clear shape;
    
end

%% solving multivariate linear regression %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('solving linear regression problem...');
R = linreg_detection( storage_init_desc, storage_del_shape, options.lambda(current_cascade) );


%% updading the new shape %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('updadting the shape...');
del_shape = regress_detection( storage_init_desc, R );

nsamples = size(storage_init_desc,1);

for isample = 1 : nsamples
    
    origin_del = bsxfun(@times, vec_2_shape(del_shape(isample,:)'), storage_bbox(isample,3:4));
    shape      = storage_init_shape(isample,:) - shape_2_vec(origin_del)';
    shape      = shape / current_scale;
    storage_new_init_shape(isample,:) = shape;
    
end

%% compute errors

err = zeros(nsamples,1);

for i = 1:nsamples
    
    pr_shape = storage_new_init_shape(i,:);
    gt_shape = storage_gt_shape(i,:);
    
    err(i) = rms_err( vec_2_shape(pr_shape'), vec_2_shape(gt_shape'), options);
    
end

rms = 100*mean(err);

disp(['ERR average: ' num2str(100*mean(err))]);

clear storage_init_shape;
clear storage_gt_shape;
clear storage_init_desc;
clear storage_del_shape;
clear storage_transM;

