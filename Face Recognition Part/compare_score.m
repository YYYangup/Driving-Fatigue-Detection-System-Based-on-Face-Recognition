function score=compare_score(sift_fea,current_sift_fea)
%% 输入：
%sift_fea：         参考特征（指的是初始正面人脸时提取的特征）
%current_sift_fea： 当前特征
%% 输出：
%score： 参考特征和当前特征的特征相似度得分
     point_num=size(sift_fea,1);
     score=zeros(1,point_num);
     method= 'cosine'; %'correlation';%'euclidean';     
     for i=1:point_num
      %% 欧氏距离
      if strcmp(method,'euclidean')
         score(i)=norm(sift_fea(i,:)-current_sift_fea(i,:));
      end
      %% 夹角余弦
      if strcmp(method,'cosine')
         fea=[sift_fea(i,:);current_sift_fea(i,:)];
         score(i)=1-pdist(fea, 'cosine'); 
      end
      %% 相关系数和相关距离 
      if strcmp(method,'correlation')
         fea=[sift_fea(i,:);current_sift_fea(i,:)];
         score(i) = pdist(fea,'correlation');
      end
     end

end