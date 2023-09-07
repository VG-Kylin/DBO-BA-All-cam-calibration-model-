function [Codes] = FunCodeRefine(SubArea)

%% ���Ƚ��е㼯�ظ����жϣ����һ���㼯��������һ���㼯����ôɾ���������㼯
Codes = [];
[nArea, n] = size(SubArea);
index_repeat = [];

numSubAreaPoint = zeros(nArea, 1);
for i = 1 : nArea
    numSubAreaPoint(i, 1) = size(SubArea(i, 1).indexNo, 1);
end

[sortResult, sortMethod] = sort(numSubAreaPoint);
SubArea_sort = SubArea(sortMethod, 1);

for i = 1 : nArea-1
    for j = i+1 : nArea
        iSubSort = SubArea_sort(i).indexNo;
        jSubSort = SubArea_sort(j).indexNo;
        iNumSub = size(iSubSort, 1);
        jNumSub = size(jSubSort, 1);
        numFindInJSub = 0;
        for k = 1 : iNumSub
            kIdxNo = iSubSort(k);
            idxFind = find(jSubSort == kIdxNo);
            if size(idxFind, 1) > 0
                numFindInJSub = numFindInJSub + 1;
            end
        end
        if numFindInJSub  == min([iNumSub jNumSub])
            idxTemp = find(index_repeat == i);
            if size(idxTemp, 1) < 1
                index_repeat = [index_repeat; i];
            end
        end
    end
end
SubArea_sort(index_repeat) = [];
%% Ȼ��ͨ��Ѱ�ұ�����������5�������㣬���жϵ㼯�ǲ��Ǳ���㼯
[nArea, n] = size(SubArea_sort);
indexCodeBasePoint = [];
for i = 1 : nArea
    BasePoint = [];
    sub = SubArea_sort(i).pSurround;
    BasePoint = FunBasePoint(sub);
    n_subCode = size(BasePoint, 1);
    if n_subCode > 0
        for i_subCode = 1 : n_subCode
            BasePoint(i_subCode, 1).indexNo = SubArea_sort(i).indexNo;
        end
        Codes = [Codes; BasePoint];
    end
end
SubArea_sort(indexCodeBasePoint, :) = [];
[nArea, n] = size(SubArea_sort);