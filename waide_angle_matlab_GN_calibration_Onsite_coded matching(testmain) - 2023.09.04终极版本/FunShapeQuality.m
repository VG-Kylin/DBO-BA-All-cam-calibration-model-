%%%判断目标点形状，主要是拟合的椭圆偏离程度
function isEllipse = FunShapeQuality(imgClipBW)
isEllipse = 1;
[numRow, numColumn] = size(imgClipBW);
% shapeThr = 1/10 * max([numRow numColumn]);

imgClipPrm = bwperim(imgClipBW);
[rCrd, cCrd] = find(imgClipPrm == 1);
sizePrm = length(rCrd);
K = []; U = -1 * ones(sizePrm, 1); syms symx symy
for k = 1 : sizePrm
    K = [K; rCrd(k)^2 cCrd(k)^2 rCrd(k)*cCrd(k) rCrd(k) cCrd(k)];
end
temp = Gauss(K'*K, K'*U);
C = temp(:, end);

x0 = (2*C(2)*C(4)-C(3)*C(5))/(C(3)^2-4*C(1)*C(2));
y0 = (C(3)*C(4)-2*C(1)*C(5))/(4*C(1)*C(2)-C(3)^2);
a_radius = sqrt(2*(C(1)*x0^2+C(2)*y0^2+C(3)*x0*y0-1)/(C(1)+C(2)-sqrt((C(1)-C(2))^2+C(3)^2)));

% f = C(1)*symx^2 + C(2)*symy^2+C(3)*symx*symy+C(4)*symx+C(5)*symy+1;
% figure, imshow(imgClipBW), hold on;
% ezplot(f, [0 100 0 100]), hold on;

shapeThr = ceil(1/10 * a_radius);
x = rCrd; y = cCrd;
for i = 1 : sizePrm
    % 求直线参数
    if x(i) == x0
        a = 1; b = 0; c = -x0;
    else
        a = (y(i) - y0)/(x(i) - x0); b = -1; c = y0 - a*x0;
    end
    c1 = C(1); c2 = C(2); c3 = C(3); c4 = C(4); c5 = C(5);
    
    % 交点坐标
    itsX = [-(1/2*b/(c1*b^2+a^2*c2-c3*a*b)*(-a^2*c5-2*c1*b*c+c4*a*b+c3*a*c+(a^4*c5^2+4*a^2*c5*c1*b*c-2*a^3*c5*c4*b-2*a^3*c5*c3*c+c4^2*a^2*b^2-2*c4*a^2*b*c3*c+c3^2*a^2*c^2-4*c1*b^2*a^2-4*a^4*c2-4*a^2*c2*c1*c^2+4*a^3*c2*c4*c+4*c3*a^3*b)^(1/2))+c)/a;
        -(1/2*b/(c1*b^2+a^2*c2-c3*a*b)*(-a^2*c5-2*c1*b*c+c4*a*b+c3*a*c-(a^4*c5^2+4*a^2*c5*c1*b*c-2*a^3*c5*c4*b-2*a^3*c5*c3*c+c4^2*a^2*b^2-2*c4*a^2*b*c3*c+c3^2*a^2*c^2-4*c1*b^2*a^2-4*a^4*c2-4*a^2*c2*c1*c^2+4*a^3*c2*c4*c+4*c3*a^3*b)^(1/2))+c)/a];
    itsY = [1/2/(c1*b^2+a^2*c2-c3*a*b)*(-a^2*c5-2*c1*b*c+c4*a*b+c3*a*c+(a^4*c5^2+4*a^2*c5*c1*b*c-2*a^3*c5*c4*b-2*a^3*c5*c3*c+c4^2*a^2*b^2-2*c4*a^2*b*c3*c+c3^2*a^2*c^2-4*c1*b^2*a^2-4*a^4*c2-4*a^2*c2*c1*c^2+4*a^3*c2*c4*c+4*c3*a^3*b)^(1/2));
        1/2/(c1*b^2+a^2*c2-c3*a*b)*(-a^2*c5-2*c1*b*c+c4*a*b+c3*a*c-(a^4*c5^2+4*a^2*c5*c1*b*c-2*a^3*c5*c4*b-2*a^3*c5*c3*c+c4^2*a^2*b^2-2*c4*a^2*b*c3*c+c3^2*a^2*c^2-4*c1*b^2*a^2-4*a^4*c2-4*a^2*c2*c1*c^2+4*a^3*c2*c4*c+4*c3*a^3*b)^(1/2))];
    distance1 = sqrt((itsX(1)-x(i))^2 + (itsY(1)-y(i))^2);
    distance2 = sqrt((itsX(2)-x(i))^2 + (itsY(2)-y(i))^2);
    distance = min([distance1 distance2]);
    if distance > shapeThr
        isEllipse = 0;
        return;
    end
end

