%% 每种方法、每个数据集都优化网络（优化核大小。记录每种方法、每个数据集、每种核大小的所有测试结果
% 构造目标函数有三种方法，修改COfun以选择所需方法。

clear; close all; imtool close all; clc;rng('default');

% 是否使用GPU并行运算开关变量。
% 1）若GPU内存不足，频繁在主存与显存中交换数据，导致速度下降。
% 2）当采用增强后的图像训练网络时，由于图像文件结构的格式不同，导致不能使用GPU。
usedGPU = false; 

% 建立优化目录函数
COfun = str2func('createObjectiveFunctionV5');

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
dirRes = fullfile(pwd,'results');   % 结果目录
dirEval = fullfile(dirRes,'eval');  % 存放Function Evaluation图片
dirVars = fullfile(dirRes,'vars');  % 存放中间变量
if ~exist(dirRes,'dir')
    mkdir(dirRes);
end

if ~exist(dirEval,'dir')
    mkdir(dirEval);    
end
if ~exist(dirVars,'dir')
    mkdir(dirVars);    
end

% 数据目录
dirData = fullfile(pwd,'data');

% 删除优化次数编号变量文件
if exist(fullfile(dirTmp,'optNo.mat'), 'file')
    delete(fullfile(dirTmp,'optNo.mat'));
end

% 变量
switch func2str(COfun)
    case "createObjectiveFunctionV4"
        OptimizableVariables = [        % CNN优化参数
            optimizableVariable('InitialLearnRate',[1e-3 1],'Transform','log')
            optimizableVariable('Momentum',[0.9 0.98])
            optimizableVariable('L2Regularization',[1e-10 1e-2],'Transform','log')];
        results = zeros(10,4,3,4);      % 10：10个数据集；4：Accuracy、Precision、Recall、F1；3：3种核大小（1-3：3、5、7）；4：4种方法
    case "createObjectiveFunctionV5"
        OptimizableVariables = [        % CNN优化参数
            optimizableVariable('FilterSizeNo',[1 3],'Type','integer')
            optimizableVariable('InitialLearnRate',[1e-3 1],'Transform','log')
            optimizableVariable('Momentum',[0.9 0.98])
            optimizableVariable('L2Regularization',[1e-10 1e-2],'Transform','log')];
        results = zeros(10,4,4);          % 10：10个数据集；4：Accuracy、Precision、Recall、F1；4：4种方法

    otherwise
        OptimizableVariables = [        % CNN优化参数
            optimizableVariable('SectionDepth',[1 3],'Type','integer')
            optimizableVariable('InitialLearnRate',[1e-1 1],'Transform','log')
            optimizableVariable('Momentum',[0.9 0.98])
            optimizableVariable('L2Regularization',[1e-10 1e-2],'Transform','log')];
        results = zeros(10,4,3,4);      % 10：10个数据集；4：Accuracy、Precision、Recall、F1；3：3种核大小（1-3：3、5、7）；4：4种方法
        
end

mtd = {'Sun','Yue','Chen','Ours'};  % 方法
FilterSize = 3:2:7;                 % 三种卷积核(Filter)大小

results = results + (-1);           % -1表示"完全无网络"
noNet = zeros(10,4,3);              % 记录优化后是否存在无优化网络（0：有最优网络；1：有次优网络；2：完全无网络），
                                    % 三维分别是数据集号、方法号、FilterSize号（1-3：3、5、7）

mm = 1;                             % mm = 1:4, 1:Sun; 2:Yue; 3:Chen; 4:Ours
hasLoaded = 0;                      % 如果前面的运行中止，则提取原来保存的变量（mm, dd, FilterSize, res, predictSame）继续运行
FSno = 1;

beginTime = datetime('now');
disp(['运行开始于：',datestr(beginTime)]);

tic
while 1     
    dd = 1;     % dd = 1:10
    while 1 
        if exist(fullfile(dirTmp,'myvariablesV6.mat'), 'file') && ~hasLoaded
            load(fullfile(dirTmp,'myvariablesV6.mat'));
            hasLoaded = 1;
            if dd >= 10
                break;
            end
        end

        data = importdata(fullfile(dirData,['data',num2str(dd), '.txt']));
        x = data(:,2:end);
        y = data(:,1);
        clear data;
        
        disp(['正在为方法',mtd{mm},'重建数据集',num2str(dd),'的图像，请稍候...']);
        % 清空临时目录
        delete(fullfile(dirTmp,'0','*.*'));
        if length(dir(fullfile(dirTmp,'0','*.*'))) > 2
            error([fullfile(dirTmp,'0','*.*'),'无法删除']); % 若无法清空，matlab仅给出警告，从而导致后续结果不正确
        end
        delete(fullfile(dirTmp,'1','*.*'));
        if length(dir(fullfile(dirTmp,'1','*.*'))) > 2
            error([fullfile(dirTmp,'1','*.*'),'无法删除']);
        end

        for i = 1:size(x,1)
            switch mm
                case 1
                    img = toSun(x(i,:));
                case 2
                    img = toYue(x(i,:));
                case 3
                    img = toChen(x(i,:));
                case 4
                    img = toOurs3(x(i,:));
            end
            imwrite(img./256, fullfile(dirTmp,num2str(y(i)),[num2str(i), '.bmp']))
        end
        disp('图像重建完成');
        clear x y;
        
        allImages = imageDatastore(dirTmp, 'IncludeSubfolders',true,'LabelSource', 'foldernames');
        imgLen = size(imread(allImages.Files{1}),1);   % 图像边长
        
        if mm == 1
            randImages=shuffle(allImages);
            [trainingSet,validSet,testSet] = splitEachLabel(randImages,0.6,0.2,'randomized');
            save(fullfile(dirVars,['data',num2str(dd),'Sets.mat']),'trainingSet','validSet','testSet');
        else
            clear trainingSet validSet testSet;
            load(fullfile(dirVars,['data',num2str(dd),'Sets.mat']));
        end
        
        disp(['正在为数据集',num2str(dd),'使用方法', mtd{mm},'优化、测试CNN，请稍候...']);
        if mm == 4
            dim = 3;
        else
            dim = 1;
        end
        
        if usedGPU
            % 需要做以下操作，否则多次并行操作后会出错
            delete(gcp('nocreate')); % 关闭并行池
            if exist('/root/.matlab/local_cluster_jobs','dir')
                rmdir('/root/.matlab/local_cluster_jobs','s');  % 删除并行池目录
            end
            if exist('/root/.matlab/local_scheduler_data','dir')
                rmdir('/root/.matlab/local_scheduler_data','s');  % 删除并行池预取目录
            end
        end

        % 创建优化目标函数
        ObjectiveFunction = COfun(imgLen, dim, FilterSize(FSno), ...
            dd, mtd{mm}, trainingSet, validSet,dirTmp,dirVars);%,OptimizableVariables);
        % 执行Bayes优化
        BayesObject = bayesopt(ObjectiveFunction,OptimizableVariables, ...
            'MaxObjectiveEvaluations',10,...
            'MaxTime',0.5*60*240, ...    
            'UseParallel',usedGPU, ... 
            'OutputFcn', {@saveToFile}, ...
            'SaveFileName', fullfile(dirVars,...
                ['BayesoptRes_data',num2str(dd),mtd{mm},'.mat']));

        saveas(gcf,fullfile(dirEval, ...
            ['FuncEval_data',num2str(dd),mtd{mm},'.png']), 'png');

        % 获取最佳网络
%                 BestIdx = BayesObject.IndexOfMinimumTrace(end);
%                 FileName = BayesObject.UserDataTrace{BestIdx};
%                 BestNetwork = load(FileName);
        % 以上方法有时最后个会出现没有BestNetwork.trainedNet的情况
        hasBestNet = 0;
        for i = 0:9
            BestIdx = BayesObject.IndexOfMinimumTrace(end-i);
            FileName = BayesObject.UserDataTrace{BestIdx};
            BestNetwork = load(FileName);
%               if exist('BestNetwork.trainedNet','var')
%               BestNetwork是结构体，不能用以上方法
            if isfield(BestNetwork,'trainedNet')
                hasBestNet = 1;
                if i > 0
                    noNet(dd,mm) = 1;    % 存在次优网络
                end
                break;
            end
        end
        
        if exist(fullfile(dirTmp,'optNo.mat'), 'file')
            delete(fullfile(dirTmp,'optNo.mat'));
        end

        % 测试网络
        if hasBestNet
            if func2str(COfun) == "createObjectiveFunctionV5"
                % results维度(10,4,4)         
                % 10：10个数据集；4：Accuracy、Precision、Recall、F1；4：4种方法
                fprintf('数据集%d使用方法%s的最佳网络文件（idx = %d）为：\n%s\n',...
                    dd,mtd{mm},BestIdx,FileName);
                % 保存网络
                save(fullfile(dirVars,['data',num2str(dd),mtd{mm},'BestNet.mat']), 'BestNetwork');
    
                predictY = classify(BestNetwork.trainedNet,testSet);
                results(dd,1,mm) = sum(predictY == testSet.Labels)/numel(predictY);    % Accuracy
                mat = confusionmat(testSet.Labels,predictY);                                % mat = [TP,FN;FP,TN]
                results(dd,2,mm) = mat(1,1)/(mat(1,1) + mat(2,1));                     % Precision = TP/(TP+FP)
                results(dd,3,mm) = mat(1,1)/(mat(1,1) + mat(1,2));                     % Recall = TP/(TP+FN)
                results(dd,4,mm) = 2 * results(dd,2,mm) * ...
                    results(dd,3,mm)/(results(dd,2,mm) + results(dd,3,mm));  % F1
    
                disp(['数据集',num2str(dd),'使用方法',mtd{mm},'时的评测指标为：']);
                fprintf('Accuracy\tPrecision\tRecall\t\tF1\n');
                disp('______________________________________________');
                fprintf('%7.6f\t%7.6f\t%7.6f\t%7.6f\n',...
                    results(dd,1,mm),results(dd,2,mm),results(dd,3,mm),results(dd,4,mm));

                % 保存的变量（mm, dd, res, predictSame），以便中止后能继续运行
            save(fullfile(dirTmp,'myvariablesV6'),'mm','dd','results');
            else
                % results维度(10,4,3,4)         
                % 10：10个数据集；4：Accuracy、Precision、Recall、F1；3：3种核大小（1-3：3、5、7）；4：4种方法
                fprintf('数据集%d使用方法%s、卷积核大小为%d的最佳网络文件（idx = %d）为：\n%s\n',...
                    dd,mtd{mm},FilterSize(FSno),BestIdx,FileName);
                % 保存网络
                save(fullfile(dirVars,['data',num2str(dd),mtd{mm},'Fs',num2str(FilterSize(FSno)),'BestNet.mat']), 'BestNetwork');

                predictY = classify(BestNetwork.trainedNet,testSet);
                results(dd,1,FSno,mm) = sum(predictY == testSet.Labels)/numel(predictY);    % Accuracy
                mat = confusionmat(testSet.Labels,predictY);                                % mat = [TP,FN;FP,TN]
                results(dd,2,FSno,mm) = mat(1,1)/(mat(1,1) + mat(2,1));                     % Precision = TP/(TP+FP)
                results(dd,3,FSno,mm) = mat(1,1)/(mat(1,1) + mat(1,2));                     % Recall = TP/(TP+FN)
                results(dd,4,FSno,mm) = 2 * results(dd,2,FSno,mm) * ...
                    results(dd,3,FSno,mm)/(results(dd,2,FSno,mm) + results(dd,3,FSno,mm));  % F1

                disp(['数据集',num2str(dd),'使用方法',mtd{mm},'、卷积核大小为',num2str(FilterSize(FSno)),'时的评测指标为：']);
                fprintf('Accuracy\tPrecision\tRecall\t\tF1\n');
                disp('______________________________________________');
                fprintf('%7.6f\t%7.6f\t%7.6f\t%7.6f\n',...
                    results(dd,1,FSno,mm),results(dd,2,FSno,mm),results(dd,3,FSno,mm),results(dd,4,FSno,mm));
    
                % 保存的变量（mm, dd, FilterSize, res, predictSame），以便中止后能继续运行
                save(fullfile(dirTmp,'myvariablesV5'),'mm','dd','FSno','results');
            end
            hasLoaded = 1;      % 不可少，否则返回循环时会被读取，从引起重复一轮循环
        else
            noNet(dd,mm) = 2;    % 无网络
            fprintf('数据集%d使用方法%s的训练无网络文件\n',dd,mtd{mm});
        end
        dd = dd + 1;
        if dd > 10
            break;
        end
    end
    
    mm = mm + 1;
    if mm > 4
        break;
    end
end

% 保存结果
st = [num2str(year(beginTime)),'-',num2str(month(beginTime)),'-', ...
    num2str(day(beginTime)),'-',num2str(hour(beginTime)),'：',num2str(minute(beginTime))];   % 开始时间字符串
save(fullfile(dirRes,['results',st]), 'results');

% 转成二维表格保存
if func2str(COfun) == "createObjectiveFunctionV5"
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
else
    % results维度(10,4,3,4)         
    % 10：10个数据集；4：Accuracy、Precision、Recall、F1；3：3种核大小（1-3：3、5、7）；4：4种方法
    res = table({},[],[],[],[],[],[],'VariableNames',{'Method','DataNo','FilterSize','Accuracy','Precision','Recall','F1'});
    n = 1;
    for i = 1:4             % Method
        for j = 1:10        % DataNo
            for  k = 1:3    % FSno
                res(n,:) = {mtd{i},j,FilterSize(k),results(j,1,k,i),results(j,2,k,i),results(j,3,k,i),results(j,4,k,i)};
                n = n + 1;
            end
        end
    end
end
writetable(res,fullfile(dirRes, ['Simulation', st,'.csv']));

disp(['CNN训练、测试于',datestr(datetime('now')),'完成，历时',num2str(toc),'秒。']);

if exist(fullfile(dirTmp,'myvariablesV6.mat'), 'file')
    if exist(fullfile(dirTmp,'myvariablesV6Old.mat'), 'file')
        delete(fullfile(dirTmp,'myvariablesV6Old.mat'));
    end
    movefile(fullfile(dirTmp,'myvariablesV6.mat'),fullfile(dirTmp,'myvariablesV6Old.mat'));
end

