function selected_indices=run_baseline_euclidean_fps(tau_number)
    % =====================================================================
    % Baseline: Euclidean Farthest Point Sampling (Diversity Only)
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
    feature_dim = 20;
    flat_dim = tau_number * feature_dim;
    euclidean_vectors = zeros(N, flat_dim);
    for i = 1:N
        raw_X = data(i).Features;
        [T, ~] = size(raw_X);
        
        current_tau = min(T, tau_number);
        if current_tau > 0
            X_focus = raw_X(end - current_tau + 1 : end, :);
            X_focus = (X_focus - global_mu) ./ global_sigma;
        else
            X_focus = zeros(0, feature_dim);
        end
        if current_tau < tau_number
            pad_len = tau_number - current_tau;
            X_padded = [zeros(pad_len, feature_dim); X_focus];
        else
            X_padded = X_focus;
        end
        euclidean_vectors(i, :) = reshape(X_padded', 1, []);
    end
    selected_indices = zeros(N, 1);
    min_dists = inf(N, 1);
    first_idx = randi(N);
    selected_indices(1) = first_idx;
    current_center = euclidean_vectors(first_idx, :);
    dists_new = sum((euclidean_vectors - current_center).^2, 2);
    min_dists = min(min_dists, dists_new);
    for k = 2:N
        [~, farthest_idx] = max(min_dists);
        if min_dists(farthest_idx) < 1e-12
            remain = find(~ismember(1:N, selected_indices(1:k-1)));
            if ~isempty(remain)
                farthest_idx = remain(1);
            end
        end
        selected_indices(k) = farthest_idx;
        new_center = euclidean_vectors(farthest_idx, :);
        dists_new = sum((euclidean_vectors - new_center).^2, 2);
        min_dists = min(min_dists, dists_new);
        min_dists(selected_indices(1:k)) = -1;
    end
end
