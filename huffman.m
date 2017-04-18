% p=[0.02 0.22 0.32 0.12 0.15 0.5];
% c=huffman(p);




function CODE=huffman(p)
% error(nargchk(1,1,nargin));
% if (ndims(p)~=2)|(min(size(p))>1)|(~isreal(p))|(~isnumeric(p))
%     error('error');
% end
global CODE
CODE=cell(length(p),1);
if length(p)>1
    p=p/sum(p);
    s=reduce(p);
    makecode(s,[]);
else 
    CODE={'1'};
end
%------------------------------------------------------------------------%
function s=reduce(p);
s=cell(length(p),1);
for i=1:length(p)
    s{i}=i;
end

while size(s,1)>2
    [p,i]=sort(p);
    p(2)=p(1)+p(2);
    p(1)=[];
    s=s(i);
    s{2}={s{1},s{2}};
    s(1)=[];
end
%------------------------------------------------------------------------%
function makecode(sc,codeword)
global CODE
if isa(sc,'cell')
    makecode(sc{1},[codeword 0]);
    makecode(sc{2},[codeword 1]);
else
    CODE{sc}=char('0'+codeword);
end