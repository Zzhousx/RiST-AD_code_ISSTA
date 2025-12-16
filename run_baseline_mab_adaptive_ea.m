function ranked_indices = run_baseline_mab_adaptive_ea(alpha, tau_number)
    % =====================================================================
    % Baseline: MAB-Driven EA with Heuristic Initialization
    % =====================================================================
    if evalin('base', 'exist(''deepScenarioData'', ''var'')')
        data = evalin('base', 'deepScenarioData');
    else
        error('No dataset was found');
    end
    validIdx = arrayfun(@(x) size(x.Features, 2) == 20 && ~isempty(x.Features), data);
    data = data(validIdx);
    N = length(data);
    durations = [data.Duration]';
    all_features = cat(1, data.Features);
    global_mu = mean(all_features);
    global_sigma = std(all_features) + 1e-8;
    D_base = 20; epsilon = 1e-5;
    risk_scores = zeros(N, 1);
    flat_dim = tau_number * D_base;
    euclidean_vectors = zeros(N, flat_dim);
    for i = 1:N
        raw_X = data(i).Features;
        [T, ~] = size(raw_X);
        current_tau = min(T, tau_number);
        if current_tau > 0
            X_focus = raw_X(end - current_tau + 1 : end, :);
            X_focus_norm = (X_focus - global_mu) ./ global_sigma;
        else
            X_focus_norm = zeros(0, D_base);
        end
        Z = [X_focus_norm, X_focus_norm]; 
        [T_embed, ~] = size(Z);
        if T_embed < 2, C = eye(D_base*2)*epsilon; z_mean_sq=0; else
            z_mean = mean(Z); Z_centered = Z - z_mean;
            C = (Z_centered' * Z_centered) / (T_embed - 1);
            z_mean_sq = sum(z_mean.^2);
        end
        risk_scores(i) = alpha * trace(C) + (1-alpha) * z_mean_sq; 
        
        if current_tau < tau_number
            X_padded = [zeros(tau_number - current_tau, D_base); X_focus_norm];
        else, X_padded = X_focus_norm; end
        euclidean_vectors(i, :) = reshape(X_padded', 1, []);
    end
    risk_scores = (risk_scores - min(risk_scores)) ./ (max(risk_scores) - min(risk_scores) + 1e-9);
    heuristic_potential = risk_scores ./ (durations + 1e-2);
    prob_weights = heuristic_potential / sum(heuristic_potential);
    max_generations = 300; 
    operators = {'SmartInsert', 'BiasedSwap', 'Scramble'}; 
    K = length(operators);
    q_values = zeros(K, 1);
    counts = zeros(K, 1);
    total_counts = 0;
    [~, greedy_idx] = sort(heuristic_potential, 'descend');
    current_genome = greedy_idx;
    swap_cnt = floor(N * 0.1); 
    for k=1:swap_cnt
        i1 = randi(N); i2 = randi(N);
        tmp = current_genome(i1); current_genome(i1)=current_genome(i2); current_genome(i2)=tmp;
    end
    current_fitness = calc_real_fitness(current_genome, heuristic_potential, euclidean_vectors);
    best_genome = current_genome;
    best_fitness = current_fitness;
    for gen = 1:max_generations
        if gen <= K
            arm_idx = gen;
        else
            ucb = q_values + 0.5 * sqrt(2 * log(total_counts) ./ (counts + 1e-5));
            [~, arm_idx] = max(ucb);
        end
        op_name = operators{arm_idx};
        mutated_genome = apply_operator_turbo(current_genome, op_name, heuristic_potential);
        new_fitness = calc_real_fitness(mutated_genome, heuristic_potential, euclidean_vectors);
        reward = 0;
        if new_fitness > current_fitness
            reward = 1;
            current_genome = mutated_genome;
            current_fitness = new_fitness;
            
            if new_fitness > best_fitness
                best_fitness = new_fitness;
                best_genome = mutated_genome;
                reward = 3; 
            end
        elseif rand() < 0.05
             current_genome = mutated_genome;
             current_fitness = new_fitness;
        end
        counts(arm_idx) = counts(arm_idx) + 1;
        total_counts = total_counts + 1;
        alpha_learning = 0.1; 
        q_values(arm_idx) = q_values(arm_idx) + alpha_learning * (reward - q_values(arm_idx));
    end
    ranked_indices = best_genome;
end


