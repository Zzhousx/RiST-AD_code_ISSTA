function rankedIndices=run_baseline_greedy_risk(alpha, tau_number)
    % =====================================================================
    % Baseline: Physics-Based Greedy Strategy (Risk Only)
    % =====================================================================
    if evalin('base', 'exist(''deepScenarioData'', ''var'')')
        data = evalin('base', 'deepScenarioData');
    else
        error('No dataset was found');
    end
    validIdx = arrayfun(@(x) size(x.Features, 2) == 20 && ~isempty(x.Features), data);
    data = data(validIdx);
    N = length(data);
    groundTruth = [data.Label]'; 
    durations = [data.Duration]';
    all_features = cat(1, data.Features);
    global_mu = mean(all_features);
    global_sigma = std(all_features) + 1e-8;
    epsilon = 1e-5; 
    D_base = 20;
    D_aug = D_base * 2; 
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
        Z = [X_normalized, X_normalized];
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
        pot_chaotic(i) = trace(C);     
        pot_intensity(i) = z_mean_sq;  
    end
    minmax = @(x) (x - min(x)) ./ (max(x) - min(x) + 1e-9);
    term_chaos = minmax(pot_chaotic);
    term_intensity = minmax(pot_intensity);
    risk_scores = alpha * term_chaos + (1 - alpha) * term_intensity;
    [~, rankedIndices] = sort(risk_scores, 'descend');
end