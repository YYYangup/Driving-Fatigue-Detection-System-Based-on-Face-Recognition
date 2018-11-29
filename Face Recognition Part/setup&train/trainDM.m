function trainDM()
%% loading the setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = setup();

%% learning other requirements %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if options.learningShape == 1
    disp('Learning shape model...');
    do_learn_shape( options );
end


if options.learningVariation == 1
    disp('Learning data variation...');
    do_learn_variation( options );
end

load( ['model/' options.datasetName '_ShapeModel.mat']    );
load( ['model/' options.datasetName '_DataVariation.mat'] );

%DataVariation.mu_trans  = mu_trans;
%DataVariation.cov_trans = cov_trans;
DataVariation.mu_scale  = [0.95 0.95];
%DataVariation.cov_scale = cov_scale;

%% learn cascaded regression %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imgDir = options.trainingImageDataPath;
%ptsDir = options.trainingTruthDataPath;

%% loading data
disp('Loading training data...');
Data = load_all_data3( imgDir, options );
%Data = load_all_data2( imgDir, ptsDir, options );

n_cascades = options.n_cascades;
DM{n_cascades}.R = [];

rms = zeros(n_cascades,1);

for icascade = 1 : n_cascades
    
    options.current_cascade = icascade;
    
    %% learning single regressors
    if icascade == 1
        
        new_init_shape = [];
        [R,new_init_shape,rms(icascade)] = learn_single_regressor(ShapeModel, DataVariation, Data, new_init_shape, options );
        
        DM{icascade}.R = R;
        
        %% save other parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        DM{icascade}.n_cascades = n_cascades;
        DM{icascade}.descSize   = options.descSize;
        DM{icascade}.descBins   = options.descBins;
        
        disp(['icascade = ' num2str(icascade)  'finise']);
    else
        
        [R, new_init_shape,rms(icascade)] = learn_single_regressor(ShapeModel, DataVariation, Data, new_init_shape, options );
        
        DM{icascade}.R = R;
        disp(['icascade = ' num2str(icascade)  'finise']);
    end
    
end

save('result/Trained_RMS.mat' , 'rms');
save([options.modelPath options.slash 'DM.mat'],'DM');

clear;
