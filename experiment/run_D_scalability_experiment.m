function run_D_scalability_experiment()
    FIXED_N = 10000; 
    D_steps = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
           
    num_tests = length(D_steps);
    times_mapping = zeros(num_tests, 1);
    times_inference = zeros(num_tests, 1);
    
    fprintf('Starting FEATURE Scalability Experiment (Fixed N=%d)...\n', FIXED_N);
    fprintf('| %-10s | %-12s | %-12s | %-12s |\n', 'Dim(D)', 'Map(s)', 'Inf(s)', 'Total(s)');
    fprintf('|%s|\n', repmat('-',1,56));
    
    for k = 1:num_tests
        current_D = D_steps(k);
        data = struct('Features', {}, 'Duration', {}, 'Label', {});
        data(FIXED_N).Features = []; 
        template_feat = randn(20, current_D); 
        for i = 1:FIXED_N
            data(i).Features = template_feat + 0.01 * randn(20, current_D); 
            data(i).Duration = 5 + rand() * 10; 
            data(i).Label = 0;
        end
        [t_map, t_inf] = run_real_algorithm_var_dim(data, current_D);
        
        times_mapping(k)   = t_map;
        times_inference(k) = t_inf;
        
        fprintf('| %-10d | %-12.4f | %-12.4f | %-12.4f |\n', ...
            current_D, t_map, t_inf, t_map + t_inf);
            
        clear data; 
    end
    fig_handle = plot_feature_style(D_steps, times_mapping, times_inference, FIXED_N);
    set(gcf, 'PaperPositionMode', 'auto');
    exportgraphics(fig_handle, 'scalability_D.pdf', 'ContentType', 'vector');
end



