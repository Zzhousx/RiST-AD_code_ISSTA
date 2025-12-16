function run_N_scalability_experiment()
    N_steps = [1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, ...
               10000, 15000, 20000, 25000, 30000];
           
    num_tests = length(N_steps);
    times_mapping = zeros(num_tests, 1);
    times_inference = zeros(num_tests, 1);
    
    fprintf('Starting STRICT Scalability Experiment (Exact Logic Replaced)...\n');
    fprintf('Warning: N=30000 requires >8GB RAM.\n');
    fprintf('| %-10s | %-12s | %-12s | %-12s |\n', 'N', 'Map(s)', 'Inf(s)', 'Total(s)');
    fprintf('|%s|\n', repmat('-',1,56));
    
    for k = 1:num_tests
        current_N = N_steps(k);
        data = struct('Features', {}, 'Duration', {}, 'Label', {});
        data(current_N).Features = []; 
        template_feat = randn(20, 20); 
        for i = 1:current_N
            data(i).Features = template_feat + 0.01 * randn(20, 20); 
            data(i).Duration = 5 + rand() * 10; 
            data(i).Label = 0;
        end
        [t_map, t_inf] = run_real_algorithm_var_samp(data);
        times_mapping(k)   = t_map;
        times_inference(k) = t_inf;
        fprintf('| %-10d | %-12.4f | %-12.4f | %-12.4f |\n', ...
            current_N, t_map, t_inf, t_map + t_inf);
        clear data; 
    end
    fig_handle=plot_pastel_style(N_steps, times_mapping, times_inference);
    set(gcf, 'PaperPositionMode', 'auto');
    exportgraphics(fig_handle, 'scalability_N.pdf', 'ContentType', 'vector');
end




