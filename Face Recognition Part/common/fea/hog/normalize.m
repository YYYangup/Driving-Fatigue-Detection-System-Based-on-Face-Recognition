function f=normalize(f)
%% 2������һ��
assert(size(f,1)==1 || size(f,2)==1);
temp=sqrt(sum(f.^2));
f=f./temp;
