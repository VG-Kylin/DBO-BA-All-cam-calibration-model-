function [Fisheye_Imgpoints_without_Noise]=Fisheye_Imgpoints_Generation(All_control_field_targets,Cam_pos_RT,CMOSsize,camera_interior_parameters)
% 输入仿真相机外参数 输出鱼眼图像图像坐标和与之对应的世界坐标

% 定义相机参数
focal_length = camera_interior_parameters(1); % 焦距为12mm

point_world=All_control_field_targets';
[pointnum,~]=size(All_control_field_targets);
R=Cam_pos_RT{1};
T=Cam_pos_RT{2};

%% 使用鱼眼投影模型进行成像
point_image = zeros(2, pointnum);
for i = 1:pointnum

    % 将点从世界坐标系转换到相机坐标系
    point_cam(1) = R(1, :)*(point_world(:, i) - T);
    point_cam(2) = R(2, :)*(point_world(:, i) - T);
    point_cam(3) = R(3, :)*(point_world(:, i) - T);
    % 计算入射角
    theta = atan(sqrt(point_cam(2)^2+point_cam(1)^2)/point_cam(3));
    
    
%% ------------------鱼眼投影模型的计算公式--------------------------
    %等距投影 Equidistant projection
    r = -focal_length * theta;

    %等角投影 Equisolid-angle projection
    % r = -2*focal_length *sin(theta/2);

    %正交投影 Orthographic projection
    % r=-focal_length*sin(theta);

    %立体投影 Stereographic projection
    % r = -2*focal_length *tan(theta/2);






% ------------------------------------------------------------------
    
    % 鱼眼投影模型后的像面坐标
    point_image_tem(1) = r*point_cam(1)/(sqrt(point_cam(1)^2 + point_cam(2)^2));
    point_image_tem(2) = r*point_cam(2)/(sqrt(point_cam(1)^2 + point_cam(2)^2));
    
    point_image(:, i) = point_image_tem;
end
%% 还需要添加一个根据CMOSsize来确定具体有哪些点可以成像的功能+++++++++++++

Fisheye_Imgpoints_without_Noise=point_image';
end