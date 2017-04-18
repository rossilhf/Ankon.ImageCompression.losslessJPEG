%本程序用于演示JPEG-LS压缩算法过程及压缩效果，运算速度和内存消耗不考虑
%JPEG-LS主要采用DPCM编码和Huffman编码的组合，是近无损编码
%    C B D
%    A X         % X是要编码的像素
%下面显示的是对X进行预测的几种方式
% Selection-value Prediction 
% 0 No prediction 
% 1 A 
% 2 B 
% 3 C 
% 4 A + B – C 
% 5 A + (B – C)/2 
% 6 B + (A – C)/2 
% 7 (A + B)/2 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=double(imread('02.jpg'));%载入图像
%同时将像素元素从uint8转化成double，要不然数值范围只有0~255
A=A(1:240,1:320,1:3);%该项目中图像的标准尺寸为240x320，程序测试时为了节省时间，可能采用较小的图片     



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%线性预测编码，需要注意：图像第一行和第一列没有编码，需要保留用来解码。下面的几行代码中，Error矩阵的第一行和第一列为空
for k=1:3 %k表示图像的某分量                                                                
    for i=2:length(A(:,1,k)) %i表示图像上某像素的行数
        for j=2:length(A(1,:,k)) %j表示图像上某像素的列数
%             Error(i,j,k)=A(i,j-1,k)-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式1
%             Error(i,j,k)=A(i-1,j,k)-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式2   
%             Error(i,j,k)=A(i-1,j-1,k)-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式3 
%             Error(i,j,k)=A(i-1,j,k)+A(i,j-1,k)-A(i-1,j-1,k)-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式4
%             Error(i,j,k)=A(i,j-1,k)+(A(i-1,j,k)-A(i-1,j-1,k))/2-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式5
%             Error(i,j,k)=A(i-1,j,k)+(A(i,j-1,k)-A(i-1,j-1,k))/2-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式6
            Error(i,j,k)=(A(i,j-1,k)+A(i-1,j,k))/2-A(i,j,k);%Error矩阵为预测误差矩阵，按照方式7 
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对A矩阵的第一行第一列的图像像素亮度进行概率统计
A1_1D=zeros(1,(length(A(:,1,1))+length(A(1,:,1))-1)*3);%图像的一维输出
count=1;
for k=1:3
    for j=1:length(A(1,:,k)) %j表示图像上某像素的列数
        A1_1D(count)=A(1,j,k);%把原始图像的第一行像素数据存入A1_1D
        count=count+1;
    end
    for i=2:length(A(:,1,k))%i表示图像上某像素的行数
        A1_1D(count)=A(i,1,k);%把原始图像的第一列像素数据存入A1_1D
        count=count+1;
    end
end

A1.luminance=min(A1_1D):1:max(A1_1D);%Errorquant.luminance对应着像素亮度    
A1.count=hist(A1_1D,length(A1.luminance));%A1.count亮度出现的次数，越大表示该亮度值出现越频繁
[A1.count,index]=sort(A1.count);%A1.count按亮度值出现频繁程度排序，由低到高
A1.luminance=A1.luminance(index);%A1.luminance也同样顺序排列



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对A矩阵的第一行第一列的图像像素亮度进行huffman编码
A1.huffmancode=huffman(A1.count);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对Error中的元素进行量化，采用线性量化                                      
% Errorquant=round(Error);%Errorquant表示量化后的Error矩阵，量化步长1
% Errorquant=round(Error/2);%Errorquant表示量化后的Error矩阵，量化步长2
Errorquant=round(Error/3);%Errorquant表示量化后的Error矩阵，量化步长4
% Errorquant=round(Error/4);%Errorquant表示量化后的Error矩阵，量化步长4


            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%统计Errorquant矩阵中各元素数值的概率分布                                                 %问题：进行概率统计实在是需要很多计算量，如果能够根据经验对图像进行熵编码，就算编码不是最优，但是起码能节约很多计算资源
Errorquant_1D=zeros(1,length(A(:,1,k))*length(A(1,:,k))*3);%图像的一维输出
count=1;
for k=1:3
    for i=2:length(A(:,1,k)) %i表示图像上某像素的行数
        for j=2:length(A(1,:,k)) %j表示图像上某像素的列数
            Errorquant_1D(count)=Errorquant(i,j,k);%把Errorquant上所有元素转移到上Errorquant_1D上
            count=count+1;                %Errorquant_1D是一维数组
        end
    end
end

Errorquant.luminance=ceil(min(Errorquant_1D)):1:ceil(max(Errorquant_1D));%Errorquant.luminance对应着像素亮度     
Errorquant.count=hist(Errorquant_1D,length(Errorquant.luminance));%Errorquant.count亮度出现的次数，越大表示该亮度值出现越频繁
[Errorquant.count,index]=sort(Errorquant.count);%Errorquant.count按亮度值出现频繁程度排序，由低到高
Errorquant.luminance=Errorquant.luminance(index);%Errorquant.luminance也同样顺序排列

temp=length(find(Errorquant.count==0));%删除Errorquant矩阵中没有出现过的亮度值
Errorquant.count=Errorquant.count(temp+1:end);
Errorquant.luminance=Errorquant.luminance(temp+1:end);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对Errorquant进行huffman编码
Errorquant.huffmancode=huffman(Errorquant.count);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对于原始图像大小和用JPEG-LS压缩后的图像大小比较
temp=length(A(:,1,1))*length(A(1,:,1))*3; %原始图像像素元素数量
originalsize=temp*ceil(log2(255-0)); %原始图像大小

JPEGLSsize1=0;%用JPEGLS压缩后的图像大小(图像第一行第一列数据部分)
JPEGLSsize2=0;%用JPEGLS压缩后的图像大小(图像其余部分的数据部分)

JPEGLS_coderoutput1='';%用JPEGLS压缩后的输出二进制序列(图像的第一行，第一列部分)                
for i=1:length(A1_1D)
    temp=A1.huffmancode(find(A1.luminance==A1_1D(i)));
    JPEGLSsize1=JPEGLSsize1+length(temp{1});
    JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,temp);
end

JPEGLS_coderoutput2='';%用JPEGLS压缩后的输出二进制序列(图像的2:end行，2:end列部分)
for i=1:length(Errorquant_1D)
    temp=Errorquant.huffmancode(find(Errorquant.luminance==Errorquant_1D(i)));
    JPEGLSsize2=JPEGLSsize2+length(temp{1});
    JPEGLS_coderoutput2=strcat(JPEGLS_coderoutput2,temp);                                    
end

compressionratio=originalsize/(JPEGLSsize1+JPEGLSsize2) %JPEGLS压缩后和完全没有压缩的原始图像的压缩比 

    