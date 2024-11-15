%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    3/29/2018 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   GUI for identifying pixel locations and sounding values on maps
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function Thrust2D
close all; clear all;

if isdeployed
%     fprintf(sprintf('%s\n',ctfroot));
    direc = fullfile(ctfroot);
else
    direc = '.';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% I/O options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

global GLOBAL ul cul st;
GLOBAL.filestream = 1;
ul  = 10; % number of navigation undo levels
cul = ul - 1; % current undo level
st  = 2; % where to start counting the undo levels

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Data variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

CDcolumns = {'X','Y','Longitude','Latitude','Name'};
Geocolumns = {'X1','Z1','X2','Z2','s'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Visualization variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

white                       = [1 1 1];
lightGrey                   = 0.9 * [1 1 1];
fn                          = 'Helvetica';
fs                          = 12;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Open Figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

screensize                  = get(0, 'screensize');
figloc                      = screensize(3:4)./2 - screensize(3:4)./4;
figpos                      = [figloc 1000 720];
fSize                       = [figpos(3) figpos(4) figpos(3) figpos(4)];
hFig                        = figure('Position', figpos, 'Color', lightGrey, 'menubar', 'figure', 'toolbar', 'figure');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

Border                      = 40; % border width (right and left at least)
Buffer                      = 10;
PbWid                       = 96; % push-button width (pixels)
PbHt                        = 25; % push-button height (pixels)
MaWid                       = (1000 - 2*Border - Buffer)*2/3; % Map Area Width (pixels)
DataWid                     = (1000 - 2*Border - Buffer)*1/3; % Data Area Width
Middle                       = (720 )*1/2;
DataFigHt                   = 200;
SegFigHt                    = 200;
CaxHt                       = 40+34;
NavHt                       = 110;
ConHt                       = 210;
DataHt                      = 430;
By                          = 425; % Button height

%%% Set up Figure Panels (Top figure shows data/forward model; bottom figure shows fault geometry)
T2D.DataFig                  = axes('parent', hFig, 'units', 'pixels', 'position', [Border Middle+Border+CaxHt MaWid DataFigHt], 'visible', 'on', 'Tag', 'T2D.DataFig', 'Layer', 'top', 'xlim', [-200 200], 'ylim', [-90 90], 'FontName', fn);
T2D.SegFig                   = axes('parent', hFig, 'units', 'pixels', 'position', [Border Border+CaxHt MaWid SegFigHt], 'visible', 'on', 'Tag', 'T2D.SegFig', 'Layer', 'top', 'xlim', [-200 200], 'ylim', [-90 10], 'FontName', fn);
By                          = Border+NavHt+CaxHt+DataFigHt+2; % height of buttons
% keyboard
%%% colorbar
T2D.cAxis                    = axes('parent', hFig, 'units', 'pixels', 'Position', [Border Border+NavHt MaWid CaxHt], 'visible', 'off', 'tag', 'T2D.cAxis', 'Layer', 'top', 'xlim', [0 360], 'ylim', [-90 90], 'FontName', fn);
T2D.ch                       = colorbar('horizontal','Position',[0.046 0.224 0.59 0.018],'FontName',fn,'FontSize',fs,'visible','off','AxisLocation','in');

%%% Data Panel
cw                          = 60;
T2D.dataPanel                = uipanel('units', 'pixels', 'position', [1000-Border-DataWid Border+DataHt+Buffer DataWid ConHt], 'visible', 'on', 'tag',  'T2D.dataPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k', 'Title', 'Data','fontsize',fs+2,'ShadowColor',lightGrey,'HighlightColor','w');
P                           = get(T2D.dataPanel,'Position');
pSize                       = [P(3:4) P(3:4)];
pbl                         = PbWid/pSize(1);
pbw                         = PbHt/pSize(2);
T2D.contSel                  = uicontrol('parent', T2D.dataPanel, 'style', 'togglebutton', 'Position', pSize.*[0.02 (By-(Border+DataHt+Buffer))/pSize(2) pbl pbw], 'visible', 'on', 'tag', 'T2D.contSel', 'callback', 'T2DFunctions(''T2D.contSel'')', 'string', 'Add', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
T2D.contLoad                 = uicontrol('parent', T2D.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+pbl (By-(Border+DataHt+Buffer))/pSize(2) pbl pbw], 'visible', 'on', 'tag', 'T2D.contLoad', 'callback', 'T2DFunctions(''T2D.contLoad'')', 'string', 'Load', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
T2D.contExp                  = uicontrol('parent', T2D.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+2*pbl (By-(Border+DataHt+Buffer))/pSize(2) pbl pbw], 'visible', 'on', 'tag', 'T2D.contExp', 'callback', 'T2DFunctions(''T2D.contExp'')', 'string', 'Export', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
% T2D.contList                 = uitable('parent', T2D.dataPanel,'ColumnName', CDcolumns, 'ColumnWidth', {cw cw cw cw cw}, 'ColumnEditable',true,'RowName', [],'Position', pSize.*[0.020 0.160 3*pbl 0.628], 'visible', 'on', 'tag', 'T2D.geoList', 'BackgroundColor', white, 'FontName', fn, 'FontSize', fs, 'ForegroundColor', 'k');
T2D.contMove                 = uicontrol('parent', T2D.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.02 pbl pbw], 'visible', 'on', 'tag', 'T2D.contMove', 'callback', 'T2DFunctions(''T2D.contMove'')', 'string', 'Move Point', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
T2D.contDel                  = uicontrol('parent', T2D.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+pbl 0.02 pbl pbw], 'visible', 'on', 'tag', 'T2D.contDel', 'callback', 'T2DFunctions(''T2D.contDel'')', 'string', 'Delete Point', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
T2D.contClear                = uicontrol('parent', T2D.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+2*pbl 0.02 pbl pbw], 'visible', 'on', 'tag', 'T2D.contClear', 'callback', 'T2DFunctions(''T2D.contClear'')', 'string', 'Clear Points', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
set(findall(T2D.dataPanel, '-property', 'enable'), 'enable', 'off')

% Fault
cw                          = DataWid/5 - 3;
T2D.geoPanel                = uipanel('units', 'pixels', 'position', [1000-Border-DataWid Border DataWid DataHt], 'visible', 'on', 'tag',  'T2D.geoPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k', 'Title', 'Fault Segments','fontsize',fs+2,'ShadowColor',lightGrey,'HighlightColor','w');
P                           = get(T2D.geoPanel,'Position');
pSize                       = [P(3:4) P(3:4)];
pbl                         = PbWid/pSize(1);
pbw                         = PbHt/pSize(2);

% T2D.dataSel                  = uicontrol('parent', T2D.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.9 pbl pbw], 'visible', 'on', 'tag', 'T2D.dataSel', 'callback', 'T2DFunctions(''T2D.dataSel'')', 'string', 'Add', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
T2D.geoLoad                  = uicontrol('parent', T2D.geoPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.9 pbl pbw], 'visible', 'on', 'tag', 'T2D.geoLoad', 'callback', 'T2DFunctions(''T2D.geoLoad'')', 'string', 'Load', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);

% T2D.dataStop                 = uicontrol('parent', T2D.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.9 pbl pbw], 'visible', 'off', 'enable', 'off','tag', 'T2D.dataStop', 'callback', 'T2DFunctions(''T2D.dataStop'')', 'string', 'Stop Adding', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);

T2D.geoDraw                 = uicontrol('parent', T2D.geoPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+pbl 0.9 pbl pbw], 'visible', 'on', 'tag', 'T2D.geoDraw', 'callback', 'T2DFunctions(''T2D.geoDraw'')', 'string', 'Draw from [0,0]', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
T2D.geoExp                  = uicontrol('parent', T2D.geoPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+2*pbl 0.9 pbl pbw], 'visible', 'on', 'tag', 'T2D.geoExp', 'callback', 'T2DFunctions(''T2D.geoExp'')', 'string', 'Export', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
T2D.geoList                 = uitable('parent', T2D.geoPanel,'ColumnName', Geocolumns, 'ColumnWidth', {cw cw cw cw cw}, 'ColumnEditable',false,'RowName', [],'Position', pSize.*[0.020 0.03+pbw 3*pbl (0.9-0.04-pbw)], 'visible', 'on', 'tag', 'T2D.geoList', 'BackgroundColor', white, 'FontName', fn, 'FontSize', fs, 'ForegroundColor', 'k');
% T2D.dataEdit                 = uicontrol('parent', T2D.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.02 pbl pbw], 'visible', 'on', 'tag', 'T2D.dataEdit', 'callback', 'T2DFunctions(''T2D.dataEdit'')', 'string', 'Edit Point', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
T2D.geoMove                 = uicontrol('parent', T2D.geoPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.02 pbl pbw], 'visible', 'on', 'tag', 'T2D.geoMove', 'callback', 'T2DFunctions(''T2D.geoMove'')', 'string', 'Move Point', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
T2D.geoDel                  = uicontrol('parent', T2D.geoPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+pbl 0.02 pbl pbw], 'visible', 'on', 'tag', 'T2D.geoDel', 'callback', 'T2DFunctions(''T2D.geoDel'')', 'string', 'Delete Segment', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
T2D.geoClear                = uicontrol('parent', T2D.geoPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+2*pbl 0.02 pbl pbw], 'visible', 'on', 'tag', 'T2D.geoClear', 'callback', 'T2DFunctions(''T2D.geoClear'')', 'string', 'Clear Segments', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
set(findall(T2D.geoPanel, '-property', 'enable'), 'enable', 'off')
set([T2D.geoLoad, T2D.geoDraw],'enable','on')

%%% Set up Navigation Area
% nav                         = uipanel('units', 'pixels','Position', [Border Border MaWid NavHt], 'visible', 'on', 'tag', 'T2D.navPanel', 'BackgroundColor', lightGrey, 'ShadowColor','w','HighlightColor',lightGrey,'ForegroundColor','k', 'Title', 'Navigation','FontName',fn,'fontsize',fs+2);
% yb                          = 10;
% bw                          = 25;
% xr                          = Border + MaWid - 3*Buffer - 4*bw;
% T2D.navSW                    = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr      yb    bw bw],  'visible', 'on', 'tag', 'T2D.navSW',   'callback', 'T2DFunctions(''T2D.navSW'')', 'string', 'SW', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
% T2D.navS                     = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+bw   yb    bw bw],  'visible', 'on', 'tag', 'T2D.navS',    'callback', 'T2DFunctions(''T2D.navS'')',  'string', 'S', 'BackgroundColor',  lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
% T2D.navSE                    = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+2*bw yb    bw bw],  'visible', 'on', 'tag', 'T2D.navSE',   'callback', 'T2DFunctions(''T2D.navSE'')', 'string', 'SE', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
% T2D.navW                     = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr      yb+bw   bw bw],  'visible', 'on', 'tag', 'T2D.navW',    'callback', 'T2DFunctions(''T2D.navW'')',  'string', 'E', 'BackgroundColor',  lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
% T2D.navE                     = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+2*bw yb+bw   bw bw],  'visible', 'on', 'tag', 'T2D.navE',    'callback', 'T2DFunctions(''T2D.navE'')',  'string', 'W', 'BackgroundColor',  lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
% T2D.navNW                    = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr      yb+2*bw bw bw],  'visible', 'on', 'tag', 'T2D.navNW',   'callback', 'T2DFunctions(''T2D.navNW'')', 'string', 'NW', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
% T2D.navN                     = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+bw   yb+2*bw bw bw],  'visible', 'on', 'tag', 'T2D.navN',    'callback', 'T2DFunctions(''T2D.navN'')',  'string', 'N', 'BackgroundColor',  lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
% T2D.navNE                    = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+2*bw yb+2*bw bw bw],  'visible', 'on', 'tag', 'T2D.navNE',   'callback', 'T2DFunctions(''T2D.navNE'')', 'string', 'NE', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
% 
% T2D.savePush                 = uicontrol('parent', nav, 'style', 'pushbutton', 'Position', [330   yb PbWid PbHt],  'visible', 'off', 'tag', 'T2D.savePush',  'callback', 'T2DFunctions(''T2D.saveOut'')', 'string', 'Save Output', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
% T2D.plotSave                 = uicontrol('parent', nav, 'style', 'pushbutton', 'Position', [330 yb+bw PbWid PbHt],  'visible', 'off', 'tag', 'T2D.savePlot',  'callback', 'T2DFunctions(''T2D.savePlot'')', 'string', 'Save Plot', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);

% longitude and latitude ranges
bl                      = 80;
tl                      = 30;
tw                      = 18;
el                      = bl-tl;
% T2D.navEditLonMax        = uicontrol('parent', nav, 'style', 'edit',       'position', [10       yb+2*bw el bw],  'visible', 'on', 'tag', 'T2D.navEditLonMax', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
% T2D.navTextLonMax        = uicontrol('parent', nav, 'style', 'text',       'position', [10+el      yb+2*bw tl tw],  'visible', 'on', 'tag', 'T2D.navTextLonMax', 'string', 'Lon+', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
% T2D.navEditLonMin        = uicontrol('parent', nav, 'style', 'edit',       'position', [10      yb+bw   el bw],  'visible', 'on', 'tag', 'T2D.navEditLonMin', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
% T2D.navTextLonMin        = uicontrol('parent', nav, 'style', 'text',       'position', [10+el      yb+bw   tl tw],  'visible', 'on', 'tag', 'T2D.navTextLonMin', 'string', 'Lon-', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
% T2D.navEditLatMax        = uicontrol('parent', nav, 'style', 'edit',       'position', [10+bl      yb+2*bw el bw],  'visible', 'on', 'tag', 'T2D.navEditLatMax', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
% T2D.navTextLatMax        = uicontrol('parent', nav, 'style', 'text',       'position', [10+bl+el   yb+2*bw tl tw], 'visible', 'on', 'tag', 'T2D.navTextLatMax', 'string', 'Lat+', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
% T2D.navEditLatMin        = uicontrol('parent', nav, 'style', 'edit',       'position', [10+bl      yb+bw   el bw],  'visible', 'on', 'tag', 'T2D.navEditLatMin', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
% T2D.navTextLatMin        = uicontrol('parent', nav, 'style', 'text',       'position', [10+bl+el   yb+bw   tl tw], 'visible', 'on', 'tag', 'T2D.navTextLatMin', 'string', 'Lat-', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
% T2D.navUpdate            = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [10+2*bl    yb+2*bw bl bw], 'visible', 'on', 'tag', 'T2D.navUpdate', 'callback', 'T2DFunctions(''T2D.navUpdate'')','string', 'Update', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
% T2D.navBack              = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [10+2*bl    yb+bw   bl bw], 'visible', 'on', 'tag', 'T2D.navBack',   'callback', 'T2DFunctions(''T2D.navBack'')','string', 'Back',   'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

% Zoom options
% T2D.navZoomIn            = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [10+0    yb bl bw],    'visible', 'on', 'tag', 'T2D.navZoomIn', 'callback', 'T2DFunctions(''T2D.navZoomIn'')','string', 'Zoom In', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
% T2D.navZoomOut           = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [10+bl   yb bl bw],    'visible', 'on', 'tag', 'T2D.navZoomOut', 'callback', 'T2DFunctions(''T2D.navZoomOut'')','string', 'Zoom Out', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
% T2D.navZoomRange         = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [10+2*bl yb bl bw],    'visible', 'on', 'tag', 'T2D.navZoomRange', 'callback', 'T2DFunctions(''T2D.navZoomRange'')', 'string', 'Zoom Range', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Finalize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Create handles structure for easy use in the callback later
cla(T2D.DataFig);
Handles.T2D = T2D;
set(hFig, 'userdata', Handles);
set(gca, 'Fontname', fn, 'FontSize', fs)

axes(T2D.SegFig)
%%% Make this a "plot surface" function
xl = get(gca,'xlim');
hold on; plot(xl,[0 0],'-','Color',0.5*[0 1 0])

% Make all figure components normalized so that they auto-resize on figure resize
set(findall(hFig,'-property','Units'),'Units','norm');

% Making the GUI visible and give it a name
set(hFig, 'visible', 'on', 'name', 'Thrust2D','HandleVisibility','on');
set(hFig, 'DoubleBuffer', 'on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% plotmap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% axes(T2D.mapAx);
% h = imshow('./Images/ApproachestoSeattle_1940.jpg');