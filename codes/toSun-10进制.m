%% ��һ������ת�ɹ���18�ĻҶ�ͼ
% Q. Sun, Q. Yue, F. Zhu, et al. The Identification research of bipolar disorder based on CNN[J]. Journal of Physics: Conference Series, 2019, 1168(3):032125.
% s - ��������
% ����ֵ��������ͼ�����һ�в��㲿�ֲ�0��
function [img] = toSun(s)
% s�е�0-2��ʾAA��Aa,aa
s(s==0) = 5;
s(s==1) = 6;
s(s==2) = 10;

l = ceil(sqrt(length(s))); % ������ͼ��ı߳�
s=[s , zeros(1,l*l-length(s))];     % ��չ��l*l��ĩβ��0
img = uint8(reshape(s,l,l)');       % ת��l*l�Ҷ�ͼ�����
end