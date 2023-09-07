clc; clear; close all

%% ʵ������������㼰�������ֵ����

%--------------------��Ԫ�ߴ�----------------------
%HIKVISION
pixSize = 0.00345;
%D300  D2x
% pixSize = 0.006;
% CMOSsize=[25.728 17.088];
%D810
% pixSize = 0.004878;
%��
% pixSize = 0.004521;
%AVT
% pixSize = 0.0074;

% CMOSsize=[36 24];
CMOSsize=[8.4456 7.0656];
%-------------------------------------------------


maxPixThresh = 5; ErrorIdx = 0;
ifComp = 0; compTemp40 = []; compTemp35 = [];
initInParam = load('IntrinsicParameters_V12mm.txt');%f�ǵ�����ֵ
%%%ͼ������ز���
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
%ͼ������ȡ�عⷴ������� _bwconncomp
[pointStructure, numCodeAll] = FunPicPointCentroid_bwconncomp(imgFileNames,...
    numImg, bwThreshold, minSpotSize, maxSpotSize, pixSize, barDesign, 0, ifComp, compTemp40, initInParam);
save pointStructure.mat;

load pointStructure.mat;
%% ��ͼ��������ʶ����ȡ���
% ÿ��ͼ�ֱ��ͼ��ÿ��ͼ�Բ�ͬ���͵ĵ������ɫ����
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
    % ���� x �᷶Χ
    xlim([-(CMOSsize(1))/2, (CMOSsize(1))/2]);
    
    % ���� y �᷶Χ
    ylim([-(CMOSsize(2)/2), (CMOSsize(2))/2]);
    % ���ͼ��
    % legend('Targets', 'Bar','Coded targets','FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'bold');
    % ��������ǩ
    title(['Measured targets image - ', num2str(i)],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    xlabel('X (mm)','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    ylabel('Y (mm)','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    set(gca, 'FontSize', FontSize);
end


%% ���������������ȡ
%--------------------------��ά�����ݼ���--------------------
control_field_alldata = readtable('..\DATA\Bundle2.txt');
%----------------------------------------------------------
[All_control_field_targets,control_field_targets,control_field_targets_Bar,control_field_targets_CODE,control_field_targets_Scale_Bar,control_field_targets_Targets,control_field_alldataall]=control_field_targets_drawing(control_field_alldata);%���Ƴ����ݷ��༰��ͼ�����շ���ȫ�����Ƴ���
[b,~]=size(control_field_targets_CODE);
numcode=(1:1:b);
CODE_targets_WC(:,2:4)=control_field_targets_CODE;
CODE_targets_WC(:,1)=numcode;



%% ����������ֵ������
Initial_value_all=[19;0;0;0;0;0;0;0;0;0]; %�ڲ���f,x0,y0,k1,k2,k3,p1,p2,b1,b2


% ����������ֵ������������
Data_Fisheye_Imgpoints_ALL=[];

for i=1:numImg
%-------------------------��������--------------------------
% [90,0,90]
Camposition=[Real_Fisheye_EXP_estimate{i}(1);Real_Fisheye_EXP_estimate{i}(2);Real_Fisheye_EXP_estimate{i}(3)];%x;y;z��ƽ������˳�� mm
%+++++++++++++++++++++++++++++++++++++�˴���Ҫ��VSTAR�Ƕ�Real_Fisheye_EXP_estimate(4:6,1)�Ķ���ת��Ϊ��Ӱ����ͨ��pwk
[Phi, Omegga, Kappa] = phgAz2Phi(Real_Fisheye_EXP_estimate{i}(4), Real_Fisheye_EXP_estimate{i}(5), Real_Fisheye_EXP_estimate{i}(6));%����ֵ���룬���������


Camorient=[Kappa;Omegga;-Phi];%z;x;y�ĽǶ�����˳�� deg%������ϵ��ת������Ҫͳһ
% Camorient=[Kappa;-Omegga;-Phi];%z;x;y�ĽǶ�����˳�� deg%������ϵ��ת������Ҫͳһ
Camorient=rad2deg(Camorient);

Camorientreal=Camorient;%z,x,y˳��% �����Camorient����Ϊ���滷������Ҫ�õĽǶ�ֵ����������ת������ΪR_generate�Դ�ת���ȹ���
Camorientreal=deg2rad(Camorientreal);%�����Ҫ��Ϊ��ֱֵ�Ӵ����Ż��㷨�У���Ϊ����������û����ƣ����Դ˴���ǰת��Ϊ�����Ƶ�λ�����Һ��������ݲ��ٴ���R_generate�����Ǵ���R_generate_rad

% ��ֵ����
% Initial_value_all ����ֵ��0.01 rad  λ��+5 mm

Initial_value_all = [Initial_value_all;Camorientreal+0;Camposition+0]; %ѭ�����ӣ�ͳ����ȫ��վλ������ڲ����������


end



%% ������������ֱ��ƥ��
% Real_Data_Fisheye_Imgpoints_coded{i}
% CODE_targets_WC

% ȫ��ʱ�̶�ʶ�𵽵ı������б���������
for i=1:numImg




    common_index = intersect(CODE_targets_WC(:,1),Real_Data_Fisheye_Imgpoints_coded{i}(:,1));
    CODE_targets_WC_matched = CODE_targets_WC(ismember(CODE_targets_WC(:,1), common_index), :);
    Real_Data_Fisheye_Imgpoints_coded_matched = Real_Data_Fisheye_Imgpoints_coded{i}(ismember(Real_Data_Fisheye_Imgpoints_coded{i}(:,1), common_index), :);
    sorted_Real_Data_Fisheye_Imgpoints_coded_matched = sortrows(Real_Data_Fisheye_Imgpoints_coded_matched, 1);


CODE_targets_WC_matched_all{i}=CODE_targets_WC_matched(:,2:4);
Data_Fisheye_Imgpoints_ALL{i}=sorted_Real_Data_Fisheye_Imgpoints_coded_matched(:,2:3);
sorted_Data_Fisheye_Imgpoints_ALL{i}=sorted_Real_Data_Fisheye_Imgpoints_coded_matched;
end





%% �궨�㷨
WorldCoordinates=CODE_targets_WC_matched_all;
ImageCoordinates=Data_Fisheye_Imgpoints_ALL;


Initial_value_all=Initial_value_all';
% [J, V, loop, AllParam,Delta_L_everyloop,V_everyloop,AllParam_everyloop]=muti_station_camera_calibration(ImageCoordinates,WorldCoordinates,Initial_value_all);

%% ��ͶӰģ��Ѱ��BA�궨�㷨

% E_best = 1000; %����һ���ܴ�ĳ�ʼ���
% eyes_best = 0;
% V_best = []; AllParam_best = [];
% for eyes = -1:0.1:1 % �����������ӣ�Ѱ����������ģ�ͣ��ɻ���Ѱ���㷨��
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
%     E = sqrt(sum(V.*V)/length(V)); %Ѱ����СRMS����Ӧ������ģ�͸��ֲ���
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

%% ����ʽ+p b mode test
% ����ʽ��p,b
%[x0, y0, k1, k2, k3, k4, k5, p1, p2, b1, b2 , phiz1,phix1,phiy1,Tx1,Ty1,Tz1,phiz2,phix2......]
[~,nn] = size(Initial_value_all);
tempp = zeros(1,nn+1);
tempp(1,12:end) = Initial_value_all(1,11:end);% �����������
tempp(1,1:2) = Initial_value_all(1,2:3);% ��������x0,y0
tempp(1,3:7) = 2;% k��ֵ��Ϊ1
tempp(1,8:9) = Initial_value_all(1,7:8);% ��������p1,p2
tempp(1,10:11) = Initial_value_all(1,9:10);% ��������b1,b2
Initial_value_all = tempp;
[J, V, loop, AllParam] = GN_mode4(ImageCoordinates,WorldCoordinates,Initial_value_all);




%% Magic model
%�����޳��۲����۾���
logical_index = abs(V) > 0.003;
% ʹ���߼�����ɾ������1����ֵ
V(logical_index) = [];


%% ���ͳ�Ƽ����ֲ����ӻ�
FontSize=12;
figure('Units', 'pixels', 'Position', [600, 600, 1000, 600])
% subplot(1,3,1);
h=histfit(V);

pd = fitdist(V,'Normal'); % ���������ߵĲ�������ֵ�ͱ�׼�r����Ҫ������������ᱨ������
sigma=pd.sigma;

mu=pd.mu;
sigma_pixel=pixSize/sigma;
% % ��Ӿ�ֵ�ͷ������ֵ
text(0.0003, 100, ['sigame = ', num2str(sigma),' mm'],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
text(0.0003, 200, ['mu = ', num2str(mu),' mm'],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
text(0.0003, 150, ['sigma pixel = 1/', num2str(sigma_pixel),' pixel'],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');

% ���ͼ��
legend('Error distribution', 'Normal distribution curve','FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'bold');

% ��������ǩ
title('Reprojection error distribution of all camera stations','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
xlabel('Error value','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
ylabel('Number of errors','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
set(gca, 'FontSize', FontSize);
%color
h(1).FaceColor = color51(12);
h(1).EdgeColor = color51(5);
h(2).Color = color51(37);

%% �������ֲ������ƿ��ӻ�
% ��������������ֵ���ͣ�˵��ϵͳ����С�����ֲ��ȽϷ�ɢ���Ҵ����϶࣬�������Ե��߱��ε��¶�λ���ȵͿ����йء������Ե��߶��ľ��ȵͣ�һ���ǹ�Դ��Ӧ����Ч��Χ��һ������״���쵼�¶��ľ��ȵ͡�
% �����õ��ǲ�����ĵ㣬����Դ�޹أ���֪���Ƿ��Ӱ�춨�ľ��ȡ�
% ��α�֤���۳����ص��£������Ȼ���Դﵽ�߾��ȶ��ģ��Ǹ����⡣
% ��Ҫ��һ���۲�����ֲ��Ƿ���������Χ���Ƿ���ڽ�������
% ԭʼȫ������������������ͳ�ƣ�1/5.0159 pixel ����
% ȥ������ʣ�ಿ�ֵ�Ĳ������ͳ�ƣ�������Ŀǰ�����۾��ȼ��ޣ��� 1/11 pixel ����
% ����ģ�͵����£�Ŀǰ����û�и���1/12 pixel��
% ��С��������㿴���Ƿ���Ա궨���������Ӧ����һ�����������Ե�ͨ������궨����
% ���ݼ�����������������vstar��������ǽ��
% �������õĳ���Ч���Ƿ��ܰ������۽��и��߾��ȵı궨��
% ���������۾�ͷ�����в��ԣ������Ƿ������������ͬ��kֵģ����ȥ����֤ģ�͵�³���Լ�������


% ��V���а�ͼ��xy�����ݷ�������
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
        ImageCoordinates{1,i}(j,3)=V_per_pic{1,i}(2*j-1,1);% ����������ImageCoordinates���������ö�Ӧ
        ImageCoordinates{1,i}(j,4)=V_per_pic{1,i}(2*j,1);
    end

end

% ��������㻭ͼ���ڻ����ϻ�����ͷ��������ʸ��ָ�򣬲�����10���Ŵ�

figure
FontSize=12;
for i=1:numImg
    subplot(a,a,i);
    plot(ImageCoordinates{i}(:,1),ImageCoordinates{i}(:,2),'ko',MarkerSize=10);axis equal;hold on;
    quiver(ImageCoordinates{i}(:,1), ImageCoordinates{i}(:,2), ImageCoordinates{i}(:,3), ImageCoordinates{i}(:,4), 0, 'LineWidth', 2);axis equal;hold on;

    % �����������С����color bar��ɫ�����Ӧ
    % ���Բο�֮ǰOMDPS������׼ģ�����ɫ��ʾ����
    quivercolor2(ImageCoordinates{i}, ImageCoordinates{i}(:,3), ImageCoordinates{i}(:,4),sorted_Data_Fisheye_Imgpoints_ALL{i});

    % ���� x �᷶Χ
    xlim([-(CMOSsize(1))/2, (CMOSsize(1))/2]);
    % ���� y �᷶Χ
    ylim([-(CMOSsize(2)/2), (CMOSsize(2))/2]);
    % ���ͼ��
    legend('Coded Targets', 'Error arrow','FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'bold');
    % ��������ǩ
    title(['Coded targets reprojection error|image ', num2str(i)],'FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    xlabel('X (mm)','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    ylabel('Y (mm)','FontName', 'Times New Roman', 'FontSize', FontSize, 'FontWeight', 'bold');
    set(gca, 'FontSize', FontSize);
    
end



%% �Զ���ͼ

% % ����ÿ��ͼ��Ϊ .jpg ��ʽ
% for p = 1:numel(findall(0,'type','figure'))
%     % ͨ�� figure(i) ����� i ��ͼ��
%     figure(p);
% 
%     % ���ñ���·�����ļ�����ע��ʹ�ò�ͬ���ļ�����·���Է�ֹ����
%     save_path = 'C:\Users\Thunder\Desktop\wide_angle_reasearch\programming\waide_angle_matlab_GN_calibration_Simulation\pics\';
%     file_name = ['figure', num2str(p), '.jpg'];
% 
%     % ʹ�� saveas ��������ͼ��Ϊ PNG ��ʽ
%     saveas(gcf, [save_path, file_name]);
% end





