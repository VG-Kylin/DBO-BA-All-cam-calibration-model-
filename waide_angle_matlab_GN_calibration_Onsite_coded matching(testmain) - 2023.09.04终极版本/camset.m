function [camposition,R,T,CaxisRT]=camset(Caxis,camphideg,camT)
%绕Z轴逆时针旋转phiz角
phiy=camphideg(3);
phix=camphideg(2);
phiz=camphideg(1);%角度值 yxz顺序旋转
[R]=R_generate(phiz,phix,phiy);%生成旋转矩阵
% R = R;%左相机旋转
T = [camT(1);camT(2);camT(3)];%左相机平移量
CaxisRT=inv(R)*Caxis+[T,T,T,T];%R'与inv(R)相同，因为R是正交矩阵，且满秩 %逆向仿真场景生成
% CaxisRT=(R)*(Caxis-[T,T,T,T]);%R'与inv(R)相同，因为R是正交矩阵，且满秩 %正向结算数值代入生成仿真场景
camposition=CaxisRT(:,4);
CaxisRT=CaxisRT';
end