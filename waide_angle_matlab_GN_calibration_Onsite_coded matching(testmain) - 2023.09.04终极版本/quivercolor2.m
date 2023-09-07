function quivercolor2(IMGStarAfterMatch, U, V,sorted_Data_Fisheye_Imgpoints_ALL)
X=IMGStarAfterMatch(:,1);
Y=IMGStarAfterMatch(:,2);
map = addcolorplus(308);

q = quiver(X, Y, U, V,2,'LineWidth',2);hold on;axis equal;


%// Compute the magnitude of the vectors

mags = sqrt(sum(cat(2, q.UData(:), q.VData(:), reshape(q.WData, numel(q.UData), [])).^2, 2));

%// Get the current colormap

currentColormap = colormap(map);

%// Now determine the color to make each arrow using a colormap

[~, ~, ind] = histcounts(mags, size(currentColormap, 1));

%// Now map this to a colormap to get RGB

cmap = uint8(ind2rgb(ind(:), currentColormap) * 255);

cmap(:,:,4) = 255;

cmap = permute(repmat(cmap, [1 3 1]), [2 1 3]);

%// We repeat each color 3 times (using 1:3 below) because each arrow has 3 vertices

set(q.Head, ...
'ColorBinding', 'interpolated', ...
'ColorData', reshape(cmap(1:3,:,:), [], 4).'); %'

%// We repeat each color 2 times (using 1:2 below) because each tail has 2 vertices

set(q.Tail, ...
'ColorBinding', 'interpolated', ...
'ColorData', reshape(cmap(1:2,:,:), [], 4).');



%// Image setting(单独调用写在函数内部即可，重复调用更改图题的话需要写在该函数外部)
% title('星点像面定位误差矢量图','fontSize',20,'FontName','宋体','FontWeight','bold');
% xlabel('像面x坐标轴（mm）','fontSize',20,'FontName','宋体','FontWeight','bold');
% ylabel('像面y坐标轴（mm）','fontSize',20,'FontName','宋体','FontWeight','bold');
% set(gca, 'Box', 'off', ...                                                         % 边框
%         'LineWidth', 1, 'GridLineStyle', '-',...                                   % 坐标轴线宽
%         'XGrid', 'on', 'YGrid', 'on','ZGrid', 'on', ...                          % 网格
%         'TickDir', 'out', 'TickLength', [.015 .015], ...                           % 刻度
%         'XMinorTick', 'on', 'YMinorTick', 'on',  'ZMinorTick', 'on',...         % 小刻度
%         'XColor', [0 0 0],  'YColor',[0 0 0], 'ZColor', [0 0 0]);         %坐标轴颜色  
% 
% xlim([-8 8]);
% ylim([-8 8]);

%// color rang setting
colorbar;
tempmin=min(mags);
tempmax=max(mags);
tempx = [tempmin,tempmax];
% tempx = [0,0.001];%颜色区间固定，方便观察各个图像的误差
set(get(colorbar,'Title'),'string','mm');

% tempx = [0,0.0034];

clim(tempx);

%// name the vectors
for i=1:length(X)

text(X(i),Y(i),['Code ',num2str(sorted_Data_Fisheye_Imgpoints_ALL(i,1))],'FontName', 'Times New Roman', 'FontSize', 5, 'FontWeight', 'bold');

end

end