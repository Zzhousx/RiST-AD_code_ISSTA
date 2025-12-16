function results = batch_run_baselines(alpha, tau_number, num_runs)
    if nargin < 3, num_runs = 30; end
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
    apfdc_fps = zeros(num_runs, 1);
    apfdc_mab = zeros(num_runs, 1);
    apfdc_rnd = zeros(num_runs, 1);

    fprintf('[Experiment] Starting batch run of %d iterations for stochastic baselines...\n', num_runs);
    h = waitbar(0, 'Running Baselines...');

    for i = 1:num_runs
        waitbar(i/num_runs, h, sprintf('Running Baselines: %d/%d', i, num_runs));
        idx_fps = run_baseline_euclidean_fps(3); 
        [~, apfdc_fps(i), ~, ~] = calc_metrics(idx_fps, groundTruth, durations);
        idx_mab = run_baseline_mab_adaptive_ea(alpha, tau_number);
        [~, apfdc_mab(i), ~, ~] = calc_metrics(idx_mab, groundTruth, durations);
        idx_rnd = randperm(N)';
        [~, apfdc_rnd(i), ~, ~] = calc_metrics(idx_rnd, groundTruth, durations);
    end
    
    close(h);
    results.fps = apfdc_fps;
    results.mab = apfdc_mab;
    results.random = apfdc_rnd;
    fprintf('[Experiment] Batch run completed.\n');
end
