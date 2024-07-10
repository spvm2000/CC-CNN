function ObjectiveFunction = createObjectiveFunction4BDV5(imgLen,dim,~, ...
    dataNo, mtdName, trainingSet,validSet,dirTmp, dirVars)
ObjectiveFunction = @valErrorFunction;
    function [valError, variableConstriants,fileName] = valErrorFunction( ...
            OptimizableVariables)
        
        %Define CNN network
        FilterSize = 3:2:7;
        imageSize = [imgLen imgLen dim];
        numClasses = numel(unique(trainingSet.Labels));

        FSnum = 16;

        if dataNo == 1
            layers = [ ...
                imageInputLayer(imageSize,'name','input')
                
                convolution2dLayer(FilterSize(OptimizableVariables.FilterSizeNo), ...
                    FSnum,'Padding','same','name','conv1')
                batchNormalizationLayer('name','norm1')
                reluLayer('name','relu1')  
                maxPooling2dLayer(2,'Stride',2,'name','pool1')
                 
                convolution2dLayer(FilterSize(OptimizableVariables.FilterSizeNo), ...
                    FSnum*2,'Padding','same','name','conv2')
                batchNormalizationLayer('name','norm2')
                reluLayer('name','relu2')   
                maxPooling2dLayer(2,'Stride',2,'name','pool2')
    
                convolution2dLayer(FilterSize(OptimizableVariables.FilterSizeNo), ...
                    FSnum*4,'Padding','same','name','conv3')
                batchNormalizationLayer('name','norm3')
                reluLayer('name','relu3')  
                maxPooling2dLayer(2,'Stride',2,'name','pool3')
             
                dropoutLayer(0.5,'name','drop')
                
                fullyConnectedLayer(numClasses,'name','fc4')
                softmaxLayer('name','prob')
                classificationLayer('name','output')];
        else
            layers = [ ...
                imageInputLayer(imageSize,'name','input')
                
                convolution2dLayer(FilterSize(OptimizableVariables.FilterSizeNo), ...
                    FSnum,'Padding','same','name','conv1')
                batchNormalizationLayer('name','norm1')
                reluLayer('name','relu1')  
                maxPooling2dLayer(2,'Stride',2,'name','pool1')
                 
                convolution2dLayer(FilterSize(OptimizableVariables.FilterSizeNo), ...
                    FSnum*2,'Padding','same','name','conv2')
                batchNormalizationLayer('name','norm2')
                reluLayer('name','relu2')   
                maxPooling2dLayer(2,'Stride',2,'name','pool2')
    
                dropoutLayer(0.5,'name','drop')
                
                fullyConnectedLayer(numClasses,'name','fc4')
                softmaxLayer('name','prob')
                classificationLayer('name','output')];
        end

        miniBatchSize = 128;
        validationFrequency = floor(numel(trainingSet.Labels)/miniBatchSize);
        options = trainingOptions('sgdm', ...
            'InitialLearnRate',OptimizableVariables.InitialLearnRate, ...
            'Momentum',OptimizableVariables.Momentum, ...
            'MaxEpochs',60, ...
            'LearnRateSchedule','piecewise', ...
            'LearnRateDropPeriod',40, ...
            'LearnRateDropFactor',0.1, ...
            'MiniBatchSize',miniBatchSize, ...
            'L2Regularization',OptimizableVariables.L2Regularization, ...
            'Shuffle','every-epoch', ...
            'Verbose',false, ...         
            'ValidationData',validSet, ...
            'ValidationFrequency',validationFrequency);
        
        [trainedNet,trainedInfo] = trainNetwork(trainingSet,layers,options);
        close(findall(groot,'Tag','NNET_CNN_TRAININGPLOT_FIGURE'))
        YPredicted = classify(trainedNet,validSet);
        valError = 1 - mean(YPredicted == validSet.Labels);
        if ~exist(fullfile(pwd,'~tmp','optNo.mat'), 'file')
            curNo = 1;
        else
            load(fullfile(pwd,'~tmp','optNo.mat'));
            curNo = curNo + 1;
        end
        fileName = fullfile(dirVars,['data',num2str(dataNo),mtdName,'Fs',...
            num2str(FilterSize(OptimizableVariables.FilterSizeNo)),...
            'No',num2str(curNo),'err',num2str(valError),'.mat']);
        save(fileName,'trainedNet','valError','options','trainedInfo');
        save(fullfile(dirTmp,'optNo.mat'), 'curNo');
        variableConstriants = [];
    end
end

