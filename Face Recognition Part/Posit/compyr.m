function rot=compyr(R)
%% ���룺
%R����ת����
%% �����
%rot��������ת���������Ӧ����ά�ռ���̬�����ȣ�
 yaw=-asin(R(3,1));
 roll=asin(R(2,1)/cos(yaw));
 pitch=asin(R(3,2)/cos(yaw));
 rot=[roll,pitch,yaw];

