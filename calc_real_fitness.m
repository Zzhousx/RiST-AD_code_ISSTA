function score = calc_real_fitness(indices, potential, vectors)
    N = length(indices);
    K_eval = min(N, 50);
    sub_idx = indices(1:K_eval);
    weights = linspace(10, 1, K_eval)'; 
    eff_score = sum(potential(sub_idx) .* weights);
    sub_vecs = vectors(sub_idx, :);
    penalty = 0;
    diffs = diff(sub_vecs, 1, 1); 
    dists_sq = sum(diffs.^2, 2);
    num_conflicts = sum(dists_sq < 0.5); 
    num_duplicates = sum(dists_sq < 0.05);
    penalty = num_conflicts * 0.5 + num_duplicates * 5.0;
    score = eff_score - penalty;
end