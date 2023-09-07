pointStructure(iImg, 1).point;
nSubArea = 0; SubArea = [];
for iPoint = 1 : pointStructure(iImg, 1).numPoint
    nIncluded = 0; crdIncluded = []; indexIncluded = [];
    searchRadius = pointStructure(iImg, 1).point(iPoint, 5) * 6;
    crdIPoint = pointStructure(iImg, 1).point(iPoint, 2:3);
    
    for jPoint = 1 : pointStructure(iImg, 1).numPoint
        crdJPoint = pointStructure(iImg, 1).point(jPoint, 2:3);
%         disBTWij = norm(crdIPoint - crdJPoint);
        disBTWij = sqrt((crdIPoint(1) - crdJPoint(1))^2 + (crdIPoint(2) - crdJPoint(2))^2);
        if disBTWij < searchRadius
            nIncluded = nIncluded + 1;
            crdIncluded = [crdIncluded; pointStructure(iImg, 1).point(jPoint, 1:3)];
            indexIncluded = [indexIncluded; pointStructure(iImg, 1).point(jPoint, 1)];
        end
    end
    
    if nIncluded >= 8  && nIncluded <= 10
        nSubArea = nSubArea + 1;
        SubArea(nSubArea, 1).center = crdIPoint;
        SubArea(nSubArea, 1).pSurround = crdIncluded;
        SubArea(nSubArea, 1).indexNo = indexIncluded;
    end
end
%对得到的点组进行一定程度的精简，把精简后的结果标记出来，最后进行整合并再次检查是否有完全重合的情况。
%%%%%%%%%%%%%%%%new code detect test
% nPoint = pointStructure(iImg, 1).numPoint;
% crdPoint = pointStructure(iImg, 1).point(:, 2:3);
% idxPoint = pointStructure(iImg, 1).point(:, 1);
% figure,
% for iPoint = 1 : nPoint
%     plot(crdPoint(iPoint, 1), crdPoint(iPoint, 2), 'b.'); hold on;
%     h = text(crdPoint(iPoint, 1)+0.1, crdPoint(iPoint, 2), num2str(idxPoint(iPoint))); hold on;
%     set(h, 'FontSize', 5); hold on;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nSubArea > 0
    [Codes] = FunCodeRefine(SubArea);
else
    Codes = [];
end

%% 解码
CodeTemplate = load('CodeTemplate_2.txt');
CodeMap = load('Codemap_vstar240.txt');
nCodes = size(Codes, 1);
isNotCode = [];
index_code_inObj = [];
numCodePos = size(CodeTemplate, 1) - 5;
% figure(2);
for iCodes = 1 : nCodes
    CodePoints = Codes(iCodes).CodePoint;
    BasePoints = Codes(iCodes).BasePoint;
    numCodePoints = size(CodePoints, 1);
    I = ones(1, numCodePoints);
    %%仿射变换
    [affineA, affineT] = FunAffine(BasePoints(:, 2:3), CodeTemplate(1:5, :));
    CodePoints_affine = (affineA*CodePoints(:, 2:3)' + affineT*I)';
    %%张倩倩提出的内外框判断
    %%框内点数目，应为3
    nPin = 0; idxInArea = [];
    for i = 1 : numCodePoints
        x_iCode = CodePoints_affine(i, 1);
        y_iCode = CodePoints_affine(i, 2);
        InArea1 = 0;
        Inarea2 = 0;
        InArea1 = (x_iCode > -0.5 & x_iCode < 7.5 & y_iCode > 9.5 & y_iCode < 12.5);
        InArea2 = (y_iCode > -0.5 & y_iCode < 7.5 & x_iCode > 9.5 & x_iCode < 12.5);
        if InArea1+InArea2 == 1
            nPin = nPin + 1;
            idxInArea = [idxInArea; i];
        end
        %%满足内外框判据
    end
    if nPin ~= 3
        isNotCode = [isNotCode; iCodes];
        continue;
    end
    CodePoints_affine_inArea = CodePoints_affine(idxInArea, :);
    %%依据编码模板查找码值序列
    CodeSeries = zeros(numCodePos, 1); idxInAllPoints = [BasePoints(:, 1); CodePoints(idxInArea, 1)];
    %%三个编码点在整个序列中的编号，即是第几个编码点
    pos_in_code = [];
    for i = 1 : 3
        for jTmp = (5+1) : (5+numCodePos)
%             disI2jTmp(jTmp-5, 1) = norm(CodePoints_affine(i, :) - CodeTemplate(jTmp, :));
            disI2jTmp(jTmp-5, 1) = sqrt((CodePoints_affine_inArea(i, 1) - CodeTemplate(jTmp, 1))^2 + ...
                (CodePoints_affine_inArea(i, 2) - CodeTemplate(jTmp, 2))^2);
        end
        dis_sort = sort(disI2jTmp);
        index_min_dis = find(disI2jTmp == dis_sort(1));
        CodeSeries(index_min_dis) = 1;
        pos_in_code = [pos_in_code; index_min_dis+5];
    end
    if sum(CodeSeries) ~= 3
        isNotCode = [isNotCode; iCodes];
        continue;
    end
    decima = 0;
    for iSeries = 1 : numCodePos
        decima = decima + CodeSeries(iSeries)*2^(iSeries-1);
    end

%%%%%%%%%%%2016-07-11修改与vstars编码对应
    csInvert = CodeSeries(end:-1:1);
    csInvert0 = [csInvert; 0];
    csInvert0String = (num2str(csInvert0))';
    decima = bin2dec(csInvert0String);
    idxTemp = find(CodeMap(:, 2) == decima);
    codeValueVstars = CodeMap(idxTemp, 1);
    if size(codeValueVstars, 1) == 1
        %%%%%%%%%%%%%%
        Codes(iCodes).CodeValue = codeValueVstars;
        Codes(iCodes).PosInCode = pos_in_code;
        index_code_inObj = [index_code_inObj; idxInAllPoints];
        %     plot(BasePoints(:, 2), BasePoints(:, 3), 'yd'), hold on;
        %     plot(CodePoints(:, 2), CodePoints(:, 3), 'cx'), hold on;
    end
end

Codes(isNotCode, :) = []; nCodes = size(Codes, 1);
if nCodes<1
    return;
end

%% 检测是否有相同码值，如有，全部删除
nCodes = size(Codes, 1);
% % % % % 
TT = [];
for iCodes = 1 : nCodes
    TT = [TT; Codes(iCodes).CodeValue Codes(iCodes).Center];
end
% % % % % 

indexRepeat = []; idxValidCode = [];
for iCodes = 1 : nCodes
    iCodesValue = Codes(iCodes).CodeValue;
    iCodesCenter = Codes(iCodes).Center(1, 1);
    numSameValue = 0; numSameCenter = 0;
    arrSameValue = zeros(nCodes, 1); arrSameCenter = zeros(nCodes, 1);
    for jCodes = 1 : nCodes
        jCodesValue = Codes(jCodes).CodeValue;
        jCodesCenter = Codes(jCodes).Center(1, 1);
        if (jCodesValue == iCodesValue)
            numSameValue = numSameValue + 1;
            arrSameValue(jCodes, 1) = 1;
        end
        if (jCodesCenter == iCodesCenter)
             arrSameCenter(jCodes, 1) = 1;
        end
        
    end
    
    %%%%码值与位置对应性判断
    idxSymmetry = (arrSameValue == arrSameCenter);
    numSymmetry = sum(idxSymmetry);
    
    if (numSymmetry == nCodes)
        [temp, idx2Add] = max(arrSameValue);
        idx2AddExist = find(idxValidCode == idx2Add);
        if (size(idx2AddExist, 1) < 1)
            idxValidCode = [idxValidCode; idx2Add];
        end
    end
end

Codes = Codes(idxValidCode, 1);
nCodes = size(Codes, 1);
TT = [];
for iCodes = 1 : nCodes
    TT = [TT; Codes(iCodes).CodeValue Codes(iCodes).Center];
end