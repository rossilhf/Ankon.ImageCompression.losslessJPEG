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
t0=cputime;%程序计时开始
A=double(imread('170.bmp'));%载入图像
%同时将像素元素从uint8转化成double，要不然数值范围只有0~255
% A=A(121:160,121:160,1:3);%该项目中图像的标准尺寸为240x320，程序测试时为了节省时间，可能采用较小的图片     
A=A(101:180,101:180,1:3);%该项目中图像的标准尺寸为240x320，程序测试时为了节省时间，可能采用较小的图片 

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

JPEGLS_coderoutput1='';%用JPEGLS压缩后的输出二进制序列(图像的第一行，第一列部分) 
temp='';
for k=1:3
    for j=1:length(A(1,:,k)) %j表示图像上某像素的列数
        temp=A1.huffmancode(find(A1.luminance==A(1,j,k)));
        JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,temp);
    end
    for i=2:length(A(:,1,k))%i表示图像上某像素的行数
        temp=A1.huffmancode(find(A1.luminance==A(i,1,k)));
        JPEGLS_coderoutput1=strcat(JPEGLS_coderoutput1,temp);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对Error中的元素进行量化，采用线性量化                                      
% Errorq=round(Error);%Errorq表示量化后的Error矩阵，量化步长1
% Errorq=round(Error/2);%Errorq表示量化后的Error矩阵，量化步长2
Errorq=round(Error/4);%Errorq表示量化后的Error矩阵，量化步长4

JPEGLS_coderoutput2='';%用JPEGLS压缩后的输出二进制序列(图像的2:end行，2:end列部分)
temp='';
for k=1:3
    for i=2:length(A(:,1,k)) %i表示图像上某像素的行数
        for j=2:length(A(1,:,k)) %j表示图像上某像素的列数
            temp=Errorquant.huffmancode(find(Errorquant.luminance==Errorq(i,j,k)));
            JPEGLS_coderoutput2=strcat(JPEGLS_coderoutput2,temp);
        end
    end
end
time=cputime-t0 %计时结束

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对于原始图像大小和用JPEG-LS压缩后的图像大小比较
temp=length(A(:,1,1))*length(A(1,:,1))*3; %原始图像像素元素数量
originalsize=temp*ceil(log2(255-0)); %原始图像大小

JPEGLSsize1=length(JPEGLS_coderoutput1{1});
JPEGLSsize2=length(JPEGLS_coderoutput2{1});
compressionratio=originalsize/(JPEGLSsize1+JPEGLSsize2) %JPEGLS压缩后和完全没有压缩的原始图像的压缩比 

    