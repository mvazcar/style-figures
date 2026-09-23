% =========================================================================
% figure_style: the figure template, with Set1 or classic MATLAB colours
%
%   s = figure_style(fontSize, lineWidth, palette)
%
% Sets the graphics defaults of the template, a minimalist style after
% Tufte: Helvetica, black axes and grid, ticks out and short, horizontal
% grid only, no box, axes line width 1, title in normal weight, labels
% and title in the axes font size, white figures 8.5 by 6.375 inches
% printed at their screen size. Set1 remains the default palette. Pass
% 'matlab' as the third argument for MATLAB's R2014b-R2024b ColorOrder.
% Colours are returned by name in s, with line width and font size in s.width and
% s.font. The single figure of the template uses a 24 point font and
% lines of width 3, the defaults; multi-panel figures keep the font and
% set their size in inches at 8.5 by 6.375 per panel. Save figures with
% figure_print, PNG at 300 dpi, the convention. Call figure_style once at
% the top of a figure script; the defaults persist for the MATLAB session.
% Each subplot keeps x and y ticks and labels. figure_print restores them
% before export; call figure_ticks(gcf) after plotting for an on-screen view.
%
%   s = figure_style() ;
%   figure ; plot(x, y, 'Color', s.blue) ; ylabel('Unit')
%   figure_print('basic.png')
% =========================================================================
function s = figure_style(fontSize, lineWidth, palette)

if nargin < 1 || isempty(fontSize), fontSize = 24 ; end
if nargin < 2 || isempty(lineWidth), lineWidth = 3 ; end
if nargin < 3 || isempty(palette), palette = 'set1' ; end
palette = validatestring(palette, {'set1', 'matlab'}) ;
availableFonts = listfonts ;
if any(strcmp(availableFonts, 'Helvetica'))
    fontName = 'Helvetica' ;
elseif any(strcmp(availableFonts, 'Arial'))
    fontName = 'Arial' ;
else
    error('style_figures:MissingFont', 'Install Helvetica or Arial before calling figure_style.') ;
end

% Set1, ColorBrewer
hex = {'377eb8', 'e41a1c', '4daf4a', '984ea3', 'ff7f00', 'ffff33', 'a65628', 'f781bf', '999999'} ;
set1 = zeros(9, 3) ;
for i = 1:9
    set1(i, :) = transpose(sscanf(hex{i}, '%2x%2x%2x'))/255 ;
end
matlab = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250; ...
    0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880; ...
    0.3010 0.7450 0.9330; 0.6350 0.0780 0.1840] ;
s.set1 = set1 ; s.matlab = matlab ; s.palette = palette ;
s.brown = set1(7, :) ; s.pink = set1(8, :) ; s.gray = set1(9, :) ;
s.cyan = matlab(6, :) ; s.black = [0 0 0] ;
if strcmp(palette, 'matlab')
    colors = matlab ;
    s.blue = matlab(1, :) ; s.orange = matlab(2, :) ; s.yellow = matlab(3, :) ;
    s.purple = matlab(4, :) ; s.green = matlab(5, :) ; s.red = matlab(7, :) ;
else
    colors = set1 ;
    s.blue = set1(1, :) ; s.red = set1(2, :) ; s.green = set1(3, :) ;
    s.purple = set1(4, :) ; s.orange = set1(5, :) ; s.yellow = set1(6, :) ;
end
s.width = lineWidth ;
s.font = fontSize ;
s.font_name = fontName ;

% Figure: white, 4:3 at 8.5 by 6.375 inches, printed at its screen size
set(groot, 'defaultFigureColor', 'w') ;
set(groot, 'defaultFigureUnits', 'inches') ;
set(groot, 'defaultFigurePosition', [1, 1, 8.5, 6.375]) ;
set(groot, 'defaultFigurePaperPositionMode', 'auto') ;

% Axes
set(groot, 'defaultAxesFontName', fontName) ;
set(groot, 'defaultAxesFontSize', fontSize) ;
set(groot, 'defaultAxesLabelFontSizeMultiplier', 1) ;
set(groot, 'defaultAxesTitleFontSizeMultiplier', 1) ;
set(groot, 'defaultAxesTitleFontWeight', 'normal') ;
set(groot, 'defaultAxesXColor', 'k') ;
set(groot, 'defaultAxesYColor', 'k') ;
set(groot, 'defaultAxesGridColor', 'k') ;
set(groot, 'defaultAxesLineWidth', 1) ;
set(groot, 'defaultAxesYGrid', 'on') ;
set(groot, 'defaultAxesXGrid', 'off') ;
set(groot, 'defaultAxesTickDirMode', 'manual') ;
set(groot, 'defaultAxesTickDir', 'out') ;
set(groot, 'defaultAxesTickLength', [0.005, 0.005]) ;
set(groot, 'defaultAxesXTickMode', 'auto') ;
set(groot, 'defaultAxesYTickMode', 'auto') ;
set(groot, 'defaultAxesXTickLabelMode', 'auto') ;
set(groot, 'defaultAxesYTickLabelMode', 'auto') ;
set(groot, 'defaultAxesBox', 'off') ;
set(groot, 'defaultAxesColorOrder', colors) ;

% Lines, legends and text
set(groot, 'defaultLineLineWidth', lineWidth) ;
set(groot, 'defaultLegendBox', 'off') ;
set(groot, 'defaultLegendFontName', fontName) ;
set(groot, 'defaultLegendFontSize', fontSize) ;
set(groot, 'defaultLegendInterpreter', 'tex') ;
set(groot, 'defaultTextFontName', fontName) ;
set(groot, 'defaultTextFontSize', fontSize) ;
set(groot, 'defaultTextInterpreter', 'tex') ;
set(groot, 'defaultAxesTickLabelInterpreter', 'tex') ;
end
