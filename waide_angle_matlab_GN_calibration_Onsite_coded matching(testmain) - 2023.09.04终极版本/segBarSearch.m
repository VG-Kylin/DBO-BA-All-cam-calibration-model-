%%%segBarSearch
% ratioDesign1310 = norm(barDesign(1, :) - barDesign(3, :))/norm(barDesign(1, :) - barDesign(6, :));
ratioDesign1310 = sqrt((barDesign(1, 1) - barDesign(3, 1))^2 + (barDesign(1, 2) - barDesign(3, 2))^2 + (barDesign(1, 3) - barDesign(3, 3))^2)/...
    sqrt((barDesign(1, 1) - barDesign(6, 1))^2 + (barDesign(1, 2) - barDesign(6, 2))^2 + (barDesign(1, 3) - barDesign(6, 3))^2);
errorSquare = 200; bar2D = [];
% ratioDesign131Mid = norm(barDesign(1, :) - barDesign(3, :))/(barDesign(2, 3));
ratioDesign131Mid = sqrt((barDesign(1, 1) - barDesign(3, 1))^2 + (barDesign(1, 2) - barDesign(3, 2))^2 + (barDesign(1, 3) - barDesign(3, 3))^2)/(barDesign(2, 3));

for iRing = 1 : numRing
    O = posRing(iRing, 1:3); searchRadi = barSearchRadi(iRing, 1);
    indexIRing = posRing(iRing, 1);
    barCluster = []; numBarCluster = 0; disThr = disThrFactor * searchRadi;
    %%%�ӵ㼯��Ѱ�Ұе��
    for iPoint = 1 : nCenter
        if iPoint ~= indexIRing
            crdIPoint = center_mm(iPoint, 1:3);
%             disO2iPoint = norm(O(2:3) - crdIPoint(2:3));
            disO2iPoint = sqrt((O(2) - crdIPoint(2))^2 + (O(3) - crdIPoint(3))^2);
            if disO2iPoint < searchRadi
                barCluster = [barCluster; crdIPoint];
                numBarCluster = numBarCluster + 1;
            end
        end
    end
    if numBarCluster < 5 | numBarCluster > 30
        continue;
    end
    
%     figure(1); plot(barCluster(:, 2), barCluster(:, 3), 'b+'), hold on;
    
    coLine = 0; balance = 0; crossBalance = 0;
    for i = 1 : numBarCluster
        for j = 1 : numBarCluster
            if i ~= j
                %%%%�ҵ�1,3���㣬�ж�׼��ͬO�㹲���зֲ���O���⣬���㳤�ȱ�����ϵ
                iCluster = barCluster(i, 1:3); jCluster = barCluster(j, 1:3);
                vectorIJ = jCluster(2:3) - iCluster(2:3);
                vectorIO = O(2:3) - iCluster(2:3);
%                 angleVectorIJ = acos(vectorIO*vectorIJ'/(norm(vectorIO)*norm(vectorIJ)));
                angleVectorIJ = acos(vectorIO*vectorIJ'/(sqrt(vectorIO(1)^2 + vectorIO(2)^2)*sqrt(vectorIJ(1)^2 + vectorIJ(2)^2)));
                coLine = (angleVectorIJ) < angleThr;
                if coLine > 0
%                     ratioVectorIJIO = norm(vectorIJ)/norm(vectorIO);
                    ratioVectorIJIO = sqrt(vectorIJ(1)^2 + vectorIJ(2)^2)/sqrt(vectorIO(1)^2 + vectorIO(2)^2);
                    balance = abs(ratioVectorIJIO - ratioDesign1310) < scaleThresh;
                end
                %%%ȷ��2,4���㣬�ж�׼��2,4������IO�ϣ��ҳ������������ϵ
                if balance > 0
                    K = [iCluster(2) 1; jCluster(2) 1]; U = [iCluster(3); jCluster(3)];
                    dk = inv(K'*K)*K'*U; lineIJ = [dk(1) -1 dk(2)];
                    for m = 1 : numBarCluster
                        for n = 1 : numBarCluster
                            if (m~=i) && (m~=j) && (n~=i) && (n~=j) &&(m~=n)
                                mCluster = barCluster(m, 1:3); nCluster = barCluster(n, 1:3);
                                midMN = (mCluster(2:3) + nCluster(2:3))/2;
%                                 disMid2LineIJ = abs(midMN(1)*lineIJ(1)+midMN(2)*lineIJ(2)+lineIJ(3))...
%                                     /sqrt(lineIJ(1)^2+lineIJ(2)^2);
%%%%%�ж�mCluster nCluster������IO�ϣ��������������ϵ
%                                 vectorMidO = O(2:3) - midMN; vectorMidI = iCluster(2:3) - midMN;
                                vectorMidO = jCluster(2:3) - midMN; vectorMidI = iCluster(2:3) - midMN;
%                                 angleVectorOMidI = acos(vectorMidO*vectorMidI'/(norm(vectorMidO)*norm(vectorMidI)));
                                angleVectorOMidI = acos(vectorMidO*vectorMidI'/(sqrt(vectorMidO(1)^2 + vectorMidO(2)^2)...
                                    *sqrt(vectorMidI(1)^2+vectorMidI(2)^2)));
                                
%                                 if disMid2LineIJ < disThr
                                if abs(pi-angleVectorOMidI) < angleThr
                                    vectorIMid = midMN - iCluster(2:3);
%                                     ratioIMidIJ = norm(vectorIJ)/norm(vectorIMid);
                                    ratioIMidIJ = sqrt(vectorIJ(1)^2 + vectorIJ(2)^2)/sqrt(vectorIMid(1)^2 + vectorIMid(2)^2);
                                    crossBalance = abs(ratioIMidIJ - ratioDesign131Mid) < scaleThresh;
                                end
                                if crossBalance > 0
                                    %%%%2,4�������
                                    vectorIM = mCluster(2:3) - iCluster(2:3); vectorIN = nCluster(2:3) - iCluster(2:3);
                                    crossIMIN = cross([vectorIM 0], [vectorIN 0]);
                                    if crossIMIN(3) > 0
                                        bar42D = mCluster; bar22D = nCluster;
                                    else
                                        bar42D = nCluster; bar22D = mCluster;
                                    end
                                    %%%%%���з���任�������ƽ���ͣ���Ϊ���ۣ�����ȷ�������
                                    coPlane3D = barDesign([1; 2; 3; 4; 6], 2:3);
                                    coPlane2D = [iCluster(2:3); bar22D(2:3); jCluster(2:3); bar42D(2:3); O(2:3)];
                                    [A, T, error] = FunAffine(coPlane3D, coPlane2D);
                                    if error < errorSquare && error < disThr^2*2*5
                                        errorSquare = error;
                                        %%%%��5��
                                        bar53D = barDesign(5, 2:3)';
                                        bar52DAffine = (A * bar53D + T)';
                                        DeviationBar52D = 200;
                                        for k = 1 : numBarCluster
                                            if k~=i && k~=j && k~=m && k~=n
                                                kCluster = barCluster(k, 1:3);
%                                                 deviation = norm(bar52DAffine - kCluster(2:3));
                                                deviation = sqrt((bar52DAffine(1)-kCluster(2))^2 + (bar52DAffine(2)-kCluster(3))^2);
                                                if deviation < DeviationBar52D
                                                    DeviationBar52D = deviation;
                                                    bar52D = kCluster;
                                                    bar2D = [iCluster; bar22D; jCluster; bar42D; bar52D; O];
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
            
end