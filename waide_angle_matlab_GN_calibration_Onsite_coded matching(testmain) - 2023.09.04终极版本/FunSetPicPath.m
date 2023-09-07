function [picFileNames, numPicFile] = FunSetPicPath()
%%%确定图片文件路径和图片类型.jpg  .bmp
picType = '';
[filename, pathname] = uigetfile('*.jpg; *.bmp; .png', 'Set Picture File Path');

isjpg = strfind(filename, '.jpg'); isJPG = strfind(filename, '.JPG');
isbmp = strfind(filename, '.bmp'); isBMP = strfind(filename, '.BMP');
ispng = strfind(filename, '.png'); isPNG = strfind(filename, '.PNG');

if size(isjpg, 1) > 0
    picType = '.jpg';
end
if size(isJPG, 1) > 0
    picType = '.JPG';
end
if size(isbmp, 1) > 0
    picType = '.bmp';
end
if size(isBMP, 1) > 0
    picType = '.BMP';
end
if size(ispng, 1) > 0
    picType = '.png';
end
if size(isPNG, 1) > 0
    picType = '.PNG';
end


allFilesUnderPath = dir(pathname);
numAllFilesUnderPath = length(allFilesUnderPath);

picFileNames = []; numPicFile = 0;
for iFile = 1 : numAllFilesUnderPath
    iFileName = allFilesUnderPath(iFile).name;
    isPicType = size(strfind(iFileName, picType), 1);
    if isPicType > 0
        picFileNames = [picFileNames; strcat(pathname, iFileName)];
        numPicFile = numPicFile + 1;
    end
end