%% ��һ������ת�ɹ���19�ĻҶ�ͼ
% Q. Yue, J. Yang, Q. Shu, et al. Convolutional Neural Network Visualization for Identification of Risk Genes in Bipolar Disorder[J]. Current Molecular Medicine, 2020, 20(6):429-441.
% s - ����������
% ����ֵ��������ͼ�����һ�в��㲿�ֲ�0��
function [img] = toYue(s)
% s�е�0-2��ʾAA��Aa,aa
s(s==0) = 25;
s(s==1) = 50;
s(s==2) = 125;

l = ceil(sqrt(length(s))); % ������ͼ��ı߳�
s=[s , zeros(1,l*l-length(s))];     % ��չ��l*l��ĩβ��0
% img = uint8(reshape(s,l,l)');       % ת��l*l�Ҷ�ͼ�����
img = reshape(s,l,l)';       % ת��l*l�Ҷ�ͼ�����
end