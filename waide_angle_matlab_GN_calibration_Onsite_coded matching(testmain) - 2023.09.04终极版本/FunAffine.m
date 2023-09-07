function [A, t, error] = FunAffine(X, Y)
%AFFINE  采用最小二乘法来估计仿射变换参数。此函数的
%输入X是编码标志的坐标系上的五个点：O、C、D、zuo、you；其中标准模板
%中的坐标五点是：Y=[0 0;5 5;12 12;0 5;5 0]'.仿射关系为：Y=AX+t。
%X的形式是：X=[x1 y1;x2 y2;x3 y3;x4 y4;x5 y5]'。
l=ones(size(X, 1),1);
%以下是利用矩阵伪逆求解仿射变换参数
X0=[X l];
H=(inv(X0'*X0))*X0'*Y;
A=H(1:2,:)';
t=H(3,:)';
delt = Y - X0*H;
error = delt(:, 1)'*delt(:, 1) + delt(:, 2)'*delt(:, 2);