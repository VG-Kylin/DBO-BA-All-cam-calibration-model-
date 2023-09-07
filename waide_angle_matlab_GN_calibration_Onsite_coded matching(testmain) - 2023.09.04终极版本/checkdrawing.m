function checkdrawing(Data_Fisheye_Imgpoints_ALL,Real_Data_Fisheye_Imgpoints_ALL,numImg,a,CMOSsize)
    figure
    FontSize=12;
    for i=1:numImg
        subplot(a,a,i)
        plot(Data_Fisheye_Imgpoints_ALL{i}(:,1),Data_Fisheye_Imgpoints_ALL{i}(:,2),'ro',MarkerSize=5);axis equal;hold on;
        plot(Real_Data_Fisheye_Imgpoints_ALL{i}(:,1),Real_Data_Fisheye_Imgpoints_ALL{i}(:,2),'b.',MarkerSize=10);axis equal;hold on;
        
        
        
        
        xlabel('X (mm)','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
        ylabel('Y (mm)','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
        title(['Fisheye Imgpoints simulation & real-measured image - ',num2str(i)],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');

        
        
        
        
        
        
        % 设置 x 轴范围
        xlim([-(CMOSsize(1))/2, (CMOSsize(1))/2]);
        
        % 设置 y 轴范围
        ylim([-(CMOSsize(2)/2), (CMOSsize(2))/2]);
    



        % % 设置图形窗口的大小和位置
        % % width = 3840;   % 宽度（以像素为单位）
        % % height = 2160;  % 高度（以像素为单位）
        % width = 2000;   % 宽度（以像素为单位）
        % height = 1600;  % 高度（以像素为单位）
        % xPos = 0;    % 水平位置（以像素为单位）
        % yPos = 0;    % 垂直位置（以像素为单位）
        % set(gca, 'Position', [xPos, yPos, width, height]);

        % % 添加图例
        legend('Simulation targets','real-measured targets','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    
        % set(gca, 'FontSize', FontSize);

    end

end