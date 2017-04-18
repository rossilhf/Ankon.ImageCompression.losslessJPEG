function x=huff2mat(y)
sz=double(y.size);
m=sz(1);
n=sz(2);
xmin=double(y.min)-32768;
map=huffman(double(y.hist));

code=cellstr(char(','0','1'));
link=[2;0;0];
left=[2 3];
found=0;
tofind=length(map);

while length(left)&(found<tofind)
    look=find(strcmp(map,code{left(1)}));
    if look
        link(left(1))=-look;
        left=left(2:end);
        found=found+1;
    else
        len=length(code);
        link(left(1))=len+1;
        link=[link;0;0];
        code{end+1}=strcat(code{left(1)},'0');
        code{end+1}=strcat(code{left(1)},'1');
        left=left(2:end);
        left=[left len+1 len+2];
    end
end
x=unravel(y.code',link,m*n);
x=x+xmin-1;
x=reshape(x,m,n);