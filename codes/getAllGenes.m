%% 获取所方法与数据的RS与基因名及只含不重复基因（用于查询关联）的结果

clear; close all;

dirCAM = fullfile(pwd,'BDOK','GradCAM');        % GradCAM输出目录
dName = {'BD001','BD005'};                      % 数据文件主文件名
mtd = {'Sun','Yue','Chen','Ours'};              % 方法

outRG = fullfile(dirCAM,'RS_GenesBD.csv');
outG = fullfile(dirCAM,'GenesBD.csv');

genes = {};
for mtdNo = 1:4
    if mtd{mtdNo} == "Sun"  % Sun转换出来的图像是其它方法的两倍（即SNP个数加倍）
        continue;
    end
    
    for dNo = 1:2
        fc = importdata(fullfile(dirCAM,['SNPfour',mtd{mtdNo},dName{dNo},'.annot']));
        for i = 1:length(fc)
            s = textscan(fc{i},'%s\t%s\t%s\t%s %s');
            if s{5} ~= "=missense" && s{5} ~= "=MISSENSE" && s{5} ~= "." && s{5} ~= "=nonsense"
                genes = [genes;[s{2},s{5}]];
            end
%             s = regexp(fc{i},'\t','split');
        end
    end
end
% 去掉"("和"|"后的内容（此操作无法在上述循环的s{5}中完成）
for i = 1:length(genes)
    b = strfind(genes{i,2},'(');
    if ~isempty(b)
        genes{i,2} = genes{i,2}(1:b-1);
    else
        b = strfind(genes{i,2},'|');
        if ~isempty(b)
            genes{i,2} = genes{i,2}(1:b-1);
        end
    end
end

geneNames = genes(:,2);
geneNames = unique(geneNames);

% 保存
fid = fopen(outRG,'w');
for i = 1:length(genes)
    fprintf(fid,'%s,%s\n',genes{i,1},genes{i,2});
end
fclose(fid);

fid = fopen(outG,'w');
for i = 1:length(geneNames)
    fprintf(fid,'%s\n',geneNames{i});
end
fclose(fid);

