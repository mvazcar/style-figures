% figure_ticks: show x and y ticks and tick labels on every visible panel.
%
%   figure_ticks(fig)
%
% Call after plotting, or let figure_print call it before export. Non-empty
% custom tick positions and labels are preserved. Empty ticks/labels are
% restored to automatic values. Axes deliberately hidden with axis off are
% skipped, as are legends and colourbars. The current figure is the default.
function figure_ticks(fig)
if nargin < 1 || isempty(fig), fig = gcf ; end
axesList = findall(fig, 'Type', 'axes') ;
for ax = reshape(axesList, 1, [])
    if strcmp(ax.Visible, 'off'), continue ; end
    ax.XAxis.Visible = 'on' ;
    ax.YAxis.Visible = 'on' ;
    if isempty(ax.XTick), ax.XTickMode = 'auto' ; end
    if isempty(ax.YTick), ax.YTickMode = 'auto' ; end
    if isempty(ax.XTickLabel) || all(strlength(string(ax.XTickLabel)) == 0)
        ax.XTickLabelMode = 'auto' ;
    end
    if isempty(ax.YTickLabel) || all(strlength(string(ax.YTickLabel)) == 0)
        ax.YTickLabelMode = 'auto' ;
    end
    if all(ax.TickLength == 0), ax.TickLength = [0.005 0.005] ; end
end
end
