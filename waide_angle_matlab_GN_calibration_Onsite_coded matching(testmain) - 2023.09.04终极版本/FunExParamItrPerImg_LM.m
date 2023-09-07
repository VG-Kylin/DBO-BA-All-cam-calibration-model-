function [param, k, fh] = FunExParamItrPerImg_LM(F, ExParam_init, pImg, pObj, nP)
%%%%%%%%%%%此内外方位参数优化方法不同于束调整方法，
%%%%%%%%%% 此方法在精确的内方位参数基础上优化每幅图片的外方位参数，6参数的外方位
kMax = 300;
k = 0;

change = 20;
param = ExParam_init;
J = zeros(2*nP, 6);
UU = 2;
VV = 2;

while k < kMax & change > 10^-10
    f = [];
    fh = [];
    k = k + 1;

    tx = param(1); ty = param(2); tz = param(3);
    az = param(4); el = param(5); ro = param(6);
    a1 = cos(ro)*cos(az)+sin(ro)*sin(el)*sin(az);
    a2 = -sin(ro)*cos(az)+cos(ro)*sin(el)*sin(az);
    a3 = cos(el)*sin(az);
    b1 = cos(ro)*sin(az)-sin(ro)*sin(el)*cos(az);
    b2 = -sin(ro)*sin(az)-cos(ro)*sin(el)*cos(az);
    b3 = -cos(el)*cos(az);
    c1 = sin(ro)*cos(el);
    c2 = cos(ro)*cos(el);
    c3 = -sin(el);
    
    for indexP = 1 : nP
        X = pObj(indexP, 1); Y = pObj(indexP, 2); Z = pObj(indexP, 3);
        u = pImg(indexP, 1); v = pImg(indexP, 2);
        Xbar = a1 * (X - tx) + b1 * (Y - ty) + c1 * (Z - tz);
        Ybar = a2 * (X - tx) + b2 * (Y - ty) + c2 * (Z - tz);
        Zbar = a3 * (X - tx) + b3 * (Y - ty) + c3 * (Z - tz);
        xEst = -F * Xbar/Zbar; yEst = -F * Ybar/Zbar;
        J(2*(indexP-1) + 1 : 2*(indexP-1) + 2, 1) = [1/Zbar * (a1*F + a3*xEst); 1/Zbar * (a2*F + a3*yEst)];
        J(2*(indexP-1) + 1 : 2*(indexP-1) + 2, 2) = [1/Zbar * (b1*F + b3*xEst); 1/Zbar * (b2*F + b3*yEst)];
        J(2*(indexP-1) + 1 : 2*(indexP-1) + 2, 3) = [1/Zbar * (c1*F + c3*xEst); 1/Zbar * (c2*F + c3*yEst)];
        J(2*(indexP-1) + 1 : 2*(indexP-1) + 2, 4) = dfdaz(F, X, Y, Z, az, el, ro, tx, ty, tz);
        J(2*(indexP-1) + 1 : 2*(indexP-1) + 2, 5) = dfdel(F, X, Y, Z, az, el, ro, tx, ty, tz);
        J(2*(indexP-1) + 1 : 2*(indexP-1) + 2, 6) = dfdro(F, X, Y, Z, az, el, ro, tx, ty, tz);

        temp = [-F * Xbar/Zbar; -F * Ybar/Zbar];
        f = [f; temp - [u; v]];
    end

    hlm = -inv(J'* J + UU*eye(size(J', 1)))*(J'* f);
    param_new = param + hlm;
    
    tx = param_new(1); ty = param_new(2); tz = param_new(3);
    az = param_new(4); el = param_new(5); ro = param_new(6);
    a1 = cos(ro)*cos(az)+sin(ro)*sin(el)*sin(az);
    a2 = -sin(ro)*cos(az)+cos(ro)*sin(el)*sin(az);
    a3 = cos(el)*sin(az);
    b1 = cos(ro)*sin(az)-sin(ro)*sin(el)*cos(az);
    b2 = -sin(ro)*sin(az)-cos(ro)*sin(el)*cos(az);
    b3 = -cos(el)*cos(az);
    c1 = sin(ro)*cos(el);
    c2 = cos(ro)*cos(el);
    c3 = -sin(el);
    for indexP = 1 : nP
        X = pObj(indexP, 1); Y = pObj(indexP, 2); Z = pObj(indexP, 3);
        u = pImg(indexP, 1); v = pImg(indexP, 2);    
        Xbar = a1 * (X - tx) + b1 * (Y - ty) + c1 * (Z - tz);
        Ybar = a2 * (X - tx) + b2 * (Y - ty) + c2 * (Z - tz);
        Zbar = a3 * (X - tx) + b3 * (Y - ty) + c3 * (Z - tz);
        temp = [-F * Xbar/Zbar; -F * Ybar/Zbar];
        fh = [fh; temp - [u; v]];
    end
 %%%%%%%%更新UU   
    L = 1/2*hlm'*(UU*hlm - J'*f);
    rou = (1/2*f'*f - 1/2*fh'*fh)/L;
    
    if rou > 0
        param = param_new;
        UU = UU*max([1/3, 1-(2*rou-1)^3]);
        VV = 2;
    else
        UU = UU * VV;
        VV = VV * 2;
    end
    change = std(hlm);
end