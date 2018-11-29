function bbox=getbbox(shape)
%% get bbox from shape
x_min=min(shape(:,1));
y_min=min(shape(:,2));
x_max=max(shape(:,1));
y_max=max(shape(:,2));
bbox=[x_min y_min x_max-x_min+1 y_max-y_min+1] ;

