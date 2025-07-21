% 初始化并加载数据
Init__();
[a, us, ~] = abfload('M:\000博士数据\20250715\A61_2M_LiCl_485k_0002.abf');
fs = 1e6 / us;
raw_signal = a(:, 1);


%% 参数设置


refs=250000;
cutoff=50000;
resamplesignal = resample(raw_signal,refs,fs);
resamplesignal=bessfilt(resamplesignal,cutoff,2,refs,'type','low');


t = (1:N)';

poly1_order = 2;    % Poly-1阶数（全局趋势，建议1或2）
poly2_order = 5;    % Poly-2阶数（局部波动，建议3或4）
window_size=30000;
%% 阶段1：Poly-1全局趋势拟合
N = length(resamplesignal);
[p_global, ~, mu] = polyfit(t, resamplesignal, poly1_order);
baseline_global = polyval(p_global, t, [], mu);

%% 阶段2：Poly-2局部波动拟合（分段处理）
step_size = ceil(N / window_size);
baseline_local = zeros(N, 1);
for i = 1:step_size
    idx_start = (i-1) * window_size + 1;
    idx_end = min(i * window_size, N);
    idx = idx_start:idx_end;
    
    % 移除全局趋势后拟合局部残差
    residual = resamplesignal(idx) - baseline_global(idx);
    if length(idx) >= poly2_order + 1
        [p_local, ~, mu_local] = polyfit(t(idx), residual, poly2_order);
        baseline_local(idx) = polyval(p_local, t(idx), [], mu_local);
    end
end

%% 合并基线并校正信号
total_baseline = baseline_global + baseline_local;
corrected_signal = resamplesignal - total_baseline;






figure;
subplot(311);
plot(raw_signal);
subplot(312);
plot(resamplesignal);hold on;
plot(total_baseline);
subplot(313);
plot(corrected_signal);


%% 可视化结果
% figure;
% 
% % 原始信号与基线
% subplot(3,1,1);
% plot(t, raw_signal, 'k'); hold on;
% plot(t, baseline_global, 'r--', 'LineWidth', 1.5);
% plot(t, total_baseline, 'b-', 'LineWidth', 1.5);
% legend('原始信号', 'Poly-1全局基线', '总基线');
% title(sprintf('双阶段基线校正 (Poly1=%d, Poly2=%d, 步长=%d)', poly1_order, poly2_order, step_size));
% grid on;
% 
% % 校正后信号（平移至基线均值）
% subplot(3,1,2);
% plot(t, corrected_signal + mean(total_baseline), 'g');
% legend('校正后信号（平移展示）');
% grid on;
% 
% % 局部波动分量
% subplot(3,1,3);
% plot(t, baseline_local, 'm');
% legend('Poly-2局部波动');
% xlabel('采样点');
% grid on;