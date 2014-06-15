function [starti,Endi]=find_con(CC)
% A function use to find indices from continues 1 0 masks.

idx = find(CC);
a=1;
Endi = [];
starti=idx(1);
for i =1:length(idx)-1
    
    %start(i) = idx(i)
    if idx(i+1) ~= idx(i)+1
        Endi=[Endi,idx(i)]
        starti=[starti,idx(i+1)]
    end
        
    
end
Endi=[Endi,idx(end)]
end