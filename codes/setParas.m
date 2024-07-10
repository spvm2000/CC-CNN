%% 设置CNN参数
% imgLen, dim, filterSize, validationImages,pStatus分别是：
% 正方形图像边长；图像维度（1：灰度图，3：彩图）；卷积核大小；验证图像集；绘图状态（'none'：不绘图，'training-progress'：绘制）
function [layers, options] = setParas(imgLen, dim, filterSize, validationImages,pStatus)
layers = [ ...
    imageInputLayer([imgLen imgLen dim],'name','input')
    
    convolution2dLayer(filterSize,8,'Padding','same','name','conv1')
    batchNormalizationLayer('name','norm1')
    reluLayer('name','relu1')  
    maxPooling2dLayer(2,'Stride',2,'name','pool1')
     
    convolution2dLayer(filterSize,16,'Padding','same','name','conv2')
    batchNormalizationLayer('name','norm2')
    reluLayer('name','relu2')   
    maxPooling2dLayer(2,'Stride',2,'name','pool2')
% %      
    convolution2dLayer(filterSize,32,'Padding','same','name','conv3')
    batchNormalizationLayer('name','norm3')
    reluLayer('name','relu3')  
    maxPooling2dLayer(2,'Stride',2,'name','pool3')
 
    dropoutLayer(0.5,'name','drop')
    
    fullyConnectedLayer(2,'name','fc4')
    softmaxLayer('name','prob')
    classificationLayer('name','output')];

% 'MiniBatchSize',miniBatchSize, ...
options = trainingOptions('adam', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',20, ...
    'Shuffle','every-epoch', ...
    'ValidationData',validationImages, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots',pStatus);   
end