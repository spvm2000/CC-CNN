
function creatBDImages(dataFn,dName,mtdName,imgPath)
    data = importdata(dataFn);
    x = data(:,2:end);
    y = data(:,1);
    clear data;
    
    disp(['正在为方法',mtdName,'重建数据集',dataFn,'的图像，请稍候...']);
    % 清空临时目录
    delete(fullfile(imgPath,mtdName,'0','*.*'));
    if length(dir(fullfile(imgPath,mtdName,'0','*.*'))) > 2
        error([fullfile(imgPath,mtdName,'0','*.*'),'无法删除']); % 若无法清空，matlab仅给出警告，从而导致后续结果不正确
    end
    delete(fullfile(imgPath,mtdName,'1','*.*'));
    if length(dir(fullfile(imgPath,mtdName,'1','*.*'))) > 2
        error([fullfile(imgPath,mtdName,'1','*.*'),'无法删除']);
    end
    
    for i = 1:size(x,1)
        switch mtdName
            case "Sun"
                img = toSun(x(i,:));
            case "Yue"
                img = toYue(x(i,:));
            case "Chen"
                img = toChen(x(i,:));
            case "Ours"
                img = toOurs3(x(i,:));
            otherwise
                error(['不存在方法',mtdName]);
        end
        imwrite(img./256, fullfile(imgPath,dName,mtdName,num2str(y(i)),[num2str(i), '.bmp']))
    end
    disp('图像重建完成');
end
