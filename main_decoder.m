%按照6x40的大小依次读取图像的各个部分
%图像大小为x*y,共读取48次

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global bayerimage0
load codebook_step1_fordecoder%载入码本
step=1;%压缩步长为2
x=240;%图像的行数
y=320;%图像的列数
z=0;%ROI起始行数
w=0;%ROI起始列数
q=0;%ROI结束行数
p=0;%ROI结束列数

for m=1:4 %4个色彩分量图0.5x*0.5y*1
    for n=1:0.25*x*y/(6*40) %每个色彩分量图上有0.25*x*y/(6*40)个6x40x1子图
        t0=cputime;%开始计时
        [Re_A,totaloutput]=losslessJPEG_decoder(Errorquant,totaloutput,step);
        Re_A0_color{m}(6*(ceil(n/(0.5*y/40))-1)+1:6*ceil(n/(0.5*y/40)),40*(mod((n-1),(0.5*y/40)))+1:40*(mod((n-1),(0.5*y/40))+1))=Re_A;%图像的解码
        time=cputime-t0%计时结束
    end
end
clear Errorquant t0 time step

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对彩色分量图进行垂直逆滤波
for i=x/2:-1:2
    Re_A0_color{1}(i,:)=2*Re_A0_color{1}(i,:)-Re_A0_color{1}(i-1,:);
    Re_A0_color{2}(i,:)=2*Re_A0_color{2}(i,:)-Re_A0_color{2}(i-1,:);
    Re_A0_color{3}(i,:)=2*Re_A0_color{3}(i,:)-Re_A0_color{3}(i-1,:);
    Re_A0_color{4}(i,:)=2*Re_A0_color{4}(i,:)-Re_A0_color{4}(i-1,:);
end

%对彩色分量图进行水平逆滤波
for i=y/2:-1:2
    Re_A0_color{1}(:,i)=2*Re_A0_color{1}(:,i)-Re_A0_color{1}(:,i-1);
    Re_A0_color{2}(:,i)=2*Re_A0_color{2}(:,i)-Re_A0_color{2}(:,i-1);
    Re_A0_color{3}(:,i)=2*Re_A0_color{3}(:,i)-Re_A0_color{3}(:,i-1);
    Re_A0_color{4}(:,i)=2*Re_A0_color{4}(:,i)-Re_A0_color{4}(:,i-1);
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%将4个分量子图0.5x*0.5y*1组合成为完整的BAYER格式图像x*y*3
Re_A0=zeros(x,y,3);

for i=2-1:2:x-1
    for j=2-1:2:y-1
        Re_A0(i,j,3)=Re_A0_color{1}((i+1)/2,(j+1)/2);%b分量元素恢复到Re_A0图像中
    end
end
        
for i=2-1:2:x-1
    for j=2:2:y
        Re_A0(i,j,2)=Re_A0_color{2}((i+1)/2,j/2);%g分量(滤波阵列右上角的那个G)元素恢复到Re_A0图像中
    end
end

for i=2:2:x
    for j=2-1:2:y-1
        Re_A0(i,j,2)=Re_A0_color{3}(i/2,(j+1)/2);%g分量(滤波阵列左下角的那个G)元素恢复到Re_A0图像中
    end
end

for i=2:2:x
    for j=2:2:y
        Re_A0(i,j,1)=Re_A0_color{4}(i/2,j/2);%b分量元素恢复到Re_A0图像中
    end
end
subplot(2,2,3),subimage(uint8(Re_A0)),title('恢复BAYER图像Re_A0')
bayerimage1=Re_A0;%计算PSNR用的参数，实际使用时可删除

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对BAYER格式照片进行插值，恢复成为RGB颜色照片
for i=2:2:x-2
    Re_A0(i,:,3)=(Re_A0(i-1,:,3)+Re_A0(i+1,:,3))/2;
end
Re_A0(x,:,3)=Re_A0(x-1,:,3);

for i=2:2:y-2
    Re_A0(:,i,3)=(Re_A0(:,i-1,3)+Re_A0(:,i+1,3))/2;
end
Re_A0(:,y,3)=Re_A0(:,y-1,3);       %将Re_A0照片中B分量插值恢复


for i=3:2:x-1
    Re_A0(i,:,1)=(Re_A0(i-1,:,1)+Re_A0(i+1,:,1))/2;
end
Re_A0(1,:,1)=Re_A0(2,:,1);

for i=3:2:y-1
    Re_A0(:,i,1)=(Re_A0(:,i-1,1)+Re_A0(:,i+1,1))/2;
end
Re_A0(:,1,1)=Re_A0(:,2,1);           %将Re_A0照片中R分量插值恢复

Re_A0(1,1,2)=(Re_A0(2,1,2)+Re_A0(1,2,2))/2;
Re_A0(x,y,2)=(Re_A0(x,y-1,2)+Re_A0(x-1,y,2))/2;
for i=2:x-1
    if Re_A0(i,1,2)==0
        Re_A0(i,1,2)=(Re_A0(i+1,1,2)+Re_A0(i,2,2))/2;
    end
    if Re_A0(i,y,2)==0
        Re_A0(i,y,2)=(Re_A0(i-1,y,2)+Re_A0(i,y-1,2))/2;
    end
end
for j=2:y-1
    if Re_A0(1,j,2)==0
        Re_A0(1,j,2)=(Re_A0(2,j,2)+Re_A0(1,j+1,2))/2;
    end
    if Re_A0(x,j,2)==0
        Re_A0(x,j,2)=(Re_A0(x-1,j,2)+Re_A0(x,j-1,2))/2;
    end
end
for i=2:x-1
    for j=2:y-1
        if Re_A0(i,j,2)==0
            Re_A0(i,j,2)=(Re_A0(i+1,j,2)+Re_A0(i,j+1,2)+Re_A0(i-1,j,2)+Re_A0(i,j-1,2))/4;
        end
    end
end %将Re_A0照片中G分量插值恢复

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%画图，计算PSNR
A0=double(imread('sample3.bmp'));%载入图像，标准图像大小为x*y
subplot(2,2,2),subimage(uint8(A0)),title('原始RGB图像A0')
Re_A0=uint8(Re_A0);%处理过程中将图像像素元素改成double精度，最后处理完了需要转换回uint8模式
subplot(2,2,4),subimage(Re_A0),title('恢复RGB图像Re_A0')

A0_1D=zeros(1,x*y*3);%图像A0的一维输出
count=1;
for k=1:3
    for i=1:x %i表示图像上某像素的行数
        for j=1:y %j表示图像上某像素的列数
            A0_1D(count)=bayerimage0(i,j,k);%把Errorquant上所有元素转移到上Errorquant_1D上
            count=count+1;                %Errorquant_1D是一维数组
        end
    end
end

Re_A0_1D=zeros(1,x*y*3);%恢复图像Re_A0的一维输出
count=1;
for k=1:3
    for i=1:x %i表示图像上某像素的行数
        for j=1:y %j表示图像上某像素的列数
            Re_A0_1D(count)=bayerimage1(i,j,k);%把Errorquant上所有元素转移到上Errorquant_1D上
            count=count+1;                %Errorquant_1D是一维数组
        end
    end
end
MSE=sum((A0_1D-Re_A0_1D).^2)/length(A0_1D);
PSNR=10*log10((2^8-1)^2/MSE)%峰值信噪比
subplot(2,2,1),subimage(uint8(bayerimage0)),title('原始BAYER图像A0')
clear A0_1D Re_A0_1D count i j k MSE Re_A n totaloutput A0 Re_A0 A0_color Re_A0_color filter m;