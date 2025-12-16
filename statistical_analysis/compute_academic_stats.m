function stat_res = compute_academic_stats(ours_val, baseline_vals)
    n = length(baseline_vals);
    sample_ours = repmat(ours_val, n, 1);
    more = sum(sample_ours > baseline_vals);
    equal = sum(sample_ours == baseline_vals);
    a12 = (more + 0.5 * equal) / n;
    [p_wilcox, ~, struct_w] = ranksum(sample_ours, baseline_vals, 'tail', 'right');
    if isfield(struct_w, 'zval')
        z_stat = struct_w.zval;
    else
        z_stat = struct_w.ranksum;
    end
    [~, ~, ~, struct_t] = ttest2(sample_ours, baseline_vals, 'Tail', 'right', 'Vartype', 'unequal');
    t_stat = struct_t.tstat;
    stat_res.A12 = a12;
    stat_res.p_value = p_wilcox; 
    stat_res.Wilcoxon_Z = z_stat;
    stat_res.T_Statistic = t_stat; 
end