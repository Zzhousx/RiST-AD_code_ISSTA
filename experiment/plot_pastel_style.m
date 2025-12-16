function gcf=plot_pastel_style(N, t_map, t_inf)
    col_map = [114, 158, 206] / 255; 
    col_inf = [237, 151, 142] / 255;
    area_data = [t_map, t_inf];
    gcf=figure('Color', 'w', 'Units', 'centimeters', 'Position', [8, 8, 14, 10]);
    h = area(N, area_data);
    h(1).FaceColor = col_map;
    h(1).EdgeColor = 'none';
    h(1).FaceAlpha = 0.9;
    h(2).FaceColor = col_inf;
    h(2).EdgeColor = 'none';
    h(2).FaceAlpha = 0.9;
    ax = gca;
    grid on;
    ax.GridLineStyle = '-';
    ax.GridColor = [0.85, 0.85, 0.85];
    ax.GridAlpha = 1;
    ax.Layer = 'bottom'; 
    ax.FontName = 'Times New Roman';
    ax.FontSize = 14;
    ax.LineWidth = 1.0;
    ax.Color = 'none';
    ax.Box = 'off';
    ax.TickDir = 'out';
    ax.XColor = [0.2, 0.2, 0.2];
    ax.YColor = [0.2, 0.2, 0.2];
    xlim([min(N), max(N)]);
    xlabel('Number of Scenarios ($N$)', 'Interpreter', 'latex', ...
           'FontName', 'Times New Roman', 'FontSize', 18);
    ylabel('Execution Time (s)', 'FontName', 'Times New Roman', 'FontSize', 18);
    lgd = legend({'Riemannian Mapping', 'DPP Inference'}, ...
                 'Location', 'northwest', 'Box', 'off');
    lgd.FontSize = 16;
    lgd.FontName = 'Times New Roman';
    total_max = max(t_map + t_inf);
    ylim([0, total_max * 1.1]);
end