%本程序通过大量肠道图像来统计肠道图像中各颜色数值（线性预测误差数值）的分布状况
num=313;%总共200张照片





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%统计图像第一行第一列的亮度数值分布
A1.count=zeros(1,256);
for l=1:num 
    fname=sprintf('%d.bmp',l);
    A=double(imread(fname));%载入图像
    %同时将像素元素从uint8转化成double，要不然数值范围只有0~255
    A=A(80:220,80:220,1:3);%该项目中图像的标准尺寸为240x320，程序测试时为了节省时间，可能采用较小的图片         
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    A1.luminance=0:1:255;%Errorquant.luminance对应着像素亮度    
    A1.count=A1.count+hist(A1_1D,A1.luminance);%A1.count亮度出现的次数，越大表示该亮度值出现越频繁
%     [A1.count,index]=sort(A1.count);%A1.count按亮度值出现频繁程度排序，由低到高
%     A1.luminance=A1.luminance(index);%A1.luminance也同样顺序排列    
end 
save A1.mat A1
clear A1;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%统计图像除了第一行第一列以外部分的线性预测值分布,量化步长1
Errorquant.count=zeros(1,511);
for l=1:num
    fname=sprintf('%d.bmp',l);
    A=double(imread(fname));%载入图像
    %同时将像素元素从uint8转化成double，要不然数值范围只有0~255
    A=A(80:220,80:220,1:3);%该项目中图像的标准尺寸为240x320，程序测试时为了节省时间，可能采用较小的图片    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %对Error中的元素进行量化，采用线性量化                                      
    Errorq=round(Error);%Errorq表示量化后的Error矩阵，量化步长1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %统计Errorq矩阵中各元素数值的概率分布                                                
    Errorquant_1D=zeros(1,length(A(:,1,k))*length(A(1,:,k))*3);%图像的一维输出
    count=1;
    for k=1:3
        for i=2:length(A(:,1,k)) %i表示图像上某像素的行数
            for j=2:length(A(1,:,k)) %j表示图像上某像素的列数
                Errorquant_1D(count)=Errorq(i,j,k);%把Errorquant上所有元素转移到上Errorquant_1D上
                count=count+1;                %Errorquant_1D是一维数组
            end
        end
    end
    Errorquant.luminance=-255:1:255;%Errorquant.luminance对应着像素亮度     
    Errorquant.count=Errorquant.count+hist(Errorquant_1D,Errorquant.luminance);%Errorquant.count亮度出现的次数，越大表示该亮度值出现越频繁
%     [Errorquant.count,index]=sort(Errorquant.count);%Errorquant.count按亮度值出现频繁程度排序，由低到高
%     Errorquant.luminance=Errorquant.luminance(index);%Errorquant.luminance也同样顺序排列
end
save Errorquant_step1.mat Errorquant
clear Errorquant





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%统计图像除了第一行第一列以外部分的线性预测值分布,量化步长2
Errorquant.count=zeros(1,257);
for l=1:num
    fname=sprintf('%d.bmp',l);
    A=double(imread(fname));%载入图像
    %同时将像素元素从uint8转化成double，要不然数值范围只有0~255
    A=A(80:220,80:220,1:3);%该项目中图像的标准尺寸为240x320，程序测试时为了节省时间，可能采用较小的图片    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %对Error中的元素进行量化，采用线性量化                                      
    Errorq=round(Error/2);%Errorq表示量化后的Error矩阵，量化步长2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %统计Errorq矩阵中各元素数值的概率分布                                                
    Errorquant_1D=zeros(1,length(A(:,1,k))*length(A(1,:,k))*3);%图像的一维输出
    count=1;
    for k=1:3
        for i=2:length(A(:,1,k)) %i表示图像上某像素的行数
            for j=2:length(A(1,:,k)) %j表示图像上某像素的列数
                Errorquant_1D(count)=Errorq(i,j,k);%把Errorquant上所有元素转移到上Errorquant_1D上
                count=count+1;                %Errorquant_1D是一维数组
            end
        end
    end
    Errorquant.luminance=-128:1:128;%Errorquant.luminance对应着像素亮度     
    Errorquant.count=Errorquant.count+hist(Errorquant_1D,Errorquant.luminance);%Errorquant.count亮度出现的次数，越大表示该亮度值出现越频繁
%     [Errorquant.count,index]=sort(Errorquant.count);%Errorquant.count按亮度值出现频繁程度排序，由低到高
%     Errorquant.luminance=Errorquant.luminance(index);%Errorquant.luminance也同样顺序排列
end
save Errorquant_step2.mat Errorquant
clear Errorquant




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%统计图像除了第一行第一列以外部分的线性预测值分布,量化步长4
Errorquant.count=zeros(1,129);
for l=1:num
    fname=sprintf('%d.bmp',l);
    A=double(imread(fname));%载入图像
    %同时将像素元素从uint8转化成double，要不然数值范围只有0~255
    A=A(80:220,80:220,1:3);%该项目中图像的标准尺寸为240x320，程序测试时为了节省时间，可能采用较小的图片    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %对Error中的元素进行量化，采用线性量化                                      
    Errorq=round(Error/4);%Errorq表示量化后的Error矩阵，量化步长4
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %统计Errorq矩阵中各元素数值的概率分布                                                
    Errorquant_1D=zeros(1,length(A(:,1,k))*length(A(1,:,k))*3);%图像的一维输出
    count=1;
    for k=1:3
        for i=2:length(A(:,1,k)) %i表示图像上某像素的行数
            for j=2:length(A(1,:,k)) %j表示图像上某像素的列数
                Errorquant_1D(count)=Errorq(i,j,k);%把Errorquant上所有元素转移到上Errorquant_1D上
                count=count+1;                %Errorquant_1D是一维数组
            end
        end
    end
    Errorquant.luminance=-64:1:64;%Errorquant.luminance对应着像素亮度     
    Errorquant.count=Errorquant.count+hist(Errorquant_1D,Errorquant.luminance);%Errorquant.count亮度出现的次数，越大表示该亮度值出现越频繁
%     [Errorquant.count,index]=sort(Errorquant.count);%Errorquant.count按亮度值出现频繁程度排序，由低到高
%     Errorquant.luminance=Errorquant.luminance(index);%Errorquant.luminance也同样顺序排列
end
save Errorquant_step4.mat Errorquant
clear Errorquant
