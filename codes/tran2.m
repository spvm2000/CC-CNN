% i=1;
% B=zeros(604);
% C=zeros(604);
% data11=85*data11;
% data11=[data1,B];
for i=1:4000
    R=data11(i,:);
    E=reshape(R,32,32);
    A=E';
    C=mat2gray(A);
%     D=im2uint8(C);
    
%     C=[C;B];
%     A=xdata3(i,:);
%     B=reshape(A,604,604);
%     m=604*(i-1)+1;
%     n=604*i;
%     A=P(m:n,:,:);
%     imtool(A);
%     I=getimage(imgca);
%     img=imresize(I,[227 227]);
    imwrite(C,['E:\aaasimproject3\grayimages10\',int2str(i),'.bmp']);
%     imtool close all;
end