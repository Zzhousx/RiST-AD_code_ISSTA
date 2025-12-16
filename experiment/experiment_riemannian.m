clc; clear; close all;
deepScenarioData = process_dataset(); 

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
all_features = cat(1, data.Features);
global_mu = mean(all_features);
global_sigma = std(all_features) + 1e-8;
tau_number = 10; 
epsilon = 1e-5;
D_base = 20;
D_aug = D_base * 2; 
dim_vec = D_aug * (D_aug + 1) / 2;

all_tangent_vectors = zeros(N, dim_vec);
saved_Cov_Danger = []; 
saved_Cov_Safe = [];   
candidates_danger_idxs = find(groundTruth == 1, 40);
candidates_safe_idxs = find(groundTruth == 0, 40);
idx_danger_demo = candidates_danger_idxs(3); 
idx_safe_demo   = candidates_safe_idxs(1);

for i = 1:N
    raw_X = data(i).Features;
    [T, ~] = size(raw_X);
    current_tau = min(T, tau_number);
    if current_tau > 0
        X_focus = raw_X(end - current_tau + 1 : end, :);
    else
        X_focus = zeros(0, D_base);
    end
    X_normalized = (X_focus - global_mu) ./ global_sigma;

    X_t = X_normalized(2:end, :);      % t
    X_t_minus_1 = X_normalized(1:end-1, :); % t-1
    Z = [X_t, X_t_minus_1];
    [T_embed, ~] = size(Z);
    
    if T_embed < 2
        C = eye(D_aug) * epsilon;
    else
        z_mean = mean(Z);
        Z_centered = Z - z_mean;
        C = (Z_centered' * Z_centered) / (T_embed - 1);
    end
    C = C + epsilon * eye(D_aug); 
    if i == idx_danger_demo
        saved_Cov_Danger = C;
    elseif i == idx_safe_demo
        saved_Cov_Safe = C;
    end
    [U, Lam] = eig(C);
    d_log = log(max(diag(Lam), 1e-10));
    S = U * diag(d_log) * U'; 
    mask_diag = logical(eye(D_aug));
    mask_off  = triu(true(D_aug), 1);
    vec = [S(mask_diag); S(mask_off) * sqrt(2)]';
  
    all_tangent_vectors(i, :) = vec; 
end
vecNorms = sqrt(sum(all_tangent_vectors.^2, 2));
all_tangent_vectors = all_tangent_vectors ./ (vecNorms + 1e-9);
%% ========================================================================
Y = tsne(all_tangent_vectors, 'NumDimensions', 2, 'Perplexity', 30, 'Standardize', true);
color_safe = [0.65, 0.65, 0.65];      
color_fail = [0.85, 0.20, 0.20];      
n_colors = 256;
custom_cmap = [linspace(0, 0, n_colors)', linspace(0, 1, n_colors)', linspace(0.5, 1, n_colors)']; 
custom_cmap_part2 = [linspace(0, 1, n_colors)', linspace(1, 1, n_colors)', linspace(1, 0, n_colors)']; 
heatmap_cmap = 'turbo'; 
font_name = 'Arial'; 
font_size_title = 14;
font_size_label = 16;
%% ========================================================================
h_fig1 = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 700, 550]);
hold on; box on;
idx_safe = find(groundTruth == 0);
s1 = scatter(Y(idx_safe, 1), Y(idx_safe, 2), 25, color_safe, 'filled', ...
    'MarkerFaceAlpha', 0.5, ... 
    'MarkerEdgeAlpha', 0.5, ...
    'DisplayName', 'Safe Scenarios');
idx_fail = find(groundTruth == 1);
s2 = scatter(Y(idx_fail, 1), Y(idx_fail, 2), 35, color_fail, 'filled', ...
    'MarkerEdgeColor', 'w', ... 
    'LineWidth', 0.5, ...
    'MarkerFaceAlpha', 0.9, ...
    'DisplayName', 'Failures');

xlabel('Dimension 1 (t-SNE)', 'Interpreter', 'latex', 'FontSize', 25);
ylabel('Dimension 2 (t-SNE)', 'Interpreter', 'latex', 'FontSize', 25);

grid on; 
set(gca, 'GridLineStyle', ':', 'GridAlpha', 0.4, 'LineWidth', 1.0, ...
    'FontName', font_name, 'FontSize', 16, 'TickDir', 'out');
lgd = legend([s1, s2], 'Location', 'best');
set(lgd, 'Interpreter', 'latex', 'FontSize', 18, 'Box', 'on', 'EdgeColor', [0.8 0.8 0.8]);
set(gcf, 'PaperPositionMode', 'auto');
% exportgraphics(h_fig1, 'tSNE_RL.pdf', 'ContentType', 'vector');
hold off;
%% ========================================================================
h_fig2=figure('Color', 'w', 'Position', [100, 100, 500,800]);
ax1=subplot(2, 1, 1);
imagesc(saved_Cov_Safe); 
colormap('jet'); colorbar;
caxis_val = max(max(saved_Cov_Danger)); 
caxis([0, caxis_val]); 
title({'Safe Scenario'}, 'Interpreter', 'latex', 'FontSize', 16);
xlabel('Feature Index', 'Interpreter', 'latex', 'FontSize', 14); 
ylabel('Feature Index', 'Interpreter', 'latex', 'FontSize', 14);
axis square;
ax2=subplot(2, 1, 2);
imagesc(saved_Cov_Danger); 
colormap('jet'); colorbar;
caxis([0, caxis_val]); 
title({'Failure'}, 'Interpreter', 'latex', 'FontSize', 16);
xlabel('Feature Index', 'Interpreter', 'latex', 'FontSize', 14); 
ylabel('Feature Index', 'Interpreter', 'latex', 'FontSize', 14);

axis square;
plot_width  = 0.65;  
plot_height = 0.35;  
left_margin = 0.13;  
set(ax2, 'Position', [left_margin, 0.1, plot_width, plot_height]);
set(ax1, 'Position', [left_margin, 0.1 + plot_height + 0.12, plot_width, plot_height]);

set(gcf, 'PaperPositionMode', 'auto');
% exportgraphics(h_fig2, 'covariance_RL.pdf', 'ContentType', 'vector');

