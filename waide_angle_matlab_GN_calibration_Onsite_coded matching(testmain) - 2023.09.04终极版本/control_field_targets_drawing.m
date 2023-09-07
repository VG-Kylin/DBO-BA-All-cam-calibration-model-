function [All_control_field_targets,control_field_targets,control_field_targets_Bar,control_field_targets_CODE,control_field_targets_Scale_Bar,control_field_targets_Targets,control_field_alldataall]=control_field_targets_drawing(control_field_alldata)

control_field_alldataall=table2array(control_field_alldata(:,2:4));

control_field_targets=table2array(control_field_alldata(:,2:4));

control_field_targets_Bar=control_field_targets(1:6,:);
control_field_targets_CODE=control_field_targets(7:41,:);

control_field_targets_Scale_Bar=[control_field_targets(99,:);control_field_targets(204,:);control_field_targets(245,:);control_field_targets(48,:);];
indices =[99,204,245,48];
control_field_targets(indices,:)=[];
control_field_targets_Targets=control_field_targets(42:end,:);

All_control_field_targets=[control_field_targets_Bar;control_field_targets_CODE;control_field_targets_Scale_Bar;control_field_targets_Targets];

end