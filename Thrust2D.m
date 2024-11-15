%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    11/13/2019 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   GUI for making 2D Thrust models
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function Thrust2D
close all; clear all;

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

DataColumns = {'x','H_obs','V_obs','H_mod','V_mod'}; % distance, horizontal motion, vertical motion
GeoColumns = {'x1','z1','x2','z2'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Visualization variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

white                       = [1 1 1];
lightGrey                   = 0.9 * [1 1 1];
fn                          = 'Helvetica';
fs                          = 14;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Open Figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

screensize                  = get(0, 'screensize');
figloc                      = screensize(3:4)./6;
figw                        = 2*screensize(3)/3;
figh                        = 2*screensize(4)/3;
figpos                      = [figloc figw figh];
fSize                       = [figpos(3) figpos(4) figpos(3) figpos(4)];
hFig                        = figure('Position', figpos, 'Color', lightGrey, 'menubar', 'figure', 'toolbar', 'figure');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Set Display Constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% keyboard

LRBorder                    = figw/40; % border width (right and left at least)
TBBorder                    = figh/40; % border width (right and left at least)
hBuffer                     = figw/100;
vBuffer                     = figh/100;
PbWid                       = 3*LRBorder; % push-button width (pixels)
PbHt                        = 2*TBBorder; % push-button height (pixels)
FigWid                      = (figw-2*LRBorder-hBuffer)*3/5; % Figure Area Width (pixels)
InfoWid                     = (figw)*2/5; % Info Area Width
hMid                        = (figh)*1/2;
vMid                        = (figw)*1/2;
DataFigHt                   = figh/3;
SegFigHt                    = figh/3;
CaxHt                       = 40+34;
NavHt                       = 110;
DataHt                      = 210;
ModelHt                     = 430;
By                          = 425; % Button height
% pbw                         = PbWid/pSize(1);
% pbh                         = PbHt/pSize(2);

% keyboard
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%% Set up Figure Panels (Top figure shows data/forward model; bottom figure shows fault geometry)
T2D.DataFig                  = axes('parent', hFig, 'units', 'pixels', 'position', [LRBorder+2*hBuffer hMid+2*TBBorder FigWid-hBuffer DataFigHt], 'visible', 'on', 'Tag', 'T2D.DataFig', 'Layer', 'top', 'xlim', [-200 200], 'ylim', [-90 90], 'FontName', fn);
T2D.DataFig.XLabel.String = 'x';
T2D.DataFig.YLabel.String = 'velocity';

T2D.SegFig                   = axes('parent', hFig, 'units', 'pixels', 'position', [LRBorder+2*hBuffer hMid-SegFigHt-TBBorder FigWid-hBuffer SegFigHt], 'visible', 'on', 'Tag', 'T2D.SegFig', 'Layer', 'top', 'xlim', [-200 200], 'ylim', [-90 10], 'FontName', fn);
T2D.SegFig.XLabel.String = 'x';
T2D.SegFig.YLabel.String = 'z (positive up)';

%%% Data Panel
cw                          = InfoWid/7;
T2D.dataPanel               = uipanel('units', 'pixels', 'position', [figw-InfoWid+LRBorder hMid+2*TBBorder InfoWid-2*LRBorder-hBuffer DataFigHt+10*vBuffer], 'visible', 'on', 'tag',  'T2D.dataPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k', 'Title', 'Data Stuff','fontsize',fs+2,'ShadowColor',lightGrey,'HighlightColor','w');
% size things
P                           = get(T2D.dataPanel,'Position');
pSize                       = [P(3:4) P(3:4)];
pbw                         = PbWid/pSize(1);
pbh                         = PbHt/pSize(2);
% data controls
T2D.datatext                = uicontrol('parent',T2D.dataPanel,'style','text','Position', pSize.*[0.020 1-1.8*pbh 4*(cw/pSize(1)) (pbh)],'visible', 'on', 'tag', 'T2D.dataEnter', 'string','Observations','BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2,'HorizontalAlignment','left');
T2D.dataList                = uitable('parent', T2D.dataPanel,'ColumnName', DataColumns, 'ColumnWidth', {cw cw cw cw cw}, 'Data',cell(1,5), 'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'},'ColumnEditable',logical([1 1 1 0 0]),'RowName', [],'Position', pSize.*[0.020 0.02+2*pbh 5*(cw/pSize(1))+0.006 (1-3.8*pbh)], 'visible', 'on', 'tag', 'T2D.dataList', 'BackgroundColor', white, 'FontName', fn, 'FontSize', fs, 'ForegroundColor', 'k');
T2D.dataEnter               = uicontrol('parent', T2D.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.02+pbh pbw pbh], 'visible', 'on', 'tag', 'T2D.dataEnter', 'callback', 'T2DFunctions(''T2D.dataEnter'')', 'string', 'Enter', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2);
T2D.dataLoad                = uicontrol('parent', T2D.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+pbw 0.02+pbh pbw pbh], 'visible', 'on', 'tag', 'T2D.dataLoad', 'callback', 'T2DFunctions(''T2D.dataLoad'')', 'string', 'Load', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2);
T2D.dataSave                = uicontrol('parent', T2D.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+2*pbw 0.02+pbh pbw pbh], 'visible', 'on', 'tag', 'T2D.dataSave', 'callback', 'T2DFunctions(''T2D.dataSave'')', 'string', 'Save', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2);
T2D.dataClear               = uicontrol('parent', T2D.dataPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+3*pbw 0.02+pbh pbw pbh], 'visible', 'on', 'tag', 'T2D.dataClear', 'callback', 'T2DFunctions(''T2D.dataClear'')', 'string', 'Clear', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2);

%%% Model Panel
cw                          = InfoWid/7;
T2D.geoPanel                = uipanel('units', 'pixels', 'position', [figw-InfoWid+LRBorder LRBorder InfoWid-2*LRBorder-hBuffer SegFigHt+12*vBuffer], 'visible', 'on', 'tag',  'T2D.geoPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k', 'Title', 'Model Stuff','fontsize',fs+2,'ShadowColor',lightGrey,'HighlightColor','w');
% size things
P                           = get(T2D.geoPanel,'Position');
pSize                       = [P(3:4) P(3:4)];
pbw                         = PbWid/pSize(1);
pbh                         = PbHt/pSize(2);
% model controls
T2D.geoFtext                = uicontrol('parent',T2D.geoPanel,'style','text','Position', pSize.*[0.020 1-1.8*pbh 4.2*(cw/pSize(1)) (pbh)],'visible', 'on', 'tag', 'T2D.geoEnter', 'string','Fault Segments','BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2,'HorizontalAlignment','left');
T2D.geoStext                = uicontrol('parent',T2D.geoPanel,'style','text','Position', pSize.*[5*(cw/pSize(1))-0.04 1-1.8*pbh 4.2*(cw/pSize(1)) (pbh)],'visible', 'on', 'tag', 'T2D.geoEnter', 'string','Slip (positive thrust)','BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2,'HorizontalAlignment','left');
T2D.geoFList                = uitable('parent', T2D.geoPanel,'ColumnName', GeoColumns, 'ColumnWidth', {cw cw cw cw}, 'Data',cell(1,4),'ColumnFormat',{'numeric','numeric','numeric','numeric'},'ColumnEditable',true,'RowName', [],'Position', pSize.*[0.020 0.02+2*pbh 4*(cw/pSize(1))+0.005 (1-3.8*pbh)], 'visible', 'on', 'tag', 'T2D.geoList', 'BackgroundColor', white, 'FontName', fn, 'FontSize', fs, 'ForegroundColor', 'k');
T2D.geoSList                = uitable('parent', T2D.geoPanel,'ColumnName', {'s'}, 'ColumnWidth', {cw}, 'Data',cell(1,1), 'ColumnFormat',{'numeric'},'ColumnEditable',true,'RowName', [],'Position', pSize.*[5*(cw/pSize(1))-0.04 0.02+2*pbh (cw/pSize(1))+0.006 (1-3.8*pbh)], 'visible', 'on', 'tag', 'T2D.geoList', 'BackgroundColor', white, 'FontName', fn, 'FontSize', fs, 'ForegroundColor', 'k');
T2D.geoEnter                = uicontrol('parent', T2D.geoPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.02+pbh pbw pbh], 'visible', 'on', 'tag', 'T2D.geoEnter', 'callback', 'T2DFunctions(''T2D.geoEnter'')', 'string', 'Enter', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2);
T2D.geoLoad                 = uicontrol('parent', T2D.geoPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+pbw 0.02+pbh pbw pbh], 'visible', 'on', 'tag', 'T2D.geoLoad', 'callback', 'T2DFunctions(''T2D.geoLoad'')', 'string', 'Load', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2);
T2D.geoSave                 = uicontrol('parent', T2D.geoPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+2*pbw 0.02+pbh pbw pbh], 'visible', 'on', 'tag', 'T2D.geoSave', 'callback', 'T2DFunctions(''T2D.geoSave'')', 'string', 'Save', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2);
T2D.geoClear                = uicontrol('parent', T2D.geoPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+3*pbw 0.02+pbh pbw pbh], 'visible', 'on', 'tag', 'T2D.geoClear', 'callback', 'T2DFunctions(''T2D.geoClear'')', 'string', 'Clear', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2);

T2D.geoForward              = uicontrol('parent', T2D.geoPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02 0.00 pbw pbh], 'visible', 'on', 'tag', 'T2D.geoForward', 'callback', 'T2DFunctions(''T2D.geoForward'')', 'string', 'Forward', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2);
T2D.geoInverse              = uicontrol('parent', T2D.geoPanel, 'style', 'pushbutton', 'Position', pSize.*[0.02+pbw 0.00 pbw pbh], 'enable','off','visible', 'on', 'tag', 'T2D.geoInverse', 'callback', 'T2DFunctions(''T2D.geoInverse'')', 'string', 'Inverse', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs-2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Finalize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Create handles structure for easy use in the callback later
cla(T2D.DataFig);
Handles.T2D = T2D;
set(hFig, 'userdata', Handles);
set(gca, 'Fontname', fn, 'FontSize', fs)


%%% Initialize figures
axes(T2D.SegFig)
xl = get(gca,'xlim');
hold on; plot(xl,[0 0],'-','Color',0.5*[0 1 0])
axes(T2D.DataFig)
xl = get(gca,'xlim');
hold on; plot(xl,[0 0],'--','Color',0.5*[1 1 1])

% Make all figure components normalized so that they auto-resize on figure resize
set(findall(hFig,'-property','Units'),'Units','norm');

% Making the GUI visible and give it a name
set(hFig, 'visible', 'on', 'name', 'Thrust2D','HandleVisibility','on');
set(hFig, 'DoubleBuffer', 'on');

