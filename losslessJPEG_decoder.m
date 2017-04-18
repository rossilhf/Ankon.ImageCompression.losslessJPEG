%本程序用于将压缩后传输出来的二进制数据流进行解码，恢复重建原有的图像
%解码所用的数据包括：
%码表（A1.luminance,A1.huffmancode），数据流(JPEGLS_coderoutput1)
%码表（Errorquant.luminance,Errorquant.huffmancode），数据流(JPEGLS_coderoutput2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%恢复图像2:end行，2:end列的预测误差数据
buff=''; %用来暂存二进制数据流
count=1;%计数用
for i=1:length(JPEGLS_coderoutput2{1})
    buff=strcat(buff,JPEGLS_coderoutput2{1}(i));%每传输一个二进制数，就压入buff
    for j=1:length(Errorquant.huffmancode)
        if strcmp(buff,Errorquant.huffmancode(j))%如果buff内容与码本中某个编码相同
            Re_Errorq_1D(count)=Errorquant.luminance(j);%则根据码本将十进制数值放入图像数据（1维排列）中
            count=count+1;
            buff='';%清空buff
            break
        end
    end
end

count=1;
for k=1:3
    for i=2:length(A(:,1,k)) %i表示图像上某像素的行数
        for j=2:length(A(1,:,k)) %j表示图像上某像素的列数
            Re_Errorq(i,j,k)=Re_Errorq_1D(count);%把Re_Errorq_1D上所有元素转移到上Re_Errorq上
            count=count+1;%Errorquant_1D是一维数组
        end
    end
end
%现在根据量化步长将Re_Errorq中元素还原成Re_Error元素
Re_Error=Re_Errorq;%量化步长为1
% Re_Error=Re_Errorq*2;%量化步长为2
% Re_Error=Re_Errorq*4;%量化步长为4



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%恢复图像第1行，第1列的像素数据
buff=''; %用来暂存二进制数据流
count=1;%计数用
for i=1:length(JPEGLS_coderoutput1{1})
    buff=strcat(buff,JPEGLS_coderoutput1{1}(i));%每传输一个二进制数，就压入buff
    for j=1:length(A1.huffmancode)
        if strcmp(buff,A1.huffmancode(j))%如果buff内容与码本中某个编码相同
            Re_A1_1D(count)=A1.luminance(j);%则根据码本将十进制数值放入图像数据（1维排列）中
            count=count+1;
            buff='';%清空buff
            break
        end
    end
end

count=1;
for k=1:3
    for j=1:length(A(1,:,k)) %j表示图像上某像素的列数
        Re_Error(1,j,k)=Re_A1_1D(count);%把原始图像的第一行像素数据存入Re_Error第一行中
        count=count+1;
    end
    for i=2:length(A(:,1,k))%i表示图像上某像素的行数
        Re_Error(i,1,k)=Re_A1_1D(count);%把原始图像的第一列像素数据存入Re_Error第一列中
        count=count+1;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%经过上述的处理，我们得到了Re_Error矩阵，大小为（图像行数x图像列数x3）
%该矩阵中，第一行第一列为原始图像数据（即与A矩阵第一行第一列相同），其余元素均为
%量化后的误差数据（即与Error对应元素相同）

%现在根据线性预测算法对Re_Error进行逆运算，恢复成Re_A矩阵
Re_A=Re_Error;
for k=1:3 %k表示图像的某分量                                                                
    for i=2:length(Re_A(:,1,k)) %i表示图像上某像素的行数
        for j=2:length(Re_A(1,:,k)) %j表示图像上某像素的列数
%             Re_A(i,j,k)=Re_A(i,j-1,k)-Re_A(i,j,k);%按照方式1重建图像A
%             Re_A(i,j,k)=Re_A(i-1,j,k)-Re_A(i,j,k);%按照方式2重建图像A   
%             Re_A(i,j,k)=Re_A(i-1,j-1,k)-Re_A(i,j,k);%按照方式3重建图像A 
%             Re_A(i,j,k)=Re_A(i-1,j,k)+Re_A(i,j-1,k)-Re_A(i-1,j-1,k)-Re_A(i,j,k);%按照方式4重建图像A
%             Re_A(i,j,k)=Re_A(i,j-1,k)+(Re_A(i-1,j,k)-Re_A(i-1,j-1,k))/2-Re_A(i,j,k);%按照方式5重建图像A
%             Re_A(i,j,k)=Re_A(i-1,j,k)+(Re_A(i,j-1,k)-Re_A(i-1,j-1,k))/2-Re_A(i,j,k);%按照方式6重建图像A
            Re_A(i,j,k)=(Re_A(i,j-1,k)+Re_A(i-1,j,k))/2-Re_A(i,j,k);%按照方式7重建图像A 
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%显示原始图像A和压缩后重建图像Re_A，并计算峰值信噪比PSNR
A=uint8(A);
Re_A=uint8(Re_A);%处理过程中将图像像素元素改成double精度，最后处理完了需要转换回uint8模式

A_1D=zeros(1,length(A(:,1,k))*length(A(1,:,k))*3);%图像A的一维输出
count=1;
for k=1:3
    for i=2:length(A(:,1,k)) %i表示图像上某像素的行数
        for j=2:length(A(1,:,k)) %j表示图像上某像素的列数
            A_1D(count)=A(i,j,k);%把Errorquant上所有元素转移到上Errorquant_1D上
            count=count+1;                %Errorquant_1D是一维数组
        end
    end
end

Re_A_1D=zeros(1,length(A(:,1,k))*length(A(1,:,k))*3);%图像A的一维输出
count=1;
for k=1:3
    for i=2:length(Re_A(:,1,k)) %i表示图像上某像素的行数
        for j=2:length(Re_A(1,:,k)) %j表示图像上某像素的列数
            Re_A_1D(count)=Re_A(i,j,k);%把Errorquant上所有元素转移到上Errorquant_1D上
            count=count+1;                %Errorquant_1D是一维数组
        end
    end
end

MSE=sum((A_1D-Re_A_1D).^2)/length(A_1D);
PSNR=10*log10((2^8-1)^2/MSE)%峰值信噪比
figure
subplot(1,2,1),subimage(A),title('原始图像A')
subplot(1,2,2),subimage(Re_A),title('压缩后重建图像Re_A')







