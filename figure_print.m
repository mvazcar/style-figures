% =========================================================================
% figure_print: save a figure as PNG at 300 dpi, the convention
%
%   figure_print(file, fig, dpi, sheet)
%
% Prints fig, the current figure by default, to the PNG file at dpi dots
% per inch, 300 by default, at the figure's screen size in inches, as
% figure_style sets it. A file name without an extension gets .png.
% Every visible subplot has x and y ticks and labels restored before export.
% Generate PNG at 300 dpi only unless the user explicitly requests another
% format or resolution. Do not automatically generate companion PDFs.
%
% sheet, [width height] in inches, is for a figure larger than the
% display: MATLAB clamps a figure to the display it draws on, and a
% printed rescaling does not keep every font at its size. Draw the figure
% instead at a fraction s of the sheet, with the fonts and lines scaled by
% s, figure_style(24*s, 3*s), and pass the sheet here: the figure is
% printed at dpi/s dots per inch, which gives the pixels of the sheet at
% dpi, with everything in the proportions drawn.
%
%   figure_print('basic.png')
%   sheet = [25.5, 31.875] ; s = 13/sheet(2) ;
%   figure_style(24*s, 3*s) ; fig = figure('Position', [1, 1, sheet*s]) ; ...
%   figure_print(fullfile(figdir, 'panels'), fig, 300, sheet) ; figure_style() ;
% =========================================================================
function figure_print(file, fig, dpi, sheet)

if nargin < 2 || isempty(fig), fig = gcf ; end
if nargin < 3 || isempty(dpi), dpi = 300 ; end
[folder, name, ext] = fileparts(file) ;
if isempty(ext), file = fullfile(folder, [name '.png']) ; end
if nargin >= 4 && ~isempty(sheet)
    units = get(fig, 'Units') ;
    set(fig, 'Units', 'inches') ;
    pos = get(fig, 'Position') ;
    set(fig, 'Units', units) ;
    dpi = dpi*sheet(1)/pos(3) ;       % the figure is drawn at the fraction pos(3)/sheet(1) of the sheet
end
set(fig, 'PaperPositionMode', 'auto') ;
figure_ticks(fig) ;
print(fig, '-dpng', sprintf('-r%d', round(dpi)), file) ;
end
