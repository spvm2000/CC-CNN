%% ��һ������ת�ɹ���18�ĻҶ�ͼ
% Q. Sun, Q. Yue, F. Zhu, et al. The Identification research of bipolar disorder based on CNN[J]. Journal of Physics: Conference Series, 2019, 1168(3):032125.
% s - ����������
% ����ֵ��������ͼ�����һ�в��㲿�ֲ�0��
function [img] = toSun(s)
% s�е�0-2��ʾAA��Aa,aa
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

l = ceil(sqrt(length(ns))); % ������ͼ��ı߳�
ns=[ns , zeros(1,l*l-length(ns))];     % ��չ��l*l��ĩβ��0
% img = uint8(reshape(ns,l,l)');       % ת��l*l�Ҷ�ͼ�����
img = reshape(ns,l,l)';       % ת��l*l�Ҷ�ͼ�����
end