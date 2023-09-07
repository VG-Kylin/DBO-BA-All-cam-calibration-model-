function [pointStructure, numCodeAll] = FunPicPointCentroid_bwconncomp(imgFileNames, numImg, bwThreshold, ...
    minSpotSize, maxSpotSize, pixSize, barDesign, ifAutoThresh, ifCompensation, camCompTemp, initInParam)
% initInParam = load('AVT_40_35mm.txt');
% initInParam = [-0.014074; -0.207993; 22.279081; 0; 0; 0; 0; 0; 0; 0]
bk = 4;
for iImg = 1 : numImg
    pointStructure(iImg, 1).point = [];
    pointStructure(iImg, 1).numPoint = 0;
    pointStructure(iImg, 1).bar = [];
    pointStructure(iImg, 1).numBar = 0;
    pointStructure(iImg, 1).code = [];
    pointStructure(iImg, 1).numCode = 0;
    pointStructure(iImg, 1).exParam = zeros(6, 1);
    pointStructure(iImg, 1).inParam = zeros(10, 1);
    pointStructure(iImg, 1).matched = [];
    pointStructure(iImg, 1).codeCorrespond = [];
    pointStructure(iImg, 1).R = zeros(3, 3);
    pointStructure(iImg, 1).T = zeros(3, 1);
end
GaussFilter = fspecial('gaussian',4,0.5) ;
spotBoxExtend = 2; ringSize = 40;
angleThr = 4/180*pi; scaleThresh = 0.2;  disThrFactor = 1/50;
% for iImg = [3 17 33 34 54]
for iImg = 1 : numImg
%     close all;
    nCenter = 0; center = []; center_mm = [];
    numRing = 0; posRing = []; barSearchRadi = [];
    imgFileName = imgFileNames(iImg, :);
    display(strcat('正在处理', imgFileName));
    img = imread(imgFileName);
    if size(img, 3) > 1
        img = rgb2gray(img);
    end
    %%%%%%%%%%%%%%%%%%%%%
    [m, n] = size(img);
    %%%%%%%%%%%%%%%%%%一些图像处理 
    img = img - bk;
    ifCompensation = 0;
    if ifCompensation > 0
        img = uint8(double(img).*double(camCompTemp));
    end
    img = imfilter(img, GaussFilter, 'replicate');
    %%%%%%%%%%%%%%%%
    
    %%% 将图像进行二值化
    if ifAutoThresh > 0
        bwThreshold = graythresh(img);
    end
    imgBW = im2bw(img, bwThreshold);
%     maxGray = double(max(max(img))); 
%     if maxGray > 200
%         bwThreshold = maxGray/4/255;
%     else
%         bwThreshold = graythresh(img);
%     end
%     imgBW = im2bw(img, bwThreshold);
%     figure(1), imshow(imgBW), hold on;
    %%二值图像中的连通区域标记
    CC = bwconncomp(imgBW); N_ConnComp = CC.NumObjects;
    for iConnComp = 1 : N_ConnComp
        iCompIndex = CC.PixelIdxList{1, iConnComp}; Area = length(iCompIndex);
        rowIndex = mod(iCompIndex, m); columnIndex = floor(iCompIndex ./ m) + 1;
        upLeft = [min(rowIndex); min(columnIndex)]; downRight = [max(rowIndex); max(columnIndex)];
        boxSize = abs(downRight - upLeft) + 1;
        minLen = min(boxSize); maxLen = max(boxSize);
        ShapeRatio = minLen / maxLen;
        
        if Area > minSpotSize && Area < maxSpotSize && ShapeRatio > 0.2
            rectUpLeft = upLeft - spotBoxExtend; rectDownRight = downRight + spotBoxExtend;
            rectSize = boxSize + 2*spotBoxExtend;           
            %%区域不能超出图像边缘，取出此连通区域
            if rectDownRight(1) <= m && rectDownRight(2) <= n && rectUpLeft(1) > 0 && rectUpLeft(2) > 0
                imgClip = img(rectUpLeft(1) : rectDownRight(1), rectUpLeft(2) : rectDownRight(2));
            else
                continue;
            end
            %%%对imgClip区域进行分析，如果包含了其他目标的部分，则进行相应处理
            bwThreshold_Clip = graythresh(imgClip);
            imgClipBW = im2bw(imgClip, bwThreshold_Clip);
            CC_Clip = bwconncomp(imgClipBW); N_clip = CC_Clip.NumObjects;
            if N_clip > 1
                areas = cellfun(@numel,CC_Clip.PixelIdxList);
                [maxArea, maxAreaIndex] = max(areas);
                for iArea = 1 : N_clip
                    if iArea ~= maxAreaIndex
                        indexMargin = CC_Clip.PixelIdxList{iArea};
                        imgClip(indexMargin) = 0; imgClipBW(indexMargin) = 0;
                    end
                end
            else if N_clip < 1
                    continue;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
            SumGray = sum(sum(imgClip));
            SumPix = size(imgClip, 1) * size(imgClip, 2);
            GrayMean = SumGray/SumPix;
            if GrayMean > 5
                [meanx, meany] = FunSquaredCentroid(imgClip);
                vec_x = meany - 1/2*rectSize(1); vec_y = meanx - 1/2*rectSize(2);
                if sqrt(vec_x^2 + vec_y^2) > 1/5*max(rectSize)
                    continue;
                end
                C = [meanx meany] + [rectUpLeft(2) rectUpLeft(1)] - 1;
                x_mm = (C(1) - n/2 - 1) * pixSize;
                y_mm = -(C(2) - m/2 - 1) * pixSize;
                %%%%%%%%%%判断是否是圆环，藉此初步确定靶标位置
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                imgClipBW_reverse = 1 - imgClipBW;
                CC_imgClip_reverse = bwconncomp(imgClipBW_reverse);
                numCC_imgClip_reverse = CC_imgClip_reverse.NumObjects;
                if numCC_imgClip_reverse == 1
                    if Area > 25
                        isEllipse = FunShapeQuality(imgClipBW);
                        if isEllipse < 1
                            continue;
                        end
                    end
                elseif numCC_imgClip_reverse == 2
                    for iCC_Reverse = 1 : 2
                        iCC_ObjPos  = CC_imgClip_reverse.PixelIdxList{iCC_Reverse};
                        findFirstPix = find(iCC_ObjPos == 1);
                        if size(findFirstPix, 1) > 0
                            imgClipBW_reverse(iCC_ObjPos) = 0;
                        end
                    end
                    isEllipse = FunShapeQuality(imgClipBW_reverse);
% isEllipse= 1;
                    if isEllipse > 0
                        numRing = numRing + 1; posRing = [posRing; nCenter+1 x_mm y_mm];
%                         ringSize = norm([size(imgClip, 1), size(imgClip, 2)])*pixSize;
                        ringSize = sqrt((size(imgClip, 1))^2 + (size(imgClip, 2))^2) * pixSize;
%                         barSearchRadi = [barSearchRadi; ringSize/40*norm(barDesign(1, :)-barDesign(6, :))+10*pixSize];
                        barSearchRadi = [barSearchRadi; ringSize/40*sqrt((barDesign(1, 1)-barDesign(6, 1))^2 ...
                            + (barDesign(1, 2)-barDesign(6, 2))^2 + (barDesign(1, 3)-barDesign(6, 3))^2)+10*pixSize];
                    end
                else
                    continue;
                end

%                 rectangle('edgecolor', 'c', 'position', [rectUpLeft(2) rectUpLeft(1) rectSize(2) rectSize(1)]);
%                 plot(C(1), C(2), 'r+'), hold on;
                nCenter = nCenter + 1; center = [center; nCenter C];
                center_mm = [center_mm; nCenter x_mm y_mm minLen*pixSize maxLen*pixSize];
            end
        end
    end
    pointStructure(iImg, 1).point = center_mm;
    pointStructure(iImg, 1).numPoint = nCenter;
    %%%确定Bar部分
%     figure(1), clf, plot(center_mm(:, 2), center_mm(:, 3), 'r+'), hold on;
    segBarSearch;

    if size(bar2D, 1) == 6
        %%%%%%%%%%%%Bar Orientation
%%%%%%%%%ExParam Guess from homography
        segResection;
        % if mean(abs(ResidualResection)) < 0.003
        if mean(abs(ResidualResection)) < 3
%         plot(bar2D(:, 2), bar2D(:, 3), 'ko'), hold on;
        display('Bar Found');
        pointStructure(iImg, 1).bar = bar2D;
        pointStructure(iImg, 1).numBar = 1;
        pointStructure(iImg, 1).point(bar2D(:, 1), :) = [];
        pointStructure(iImg, 1).numPoint = pointStructure(iImg, 1).numPoint - 6;
        else
            display('No Bar');
            pointStructure(iImg, 1).numBar = 0;
            pointStructure(iImg, 1).bar = ones(6, 1)*[0 2000 2000];
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pointStructure(iImg, 1).exParam = Ex_resection;
    else
        display('No Bar');
        pointStructure(iImg, 1).numBar = 0;
        pointStructure(iImg, 1).bar = ones(6, 1)*[0 2000 2000];
    end
    %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%编码点识别部分，每张图上编码点信息保存在Codes  nCodes中
    segCodeDetect;
    idxSurround = [];
    pointStructure(iImg, 1).numCode = nCodes;
    if nCodes > 0
        display(strcat(num2str(nCodes), ' Codes Found'));
        for iCode = 1 : nCodes
            for iSurround = 1 : 8
                idxNo = find(pointStructure(iImg, 1).point(:, 1) == Codes(iCode, 1).indexNo(iSurround));
                if size(idxNo, 1) == 1
                    idxSurround = [idxSurround; idxNo];
                end
            end
            pointStructure(iImg, 1).code = [pointStructure(iImg, 1).code; Codes(iCode, 1).CodeValue Codes(iCode, 1).Center(1, 2:3)];
        end
        pointStructure(iImg, 1).point(idxSurround, :) = [];
        pointStructure(iImg, 1).numPoint = pointStructure(iImg, 1).numPoint - 8*nCodes;
    else
        display('No Codes Found');
    end
    pointStructure(iImg, 1).inParam = initInParam; 
end
%%%Code Correspondence
codeSeries = [];
numCodeAll = 0;
for iImg = 1 : numImg;
    iImgNumCode = pointStructure(iImg).numCode;
    for iImgiCode = 1 : iImgNumCode
        iImgiCodeValue = pointStructure(iImg).code(iImgiCode, 1);
        valueExistInSeries = find(codeSeries == iImgiCodeValue);
        if size(valueExistInSeries, 1) < 1
            numCodeAll = numCodeAll + 1;
            codeSeries = [codeSeries; iImgiCodeValue];
        end
    end
end

for iImg = 1 : numImg
    pointStructure(iImg).codeCorrespond = 2000*ones(numCodeAll, 3);
    pointStructure(iImg).codeCorrespond(1:numCodeAll, 1) = codeSeries;
    iImgNumCode = pointStructure(iImg).numCode;
    for iImgiCode = 1 : iImgNumCode
        iImgiCodeValue = pointStructure(iImg).code(iImgiCode, 1);
        idxLand = find(codeSeries == iImgiCodeValue);
        pointStructure(iImg).codeCorrespond(idxLand, :) = pointStructure(iImg).code(iImgiCode, :);
    end
end