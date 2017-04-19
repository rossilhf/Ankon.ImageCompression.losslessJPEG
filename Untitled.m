%该程序用来检验codebook_step1中树形结构和线性结构码本是不是完全吻合
load codebook_step1
s=Errorquant.tree;
for i=1:length(Errorquant.huffmancode)
    s=Errorquant.tree;
    temp=Errorquant.huffmancode(i);
    for j=1:length(Errorquant.huffmancode{i})        
        if temp{1}(j)=='0'
            s=s{1};
        end
        if temp{1}(j)=='1'
            s=s{2};
        end
    end
    Re_luminance(i)=s;
end

% 
% 
% load codebook_step1
% s=Errorquant.tree;
% 
