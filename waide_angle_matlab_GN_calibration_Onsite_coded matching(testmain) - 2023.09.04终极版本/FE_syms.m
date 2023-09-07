clc; clear; close all;
syms  f x0 y0 k1 k2 k3 p1 p2 b1 b2 x y X_w Y_w Z_w phiz phiy phix Tx Ty Tz

            Rz=[ cos(phiz), sin(phiz), 0
                -sin(phiz), cos(phiz), 0
                      0     ,      0      , 1];
            % 绕X轴顺时针旋转phix角
            Rx=[1,      0     ,      0
                0, cos(phix), sin(phix)
                0, -sin(phix), cos(phix)];
            % 绕Y轴顺时针旋转phiy角
            Ry=[ cos(phiy), 0 ,-sin(phiy)
                     0       , 1 ,     0
                 sin(phiy), 0 , cos(phiy)];
            R=Rz*Rx*Ry;
            X_c = R(1, :)*([X_w; Y_w; Z_w]-[Tx; Ty; Tz]);
            Y_c = R(2, :)*([X_w; Y_w; Z_w]-[Tx; Ty; Tz]);
            Z_c = R(3, :)*([X_w; Y_w; Z_w]-[Tx; Ty; Tz]);
            % 获取畸变方程
            x_int = x - x0;
            y_int = y - y0;
            r = x_int^2 + y_int^2;
            
            x_distortion = x_int*(k1*r+k2*r^2+k3*r^3)+p1*(2*x_int^2+r)+2*p2*x_int*y_int+b1*x_int+b2*y_int;  
            y_distortion = y_int*(k1*r+k2*r^2+k3*r^3)+p2*(2*y_int^2+r)+2*p1*x_int*y_int; 
            %计算入射角
            theta = atan(sqrt(X_c^2 + Y_c^2)/Z_c);
            %鱼眼共线方程
            fx = x0 - x_distortion -f*theta*(X_c/(sqrt(X_c^2 + Y_c^2)));
            fy = y0 - y_distortion -f*theta*(Y_c/(sqrt(X_c^2 + Y_c^2)));


            jx1 = diff(fx,f)
            jx2 = diff(fx,x0)
            jx3 = diff(fx,y0)
            jx4 = diff(fx,k1)
            jx5 = diff(fx,k2)
            jx6 = diff(fx,k3)
            jx7 = diff(fx,p1)
            jx8 = diff(fx,p2)
            jx9 = diff(fx,b1)
            jx10 = diff(fx,b2)
            jx11 = diff(fx,phiz)
            jx12 = diff(fx,phix)
            jx13 = diff(fx,phiy)
            jx14 = diff(fx,Tx)
            jx15 = diff(fx,Ty)
            jx16 = diff(fx,Tz)
            
            jy1 = diff(fy,f)
            jy2 = diff(fy,x0)
            jy3 = diff(fy,y0)
            jy4 = diff(fy,k1)
            jy5 = diff(fy,k2)
            jy6 = diff(fy,k3)
            jy7 = diff(fy,p1)
            jy8 = diff(fy,p2)
            jy9 = diff(fy,b1)
            jy10 = diff(fy,b2)
            jy11 = diff(fy,phiz)
            jy12 = diff(fy,phix)
            jy13 = diff(fy,phiy)
            jy14 = diff(fy,Tx)
            jy15 = diff(fy,Ty)
            jy16 = diff(fy,Tz)
            
            JX = [jx1;jx2;jx3;jx4;jx5;jx6;jx7;jx8;jx9;jx10;jx11;jx12;jx13;jx14;jx15;jx16];
            JY = [jy1;jy2;jy3;jy4;jy5;jy6;jy7;jy8;jy9;jy10;jy11;jy12;jy13;jy14;jy15;jy16];
            XX = eval(JX);
            YY = eval(JY);
            
           