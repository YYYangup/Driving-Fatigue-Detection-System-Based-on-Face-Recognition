function Y = regress( X , R )
%% if using ridge regression
%Y = X * R;
Y = [X ones(size(X,1),1)] * R;
end
