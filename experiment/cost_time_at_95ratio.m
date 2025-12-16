function cost_results = cost_time_at_95ratio(rankings_struct, groundTruth, durations)
    total_faults = sum(groundTruth);
    target_faults = ceil(0.95 * total_faults); 
    num_methods = length(rankings_struct);
    fprintf('Total Faults in Dataset: %d | Target (95%%): %d\n', total_faults, target_faults);
    fprintf('------------------------------------\n');
    fprintf('| %-15s | %-15s |\n', 'Method', 'Cost (Time)');
    fprintf('|-----------------|-----------------|\n');
    cost_results = struct();
    for m = 1:num_methods
        method_name = rankings_struct(m).name;
        ranking = rankings_struct(m).indices;
        acc_cost = 0;
        acc_faults = 0;
        found_target = false;
        for i = 1:length(ranking)
            idx = ranking(i);
            acc_cost = acc_cost + durations(idx);
            if groundTruth(idx) == 1
                acc_faults = acc_faults + 1;
            end
            if acc_faults >= target_faults
                cost_results(m).name = method_name;
                cost_results(m).cost = acc_cost;
                found_target = true;
                break;
            end
        end
        if found_target
            fprintf('| %-15s | %-15.2f |\n', method_name, acc_cost);
        else
            fprintf('| %-15s | %-15s |\n', method_name, 'Not Reached');
            cost_results(m).name = method_name;
            cost_results(m).cost = NaN;
        end
    end
    fprintf('--------------------------------------------------\n');
end