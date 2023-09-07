function [pImgCorrect] = FunDistortionCorrect(pImg, distortion, x0, y0)
%%%%%%%%%%%%%%%输入图像点坐标pImg数组和畸变参数
%%%%%%%%%%%%%%%distortion含有7个畸变参数，如下
% % % k1 = distortion(1);
% % % k2 = distortion(2);
% % % k3 = distortion(3);
% % % p1 = distortion(4);
% % % p2 = distortion(5);
% % % b1 = distortion(6);
% % % b2 = distortion(7);

k1 = distortion(1);
k2 = distortion(2);
k3 = distortion(3);
p1 = distortion(4);
p2 = distortion(5);
b1 = distortion(6);
b2 = distortion(7);

[m, n] = size(pImg);
pImg(:, 1) = pImg(:, 1) - x0;
pImg(:, 2) = pImg(:, 2) - y0;
pImgCorrect = [];
for i = 1 : m
    x = pImg(i, 1);
    y = pImg(i, 2);
    r = sqrt(x^2 + y^2);
    deltX = x*(k1*r^2+k2*r^4+k3*r^6)+p1*(r^2+2*x^2)+2*p2*x*y + b1*x + b2*y;
    deltY = y*(k1*r^2+k2*r^4+k3*r^6)+p2*(r^2+2*y^2)+2*p1*x*y;
    pImgCorrect = [pImgCorrect;x+deltX y+deltY];
end