%本程序通过大量肠道图像来统计肠道图像中各颜色数值（线性预测误差数值）的分布状况
num=313;%总共313张照片

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%统计图像除了第一行第一列以外部分的线性预测值分布,量化步长1
Errorquant.count=zeros(1,511);
for l=1:num
    l
    fname=sprintf('%d.bmp',l);
    A=double(imread(fname));%载入图像
    %同时将像素元素从uint8转化成double，要不然数值范围只有0~255
    A=A(70:230,70:230,1:3);%该项目中图像的尺寸为160x160，程序测试时为了节省时间，可能采用较小的图片   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    filter(:,:,1)=[1 0;0 0];%bayer彩色滤波阵列R分量
filter(:,:,2)=[0 1;1 0];%bayer彩色滤波阵列G分量
filter(:,:,3)=[0 0;0 1];%bayer彩色滤波阵列B分量

%将普通GRB颜色照片转成BAYER格式照片
for i=1:80%行数，每个滤波阵列为2x2,图像有160行，所以需要循环80次
    for j=1:80%列数，循环80次
        A0(2*i-1:2*i,2*j-1:2*j,:)=A(2*i-1:2*i,2*j-1:2*j,:).*filter;%A变成转换好了的bayer格式照片，尺寸还是160x160x3
    end
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%将原始图像160x160x3分成4个子图80x80x1,分别是R分量，两个G分量，B分量像素集合
for i=2-1:2:160-1
    for j=2-1:2:160-1
        A0_color{1}((i+1)/2,(j+1)/2)=A0(i,j,1);%A0_color{1}是BAY格式的图像中r分量元素单独提取出来组成的图像，大小为80x80x1
    end
end
        
for i=2-1:2:160-1
    for j=2:2:160
        A0_color{2}((i+1)/2,j/2)=A0(i,j,2);%A0_color{2}是BAY格式的图像中g分量(滤波阵列右上角的那个G)元素单独提取出来组成的图像，大小为80x80x1
    end
end

for i=2:2:160
    for j=2-1:2:160-1
        A0_color{3}(i/2,(j+1)/2)=A0(i,j,2);%A0_color{3}是BAY格式的图像中g分量(滤波阵列左下角的那个G)元素单独提取出来组成的图像，大小为80x80x1
    end
end

for i=2:2:160
    for j=2:2:160
        A0_color{4}(i/2,j/2)=A0(i,j,3);%A0_color{4}是BAY格式的图像中b分量元素单独提取出来组成的图像，大小为80x80x1
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对4个BAYER分量图进行水平滤波
for i=2:80
    A0_color{1}(:,i)=round((A0_color{1}(:,i-1)+A0_color{1}(:,i))/2);
    A0_color{2}(:,i)=round((A0_color{2}(:,i-1)+A0_color{2}(:,i))/2);
    A0_color{3}(:,i)=round((A0_color{3}(:,i-1)+A0_color{3}(:,i))/2);
    A0_color{4}(:,i)=round((A0_color{4}(:,i-1)+A0_color{4}(:,i))/2);
end
    
%对4个BAYER分量图进行垂直滤波
for i=2:80
    A0_color{1}(i,:)=round((A0_color{1}(i-1,:)+A0_color{1}(i,:))/2);
    A0_color{2}(i,:)=round((A0_color{2}(i-1,:)+A0_color{2}(i,:))/2);
    A0_color{3}(i,:)=round((A0_color{3}(i-1,:)+A0_color{3}(i,:))/2);
    A0_color{4}(i,:)=round((A0_color{4}(i-1,:)+A0_color{4}(i,:))/2);
end

    
    
    
    
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %线性预测编码，需要注意：图像第一行和第一列没有编码，需要保留用来解码。下面的几行代码中，Error矩阵的第一行和第一列为空
    for k=1:4 %k表示图像的某分量图，共R,G1,G2,B四个                                                                
        for i=2:length(A0_color{1}(:,1)) %i表示图像上某像素的行数
            for j=2:length(A0_color{1}(1,:)) %j表示图像上某像素的列数
%             Error(i,j,k)=A(i,j-1,k)-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式1
%             Error(i,j,k)=A(i-1,j,k)-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式2   
%             Error(i,j,k)=A(i-1,j-1,k)-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式3 
%             Error(i,j,k)=A(i-1,j,k)+A(i,j-1,k)-A(i-1,j-1,k)-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式4
%             Error(i,j,k)=A(i,j-1,k)+(A(i-1,j,k)-A(i-1,j-1,k))/2-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式5
%             Error(i,j,k)=A(i-1,j,k)+(A(i,j-1,k)-A(i-1,j-1,k))/2-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式6
                Error{k}(i,j)=(A0_color{k}(i,j-1)+A0_color{k}(i-1,j))/2-A0_color{k}(i,j);%Error矩阵为预测误差矩阵，按照方式7 
            end
        end
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %对Error中的元素进行量化，采用线性量化   
    for k=1:4
    Errorq{k}=round(Error{k}/2);%Errorq表示量化后的Error矩阵，量化步长step=2
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %统计Errorq矩阵中各元素数值的概率分布                                                
    Errorquant_1D=zeros(1,length(A0_color{1}(:,1))*length(A0_color{1}(1,:))*4);%图像的一维输出
    count=1;
    for k=1:4
        for i=2:length(A0_color{1}(:,1)) %i表示图像上某像素的行数
            for j=2:length(A0_color{1}(1,:)) %j表示图像上某像素的列数
                Errorquant_1D(count)=Errorq{k}(i,j);%把Errorquant上所有元素转移到上Errorquant_1D上
                count=count+1;                %Errorquant_1D是一维数组
            end
        end
    end
    Errorquant.luminance=-255:1:255;%Errorquant.luminance对应着像素亮度     
    Errorquant.count=Errorquant.count+hist(Errorquant_1D,Errorquant.luminance);%Errorquant.count亮度出现的次数，越大表示该亮度值出现越频繁
%     [Errorquant.count,index]=sort(Errorquant.count);%Errorquant.count按亮度值出现频繁程度排序，由低到高
%     Errorquant.luminance=Errorquant.luminance(index);%Errorquant.luminance也同样顺序排列
end

Errorquant.luminance(find(Errorquant.count==0))=[];
Errorquant.count(find(Errorquant.count==0))=[];
[Errorquant.tree,Errorquant.huffmancode]=huffman(Errorquant.count,Errorquant.luminance);
% p=Errorquant.count;
% s=cell(length(p),1);
% s1=cell(length(p),1);
% for i=1:length(p)
%     s{i}=i;
%     s1{i}=Errorquant.luminance(i);
% end
% 
% while size(s,1)>2
%     [p,i]=sort(p);
%     p(2)=p(1)+p(2);
%     p(1)=[];
%     s=s(i);
%     s1=s1(i);
%     s{2}={s{1},s{2}};
%     s1{2}={s1{1},s1{2}};
%     s(1)=[];
%     s1(1)=[];
% end
% Errorquant.tree=s1;

[temp,i]=sort(Errorquant.count);
Errorquant.luminance=Errorquant.luminance(i);
Errorquant.huffmancode=Errorquant.huffmancode(i);
Errorquant.count=temp(end:-1:1);

temp=Errorquant.luminance(end:-1:1);
 Errorquant.luminance=temp(end:-1:1);
 Errorquant.luminance=temp;
 temp=Errorquant.huffmancode(end:-1:1);
 Errorquant.huffmancode=temp;



% save codebook_bayer.mat Errorquant


