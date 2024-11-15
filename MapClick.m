%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    3/29/2018 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   GUI for identifying pixel locations and sounding values on maps
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function MapClick

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
Dcolumns = {'X','Y','Value'};

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
MaHt                        = 420;
CaxHt                       = 40+34;
NavHt                       = 110;
ConHt                       = 210;
DataHt                      = 430;

%%% Set up Map area
DT.mapAx                    = axes('parent', hFig, 'units', 'pixels', 'position', [Border Border+NavHt+CaxHt MaWid MaHt], 'visible', 'off', 'Tag', 'DT.mapAx', 'Layer', 'top', 'xlim', [0 360], 'ylim', [-90 90], 'FontName', fn);
DT.Maptext                  = uicontrol('parent', hFig, 'style', 'text', 'Position', [Border Border+NavHt+CaxHt+MaHt+2 PbWid PbHt], 'visible', 'on', 'tag', 'DT.loadMap', 'string', 'Image file: ', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs+2, 'HorizontalAlignment', 'left');
DT.Mapfile                  = uicontrol('parent', hFig, 'style', 'edit', 'Position', [Border+PbWid Border+NavHt+CaxHt+MaHt+2 3*PbWid PbHt], 'visible', 'on', 'tag', 'DT.mapFile', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'HorizontalAlignment', 'left');
DT.loadMap                  = uicontrol('parent', hFig, 'style', 'pushbutton', 'Position', [Border+MaWid-2*PbWid Border+NavHt+CaxHt+MaHt+2 PbWid PbHt], 'visible', 'on', 'tag', 'DT.loadMap', 'callback', 'DTFunctions(''DT.loadMap'')', 'string', 'Load Image', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.clearMap                 = uicontrol('parent', hFig, 'style', 'pushbutton', 'Position', [Border+MaWid-PbWid Border+NavHt+CaxHt+MaHt+2 PbWid PbHt], 'visible', 'on', 'tag', 'DT.clearMap', 'callback', 'DTFunctions(''DT.clearMap'')', 'string', 'Clear All', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
By                          = Border+NavHt+CaxHt+MaHt+2; % height of buttons

%%% colorbar
DT.cAxis                    = axes('parent', hFig, 'units', 'pixels', 'Position', [Border Border+NavHt MaWid CaxHt], 'visible', 'off', 'tag', 'DT.cAxis', 'Layer', 'top', 'xlim', [0 360], 'ylim', [-90 90], 'FontName', fn);
DT.ch                       = colorbar('horizontal','Position',[0.046 0.224 0.59 0.018],'FontName',fn,'FontSize',fs,'visible','off','AxisLocation','in');

%%% Control Points
cw                          = 60;
DT.contPanel                = uipanel('units', 'pixels', 'position', [1000-Border-DataWid Border+DataHt+Buffer DataWid ConHt], 'visible', 'on', 'tag',  'DT.contPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k', 'Title', 'Control Points','fontsize',fs+2,'ShadowColor',lightGrey,'HighlightColor','w');
P                           = get(DT.contPanel,'Position');
pSize                       = [P(3:4) P(3:4)];
pbl                         = PbWid/pSize(1);
pbw                         = PbHt/pSize(2);
DT.contSel                  = uicontrol('parent', DT.contPanel, 'style', 'togglebutton', 'Position', pSize.*[0.02 (By-(Border+DataHt+Buffer))/pSize(2) pbl pbw], 'visible', 'on', 'tag', 'DT.contSel', 'callback', 'DTFunctions(''DT.contSel'')', 'string', 'Add', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.contLoad                 = uicontrol('parent', DT.contPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+pbl (By-(Border+DataHt+Buffer))/pSize(2) pbl pbw], 'visible', 'on', 'tag', 'DT.contLoad', 'callback', 'DTFunctions(''DT.contLoad'')', 'string', 'Load', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.contExp                  = uicontrol('parent', DT.contPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+2*pbl (By-(Border+DataHt+Buffer))/pSize(2) pbl pbw], 'visible', 'on', 'tag', 'DT.contExp', 'callback', 'DTFunctions(''DT.contExp'')', 'string', 'Export', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.contList                 = uitable('parent', DT.contPanel,'ColumnName', CDcolumns, 'ColumnWidth', {cw cw cw cw cw}, 'ColumnEditable',true,'RowName', [],'Position', pSize.*[0.020 0.160 3*pbl 0.628], 'visible', 'on', 'tag', 'DT.contList', 'BackgroundColor', white, 'FontName', fn, 'FontSize', fs, 'ForegroundColor', 'k');
DT.contMove                 = uicontrol('parent', DT.contPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.02 pbl pbw], 'visible', 'on', 'tag', 'DT.contMove', 'callback', 'DTFunctions(''DT.contMove'')', 'string', 'Move Point', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.contDel                  = uicontrol('parent', DT.contPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+pbl 0.02 pbl pbw], 'visible', 'on', 'tag', 'DT.contDel', 'callback', 'DTFunctions(''DT.contDel'')', 'string', 'Delete Point', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.contClear                = uicontrol('parent', DT.contPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+2*pbl 0.02 pbl pbw], 'visible', 'on', 'tag', 'DT.contClear', 'callback', 'DTFunctions(''DT.contClear'')', 'string', 'Clear Points', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
set(findall(DT.contPanel, '-property', 'enable'), 'enable', 'off')

% Data Points
cw                          = 94;
DT.dataPanel                = uipanel('units', 'pixels', 'position', [1000-Border-DataWid Border DataWid DataHt], 'visible', 'on', 'tag',  'DT.dataPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k', 'Title', 'Data Points','fontsize',fs+2,'ShadowColor',lightGrey,'HighlightColor','w');
P                           = get(DT.dataPanel,'Position');
pSize                       = [P(3:4) P(3:4)];
pbl                         = PbWid/pSize(1);
pbw                         = PbHt/pSize(2);

% DT.dataSel                  = uicontrol('parent', DT.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.9 pbl pbw], 'visible', 'on', 'tag', 'DT.dataSel', 'callback', 'DTFunctions(''DT.dataSel'')', 'string', 'Add', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.dataSel                  = uicontrol('parent', DT.dataPanel, 'style', 'togglebutton', 'Position', pSize.*[0.02 0.9 pbl pbw], 'visible', 'on', 'tag', 'DT.dataSel', 'callback', 'DTFunctions(''DT.dataSel'')', 'string', 'Add', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);

% DT.dataStop                 = uicontrol('parent', DT.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.9 pbl pbw], 'visible', 'off', 'enable', 'off','tag', 'DT.dataStop', 'callback', 'DTFunctions(''DT.dataStop'')', 'string', 'Stop Adding', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);

DT.dataLoad                 = uicontrol('parent', DT.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+pbl 0.9 pbl pbw], 'visible', 'on', 'tag', 'DT.dataLoad', 'callback', 'DTFunctions(''DT.dataLoad'')', 'string', 'Load', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.dataExp                  = uicontrol('parent', DT.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+2*pbl 0.9 pbl pbw], 'visible', 'on', 'tag', 'DT.dataExp', 'callback', 'DTFunctions(''DT.dataExp'')', 'string', 'Export', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.dataList                 = uitable('parent', DT.dataPanel,'ColumnName', Dcolumns, 'ColumnWidth', {cw cw cw}, 'ColumnEditable',true,'RowName', [],'Position', pSize.*[0.020 0.03+pbw 3*pbl (0.9-0.04-pbw)], 'visible', 'on', 'tag', 'DT.contList', 'BackgroundColor', white, 'FontName', fn, 'FontSize', fs, 'ForegroundColor', 'k');
% DT.dataEdit                 = uicontrol('parent', DT.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.02 pbl pbw], 'visible', 'on', 'tag', 'DT.dataEdit', 'callback', 'DTFunctions(''DT.dataEdit'')', 'string', 'Edit Point', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.dataMove                 = uicontrol('parent', DT.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.02 pbl pbw], 'visible', 'on', 'tag', 'DT.dataMove', 'callback', 'DTFunctions(''DT.dataMove'')', 'string', 'Move Point', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.dataDel                  = uicontrol('parent', DT.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+pbl 0.02 pbl pbw], 'visible', 'on', 'tag', 'DT.dataDel', 'callback', 'DTFunctions(''DT.dataDel'')', 'string', 'Delete Point', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.dataClear                = uicontrol('parent', DT.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+2*pbl 0.02 pbl pbw], 'visible', 'on', 'tag', 'DT.dataClear', 'callback', 'DTFunctions(''DT.dataClear'')', 'string', 'Clear Points', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
set(findall(DT.dataPanel, '-property', 'enable'), 'enable', 'off')

%%% Set up Navigation Area
nav                         = uipanel('units', 'pixels','Position', [Border Border MaWid NavHt], 'visible', 'on', 'tag', 'DT.navPanel', 'BackgroundColor', lightGrey, 'ShadowColor','w','HighlightColor',lightGrey,'ForegroundColor','k', 'Title', 'Navigation','FontName',fn,'fontsize',fs+2);
yb                          = 10;
bw                          = 25;
xr                          = Border + MaWid - 3*Buffer - 4*bw;
DT.navSW                    = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr      yb    bw bw],  'visible', 'on', 'tag', 'DT.navSW',   'callback', 'DTFunctions(''DT.navSW'')', 'string', 'SW', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
DT.navS                     = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+bw   yb    bw bw],  'visible', 'on', 'tag', 'DT.navS',    'callback', 'DTFunctions(''DT.navS'')',  'string', 'S', 'BackgroundColor',  lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
DT.navSE                    = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+2*bw yb    bw bw],  'visible', 'on', 'tag', 'DT.navSE',   'callback', 'DTFunctions(''DT.navSE'')', 'string', 'SE', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
DT.navW                     = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr      yb+bw   bw bw],  'visible', 'on', 'tag', 'DT.navW',    'callback', 'DTFunctions(''DT.navW'')',  'string', 'E', 'BackgroundColor',  lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
DT.navE                     = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+2*bw yb+bw   bw bw],  'visible', 'on', 'tag', 'DT.navE',    'callback', 'DTFunctions(''DT.navE'')',  'string', 'W', 'BackgroundColor',  lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
DT.navNW                    = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr      yb+2*bw bw bw],  'visible', 'on', 'tag', 'DT.navNW',   'callback', 'DTFunctions(''DT.navNW'')', 'string', 'NW', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
DT.navN                     = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+bw   yb+2*bw bw bw],  'visible', 'on', 'tag', 'DT.navN',    'callback', 'DTFunctions(''DT.navN'')',  'string', 'N', 'BackgroundColor',  lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
DT.navNE                    = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+2*bw yb+2*bw bw bw],  'visible', 'on', 'tag', 'DT.navNE',   'callback', 'DTFunctions(''DT.navNE'')', 'string', 'NE', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

DT.savePush                 = uicontrol('parent', nav, 'style', 'pushbutton', 'Position', [330   yb PbWid PbHt],  'visible', 'off', 'tag', 'DT.savePush',  'callback', 'DTFunctions(''DT.saveOut'')', 'string', 'Save Output', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
DT.plotSave                 = uicontrol('parent', nav, 'style', 'pushbutton', 'Position', [330 yb+bw PbWid PbHt],  'visible', 'off', 'tag', 'DT.savePlot',  'callback', 'DTFunctions(''DT.savePlot'')', 'string', 'Save Plot', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);

% longitude and latitude ranges
bl                      = 80;
tl                      = 30;
tw                      = 18;
el                      = bl-tl;
% DT.navEditLonMax        = uicontrol('parent', nav, 'style', 'edit',       'position', [10       yb+2*bw el bw],  'visible', 'on', 'tag', 'DT.navEditLonMax', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
% DT.navTextLonMax        = uicontrol('parent', nav, 'style', 'text',       'position', [10+el      yb+2*bw tl tw],  'visible', 'on', 'tag', 'DT.navTextLonMax', 'string', 'Lon+', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
% DT.navEditLonMin        = uicontrol('parent', nav, 'style', 'edit',       'position', [10      yb+bw   el bw],  'visible', 'on', 'tag', 'DT.navEditLonMin', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
% DT.navTextLonMin        = uicontrol('parent', nav, 'style', 'text',       'position', [10+el      yb+bw   tl tw],  'visible', 'on', 'tag', 'DT.navTextLonMin', 'string', 'Lon-', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
% DT.navEditLatMax        = uicontrol('parent', nav, 'style', 'edit',       'position', [10+bl      yb+2*bw el bw],  'visible', 'on', 'tag', 'DT.navEditLatMax', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
% DT.navTextLatMax        = uicontrol('parent', nav, 'style', 'text',       'position', [10+bl+el   yb+2*bw tl tw], 'visible', 'on', 'tag', 'DT.navTextLatMax', 'string', 'Lat+', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
% DT.navEditLatMin        = uicontrol('parent', nav, 'style', 'edit',       'position', [10+bl      yb+bw   el bw],  'visible', 'on', 'tag', 'DT.navEditLatMin', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
% DT.navTextLatMin        = uicontrol('parent', nav, 'style', 'text',       'position', [10+bl+el   yb+bw   tl tw], 'visible', 'on', 'tag', 'DT.navTextLatMin', 'string', 'Lat-', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
% DT.navUpdate            = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [10+2*bl    yb+2*bw bl bw], 'visible', 'on', 'tag', 'DT.navUpdate', 'callback', 'DTFunctions(''DT.navUpdate'')','string', 'Update', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
DT.navBack              = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [10+2*bl    yb+bw   bl bw], 'visible', 'on', 'tag', 'DT.navBack',   'callback', 'DTFunctions(''DT.navBack'')','string', 'Back',   'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

% Zoom options
DT.navZoomIn            = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [10+0    yb bl bw],    'visible', 'on', 'tag', 'DT.navZoomIn', 'callback', 'DTFunctions(''DT.navZoomIn'')','string', 'Zoom In', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
DT.navZoomOut           = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [10+bl   yb bl bw],    'visible', 'on', 'tag', 'DT.navZoomOut', 'callback', 'DTFunctions(''DT.navZoomOut'')','string', 'Zoom Out', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
DT.navZoomRange         = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [10+2*bl yb bl bw],    'visible', 'on', 'tag', 'DT.navZoomRange', 'callback', 'DTFunctions(''DT.navZoomRange'')', 'string', 'Zoom Range', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Finalize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Create handles structure for easy use in the callback later
cla(DT.mapAx);
Handles.DT = DT;
set(hFig, 'userdata', Handles);
set(gca, 'Fontname', fn, 'FontSize', fs)

% Make all figure components normalized so that they auto-resize on figure resize
set(findall(hFig,'-property','Units'),'Units','norm');

% Making the GUI visible and give it a name
set(hFig, 'visible', 'on', 'name', 'Historical Geodesy 1','HandleVisibility','on');
set(hFig, 'DoubleBuffer', 'on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% plotmap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% axes(DT.mapAx);
% h = imshow('./Images/ApproachestoSeattle_1940.jpg');