function score=compare_score(sift_fea,current_sift_fea)
%% ���룺
%sift_fea��         �ο�������ָ���ǳ�ʼ��������ʱ��ȡ��������
%current_sift_fea�� ��ǰ����
%% �����
%score�� �ο������͵�ǰ�������������ƶȵ÷�
     point_num=size(sift_fea,1);
     score=zeros(1,point_num);
     method= 'cosine'; %'correlation';%'euclidean';     
     for i=1:point_num
      %% ŷ�Ͼ���
      if strcmp(method,'euclidean')
         score(i)=norm(sift_fea(i,:)-current_sift_fea(i,:));
      end
      %% �н�����
      if strcmp(method,'cosine')
         fea=[sift_fea(i,:);current_sift_fea(i,:)];
         score(i)=1-pdist(fea, 'cosine'); 
      end
      %% ���ϵ������ؾ��� 
      if strcmp(method,'correlation')
         fea=[sift_fea(i,:);current_sift_fea(i,:)];
         score(i) = pdist(fea,'correlation');
      end
     end

end