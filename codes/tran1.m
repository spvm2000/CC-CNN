% i=1;
% B=zeros(604);
% C=zeros(604);
for i=1:4000
    R=data1a(i,:);
    E=reshape(R,32,32);
    A=E';
    S=data1b(i,:);
    F=reshape(S,32,32);
    B=F';
    T=data1c(i,:);
    G=reshape(T,32,32);
    C=G';
    D=cat(3,C,B,A);
%     img=255*D;
%     I=im2double(img);
%     C=[C;B];
%     A=xdata3(i,:);
%     B=reshape(A,604,604);
%     m=604*(i-1)+1;
%     n=604*i;
%     A=P(m:n,:,:);
%     imtool(D);
%     I=getimage(imgca);
%     img=imresize(I,[227 227]);
    imwrite(D,['E:\aaasimproject3\test1\',int2str(i),'.bmp']);
%     imtool close all;
end