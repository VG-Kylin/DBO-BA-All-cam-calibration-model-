% % % 为VC系统集成的模块
% % % 2012.07.05
function [Phi, Omegga, Kappa] = phgAz2Phi(Az, El, Ro)% 弧度制转弧度制
%% 从az, el, ro到 phi, omegga, kappa的变化
%% 输入以 °度为单位的角度值，得到以°度为单位的角度值
% % sin(omegga) = cos(el)*cos(az)
% % sin(phi) = -cos(el)*sin(az)/cos(omegga)
% % cos(phi) = -sin(el)/cos(omegga)
% % sin(kappa) = (cos(ro)*sin(az)-sin(ro)*sin(el)*cos(az))/cos(omegga)
% % cos(kappa) = (-sin(ro)*sin(az)-cos(ro)*sin(el)*cos(az))/cos(omegga)

% az = Az/180*pi;
% el = El/180*pi;
% ro = Ro/180*pi;

az = Az;
el = El;
ro = Ro;


%%%%%%%%%
omegga = asin(cos(el)*cos(az));
%%%%%%%%%%%%
phi = atan2(-cos(el)*sin(az)/cos(omegga), -sin(el)/cos(omegga));
kappa = atan2((cos(ro)*sin(az)-sin(ro)*sin(el)*cos(az))/cos(omegga),...
    (-sin(ro)*sin(az)-cos(ro)*sin(el)*cos(az))/cos(omegga));


% Omegga = omegga *180 / pi;
% Phi = phi * 180 /pi;
% Kappa = kappa * 180 / pi;

Omegga = omegga;
Phi = phi;
Kappa = kappa;