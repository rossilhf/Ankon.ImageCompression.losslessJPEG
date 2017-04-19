%本程序用于将压缩后传输出来的二进制数据流进行解码，恢复重建原有的图像

function [Re_A,totaloutput]=losslessJPEG_decoder(Errorquant,totaloutput,step)
% global totaloutput
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%恢复图像第1行，第1列的像素数据
buff=''; %用来暂存二进制数据流
count=1;%计数用
i=1;
while count<=40+5 %第一行和第一列的所有数据。因为图像是6*40的尺寸，第一行第一列的数据共40+5个
    buff=strcat(buff,totaloutput{1}(i:i+7));%每次传输8个二进制数压入buff。因为第一行第一列数据是固定8bit码长。
    i=i+8;
    Re_A1_1D(count)=bin2dec(buff);%则根据码本将十进制数值放入图像数据（1维排列）中
    count=count+1;
    buff='';%清空buff 
end

Re_Error(1,1:40)=Re_A1_1D(1:40);%把原始图像的第一行像素数据存入Re_Error第一行中
Re_Error(2:6,1)=Re_A1_1D(41:45);%把原始图像的第一列像素数据存入Re_Error第一列中

clear Re_A1_1D;
totaloutput{1}(1:i-1)=[];%将二进制数据流已经载入解码器的部分清除

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%恢复图像2:end行，2:end列的预测误差数据
buff=[];
count=1;%计数用
ii=0;
s=Errorquant.tree;
count1=1;
while count<=5*39;%图像除了第一行第一列的其余部分像素
    ii=ii+1;
    if totaloutput{1}(ii)=='0'
        buff(count1)=1;%每传输一个二进制数，就压入buff
    else
        buff(count1)=2;%每传输一个二进制数，就压入buff
    end 
    count1=count1+1;
    s=s{buff(count1-1)};
    
    if isa(s,'double')%如果buff内容与码本中某个编码相同
        Re_Errorq_1D(count)=s;%则根据码本将十进制数值放入图像数据（1维排列）中
        count=count+1;
        count1=1;
        buff=[];%清空buff
        s=Errorquant.tree;
    end
end
clear s count1 buff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

count=1;
for i=2:6 %i表示图像上某像素的行数
    for j=2:40 %j表示图像上某像素的列数
        Re_Errorq(i,j)=Re_Errorq_1D(count);%把Re_Errorq_1D上所有元素转移到上Re_Errorq上
        count=count+1;%Errorquant_1D是一维数组
    end
end

clear Re_Errorq_1D;
totaloutput{1}(1:ii)=[];%将二进制数据流已经载入解码器的部分清除
% length(totaloutput{1})%查错用

%现在根据量化步长将Re_Errorq中元素还原成Re_Error元素
Re_Error(2:end,2:end)=Re_Errorq(2:end,2:end)*step;%量化步长为step
clear Re_Errorq step ii;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%经过上述的处理，我们得到了Re_Error矩阵，大小为（6x40x3）
%该矩阵中，第一行第一列为原始图像数据（即与A矩阵第一行第一列相同），其余元素均为
%量化后的误差数据（即与Error对应元素相同）

%现在根据线性预测算法对Re_Error进行逆运算，恢复成Re_A矩阵
Re_A=Re_Error;
clear Re_Error;
                                                             
    for i=2:length(Re_A(:,1)) %i表示图像上某像素的行数
        for j=2:length(Re_A(1,:)) %j表示图像上某像素的列数
%             Re_A(i,j)=Re_A(i,j-1)-Re_A(i,j);%按照方式1重建图像A
%             Re_A(i,j)=Re_A(i-1,j)-Re_A(i,j);%按照方式2重建图像A   
%             Re_A(i,j)=Re_A(i-1,j-1)-Re_A(i,j);%按照方式3重建图像A 
%             Re_A(i,j)=Re_A(i-1,j)+Re_A(i,j-1)-Re_A(i-1,j-1)-Re_A(i,j);%按照方式4重建图像A
%             Re_A(i,j)=Re_A(i,j-1)+(Re_A(i-1,j)-Re_A(i-1,j-1))/2-Re_A(i,j);%按照方式5重建图像A
%             Re_A(i,j)=Re_A(i-1,j)+(Re_A(i,j-1)-Re_A(i-1,j-1))/2-Re_A(i,j);%按照方式6重建图像A
            Re_A(i,j)=(Re_A(i,j-1)+Re_A(i-1,j))/2-Re_A(i,j);%按照方式7重建图像A 
        end
    end
    
clear i j







