function run_budget_scalability_experiment()
    FIXED_N = 10000; 
    K_steps = [10, 50, 100, 200, 300, 400, 500, 600, 800, 1000];
           
    num_tests = length(K_steps);
    times_mapping = zeros(num_tests, 1);
    times_inference = zeros(num_tests, 1);
    
    fprintf('Starting BUDGET Scalability Experiment (Fixed N=%d)...\n', FIXED_N);
    fprintf('| %-10s | %-12s | %-12s | %-12s |\n', 'Budget(k)', 'Map(s)', 'Inf(s)', 'Total(s)');
    fprintf('|%s|\n', repmat('-',1,56));
    data = struct('Features', {}, 'Duration', {}, 'Label', {});
    data(FIXED_N).Features = [];
    template_feat = randn(20, 20); 
    for i = 1:FIXED_N
        data(i).Features = template_feat + 0.01 * randn(20, 20); 
        data(i).Duration = 5 + rand() * 10; 
        data(i).Label = 0;
    end
    
    for k_idx = 1:num_tests
        current_k = K_steps(k_idx);
        [t_map, t_inf] = run_real_algorithm_var_budget(data, current_k);
        
        times_mapping(k_idx)   = t_map;
        times_inference(k_idx) = t_inf;
        
        fprintf('| %-10d | %-12.4f | %-12.4f | %-12.4f |\n', ...
            current_k, t_map, t_inf, t_map + t_inf);
    end
    clear data;
    fig_handle = plot_budget_style(K_steps, times_mapping, times_inference, FIXED_N);
    set(gcf, 'PaperPositionMode', 'auto');
    exportgraphics(fig_handle, 'scalability_k.pdf', 'ContentType', 'vector');
end
