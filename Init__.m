function Init__(infoFlag)
    if nargin < 1
        infoFlag = false;
    end
    close all;
    %evalin('base', 'clear');
    clc;
    %restoredefaultpath;  
    functionPath = fullfile(fileparts(mfilename('fullpath')), 'function\');
    addpath(functionPath);
    if infoFlag
        fprintf('已导入%s内的函数。\n',functionPath);
    end
end