%本程序用于演示JPEG-LS压缩算法过程及压缩效果
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


function [JPEGLS_coderoutput1,JPEGLS_coderoutput2]=losslessJPEG_coder(A,Errorquant,step)
% global A1 Errorquant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t0=cputime;%程序计时开始

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%线性预测编码，需要注意：图像第一行和第一列没有编码，需要保留用来解码。下面的几行代码中，Error矩阵的第一行和第一列为空
                                                               
for i=2:length(A(:,1)) %i表示图像上某像素的行数
    for j=2:length(A(1,:)) %j表示图像上某像素的列数
%             Error(i,j)=A(i,j-1)-A(i,j);%Error矩阵为预测误差矩阵，按照方式1
%             Error(i,j)=A(i-1,j)-A(i,j);%Error矩阵为预测误差矩阵，按照方式2   
%             Error(i,j)=A(i-1,j-1)-A(i,j);%Error矩阵为预测误差矩阵，按照方式3 
%             Error(i,j)=A(i-1,j)+A(i,j-1)-A(i-1,j-1)-A(i,j);%Error矩阵为预测误差矩阵，按照方式4
%             Error(i,j)=A(i,j-1)+(A(i-1,j)-A(i-1,j-1))/2-A(i,j);%Error矩阵为预测误差矩阵，按照方式5
%             Error(i,j)=A(i-1,j)+(A(i,j-1)-A(i-1,j-1))/2-A(i,j);%Error矩阵为预测误差矩阵，按照方式6
        Error(i,j)=(A(i,j-1)+A(i-1,j))/2-A(i,j);%Error矩阵为预测误差矩阵，按照方式7 
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
JPEGLS_coderoutput1='';%用JPEGLS压缩后的输出二进制序列(图像的第一行，第一列部分) 
temp='';

for j=1:length(A(1,:)) %j表示图像上某像素的列数
    temp=dec2bin(A(1,j));
    temp1=length(temp);
    if temp1==1
        temp1='0000000';
    end
    if temp1==2
        temp1='000000';
    end
    if temp1==3
        temp1='00000';
    end
    if temp1==4
        temp1='0000';
    end
    if temp1==5
        temp1='000';
    end
    if temp1==6
        temp1='00';
    end
    if temp1==7
        temp1='0';
    end
    if temp1==8
        temp1='';
    end
    JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,temp1,temp);
end           %对第一行数据进行无压缩的等长编码，每位数据提供8bit空间。这样就不需要一个额外的码本codebook_A1了，减少内存消耗。
              %而且由于第一行第一列数据较少，增加的数据传输量也不多
for i=2:length(A(:,1))%i表示图像上某像素的行数
    temp=dec2bin(A(i,1));
    temp1=length(temp);
    if temp1==1
        temp1='0000000';
    end
    if temp1==2
        temp1='000000';
    end
    if temp1==3
        temp1='00000';
    end
    if temp1==4
        temp1='0000';
    end
    if temp1==5
        temp1='000';
    end
    if temp1==6
        temp1='00';
    end
    if temp1==7
        temp1='0';
    end
    if temp1==8
        temp1='';
    end
    JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,temp1,temp);
end           %对第一列数据进行无压缩的等长编码，每位数据提供8bit空间。这样就不需要一个额外的码本codebook_A1了，减少内存消耗。
              %而且由于第一行第一列数据较少，增加的数据传输量也不多

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对Error中的元素进行量化，采用线性量化                                      
Errorq=round(Error/step);%Errorq表示量化后的Error矩阵，量化步长为step
clear Error step;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
JPEGLS_coderoutput2='';%用JPEGLS压缩后的输出二进制序列(图像的2:end行，2:end列部分)
temp='';

    for i=2:length(A(:,1)) %i表示图像上某像素的行数
        for j=2:length(A(1,:)) %j表示图像上某像素的列数
            if find(Errorquant.luminance==Errorq(i,j))~=0%如果在经验码本中找到了对应的像素值
                temp=Errorquant.huffmancode(find(Errorquant.luminance==Errorq(i,j)));%则直接转化为huffman编码
            else   %如果在经验码本中找不到对应的像素值，则找最接近的
                temp1=min(abs(Errorquant.luminance-Errorq(i,j)));
                if find(Errorquant.luminance==(Errorq(i,j)+temp1))~=0
                    temp=Errorquant.huffmancode(find(Errorquant.luminance==(Errorq(i,j)+temp1)));
                else
                    temp=Errorquant.huffmancode(find(Errorquant.luminance==(Errorq(i,j)-temp1)));
                end
            end
            JPEGLS_coderoutput2=strcat(JPEGLS_coderoutput2,temp);
        end
    end

% time=cputime-t0 %计时结束
clear Errorq i j t0 temp1 temp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对于原始图像大小和用JPEG-LS压缩后的图像大小比较
temp=length(A(:,1))*length(A(1,:)); %原始图像像素元素数量
originalsize=temp*ceil(log2(255-0)); %原始图像大小
clear temp;
JPEGLSsize1=length(JPEGLS_coderoutput1);
JPEGLSsize2=length(JPEGLS_coderoutput2{1});%这里不知道为什么同样的操作，得到的JPEGLS_coderoutput1和2的类型不一样
compressionratio=originalsize/(JPEGLSsize1+JPEGLSsize2) %JPEGLS压缩后和完全没有压缩的原始图像的压缩比 
clear JPEGLSsize1 JPEGLSsize2 originalsize time compressionratio;

    