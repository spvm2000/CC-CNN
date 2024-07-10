%% 按方法、数据获取RS与基因名

% clear; close all;

dirCAM = fullfile(pwd,'BDOK','GradCAM');        % GradCAM输出目录
dName = {'BD001','BD005'};                      % 数据文件主文件名
mtd = {'Sun','Yue','Chen','Ours'};              % 方法


for mtdNo = 1:4
    if mtd{mtdNo} == "Sun"  % Sun转换出来的图像是其它方法的两倍（即SNP个数加倍）
        continue;
    end

    for dNo = 1:2
        gen = {};
        fc = importdata(fullfile(dirCAM,['SNPfour',mtd{mtdNo},dName{dNo},'.annot']));
        for i = 1:length(fc)
            s = textscan(fc{i},'%s\t%s\t%s\t%s %s');
%             s = regexp(fc{i},'\t','split');
            if s{5} ~= "=missense" && s{5} ~= "=MISSENSE" && s{5} ~= "." && s{5} ~= "=nonsense"
                gen = [gen;[s{2},s{5}]];
            end
        end
        gen = rmvChars(gen);

        % 保存
        fid = fopen(fullfile(dirCAM,['RS_Genes',mtd{mtdNo},dName{dNo},'.csv']),'w');
        fprintf(fid,'%s,%s,Assoc\n',gen{1,1},gen{1,2}); % 表头
        for i = 2:length(gen)
            fprintf(fid,'%s,%s\n',gen{i,1},gen{i,2});
        end
        fclose(fid);
    end
end

% 去掉"("和"|"后的内容（此操作无法在上述循环的s{5}中完成）
function [gene] = rmvChars(gen)
    for i = 1:length(gen)
        b = strfind(gen{i,2},'(');
        if ~isempty(b)
            gen{i,2} = gen{i,2}(1:b-1);
        else
            b = strfind(gen{i,2},'|');
            if ~isempty(b)
                gen{i,2} = gen{i,2}(1:b-1);
            end
        end
    end
    gene = gen;
end

% geneNames = genes(:,2);
% geneNames = unique(geneNames);
% 
% % 保存
% fid = fopen(outRG,'w');
% for i = 1:length(genes)
%     fprintf(fid,'%s,%s\n',genes{i,1},genes{i,2});
% end
% fclose(fid);
% 
% fid = fopen(outG,'w');
% for i = 1:length(geneNames)
%     fprintf(fid,'%s\n',geneNames{i});
% end
% fclose(fid);

