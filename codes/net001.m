clear; close all; imtool close all; clc;rng('default')

allImages = imageDatastore('images001', 'IncludeSubfolders',true,'LabelSource', 'foldernames');
randImages=shuffle(allImages);
[trainingImages,testImages] = splitEachLabel(randImages,0.8,'randomized');
validationImages=testImages;

layers = [
    imageInputLayer([71 71 3],'name','input')
    
    convolution2dLayer(3,16,'Padding','same','name','conv1')
    batchNormalizationLayer('name','norm1')
    reluLayer('name','relu1')
    
%     maxPooling2dLayer(2,'Stride',2,'name','pool1')
    
    convolution2dLayer(3,32,'Padding','same','name','conv2')
    batchNormalizationLayer('name','norm2')
    reluLayer('name','relu2')
    
%     maxPooling2dLayer(2,'Stride',2,'name','pool2')
    
    convolution2dLayer(3,64,'Padding','same','name','conv3')
    batchNormalizationLayer('name','norm3')
    reluLayer('name','relu3')
    
%     maxPooling2dLayer(2,'Stride',2,'name','pool3')
    
%     dropoutLayer(0.5,'name','drop')
%     
%     
%     convolution2dLayer(3,64,'Padding','same','name','conv4')
%     batchNormalizationLayer('name','norm4')
%     reluLayer('name','relu4')
    
    fullyConnectedLayer(2,'name','fc4')
    softmaxLayer('name','prob')
    classificationLayer('name','output')]

options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.001, ...
    'MaxEpochs',6, ...
    'Shuffle','every-epoch', ...
    'ValidationData',validationImages, ...
    'ValidationFrequency',1, ...
    'Verbose',false, ...
    'Plots','training-progress');

[net,info] = trainNetwork(trainingImages,layers,options);
save('mynet001.mat','net');
save('testImages001.mat','testImages');

[YTest,myscores] = classify(net,testImages);
TTest = testImages.Labels;
accuracy = sum(YTest == TTest)/numel(YTest)

% figure
% plot(x,y,'Color',[0,0.7,0.9])
% 
% title('2-D Line Plot')
% xlabel('x')
% ylabel('cos(5x)')

idx = 100;
img = readimage(testImages, idx);
result = classify(net,img);
subplot(1,2,1),imshow(img)
title(string(result),'FontSize',20);
idx2 = 200;
img2 = readimage(testImages, idx2);
result2 = classify(net,img2);
subplot(1,2,2),imshow(img2)
title(string(result2),'FontSize',20);shg

% YPred = classify(net,testImages);
% YValidation = testImages.Labels;
% 
% accuracy = sum(YPred == YValidation)/numel(YValidation)