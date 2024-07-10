%% 把一个样本转成工作18的灰度图
% Q. Sun, Q. Yue, F. Zhu, et al. The Identification research of bipolar disorder based on CNN[J]. Journal of Physics: Conference Series, 2019, 1168(3):032125.
% s - 样本行向量
% 返回值：正方形图像（最后一行不足部分补0）
function [img] = toSun(s)
% s中的0-2表示AA，Aa,aa
ns = [];
for i = 1:length(s)
    switch s(i)
        case 0
            ss = [0,1,0,1];
        case 1
            ss = [0,1,1,0];
        case 2
            ss = [1,0,1,0];
    end
    ns = [ns, ss];
end

l = ceil(sqrt(length(ns))); % 正方形图像的边长
ns=[ns , zeros(1,l*l-length(ns))];     % 扩展至l*l，末尾补0
% img = uint8(reshape(ns,l,l)');       % 转成l*l灰度图像矩阵
img = reshape(ns,l,l)';       % 转成l*l灰度图像矩阵
end