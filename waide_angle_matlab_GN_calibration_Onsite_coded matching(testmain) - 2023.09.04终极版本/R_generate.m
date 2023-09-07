function [R]=R_generate(phiz,phix,phiy)%��ת���� ���ַ���

phizdeg= deg2rad(phiz);%ת����ֵ
phixdeg= deg2rad(phix);
phiydeg= deg2rad(phiy);
%��Z��˳ʱ����תphiz��
Rz=[ cos(phizdeg), sin(phizdeg), 0
    -sin(phizdeg), cos(phizdeg), 0
          0     ,      0      , 1];
% ��X��˳ʱ����תphix��
Rx=[1,      0     ,      0
    0, cos(phixdeg), sin(phixdeg)
    0, -sin(phixdeg), cos(phixdeg)];
% ��Y��˳ʱ����תphiy��
Ry=[ cos(phiydeg), 0 ,-sin(phiydeg)
         0       , 1 ,     0
     sin(phiydeg), 0 , cos(phiydeg)];
R=Rz*Rx*Ry;

end

