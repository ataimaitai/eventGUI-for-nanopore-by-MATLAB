function filtered_data = butterfilt(data, cutoff, pole, fs, varargin)
% BUTTERFILT - 优化的巴特沃斯滤波器实现（支持高通/低通）
%
% 输入参数：
%   data    : 输入信号（向量或矩阵）
%   cutoff  : 截止频率（Hz）或[low, high]带通范围
%   pole    : 滤波器阶数
%   fs      : 采样频率（Hz）
%   varargin: 可选键值对参数：
%       'type'     : 滤波器类型 ('low','high','bandpass','bandstop')
%       'pad_ratio': 填充长度比例（默认10）
%       'ripple'   : 通带波纹（仅用于一致性，巴特沃斯不使用）
%
% 输出参数：
%   filtered_data : 滤波后的信号

    % 参数验证
    if any(cutoff >= fs/2)
        error('截止频率必须小于奈奎斯特频率 (%.1f Hz)', fs/2);
    end
    if pole < 1
        error('阶数必须大于等于1');
    end

    % 默认参数
    filter_type = 'low';
    pad_ratio = 10;
    
    % 解析可选参数
    for i = 1:2:length(varargin)
        param = lower(varargin{i});
        if strcmp(param, 'type')
            filter_type = lower(varargin{i+1});
        elseif strcmp(param, 'pad_ratio')
            pad_ratio = varargin{i+1};
        end
    end

    % 设计数字巴特沃斯滤波器
    if strcmpi(filter_type, 'bandpass') || strcmpi(filter_type, 'bandstop')
        if numel(cutoff) ~= 2
            error('带通/带阻滤波需要指定[low, high]截止频率');
        end
        Wn = cutoff/(fs/2);
    else
        Wn = cutoff/(fs/2);
    end
    
    [num, den] = butter(pole, Wn, filter_type);

    % 计算填充长度
    if numel(cutoff) == 2
        min_cutoff = min(cutoff);
    else
        min_cutoff = cutoff;
    end
    pad_len = min(round(pad_ratio * fs/min_cutoff), floor(length(data)/2));
    
    % 分通道滤波
    filtered_data = zeros(size(data));
    for i = 1:size(data, 2)
        padded = padarray(data(:,i), [pad_len,0], 'symmetric', 'both');
        filt_data = filtfilt(num, den, padded);
        filtered_data(:,i) = filt_data(pad_len+1:end-pad_len);
    end
end