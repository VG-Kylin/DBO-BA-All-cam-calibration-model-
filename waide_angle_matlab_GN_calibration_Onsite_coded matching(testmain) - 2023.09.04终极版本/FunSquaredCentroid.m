function [meanx,meany] = FunSquaredCentroid(pic)


if size(pic,3)~=1
    pic=rgb2gray(pic);
end
im = pic;
[rows,cols] = size(im);
x = ones(rows,1)*(1:cols);    % Matrix with each pixel set to its x coordinate
y = (1:rows)'*ones(1,cols);   %   "     "     "    "    "  "   "  y    "

area = sum(sum(double(im).^2));          %Sum of gray value
meanx = sum(sum(double(im).^2.*x))/area;
meany = sum(sum(double(im).^2.*y))/area;