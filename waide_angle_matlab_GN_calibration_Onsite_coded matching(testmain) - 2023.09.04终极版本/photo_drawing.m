function photo_drawing(Fisheye_Imgpoints_without_Noise,CMOSsize,i,num_points)
fig=figure(3);
FontSize=12;
subplot(num_points,num_points,i)
% 绘制鱼眼相机成像的二维像面坐标
plot(Fisheye_Imgpoints_without_Noise(:, 1), Fisheye_Imgpoints_without_Noise(:, 2), 'b.');axis equal;hold on;
xlabel('X (mm)','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
ylabel('Y (mm)','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
title(['Fisheye Imgpoints simulation - ',num2str(i)],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');

% 设置 x 轴范围
xlim([-(CMOSsize(1))/2, (CMOSsize(1))/2]);

% 设置 y 轴范围
ylim([-(CMOSsize(2)/2), (CMOSsize(2))/2]);




% 设置图形窗口的大小和位置
% width = 3840;   % 宽度（以像素为单位）
% height = 2160;  % 高度（以像素为单位）
width = 2000;   % 宽度（以像素为单位）
height = 1600;  % 高度（以像素为单位）
xPos = 0;    % 水平位置（以像素为单位）
yPos = 0;    % 垂直位置（以像素为单位）
set(fig, 'Position', [xPos, yPos, width, height]);


    % % 添加图例
    legend('All targets','FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'bold');

    set(gca, 'FontSize', FontSize);

end