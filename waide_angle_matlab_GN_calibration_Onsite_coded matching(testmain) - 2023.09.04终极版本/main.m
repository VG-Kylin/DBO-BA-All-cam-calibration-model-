clc;
clear;
close all;
%% 数据设定及加载

%----------------------相机硬件参数统计------------------------
% HIKVISION
% The camera field of view is 90°
% The image resolution is 4096 × 3000
% The image sensor model is Sony IMX304 1.1" CMOS
% The pixel size is 3.45 µm
%CMOS size: 7.0656*2mm 5.1750*2mm
%相机CMOS范围
% CMOSsize=[7.0656 5.1750];
CMOSsize=[36 24];%单位(mm)  能有效反求畸变后成像坐标的成像范围尺寸，用真实CMOS尺寸算法在视场边缘无法正确迭代出正确的畸变坐标
%------------------------------------------------------------


%-------------------------相机内参数--------------------------
% camera_interior_parameters=[12;0;0;0;0;0;0;0;0;0];%f,x0,y0,k1,k2,k3,p1,p2,b1,b2

camera_interior_parameters=[12
-0.0951000000000000
0.00870000000000000
0.00000240000000000000
-0.00000164560000000000
1.33810000000000e-09
0.0000187680000000000
-2.60410000000000e-09
-0.0000104290000000000
-2.33730000000000e-06];%畸变系数加了很小的kpb，为了避免观测坐标反向最小二乘法求解初值不准确导致点坐标计算失败的情况
%------------------------------------------------------------


%--------------------------三维点数据加载--------------------
control_field_alldata = readtable('..\DATA\control_field_data.txt');
%----------------------------------------------------------


%-------------------------坐标系尺度--------------------------
World_axis_scale=300;%世界坐标系尺度
Cam_axis_scale=200;%相机坐标系尺度
%------------------------------------------------------------


%-------------------------相机球形网络设置--------------------------
% 假设中心点为 (0, 0, 0)
center = [0, 0, 0];
% 网络整体平移x;y;z
T=[0;0;0];
% 定义球形点阵列的半径和点数
radius = 2000;
num_points = 6;
%偏航角范围
Yaw_range=[30;150];
%俯仰角范围
Pitch_range=[50;130];
%球形网络生成
[cam_position_angle_all,cam_num]=cam_muti_pose_set(radius,num_points,Yaw_range,Pitch_range,center,T);
%------------------------------------------------------------------




%% 控制场数据分流分类

[All_control_field_targets,control_field_targets,control_field_targets_Bar,control_field_targets_CODE,control_field_targets_Scale_Bar,control_field_targets_Targets,control_field_alldataall]=control_field_targets_drawing(control_field_alldata);%控制场数据分类及绘图。最终返回全部控制场点



%% 迭代参数初值矩阵定义
Initial_value_all=[14;0;0;0;0;0;0;0;0;0]; 


%% 循环生成多站位相机像面观测数据
Data_Fisheye_Imgpoints_ALL=[];
Or=[90;180];%绕光轴旋转90°，辅助相机网络矩阵正则化 Orthogonality_Camorient
for o=1:2
for i=1:cam_num
%-------------------------相机外参数--------------------------

Camposition=[cam_position_angle_all(i,1);cam_position_angle_all(i,2);cam_position_angle_all(i,3)];%x;y;z的平移设置顺序 mm

Camorient=[Or(o);90-cam_position_angle_all(i,5);90-cam_position_angle_all(i,4)];%z;x;y的角度设置顺序 deg


Camorientreal=Camorient;%z,x,y顺序% 这里的Camorient是作为仿真环境生成要用的角度值，不做弧度转换，因为R_generate自带转弧度功能
Camorientreal=deg2rad(Camorientreal);%这个是要作为初值直接带入优化算法中，因为符号运算采用弧度制，所以此处提前转换为弧度制单位，并且后续该数据不再带入R_generate，而是带入R_generate_rad

%% 初值加偏移量
% Initial_value_all 弧度值＋0.01 rad  位置+5 mm

Initial_value_all = [Initial_value_all;Camorientreal+0.01;Camposition+5]; %循环叠加，统计了全部站位相机的内参数及外参数
%------------------------------------------------------------


%% 坐标系设置及相机站位生成

[camphideg,camposition,Cam_pos_RT,CaxisRT]=CamSimuGenerate(Cam_axis_scale,Camposition,Camorient);


%% 仿真环境生成
if i==1     %只在第一个循环画整个场景和当前相机站位
    Simulation_drawing(CaxisRT,World_axis_scale,control_field_targets_Bar,control_field_targets_CODE,control_field_targets_Scale_Bar,control_field_targets_Targets,control_field_alldataall,control_field_alldata);
else        %后续循环都不再重复画场景，只画相机站位
    Simulation_drawing_2(CaxisRT);
end

%% control_field_targets 成像仿真

[Fisheye_Imgpoints_without_Noise]=Fisheye_Imgpoints_Generation(All_control_field_targets,Cam_pos_RT,CMOSsize,camera_interior_parameters);

%% 畸变成像（鱼眼每个点的初值更加难以估计，正常KPB畸变数值无法全视场覆盖，只能减小数值）++++++++++++++++++
%===================畸变成像==========================
disParam=camera_interior_parameters(4:10,:);
u0=camera_interior_parameters(2);
v0=camera_interior_parameters(3);

for D=1:length(Fisheye_Imgpoints_without_Noise(:,1))

x_linear=Fisheye_Imgpoints_without_Noise(D,1);
y_linear=Fisheye_Imgpoints_without_Noise(D,2);


[uv_distorted, residual] = distortionContaminate_LM(x_linear, y_linear, u0, v0, disParam);
        Fisheye_Imgpoints_OB(D,1)=uv_distorted(1);
        Fisheye_Imgpoints_OB(D,2)=uv_distorted(2);

end
%===================================================




%% 成像结果可视化
% photo_drawing(Fisheye_Imgpoints_without_Noise,CMOSsize,i,num_points,o);
photo_drawing(Fisheye_Imgpoints_OB,CMOSsize,i,num_points,o);


% Data_Fisheye_Imgpoints{i}=Fisheye_Imgpoints_without_Noise;
Data_Fisheye_Imgpoints{i}=Fisheye_Imgpoints_OB;

end

Data_Fisheye_Imgpoints_ALL=[Data_Fisheye_Imgpoints_ALL,Data_Fisheye_Imgpoints];

end

%% 像面点坐标加噪
% Data_Fisheye_Imgpoints
for C=1:(2*cam_num)
j=length(Data_Fisheye_Imgpoints_ALL{1,C}(:,1));
nd=normrnd(0,0.0002,j,2);%normrnd（平均值，标准差，行，列）；添加平均值0um，标准差0.2um的误差
Data_Fisheye_Imgpoints_ALL{1,C}=Data_Fisheye_Imgpoints_ALL{1,C}+nd;
end

%% 标定算法
ImageCoordinates=Data_Fisheye_Imgpoints_ALL;
WorldCoordinates=All_control_field_targets;

Initial_value_all=Initial_value_all';
[J, V, loop, AllParam,Delta_L_everyloop,V_everyloop,AllParam_everyloop]=muti_station_camera_calibration(ImageCoordinates,WorldCoordinates,Initial_value_all);



%% 误差统计及误差分布可视化
FontSize=12;
figure('Units', 'pixels', 'Position', [600, 600, 1000, 600])
% subplot(1,3,1);
h=histfit(V);

pd = fitdist(V,'Normal'); % 获得拟合曲线的参数，均值和标准差，r必须要列向量，否则会报错！！！
sigma=pd.sigma;

mu=pd.mu;
sigma_pixel=0.004878/sigma;
% % 添加均值和方差的数值
text(0.0003, 100, ['sigame = ', num2str(sigma),' mm'],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
text(0.0003, 200, ['mu = ', num2str(mu),' mm'],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
text(0.0003, 150, ['sigma pixel = ', num2str(sigma_pixel),' pixel'],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');

% 添加图例
legend('Error distribution', 'Normal distribution curve','FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'bold');

% 标题和轴标签
title('Reprojection error distribution of all camera stations','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
xlabel('Error value','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
ylabel('Number of errors','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
set(gca, 'FontSize', FontSize);
%color
h(1).FaceColor = color51(12);
h(1).EdgeColor = color51(5);
h(2).Color = color51(37);




%% 自动存图

% 保存每个图像为 .jpg 格式
for p = 1:numel(findall(0,'type','figure'))
    % 通过 figure(i) 激活第 i 个图像
    figure(p);

    % 设置保存路径和文件名，注意使用不同的文件名或路径以防止覆盖
    save_path = 'C:\Users\Thunder\Desktop\wide_angle_reasearch\programming\waide_angle_matlab_GN_calibration_Simulation\pics\';
    file_name = ['figure', num2str(p), '.jpg'];

    % 使用 saveas 函数保存图像为 PNG 格式
    saveas(gcf, [save_path, file_name]);
end








