function Y = regress2( X , R )

%% regress2函数功能：形状回归
%% if using ridge regression
Y = X * R;

%Y = [ones(size(X,1),1) X] * R;

%Y = [X ones(size(X,1),1) ] * R;
end
