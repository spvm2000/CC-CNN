clear; close all; imtool close all; clc;rng('default')

allImages = imageDatastore('rgbimages2', 'IncludeSubfolders',true,'LabelSource', 'foldernames');
randImages=shuffle(allImages);
[trainingImages,testImages] = splitEachLabel(randImages,0.8,'randomized');
validationImages=testImages;

layers = [
    imageInputLayer([32 32 3],'name','input')
    
    convolution2dLayer(7,8,'Padding','same','name','conv1')
    batchNormalizationLayer('name','norm1')
    reluLayer('name','relu1')  
    maxPooling2dLayer(2,'Stride',2,'name','pool1')
     
    convolution2dLayer(7,16,'Padding','same','name','conv2')
    batchNormalizationLayer('name','norm2')
    reluLayer('name','relu2')   
    maxPooling2dLayer(2,'Stride',2,'name','pool2')
% %      
    convolution2dLayer(7,32,'Padding','same','name','conv3')
    batchNormalizationLayer('name','norm3')
    reluLayer('name','relu3')  
    maxPooling2dLayer(2,'Stride',2,'name','pool3')
 
    dropoutLayer(0.5,'name','drop')
    
    fullyConnectedLayer(2,'name','fc4')
    softmaxLayer('name','prob')
    classificationLayer('name','output')]

% 'MiniBatchSize',miniBatchSize, ...
options = trainingOptions('adam', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',20, ...
    'Shuffle','every-epoch', ...
    'ValidationData',validationImages, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

[net,info] = trainNetwork(trainingImages,layers,options);
save('rgbmynet1.mat','net');
save('rgbtestImages1.mat','testImages');

[YTest,myscores] = classify(net,testImages);
TTest = testImages.Labels;
accuracy = sum(YTest == TTest)/numel(YTest)

% figure
% plot(x,y,'Color',[0,0.7,0.9])
% 
% title('2-D Line Plot')
% xlabel('x')
% ylabel('cos(5x)')

% idx = 100;
% img = readimage(testImages, idx);
% result = classify(net,img);
% subplot(1,2,1),imshow(img)
% title(string(result),'FontSize',20);
% idx2 = 200;
% img2 = readimage(testImages, idx2);
% result2 = classify(net,img2);
% subplot(1,2,2),imshow(img2)
% title(string(result2),'FontSize',20);shg

% YPred = classify(net,testImages);
% YValidation = testImages.Labels;
% 
% accuracy = sum(YPred == YValidation)/numel(YValidation)