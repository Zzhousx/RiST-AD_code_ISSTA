function plot_cost_efficiency(cost_struct)
    names = {cost_struct.name};
    costs = [cost_struct.cost];
    num_methods = length(names);
    base_color = [44, 62, 80] / 255;   
    light_color = [220, 220, 220] / 255; 
    figure('Color', 'w', 'Units', 'centimeters', 'Position', [5, 5, 16, 11]); 
    hold on;
    b = bar(costs, 'FaceColor', 'flat', 'EdgeColor', 'none', 'BarWidth', 0.55);
    min_c = min(costs);
    max_c = max(costs);
    for i = 1:num_methods
        val = costs(i);
        name = names{i};
        if strcmpi(name, 'RiST-AD') || contains(name, 'Ours', 'IgnoreCase', true)
            b.CData(i, :) = base_color;
        elseif strcmpi(name, 'Random')
            b.CData(i, :) = light_color;
        else
            ratio = (val - min_c) / (max_c - min_c); 
            ratio = ratio * 0.8 + 0.1; 
            b.CData(i, :) = base_color + (light_color - base_color) * ratio;
        end
    end
    ax = gca;
    ax.FontName = 'Times New Roman'; 
    ax.FontSize = 13;                
    ax.LineWidth = 1.2;              
    ax.Color = 'none';
    ax.Box = 'off';                  
    ax.TickDir = 'out';              
    ax.XColor = [0.15, 0.15, 0.15];
    ax.YColor = [0.15, 0.15, 0.15];
    set(gca, 'XTick', 1:num_methods, 'XTickLabel', names);
    xtickangle(0);
    ylabel('Execution Cost (s)', 'FontName', 'Times New Roman', ...
           'FontSize', 18);
    y_ticks = get(gca, 'YTick');
    y_ticks(y_ticks == 0) = []; 
    x_lim = get(gca, 'XLim');
    for y = y_ticks
        line(x_lim, [y, y], 'Color', [0.9, 0.9, 0.9], 'LineWidth', 1, 'LineStyle', '-');
    end
    uistack(b, 'top');
    for i = 1:num_methods
        val = costs(i);
        name = names{i};
        if isnan(val)
            txt = '-';
        else
            txt = sprintf('%.0f', val);
        end
        if strcmpi(name, 'RiST-AD') || contains(name, 'Ours', 'IgnoreCase', true)
            weight = 'bold';
            col = base_color; 
            fs = 13; 
        else
            weight = 'normal';
            col = [0.4, 0.4, 0.4];
            fs = 12;
        end
        
        text(i, val, txt, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontName', 'Times New Roman', ... 
            'FontSize', fs, ...
            'Color', col, ...
            'FontWeight', weight, ...
            'Margin', 5); 
    end
    if ~all(isnan(costs))
        ylim([0, max(costs) * 1.2]);
    end
    set(gcf, 'PaperPositionMode', 'auto');
    exportgraphics(gcf, 'cost_times_RL.pdf', 'ContentType', 'vector');
    hold off;
end