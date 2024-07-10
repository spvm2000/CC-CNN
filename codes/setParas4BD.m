%% 设置CNN参数
% imgLen, dim, pValue, validationImages,pStatus分别是：
% 正方形图像边长；图像维度（1：灰度图，3：彩图）；特征选择时的P（用于区别两个数据文件。1：0.01；5：0.05；）；
% 验证图像集；绘图状态（'none'：不绘图，'training-progress'：绘制）
function [layers, options] = setParas4BD(imgLen, dim, pValue, validationImages,pStatus)

if pValue == 1
    layers = [ ...
        imageInputLayer([imgLen imgLen dim],'name','input')
        
        convolution2dLayer(3,16,'Padding','same','name','conv1')
        batchNormalizationLayer('name','norm1')
        reluLayer('name','relu1')

        convolution2dLayer(3,32,'Padding','same','name','conv2')
        batchNormalizationLayer('name','norm2')
        reluLayer('name','relu2')
        
        convolution2dLayer(3,64,'Padding','same','name','conv3')
        batchNormalizationLayer('name','norm3')
        reluLayer('name','relu3')
        
        dropoutLayer(0.5,'name','drop')
        
        fullyConnectedLayer(2,'name','fc4')
        softmaxLayer('name','prob')
        classificationLayer('name','output')]
else
    layers = [ ...
        imageInputLayer([imgLen imgLen dim],'name','input')
        
        convolution2dLayer(3,16,'Padding','same','name','conv1')
        batchNormalizationLayer('name','norm1')
        reluLayer('name','relu1')
        
        maxPooling2dLayer(2,'Stride',2,'name','pool1')
        
        convolution2dLayer(3,32,'Padding','same','name','conv2')
        batchNormalizationLayer('name','norm2')
        reluLayer('name','relu2')
        
        maxPooling2dLayer(2,'Stride',2,'name','pool2')
        
        dropoutLayer(0.5,'name','drop')
        
        fullyConnectedLayer(2,'name','fc4')
        softmaxLayer('name','prob')
        classificationLayer('name','output')]
end

options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.001, ...
    'MaxEpochs',6, ...
    'Shuffle','every-epoch', ...
    'ValidationData',validationImages, ...
    'ValidationFrequency',1, ...
    'Verbose',false, ...
    'Plots',pStatus);   
end