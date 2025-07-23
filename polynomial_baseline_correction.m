function [y_corrected, y_baseline] = polynomial_baseline_correction(y, window_size, poly1_order, poly2_order)
    N = length(y);
    t = 1:N;
    [p_global, ~, mu] = polyfit(t, y, poly1_order);
    baseline_global = polyval(p_global, t, [], mu);
    step_size = ceil(N / window_size);
    baseline_local = zeros(N, 1);
    for i = 1:step_size
        idx_start = (i-1) * window_size + 1;
        idx_end = min(i * window_size, N);
        idx = idx_start:idx_end;
        residual = y(idx) - baseline_global(idx)';
        if length(idx) >= poly2_order + 1
            [p_local, ~, mu_local] = polyfit(t(idx), residual, poly2_order);
            baseline_local(idx) = polyval(p_local, t(idx), [], mu_local);
        end
    end
    total_baseline = baseline_global' + baseline_local;
    y_corrected = y - total_baseline;
    y_baseline = total_baseline;
end