function [camphideg,camposition,Cam_pos_RT,CaxisRT]=CamSimuGenerate(Cam_axis_scale,Camposition,Camorient)
%% �������
Caxis=[Cam_axis_scale,0,0,0
        0,Cam_axis_scale,0,0
        0,0,Cam_axis_scale,0];

    camphideg{1}=Camorient;%y;x;z�ĽǶ�����˳��%��

    camT{1}    = Camposition;%x;y;z��ƽ������˳��

    [camposition,R,T,CaxisRT]=camset(Caxis,camphideg{1},camT{1});

    Cam_pos_RT{1,1}=R;
    Cam_pos_RT{2,1}=T;
end