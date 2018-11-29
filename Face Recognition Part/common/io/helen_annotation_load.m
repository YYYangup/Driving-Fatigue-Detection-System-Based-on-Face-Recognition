function [pts] = helen_annotation_load( shape_path )

%fpath = ['/home/tranngoctrung/Workspace/These/3dpose/data/input/HELEN/points/' '232194_1.txt'];

% pts = [];
% 
% if exist(fpath,'file') ~= 0
% 
% fp = fopen(fpath,'r');
% 
% npts = 194; %predefined
% pts  = zeros(npts,2);
% 
% count = 0;
% 
% while ~feof(fp)
%     
%     count = count + 1;
%     
%     line = fgetl(fp);
%     
%     if count > 1
%         disp(count);
%         terms = strsplit(line,',');
%         pts(count-1,1) = str2num(terms{1});
%         pts(count-1,2) = str2num(terms{2});
%     end
%     
% end
% 
% end
% 
% fclose(fp);


fid = fopen(shape_path);
n_vertices=66;
tline = fgetl(fid);
start = 1;
while ~strcmp(tline, '{')
    start = start + 1;
    tline = fgetl(fid);
end
fclose(fid);

% read shape
pts =  dlmread(shape_path, ' ', [start 0 start+n_vertices-1 1]);
end
