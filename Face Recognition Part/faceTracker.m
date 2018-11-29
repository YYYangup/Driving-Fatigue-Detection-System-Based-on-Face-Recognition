function [angle,status,fps]=faceTracker(params)

%% 输入：
%params结构化参数
%% 输出：
%angle：帧数*3（roll，pitch，yaw）的头部姿态角度
%status：帧数*1（0，1）报警提示状态
%fps：帧速（显示程序效率）
number_alarm=params.number_alarm;   %报警阈值数，大于该数值时，开始报警；小于该数值时，不报警
inter=params.interval;              %间隔帧数
delt=params.delt;                   %离标准中心相对位置的阈值（这里采用初始化人脸图像的鼻尖点作为标准中心位置）
filepath=params.filepath;           %固定给定视频的文件名
visualization=params.visualization; %是否可视化报警曲线，1为可视化，0为不可视化
num_frames = params.NumberOfFrames; %固定视频的帧数
image_scale=params.image_scale;     %图像尺度参数设置，为了提高效率，可以适当缩小原人脸区域图像的大小
isvid=params.isvid;                 %是否为实时视频，1表示实时视频，0表示固定给定视频

options=params.options;             %全局参数
DM=params.DM;                       %检测模型
TM=params.TM;                       %跟踪模型
ShapeModel=params.ShapeModel;       %人脸形状模型
DataVariation=params.DataVariation; %人脸区域扰动参数

addpath('Posit');                   %添加默认相对路径Posit（头部姿态估计）

mean_shape = [];                    %平均人脸形状 
load('mean_shape');                 %加载平均人脸形状

addpath('fea/sift');                %添加sift特征默认路径
addpath('fea/hog');                 %添加hog特征默认路径 

status=zeros(num_frames,1);         %记录报警状态


%sp=actxserver('SAPI.SpVoice');
text_alarm='Fatigue Driving';       %设置报警提示
text_normal='Normal Driving';       %设置正常驾驶提示
%% 是否为实时视频
if isvid  %%实时视频
   vid=params.vid; 
   frame_w=640; frame_h=480;
else      %%固定给定视频
   videofile = VideoReader(filepath);
   frame_w = videofile.Width;
   frame_h = videofile.Height;
end

% parameters
thd=15;                     %跟踪失败的特征点数的阈值
thd_rot=20;                 %是否角度超过的阈值
focalLength=1000;           %焦距大小
center=[320 240];           %图像中心
time = 0;                   %计算总时间
checking=1;                 %是否进行疲劳预警检测
addnum=0;                   %初始化成功时，addnum++
istracking=0;               %是否进行跟踪阶段
ischeck=1;                  %是否进行连续帧检查，1表示是，0表示否
flag=0;                     %是否进行语音报警提示，flag=1时进行语音提示，flag=1时不进行任何提示
drawed=false;               %是否开始绘图
number=0;                   %统计连续超过疲劳驾驶预警的次数
angle=zeros(num_frames,3);  %头部姿态角度（帧数*3）

index=[14 17 20 23 26 29 32 35 38 41]+17;   %计算头部姿态时选取的10个人脸关键点的位置索引

shape=[];         % 人脸形状
%% 描绘三维头部姿态坐标轴
linel  = 60;      % head nosetip axis line length  表示相应x，y，z三维坐标轴*60
loc    = [70 70]; % where to draw head nosetip     表示三维坐标轴的中心相对描绘位置
% create a figure to draw upon
figure('units','pixels',...
       'position',[400 400 frame_w frame_h+50],...  %figure绘图的位置和大小设置
       'menubar','none',...
       'name','fatigue driving detection',...              
       'numbertitle','off',...
       'resize','on',...
       'renderer','painters');
axes('units','pixels',...  
      'position',[1 51 frame_w frame_h],...     
      'drawmode','fast');
im_h = imshow(zeros(frame_h,frame_w,3,'uint8'));     %显示人脸图像并返回人脸图像的句柄
frame_h = text(10,10,'1');                           %在figure图中（10,10）位置处显示第一帧文本并返回帧次（第几帧）文本的句柄
set(frame_h,'color','b','fontsize',10);              %帧次文本句柄的颜色和字体设置
track_Text = text(140,400,'Normal Tracking');        %在figure图中（140,400）位置处显示初始化时，正常状态驾驶的文本提示并返回相应的文本句柄
set(track_Text,'fontsize',18,'color','g');           %正常驾驶状态文本句柄的颜色和字体设置
hold on;                                             %继续绘图
%% 帧循环
for frame = 1:num_frames
    tic;                                             %记录时间
    if isvid %实时视频时，从摄像头捕获视频帧
       im = getsnapshot(vid);
    else     %固定给定视频时，从文件中读取视频帧
       im = read(videofile,frame);
    end
    [shape,bbox] = falign( ShapeModel, DataVariation, DM ,TM, shape, im, options );  %人脸对齐（人脸关键点定位）
  if ~istracking 
%% 判断初始化是否为正脸
%       if ~isempty(nosetip)
%           rr=nosetip.angle;
%           if rr(3)>0
%               rr(3)=180-rr(3);
%           else
%               rr(3)=-(180+rr(3));
%           end
%           rr=[-rr(1) rr(3) -rr(2)];
%           isfrontal=(abs(rr(1))<10 && abs(rr(2))<5 && abs(rr(3))<10);
%       end
      if ~isempty(shape) %%&& (addnum>0 || isfrontal)
         fc=frame;       %记录初始化帧（记录第几帧初始化）
         istracking=1;
         flag=0;
         addnum=addnum+1;
         disp('Initialization');
      else
         disp(['frame ' num2str(frame) '  No-initialized']);  
      end
      if flag==1
        % sp.Speak('attentionplease')
      end
  end

  if  istracking
     %% 图像光照处理
%     if params.light
%        imm=imresize(im,image_scale);
%        imm=lshImage(imm);
%        im=imresize(imm,1/image_scale);   
%     end
    %初始化跟踪点位置  
   if frame==fc
       nosetip=double(shape(31,:));           %nose tip 鼻尖点
       baseline=nosetip(2);                   %baseline 初始鼻尖点的相对垂直位置（Y轴）
       [leye,reye] = comp_eye_ratio(shape);   %计算双眼水平和垂直比例
       %%center=mean(shape);
       current_shape=shape(index,:);          %给定的三维人脸模型对应的10个人脸关键点
       
       [R, T] = modernPosit(current_shape,mean_shape, focalLength, center);   %Posit头部姿态估计
       rot=R2rot(R);                                                          %角度矩阵R角度转化对应的三维姿态（roll，pitch，yaw）
       angle(frame,:)=rot;                                                    %统计当前帧的头部姿态角度
       if addnum==1
          %mean_shape=[current_shape mean_shape(:,3)];
       end
      %% 自适应选取跟踪点
%        if strcmp(options.descType ,'xx_sift')
%            sift_fea = local_descriptors(im, shape ,20, 4, options);
%            sift_fea = reshape(sift_fea,size(shape,1),[]);
%        end
%        if strcmp(options.descType ,'xx_hog')
%            hog_fea = hog_feature(im, shape);
%            hog_fea = reshape(hog_fea,size(shape,1),[]);
%        end
      
       set(im_h,'cdata',im); % update frame 更新人脸图像句柄
       set(frame_h,'string',num2str(frame)); %更新帧次文本句柄 
   end
   if frame>fc  %跟踪阶段
      if isempty(shape) %跟踪丢失
          istracking=0;   %istracking设置为0，则重新初始化检测阶段
          set(track_Text,'string','Loss Tracking','color','r');  %设置跟踪丢失文本提示
          disp('Loss Tracking');  
      else
      nosetip=shape(31,:);  %nose tip 鼻尖点位置
      [leye,reye] = comp_eye_ratio(shape);   %计算双眼水平和垂直比例
     %% 自适应选取跟踪点（通过特征相似度进行阈值比较）
%       if strcmp(options.descType,'xx_sift')
%         current_sift_fea = local_descriptors(im,shape,20, 4, options);
%         current_sift_fea = reshape(current_sift_fea ,size(shape,1),[]);
%         score=compare_score(sift_fea,current_sift_fea);
%       end
%       if strcmp(options.descType,'xx_hog')
%         current_hog_fea = hog_feature(im,shape);
%         current_hog_fea = reshape(current_hog_fea ,size(shape,1),[]);
%         score=compare_score(hog_fea,current_hog_fea);
%       end
%       num=nscore(score);
      current_shape=shape(index,:);                                        %给定的三维人脸模型对应的10个人脸关键点
      [R, T] = modernPosit(current_shape,mean_shape, focalLength, center); %Posit头部姿态估计
      rot=R2rot(R);                                                        %角度矩阵R角度转化对应的三维姿态（roll，pitch，yaw）
      angle(frame,:)=rot;                                                  %统计当前帧的头部姿态角度
      %% 跟踪点失败过多时就重新初始化并检测
%       if num<thd
%          istracking=0;
%          shape=[];
%          set(track_Text,'string','Loss Tracking','color','r');
%          disp('Loss Tracking');  
%       end
      set(im_h,'cdata',im); % update frame 更新人脸图像句柄
      set(frame_h,'string',num2str(frame)); %更新帧次文本句柄 
      end
   end
    
    y=nosetip(2);      %y 当前帧鼻尖点的相对垂直位置（Y轴）
    % visual line
    if frame>fc        
        if (frame-fc)<inter     %当当前连续帧数不超过给定连续帧阈值inter时，默认预报警数值为0
           number=0;
        end
    if checking
       %当提取出的若干帧中跟踪点的位置大于某个范围的百分比超过一定数目时，认为是报警点，设置相应的状态值为1，否则默认为0
      %% 通过头部姿态角度pitch判断疲劳驾驶状态
       if y>baseline+delt    %%人脸平行向下移动时，认为不是报警状态  
         if rot(2)>thd_rot    %当前帧头部姿态角度pitch大于设定阈值thd_rot时，预报警数值number=number+2   
             number=number+2;
         else
             number=0;
         end
         if number>=number_alarm %当预报警数值number大于设定的报警数值阈值时，认为是疲劳驾驶状态，则当前帧状态设为1
           status(frame)=1;
         end
       end
      %% 通过闭眼判断疲劳驾驶状态  
       if leye<0.20       %通过其中左眼相对比例关系进行判断，leye小于设定阈值时，预报警数值numb=numb+2 
          numb = numb+2;
          if numb>=number_alarm %当预报警数值numb大于设定的报警数值阈值时，认为是疲劳驾驶状态，则当前帧状态设为1
           status(frame)=1;
          end
       else
          numb=0;
       end
    end
     %分析报警状态
     if status(frame)==1
     end
     %分析连续帧变化情况
     if ischeck && frame>fc+200 && frame<fc+230
     end
    %%  可视化报警曲线 (非常影响程序速度)
     if visualization==1
       %位置曲线界面
       x=1:frame;
       y=y(x);
       ys=y(logical(status));
       xs=x(logical(status));
      
       hold on; 
       set(gca,'nosePosition',[0.21 0.21 0.78 0.78]);
       %可视化报警
       h=uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'FontSize', 12,...
               'nosePosition', [0 0 0.2 0.2], 'string', '');
       set(h,'visible','on');
     
       if status(frame)==1 
          set(h,'BackgroundColor','red');
          set(h,'String','Fatigue Driving');
          flag=1;
       else
          set(h,'BackgroundColor','green'); 
          set(h,'String','Normal Driving');
          flag=0;
       end
     
       %位置曲线显示，报警点用红色圆圈表示，正常时用绿色线条表示
       plot(x,y,'g');
       plot(xs,ys,'ro');
       xlabel('Frame');
       ylabel('nosetipition');
     end
    end
  te = toc;         %结束时间
  %% 人脸关键点检测和跟踪以及头部姿态估计的绘图显示
  if isempty(shape) % if lost/no face, delete all drawings
    if drawed
      delete(pts_h); delete(time_h); delete(angle_Pitch);
      delete(left_eye_ratio);  delete(right_eye_ratio);
      delete(h1); delete(h2); delete(h3);
      drawed = false;
    end
  else % else update all drawing
        % update head nosetip
        if drawed
        p2D  = project(R,linel); 
        set(h1,'xdata',[p2D(1,1) p2D(2,1)]+loc(1),'ydata',[p2D(1,2) p2D(2,2)]+loc(2));
        set(h2,'xdata',[p2D(1,1) p2D(3,1)]+loc(1),'ydata',[p2D(1,2) p2D(3,2)]+loc(2));
        set(h3,'xdata',[p2D(1,1) p2D(4,1)]+loc(1),'ydata',[p2D(1,2) p2D(4,2)]+loc(2));
        % update tracked points
        set(pts_h, 'xdata', shape(18:end,1), 'ydata',shape(18:end,2));
        %set(pts_h, 'xdata', shape(:,1), 'ydata',shape(:,2));
        % update frame/second
        set(time_h, 'string', sprintf('%d FPS',uint8(1/te)));
        %set(angle_Roll,'string',num2str(rot(1)));
        set(angle_Pitch,'string',num2str(rot(2)));
        %set(angle_Yaw,'string',num2str(rot(3)));
        %updata eye distance ratio
        set(left_eye_ratio,'string',num2str(leye));
        set(right_eye_ratio,'string',num2str(reye));
        %update alarm text
        if status(frame)==1
           set(alarm_Text,'string',text_alarm,'Color','r');
           flag=1;
        else
           set(alarm_Text,'string',text_normal,'Color','g');
           flag=0;
        end
        else
        p2D  = project(R,linel);
        % create head nosetip drawing
        h1=line([p2D(1,1) p2D(2,1)]+loc(1),[p2D(1,2) p2D(2,2)]+loc(2));
        set(h1,'Color','r','LineWidth',2);
        
        h2=line([p2D(1,1) p2D(3,1)]+loc(1),[p2D(1,2) p2D(3,2)]+loc(2));
        set(h2,'Color','g','LineWidth',2);
        
        h3=line([p2D(1,1) p2D(4,1)]+loc(1),[p2D(1,2) p2D(4,2)]+loc(2));
        set(h3,'Color','b','LineWidth',2);
        
        % create tracked points drawing
        pts_h   = plot(shape(18:end,1),shape(18:end,2), 'g.');
        %pts_h   = plot(shape(:,1),shape(:,2), 'g.'); 
        % create frame/second drawing
        time_h  = text(frame_w-100,50,sprintf('%d FPS',uint8(1/te)),'fontsize',20,'color','m');
        % create angle 
        %angle_Roll = text(10,30,['Roll:' num2str(rot(1))]);
        angle_Pitch = text(10,50,['Pitch:' num2str(rot(2))]);
        set(angle_Pitch,'color','r','Fontsize',15);
        %angle_Yaw = text(10,70,['Yaw:' num2str(rot(3))]);
        % create eye distance ratio
        left_eye_ratio = text(10,90,['LER:' num2str(leye)]);
        set(left_eye_ratio,'color','r','Fontsize',15);
        
        right_eye_ratio = text(10,110,['RER:' num2str(reye)]);
        set(right_eye_ratio,'color','r','Fontsize',15);
        % create alarm text
        alarm_Text = text(140,10,text_normal);
        set(alarm_Text,'FontSize',18);
        drawed = true;
        end
  end
%     if flag==1
%         sp.Speak('attentionplease'); %报警语音提示
%     end
  end
  drawnow;
  time = time + toc;        %总时间
  if isvid
     flushdata(vid,'all');  %释放缓存vid
  end
end

fps = num_frames/time;      %帧速
if isvid
   flushdata(vid,'all'); delete(vid); clear vid ;
end

  function [leye,reye] = comp_eye_ratio(shape)    %计算
           LD=sqrt((shape(37,1)-shape(40,1)).^2+(shape(37,2)-shape(40,2)).^2);
           RD=sqrt((shape(43,1)-shape(46,1)).^2+(shape(43,2)-shape(46,2)).^2);
           d1=sqrt((shape(38,1)-shape(42,1)).^2+(shape(38,2)-shape(42,2)).^2);
           d2=sqrt((shape(39,1)-shape(41,1)).^2+(shape(39,2)-shape(41,2)).^2);
           d3=sqrt((shape(44,1)-shape(48,1)).^2+(shape(44,2)-shape(48,2)).^2);
           d4=sqrt((shape(45,1)-shape(47,1)).^2+(shape(45,2)-shape(47,2)).^2);
           leye=mean([d1,d2])/LD;
           reye=mean([d3,d4])/RD;
  end
  function p2D = project(R,l)
      po = [0,0,0; l,0,0; 0,l,0; 0,0,l];
      p2D = po*R(1:2,:)';
  end
  function rot=R2rot(R)
      r=compyr(R);
      r=rad2deg(r);
      rot=[-r(1) -r(2) r(3)]; 
  end
  close all;
end

