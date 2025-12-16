function X_aug = extract_20dim_features(raw_feats, is_rain, is_night, simHour)
    dt = 0.5; T = size(raw_feats, 1);
    if T < 2, X_aug = zeros(T, 20); return; end
    ego_vel = raw_feats(:, 4:5); 
    npc_pos = raw_feats(:, 7:8); npc_vel = raw_feats(:, 10:11);
    ego_pos = raw_feats(:, 1:2);
    % dy
    ego_acc = [0 0; diff(ego_vel)/dt]; 
    ego_jerk = [0 0; diff(ego_acc)/dt];
    npc_acc = [0 0; diff(npc_vel)/dt];
    % corr
    rel_pos = npc_pos - ego_pos; 
    rel_vel = npc_vel - ego_vel;
    dist_sq = sum(rel_pos.^2, 2); 
    dist = sqrt(dist_sq + 1e-6); 
    rel_speed_mag = sqrt(sum(rel_vel.^2, 2));
    % yaw
    yaw = atan2(ego_vel(:,2), ego_vel(:,1)); yaw(isnan(yaw)) = 0;
    % TTC
    dot_prod = rel_vel(:,1).*rel_pos(:,1) + rel_vel(:,2).*rel_pos(:,2);
    closing_speed = -dot_prod ./ dist;
    inv_ttc = zeros(T, 1);
    risk_idx = closing_speed > 0.01; 
    inv_ttc(risk_idx) = closing_speed(risk_idx) ./ dist(risk_idx);
    % pot
    pot_dist = exp(-0.2 * dist);
    npc_acc_mag = sqrt(sum(npc_acc.^2, 2));
    % evir
    base_friction = 0.9 - (0.3 * double(is_rain)); 
    feat_friction = base_friction + randn(T,1) * 0.02; 
    if isnan(simHour), if is_night, simHour = 22; else, simHour = 12; end; end
    time_rad = (simHour / 24.0) * 2 * pi;
    feat_time_sin = sin(time_rad) * ones(T, 1);
    feat_time_cos = cos(time_rad) * ones(T, 1);
    v_sq = sum(ego_vel.^2, 2);
    cross_prod_abs = abs(ego_vel(:,1).*ego_acc(:,2) - ego_vel(:,2).*ego_acc(:,1));
    curvature = zeros(T, 1);
    valid_v = v_sq > 0.1;
    curvature(valid_v) = cross_prod_abs(valid_v) ./ (v_sq(valid_v).^1.5);
    curvature(curvature > 1.0) = 1.0; 
    X_aug = [ ...
        ego_vel(:,1), ego_vel(:,2), ...         % 1-2
        ego_acc(:,1), ego_acc(:,2), ...         % 3-4
        ego_jerk(:,1), ego_jerk(:,2), ...       % 5-6
        rel_pos(:,1), rel_pos(:,2), ...         % 7-8
        rel_vel(:,1), rel_vel(:,2), ...         % 9-10
        cos(yaw), sin(yaw), ...                 % 11-12
        inv_ttc, ...                            % 13
        rel_speed_mag, ...                      % 14
        pot_dist, ...                           % 15
        npc_acc_mag, ...                        % 16
        feat_friction, ...                      % 17
        feat_time_sin, feat_time_cos, ...       % 18-19
        curvature ...                           % 20
    ];
    X_aug(isnan(X_aug)) = 0;
end