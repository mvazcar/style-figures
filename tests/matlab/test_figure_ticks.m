function tests = test_figure_ticks
tests = functiontests(localfunctions) ;
end

function setupOnce(testCase)
testCase.TestData.defaults = get(groot, 'default') ;
addpath(fileparts(fileparts(fileparts(mfilename('fullpath'))))) ;
figure_style() ;
end

function teardownOnce(testCase)
reset(groot) ;
set(groot, testCase.TestData.defaults) ;
end

function teardown(~)
close all force
end

function testFontFamily(testCase)
s = figure_style() ;
fig = figure('Visible', 'off') ;
ax = axes(fig) ; plot(ax, 1:3) ; label = xlabel(ax, 'Age') ;
verifyTrue(testCase, any(strcmp(s.font_name, {'Helvetica', 'Arial'}))) ;
verifyEqual(testCase, ax.FontName, s.font_name) ;
verifyEqual(testCase, label.FontName, s.font_name) ;
end

function testDefaultExportIsOnlyPngAt300Dpi(testCase)
fig = figure('Visible', 'off', 'Position', [1 1 4 3]) ;
ax = axes(fig) ; plot(ax, 1:3) ;
folder = tempname ; mkdir(folder) ;
output = fullfile(folder, 'default') ;
cleanup = onCleanup(@() delete([output '.png'])) ; %#ok<NASGU>
figure_print(output, fig) ;
info = imfinfo([output '.png']) ;
verifyEqual(testCase, info.Format, 'png') ;
verifyEqual(testCase, info.Width, 1200, 'AbsTol', 2) ;
verifyEqual(testCase, info.Height, 900, 'AbsTol', 2) ;
files = dir(fullfile(folder, '*.*')) ;
verifyEqual(testCase, sum(~[files.isdir]), 1) ;
end

function testLinkedPanelsRestoreLabels(testCase)
fig = figure('Visible', 'off') ;
tiledlayout(fig, 2, 2) ;
axesList = gobjects(1, 4) ;
for i = 1:4
    axesList(i) = nexttile ;
    plot(axesList(i), 0:2, [1 2 3]) ;
    axesList(i).XTickLabel = [] ;
    axesList(i).YTickLabel = [] ;
end
linkaxes(axesList, 'xy') ;
figure_ticks(fig) ; drawnow ;
for ax = axesList
    verifyNotEmpty(testCase, ax.XTickLabel) ;
    verifyNotEmpty(testCase, ax.YTickLabel) ;
    verifyGreaterThan(testCase, ax.TickLength(1), 0) ;
end
xlim(axesList(1), [-1 4]) ;
verifyEqual(testCase, axesList(4).XLim, [-1 4]) ;
end

function testPreserveCustomLabelsAndHiddenPanel(testCase)
fig = figure('Visible', 'off') ;
ax = subplot(1, 2, 1, 'Parent', fig) ;
plot(ax, 0:2, [1 2 3]) ;
set(ax, 'XTick', [0 2], 'XTickLabel', {'Start', 'End'}, ...
    'YTick', [1 2 3], 'YTickLabel', {'Low', 'Mid', 'High'}) ;
hidden = subplot(1, 2, 2, 'Parent', fig) ; axis(hidden, 'off') ;
figure_ticks(fig) ;
verifyEqual(testCase, string(ax.XTickLabel), ["Start"; "End"]) ;
verifyEqual(testCase, string(ax.YTickLabel), ["Low"; "Mid"; "High"]) ;
verifyEqual(testCase, string(hidden.Visible), "off") ;
end

function testExportRestoresTicks(testCase)
fig = figure('Visible', 'off', 'Position', [1 1 4 3]) ;
ax = axes(fig) ; plot(ax, 1:3) ;
ax.XTick = [] ; ax.YTickLabel = [] ; ax.TickLength = [0 0] ;
output = [tempname '.png'] ;
cleanup = onCleanup(@() delete(output)) ; %#ok<NASGU>
figure_print(output, fig, 80) ; drawnow ;
verifyNotEmpty(testCase, ax.XTick) ;
verifyNotEmpty(testCase, ax.YTickLabel) ;
verifyGreaterThan(testCase, ax.TickLength(1), 0) ;
info = imfinfo(output) ;
verifyEqual(testCase, info.Width, 320, 'AbsTol', 2) ;
verifyEqual(testCase, info.Height, 240, 'AbsTol', 2) ;
end
