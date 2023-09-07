function[J, V, loop, AllParam,Data2] = GN_mode_y(ImageCoordinates,WorldCoordinates,InitialAllParam)  
% 假设我们有 n 个站位，每个站位包含 m 个特征点
% n = 3;
% m = 10;

% 代入已知每个站位的图像坐标和世界坐标
Image_Coordinates = ImageCoordinates;   % cell(1,n) 每个cell里（m，2）
World_Coordinates = WorldCoordinates;         % cell(1,n) 每个cell里（m，3）
[~,n] = size(ImageCoordinates);

% 代入已知相机初始内参数畸变参数和初始外参数
AllParam = InitialAllParam;   %[f, x0, y0, k1, k2, k3, p1, p2, b1, b2 , phiz1,phix1,phiy1,Tx1,Ty1,Tz1,phiz2,phix2......]  
                              %！！！phiz，phix，phiy 必须为弧度值！！！
%% 构建雅克比矩阵
rowJ = 0;
% 寻找雅克比矩阵的总行数
for i = 1:n
    
    [tem,~] = size(Image_Coordinates{1,i});
    rowJ = tem + rowJ;
    
end
J_row = 2 * rowJ; J_col = 10 + 6 * n;
% J = zeros(J_row, J_col); % 雅克比矩阵的大小
V = zeros(J_row, 1);     % 残差矩阵

%% 迭代循环
loop = 0;       % 迭代次数
loopMax = 2000;  % 最多迭代次数
change = 20; 
lastm_all = 0;  % 记录当前特征点之前点的总数
alpha = 1;
while loop < loopMax && change > 2*10^-11 %判断左右均成立往下执行
    loop = loop + 1;
    
        % 获取当前新的内参数
        f = AllParam(1);
        x0 = AllParam(2);
        y0 = AllParam(3);
        k1 = AllParam(4);
        k2 = AllParam(5);
        k3 = AllParam(6);
        p1 = AllParam(7);
        p2 = AllParam(8);
        
        b1 = AllParam(9);
        b2 = AllParam(10);
        lastm_all = 0;
        J = zeros(J_row, J_col); % 雅克比矩阵的大小
        V = zeros(J_row, 1);     % 残差矩阵
        % 遍历每个站位
    for i = 1:n
        % 获取当前站位的图像坐标和世界坐标
        image_coords = Image_Coordinates{1,i};
        world_coords = World_Coordinates{1,i};
       
        % 获取当前站位的外参
        phiz = AllParam(6*(i-1)+11); phix = AllParam(6*(i-1)+12); phiy = AllParam(6*(i-1)+13);
        Tx = AllParam(6*(i-1)+14); Ty = AllParam(6*(i-1)+15); Tz = AllParam(6*(i-1)+16);
        R = R_generate_rad(phiz,phix,phiy);
        % 获取每张图的点数
        [m,~] = size(image_coords);
        % 遍历每个特征点
        for j = 1:m
            % 获取当前特征点的图像坐标和世界坐标
            x = image_coords(j, 1);
            y = image_coords(j, 2);
            X_w = world_coords(j, 1);
            Y_w = world_coords(j, 2);
            Z_w = world_coords(j, 3);
            % 获取当前相机坐标
            X_c = R(1, :)*([X_w; Y_w; Z_w]-[Tx; Ty; Tz]);
            Y_c = R(2, :)*([X_w; Y_w; Z_w]-[Tx; Ty; Tz]);
            Z_c = R(3, :)*([X_w; Y_w; Z_w]-[Tx; Ty; Tz]);
            % 获取畸变方程
            x_int = x - x0;
            y_int = y - y0;
            r = x_int^2 + y_int^2;
            x_distortion = x_int*(k1*r+k2*r^2+k3*r^3)+p1*(2*x_int^2+r)+2*p2*x_int*y_int+b1*x_int+b2*y_int;  
            y_distortion = y_int*(k1*r+k2*r^2+k3*r^3)+p2*(2*y_int^2+r)+2*p1*x_int*y_int; 
            % %计算入射角
            % theta = atan(sqrt(X_c^2 + Y_c^2)/Z_c);
            %鱼眼共线方程
            fx = x0 - x_distortion -f*(X_c/Z_c);
            fy = y0 - y_distortion -f*(Y_c/Z_c);
            % 计算当前特征点的残差
            V(2*lastm_all + j*2-1,:) = x-fx;
            V(2*lastm_all + j*2,:)   = y-fy;
            % 计算雅克比矩阵
            jx1 = -((Tx - X_w)*(cos(phiy)*cos(phiz) + sin(phix)*sin(phiy)*sin(phiz)) - (Tz - Z_w)*(cos(phiz)*sin(phiy) - cos(phiy)*sin(phix)*sin(phiz)) + cos(phix)*sin(phiz)*(Ty - Y_w))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w));
            jx2 = b1 + k1*((x - x0)^2 + (y - y0)^2) + (x - x0)*(k1*(2*x - 2*x0) + 2*k2*(2*x - 2*x0)*((x - x0)^2 + (y - y0)^2) + 3*k3*(2*x - 2*x0)*((x - x0)^2 + (y - y0)^2)^2) + 2*p2*(y - y0) + k2*((x - x0)^2 + (y - y0)^2)^2 + k3*((x - x0)^2 + (y - y0)^2)^3 + p1*(6*x - 6*x0) + 1;
            jx3 = b2 + (x - x0)*(k1*(2*y - 2*y0) + 2*k2*(2*y - 2*y0)*((x - x0)^2 + (y - y0)^2) + 3*k3*(2*y - 2*y0)*((x - x0)^2 + (y - y0)^2)^2) + 2*p2*(x - x0) + p1*(2*y - 2*y0);
            jx4 = -((x - x0)^2 + (y - y0)^2)*(x - x0);
            jx5 = -((x - x0)^2 + (y - y0)^2)^2*(x - x0);
            jx6 = -((x - x0)^2 + (y - y0)^2)^3*(x - x0);
            jx7 = - 3*(x - x0)^2 - (y - y0)^2;
            jx8 = -2*(x - x0)*(y - y0);
            jx9 = x0 - x;
            jx10 = y0 - y;
            jx11 = -(f*((Tz - Z_w)*(sin(phiy)*sin(phiz) + cos(phiy)*cos(phiz)*sin(phix)) - (Tx - X_w)*(cos(phiy)*sin(phiz) - cos(phiz)*sin(phix)*sin(phiy)) + cos(phix)*cos(phiz)*(Ty - Y_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w));
            jx12 = - (f*(cos(phix)*cos(phiy)*sin(phiz)*(Tz - Z_w) - sin(phix)*sin(phiz)*(Ty - Y_w) + cos(phix)*sin(phiy)*sin(phiz)*(Tx - X_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w)) - (f*(cos(phix)*(Ty - Y_w) + cos(phiy)*sin(phix)*(Tz - Z_w) + sin(phix)*sin(phiy)*(Tx - X_w))*((Tx - X_w)*(cos(phiy)*cos(phiz) + sin(phix)*sin(phiy)*sin(phiz)) - (Tz - Z_w)*(cos(phiz)*sin(phiy) - cos(phiy)*sin(phix)*sin(phiz)) + cos(phix)*sin(phiz)*(Ty - Y_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w))^2;
            jx13 = (f*((Tx - X_w)*(cos(phiz)*sin(phiy) - cos(phiy)*sin(phix)*sin(phiz)) + (Tz - Z_w)*(cos(phiy)*cos(phiz) + sin(phix)*sin(phiy)*sin(phiz))))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w)) + (f*(cos(phix)*cos(phiy)*(Tx - X_w) - cos(phix)*sin(phiy)*(Tz - Z_w))*((Tx - X_w)*(cos(phiy)*cos(phiz) + sin(phix)*sin(phiy)*sin(phiz)) - (Tz - Z_w)*(cos(phiz)*sin(phiy) - cos(phiy)*sin(phix)*sin(phiz)) + cos(phix)*sin(phiz)*(Ty - Y_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w))^2;
            jx14 = (f*cos(phix)*sin(phiy)*((Tx - X_w)*(cos(phiy)*cos(phiz) + sin(phix)*sin(phiy)*sin(phiz)) - (Tz - Z_w)*(cos(phiz)*sin(phiy) - cos(phiy)*sin(phix)*sin(phiz)) + cos(phix)*sin(phiz)*(Ty - Y_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w))^2 - (f*(cos(phiy)*cos(phiz) + sin(phix)*sin(phiy)*sin(phiz)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w));
            jx15 = - (f*sin(phix)*((Tx - X_w)*(cos(phiy)*cos(phiz) + sin(phix)*sin(phiy)*sin(phiz)) - (Tz - Z_w)*(cos(phiz)*sin(phiy) - cos(phiy)*sin(phix)*sin(phiz)) + cos(phix)*sin(phiz)*(Ty - Y_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w))^2 - (f*cos(phix)*sin(phiz))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w));
            jx16 = (f*(cos(phiz)*sin(phiy) - cos(phiy)*sin(phix)*sin(phiz)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w)) + (f*cos(phix)*cos(phiy)*((Tx - X_w)*(cos(phiy)*cos(phiz) + sin(phix)*sin(phiy)*sin(phiz)) - (Tz - Z_w)*(cos(phiz)*sin(phiy) - cos(phiy)*sin(phix)*sin(phiz)) + cos(phix)*sin(phiz)*(Ty - Y_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w))^2;

            jy1 = -((Tz - Z_w)*(sin(phiy)*sin(phiz) + cos(phiy)*cos(phiz)*sin(phix)) - (Tx - X_w)*(cos(phiy)*sin(phiz) - cos(phiz)*sin(phix)*sin(phiy)) + cos(phix)*cos(phiz)*(Ty - Y_w))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w));
            jy2 = (y - y0)*(k1*(2*x - 2*x0) + 2*k2*(2*x - 2*x0)*((x - x0)^2 + (y - y0)^2) + 3*k3*(2*x - 2*x0)*((x - x0)^2 + (y - y0)^2)^2) + 2*p1*(y - y0) + p2*(2*x - 2*x0);
            jy3 = k1*((x - x0)^2 + (y - y0)^2) + (y - y0)*(k1*(2*y - 2*y0) + 2*k2*(2*y - 2*y0)*((x - x0)^2 + (y - y0)^2) + 3*k3*(2*y - 2*y0)*((x - x0)^2 + (y - y0)^2)^2) + 2*p1*(x - x0) + k2*((x - x0)^2 + (y - y0)^2)^2 + k3*((x - x0)^2 + (y - y0)^2)^3 + p2*(6*y - 6*y0) + 1;
            jy4 = -((x - x0)^2 + (y - y0)^2)*(y - y0);
            jy5 = -((x - x0)^2 + (y - y0)^2)^2*(y - y0);
            jy6 = -((x - x0)^2 + (y - y0)^2)^3*(y - y0);
            jy7 = -2*(x - x0)*(y - y0);
            jy8 = - (x - x0)^2 - 3*(y - y0)^2;
            jy9 = 0;
            jy10 =0;
            jy11 = (f*((Tx - X_w)*(cos(phiy)*cos(phiz) + sin(phix)*sin(phiy)*sin(phiz)) - (Tz - Z_w)*(cos(phiz)*sin(phiy) - cos(phiy)*sin(phix)*sin(phiz)) + cos(phix)*sin(phiz)*(Ty - Y_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w));
            jy12 = - (f*(cos(phix)*cos(phiy)*cos(phiz)*(Tz - Z_w) - cos(phiz)*sin(phix)*(Ty - Y_w) + cos(phix)*cos(phiz)*sin(phiy)*(Tx - X_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w)) - (f*(cos(phix)*(Ty - Y_w) + cos(phiy)*sin(phix)*(Tz - Z_w) + sin(phix)*sin(phiy)*(Tx - X_w))*((Tz - Z_w)*(sin(phiy)*sin(phiz) + cos(phiy)*cos(phiz)*sin(phix)) - (Tx - X_w)*(cos(phiy)*sin(phiz) - cos(phiz)*sin(phix)*sin(phiy)) + cos(phix)*cos(phiz)*(Ty - Y_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w))^2;
            jy13 = (f*(cos(phix)*cos(phiy)*(Tx - X_w) - cos(phix)*sin(phiy)*(Tz - Z_w))*((Tz - Z_w)*(sin(phiy)*sin(phiz) + cos(phiy)*cos(phiz)*sin(phix)) - (Tx - X_w)*(cos(phiy)*sin(phiz) - cos(phiz)*sin(phix)*sin(phiy)) + cos(phix)*cos(phiz)*(Ty - Y_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w))^2 - (f*((Tx - X_w)*(sin(phiy)*sin(phiz) + cos(phiy)*cos(phiz)*sin(phix)) + (Tz - Z_w)*(cos(phiy)*sin(phiz) - cos(phiz)*sin(phix)*sin(phiy))))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w));
            jy14 = (f*(cos(phiy)*sin(phiz) - cos(phiz)*sin(phix)*sin(phiy)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w)) + (f*cos(phix)*sin(phiy)*((Tz - Z_w)*(sin(phiy)*sin(phiz) + cos(phiy)*cos(phiz)*sin(phix)) - (Tx - X_w)*(cos(phiy)*sin(phiz) - cos(phiz)*sin(phix)*sin(phiy)) + cos(phix)*cos(phiz)*(Ty - Y_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w))^2;
            jy15 = - (f*sin(phix)*((Tz - Z_w)*(sin(phiy)*sin(phiz) + cos(phiy)*cos(phiz)*sin(phix)) - (Tx - X_w)*(cos(phiy)*sin(phiz) - cos(phiz)*sin(phix)*sin(phiy)) + cos(phix)*cos(phiz)*(Ty - Y_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w))^2 - (f*cos(phix)*cos(phiz))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w));
            jy16 = (f*cos(phix)*cos(phiy)*((Tz - Z_w)*(sin(phiy)*sin(phiz) + cos(phiy)*cos(phiz)*sin(phix)) - (Tx - X_w)*(cos(phiy)*sin(phiz) - cos(phiz)*sin(phix)*sin(phiy)) + cos(phix)*cos(phiz)*(Ty - Y_w)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w))^2 - (f*(sin(phiy)*sin(phiz) + cos(phiy)*cos(phiz)*sin(phix)))/(cos(phix)*cos(phiy)*(Tz - Z_w) - sin(phix)*(Ty - Y_w) + cos(phix)*sin(phiy)*(Tx - X_w));

            % fx对内外参求导写入J
            J(2*lastm_all + j*2-1,1:10) = [jx1 jx2 jx3 jx4 jx5 jx6 jx7 jx8 jx9 jx10];
            J(2*lastm_all + j*2-1,(11+6*(i-1)):(11+6*(i-1)+5)) = [jx11 jx12 jx13 jx14 jx15 jx16];
            % fy对内外参求导写入J
            J(2*lastm_all + j*2,1:10) = [jy1 jy2 jy3 jy4 jy5 jy6 jy7 jy8 jy9 jy10];
            J(2*lastm_all + j*2,11+6*(i-1):11+6*(i-1)+5) = [jy11 jy12 jy13 jy14 jy15 jy16];
        
%                         if rank(J'*J) == 10      %验证代入多少点时秩为多少
%                             KKKKK = size(J);
%                         end
            
        end
        lastm_all = lastm_all + m;
        
        
    end
    
    for i = 1:J_col
        A(1,i)=norm(J(:,i));    %求每列二范数
    end
    A=repmat(A,J_row,1);            %平铺生成点除要用的二范数矩阵
    Jguiyi=J./A;                %A./B表示A矩阵与B矩阵对应元素相除，所以要求A，B行数列数相等%相当于J右乘A（对角矩阵）的逆
    Aduijiao = diag(A(1,:),0);  %生成二范数矩阵的对角阵,用于Delta还原的公式推导
    A=[];
    Delta_E = inv(Jguiyi'* Jguiyi)*Jguiyi'* V;
    Delta_L= inv(Aduijiao)*Delta_E;
    AllParam = AllParam + alpha*Delta_L';
    change = norm(Delta_L');
    
    %% 数据统计
    Data4(loop) = change;
    Data3{loop} = AllParam;
    Data2{loop} = Delta_L;
    Data1{loop} = V;

end
% % 计算参数的更新步长 delta_x
% delta_x = -J \ V;
% 
% % 更新相机内参数和外参数
% delta_K = delta_x(1:3);
% delta_R = delta_x(4:6);
% delta_t = delta_x(7:end);
% 
% InParam = InParam + delta_K';
% R = expm(skew_symmetric(delta_R')) * R;
% T = T + delta_t;


end