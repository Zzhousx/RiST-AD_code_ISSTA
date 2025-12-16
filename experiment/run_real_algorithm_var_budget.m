function [t_map, t_inf] = run_real_algorithm_var_budget(data, budget_input)
    N = length(data);
    tau_number = 10; 
    alpha = 0.5;
    epsilon = 1e-5;
    tic;
    all_features = cat(1, data.Features);
    global_mu = mean(all_features);
    global_sigma = std(all_features) + 1e-8;
    clear all_features; 
    D_base = 20;
    D_aug = D_base * 2; 
    dim_vec = D_aug * (D_aug + 1) / 2;
    tangentVectors = zeros(N, dim_vec);
    pot_chaotic = zeros(N, 1);
    pot_intensity = zeros(N, 1);
    mask_diag = logical(eye(D_aug));
    mask_off  = triu(true(D_aug), 1);
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
        X_t = X_normalized(1:current_tau, :);      
        X_t_minus_1 = X_normalized(1:end, :); 
        Z = [X_t, X_t_minus_1];
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
        
        tangentVectors(i, :) = [S(mask_diag); S(mask_off) * sqrt(2)]';
    end
    vecNorms = sqrt(sum(tangentVectors.^2, 2));
    tangentVectors = tangentVectors ./ (vecNorms + 1e-9);
    t_map = toc;
    tic;
    durations = [data.Duration]';
    minmax = @(x) (x - min(x)) ./ (max(x) - min(x) + 1e-9);
    term_chaos = minmax(pot_chaotic);
    term_intensity = minmax(pot_intensity);
    q_scores = alpha * term_chaos + (1 - alpha) * term_intensity;
    q_scores = q_scores + 1e-4; 
    K_geo = tangentVectors * tangentVectors';
    Weight_Cost = 1 ./ (durations .^ 2);
    q_scores = q_scores .* Weight_Cost; 
    L_matrix = (q_scores * q_scores') .* K_geo;
    L_matrix = (L_matrix + L_matrix') / 2;
    standard_greedy_dpp(L_matrix, budget_input);
    t_inf = toc;
    clear L_matrix K_geo tangentVectors;
end

