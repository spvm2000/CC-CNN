%% 把一个样本转成工作18的灰度图
% Q. Sun, Q. Yue, F. Zhu, et al. The Identification research of bipolar disorder based on CNN[J]. Journal of Physics: Conference Series, 2019, 1168(3):032125.
% s - 样本向量
% 返回值：正方形图像（最后一行不足部分补0）
function [img] = toSun(s)
% s中的0-2表示AA，Aa,aa
s(s==0) = 5;
s(s==1) = 6;
s(s==2) = 10;

l = ceil(sqrt(length(s))); % 正方形图像的边长
s=[s , zeros(1,l*l-length(s))];     % 扩展至l*l，末尾补0
img = uint8(reshape(s,l,l)');       % 转成l*l灰度图像矩阵
end