ExResection_BarDesign = barDesign([1; 2; 3; 4; 5], :);
ExResection_BarImg = bar2D([1; 2; 3; 4; 5], 2:3);
ExResection_BarImgCorrect = FunDistortionCorrect(ExResection_BarImg,...
    initInParam(4:10), initInParam(1), initInParam(2));
rW2C = [0 1 0; 0 0 1; 1 0 0];
Ex_resection = zeros(6, 1);
ExResectionGuess = [0; 0; 0; pi/2; 0; 0];
% disImgBar13 = norm(ExResection_BarImgCorrect(1, :) - ExResection_BarImgCorrect(3, :));
disImgBar13 = sqrt((ExResection_BarImgCorrect(1, 1) - ExResection_BarImgCorrect(3, 1))^2 + ...
    (ExResection_BarImgCorrect(1, 2) - ExResection_BarImgCorrect(3, 2))^2);
% disImgBar24 = norm(ExResection_BarImgCorrect(2, :) - ExResection_BarImgCorrect(4, :));
disImgBar24 = sqrt((ExResection_BarImgCorrect(2, 1) - ExResection_BarImgCorrect(4, 1))^2 + ...
    (ExResection_BarImgCorrect(2, 2) - ExResection_BarImgCorrect(4, 2))^2);
% disBar13 = norm(ExResection_BarDesign(1, :) - ExResection_BarDesign(3, :));
disBar13 = sqrt((ExResection_BarDesign(1, 1) - ExResection_BarDesign(3, 1))^2 + ...
    (ExResection_BarDesign(1, 2) - ExResection_BarDesign(3, 2))^2);
% disBar24 = norm(ExResection_BarDesign(2, :) - ExResection_BarDesign(4, :));
disBar24 = sqrt((ExResection_BarDesign(2, 1) - ExResection_BarDesign(4, 1))^2 + ...
    (ExResection_BarDesign(2, 2) - ExResection_BarDesign(4, 2))^2);
k13 = disBar13/disImgBar13;
k24 = disBar24/disImgBar24;
k = max([k13 k24]);
Worigion2C = [ExResection_BarImgCorrect(1, 1)*k; ExResection_BarImgCorrect(1, 2)*k; -initInParam(3)*k];
t = -inv(rW2C)*Worigion2C;
t = [2000; 0; 0];
ExResectionGuess(1:3) = t;
[Ex_resection, kResection, ResidualResection] = FunExParamItrPerImg_LM(initInParam(3), ...
    ExResectionGuess, ExResection_BarImgCorrect, ExResection_BarDesign, size(ExResection_BarImg, 1));
% [Ex_resection, kResection, ResidualResection] = FunExParamItrPerImg_GN(initInParam(3), ...
%     Ex_resection, ExResection_BarImgCorrect, ExResection_BarDesign, size(ExResection_BarImg, 1));
% [iImg mean(abs(ResidualResection))]

