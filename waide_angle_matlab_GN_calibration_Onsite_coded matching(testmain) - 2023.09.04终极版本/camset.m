function [camposition,R,T,CaxisRT]=camset(Caxis,camphideg,camT)
%��Z����ʱ����תphiz��
phiy=camphideg(3);
phix=camphideg(2);
phiz=camphideg(1);%�Ƕ�ֵ yxz˳����ת
[R]=R_generate(phiz,phix,phiy);%������ת����
% R = R;%�������ת
T = [camT(1);camT(2);camT(3)];%�����ƽ����
CaxisRT=inv(R)*Caxis+[T,T,T,T];%R'��inv(R)��ͬ����ΪR���������������� %������泡������
% CaxisRT=(R)*(Caxis-[T,T,T,T]);%R'��inv(R)��ͬ����ΪR���������������� %���������ֵ�������ɷ��泡��
camposition=CaxisRT(:,4);
CaxisRT=CaxisRT';
end