function [BasePoint] = FunBasePoint(sub)
v = 0;
numSub = size(sub, 1);
BasePoint = [];
for iSub = 1 : numSub
    O = sub(iSub, :);
    for indi = 1 : numSub-2
        for indj = indi+1 : numSub-1
            subWithoutO = sub;
            subWithoutO(iSub, :) = [];
            vi = subWithoutO(indi, 2:3) - O(1, 2:3);
            vj = subWithoutO(indj, 2:3) - O(1, 2:3);
            angle = acos(vi*vj'/(norm(vi)*norm(vj)));
            if angle < 5/180*pi
                if norm(vi) > norm(vj)
                    D = subWithoutO(indi, :);
                    C = subWithoutO(indj, :);
                elseif norm(vi) < norm(vj)
                    C = subWithoutO(indi, :);
                    D = subWithoutO(indj, :);
                else
                    continue;
                end
                
                middle_OD = 1/2 * (O(1, 2:3) + D(1, 2:3));
                if norm(C(1, 2:3) - D(1, 2:3)) <= norm(O(1, 2:3) - C(1, 2:3))
                    continue;
                end
%%从剩余五点找另外两个基础点                
                subWithoutO([indi indj], :) = [];
                for iH = 1 : numSub-3
                    disOH(iH, 1) = norm(O(1, 2:3) - subWithoutO(iH, 2:3));
                end
                disOH_sort = sort(disOH);
                indH1 = find(disOH == disOH_sort(1));
                indH2 = find(disOH == disOH_sort(2));
                H1 = subWithoutO(indH1, :);
                H2 = subWithoutO(indH2, :);
                %% OD和H1H2直线参数
                k_OD = (D(3) - O(3))/(D(2) - O(2));
                b_OD = O(3) - k_OD * O(2);
                k_H1H2 = (H1(3) - H2(3))/(H1(2) - H2(2));
                b_H1H2 = H1(3) - k_H1H2 * H1(2);
                its_x = (b_OD-b_H1H2)/(k_H1H2-k_OD);
                its_y = k_OD * its_x + b_OD;
                B = [its_x its_y];
                if norm(H1(1, 2:3)-H2(1, 2:3)) <= max([norm(B-H1(1, 2:3)) norm(B-H2(1, 2:3))])
                    continue;
                end
                %% 通过平行度判断是否是H1H2
                v_H1O = (O(1, 2:3) - H1(1, 2:3))/norm(O(1, 2:3) - H1(1, 2:3));
                v_CH2 = (H2(1, 2:3) - C(1, 2:3))/norm(H2(1, 2:3) - C(1, 2:3));
                angle_H1OCH2 = acos(v_H1O * v_CH2');
                v_H1C = (C(1, 2:3) - H1(1, 2:3))/norm(C(1, 2:3) - H1(1, 2:3));
                v_OH2 = (H2(1, 2:3) - O(1, 2:3))/norm(H2(1, 2:3) - O(1, 2:3));
                angle_H1COH2 = acos(v_H1C * v_OH2');
                angle = sqrt(angle_H1OCH2^2 + angle_H1COH2^2);
                if angle > 13/180*pi
                    continue;
                end
                
                v_OD = D(1, 2:3) - O(1, 2:3);
                v_OH1 = H1(1, 2:3) - O(1, 2:3);
                v_OH2 = H2(1, 2:3) - O(1, 2:3);
%%通过叉乘符号判断H1H2的位置关系                
                a = cross([v_OD 0], [v_OH1 0]);
                b = cross([v_OD 0], [v_OH2 0]);
                if a(3) * b(3) >= 0
                    continue;
                end
                if a(3) < 0
                    temp = H2;
                    H2 = H1;
                    H1 = temp;
                end
                v = v + 1;
                subWithoutO([indH1; indH2], :) = [];
                BasePoint(v, 1).BasePoint = [O; C; D; H1; H2];
                BasePoint(v, 1).LinearOCD = angle;
                BasePoint(v, 1).CodePoint = subWithoutO;
                BasePoint(v, 1).Center = C;
            end
        end
    end
end

%%%张倩倩的共线条件判断
% [nBasePoint, n] = size(BasePoint);
% LinearIndexSeries = zeros(nBasePoint, 1);
% LinearIndex = 0;
% for iBasePoint = 1 : nBasePoint-1
%     for jBasePoint = iBasePoint+1 : nBasePoint
%         if BasePoint(iBasePoint).LinearOCD - BasePoint(jBasePoint).LinearOCD > 1.5/180*pi
%             LinearIndexSeries(iBasePoint) = 1;
%         elseif BasePoint(jBasePoint).LinearOCD - BasePoint(iBasePoint).LinearOCD > 1.5/180*pi
%             LinearIndexSeries(jBasePoint) = 1;
%         else
%             LinearIndexSeries(iBasePoint) = 1;
%             LinearIndexSeries(jBasePoint) = 1;
%         end
%     end
% end


