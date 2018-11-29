function rot=compyr(R)
%% 输入：
%R：旋转矩阵
%% 输出：
%rot：根据旋转矩阵计算相应的三维空间姿态（弧度）
 yaw=-asin(R(3,1));
 roll=asin(R(2,1)/cos(yaw));
 pitch=asin(R(3,2)/cos(yaw));
 rot=[roll,pitch,yaw];

