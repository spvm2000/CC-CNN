%% 直接使用仿真数据得到的最优模型测试（由于仿真集图像大小为32*32，小于真实数据图像大小，无法实现预测）

clear; close all; imtool close all; clc;rng('default');

% 开关变量
% 是否使用GPU并行运算开关变量。
% 1）若GPU内存不足，频繁在主存与显存中交换数据，导致速度下降。
% 2）当采用增强后的图像训练网络时，由于图像文件结构的格式不同，导致不能使用GPU。
usedGPU = false; 

creatImg = false;

%创建临时工作目录
dirTmp = fullfile(pwd,'~tmp');
if ~exist(dirTmp,'dir')
    mkdir(dirTmp);
    mkdir(fullfile(dirTmp,'0'));    % 存放ctrl图片
    mkdir(fullfile(dirTmp,'1'));    % 存放case图片
else
    if ~exist(fullfile(dirTmp,'0'),'dir')
        mkdir(fullfile(dirTmp,'0'));    % 存放ctrl图片
    end
    if ~exist(fullfile(dirTmp,'1'),'dir')
        mkdir(fullfile(dirTmp,'1'));    % 存放case图片
    end
end

% 创建结果目录
dirRes = fullfile(pwd,'BDres');   % 结果目录
dirEval = fullfile(dirRes,'eval_noOpt');  % 存放Function Evaluation图片
dirVars = fullfile(dirRes,'vars_noOpt');  % 存放中间变量
if ~exist(dirRes,'dir')
    mkdir(dirRes);
end

if ~exist(dirEval,'dir')
    mkdir(dirEval);    
end
if ~exist(dirVars,'dir')
    mkdir(dirVars);    
end

mtd = {'Sun','Yue','Chen','Ours'};  % 方法
dName = {'BD001','BD005'};          % 数据文件主文件名
% 数据目录
dirData = fullfile(pwd,'data','BD');
dirImages = fullfile(dirData,'Images');
if ~exist(dirImages,'dir')
    mkdir(dirImages);    
end
for i = 1:4
    for j = 1:2
        if ~exist(fullfile(dirImages,dName{j}),'dir')
            mkdir(fullfile(dirImages,dName{j}));    
        end
        if ~exist(fullfile(dirImages,dName{j},mtd{i}),'dir')
            mkdir(fullfile(dirImages,dName{j},mtd{i}));    
        end
        if ~exist(fullfile(dirImages,dName{j},mtd{i},'0'),'dir')
            mkdir(fullfile(dirImages,dName{j},mtd{i},'0'));    
        end
        if ~exist(fullfile(dirImages,dName{j},mtd{i},'1'),'dir')
            mkdir(fullfile(dirImages,dName{j},mtd{i},'1'));    
        end
    end
end

% 变量
results = zeros(2,4,4);             % 2：2个数据集；4：Accuracy、Precision、Recall、F1；4：4种方法
results = results + (-1);           % -1表示"完全无网络"

beginTime = datetime('now');
strBeginTime = [num2str(year(beginTime)),'-',num2str(month(beginTime)),'-', ...
    num2str(day(beginTime)),'-',num2str(hour(beginTime)),'：',num2str(minute(beginTime))];   % 开始时间字符串

disp(['运行开始于：',strBeginTime]);

tic
netlst = dir(fullfile(pwd,'results','x','*.mat'));

for netNo = 1:length(netlst)     % 网络循环 
    b = false;
    for i = 1:4
        if strfind(netlst(netNo).name, mtd{i}) > 0
            mtdNo = i;% mtdNo = 1:4, 1:Sun; 2:Yue; 3:Chen; 4:Ours
            b = true;
            break;
        end
    end

    if ~b
        error([netlst(netNo).name,'不是合法的网络文件']);
    end

    for dNo = 1:2 % 数据集循环
        if creatImg
            creatBDImages(fullfile(dirData,[dName{dNo},'.txt']),dName{dNo},mtd{mtdNo},dirImages);
        end

        allImages = imageDatastore(fullfile(dirImages,dName{dNo},mtd{mtdNo}), ...
            'IncludeSubfolders',true,'LabelSource', 'foldernames');
        imgLen = size(imread(allImages.Files{1}),1);   % 图像边长
        
        disp(['正在为数据集',dName{dNo},'使用方法', mtd{mtdNo},'作CNN预测，请稍候...']);
        if mtdNo == 4
            dim = 3;
        else
            dim = 1;
        end
        
        % 测试网络
        % results维度(2,4,4)         
        % 2：2个数据集；4：Accuracy、Precision、Recall、F1；4：4种方法
        
        % 加载网络
        load(fullfile(netlst(netNo).folder,netlst(netNo).name));
        predictY = classify(BestNetwork.trainedNet,allImages);
        results(dNo,1,mtdNo) = sum(predictY == allImages.Labels)/numel(predictY);    % Accuracy
        mat = confusionmat(testSet.Labels,predictY);                                % mat = [TP,FN;FP,TN]
        results(dNo,2,mtdNo) = mat(1,1)/(mat(1,1) + mat(2,1));                     % Precision = TP/(TP+FP)
        results(dNo,3,mtdNo) = mat(1,1)/(mat(1,1) + mat(1,2));                     % Recall = TP/(TP+FN)
        results(dNo,4,mtdNo) = 2 * results(dNo,2,mtdNo) * ...
            results(dNo,3,mtdNo)/(results(dNo,2,mtdNo) + results(dNo,3,mtdNo));  % F1

        disp(['数据集',dName{dNo},'使用方法',mtd{mtdNo},'时的评测指标为：']);
        fprintf('Accuracy\tPrecision\tRecall\t\tF1\n');
        disp('______________________________________________');
        fprintf('%7.6f\t%7.6f\t%7.6f\t%7.6f\n',...
            results(dNo,1,mtdNo),results(dNo,2,mtdNo),results(dNo,3,mtdNo),results(dNo,4,mtdNo));
    end
end

% 保存结果
save(fullfile(dirRes,['results',strBeginTime]), 'results');

% 转成二维表格保存
% results维度(10,4,4)         
% 10：10个数据集；4：Accuracy、Precision、Recall、F1；4：4种方法
res = table({},[],[],[],[],[],'VariableNames',{'Method','DataNo','Accuracy','Precision','Recall','F1'});
n = 1;
for i = 1:4             % Method
    for j = 1:10        % DataNo
        res(n,:) = {mtd{i},j,results(j,1,i),results(j,2,i),results(j,3,i),results(j,4,i)};
        n = n + 1;
    end
end
writetable(res,fullfile(dirRes, ['BD', strBeginTime,'Optimize-FilterNum16-64.csv']));

disp(['CNN训练、测试于',datestr(datetime('now')),'完成，历时',num2str(toc),'秒。']);

if exist(fullfile(dirTmp,recoveryVar), 'file')
    old = [recoveryVar(1:(strfind(recoveryVar,'.')-1)),'Old.mat'];
    if exist(fullfile(dirTmp,old), 'file')
        delete(fullfile(dirTmp,old));
    end
    movefile(fullfile(dirTmp,recoveryVar),fullfile(dirTmp,old),"f");
end

