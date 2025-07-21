function [y_corrected, y_baseline] = polynomial_baseline_correction(x, y, step_size, poly1_order, poly2_order)
    % 输入参数：
    %   x: 时间轴或采样点向量（1×N）
    %   y: 原始信号数据（1×N）
    %   step_size: 分段拟合的步长（建议1-100，高采样率增大）
    %   poly1_order: Poly-1的阶数（全局趋势，建议1或2）
    %   poly2_order: Poly-2的阶数（局部波动，建议3或4）
    %
    % 输出参数：
    %   y_corrected: 基线校正后的信号
    %   y_baseline: 拟合的基线

    % --- 阶段1：Poly-1全局趋势拟合（低阶多项式）---
    p_global = polyfit(x, y, poly1_order);
    y_global = polyval(p_global, x);

    % --- 阶段2：Poly-2局部波动拟合（分段高阶多项式）---
    num_segments = ceil(length(x) / step_size);
    y_local = zeros(size(y));
    
    for i = 1:num_segments
        idx_start = max(1, (i-1) * step_size + 1);
        idx_end = min(length(x), i * step_size);
        segment_x = x(idx_start:idx_end);
        segment_y = y(idx_start:idx_end) - y_global(idx_start:idx_end); % 移除全局趋势
        
        % 对局部残差进行高阶拟合
        if length(segment_x) >= poly2_order + 1  % 确保数据点数足够拟合
            p_local = polyfit(segment_x, segment_y, poly2_order);
            y_local(idx_start:idx_end) = polyval(p_local, segment_x);
        else
            y_local(idx_start:idx_end) = 0; % 数据不足时跳过拟合
        end
    end

    % 合并拟合结果
    y_baseline = y_global + y_local;
    y_corrected = y - y_baseline;

    % --- 可视化结果 ---
    figure;
    subplot(3,1,1);
    plot(x, y, 'k', 'LineWidth', 1.5); hold on;
    plot(x, y_global, 'r--', 'LineWidth', 2);
    plot(x, y_baseline, 'b-', 'LineWidth', 2);
    legend('原始数据', 'Poly-1全局拟合', '最终基线拟合');
    title(sprintf('基线拟合 (Poly1=%d, Poly2=%d, 步长=%d)', poly1_order, poly2_order, step_size));
    xlabel('时间'); ylabel('幅值');
    grid on;

    subplot(3,1,2);
    plot(x, y_corrected, 'g', 'LineWidth', 1.5);
    legend('校正后信号');
    title('基线校正后的信号');
    xlabel('时间'); ylabel('幅值');
    grid on;

    subplot(3,1,3);
    plot(x, y_local, 'm', 'LineWidth', 1.5);
    legend('Poly-2局部波动');
    title('局部波动分量');
    xlabel('时间'); ylabel('幅值');
    grid on;
end