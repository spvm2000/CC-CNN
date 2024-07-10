SNPlst = dir(fullfile(dirCAM,'*00*.txt'));
SNP = {};
for i = 1:length(SNPlst)
    SNP = [SNP;importdata(fullfile(dirCAM,SNPlst(i).name))];
end

SNP = unique(SNP);

lf = length(SNP);
n = round(lf/4);
for j = 1:4
    fid = fopen(fullfile(dirCAM,['SNPBDnorpt',num2str(j),'.txt']),'w');
    for i = ((j-1)*n+1):n*j
        if i <= lf
            fprintf(fid,'%s\n',char(SNP{i}));
        end
    end
    if j == 4 && i < lf
        for i = (i+1):lf
            fprintf(fid,'%s\n',char(SNP{i}));
        end
    end
    fclose(fid);
end