function ObjectiveFunction = createObjectiveFunction(imgLen,dim,FilterSize, ...
    dataNo, mtdName, trainingSet,validSet)
ObjectiveFunction = @valErrorFunction;
    function [valError, variableConstriants,fileName] = valErrorFunction( ...
            OptimizableVariables)
        
        %Define CNN network
        imageSize = [imgLen imgLen dim];
        numClasses = numel(unique(trainingSet.Labels));
        numFilters = round(32/sqrt( ...
            OptimizableVariables.SectionDepth));
        layers = [
            imageInputLayer(imageSize)
          
            convBlock(FilterSize,numFilters, ...
            OptimizableVariables.SectionDepth)  
            maxPooling2dLayer(2,'Stride',2,'Padding','same')
            
            convBlock(FilterSize,2*numFilters, ...
            OptimizableVariables.SectionDepth)
            maxPooling2dLayer(2,'Stride',2,'Padding','same')
            
            convBlock(FilterSize,4*numFilters, ...
            OptimizableVariables.SectionDepth)
            averagePooling2dLayer(8)
 
            fullyConnectedLayer(numClasses)
            softmaxLayer
            classificationLayer];
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
        %Data augmentation
%         pixelRange = [-4 4];
%         imageAugmenter = imageDataAugmenter( ...
%             'RandXReflection',true, ...
%             'RandXTranslation',pixelRange, ...
%             'RandYTranslation',pixelRange);
%         datasource = augmentedImageDatastore(imageSize,XTrain,YTrain, ...
%             'DataAugmentation',imageAugmenter);
        datasource = trainingSet;
        trainedNet = trainNetwork(datasource,layers,options);
        close(findall(groot,'Tag','NNET_CNN_TRAININGPLOT_FIGURE'))
        YPredicted = classify(trainedNet,validSet);
        valError = 1 - mean(YPredicted == validSet.Labels);
        if ~exist(fullfile(pwd,'~tmp','optNo.mat'), 'file')
            curNo = 1;
        else
            load(fullfile(pwd,'~tmp','optNo.mat'));
            curNo = curNo + 1;
        end
        fileName = fullfile(pwd,'~tmp',['data',num2str(dataNo),mtdName,'Fs',...
            num2str(FilterSize),'No',num2str(curNo),'err',num2str(valError),'.mat']);
        save(fileName,'trainedNet','valError','options');
        save(fullfile(pwd,'~tmp','optNo.mat'), 'curNo');
        variableConstriants = [];
    end
end

%%Define 
function layers = convBlock(FilterSize,numFilters,numConvLayers)
layers = [
    convolution2dLayer(FilterSize,numFilters,'Padding','same')
    batchNormalizationLayer
   reluLayer];
layers = repmat(layers,numConvLayers,1);
end