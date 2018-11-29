function  sdmvid()

%% sdmvid函数功能：每一帧采用检测的方式定位人脸关键点，可以参考faceTracker
%% detection for video
vid = videoinput('winvideo',1, 'YUY2_640x480');
set(vid,'FramesPerTrigger',Inf);
set(vid,'ReturnedColorSpace','rgb');
start(vid)

options = setupLFW66();
options.descType  = 'xx_sift';

load(['model/' options.datasetName '_ShapeModel.mat']);
load(['model/' options.datasetName '_DataVariation.mat']);
load( 'model/lfw&helen/DM_xxsift.mat');

disp('initialization');
%%  evaluating on real video
% try
% n=300;
% for i=1:n
%     tic;
%     im = getsnapshot(vid);
%     [shape,bbox] = falign2( ShapeModel, DataVariation, DM , im, options );
%     figure(1),imshow(im);
%     hold on;
%     text(10,10,num2str(i));
%     if ~isempty(bbox)
%       shape = shape(18:end,:);  
%       plot(shape(:,1),shape(:,2),'g.');
%       rectangle('position',bbox,'EdgeColor','r');     
%     end
%     te=toc;
%     flushdata(vid,'all');
% end
%     flushdata(vid,'all'); delete(vid); clear vid;
% catch
%     disp('catch an error');flushdata(vid,'all'); delete(vid); clear vid;
% end


frame_w = 640;
frame_h = 480;

drawed = false; % nor draw anything yet
% create a figure to draw upon
figure('units','pixels',...
       'position',[400 400 frame_w frame_h+50],...
       'menubar','none',...
       'name','INTRAFACE_TRACKER',...              
       'numbertitle','off',...
       'resize','on',...
       'renderer','painters');
axes('units','pixels',...  
      'position',[1 51 frame_w frame_h],...
      'drawmode','fast');
im_h = imshow(zeros(frame_h,frame_w,3,'uint8'));
frame_h = text(10,10,'1');
hold on;

%%  evaluating on real video
n=300;

%try
for i=1:n
    tic;
    im = getsnapshot(vid);
    [shape,bbox] = falign2( ShapeModel, DataVariation, DM , im, options );
    %shape = shape(18:end,:);

    set(im_h,'cdata',im); % update frame
    set(frame_h,'string',num2str(i));
    te = toc;
    if isempty(bbox) % if lost/no face, delete all drawings
       if drawed, 
           delete(pts_h); delete(time_h); delete(bbox_h);
           drawed = false;
       end
    else % else update all drawings
       if drawed % faster to update than to creat new drawings
        % update tracked points
        set(pts_h, 'xdata', shape(:,1), 'ydata',shape(:,2));
        % update rectangle face box
        set(bbox_h,'position',bbox);
        % update frame/second
        set(time_h, 'string', sprintf('%d FPS',uint8(1/te)));
       else  
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
    %%pause;
  
    flushdata(vid,'all');
end
    flushdata(vid,'all'); delete(vid); clear vid;
%catch
%    disp('catch an error');flushdata(vid,'all'); delete(vid); clear vid;
%end

close all;

  
end



