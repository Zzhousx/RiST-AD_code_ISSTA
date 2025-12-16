function fig_handle = run_APFDc_fig(methods_data)
    c_magenta = [0.85, 0.00, 0.85]; 
    c_red     = [0.85, 0.10, 0.10]; 
    c_blue    = [0.00, 0.20, 0.80]; 
    c_green   = [0.00, 0.60, 0.20]; 
    c_black   = [0.00, 0.00, 0.00]; 
    palette = {c_magenta, c_red, c_blue, c_green, c_black};
    fig_handle = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 650, 500]);
    hold on; box on;
    set(gca, 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 1.2); 
    target_x = 30;
    line([target_x, target_x], [0, 100], 'Color', [0.5 0.5 0.5], ...
         'LineStyle', '--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
    num_methods = length(methods_data);
    lines = gobjects(num_methods, 1);
    order = 1:num_methods;   
    for i = 1:num_methods
        data = methods_data(i);
        if data.is_rnd
            curr_color = c_black;
            lw = 1.5; 
        elseif data.is_ours
            curr_color = c_magenta;
            lw = 2; 
        else
            if i == 2, curr_color = c_red;
            elseif i == 3, curr_color = c_blue;
            else, curr_color = c_green;
            end
            lw = 1.5;
        end
        lines(i) = plot(data.x, data.y, 'Color', curr_color, ...
            'LineWidth', lw, 'DisplayName', sprintf('%s (APFDc: %.3f)', data.name, data.apfdc));
        y_val = interp1(data.x, data.y, target_x, 'linear');
        line([0, target_x], [y_val, y_val], 'Color', curr_color, ...
             'LineStyle', '--', 'LineWidth', 1.0, 'HandleVisibility', 'off');
        txt_str = sprintf('%.1f%% faults', y_val);
        vertical_align = 'bottom'; 
        vertical_align = 'top';
        if data.is_rnd
            vertical_align = 'top'; 
        end
        text(target_x + 1, y_val, txt_str, ...
            'FontSize', 12, ...
            'VerticalAlignment', vertical_align);
    end
    for i = 1:num_methods
        if methods_data(i).is_ours
            uistack(lines(i), 'top');
        end
    end
    xlabel('Test Execution Cost (%)', 'FontSize', 16);
    ylabel('Fault Detected (%)', 'FontSize', 16);
    
    xlim([0, 100]);
    ylim([0, 100]); 
    lgd = legend(lines, 'Location', 'southeast');
    set(lgd, 'FontSize', 13, 'Box', 'on', 'EdgeColor', 'k');
    
    hold off;
end