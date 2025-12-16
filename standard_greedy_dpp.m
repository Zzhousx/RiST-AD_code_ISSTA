function Y = standard_greedy_dpp(L, k)
    N = size(L, 1);
    Y = [];
    selected = false(N, 1);
    for t = 1:k
        if t == 1
            gains = diag(L);
            gains(selected) = -inf;
        else
            L_YY = L(Y, Y) + eye(length(Y)) * 1e-10;
            invL_YY = inv(L_YY);
            rem_idx = find(~selected);
            gains = -inf(N, 1);
            for i = 1:length(rem_idx)
                u = rem_idx(i);
                vec_uY = L(u, Y);
                term = vec_uY * invL_YY * vec_uY';
                gains(u) = L(u, u) - term;
            end
        end
        [max_gain, best_idx] = max(gains);
        if max_gain <= 1e-12, break; end
        Y = [Y; best_idx];
        selected(best_idx) = true;
    end
    if length(Y) < N
        remaining = find(~selected);
        [~, sort_rem] = sort(diag(L(remaining, remaining)), 'descend');
        Y = [Y; remaining(sort_rem)];
    end
end