% act=xlsread('TTest.xlsx');
% act=TTest;
% act1=act';
% det=xlsread('YTest.xlsx');
% det=YTest;
% det1=det';

[mat,order] = confusionmat(act1,det1);
precise = mat(1,1)/(mat(1,1) + mat(2,1));
recall = mat(1,1)/(mat(1,1) + mat(1,2));
F1 = 2 * precise * recall/(precise + recall);
