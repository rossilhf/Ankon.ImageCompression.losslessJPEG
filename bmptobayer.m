%该程序包含部分有：1，将普通照片等转换为BAYER格式的照片(240x320x3)
%                 2，将BAYER格式照片中不同颜色分量单独分离出来，成为4个子图(120x160x1)
%                 3，对4个子图进行低通滤波
%                 4，对4个子图进行逆滤波
%                 5，将4个子图重组回到BAYER格式照片中
%                 6，对BAYER格式照片进行插值，恢复成普通RGB颜色照片
%其中第1 2 3部分在图像编码之前运行，第4 5 6部分在图像解码之后运行

A0=double(imread('sample2.bmp'));%载入图像
A0=A0(1:240,1:320,:);%标准图像大小为240x320

% figure
% imagesc(A0);


filter(:,:,1)=[1 0;0 0];%bayer彩色滤波阵列R分量
filter(:,:,2)=[0 1;1 0];%bayer彩色滤波阵列G分量
filter(:,:,3)=[0 0;0 1];%bayer彩色滤波阵列B分量


%bayer彩色滤波阵列格式
%  R  G
%  G  B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%将普通GRB颜色照片转成BAYER格式照片
for i=1:120%行数，每个滤波阵列为2x2,图像有240行，所以需要循环120次
    for j=1:160%列数，循环160次
        BAY(2*i-1:2*i,2*j-1:2*j,:)=A0(2*i-1:2*i,2*j-1:2*j,:).*filter;%BAY矩阵是转换好了的bayer格式照片，尺寸还是240x320x3
    end
end

% figure
% imagesc(BAY);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%将原始图像240x320x3分成4个子图120x160x1,分别是R分量，两个G分量，B分量像素集合
for i=2-1:2:240-1
    for j=2-1:2:320-1
        BAYr((i+1)/2,(j+1)/2)=BAY(i,j,1);%BAYr是BAY格式的图像中r分量元素单独提取出来组成的图像，大小为120x160x1
    end
end
        
for i=2-1:2:240-1
    for j=2:2:320
        BAYg1((i+1)/2,j/2)=BAY(i,j,2);%BAYg1是BAY格式的图像中g分量(滤波阵列右上角的那个G)元素单独提取出来组成的图像，大小为120x160x1
    end
end

for i=2:2:240
    for j=2-1:2:320-1
        BAYg2(i/2,(j+1)/2)=BAY(i,j,2);%BAYb是BAY格式的图像中g分量(滤波阵列左下角的那个G)元素单独提取出来组成的图像，大小为120x160x1
    end
end

for i=2:2:240
    for j=2:2:320
        BAYb(i/2,j/2)=BAY(i,j,3);%BAYb是BAY格式的图像中b分量元素单独提取出来组成的图像，大小为120x160x1
    end
end

% figure
% imagesc(BAYr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对4个BAYER分量子图进行水平滤波
for i=2:160
    BAYr(:,i)=round((BAYr(:,i-1)+BAYr(:,i))/2);
    BAYg1(:,i)=round((BAYg1(:,i-1)+BAYg1(:,i))/2);
    BAYg2(:,i)=round((BAYg2(:,i-1)+BAYg2(:,i))/2);
    BAYb(:,i)=round((BAYb(:,i-1)+BAYb(:,i))/2);
end
    
%对4个BAYER分量子图进行垂直滤波
for i=2:120
    BAYr(i,:)=round((BAYr(i-1,:)+BAYr(i,:))/2);
    BAYg1(i,:)=round((BAYg1(i-1,:)+BAYg1(i,:))/2);
    BAYg2(i,:)=round((BAYg2(i-1,:)+BAYg2(i,:))/2);
    BAYb(i,:)=round((BAYb(i-1,:)+BAYb(i,:))/2);
end

% figure
% imagesc(BAYr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对分量子图进行垂直逆滤波
for i=120:-1:2
    BAYr(i,:)=2*BAYr(i,:)-BAYr(i-1,:);
    BAYg1(i,:)=2*BAYg1(i,:)-BAYg1(i-1,:);
    BAYg2(i,:)=2*BAYg2(i,:)-BAYg2(i-1,:);
    BAYb(i,:)=2*BAYb(i,:)-BAYb(i-1,:);
end

%对分量子图进行水平逆滤波
for i=160:-1:2
    BAYr(:,i)=2*BAYr(:,i)-BAYr(:,i-1);
    BAYg1(:,i)=2*BAYg1(:,i)-BAYg1(:,i-1);
    BAYg2(:,i)=2*BAYg2(:,i)-BAYg2(:,i-1);
    BAYb(:,i)=2*BAYb(:,i)-BAYb(:,i-1);
end
        
% figure
% imagesc(BAYr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%将4个分量子图120x160x1组合成为完整的BAYER格式图像240x320x3
BAY=zeros(240,320,3);

for i=2-1:2:240-1
    for j=2-1:2:320-1
        BAY(i,j,1)=BAYr((i+1)/2,(j+1)/2);%r分量元素恢复到BAY图像中
    end
end
        
for i=2-1:2:240-1
    for j=2:2:320
        BAY(i,j,2)=BAYg1((i+1)/2,j/2);%g分量(滤波阵列右上角的那个G)元素恢复到BAY图像中
    end
end

for i=2:2:240
    for j=2-1:2:320-1
        BAY(i,j,2)=BAYg2(i/2,(j+1)/2);%g分量(滤波阵列左下角的那个G)元素恢复到BAY图像中
    end
end

for i=2:2:240
    for j=2:2:320
        BAY(i,j,3)=BAYb(i/2,j/2);%b分量元素恢复到BAY图像中
    end
end

% figure
% imagesc(BAY);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%对BAYER格式照片进行插值，恢复成为RGB颜色照片
for i=2:2:238
    BAY(i,:,1)=(BAY(i-1,:,1)+BAY(i+1,:,1))/2;
end
BAY(240,:,1)=BAY(239,:,1);

for i=2:2:318
    BAY(:,i,1)=(BAY(:,i-1,1)+BAY(:,i+1,1))/2;
end
BAY(:,320,1)=BAY(:,319,1);       %将BAYER照片中R分量插值恢复


for i=3:2:239
    BAY(i,:,3)=(BAY(i-1,:,3)+BAY(i+1,:,3))/2;
end
BAY(1,:,3)=BAY(2,:,3);

for i=3:2:319
    BAY(:,i,3)=(BAY(:,i-1,3)+BAY(:,i+1,3))/2;
end
BAY(:,1,3)=BAY(:,2,3);           %将BYAER照片中B分量插值恢复

BAY(1,1,2)=(BAY(2,1,2)+BAY(1,2,2))/2;
BAY(240,320,2)=(BAY(240,319,3)+BAY(239,320,2))/2;
for i=2:239
    if BAY(i,1,2)==0
        BAY(i,1,2)=(BAY(i+1,1,2)+BAY(i,2,2))/2;
    end
    if BAY(i,320,2)==0
        BAY(i,320,2)=(BAY(i-1,320,2)+BAY(i,319,2))/2;
    end
end
for j=2:319
    if BAY(1,j,2)==0
        BAY(1,j,2)=(BAY(2,j,2)+BAY(1,j+1,2))/2;
    end
    if BAY(240,j,2)==0
        BAY(240,320,2)=(BAY(239,j,2)+BAY(240,j-1,2))/2;
    end
end
for i=2:239
    for j=2:319
        if BAY(i,j,2)==0
            BAY(i,j,2)=(BAY(i+1,j,2)+BAY(i,j+1,2)+BAY(i-1,j,2)+BAY(i,j-1,2))/4;
        end
    end
end                              %将BYAER照片中G分量插值恢复

figure
imagesc(uint8(A0));
figure
imagesc(uint8(BAY));

