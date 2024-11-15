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

function T2DFunctions(option) 

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
T2D = ud.T2D;

if isdeployed
%     fprintf(sprintf('%s\n',ctfroot));
    direc = fullfile(ctfroot);
else
    direc = '.';
end
% [T2D.X,Control.Y,Control.Lon,Control.Lat] = deal([]);
% [Data.X,Data.Y,Data.D] = deal([]);
% setappdata(gcf, 'Control', Control);
% setappdata(gcf, 'Data', Data);

axes(T2D.SegFig)
%%% Make this a "plot surface" function
xl = get(gca,'xlim');
hold on; plot(xl,[0 0],'-','Color',0.5*[0 1 0])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Parse callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

switch(option)
    
    case 'T2D.loadMap'
        %%% First, identify map file
        filenameFull = GetMapName(T2D.Mapfile);
        if isempty(filenameFull),  return;  end
        
        %%% Display the Map File
        axes(T2D.mapAx);
        h = imshow(filenameFull);
        impixelinfo(h);
        
        %%% Enable Data Panels
        set(findall(T2D.contPanel, '-property', 'enable'), 'enable', 'on');
        set(findall(T2D.dataPanel, '-property', 'enable'), 'enable', 'on');
        
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
        
    case 'T2D.clearMap'
        %%% First, clear map file
        set(T2D.Mapfile, 'string', '');
        
        %%% Clear the Map File
        cla(T2D.mapAx);
        
        %%% Enable Data Panels
        set(findall(T2D.contPanel, '-property', 'enable'), 'enable', 'off');
        set(findall(T2D.dataPanel, '-property', 'enable'), 'enable', 'off');
        set([T2D.dataExp T2D.contExp],'enable','on');
        
        %%% Refresh axis info
        xlim = get(gca,'XLim');
        ylim = get(gca,'Ylim');
        [Range.x, Range.xLim] = deal(xlim);
        [Range.y, Range.yLim] = deal(ylim);
        Range.xOld = repmat(Range.x,ul,1);
        Range.yOld = repmat(Range.y,ul,1);
        
        %%% clear control data
        T2D.contList.Data = [];        
        axes(T2D.mapAx)
        hold on; 
        h = findobj(gca,'Type','Line','Marker','v');
        delete(h);
        
        %%% clear control data
        T2D.dataList.Data = [];        
        axes(T2D.mapAx)
        hold on; 
        h = findobj(gca,'Type','Scatter');
        delete(h);
       
        
        %%% Pass
        SetAxes(Range);
        Handles.DT = DT;
        setappdata(gcf, 'Range', Range);
        set(gcf, 'userdata', Handles);
        
    case 'T2D.contSel'
        axes(T2D.mapAx)
        while get(T2D.contSel,'Value')
            
            set(T2D.contSel,'string','Stop Adding');
            
            
            Value = PixelSelect('Control');
%             keyboard
            
            T2D.contList.Data = [T2D.contList.Data; Value];
            
            
            if ~isempty(T2D.contList.Data)
                
                hold on;
                h = findobj(gca,'Type','Line','Marker','v');
                delete(h);
                plot(cell2mat(T2D.contList.Data(:,1)), cell2mat(T2D.contList.Data(:,2)),'vk','MarkerFaceColor','k');
            end
        end
        set(T2D.contSel,'string','Add');
        set(gcf,'pointer','arrow');
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
        
    case 'T2D.contLoad'    
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
        
        T2D.contList.Data = [T2D.contList.Data; [num2cell([T{1} T{2} T{3} T{4}]) T{5}] ];
        
        axes(T2D.mapAx)
        hold on; 
        h = findobj(gca,'Type','Line','Marker','v');
        delete(h);
        plot(cell2mat(T2D.contList.Data(:,1)), cell2mat(T2D.contList.Data(:,2)),'vk','MarkerFaceColor','k');
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
        
    case 'T2D.contExp'    
        [filename, pathname] = uiputfile({'Control.txt'});
        filename = fullfile(pathname,filename);
        ExportTable(T2D.contList.Data,filename);
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.contMove'
        
        DD = cell2mat(T2D.contList.Data(:,1:2));
%         keyboard
        [idx,DD] = MovePoint(DD);
%         keyboard
        T2D.contList.Data(:,1:2) = num2cell(DD);
%         keyboard
%         set(T2D.contList,'Data',Data);
        
        axes(T2D.mapAx)
        hold on; 
        h = findobj(gca,'Type','Line','Marker','v');
        delete(h);
        plot(cell2mat(T2D.contList.Data(:,1)), cell2mat(T2D.contList.Data(:,2)),'vk','MarkerFaceColor','k');
        
%         keyboard
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.contClear'
        %%% Text - this will delete the entered points. Is this what you
        %%% want to do?
        
         T2D.contList.Data = [];
        
%         keyboard
        
        axes(T2D.mapAx)
        hold on; 
        h = findobj(gca,'Type','Line','Marker','v');
        delete(h);
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.contDel'
        %%% Text - this will delete the selected point. Is this what you
        %%% want to do?
%         keyboard
        DD = cell2mat(T2D.contList.Data(:,1:2));
        [idx,DD] = MovePoint(DD);
        T2D.contList.Data(idx,:) = [];
%         set(T2D.contList,'Data',Data);
        
        axes(T2D.mapAx)
        hold on; 
        h = findobj(gca,'Type','Line','Marker','v');
        delete(h);
        plot(cell2mat(T2D.contList.Data(:,1)), cell2mat(T2D.contList.Data(:,2)),'vk','MarkerFaceColor','k');
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.dataSel'
        
        while get(T2D.dataSel,'Value')
            
            set(T2D.dataSel,'string','Stop Adding');
            Value = PixelSelect('Data');
            
            T2D.dataList.Data = [T2D.dataList.Data; Value];
            
%             keyboard
            sx = cell2mat(T2D.dataList.Data(:,1));
            sy = cell2mat(T2D.dataList.Data(:,2));
            sd = cell2mat(T2D.dataList.Data(:,3));
            
            if ~isempty(T2D.dataList.Data)
                axes(T2D.mapAx)
                hold on;
                h = findobj(gca,'Type','Scatter');
                delete(h);
                h = findobj(gca,'Type','Line','Marker','o');
                delete(h);
                scatter(sx,sy,[],sd,'filled','MarkerEdgeColor','none');
                axes(T2D.cAxis)
                if numel(sd) < 2
                    caxis([0 1]);
                    set([T2D.ch],'Limits',[0 1],'UserData',sd);
                else
                    caxis([0 max(sd)]);
                    set([T2D.ch],'Limits',[0, max(sd)],'UserData',sd);
                end
                set(T2D.ch,'visible','on');
            end
        end
        set(T2D.dataSel,'string','Add');
        set(gcf,'pointer','arrow');
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);

    case 'T2D.geoLoad'
        [filename, pathname] = uigetfile({'*.txt;*.csv','Text Files'},'Select Existing Geometry File','.');
        filename = fullfile(pathname,filename);
        if isempty(filename) 
            return;  
        end
        
        fid = fopen(filename);
        T = textscan(fid,'%f %f %f %f','Delimiter','\t','Headerlines',1);
        fclose(fid);
       
        T2D.geoList.Data = [T2D.geoList.Data; num2cell([T{1} T{2} T{3} T{4}])];
        
        sx1 = cell2mat(T2D.geoList.Data(:,1));
        sz1 = cell2mat(T2D.geoList.Data(:,2));
        sx2 = cell2mat(T2D.geoList.Data(:,3));
        sz2 = cell2mat(T2D.geoList.Data(:,4));
        
%         keyboard
        
        axes(T2D.SegFig)
        hold on;
        h = findobj(gca,'Type','Line');
        delete(h);
        for ss = 1:numel(sx1)
            plot([sx1(ss) sx2(ss)],[sz1(ss) sz2(ss)],'.-k','LineWidth',2)
        end
        set(findall(T2D.geoPanel, '-property', 'enable'), 'enable', 'on');
        % recenter
        set(gca,'xlim',[min([sx1; sx2]) max([sx1; sx2])]);
        set(gca,'ylim',[min([sz1; sz2]) 10]);
        
        
        hold on; plot([min([sx1; sx2]) max([sx1; sx2])],[0 0],'-','Color',0.5*[0 1 0]);
        
        
        
%         keyboard
%         axes(T2D.mapAx)
%         hold on; 
%         h = findobj(gca,'Type','Scatter');
%         delete(h);
%         scatter(sx,sy,20,sd,'filled','MarkerEdgeColor','none');
%         axes(T2D.cAxis)
%         if numel(sd) < 2
%             caxis([0 1]);
%             set([T2D.ch],'Limits',[0 1],'UserData',sd);
%         else
%             caxis([0 max(sd)]);
%             set([T2D.ch],'Limits',[0, max(sd)],'UserData',sd);
%         end
%         set(T2D.ch,'visible','on');
%         
%         %%% Pass
        Handles.T2D = T2D;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.dataExp'
%         keyboard
        [filename, pathname] = uiputfile({'Data.txt'});
%         filename = fullfile(direc,pathname,filename);
        filename = fullfile(pathname,filename);
        ExportTable(T2D.dataList.Data,filename);
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.dataMove'
        DD = cell2mat(T2D.dataList.Data(:,1:2));
        [idx,DD] = MoveScPoint(DD);
        T2D.dataList.Data(:,1:2) = num2cell(DD);
%         set(T2D.dataList,'Data',Data);
        sx = cell2mat(T2D.dataList.Data(:,1));
        sy = cell2mat(T2D.dataList.Data(:,2));
        sd = cell2mat(T2D.dataList.Data(:,3));

        axes(T2D.mapAx)
        hold on; 
        h = findobj(gca,'Type','Scatter');
        delete(h);
        scatter(sx,sy,20,sd,'filled','MarkerEdgeColor','none');
        axes(T2D.cAxis)
        if numel(T2D.dataList.Data(:,3)) < 2
            caxis([0 1]);
            set([T2D.ch],'Limits',[0 1],'UserData',sd);
        else
            caxis([0 max(T2D.dataList.Data(:,3))]);
            set([T2D.ch],'Limits',[0, max(sc)],'UserData',sd);
        end
        set(T2D.ch,'visible','on');
        
%         keyboard
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.dataDel'
        %%% Text - this will delete the selected point. Is this what you
        %%% want to do?
        DD = cell2mat(T2D.dataList.Data(:,1:2));
        [idx,DD] = MoveScPoint(DD);
        T2D.dataList.Data(idx,:) = [];
        
        sx = cell2mat(T2D.dataList.Data(:,1));
        sy = cell2mat(T2D.dataList.Data(:,2));
        sd = cell2mat(T2D.dataList.Data(:,3));
        
        axes(T2D.mapAx)
        hold on; 
        h = findobj(gca,'Type','Scatter');
        delete(h);
        scatter(sx,sy,20,sd,'filled','MarkerEdgeColor','none');
        axes(T2D.cAxis)
        if numel(T2D.dataList.Data(:,3)) < 2
            caxis([0 1]);
            set([T2D.ch],'Limits',[0 1],'UserData',sd);
        else
            caxis([0 max(T2D.dataList.Data(:,3))]);
            set([T2D.ch],'Limits',[0, max(sd)],'UserData',sd);
        end
        set(T2D.ch,'visible','on');
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.dataClear'
        %%% Text - this will delete the selected point. Is this what you
        %%% want to do?
        
         T2D.dataList.Data = [];
        
        axes(T2D.mapAx)
        hold on; 
        h = findobj(gca,'Type','Scatter');
        delete(h);
        set(T2D.ch,'visible','off');
        
        %%% Pass
        Handles.DT = DT;
        set(gcf, 'userdata', Handles);
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  Navigation callbacks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'T2D.navBack'
        axes(T2D.mapAx)
        Range = getappdata(gcf, 'Range');
        RangeLev = max([1 cul]);
        Range.x = Range.xOld(RangeLev, :);
        Range.y = Range.yOld(RangeLev, :);
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        cul = max([1 RangeLev - 1]);
        SetAxes(Range);
        
    case 'T2D.navZoomRange'
        axes(T2D.mapAx)
        Range = GetRangeRbbox(getappdata(gcf, 'Range'));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        Range = getappdata(gcf, 'Range');
        Range.xOld = [Range.xOld(st:cul+1, 1:2) ; Range.x];
        Range.yOld = [Range.yOld(st:cul+1, 1:2) ; Range.y];
        cul = min([size(Range.xOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        
    case 'T2D.navZoomIn'
        axes(T2D.mapAx)
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
        
    case 'T2D.navZoomOut'
        axes(T2D.mapAx)
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
        
    case 'T2D.navSW'
        axes(T2D.mapAx)
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
        
    case 'T2D.navS'
        axes(T2D.mapAx)
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
        
    case 'T2D.navSE'
        axes(T2D.mapAx)
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
        
    case 'T2D.navW'
        axes(T2D.mapAx)
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
        
    case 'T2D.navE'
        axes(T2D.mapAx)
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
        
    case 'T2D.navNW'
        axes(T2D.mapAx)
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
        
    case 'T2D.navN'
        axes(T2D.mapAx)
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
        
    case 'T2D.navNE'
        axes(T2D.mapAx)
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
                thistoggle = T2D.contSel;
            case 'Data'
                thistoggle = T2D.dataSel;
        end

    PointerStyle = {'arrow','crosshair'};

    set(gcf, 'WindowButtonDownFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    
    while 1
        while ~getappdata(gcf,'doneClick')
            cp = get(T2D.mapAx, 'CurrentPoint');
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
                if get(T2D.contSel,'Value')
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
                if get(T2D.dataSel,'Value')
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