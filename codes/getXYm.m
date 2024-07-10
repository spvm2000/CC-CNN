%% 把ImageDataStore转成augmentedImageDatastore期望的X和Y
function [X,Y] = getXYm(imgLen,dim,imds)
x = imds.Files;
Y = imds.Labels;
n = size(x,1);
X = zeros(imgLen,imgLen,dim,n);
for i = 1:n   
    X(:,:,:,i) = imread(x{i});
end
X = uint8(X);
end