clc; clear; close all

%% 实测像面坐标计算及外参数初值估计

%--------------------像元尺寸----------------------
%HIKVISION
pixSize = 0.00345;
%D300  D2x
% pixSize = 0.006;
% CMOSsize=[25.728 17.088];
%D810
% pixSize = 0.004878;
%戴
% pixSize = 0.004521;
%AVT
% pixSize = 0.0074;

% CMOSsize=[36 24];
CMOSsize=[8.4456 7.0656];
%-------------------------------------------------


maxPixThresh = 5; ErrorIdx = 0;
ifComp = 0; compTemp40 = []; compTemp35 = [];
initInParam = load('IntrinsicParameters_V12mm.txt');%f是第三个值
%%%图像处理相关参数
bwThreshold = 0.2; 
% minSpotSize = 9; 
minSpotSize = 2000; 
maxSpotSize = 20000;
barDesign = [0.000	0.000	0.000;
0.000	-50.800	114.300;
0.000	0.000	177.800;
0.000	50.800	114.300;
12.700	0.000	57.150;
0.000	0.000	127.000];
%SetPath
[imgFileNames, numImg] = FunSetPicPath();
%图像处理，获取回光反射点中心 _bwconncomp
[pointStructure, numCodeAll] = FunPicPointCentroid_bwconncomp(imgFileNames,...
    numImg, bwThreshold, minSpotSize, maxSpotSize, pixSize, barDesign, 0, ifComp, compTemp40, initInParam);
save pointStructure.mat;

load pointStructure.mat;
%% 画图检查点坐标识别及提取情况
% 每张图分别绘图，每个图对不同类型的点进行颜色区分
a=sqrt(numImg);
a=ceil(a);
figure(1)
FontSize=12;
for i=1:numImg
    point=pointStructure(i).point;
    bar=pointStructure(i).bar;
    code=pointStructure(i).code;
    Real_Data_Fisheye_Imgpoints_coded{i}=code;
    Real_Fisheye_EXP_estimate{i}=pointStructure(i).exParam;

    subplot(a,a,i);
    plot(point(:,2),point(:,3),'b.',MarkerSize=10);axis equal;hold on;
    plot(bar(:,2),bar(:,3),'g.',MarkerSize=10);axis equal;hold on;
    plot(code(:,2),code(:,3),'r.',MarkerSize=10);axis equal;hold on;
    % 设置 x 轴范围
    xlim([-(CMOSsize(1))/2, (CMOSsize(1))/2]);
    
    % 设置 y 轴范围
    ylim([-(CMOSsize(2)/2), (CMOSsize(2))/2]);
    % 添加图例
    % legend('Targets', 'Bar','Coded targets','FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'bold');
    % 标题和轴标签
    title(['Measured targets image - ', num2str(i)],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    xlabel('X (mm)','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    ylabel('Y (mm)','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    set(gca, 'FontSize', FontSize);
end


%% 编码点世界坐标提取
%--------------------------三维点数据加载--------------------
control_field_alldata = readtable('..\DATA\Bundle2.txt');
%----------------------------------------------------------
[All_control_field_targets,control_field_targets,control_field_targets_Bar,control_field_targets_CODE,control_field_targets_Scale_Bar,control_field_targets_Targets,control_field_alldataall]=control_field_targets_drawing(control_field_alldata);%控制场数据分类及绘图。最终返回全部控制场点
[b,~]=size(control_field_targets_CODE);
numcode=(1:1:b);
CODE_targets_WC(:,2:4)=control_field_targets_CODE;
CODE_targets_WC(:,1)=numcode;



%% 迭代参数初值矩阵定义
Initial_value_all=[19;0;0;0;0;0;0;0;0;0]; %内参数f,x0,y0,k1,k2,k3,p1,p2,b1,b2


% 相机外参数初值估计数据整理
Data_Fisheye_Imgpoints_ALL=[];

for i=1:numImg
%-------------------------相机外参数--------------------------
% [90,0,90]
Camposition=[Real_Fisheye_EXP_estimate{i}(1);Real_Fisheye_EXP_estimate{i}(2);Real_Fisheye_EXP_estimate{i}(3)];%x;y;z的平移设置顺序 mm
%+++++++++++++++++++++++++++++++++++++此处需要将VSTAR角度Real_Fisheye_EXP_estimate(4:6,1)的定义转换为摄影测量通用pwk
[Phi, Omegga, Kappa] = phgAz2Phi(Real_Fisheye_EXP_estimate{i}(4), Real_Fisheye_EXP_estimate{i}(5), Real_Fisheye_EXP_estimate{i}(6));%弧度值进入，弧度制输出


Camorient=[Kappa;Omegga;-Phi];%z;x;y的角度设置顺序 deg%左右手系旋转正负需要统一
% Camorient=[Kappa;-Omegga;-Phi];%z;x;y的角度设置顺序 deg%左右手系旋转正负需要统一
Camorient=rad2deg(Camorient);

Camorientreal=Camorient;%z,x,y顺序% 这里的Camorient是作为仿真环境生成要用的角度值，不做弧度转换，因为R_generate自带转弧度功能
Camorientreal=deg2rad(Camorientreal);%这个是要作为初值直接带入优化算法中，因为符号运算采用弧度制，所以此处提前转换为弧度制单位，并且后续该数据不再带入R_generate，而是带入R_generate_rad

% 初值定义
% Initial_value_all 弧度值＋0.01 rad  位置+5 mm

Initial_value_all = [Initial_value_all;Camorientreal+0;Camposition+0]; %循环叠加，统计了全部站位相机的内参数及外参数


end



%% 像面编码点坐标直接匹配
% Real_Data_Fisheye_Imgpoints_coded{i}
% CODE_targets_WC

% 全部时刻都识别到的编码点进行保留并排序
for i=1:numImg




    common_index = intersect(CODE_targets_WC(:,1),Real_Data_Fisheye_Imgpoints_coded{i}(:,1));
    CODE_targets_WC_matched = CODE_targets_WC(ismember(CODE_targets_WC(:,1), common_index), :);
    Real_Data_Fisheye_Imgpoints_coded_matched = Real_Data_Fisheye_Imgpoints_coded{i}(ismember(Real_Data_Fisheye_Imgpoints_coded{i}(:,1), common_index), :);
    sorted_Real_Data_Fisheye_Imgpoints_coded_matched = sortrows(Real_Data_Fisheye_Imgpoints_coded_matched, 1);


CODE_targets_WC_matched_all{i}=CODE_targets_WC_matched(:,2:4);
Data_Fisheye_Imgpoints_ALL{i}=sorted_Real_Data_Fisheye_Imgpoints_coded_matched(:,2:3);
sorted_Data_Fisheye_Imgpoints_ALL{i}=sorted_Real_Data_Fisheye_Imgpoints_coded_matched;
end





%% 标定算法
WorldCoordinates=CODE_targets_WC_matched_all;
ImageCoordinates=Data_Fisheye_Imgpoints_ALL;


Initial_value_all=Initial_value_all';
% [J, V, loop, AllParam,Delta_L_everyloop,V_everyloop,AllParam_everyloop]=muti_station_camera_calibration(ImageCoordinates,WorldCoordinates,Initial_value_all);

%% 跨投影模型寻优BA标定算法

% E_best = 1000; %设置一个很大的初始误差
% eyes_best = 0;
% V_best = []; AllParam_best = [];
% for eyes = -1:0.1:1 % 遍历鱼眼因子，寻找最优鱼眼模型（可换成寻优算法）
% 
%     if eyes == 0
%         [J, V, loop, AllParam] = GN_mode2(ImageCoordinates,WorldCoordinates,Initial_value_all);
% 
%     elseif (1>eyes)&&(eyes>0)
%         [J, V, loop, AllParam] = GN_mode1(ImageCoordinates,WorldCoordinates,Initial_value_all,eyes);
% 
%     elseif (-1<=eyes)&&(eyes<0)
%         [J, V, loop, AllParam] = GN_mode3(ImageCoordinates,WorldCoordinates,Initial_value_all,eyes);
% 
%     end
% 
%     E = sqrt(sum(V.*V)/length(V)); %寻找最小RMS所对应的鱼眼模型各种参数
%     if E<E_best
% 
%         E_best = E;
%         eyes_best = eyes;
%         V_best = V;
%         AllParam_best = AllParam';
% 
%     end
% 
% end
% V = V_best;


%% Pinhole mode test
% eyes=1;
% [J, V, loop, AllParam] = GN_mode1(ImageCoordinates,WorldCoordinates,Initial_value_all,eyes);%pin_hole_mode_tan

% [J, V, loop, AllParam,Data2] = GN_mode_y(ImageCoordinates,WorldCoordinates,Initial_value_all);%pin_hole mode

%% 多项式+p b mode test
% 多项式加p,b
%[x0, y0, k1, k2, k3, k4, k5, p1, p2, b1, b2 , phiz1,phix1,phiy1,Tx1,Ty1,Tz1,phiz2,phix2......]
[~,nn] = size(Initial_value_all);
tempp = zeros(1,nn+1);
tempp(1,12:end) = Initial_value_all(1,11:end);% 重新排列外参
tempp(1,1:2) = Initial_value_all(1,2:3);% 重新排列x0,y0
tempp(1,3:7) = 2;% k初值设为1
tempp(1,8:9) = Initial_value_all(1,7:8);% 重新排列p1,p2
tempp(1,10:11) = Initial_value_all(1,9:10);% 重新排列b1,b2
Initial_value_all = tempp;
[J, V, loop, AllParam] = GN_mode4(ImageCoordinates,WorldCoordinates,Initial_value_all);




%% Magic model
%数据剔除观察理论精度
logical_index = abs(V) > 0.003;
% 使用逻辑索引删除大于1的数值
V(logical_index) = [];


%% 误差统计及误差分布可视化
FontSize=12;
figure('Units', 'pixels', 'Position', [600, 600, 1000, 600])
% subplot(1,3,1);
h=histfit(V);

pd = fitdist(V,'Normal'); % 获得拟合曲线的参数，均值和标准差，r必须要列向量，否则会报错！！！
sigma=pd.sigma;

mu=pd.mu;
sigma_pixel=pixSize/sigma;
% % 添加均值和方差的数值
text(0.0003, 100, ['sigame = ', num2str(sigma),' mm'],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
text(0.0003, 200, ['mu = ', num2str(mu),' mm'],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
text(0.0003, 150, ['sigma pixel = 1/', num2str(sigma_pixel),' pixel'],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');

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

%% 误差像面分布及趋势可视化
% 分析：像面误差均值误差低，说明系统误差很小；误差分布比较分散，且大误差较多，与像面边缘光斑变形导致定位精度低可能有关。像面边缘光斑定心精度低，一个是光源响应超有效范围，一个是形状拉伸导致定心精度低。
% 别人用的是不发光的点，跟光源无关，不知道是否会影响定心精度。
% 如何保证鱼眼成像特点下，光斑依然可以达到高精度定心，是个问题。
% 需要进一步观察大误差分布是否都在像面周围，是否存在渐变趋势
% 原始全部点坐标残余误差数据统计：1/5.0159 pixel 精度
% 去掉大误差，剩余部分点的残余误差统计（可能是目前的理论精度极限）： 1/11 pixel 精度
% 解析模型的文章，目前精度没有高于1/12 pixel的
% 用小相机来拍摄看看是否可以标定，这个方法应该是一个具有普适性的通用相机标定方法
% 数据集重新制作，重新拍vstar，重新拍墙面
% 看看更好的成像效果是否能帮助鱼眼进行更高精度的标定？
% 换几种鱼眼镜头来进行测试，看看是否可以收敛到不同的k值模型上去，论证模型的鲁棒性及泛用性


% 对V进行按图像及xy的数据分类整理
Vclass=V;
V_per_pic=cell(2,numImg);
for i=1:numImg
    [m,n]=size(ImageCoordinates{i});
    V_per_pic{1,i}=Vclass(1:(m*n));
    Vclass(1:(m*n))=[];
    
    [l,~]=size(V_per_pic{1,i});
    for j=1:(l/2)
        V_per_pic{2,i}(j,1)=V_per_pic{1,i}(2*j-1,1);
        V_per_pic{2,i}(j,2)=V_per_pic{1,i}(2*j,1);
        ImageCoordinates{1,i}(j,3)=V_per_pic{1,i}(2*j-1,1);% 与像面坐标ImageCoordinates的数据做好对应
        ImageCoordinates{1,i}(j,4)=V_per_pic{1,i}(2*j,1);
    end

end

% 按照像面点画图，在基础上画出箭头误差坐标的矢量指向，并进行10倍放大

figure
FontSize=12;
for i=1:numImg
    subplot(a,a,i);
    plot(ImageCoordinates{i}(:,1),ImageCoordinates{i}(:,2),'ko',MarkerSize=10);axis equal;hold on;
    quiver(ImageCoordinates{i}(:,1), ImageCoordinates{i}(:,2), ImageCoordinates{i}(:,3), ImageCoordinates{i}(:,4), 0, 'LineWidth', 2);axis equal;hold on;

    % 根据误差量大小做好color bar颜色渐变对应
    % 可以参考之前OMDPS点云配准模块的颜色显示代码
    quivercolor2(ImageCoordinates{i}, ImageCoordinates{i}(:,3), ImageCoordinates{i}(:,4),sorted_Data_Fisheye_Imgpoints_ALL{i});

    % 设置 x 轴范围
    xlim([-(CMOSsize(1))/2, (CMOSsize(1))/2]);
    % 设置 y 轴范围
    ylim([-(CMOSsize(2)/2), (CMOSsize(2))/2]);
    % 添加图例
    legend('Coded Targets', 'Error arrow','FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'bold');
    % 标题和轴标签
    title(['Coded targets reprojection error|image ', num2str(i)],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    xlabel('X (mm)','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    ylabel('Y (mm)','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    set(gca, 'FontSize', FontSize);
    
end



%% 自动存图

% % 保存每个图像为 .jpg 格式
% for p = 1:numel(findall(0,'type','figure'))
%     % 通过 figure(i) 激活第 i 个图像
%     figure(p);
% 
%     % 设置保存路径和文件名，注意使用不同的文件名或路径以防止覆盖
%     save_path = 'C:\Users\Thunder\Desktop\wide_angle_reasearch\programming\waide_angle_matlab_GN_calibration_Simulation\pics\';
%     file_name = ['figure', num2str(p), '.jpg'];
% 
%     % 使用 saveas 函数保存图像为 PNG 格式
%     saveas(gcf, [save_path, file_name]);
% end





