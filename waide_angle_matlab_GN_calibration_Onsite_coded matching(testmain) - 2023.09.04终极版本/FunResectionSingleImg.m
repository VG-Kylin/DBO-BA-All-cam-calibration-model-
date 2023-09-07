% ��д�ɺ���
function [ExtParams, resi, loop] = FunResectionSingleImg(InnerParams, AutoBarSpace, AutoBarImg,EXinitialvalue_CF)
% ���ܣ�����ͼƬ�������ڲ������е�ռ������������꣬�����ⷽλ����
% ����ֵ
%       ExtParams(6*1):�ⷽλ������1:3 Xs Ys Zs, 4:6 phi omegga kappa
% �������
%       InnerParams(14*1):[Resolx(����), Resoly(����), PixelSizex(mm), PixelSizey(mm), x0(mm), y0(mm), f(mm), k1, k2, k3, p1, p2, b1, b2]
%       AutoBarSpace(6*3): [X Y Z]          (mm)
%       AutoBarImg(6*2):     [x, y]              (mm)   ������(x0,y0)Ϊԭ�㣬��������ϵ

% ����(mm)
f = InnerParams(1); 
% ����(mm)
x0 = InnerParams(2);
y0 = InnerParams(3);

% ����ϵ��
k1 = InnerParams(4);
k2 = InnerParams(5);
k3 = InnerParams(6);
p1 = InnerParams(7);
p2 = InnerParams(8);
b1 = InnerParams(9);
b2 = InnerParams(10);

distortion = [k1; k2; k3; p1; p2; b1; b2];
xy = FunDistortionCorrect(AutoBarImg, distortion, x0, y0);
x = xy(:, 1);
y = xy(:, 2);

% �������ֵ
Xs = EXinitialvalue_CF(1);
Ys = EXinitialvalue_CF(2);
Zs = EXinitialvalue_CF(3);


% �Զ�Ϊ��λ����ת��
phi =  EXinitialvalue_CF(4);
omega = EXinitialvalue_CF(5);
kappa = EXinitialvalue_CF(6);
% % �������ֵ
% Xs = 3000;
% Ys = 100;
% Zs = 100;
% 
% 
% % �Զ�Ϊ��λ����ת��
% phi = -90;
% omega = 0;
% kappa = 90;

phi= deg2rad(phi);%deg2rad�Ƕ�ת����
omega = deg2rad(omega);
kappa = deg2rad(kappa);

ExtParam = [Xs, Ys, Zs, phi, omega, kappa]';

% ����ѭ��
loop = 0;   %��������
loopMax = 100; %�Զ��������
UU = 20;
VV = 2;
change = 20;
L = zeros(2*length(AutoBarImg), 1);
while loop < loopMax & change > 10^-12% 1 �� 10-12

    loop = loop + 1;
    
    Xs = ExtParam(1);
    Ys = ExtParam(2);
    Zs = ExtParam(3);
    phi = ExtParam(4);
    omega = ExtParam(5);
    kappa = ExtParam(6);
 
    a1=cos(phi)*cos(kappa)-sin(phi)*sin(omega)*sin(kappa);
    a2=-cos(phi)*sin(kappa)-sin(phi)*sin(omega)*cos(kappa);
    a3=-sin(phi)*cos(omega);
    b1=cos(omega)*sin(kappa);
    b2=cos(omega)*cos(kappa);
    b3=-sin(omega);
    c1=sin(phi)*cos(kappa)+cos(phi)*sin(omega)*sin(kappa);
    c2=-sin(phi)*sin(kappa)+cos(phi)*sin(omega)*cos(kappa);
    c3=cos(phi)*cos(omega);
    
    x_c = zeros(length(AutoBarImg), 1);
    y_c = zeros(length(AutoBarImg), 1);

    C = zeros(2*length(AutoBarImg), 6);
    L = zeros(2*length(AutoBarImg), 1);
    for ii = 1 : length(AutoBarImg)
        X = AutoBarSpace(ii, 1);
        Y = AutoBarSpace(ii, 2);
        Z = AutoBarSpace(ii, 3);
        X_ = a1*(X-Xs)+b1*(Y-Ys)+c1*(Z-Zs);
        Y_ = a2*(X-Xs)+b2*(Y-Ys)+c2*(Z-Zs);
        Z_ = a3*(X-Xs)+b3*(Y-Ys)+c3*(Z-Zs);
        x_c(ii) = -f * X_ / Z_ ;
        y_c(ii) = -f * Y_ / Z_;

        c11 = -f*(-cos(kappa)*cos(phi)+sin(kappa)*sin(omega)*sin(phi))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))+f*((cos(kappa)*cos(phi)-sin(kappa)*sin(omega)*sin(phi))*(X-Xs)+sin(kappa)*cos(omega)*(Y-Ys)+(cos(kappa)*sin(phi)+sin(kappa)*sin(omega)*cos(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))^2*cos(omega)*sin(phi);
        c21 =  -f*(sin(kappa)*cos(phi)+cos(kappa)*sin(omega)*sin(phi))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))+f*((-sin(kappa)*cos(phi)-cos(kappa)*sin(omega)*sin(phi))*(X-Xs)+cos(kappa)*cos(omega)*(Y-Ys)+(-sin(kappa)*sin(phi)+cos(kappa)*sin(omega)*cos(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))^2*cos(omega)*sin(phi);
        c12 = f*sin(kappa)*cos(omega)/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))+f*((cos(kappa)*cos(phi)-sin(kappa)*sin(omega)*sin(phi))*(X-Xs)+sin(kappa)*cos(omega)*(Y-Ys)+(cos(kappa)*sin(phi)+sin(kappa)*sin(omega)*cos(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))^2*sin(omega);
        c22 = f*cos(kappa)*cos(omega)/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))+f*((-sin(kappa)*cos(phi)-cos(kappa)*sin(omega)*sin(phi))*(X-Xs)+cos(kappa)*cos(omega)*(Y-Ys)+(-sin(kappa)*sin(phi)+cos(kappa)*sin(omega)*cos(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))^2*sin(omega);
        c13 = -f*(-cos(kappa)*sin(phi)-sin(kappa)*sin(omega)*cos(phi))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))-f*((cos(kappa)*cos(phi)-sin(kappa)*sin(omega)*sin(phi))*(X-Xs)+sin(kappa)*cos(omega)*(Y-Ys)+(cos(kappa)*sin(phi)+sin(kappa)*sin(omega)*cos(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))^2*cos(omega)*cos(phi);
        c23 = -f*(sin(kappa)*sin(phi)-cos(kappa)*sin(omega)*cos(phi))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))-f*((-sin(kappa)*cos(phi)-cos(kappa)*sin(omega)*sin(phi))*(X-Xs)+cos(kappa)*cos(omega)*(Y-Ys)+(-sin(kappa)*sin(phi)+cos(kappa)*sin(omega)*cos(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))^2*cos(omega)*cos(phi);
        c14 = -f*((-cos(kappa)*sin(phi)-sin(kappa)*sin(omega)*cos(phi))*(X-Xs)+(cos(kappa)*cos(phi)-sin(kappa)*sin(omega)*sin(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))+f*((cos(kappa)*cos(phi)-sin(kappa)*sin(omega)*sin(phi))*(X-Xs)+sin(kappa)*cos(omega)*(Y-Ys)+(cos(kappa)*sin(phi)+sin(kappa)*sin(omega)*cos(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))^2*(-cos(omega)*cos(phi)*(X-Xs)-cos(omega)*sin(phi)*(Z-Zs));
        c24 = -f*((sin(kappa)*sin(phi)-cos(kappa)*sin(omega)*cos(phi))*(X-Xs)+(-sin(kappa)*cos(phi)-cos(kappa)*sin(omega)*sin(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))+f*((-sin(kappa)*cos(phi)-cos(kappa)*sin(omega)*sin(phi))*(X-Xs)+cos(kappa)*cos(omega)*(Y-Ys)+(-sin(kappa)*sin(phi)+cos(kappa)*sin(omega)*cos(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))^2*(-cos(omega)*cos(phi)*(X-Xs)-cos(omega)*sin(phi)*(Z-Zs));
        c15 = -f*(-sin(kappa)*cos(omega)*sin(phi)*(X-Xs)-sin(kappa)*sin(omega)*(Y-Ys)+sin(kappa)*cos(omega)*cos(phi)*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))+f*((cos(kappa)*cos(phi)-sin(kappa)*sin(omega)*sin(phi))*(X-Xs)+sin(kappa)*cos(omega)*(Y-Ys)+(cos(kappa)*sin(phi)+sin(kappa)*sin(omega)*cos(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))^2*(sin(omega)*sin(phi)*(X-Xs)-cos(omega)*(Y-Ys)-sin(omega)*cos(phi)*(Z-Zs));
        c25 = -f*(-cos(kappa)*cos(omega)*sin(phi)*(X-Xs)-cos(kappa)*sin(omega)*(Y-Ys)+cos(kappa)*cos(omega)*cos(phi)*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))+f*((-sin(kappa)*cos(phi)-cos(kappa)*sin(omega)*sin(phi))*(X-Xs)+cos(kappa)*cos(omega)*(Y-Ys)+(-sin(kappa)*sin(phi)+cos(kappa)*sin(omega)*cos(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs))^2*(sin(omega)*sin(phi)*(X-Xs)-cos(omega)*(Y-Ys)-sin(omega)*cos(phi)*(Z-Zs));
        c16 = -f*((-sin(kappa)*cos(phi)-cos(kappa)*sin(omega)*sin(phi))*(X-Xs)+cos(kappa)*cos(omega)*(Y-Ys)+(-sin(kappa)*sin(phi)+cos(kappa)*sin(omega)*cos(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs));
        c26 = -f*((-cos(kappa)*cos(phi)+sin(kappa)*sin(omega)*sin(phi))*(X-Xs)-sin(kappa)*cos(omega)*(Y-Ys)+(-cos(kappa)*sin(phi)-sin(kappa)*sin(omega)*cos(phi))*(Z-Zs))/(-cos(omega)*sin(phi)*(X-Xs)-sin(omega)*(Y-Ys)+cos(omega)*cos(phi)*(Z-Zs));

        C(ii*2-1, :) = [c11 c12 c13 c14 c15 c16];
        C(ii*2,    :) = [c21 c22 c23 c24 c25 c26];
        L(ii*2-1) =  x_c(ii) - x(ii);
        L(ii*2)    = y_c(ii) - y(ii);
    end

    Delta = -inv(C'* C + UU * eye(size(C', 1)))*(C'* L);%C=eye(a):����һ��a��a�ĵ�λ����C=eye(a��b):����һ��a��b�ĵ�λ����Ҳ����ʹ��C=eye([a��b])��C=eye(size(D)):����һ���;���D������һ���ĵ�λ������ͼ��ʾ��������
    ExtParamNew = ExtParam + Delta;
    
    Xs = ExtParamNew(1);
    Ys = ExtParamNew(2);
    Zs = ExtParamNew(3);
    phi = ExtParamNew(4);
    omega = ExtParamNew(5);
    kappa = ExtParamNew(6);
    
    a1=cos(phi)*cos(kappa)-sin(phi)*sin(omega)*sin(kappa);
    a2=-cos(phi)*sin(kappa)-sin(phi)*sin(omega)*cos(kappa);
    a3=-sin(phi)*cos(omega);
    b1=cos(omega)*sin(kappa);
    b2=cos(omega)*cos(kappa);
    b3=-sin(omega);
    c1=sin(phi)*cos(kappa)+cos(phi)*sin(omega)*sin(kappa);
    c2=-sin(phi)*sin(kappa)+cos(phi)*sin(omega)*cos(kappa);
    c3=cos(phi)*cos(omega);

    x_c = zeros(length(AutoBarImg), 1);
    y_c = zeros(length(AutoBarImg), 1);
    Lnew = zeros(2*length(AutoBarImg), 1);
    
    for ii = 1 : length(AutoBarImg)
        X = AutoBarSpace(ii, 1);
        Y = AutoBarSpace(ii, 2);
        Z = AutoBarSpace(ii, 3);
        X_ = a1*(X-Xs)+b1*(Y-Ys)+c1*(Z-Zs);
        Y_ = a2*(X-Xs)+b2*(Y-Ys)+c2*(Z-Zs);
        Z_ = a3*(X-Xs)+b3*(Y-Ys)+c3*(Z-Zs);
        x_c(ii) = -f * X_ / Z_ ;
        y_c(ii) = -f * Y_ / Z_;
 
        Lnew(ii*2-1) = x_c(ii) - x(ii);
        Lnew(ii*2)    = y_c(ii) - y(ii);
    end
    
%     ����UU
    LL = 1/2*Delta'*(UU*Delta - C'*L);
    rou = (1/2*L'*L - 1/2*Lnew'*Lnew)/LL;
    
     if rou > 0
        ExtParam = ExtParamNew;
        UU = UU*max([1/3, 1-(2*rou-1)^3]);
        VV = 2;
    else
        UU = UU * VV;
        VV = VV * 2;
    end
    change = norm(Delta);%NORM��һ��������������һ�ֿ����������ռ�����������賤�Ⱥʹ�С����ʽ��n=norm(A,p)������A���������ֵ����max(svd(A)) n=norm(A,p)������p�Ĳ�ͬ�����ز�ͬ��ֵ��
end
resi = L;
ExtParam(4:6)=rad2deg(ExtParam(4:6));%���ǵĵ�λ�ӻ���ת��Ϊ��

ExtParams = ExtParam;

