function [uv_distorted, residual] = distortionContaminate_LM(x_linear, y_linear, u0, v0, disParam)
k1 = disParam(1); k2 = disParam(2); k3 = disParam(3);
p1 = disParam(4); p2 = disParam(5);
b1 = disParam(6); b2 = disParam(7);

u = x_linear; v = y_linear;
% x_linear_est = u - u0 + b1*(u - u0) + b2*(v - v0) + p1*(3*(u - u0)^2 + (v - v0)^2) + (u - u0)*(k1*((u - u0)^2 + (v - v0)^2) + k2*((u - u0)^2 + (v - v0)^2)^2 + k3*((u - u0)^2 + (v - v0)^2)^3) + 2*p2*(u - u0)*(v - v0);
% y_linear_est = v - v0 + p2*((u - u0)^2 + 3*(v - v0)^2) + (v - v0)*(k1*((u - u0)^2 + (v - v0)^2) + k2*((u - u0)^2 + (v - v0)^2)^2 + k3*((u - u0)^2 + (v - v0)^2)^3) + 2*p1*(u - u0)*(v - v0);
x_linear_est = x_linear;
y_linear_est = y_linear;
uvParam = [x_linear_est; y_linear_est];
kMax = 300;
k = 1;
uvIncrease = 1;
UU = 2;
VV = 2;

while uvIncrease > 0.0000001 && k < kMax
    k = k + 1;
    u = uvParam(1); v = uvParam(2);
    J = zeros(2, 2);
    f = zeros(2, 1);
    fh = zeros(2, 1);
    J(1, 1) = b1 + (u - u0)*(k1*(2*u - 2*u0) + 2*k2*(2*u - 2*u0)*((u - u0)^2 + (v - v0)^2) + 3*k3*(2*u - 2*u0)*((u - u0)^2 + (v - v0)^2)^2) + k1*((u - u0)^2 + (v - v0)^2) + 2*p2*(v - v0) + k2*((u - u0)^2 + (v - v0)^2)^2 + k3*((u - u0)^2 + (v - v0)^2)^3 + p1*(6*u - 6*u0) + 1;
    J(1, 2) = b2 + (u - u0)*(k1*(2*v - 2*v0) + 2*k2*(2*v - 2*v0)*((u - u0)^2 + (v - v0)^2) + 3*k3*(2*v - 2*v0)*((u - u0)^2 + (v - v0)^2)^2) + 2*p2*(u - u0) + p1*(2*v - 2*v0);
    J(2, 1) = (v - v0)*(k1*(2*u - 2*u0) + 2*k2*(2*u - 2*u0)*((u - u0)^2 + (v - v0)^2) + 3*k3*(2*u - 2*u0)*((u - u0)^2 + (v - v0)^2)^2) + 2*p1*(v - v0) + p2*(2*u - 2*u0);
    J(2, 2) = (v - v0)*(k1*(2*v - 2*v0) + 2*k2*(2*v - 2*v0)*((u - u0)^2 + (v - v0)^2) + 3*k3*(2*v - 2*v0)*((u - u0)^2 + (v - v0)^2)^2) + k1*((u - u0)^2 + (v - v0)^2) + 2*p1*(u - u0) + k2*((u - u0)^2 + (v - v0)^2)^2 + k3*((u - u0)^2 + (v - v0)^2)^3 + p2*(6*v - 6*v0) + 1;
    x_linear_est = u - u0 + b1*(u - u0) + b2*(v - v0) + p1*(3*(u - u0)^2 + (v - v0)^2) + (u - u0)*(k1*((u - u0)^2 + (v - v0)^2) + k2*((u - u0)^2 + (v - v0)^2)^2 + k3*((u - u0)^2 + (v - v0)^2)^3) + 2*p2*(u - u0)*(v - v0);
    y_linear_est = v - v0 + p2*((u - u0)^2 + 3*(v - v0)^2) + (v - v0)*(k1*((u - u0)^2 + (v - v0)^2) + k2*((u - u0)^2 + (v - v0)^2)^2 + k3*((u - u0)^2 + (v - v0)^2)^3) + 2*p1*(u - u0)*(v - v0);
    f = [x_linear - x_linear_est; y_linear  - y_linear_est];
%% GN
%     hgn = inv(J'*J)*J'*f; 
%     uvParam = uvParam + hgn;
%% LM
    hlm = inv(J'* J + UU*eye(size(J', 1)))*(J'* f);    
    uvParam_new = uvParam + hlm;
    u = uvParam_new(1); v = uvParam_new(2);
    x_linear_est = u - u0 + b1*(u - u0) + b2*(v - v0) + p1*(3*(u - u0)^2 + (v - v0)^2) + (u - u0)*(k1*((u - u0)^2 + (v - v0)^2) + k2*((u - u0)^2 + (v - v0)^2)^2 + k3*((u - u0)^2 + (v - v0)^2)^3) + 2*p2*(u - u0)*(v - v0);
    y_linear_est = v - v0 + p2*((u - u0)^2 + 3*(v - v0)^2) + (v - v0)*(k1*((u - u0)^2 + (v - v0)^2) + k2*((u - u0)^2 + (v - v0)^2)^2 + k3*((u - u0)^2 + (v - v0)^2)^3) + 2*p1*(u - u0)*(v - v0);
    fh = [x_linear - x_linear_est; y_linear  - y_linear_est];
    L = 1/2*hlm'*(UU*hlm + J'*f);
    rou = (1/2*f'*f - 1/2*fh'*fh)/L;
    
    if rou > 0
        uvParam = uvParam_new;
        UU = UU*max([1/3, 1-(2*rou-1)^3]);
        VV = 2;
    else
        UU = UU * VV;
        VV = VV * 2;
    end
    
%     uvIncrease = mean(abs(hgn));%GN
    uvIncrease = mean(abs(hlm));%LM
end
uv_distorted = uvParam';
residual = f;