function num=nscore(score)

%% nscore函数功能：计算一向量中得分大于阈值的个数
% [a,b]=size(ss);
% num=zeros(a,1);
% for i=1:a
%      num(i)=size(find(ss(i,:)>0.65),2);
% end
num=size(find(score>0.65),2);