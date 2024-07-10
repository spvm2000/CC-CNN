% clear; close all;

dirCAM = fullfile(pwd,'BDOK','GradCAM');        % GradCAM输出目录
dirData = fullfile(pwd,'data','BD');            % 数据目录
dName = {'BD001','BD005'};                      % 数据文件主文件名

rslst = {};
for i = 1:2
    rslst = [rslst;importdata(fullfile(dirData,[dName{i},'.bim']))];
end

rs = {};
for i = 1:length(rslst)
%     s = regexp(rslst{i},'\t','split');
    s = textscan(rslst{i},'%s\t%s\t%s\t%s\t%s\t%s');
    rs = [rs;s];
end

SNPlst = dir(fullfile(dirCAM,'*00*.txt'));
SNP = {};
for i = 1:length(SNPlst)
    SNP = [SNP;importdata(fullfile(dirCAM,SNPlst(i).name))];
end

SNP = unique(SNP);
lf = length(SNP);

fid = fopen(fullfile(dirCAM,'SNPPlink.txt'),'w');
fprintf(fid,'CHR\tSNP\tBP\tP\n');
for i = 1:lf
    fprintf(fid,'1\t%s\t%d\t0.005\n',char(SNP{i}),i);
end
fclose(fid);
