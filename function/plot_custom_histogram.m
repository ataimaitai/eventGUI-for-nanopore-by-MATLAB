function plot_custom_histogram(data, varargin)
% 绘制高度可定制的直方图（支持普通坐标轴和appdesigner的UIAxes）
% 必需参数：
%   data - 输入数据向量
%
% 可选name-value参数对：
%   'NumBins'     - 箱体数量（默认自动计算）
%   'BinWidth'    - 箱体宽度（优先于NumBins）
%   'GapRatio'    - 间隙比例（默认0.1）
%   'FaceColor'   - 箱体颜色（默认[0.2 0.6 0.8]）
%   'AddKDE'      - 是否添加核密度曲线（默认false）
%   'KDEColor'    - 核密度曲线颜色（默认[0.9 0.2 0.2]）
%   'KDEWidth'    - 曲线宽度（默认1.5）
%   'Orientation' - 方向：'vertical'（默认）或'horizontal'
%   'ShowGrid'    - 是否显示网格（默认false）
%   'Padding'     - 频数轴扩展比例（默认0.05，即5%）
%   'Reverse'     - 水平方向是否反转x轴（默认true）
%   'Parent'      - 目标坐标轴/UIAxes（默认当前坐标轴gca）

% 默认参数设置
defaults = struct(...
    'NumBins', [], ...
    'BinWidth', [], ...
    'GapRatio', 0.1, ...
    'FaceColor', [0.2 0.6 0.8], ...
    'AddKDE', false, ...
    'KDEColor', [0.9 0.2 0.2], ...
    'KDEWidth', 1.5, ...
    'Orientation', 'vertical', ...
    'ShowGrid', false, ...
    'Padding', 0.05, ...
    'Reverse', true, ...
    'Parent', gca);  % 默认为当前坐标轴

% 解析输入参数
p = inputParser;
paramNames = fieldnames(defaults);
for i = 1:length(paramNames)
    addParameter(p, paramNames{i}, defaults.(paramNames{i}));
end
parse(p, varargin{:});
params = p.Results;

% 参数验证
valid_orientations = {'vertical', 'horizontal'};
params.Orientation = validatestring(params.Orientation, valid_orientations);
params.GapRatio = max(0, min(1, params.GapRatio));
params.Padding = max(0, min(0.5, params.Padding));

% 检查Parent是否是有效的坐标轴或UIAxes
if ~(isgraphics(params.Parent, 'axes') || isa(params.Parent, 'matlab.ui.control.UIAxes'))
    error('Parent must be a valid axes or UIAxes object');
end

% 设置当前坐标轴
if isa(params.Parent, 'matlab.ui.control.UIAxes')
    % 对于UIAxes，直接使用它作为父对象
    ax = params.Parent;
else
    % 对于普通坐标轴，设置为当前坐标轴
    axes(params.Parent);
    ax = params.Parent;
end

% 计算直方图数据
if ~isempty(params.BinWidth)
    [counts, edges] = histcounts(data, 'BinWidth', params.BinWidth);
elseif ~isempty(params.NumBins)
    [counts, edges] = histcounts(data, params.NumBins);
else
    [counts, edges] = histcounts(data); % 自动计算
end

bin_centers = edges(1:end-1) + diff(edges)/2;
bin_width = edges(2) - edges(1);

% 获取当前hold状态
hold_state = ishold(ax);
hold(ax, 'on');

% 根据方向选择绘图方式
if strcmp(params.Orientation, 'vertical')
    % ========== 垂直直方图 ==========
    bar(ax, bin_centers, counts, ...
        'BarWidth', (1 - params.GapRatio), ...
        'FaceColor', params.FaceColor, ...
        'EdgeColor', 'none');
    
    % 添加核密度曲线
    if params.AddKDE
        [kde, x] = ksdensity(data);
        plot(ax, x, kde * sum(counts)*bin_width, ...
            'Color', params.KDEColor, ...
            'LineWidth', params.KDEWidth);
    end
    
    % 标签和坐标轴设置
    if ~hold_state
        xlabel(ax, 'Value');
        ylabel(ax, 'Frequency');
        ylim(ax, [0, max(counts)*(1 + params.Padding)]);
    end
    
    % 调整值轴范围
    val_pad = range(data)*params.Padding;
    xlim(ax, [min(data)-val_pad, max(data)+val_pad]);
else
    % ========== 水平直方图 ==========
    barh(ax, bin_centers, counts, ...
        'BarWidth', (1 - params.GapRatio), ...
        'FaceColor', params.FaceColor, ...
        'EdgeColor', 'none');
    
    % 添加核密度曲线
    if params.AddKDE
        [kde, x] = ksdensity(data);
        plot(ax, kde * sum(counts)*bin_width, x, ...
            'Color', params.KDEColor, ...
            'LineWidth', params.KDEWidth);
    end
    
    % 标签和坐标轴设置
    if ~hold_state
        ylabel(ax, 'Value');
        xlabel(ax, 'Frequency');
        xlim(ax, [0, max(counts)*(1 + params.Padding)]);
        
        % 反转x轴方向（从右向左）
        if params.Reverse
            ax.XDir = 'reverse';
        end
    end
    
    % 调整值轴范围
    val_pad = range(data)*params.Padding;
    ylim(ax, [min(data)-val_pad, max(data)+val_pad]);
end

% 通用设置
if ~hold_state
    title(ax, sprintf('Distribution (Bins: %d)', length(counts)));
    if params.ShowGrid, grid(ax, 'on'); end
    box(ax, 'on');
end

% 恢复hold状态
if ~hold_state, hold(ax, 'off'); end
end