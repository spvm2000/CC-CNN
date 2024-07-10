%% 把一个样本转成工作19的灰度图
% Q. Yue, J. Yang, Q. Shu, et al. Convolutional Neural Network Visualization for Identification of Risk Genes in Bipolar Disorder[J]. Current Molecular Medicine, 2020, 20(6):429-441.
% s - 样本行向量
% 返回值：正方形图像（最后一行不足部分补0）
function [img] = toYue(s)
% s中的0-2表示AA，Aa,aa
s(s==0) = 25;
s(s==1) = 50;
s(s==2) = 125;

l = ceil(sqrt(length(s))); % 正方形图像的边长
s=[s , zeros(1,l*l-length(s))];     % 扩展至l*l，末尾补0
% img = uint8(reshape(s,l,l)');       % 转成l*l灰度图像矩阵
img = reshape(s,l,l)';       % 转成l*l灰度图像矩阵
end