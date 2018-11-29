function shape_flipped = flipshape(shape)

%FLIPSHAPE Summary of this function goes here
%   Function: flip input shape horizonically
%   Detailed explanation goes here

if size(shape, 1) == 68

    shape_flipped = shape;
    % flip check
    shape_flipped(1:17, :) = shape(17:-1:1, :);
    % flip eyebows
    shape_flipped(18:27, :) = shape(27:-1:18, :);
    % flip eyes
    shape_flipped(32:36, :) = shape(36:-1:32, :);
    % flip eyes
    shape_flipped(37:40, :) = shape(46:-1:43, :);
    
    shape_flipped(41:42, :) = shape(48:-1:47, :);
    
    shape_flipped(43:46, :) = shape(40:-1:37, :);
    
    shape_flipped(47:48, :) = shape(42:-1:41, :);
    
    % flip mouth
    shape_flipped(49:55, :) = shape(55:-1:49, :);
    shape_flipped(56:60, :) = shape(60:-1:56, :);   
    
    shape_flipped(61:65, :) = shape(65:-1:61, :);
    shape_flipped(66:68, :) = shape(68:-1:66, :);   
    
elseif size(shape,1) == 49
     shape_flipped = shape; 
    % flip eyebows
    shape_flipped(1:10, :) = shape(10:-1:1, :);
    shape_flipped(15:19, :) = shape(19:-1:15, :);
    % flip eyes
    shape_flipped(20:25, :) = shape(25:-1:20, :);
    % flip eyes
    shape_flipped(26:31, :) = shape(31:-1:26, :);
    
    % flip mouth
    shape_flipped(32:38, :) = shape(38:-1:32, :);
    
    shape_flipped(39:43, :) = shape(43:-1:39, :);   
    
    shape_flipped(44:46, :) = shape(46:-1:44, :);
    
    shape_flipped(47:49, :) = shape(49:-1:47, :);
    
elseif size(shape, 1) == 51
    shape_flipped = shape;
    % flip eyebows
    shape_flipped(1:10, :) = shape(10:-1:1, :);
    % flip eyes
    shape_flipped(15:19, :) = shape(19:-1:15, :);
    % flip eyes
    shape_flipped(20:23, :) = shape(29:-1:26, :);
    
    shape_flipped(24:25, :) = shape(31:-1:30, :);
    
    shape_flipped(26:29, :) = shape(23:-1:20, :);
    
    shape_flipped(30:31, :) = shape(25:-1:24, :);
    
    % flip mouth
    shape_flipped(32:38, :) = shape(38:-1:32, :);
    
    shape_flipped(39:43, :) = shape(43:-1:39, :);   
    
    shape_flipped(44:48, :) = shape(48:-1:44, :);
    
    shape_flipped(49:51, :) = shape(51:-1:49, :);   
    
elseif size(shape, 1) == 66
    shape_flipped = shape;
    % flip check
    shape_flipped(1:17, :) = shape(17:-1:1, :);
    % flip eyebows
    shape_flipped(18:27, :) = shape(27:-1:18, :);
    % flip eyes
    shape_flipped(32:36, :) = shape(36:-1:32, :);
    % flip eyes
    shape_flipped(37:40, :) = shape(46:-1:43, :);
    
    shape_flipped(41:42, :) = shape(48:-1:47, :);
    
    shape_flipped(43:46, :) = shape(40:-1:37, :);
    
    shape_flipped(47:48, :) = shape(42:-1:41, :);
    
    % flip mouth
    shape_flipped(49:55, :) = shape(55:-1:49, :);
    shape_flipped(56:60, :) = shape(60:-1:56, :);   
    
    shape_flipped(61:63, :) = shape(63:-1:61, :);
    shape_flipped(64:66, :) = shape(66:-1:64, :);
%     shape_flipped = shape;
%     % flip check
%     shape_flipped(1:15, :) = shape(15:-1:1, :);
%     % flip eyebows
%     shape_flipped(16:19, :) = shape(19:-1:16, :);
%     % flip eyes
%     shape_flipped(20:23, :) = shape(23:-1:20, :);
%     % flip eyes
%     shape_flipped(28:32, :) = shape(32:-1:28, :);
%     
%     shape_flipped(33:40, :) = shape(40:-1:33, :);
%     
%     shape_flipped(49:54, :) = shape(54:-1:49, :);
%     
%     shape_flipped(55:60, :) = shape(60:-1:55, :);
%     
%     shape_flipped(61:63, :) = shape(63:-1:61, :);
%     
%     shape_flipped(64:66, :) = shape(66:-1:64, :);
elseif size(shape, 1) == 74
    shape_flipped = shape;
    % flip check
    shape_flipped(1:15, :) = shape(15:-1:1, :);
   
    shape_flipped(16:19, :) = shape(19:-1:16, :);
    
    shape_flipped(20:21, :) = shape(21:-1:20, :);
   
    shape_flipped(22:25, :) = shape(25:-1:22, :);
    
    shape_flipped(67:68, :) = shape(70:-1:69, :);
    shape_flipped(69:70, :) = shape(68:-1:67, :);
    shape_flipped(71:72, :) = shape(74:-1:73, :);
    shape_flipped(73:74, :) = shape(74:-1:73, :);
    shape_flipped(26:27, :) = shape(27:-1:26, :);
    
    shape_flipped(28:30, :) = shape(30:-1:28, :);
    
    shape_flipped(32:34, :) = shape(34:-1:32, :);
    
    shape_flipped(36:39, :) = shape(44:-1:41, :);
    shape_flipped(41:44, :) = shape(39:-1:36, :);
    shape_flipped(45:46, :) = shape(46:-1:45, :);   
    
    shape_flipped(47:53, :) = shape(53:-1:47, :);
    shape_flipped(54:58, :) = shape(58:-1:54, :);
    shape_flipped(59:61, :) = shape(61:-1:59, :);
    shape_flipped(62:64, :) = shape(64:-1:62, :);
    
elseif size(shape, 1) == 29

	shape_flipped = shape;
	
	shape_flipped(1,  :) = shape(2,  :);
	shape_flipped(2,  :) = shape(1,  :);
	shape_flipped(3,  :) = shape(4,  :);
	shape_flipped(4,  :) = shape(3,  :);
	shape_flipped(5,  :) = shape(7,  :);
	shape_flipped(6,  :) = shape(8,  :);
	shape_flipped(7,  :) = shape(5,  :);
	shape_flipped(8,  :) = shape(6,  :);
	shape_flipped(9,  :) = shape(10, :);
	shape_flipped(10, :) = shape(9,  :);
	shape_flipped(11, :) = shape(12, :);
	shape_flipped(12, :) = shape(11, :);
	shape_flipped(13, :) = shape(15, :);
	shape_flipped(14, :) = shape(16, :);
	shape_flipped(15, :) = shape(13, :);
	shape_flipped(16, :) = shape(14, :);
	shape_flipped(17, :) = shape(18, :);
	shape_flipped(18, :) = shape(17, :);
	shape_flipped(19, :) = shape(20, :);
	shape_flipped(20, :) = shape(19, :);
	shape_flipped(23, :) = shape(24, :);
	shape_flipped(24, :) = shape(23, :);

else
    disp('The Flip Funtion is Error!')
end

end

