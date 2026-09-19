% A reproducible 2-by-2 layout, with both axes labelled on every panel.
templateRoot = fileparts(fileparts(mfilename('fullpath'))) ;
addpath(templateRoot) ;
sheet = [17 12.75] ;
scale = 0.5 ; % Fit on screen; figure_print restores the sheet dimensions.
figure_style(24*scale, 3*scale) ;
fig = figure('Position', [1 1 sheet*scale]) ;
tiledlayout(fig, 2, 2, 'TileSpacing', 'loose', 'Padding', 'loose') ;
x = linspace(0, 10, 101) ;
axesList = gobjects(1, 4) ;
for i = 1:4
    ax = nexttile ; axesList(i) = ax ; hold(ax, 'on') ;
    plot(ax, x, 1 + 0.2*sin(x + (i-1)/2), '-', 'DisplayName', 'Series A') ;
    plot(ax, x, 1 + 0.2*sin(x + (i-1)/2 + 0.4), '--', 'DisplayName', 'Series B') ;
    title(ax, sprintf('Panel %d', i)) ; xlabel(ax, 'Time') ; ylabel(ax, 'Value') ;
    set(ax, 'XTick', 0:2:10, 'YTick', [0.8 1 1.2], 'YLim', [0.75 1.3]) ;
    legend(ax, 'Location', 'northeast', 'NumColumns', 2) ;
end
linkaxes(axesList, 'xy') ;
figure_print(fullfile(templateRoot, 'figures', 'matlab_panels.png'), fig, 300, sheet) ;
figure_style() ;
