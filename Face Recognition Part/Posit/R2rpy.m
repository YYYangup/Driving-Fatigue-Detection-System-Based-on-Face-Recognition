%funcio per retornar els angles de rotacio Roll, Pitch i Yaw a partir de la
%matriu de rotacio
function [r,p,y]=R2rpy(R)
y=atan2(R(3,2),R(3,3));
if isnan(y)
    y=0;
end
r=atan2(R(2,1),R(1,1));
if isnan(r)
    r=0;
end
cosp=R(2,1)/sin(r);
signecosp=sign(cosp);
p=atan2(-R(3,1),signecosp*sqrt(R(3,2)^2+R(3,3)^2));
if isnan(p)
    p=0;
end
% ox=y;
% oy=p;
% oz=r;
% Rx=[1 0 0;0 cos(ox) -sin(ox);0 sin(ox) cos(ox)];
% Ry=[cos(oy) 0 sin(oy);0 1 0;-sin(oy) 0 cos(oy)];
% Rz=[cos(oz) -sin(oz) 0;sin(oz) cos(oz) 0;0 0 1];
% R=Rz*Ry*Rx;

