% load('rgbmynet2');
% load('rgbtestImages2');
% idx = 1;
HeatMap2=zeros(32,32,3);
gradcam2=zeros(32,32);
% result1=zeros(71,71);
TTest=testImages.Labels;
for idx=1:800
    img=readimage(testImages,idx);
%     testlabel=TTest(idx,1);
    [class,score]=classify(net,img);
    img3=img;
%    img = readimage(testImages, idx);
%   result = classify(convnet,img);
  lgraph = layerGraph(net.Layers);
  Outputlayer =  lgraph.Layers(end);
  newlgraph = removeLayers(lgraph,lgraph.Layers(end).Name);
  net2 = dlnetwork(newlgraph);
  softmaxlayer = 'prob' ; % softmaxlayer
  activationlayer = 'pool3'; % layer you apply Grad-CAM
  img4 = dlarray(single(img3),'SSC');
  [conv_output,gradients] = dlfeval(@Gradient_function,net2,img4,softmaxlayer,activationlayer,class);
  alpha = mean(gradients, [1 2]); % Global average pooling for getting neuron importance weights alpha
  linearcombination = sum(conv_output .* alpha, 3); %
  linearcombination = extractdata(linearcombination); % convert dlarray to single
  gradcam = max(linearcombination,0); % apply relu function
  gradcam1=gradcam;
  gradcam = imresize(gradcam, [32 32], 'Method', 'bicubic'); % resize map to fit image
  HeatMap = map2jpg(gradcam, [], 'jet'); % convert heatmap into image data
  HeatMap1 = uint8((im2double(img3)*0.3+HeatMap*0.5)*255); % overrap images
  
%   imtool(HeatMap);
%   I=getimage(imgca);
%   result=rgb2gray(I);
%   imtool close all;
  
%   imtool(HeatMap);
%   I=getimage(imgca);
%   imwrite(I,['E:\Amyproject\data\result2\',int2str(idx),'.png']);
%   img=imresize(I,[30 30]);
%     imwrite(img,['E:\Amyproject\data\result3\',int2str(idx),'.png']);
%     imtool close all;
% HeatMap2=HeatMap+HeatMap2;
%   idx=int2str(i)
if class=='bad'
%     result1=result+result1;
%     HeatMap2=HeatMap+HeatMap2;
    gradcam2=gradcam+gradcam2;
    HeatMap2=HeatMap+HeatMap2;
end
end

[~,idx]=max(score);
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