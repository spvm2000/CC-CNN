clear; close all; imtool close all; clc;rng('default');

dirRes = fullfile(pwd,'BDOK','Opt');            % 优化结果目录
dirCAM = fullfile(pwd,'BDOK','GradCAM');        % GradCAM输出目录
dirData = fullfile(pwd,'data','BD');            % 数据目录
dirImages = fullfile(dirData,'Images');         % 图像目录
mtd = {'Sun','Yue','Chen','Ours'};              % 方法
dName = {'BD001','BD005'};                      % 数据文件主文件名

netlst = dir(fullfile(dirRes,'*BestNet.mat'));
setlst = dir(fullfile(dirRes,'*Sets.mat'));

beginTime = datetime('now');
strBeginTime = [num2str(year(beginTime)),'-',num2str(month(beginTime)),'-', ...
    num2str(day(beginTime)),'-',num2str(hour(beginTime)),'：',num2str(minute(beginTime))];   % 开始时间字符串

disp(['运行开始于：',strBeginTime]);

tic

for netNo = 1:length(netlst)     % 网络循环 
    % 提取方法与数据名
    b = false;
    for i = 1:4
        if ~isempty(strfind(netlst(netNo).name, mtd{i}))
            mtdNo = i;% mtdNo = 1:4, 1:Sun; 2:Yue; 3:Chen; 4:Ours
            if ~isempty(strfind(netlst(netNo).name, dName{1}))
                dNo = 1;
            else
                dNo = 2;
            end
            b = true;
            break;
        end
    end

    if ~b
        error([netlst(netNo).name,'不是合法的网络文件']);
    end

    if mtd{mtdNo} == "Sun"  % Sun转换出来的图像是其它方法的两倍（即SNP个数加倍）
        continue;
    end

    % 找出对应的数据集文件名
    for i = 1:length(setlst)
        b = false;
        if ~isempty(strfind(setlst(i).name, mtd{mtdNo})) && ~isempty(strfind(setlst(i).name, dName{dNo}))
            dFn = setlst(i).name;
            b = true;
            break;
        end
    end
    if ~b
        error(['没有与',netlst(netNo).name,'对应的数据集文件']);
    end

    load(fullfile(dirRes,dFn),'testSet');     % 加载测试集
%     allImages = imageDatastore(fullfile(dirImages,dName{dNo},mtd{mtdNo}), ...
%             'IncludeSubfolders',true,'LabelSource', 'foldernames');
    if ~isempty(strfind(testSet.Files{1},'root')) % linux下的结果，需要转成windows路径
        n = strfind(testSet.Files{1},'data');
        for i = 1:length(testSet.Files)
            testSet.Files{i} = fullfile(pwd,testSet.Files{i}(n:end));
        end
    end

    imgLen = size(imread(testSet.Files{1}),1);   % 图像边长

    HeatMapRes = zeros(imgLen,imgLen,3);
    gradcamRes = zeros(imgLen,imgLen);
    load(fullfile(dirRes,netlst(netNo).name));

    for idx=1:length(testSet.Labels)
        img=readimage(testSet,idx);
        [class,score]=classify(BestNetwork.trainedNet,img);
%         ss = gradCAM(BestNetwork.trainedNet,img,class);
        lgraph = layerGraph(BestNetwork.trainedNet.Layers);   % 提取网络，以便后续操作
        Outputlayer =  lgraph.Layers(end);    % 提取输出层
        newlgraph = removeLayers(lgraph,lgraph.Layers(end).Name); % 删除输出层
        newNet = dlnetwork(newlgraph);    % 转回DL网络
        softmaxlayer = 'prob' ; % softmaxlayer
        activationlayer = 'pool3'; % layer you apply Grad-CAM
        dlImg = dlarray(single(img),'SSC');   % 图像转DL格式
        [conv_output,gradients] = dlfeval(@Gradient_function,newNet,dlImg,softmaxlayer,activationlayer,class); % 评估DL模型
        alpha = mean(gradients, [1 2]); % Global average pooling for getting neuron importance weights alpha
        linearcombination = sum(conv_output .* alpha, 3); %
        linearcombination = extractdata(linearcombination); % convert dlarray to single
        gradcam = max(linearcombination,0); % apply relu function
        %       gradcam1=gradcam;
        gradcam = imresize(gradcam, [imgLen imgLen], 'Method', 'bicubic'); % resize map to fit image
        
        % convert heatmap into image data
        if mtdNo == 4
          HeatMap = map2jpg(gradcam, [], 'jet');
        else
          HeatMap = map2jpg(gradcam);
        end

      
        if class=='1'
            gradcamRes = gradcam + gradcamRes;
            HeatMapRes = HeatMap + HeatMapRes;
        end
    end

    for i = 1:3 % 热图归一化
        HeatMapRes(:,:,i) = mapminmax(HeatMapRes(:,:,i),0,1);
    end
    HeatMapRes = uint8((im2double(img)*0.3+im2double(HeatMapRes)*0.5)*255); % overrap images
    imwrite(HeatMapRes,fullfile(dirCAM,[mtd{mtdNo},dName{dNo},'.png']));

    % 把结果展成向量
    n = imgLen*imgLen;
    gradcamRes = reshape(gradcamRes',n,1); % 转置不能少
    % 逆序排列
    [~,idx] = sort(gradcamRes,'descend');

    % 查找关联SNP
    n = round(n * 0.05); % top5%
    f = importdata(fullfile(dirData,[dName{dNo},'.bim']));
    lf = length(f);
    fid1 = fopen(fullfile(dirCAM,['SNPone',mtd{mtdNo},dName{dNo},'.txt']),'w');
    fid2 = fopen(fullfile(dirCAM,['SNPfour',mtd{mtdNo},dName{dNo},'.txt']),'w');
    fprintf(fid2,'CHR\tSNP\tBP\tP\n');
    for i = 1:n
        if idx(i) <= lf
            SNP = textscan(f{idx(i)},'%s\t%s\t%s\t%s\t%s\t%s');
            fprintf(fid1,'%s\n',char(SNP{2}));
            fprintf(fid2,'1\t%s\t%s\t0.005\n',char(SNP{2}),char(SNP{4}));
        end
    end
    fclose(fid1);
    fclose(fid2);
    
    disp(['网络',num2str(netNo),'完成，历时',num2str(toc),'秒。']);

%     [~,idx]=max(score);
end

% 拆成不重复的四等份
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
    if j == 4 && i < lf % 尾上可能还有几个
        for i = (i+1):lf
            fprintf(fid,'%s\n',char(SNP{i}));
        end
    end
    fclose(fid);
end

disp(['全部完成，历时',num2str(toc),'秒。']);


function [conv_output,gradients] = Gradient_function(net2,I2,softmaxlayer,activationlayer,class)
    [scores,conv_output] = predict(net2, I2, 'Outputs', {softmaxlayer, activationlayer}); % get score and output at defiend layer.
    loss = scores(class); %
    gradients = dlgradient(loss,conv_output); % get gradient of loss with respect to conv_output
    gradients = gradients / (sqrt(mean(gradients.^2,'all')) + 1e-5); % Normalization
end

function img = map2jpg(imgmap, range, colorMap)
    imgmap = double(imgmap);
    if(~exist('range', 'var') || isempty(range))
        range = [min(imgmap(:)) max(imgmap(:))];
    end
    heatmap_gray = mat2gray(imgmap, range);
    heatmap_x = gray2ind(heatmap_gray, 256);
    heatmap_x(isnan(imgmap)) = 0;
    
    if(~exist('colorMap', 'var'))
        img = ind2rgb(heatmap_x, jet(256));
    else
        img = ind2rgb(heatmap_x, eval([colorMap '(256)']));
    end
end




