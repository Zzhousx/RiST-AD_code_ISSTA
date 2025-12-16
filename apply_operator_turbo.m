function genome = apply_operator_turbo(genome, op, potential)
    N = length(genome);
    
    switch op
        case 'SmartInsert'
            candidates = randi([floor(N/3), N], 5, 1);
            vals = genome(candidates);
            [~, best_local] = max(potential(vals));
            target_val = vals(best_local);
            current_pos = find(genome == target_val, 1);
            insert_pos = randi(max(1, floor(N/5)));
            if current_pos > insert_pos
                genome(current_pos) = []; 
                genome = [genome(1:insert_pos-1); target_val; genome(insert_pos:end)];
            end
        case 'BiasedSwap'
            idx1 = randi(floor(N/2)); 
            idx2 = randi([floor(N/2)+1, N]); 
            val1 = genome(idx1); val2 = genome(idx2);
            if potential(val2) > potential(val1) || rand() < 0.3
                genome(idx1) = val2;
                genome(idx2) = val1;
            end  
        case 'Scramble'
            len = floor(N * 0.05);
            start_i = randi(N - len);
            range = start_i : (start_i + len);
            fragment = genome(range);
            genome(range) = fragment(randperm(length(fragment)));
    end
end