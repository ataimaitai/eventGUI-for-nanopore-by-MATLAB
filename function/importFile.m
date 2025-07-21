function [fileName,filePath,fileNamePath,fileSum]=importFile(infoFlag)
    if nargin<1
        infoFlag=false;
    end
    [fileName, filePath] = uigetfile('*.abf;*.mat', '选择一个或多个ABF/mat文件', 'MultiSelect', 'on');
    if isequal(fileName, 0)
        error('未选择文件.');
    end
    if ischar(fileName)
        fileName = {fileName};
    end
    fileName=fileName';
    fileNamePath=fullfile(filePath,fileName)';
    fileSum=length(fileName);
    if infoFlag
        fprintf('已导入%d份文件。\n',fileSum);
    end
end

