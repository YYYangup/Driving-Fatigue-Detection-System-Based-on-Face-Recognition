function pts=readlandmark(filename)
%% specical for read landmarks for LFW database (74 landmarks)
%% we only get 66 landmarks in them
p=importdata(filename);
assert(length(p)==74*2+1);
p=reshape(p(2:end),2,74)';

% pts = zeros(66,2);
% pts(1:15,:)=p(1:15,:);
% pts(16:19,:)=p(22:25,:);
% pts(20:23,:)=p(19:-1:16,:);
% pts(24,:)=mean(p([36 44],:));
% pts(25,:)=mean(p([37 43],:));
% pts(26,:)=mean(p([38 42],:));
% pts(27,:)=p(66,:);
% pts(28:32,:)=p(38:42,:);
% pts(33:40,:)=p([28 67 29 70 30 69 31 68],:);
% pts(41:48,:)=p([34 71 33 74 32 73 35 72],:);
% pts(49:60,:)=p(47:58,:);
% pts(61:66,:)=p(64:-1:59,:);


pts=p;
pts=[pts(:,1) 250-pts(:,2)];
pts=pts';
pts=pts(:);