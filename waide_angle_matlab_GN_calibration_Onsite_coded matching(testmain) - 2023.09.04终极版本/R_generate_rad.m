function R = R_generate_rad(phiz,phix,phiy)
phizdeg= phiz;%转弧度值
phixdeg= phix;
phiydeg= phiy;
%绕Z轴顺时针旋转phiz角
Rz=[ cos(phizdeg), sin(phizdeg), 0
    -sin(phizdeg), cos(phizdeg), 0
          0     ,      0      , 1];
% 绕X轴顺时针旋转phix角
Rx=[1,      0     ,      0
    0, cos(phixdeg), sin(phixdeg)
    0, -sin(phixdeg), cos(phixdeg)];
% 绕Y轴顺时针旋转phiy角
Ry=[ cos(phiydeg), 0 ,-sin(phiydeg)
         0       , 1 ,     0
     sin(phiydeg), 0 , cos(phiydeg)];
R=Rz*Rx*Ry;
end