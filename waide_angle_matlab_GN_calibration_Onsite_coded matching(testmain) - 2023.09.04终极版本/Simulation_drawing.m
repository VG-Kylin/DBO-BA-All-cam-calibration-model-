function Simulation_drawing(CaxisRT,World_axis_scale,control_field_targets_Bar,control_field_targets_CODE,control_field_targets_Scale_Bar,control_field_targets_Targets,control_field_alldataall,control_field_alldata)
% figure('Units', 'pixels', 'Position', [100, 100, 2000, 1600]);
fig = figure(2);

% 设置图形窗口的大小和位置
width = 2000;   % 宽度（以像素为单位）
height = 1600;  % 高度（以像素为单位）
xPos = 100;    % 水平位置（以像素为单位）
yPos = 100;    % 垂直位置（以像素为单位）
set(fig, 'Position', [xPos, yPos, width, height]);


%% 相机绘图
plot3(CaxisRT(:,1),CaxisRT(:,2),CaxisRT(:,3),'k.');hold on;axis equal;

x_label=[CaxisRT(1,:);CaxisRT(4,:)];
y_label=[CaxisRT(2,:);CaxisRT(4,:)];
z_label=[CaxisRT(3,:);CaxisRT(4,:)];

plot3(x_label(:,1),x_label(:,2),x_label(:,3),'r-');hold on;axis equal;
plot3(y_label(:,1),y_label(:,2),y_label(:,3),'g-');hold on;axis equal;
plot3(z_label(:,1),z_label(:,2),z_label(:,3),'b-');hold on;axis equal;
text(CaxisRT(4, 1), CaxisRT(4, 2), CaxisRT(4, 3),'Cam', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right','FontWeight', 'bold', 'FontSize', 18,'FontName','Times New Roman');

%% 世界系绘图
axis([-World_axis_scale World_axis_scale -World_axis_scale World_axis_scale -World_axis_scale World_axis_scale]);hold on;
a=[World_axis_scale;0;0];b=[0;World_axis_scale;0];c=[0;0;World_axis_scale];o=[0;0;0];
x_label =[o';a'];y_label=[o';b'];z_label=[o';c'];

plot3(x_label(:,1),x_label(:,2),x_label(:,3),'r-');hold on;axis equal;
plot3(y_label(:,1),y_label(:,2),y_label(:,3),'g-');hold on;axis equal;
plot3(z_label(:,1),z_label(:,2),z_label(:,3),'b-');hold on;axis equal;
text(0, 0, 0,'World Center', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right','FontWeight', 'bold', 'FontSize', 18,'FontName','Times New Roman');


%% 场绘图
% 数据可视化

plot3(control_field_targets_Bar(:,1),control_field_targets_Bar(:,2),control_field_targets_Bar(:,3),'b.',MarkerSize=10);axis equal;hold on;
plot3(control_field_targets_CODE(:,1),control_field_targets_CODE(:,2),control_field_targets_CODE(:,3),'r.',MarkerSize=10);axis equal;hold on;
plot3(control_field_targets_Scale_Bar(:,1),control_field_targets_Scale_Bar(:,2),control_field_targets_Scale_Bar(:,3),'g.',MarkerSize=10);axis equal;hold on;

plot3(control_field_targets_Targets(:,1),control_field_targets_Targets(:,2),control_field_targets_Targets(:,3),'k.',MarkerSize=10);axis equal;hold on;



[a,~]=size(control_field_alldataall);
% 添加点的名称
for i = 1:a
    x = control_field_alldataall(i, 1);
    y = control_field_alldataall(i, 2);
    z = control_field_alldataall(i, 3);
    name = control_field_alldata(i, 1);
    text(x, y, z, [name.Var1], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 8,'FontWeight','bold','FontName','Times New Roman');
end

% 添加坐标轴标签和标题等其他设置
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Simulation scene','FontName', 'Times New Roman', 'FontSize', 18, 'FontWeight', 'bold');

% 显示网格
grid on;
% 空间全部点

% figure
% plot3(All_control_field_targets(:,1),All_control_field_targets(:,2),All_control_field_targets(:,3),'k.',MarkerSize=10);axis equal;hold on;
% 设置 x 轴范围为 0 到 10
xlim([-1000, 5000])

% 设置 y 轴范围为 -5 到 5
ylim([-3000, 3000])

% 设置 z 轴范围为 -5 到 5
zlim([-1000, 3000])






view(120, 30);




end 