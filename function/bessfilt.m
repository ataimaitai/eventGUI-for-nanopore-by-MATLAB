function filtered_data = bessfilt(data, cutoff, pole, fs, varargin)
% BESSFILT - 优化的贝塞尔滤波器实现（支持高通/低通）
%
% 输入参数：
%   data    : 输入信号（向量或矩阵）
%   cutoff  : 截止频率（Hz）
%   pole    : 滤波器阶数（1-8）
%   fs      : 采样频率（Hz）
%   varargin: 可选键值对参数：
%       'type'     : 滤波器类型 ('low'或'high'，默认'low')
%       'pad_ratio': 填充长度比例（默认10）
%
% 输出参数：
%   filtered_data : 滤波后的信号

    % 参数验证
    if cutoff >= fs/2
        error('截止频率必须小于奈奎斯特频率 (%.1f Hz)', fs/2);
    end
    if pole < 1 || pole > 8
        error('阶数必须在1-8之间');
    end

    % 默认参数
    filter_type = 'low';
    pad_ratio = 10;
    
    % 解析可选参数
    for i = 1:2:length(varargin)
        if strcmpi(varargin{i}, 'type')
            filter_type = lower(varargin{i+1});
        elseif strcmpi(varargin{i}, 'pad_ratio')
            pad_ratio = varargin{i+1};
        end
    end

    % 设计模拟贝塞尔滤波器
    [b,a] = besself(pole, 2*pi*cutoff, filter_type);
    
    % 转换为数字滤波器（双线性变换）
    try
        [num,den] = bilinear(b,a,fs);
    catch
        warning('双线性变换不稳定，改用脉冲响应不变法');
        [num,den] = impinvar(b,a,fs,1/(2*pi*cutoff));
    end

    % 计算填充长度
    pad_len = min(round(pad_ratio * fs/cutoff), floor(length(data)/2));
    
    % 分通道滤波（支持多列数据）
    filtered_data = zeros(size(data));
    for i = 1:size(data, 2)
        padded = padarray(data(:,i), [pad_len,0], 'symmetric', 'both');
        filt_data = filtfilt(num, den, padded);
        filtered_data(:,i) = filt_data(pad_len+1:end-pad_len);
    end
end