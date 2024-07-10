%% 根据查询结果，按方法、数据匹配基因的关联

% clear; close all;

dirCAM = fullfile(pwd,'BDOK','GradCAM');        % GradCAM输出目录
dName = {'BD001','BD005'};                      % 数据文件主文件名
mtd = {'Sun','Yue','Chen','Ours'};              % 方法

% 拼接四个查询文件
qry = {};
for i = 1:4
    [~,fc,~] = xlsread(fullfile(dirCAM,['GenesBD',num2str(i),'.xlsx']));
    fc(1,:) = []; % 删除表头
    qry = [qry;fc];
end
clear fc;
% 清除空格
for i = 1:length(qry)
    qry{i,2} = strip(qry{i,2});
end

for mtdNo = 1:4
    if mtd{mtdNo} == "Sun"  % Sun转换出来的图像是其它方法的两倍（即SNP个数加倍）
        continue;
    end

    for dNo = 1:2
        [~,fc,~] = xlsread(fullfile(dirCAM,['RS_Genes',mtd{mtdNo},dName{dNo},'.csv']));
        for i = 2:length(fc)
%             s = textscan(fc{i},'%s\t%s\t%s\t%s %s');
%             s = regexp(fc{i,:},',','split');
            n = find(qry==strcat(fc{i,2},"")); % 必须用strcat拼一个空串才能变成双引号的字串
            if ~isempty(n)
                if ~isempty(qry{n,2})
                    fc{i,3} = 'True';
                end
            end
        end

        % 保存
        fid = fopen(fullfile(dirCAM,['RS_GenesMatched',mtd{mtdNo},dName{dNo},'.csv']),'w');
%         fprintf(fid,'%s,%s,Assoc\n',gen{1,1},gen{1,2}); % 表头
        for i = 1:length(fc)
            fprintf(fid,'%s,%s,%s\n',fc{i,1},fc{i,2},fc{i,3});
        end
        fclose(fid);
    end
end

% 匹配
% function [matched] = mathGene(genes,name)
%     for i = 1:length(genes)
%         b = strfind(genes{i,2},'(');
%         if ~isempty(b)
%             genes{i,2} = genes{i,2}(1:b-1);
%         else
%             b = strfind(genes{i,2},'|');
%             if ~isempty(b)
%                 genes{i,2} = genes{i,2}(1:b-1);
%             end
%         end
%     end
%     matched = genes;
% end

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

