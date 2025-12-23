function apfdc_ours = run_RiST(alpha)
    if evalin('base', 'exist(''deepScenarioData'', ''var'')')
        data = evalin('base', 'deepScenarioData');
    else
        error('error: not found deepScenarioData');
    end
    validIdx = arrayfun(@(x) size(x.Features, 2) == 20 && ~isempty(x.Features), data);
    data = data(validIdx);
    N = length(data);
    use_time_delay_mode = false;
    if use_time_delay_mode == false
        tau_number=2;
    else
        tau_number=12;
    end
    groundTruth = [data.Label]'; 
    durations = [data.Duration]';
    fprintf('scenarios N=%d, faults=%d\n', N, sum(groundTruth));
    all_features = cat(1, data.Features);
    global_mu = mean(all_features);
    global_sigma = std(all_features) + 1e-8;
    clear all_features; 
    epsilon = 1e-5; 
    tic
    %Riemannian Spatio-Temporal representation
    D_base = 20;
    D_aug = D_base * 2; 
    dim_vec = D_aug * (D_aug + 1) / 2;
    
    tangentVectors = zeros(N, dim_vec);
    pot_chaotic = zeros(N, 1);
    pot_intensity = zeros(N, 1);
    for i = 1:N
        raw_X = data(i).Features;
        [T, ~] = size(raw_X);
        current_tau = min(T, tau_number);
        if current_tau > 0
            X_focus = raw_X(end - current_tau + 1 : end, :);
        else
            X_focus = zeros(0, D_base);
        end
        X_normalized = (X_focus - global_mu) ./ global_sigma;

        if use_time_delay_mode== false
            X_t = X_normalized(2:end, :);      
            X_t_minus_1 = X_normalized(1:end-1, :); 
            Z = [X_t, X_t_minus_1];
        else
            current_tau = size(X_normalized, 1); 
            X_t = X_normalized(1:current_tau, :);      
            X_t_minus_1 = X_normalized(1:end, :); 
            Z = [X_t, X_t_minus_1];
        end
        [T_embed, ~] = size(Z);
        if T_embed < 2  
            C = eye(D_aug) * epsilon;
            z_mean_sq = 0;
        else
            z_mean = mean(Z);
            Z_centered = Z - z_mean;
            C = (Z_centered' * Z_centered) / (T_embed - 1);
            z_mean_sq = sum(z_mean.^2);
        end
        C = C + epsilon * eye(D_aug);
        pot_chaotic(i) = trace(C);     
        pot_intensity(i) = z_mean_sq;  
        [U, Lam] = eig(C, 'vector');
        d_log = log(max(Lam, 1e-10));
        S = U * diag(d_log) * U'; 
        mask_diag = logical(eye(D_aug));
        mask_off  = triu(true(D_aug), 1);
        tangentVectors(i, :) = [S(mask_diag); S(mask_off) * sqrt(2)]';
    end
    vecNorms = sqrt(sum(tangentVectors.^2, 2));
    tangentVectors = tangentVectors ./ (vecNorms + 1e-9);
    
    %construct phy energy
    minmax = @(x) (x - min(x)) ./ (max(x) - min(x) + 1e-9);
    term_chaos = minmax(pot_chaotic);
    term_intensity = minmax(pot_intensity);
    q_scores = alpha * term_chaos + (1 - alpha) * term_intensity;
    q_scores = q_scores+ 1e-4; 
    
    %construct L-Ensemble kernel matrix
    K_geo = tangentVectors * tangentVectors';
    Weight_Cost = 1 ./ (durations .^ 2);
    q_scores = q_scores.* Weight_Cost; 
    L_matrix = (q_scores * q_scores') .* K_geo;
    L_matrix = (L_matrix + L_matrix') / 2;
    rankedIndices_PIRDPP = standard_greedy_dpp(L_matrix, N);
    toc
    %experiment
    avg_x_rand = linspace(0, 100, 1000)'; 
    sum_y_interp = zeros(size(avg_x_rand));
    sum_apfdc = 0;
    num_runs=30;
    for r = 1: num_runs
        curr_randIdx = randperm(N)';
        [~, r_apfdc, r_x, r_y] = calc_metrics(curr_randIdx, groundTruth, durations);
        sum_apfdc = sum_apfdc + r_apfdc;
        y_interp = interp1(r_x, r_y, avg_x_rand, 'linear', 'extrap');
        y_interp = max(0, min(100, y_interp));
        sum_y_interp = sum_y_interp + y_interp;
    end
    apfdc_rand = sum_apfdc / num_runs;
    

    x_rand = avg_x_rand;
    y_rand = sum_y_interp / num_runs;
    tau_number_baseline=12;
    idx_greedy = run_baseline_greedy_risk(alpha, tau_number_baseline);
    idx_mab = run_baseline_mab_adaptive_ea(alpha, 6);
    idx_fps = run_baseline_euclidean_fps(6);
    plot_data = struct(); 
    
    % 1. Ours
    [~, apfdc, x, y] = calc_metrics(rankedIndices_PIRDPP, groundTruth, durations);
    plot_data(1).name = 'RiST-AD'; 
    plot_data(1).x = x; plot_data(1).y = y; plot_data(1).apfdc = apfdc;apfdc_ours=apfdc;
    plot_data(1).is_ours = true; 

% % %     % Statistical Analysis
% % %     stochastic_results = batch_run_baselines(alpha, tau_number, 30);
% % %     stats_rnd = compute_academic_stats(apfdc_ours, stochastic_results.random);
% % %     stats_mab = compute_academic_stats(apfdc_ours, stochastic_results.mab);
% % %     stats_fps = compute_academic_stats(apfdc_ours, stochastic_results.fps);
% % %     fprintf('\n| %-15s | %-10s | %-6s | %-10s | %-10s |\n', 'Approach', 'Mean APFDc', 'A12', 't-stat', 'p-value');
% % %     fprintf('|%s|\n', repmat('-',1,62));
% % %     % Ours (Benchmark)
% % %     fprintf('| %-15s | %.4f     | %-6s | %-10s | %-10s |\n', 'PIR-DPP (Ours)', apfdc_ours, '-', '-', '-');
% % %     % Random
% % %     fprintf('| %-15s | %.4f     | %.2f   | %10.2f | %.2e |\n', ...
% % %         'Random', mean(stochastic_results.random), ...
% % %         stats_rnd.A12, stats_rnd.T_Statistic, stats_rnd.p_value);
% % %     % Euclidean-FPS
% % %     fprintf('| %-15s | %.4f     | %.2f   | %10.2f | %.2e |\n', ...
% % %         'Euclidean-FPS', mean(stochastic_results.fps), ...
% % %         stats_fps.A12, stats_fps.T_Statistic, stats_fps.p_value);
% % %     % MAB-EA
% % %     fprintf('| %-15s | %.4f     | %.2f   | %10.2f | %.2e |\n', ...
% % %         'MAB-Adaptive EA', mean(stochastic_results.mab), ...
% % %         stats_mab.A12, stats_mab.T_Statistic, stats_mab.p_value);


    % 2. Greedy 
    [~, apfdc, x, y] = calc_metrics(idx_greedy, groundTruth, durations);
    plot_data(3).name = 'Greedy';
    plot_data(3).x = x; plot_data(3).y = y; plot_data(3).apfdc = apfdc;
    
    % 3. MAB-EA 
    [~, apfdc, x, y] = calc_metrics(idx_mab, groundTruth, durations);
    plot_data(2).name = 'MAB-EA';
    plot_data(2).x = x; plot_data(2).y = y; plot_data(2).apfdc = apfdc;

    % 4. FPS
    [~, apfdc, x, y] = calc_metrics(idx_fps, groundTruth, durations);
    plot_data(4).name = 'FPS';
    plot_data(4).x = x; plot_data(4).y = y; plot_data(4).apfdc = apfdc;
    
    % 5. Random 
    plot_data(5).name = 'Random';
    plot_data(5).x = x_rand; plot_data(5).y = y_rand; plot_data(5).apfdc = apfdc_rand;
    plot_data(5).is_rnd = true; 

    fprintf('\n===== results ====\n');
    fprintf('| Method     | APFDc  |\n');
    fprintf('| ours       | %.4f |\n', plot_data(1).apfdc);
    fprintf('| MAB-EA     | %.4f |\n', plot_data(2).apfdc);
    fprintf('| Greedy     | %.4f |\n', plot_data(3).apfdc); 
    fprintf('| FPS        | %.4f |\n', plot_data(4).apfdc);
    fprintf('| Random     | %.4f |\n', plot_data(5).apfdc);
    fprintf('====================\n');

    fig_handle=run_APFDc_fig(plot_data);
%     set(gcf, 'PaperPositionMode', 'auto');
%     exportgraphics(fig_handle, 'APFDc_RL.pdf', 'ContentType', 'vector');

% % %      %run time
% % %     ranks_to_compare = struct();
% % %     ranks_to_compare(1).name = 'RiST-AD';   ranks_to_compare(1).indices = rankedIndices_PIRDPP;
% % %     ranks_to_compare(2).name = 'MAB-EA';    ranks_to_compare(2).indices = idx_mab;
% % %     ranks_to_compare(3).name = 'Greedy';    ranks_to_compare(3).indices = idx_greedy;
% % %     ranks_to_compare(4).name = 'FPS';       ranks_to_compare(4).indices = idx_fps;
% % %     ranks_to_compare(5).name = 'Random';    ranks_to_compare(5).indices = curr_randIdx; 
% % %     efficiency_stats = cost_time_at_95ratio(ranks_to_compare, groundTruth, durations);
% % %     plot_cost_efficiency(efficiency_stats);
end




