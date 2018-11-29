function  sdmtrack()

%% 函数sdmtrack的功能：不包含头部姿态估计的人脸关键点定位，可以参考faceTracker
%% 基本设置
options = setupLFW66();
choice=3;
if choice==1
%% 特征的选取
options.descType  = 'xx_sift';  
%% 加载模型
load(['model/' options.datasetName '_ShapeModel.mat']);
load(['model/' options.datasetName '_DataVariation.mat']);
load('model/lfw&helen/DM_xxsift.mat');     
load('model/lfw&helen/TM_xxsift5b.mat');  
elseif choice==2
%% 特征的选取
options.descType  = 'my_sift';  
%% 加载模型
load(['model/' options.datasetName '_ShapeModel.mat']);
load(['model/' options.datasetName '_DataVariation.mat']);
load('model/lfw&helen/DM_mysift.mat');     
load('model/lfw&helen/TM_mysift5b.mat');   
elseif choice==3
%% 特征的选取
options.descType  = 'xx_hog';  
%% 加载模型
load(['model/' options.datasetName '_ShapeModel.mat']);
load(['model/' options.datasetName '_DataVariation.mat']);
load('model/lfw&helen/DM_xxhog.mat');     
load('model/lfw&helen/TM_xxhog5b.mat');
else
options.descType  = 'xx_pool';  
%% 加载模型
load(['model/' options.datasetName '_ShapeModel.mat']);
load(['model/' options.datasetName '_DataVariation.mat']);
load('model/lfw&helen/DM_xxpool.mat');     
load('model/lfw&helen/TM_xxpool5b.mat');   
    
end


addpath('Posit'); 
mean_shape = [];  load('mean_shape');
disp('initialization');
%% 视频设置参数
frame_w = 640;
frame_h = 480;

drawed = false; % nor draw anything yet
linel  = 60;    % head pose axis line length
loc    = [70 70]; % where to draw head pose
po = [0,0,0; linel,0,0; 0,linel,0; 0,0,linel];

focalLength=1000;
center=[320 240];
% create a figure to draw upon
figure('units','pixels',...
       'position',[400 400 frame_w frame_h+50],...
       'menubar','none',...
       'name','fatigue driving detection',...              
       'numbertitle','off',...
       'resize','on',...
       'renderer','painters');
axes('units','pixels',...  
      'position',[1 51 frame_w frame_h],...
      'drawmode','fast');
im_h = imshow(zeros(frame_h,frame_w,3,'uint8'));
frame_h = text(10,10,'1');
hold on;
%% 主函数
%%  evaluating on real video
n=300;
index=[14 17 20 23 26 29 32 35 38 41]+17;
shape = [];
try
%% using sdm tracking
vid = videoinput('winvideo',1, 'YUY2_640x480');
set(vid,'FramesPerTrigger',Inf);
set(vid,'ReturnedColorSpace','rgb');
start(vid)    
for i=1:n
    tic;
    im = getsnapshot(vid);
    
    [shape,bbox] = falign( ShapeModel, DataVariation, DM ,TM, shape, im, options );
    if ~isempty(bbox)
      current_shape=shape(index,:);
      [R, T] = modernPosit(current_shape,mean_shape, focalLength, center);
      r=compyr(R);
      r=rad2deg(r);
      rot=[-r(1) -r(2) r(3)];  
    end
    set(im_h,'cdata',im); % update frame
    set(frame_h,'string',num2str(i));
    te = toc;
    if isempty(bbox) % if lost/no face, delete all drawings
       if drawed, 
           delete(pts_h); delete(time_h); delete(bbox_h);
           delete(h1); delete(h2); delete(h3); 
           delete(angle_Pitch);
           drawed = false;
       end
    else % else update all drawings
       if drawed % faster to update than to creat new drawings
        p2D = po*R(1:2,:)';
        set(h1,'xdata',[p2D(1,1) p2D(2,1)]+loc(1),'ydata',[p2D(1,2) p2D(2,2)]+loc(2));
        set(h2,'xdata',[p2D(1,1) p2D(3,1)]+loc(1),'ydata',[p2D(1,2) p2D(3,2)]+loc(2));
        set(h3,'xdata',[p2D(1,1) p2D(4,1)]+loc(1),'ydata',[p2D(1,2) p2D(4,2)]+loc(2));   
        % updata pitch angle
        set(angle_Pitch,'string',num2str(rot(2)));
        % update tracked points
        set(pts_h, 'xdata', shape(:,1), 'ydata',shape(:,2));
        % update rectangle face box
        set(bbox_h,'position',bbox);
        % update frame/second
        set(time_h, 'string', sprintf('%d FPS',uint8(1/te)));
       else  
        p2D = po*R(1:2,:)';   
        % create head pose drawing
        h1=line([p2D(1,1) p2D(2,1)]+loc(1),[p2D(1,2) p2D(2,2)]+loc(2));
        set(h1,'Color','r','LineWidth',2);
        
        h2=line([p2D(1,1) p2D(3,1)]+loc(1),[p2D(1,2) p2D(3,2)]+loc(2));
        set(h2,'Color','g','LineWidth',2);
        
        h3=line([p2D(1,1) p2D(4,1)]+loc(1),[p2D(1,2) p2D(4,2)]+loc(2));
        set(h3,'Color','b','LineWidth',2);   
        % create pitch angle
        angle_Pitch = text(10,50,['Pitch:' num2str(rot(2))]);
        set(angle_Pitch,'color','r','Fontsize',15);
        % create tracked points drawing
        pts_h   = plot(shape(:,1), shape(:,2), 'g.');
        % create rectangle face box 
        bbox_h = rectangle('position',bbox,'EdgeColor','r');
        % create frame/second drawing
        time_h  = text(frame_w-100,50,sprintf('%d FPS',uint8(1/te)),'fontsize',20,'color','m');
        drawed = true;
      end
    end

    drawnow;
    %pause;
  
    flushdata(vid,'all');
end
    flushdata(vid,'all'); delete(vid); clear vid;
catch
   disp('catch an error');flushdata(vid,'all'); delete(vid); clear vid;
end

close all;

  
end



