%% posit方法测试
%% 结合视频第一帧人脸形状作为三维模型
%% 使用10个点的三维模型进行姿态估计
%% 当tracking=0时，使用跟踪的方法；当trcking=1时，使用dlib特征点检测。
load('mean_shape'); 
load('rot3');
index=6;
angle=rot3(1+(index-1)*200:200*index,:);

path='E:/分类文件/video/avi/';
mov=VideoReader([path 'llm' num2str(index) '.mov']); 
n=200;


focalLength=960;
rotation=zeros(n,3);
translation=zeros(n,3);
index=[31,34,37,40,43,46,49,52,55,58]';

videoPlayer  = vision.VideoPlayer;


tracking=0;
for i=1:n
    disp(i);
    frame = read(mov,i);
  
  
    if i==1
       I=rgb2gray(frame);
       [shape,bbox] = getshape(double(I));
       center=mean(shape);
       shape=shape(index,:);
       s0=shape;
      
       mean_shape=[s0 mean_shape(:,3)];
       if tracking
           tracker=vision.PointTracker('MaxBidirectionalError',2,'MaxIterations',30);
           initialize(tracker,shape,frame);    %初始化特征点跟踪
       end
    else
        if tracking
            [shape,validty]=step(tracker,frame);
        else
            I=rgb2gray(frame);
            [shape,bbox] = getshape(double(I));
            shape=shape(index,:);
        end
    end
    frame = insertMarker(frame, shape, '+', 'Color', 'green'); 
    current_shape=shape;
    if min(bbox)>0
      [R, T] = modernPosit(current_shape,mean_shape, focalLength, center);
      %%[r,p,y]=R2rpy(R); rot=[r p y];
      rot=compyr(R);
      rot=rad2deg(rot);
      rotation(i,:)=[-rot(1) -rot(2) rot(3)]; 
      %rotation(i,:)=-rot;
      translation(i,:)=T';
    else
      rotation(i,:)=rotation(i-1,:);  
    end
    pause(0.1)
    step(videoPlayer, frame);

end
error=rotation-angle;
mean(abs(error))

%show(rotation,angle);
