%按照6*40的大小依次读取图像的各个部分
%图像大小为x*y,共读取48次

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global bayerimage0 %这只是个用于计算PSNR的参数，实际使用时可以删除
totaloutput='';%总体图像的输出
A0=double(imread('sample3.bmp'));%载入图像，标准图像大小为x*y
load codebook_step1_forcoder%载入码本，压缩步长为2。王主管说医生要求图片尽量清晰，所以尽可能的不要降低图像质量
step=1;%量化步长
x=240;%图像的行数
y=320;%图像的列数
z=0;%ROI起始行数
w=0;%ROI起始列数
q=0;%ROI结束行数
p=0;%ROI结束列数

%bayer彩色滤波阵列格式
%  B  G
%  G  R
filter(:,:,3)=[1 0;0 0];%bayer彩色滤波阵列b分量
filter(:,:,2)=[0 1;1 0];%bayer彩色滤波阵列g分量
filter(:,:,1)=[0 0;0 1];%bayer彩色滤波阵列r分量

%将普通GRB颜色照片转成BAYER格式照片
for i=1:x/2%行数，每个滤波阵列为2*2,图像有x行，所以需要循环120次
    for j=1:y/2%列数，循环160次
        A0(2*i-1:2*i,2*j-1:2*j,:)=A0(2*i-1:2*i,2*j-1:2*j,:).*filter;
    end
end
bayerimage0=A0;
temp=zeros(x,y,1);
temp=A0(:,:,1)+A0(:,:,2)+A0(:,:,3);
A0=temp;%A0变成转换好了的bayer照片，尺寸是x*y*1
clear temp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%将原始图像x*y*3分成4个子图120*160*1,分别是b分量，两个g分量，r分量像素集合
for i=2-1:2:x-1
    for j=2-1:2:y-1
        A0_color{1}((i+1)/2,(j+1)/2)=A0(i,j);%A0_color{1}是BAY格式的图像中b分量元素单独提取出来组成的图像，大小为0.5x*0.5y*1
    end
end
        
for i=2-1:2:x-1
    for j=2:2:y
        A0_color{2}((i+1)/2,j/2)=A0(i,j);%A0_color{2}是BAY格式的图像中g分量(滤波阵列右上角的那个G)元素单独提取出来组成的图像，大小为0.5x*0.5y*1
    end
end

for i=2:2:x
    for j=2-1:2:y-1
        A0_color{3}(i/2,(j+1)/2)=A0(i,j);%A0_color{3}是BAY格式的图像中g分量(滤波阵列左下角的那个G)元素单独提取出来组成的图像，大小为0.5x*0.5y*1
    end
end

for i=2:2:x
    for j=2:2:y
        A0_color{4}(i/2,j/2)=A0(i,j);%A0_color{4}是BAY格式的图像中r分量元素单独提取出来组成的图像，大小为0.5x*0.5y*1
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对4个BAYER分量图进行水平滤波
for i=2:y/2
    A0_color{1}(:,i)=round((A0_color{1}(:,i-1)+A0_color{1}(:,i))/2);
    A0_color{2}(:,i)=round((A0_color{2}(:,i-1)+A0_color{2}(:,i))/2);
    A0_color{3}(:,i)=round((A0_color{3}(:,i-1)+A0_color{3}(:,i))/2);
    A0_color{4}(:,i)=round((A0_color{4}(:,i-1)+A0_color{4}(:,i))/2);
end
    
%对4个BAYER分量图进行垂直滤波
for i=2:x/2
    A0_color{1}(i,:)=round((A0_color{1}(i-1,:)+A0_color{1}(i,:))/2);
    A0_color{2}(i,:)=round((A0_color{2}(i-1,:)+A0_color{2}(i,:))/2);
    A0_color{3}(i,:)=round((A0_color{3}(i-1,:)+A0_color{3}(i,:))/2);
    A0_color{4}(i,:)=round((A0_color{4}(i-1,:)+A0_color{4}(i,:))/2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%分小区域取图作为计算单位

for m=1:4 %4个颜色分量图
    for n=1:0.25*x*y/(6*40)  %每个颜色分量图片上的子图区域共有0.25*x*y/(6*40)个
        A=A0_color{m}(6*(ceil(n/(0.5*y/40))-1)+1:6*ceil(n/(0.5*y/40)),40*(mod((n-1),(0.5*y/40)))+1:40*(mod((n-1),(0.5*y/40))+1)); %A是整体图像0.5x*0.5y*1上的一个6*40*1小区域，是算法中图像处理的基本单位        
        [JPEGLS_coderoutput1,JPEGLS_coderoutput2]=losslessJPEG_coder(A,Errorquant,step);
        totaloutput=strcat(totaloutput,JPEGLS_coderoutput1,JPEGLS_coderoutput2);
    end
end

TotalCompressionRatio=x*y*8/length(totaloutput{1})%总体压缩率
clear A JPEGLS_coderoutput1 JPEGLS_coderoutput2 n A1 Errorquant A0 i j m filter A0_color step;

       
        