function [cam_position_angle_all,cam_num]=cam_muti_pose_set(radius,num_points,Yaw_range,Pitch_range,center,T)
% clc;
% clear;
% close all;
%% 球形点阵列生成


%相机站位球形角度间隔定义
deg_angle_range=[Yaw_range;Pitch_range];
rad_angle_range=deg2rad(deg_angle_range);

% 生成球坐标系的方位角和俯仰角
theta = linspace(rad_angle_range(1),rad_angle_range(2), num_points);
phi = linspace(rad_angle_range(3),rad_angle_range(4), num_points);



% 使用 meshgrid 生成球坐标系的网格矩阵
[Theta, Phi] = meshgrid(theta, phi);

% 将球坐标转换为笛卡尔坐标
X = radius * sin(Phi) .* cos(Theta);
Y = radius * sin(Phi) .* sin(Theta);
Z = radius * cos(Phi);


%全部坐标整理
cam_position_all=[];
for i=1:num_points

cam_position=[X(:,i),Y(:,i),Z(:,i)];

cam_position_all=[cam_position_all;cam_position];
end



%% 计算每个点到圆心的矢量夹角



% 假设点阵列的 X、Y、Z 坐标存储在 X、Y、Z 变量中
X = cam_position_all(:,1);
Y = cam_position_all(:,2);
Z = cam_position_all(:,3);

% 计算每个点到中心的矢量
vector_to_center = [X(:) - center(1), Y(:) - center(2), Z(:) - center(3)];

% 计算每个矢量的俯仰角（仰角角度的计算）

elevation_angle = atan2(vector_to_center(:,3), sqrt(vector_to_center(:,1).^2 + vector_to_center(:,2).^2));%俯仰角
azimuth_angle = atan2(vector_to_center(:,2), vector_to_center(:,1));%偏航角

% 将俯仰角和偏航角转换为欧拉角（假设旋转角度绕 X 轴）
euler_angles = [ elevation_angle, azimuth_angle];

deg_euler_angles=rad2deg(euler_angles);


%坐标系转换至仿真世界坐标系下，使相机站位具有物理意义
camphideg=[90,0,0];
phiy=camphideg(3);
phix=camphideg(2);
phiz=camphideg(1);%角度值 yxz顺序旋转
[R]=R_generate(phiz,phix,phiy);%生成旋转矩阵
cam_position_all=R*cam_position_all';


cam_position_all=cam_position_all+T;





%数据集合
cam_position_angle_all=[cam_position_all',deg_euler_angles];
[cam_num,~]=size(cam_position_angle_all);

figure(1)
% 绘制球形点阵列坐标
plot3(cam_position_angle_all(:,1), cam_position_angle_all(:,2), cam_position_angle_all(:,3), 'b>', 'MarkerSize', 5);axis equal;hold on;

% 添加坐标轴标签和标题等其他设置
xlabel('X');
ylabel('Y');
zlabel('Z');
title('All Cam Positions');


% 显示网格
grid on;
end