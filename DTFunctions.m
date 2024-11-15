%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    3/29/2018 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   Describe purpose of script/function here. 
%                ( 3/29/2018 , 11:37:47 am ) 
% 
%   INPUT 
%       1. Input one here 
%       2. Input two here 
% 
%   OUTPUT 
%       1. Output one here 
% 
%   Outline 
%       1.  
%       2.  
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function DTFunctions(option) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Declare variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

global ul cul st
translateScale = 0.2;
% Color variables
white           = [1 1 1];
lightGrey       = 0.85 * [1 1 1];
fn              = 'Helvetica';
fs              = 12;
% Get the struct holding the uicontrols' direct handles (avoiding runtime findobj() calls)
ud = get(gcf,'UserData');
DT = ud.DT;

if isdeployed
%     fprintf(sprintf('%s\n',ctfroot));
    direc = fullfile(ctfroot);
else
    direc = '.';
end
% [DT.X,Control.Y,Control.Lon,Control.Lat] = deal([]);
% [Data.X,Data.Y,Data.D] = deal([]);
% setappdata(gcf, 'Control', Control);
% setappdata(gcf, 'Data', Data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Parse callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

switch(option)
    
    case 'DT.loadMap'
        %%% First, identify map file
        filenameFull = GetMapName(DT.Mapfile);
        if isempty(filenameFull),  return;  end
        
        %%% Display the Map File
        axes(DT.mapAx);
        h = imshow(filenameFull);
        impixelinfo(h);
        
        %%% Enable Data Panels
        set(findall(DT.contPanel, '-property', 'enable'), 'enable', 'on');
        set(findall(DT.dataPanel, '-property', 'enable'), 'enable', 'on');
        
        %%% Get axis info
        xlim = get(gca,'XLim');
        ylim = get(gca,'Ylim');
        [Range.x, Range.xLim] = deal(xlim);
        [Range.y, Range.yLim] = deal(ylim);
        Range.xOld = repmat(Range.x,ul,1);
        Range.yOld = repmat(Range.y,ul,1);
        
        %%% Pass
        SetAxes(Range);
        Handles.DT = DT;
        setappdata(gcf, 'Range', Range);
        set(gcf, 'userdata', Handles);
        
    case 'DT.clearMap'
        %%% First, clear map file
        set(DT.Mapfile, 'string', '');
        
        %%% Clear the Map File
        cla(DT.mapAx);
        
        %%% Enable Data Panels
        set(findall(DT.contPanel, '-property', 'enable'), 'enable', 'off');
        set(findall(DT.dataPanel, '-property', 'enable'), 'enable', 'off');
        set([DT.dataExp DT.contExp],'enable','on');
        
        %%% Refresh axis info
        xlim = get(gca,'XLim');
        ylim = get(gca,'Ylim');
        [Range.x, Range.xLim] = deal(xlim);
        [Range.y, Range.yLim] = deal(ylim);
        Range.xOld = repmat(Range.x,ul,1);
        Range.yOld = repmat(Range.y,ul,1);
        
        %%% clear control data
        DT.contList.Data = [];        
        axes(DT.mapAx)
        hold on; 
        h = findobj(gca,'Type','Line','Marker','v');
        delete(h);
        
        %%% clear control data
        DT.dataList.Data = [];        
        axes(DT.mapAx)
        hold on; 
        h = findobj(gca,'Type','Scatter');
        delete(h);
       
        
        %%% Pass
        SetAxes(Range);
        Handles.DT = DT;
        setappdata(gcf, 'Range', Range);
        set(gcf, 'userdata', Handles);
        
    case 'DT.contSel'
        axes(DT.mapAx)
        while get(DT.contSel,'Value')
            
            set(DT.contSel,'string','Stop Adding');
            
            
            Value = PixelSelect('Control');
%             keyboard
            
            DT.contList.Data = [DT.contList.Data; Value];
            
            
            if ~isempty(DT.contList.Data)
                
                hold on;
                h = findobj(gca,'Type','Line','Marker','v');
                delete(h);
                plot(cell2mat(DT.contList.Data(:,1)), cell2mat(DT.contList.Data(:,2)),'vk','MarkerFaceColor','k');
            end
        end
        set(DT.contSel,'string','Add');
        set(gcf,'pointer','arrow');
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
        
    case 'DT.contLoad'    
        [filename, pathname] = uigetfile({'*.txt;*.csv','Text Files'},'Select Existing Control Points File','..');
        filename = fullfile(pathname,filename);
        if isempty(filename) 
            return;  
        end
        
        fid = fopen(filename);
        T = textscan(fid,'%f %f %f %f %s','Delimiter','\t','Headerlines',1);
        fclose(fid);
%         
%         keyboard
%         
%         temp = 
        
        DT.contList.Data = [DT.contList.Data; [num2cell([T{1} T{2} T{3} T{4}]) T{5}] ];
        
        axes(DT.mapAx)
        hold on; 
        h = findobj(gca,'Type','Line','Marker','v');
        delete(h);
        plot(cell2mat(DT.contList.Data(:,1)), cell2mat(DT.contList.Data(:,2)),'vk','MarkerFaceColor','k');
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
        
    case 'DT.contExp'    
        [filename, pathname] = uiputfile({'Control.txt'});
        filename = fullfile(pathname,filename);
        ExportTable(DT.contList.Data,filename);
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'DT.contMove'
        
        DD = cell2mat(DT.contList.Data(:,1:2));
%         keyboard
        [idx,DD] = MovePoint(DD);
%         keyboard
        DT.contList.Data(:,1:2) = num2cell(DD);
%         keyboard
%         set(DT.contList,'Data',Data);
        
        axes(DT.mapAx)
        hold on; 
        h = findobj(gca,'Type','Line','Marker','v');
        delete(h);
        plot(cell2mat(DT.contList.Data(:,1)), cell2mat(DT.contList.Data(:,2)),'vk','MarkerFaceColor','k');
        
%         keyboard
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'DT.contClear'
        %%% Text - this will delete the entered points. Is this what you
        %%% want to do?
        
         DT.contList.Data = [];
        
%         keyboard
        
        axes(DT.mapAx)
        hold on; 
        h = findobj(gca,'Type','Line','Marker','v');
        delete(h);
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'DT.contDel'
        %%% Text - this will delete the selected point. Is this what you
        %%% want to do?
%         keyboard
        DD = cell2mat(DT.contList.Data(:,1:2));
        [idx,DD] = MovePoint(DD);
        DT.contList.Data(idx,:) = [];
%         set(DT.contList,'Data',Data);
        
        axes(DT.mapAx)
        hold on; 
        h = findobj(gca,'Type','Line','Marker','v');
        delete(h);
        plot(cell2mat(DT.contList.Data(:,1)), cell2mat(DT.contList.Data(:,2)),'vk','MarkerFaceColor','k');
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'DT.dataSel'
        
        while get(DT.dataSel,'Value')
            
            set(DT.dataSel,'string','Stop Adding');
            Value = PixelSelect('Data');
            
            DT.dataList.Data = [DT.dataList.Data; Value];
            
%             keyboard
            sx = cell2mat(DT.dataList.Data(:,1));
            sy = cell2mat(DT.dataList.Data(:,2));
            sd = cell2mat(DT.dataList.Data(:,3));
            
            if ~isempty(DT.dataList.Data)
                axes(DT.mapAx)
                hold on;
                h = findobj(gca,'Type','Scatter');
                delete(h);
                h = findobj(gca,'Type','Line','Marker','o');
                delete(h);
                scatter(sx,sy,[],sd,'filled','MarkerEdgeColor','none');
                axes(DT.cAxis)
                if numel(sd) < 2
                    caxis([0 1]);
                    set([DT.ch],'Limits',[0 1],'UserData',sd);
                else
                    caxis([0 max(sd)]);
                    set([DT.ch],'Limits',[0, max(sd)],'UserData',sd);
                end
                set(DT.ch,'visible','on');
            end
        end
        set(DT.dataSel,'string','Add');
        set(gcf,'pointer','arrow');
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);

    case 'DT.dataLoad'
        [filename, pathname] = uigetfile({'*.txt;*.csv','Text Files'},'Select Existing Control Points File','..');
        filename = fullfile(pathname,filename);
        if isempty(filename) 
            return;  
        end
        
        fid = fopen(filename);
        T = textscan(fid,'%f %f %f','Delimiter','\t','Headerlines',1);
        fclose(fid);
       
        DT.dataList.Data = [DT.dataList.Data; num2cell([T{1} T{2} T{3}])];
        
        sx = cell2mat(DT.dataList.Data(:,1));
        sy = cell2mat(DT.dataList.Data(:,2));
        sd = cell2mat(DT.dataList.Data(:,3));
        
        axes(DT.mapAx)
        hold on; 
        h = findobj(gca,'Type','Scatter');
        delete(h);
        scatter(sx,sy,20,sd,'filled','MarkerEdgeColor','none');
        axes(DT.cAxis)
        if numel(sd) < 2
            caxis([0 1]);
            set([DT.ch],'Limits',[0 1],'UserData',sd);
        else
            caxis([0 max(sd)]);
            set([DT.ch],'Limits',[0, max(sd)],'UserData',sd);
        end
        set(DT.ch,'visible','on');
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'DT.dataExp'
%         keyboard
        [filename, pathname] = uiputfile({'Data.txt'});
%         filename = fullfile(direc,pathname,filename);
        filename = fullfile(pathname,filename);
        ExportTable(DT.dataList.Data,filename);
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'DT.dataMove'
        DD = cell2mat(DT.dataList.Data(:,1:2));
        [idx,DD] = MoveScPoint(DD);
        DT.dataList.Data(:,1:2) = num2cell(DD);
%         set(DT.dataList,'Data',Data);
        sx = cell2mat(DT.dataList.Data(:,1));
        sy = cell2mat(DT.dataList.Data(:,2));
        sd = cell2mat(DT.dataList.Data(:,3));

        axes(DT.mapAx)
        hold on; 
        h = findobj(gca,'Type','Scatter');
        delete(h);
        scatter(sx,sy,20,sd,'filled','MarkerEdgeColor','none');
        axes(DT.cAxis)
        if numel(DT.dataList.Data(:,3)) < 2
            caxis([0 1]);
            set([DT.ch],'Limits',[0 1],'UserData',sd);
        else
            caxis([0 max(DT.dataList.Data(:,3))]);
            set([DT.ch],'Limits',[0, max(sc)],'UserData',sd);
        end
        set(DT.ch,'visible','on');
        
%         keyboard
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'DT.dataDel'
        %%% Text - this will delete the selected point. Is this what you
        %%% want to do?
        DD = cell2mat(DT.dataList.Data(:,1:2));
        [idx,DD] = MoveScPoint(DD);
        DT.dataList.Data(idx,:) = [];
        
        sx = cell2mat(DT.dataList.Data(:,1));
        sy = cell2mat(DT.dataList.Data(:,2));
        sd = cell2mat(DT.dataList.Data(:,3));
        
        axes(DT.mapAx)
        hold on; 
        h = findobj(gca,'Type','Scatter');
        delete(h);
        scatter(sx,sy,20,sd,'filled','MarkerEdgeColor','none');
        axes(DT.cAxis)
        if numel(DT.dataList.Data(:,3)) < 2
            caxis([0 1]);
            set([DT.ch],'Limits',[0 1],'UserData',sd);
        else
            caxis([0 max(DT.dataList.Data(:,3))]);
            set([DT.ch],'Limits',[0, max(sd)],'UserData',sd);
        end
        set(DT.ch,'visible','on');
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'DT.dataClear'
        %%% Text - this will delete the selected point. Is this what you
        %%% want to do?
        
         DT.dataList.Data = [];
        
        axes(DT.mapAx)
        hold on; 
        h = findobj(gca,'Type','Scatter');
        delete(h);
        set(DT.ch,'visible','off');
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  Navigation callbacks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'DT.navBack'
        axes(DT.mapAx)
        Range = getappdata(gcf, 'Range');
        RangeLev = max([1 cul]);
        Range.x = Range.xOld(RangeLev, :);
        Range.y = Range.yOld(RangeLev, :);
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        cul = max([1 RangeLev - 1]);
        SetAxes(Range);
        
    case 'DT.navZoomRange'
        axes(DT.mapAx)
        Range = GetRangeRbbox(getappdata(gcf, 'Range'));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        Range = getappdata(gcf, 'Range');
        Range.xOld = [Range.xOld(st:cul+1, 1:2) ; Range.x];
        Range.yOld = [Range.yOld(st:cul+1, 1:2) ; Range.y];
        cul = min([size(Range.xOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        
    case 'DT.navZoomIn'
        axes(DT.mapAx)
        zoomFactor = 0.5;
        Range = getappdata(gcf, 'Range');
        deltaLon = (max(Range.x) - min(Range.x)) / 2;
        deltaLat = (max(Range.y) - min(Range.y)) / 2;
        centerLon = mean(Range.x);
        centerLat = mean(Range.y);
        Range.x = [centerLon - zoomFactor * deltaLon, centerLon + zoomFactor * deltaLon];
        Range.y = [centerLat - zoomFactor * deltaLat, centerLat + zoomFactor * deltaLat];
        Range = CheckRange(Range);
        Range.xOld = [Range.xOld(st:cul+1, 1:2) ; Range.x];
        Range.yOld = [Range.yOld(st:cul+1, 1:2) ; Range.y];
        cul = min([size(Range.xOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'DT.navZoomOut'
        axes(DT.mapAx)
        zoomFactor = 2.0;
        Range = getappdata(gcf, 'Range');
        deltaLon = (max(Range.x) - min(Range.x)) / 2;
        deltaLat = (max(Range.y) - min(Range.y)) / 2;
        centerLon = mean(Range.x);
        centerLat = mean(Range.y);
        Range.x = [centerLon - zoomFactor * deltaLon, centerLon + zoomFactor * deltaLon];
        Range.y = [centerLat - zoomFactor * deltaLat, centerLat + zoomFactor * deltaLat];
        Range = CheckRange(Range);
        Range.xOld = [Range.xOld(st:cul+1, 1:2) ; Range.x];
        Range.yOld = [Range.yOld(st:cul+1, 1:2) ; Range.y];
        cul = min([size(Range.xOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'DT.navSW'
        axes(DT.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.x) - min(Range.x);
        deltaLat = max(Range.y) - min(Range.y);
        Range.x = Range.x - translateScale * deltaLon;
        Range.y = Range.y + translateScale * deltaLat;
        Range = CheckRange(Range);
        Range.xOld = [Range.xOld(st:cul+1, 1:2) ; Range.x];
        Range.yOld = [Range.yOld(st:cul+1, 1:2) ; Range.y];
        cul = min([size(Range.xOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'DT.navS'
        axes(DT.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.x) - min(Range.x);
        deltaLat = max(Range.y) - min(Range.y);
        Range.x = Range.x;
        Range.y = Range.y + translateScale * deltaLat;
        Range = CheckRange(Range);
        Range.xOld = [Range.xOld(st:cul+1, 1:2) ; Range.x];
        Range.yOld = [Range.yOld(st:cul+1, 1:2) ; Range.y];
        cul = min([size(Range.xOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'DT.navSE'
        axes(DT.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.x) - min(Range.x);
        deltaLat = max(Range.y) - min(Range.y);
        Range.x = Range.x + translateScale * deltaLon;
        Range.y = Range.y + translateScale * deltaLat;
        Range = CheckRange(Range);
        Range.xOld = [Range.xOld(st:cul+1, 1:2) ; Range.x];
        Range.yOld = [Range.yOld(st:cul+1, 1:2) ; Range.y];
        cul = min([size(Range.xOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'DT.navW'
        axes(DT.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.x) - min(Range.x);
        deltaLat = max(Range.y) - min(Range.y);
        Range.x = Range.x - translateScale * deltaLon;
        Range.y = Range.y;
        Range = CheckRange(Range);
        Range.xOld = [Range.xOld(st:cul+1, 1:2) ; Range.x];
        Range.yOld = [Range.yOld(st:cul+1, 1:2) ; Range.y];
        cul = min([size(Range.xOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'DT.navE'
        axes(DT.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.x) - min(Range.x);
        deltaLat = max(Range.y) - min(Range.y);
        Range.x = Range.x + translateScale * deltaLon;
        Range.y = Range.y;
        Range = CheckRange(Range);
        Range.xOld = [Range.xOld(st:cul+1, 1:2) ; Range.x];
        Range.yOld = [Range.yOld(st:cul+1, 1:2) ; Range.y];
        cul = min([size(Range.xOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'DT.navNW'
        axes(DT.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.x) - min(Range.x);
        deltaLat = max(Range.y) - min(Range.y);
        Range.x = Range.x - translateScale * deltaLon;
        Range.y = Range.y - translateScale * deltaLat;
        Range = CheckRange(Range);
        Range.xOld = [Range.xOld(st:cul+1, 1:2) ; Range.x];
        Range.yOld = [Range.yOld(st:cul+1, 1:2) ; Range.y];
        cul = min([size(Range.xOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'DT.navN'
        axes(DT.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.x) - min(Range.x);
        deltaLat = max(Range.y) - min(Range.y);
        Range.x = Range.x;
        Range.y = Range.y - translateScale * deltaLat;
        Range = CheckRange(Range);
        Range.xOld = [Range.xOld(st:cul+1, 1:2) ; Range.x];
        Range.yOld = [Range.yOld(st:cul+1, 1:2) ; Range.y];
        cul = min([size(Range.xOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'DT.navNE'
        axes(DT.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.x) - min(Range.x);
        deltaLat = max(Range.y) - min(Range.y);
        Range.x = Range.x + translateScale * deltaLon;
        Range.y = Range.y - translateScale * deltaLat;
        Range = CheckRange(Range);
        Range.xOld = [Range.xOld(st:cul+1, 1:2) ; Range.x];
        Range.yOld = [Range.yOld(st:cul+1, 1:2) ; Range.y];
        cul = min([size(Range.xOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Set axis limits
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function SetAxes(Range)
    %%  SetAxes
    axis equal % disables 'stretch to fill'
    axis([min(Range.x) max(Range.x) min(Range.y) max(Range.y)]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Get range from drawn rubberband box %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Range = GetRangeRbbox(Range)
    % GetRangeRbbox
    k = waitforbuttonpress;
    point1 = get(gca, 'CurrentPoint');
    finalRect = rbbox;
    point2 = get(gca, 'CurrentPoint');
    point1 = point1(1,1:2);
    point2 = point2(1,1:2);
    Range.x = sort([point1(1) point2(1)]);
    Range.y = sort([point1(2) point2(2)]);
end

%%%%%%%%%%%%%%%%%%%%%%
% Check window range %
%%%%%%%%%%%%%%%%%%%%%%
function Range = CheckRange(Range)
    % CheckRange
    Range.x = sort(Range.x);
    Range.y = sort(Range.y);
    Range.x(Range.x > max(Range.xLim)) = max(Range.xLim);
    Range.x(Range.x < min(Range.xLim)) = min(Range.xLim);
    Range.y(Range.y > max(Range.yLim)) = max(Range.yLim);
    Range.y(Range.y < min(Range.yLim)) = min(Range.yLim);
end

%%%%%%%%%%%%%%%%%%%%%%%%
% Select Pixel         %
%%%%%%%%%%%%%%%%%%%%%%%%
    function Value = PixelSelect(option)
        Value = [];
        Range = getappdata(gcf, 'Range');
        switch option
            case 'Control'
                thistoggle = DT.contSel;
            case 'Data'
                thistoggle = DT.dataSel;
        end

    PointerStyle = {'arrow','crosshair'};

    set(gcf, 'WindowButtonDownFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    
    while 1
        while ~getappdata(gcf,'doneClick')
            cp = get(DT.mapAx, 'CurrentPoint');
            x = cp(1,1); y = cp(1,2);
            IN = double(inpolygon(x,y,[Range.x(1) Range.x(2) Range.x(2) Range.x(1) Range.x(1)],[Range.y(1) Range.y(1) Range.y(2) Range.y(2) Range.y(1)]));
            set(gcf,'pointer',PointerStyle{IN+1});
            drawnow; pause(0.02);
            if ~get(thistoggle,'Value')
                break
            end
        end
        if IN
            break
        else
            setappdata(gcf, 'doneClick', false);
        end
        
    end
    set(gcf, 'WindowButtonDownFcn', '');
    
    point = cp;

        
        switch(option)
            case 'Control'
                if get(DT.contSel,'Value')
                    hold on; plot(point(1,1), point(1,2),'vk');
                    prompt = {'Longitude: ', 'Latitude: ', 'Name: '};
                    dlt_title = 'Enter Control Point';
                    output = inputdlg(prompt,dlt_title);
%                     keyboard
                    if ~isempty(output)
%                         Value = [point(1,1) point(1,2) str2double(output{1}) str2double(output{2}) output(3)];
                        Value = {point(1,1) point(1,2) str2double(output{1}) str2double(output{2}) output{3}};
                    end
                end
            case 'Data'
                if get(DT.dataSel,'Value')
                    hold on; plot(point(1,1), point(1,2),'ok');
                    prompt = {'Value: '};
                    dlt_title = 'Enter Data';
                    output = inputdlg(prompt,dlt_title);
                    if ~isempty(output)
%                         Value = [point(1,1) point(1,2) str2double(output{1})];
                        Value = {point(1,1) point(1,2) str2double(output{1})};
                    end
                end
        end
%     end
        set(gcf,'pointer','arrow');
    end



%%% End Functions
end