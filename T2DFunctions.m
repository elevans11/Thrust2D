%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    11/18/2019 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Initial surface plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


switch(option)
    
    case 'T2D.dataEnter'
        X = cell2mat(T2D.dataList.Data(:,1));
        U1 = cell2mat(T2D.dataList.Data(:,2));
        U2 = cell2mat(T2D.dataList.Data(:,3));
        
        if isempty(X)
            msgbox('Enter data first')
        else
            PlotData(X,U1,U2)
        end
        
        if ~isempty(T2D.dataList.Data{end,1})
            T2D.dataList.Data = [T2D.dataList.Data; cell(1,5)]; % adds new row to enter more
        end
        
        %%% Pass
        Handles.T2D = T2D;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.dataLoad'
        [filename, pathname] = uigetfile({'*.txt;*.csv','Text Files'},'Select Existing Geometry File','.');
        filename = fullfile(pathname,filename);
        if isempty(filename) 
            return;  
        end
        
        % Check to see how many headerlines, and how many columns are in the file
        fid = fopen(filename,'r');
        temp = fgetl(fid);
        nhead = 0;
        while strcmp(temp(1),'#')
            nhead = nhead+1;
            temp = fgetl(fid);
        end
        % how many columns?
        T = textscan(temp,'%f','Delimiter',' \t,;:','MultipleDelimsAsOne',1);
        nc = numel(T{1});
        fclose(fid);
        
        fid = fopen(filename,'r');
        if nc == 3
            T = textscan(fid,'%f %f %f','Delimiter',' \t,;:','Headerlines',nhead,'MultipleDelimsAsOne',1);
        else
            ErrorMessage;
        end
        fclose(fid);
        
        T2D.dataList.Data = [num2cell([T{1} T{2} T{3}]) cell(numel(T{1}),1) cell(numel(T{1}),1); cell(1,5)];
        
        X = cell2mat(T2D.dataList.Data(:,1));
        U1 = cell2mat(T2D.dataList.Data(:,2));
        U2 = cell2mat(T2D.dataList.Data(:,3));
        
        %%% Need a PlotDataFunction
        PlotData(X,U1,U2)
        
        %%% Pass
        Handles.T2D = T2D;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.dataSave'
        [filename, pathname] = uiputfile({'Data.txt'});
        filename = fullfile(pathname,filename);
        TableToSave = [T2D.dataList.Data];
        ExportTable(TableToSave,filename,'data');
        
        %%% Pass
        Handles.T2D = T2D;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.dataClear'
        T2D.dataList.Data = cell(1,3);
        
        axes(T2D.DataFig)
        h = findobj(gca,'Type','Line');
        delete(h);
        xl = get(gca,'xlim');
        hold on; plot(xl,[0 0],'--','Color',0.5*[1 1 1])
        legend('off');
        
        %%% Pass
        Handles.T2D = T2D;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.geoEnter'
        sx1 = cell2mat(T2D.geoFList.Data(:,1));
        sz1 = cell2mat(T2D.geoFList.Data(:,2));
        sx2 = cell2mat(T2D.geoFList.Data(:,3));
        sz2 = cell2mat(T2D.geoFList.Data(:,4));
        
        slip = cell2mat(T2D.geoSList.Data(:,1));
        
        if isempty(sx1)
            msgbox('Enter data first')
            return
        end
        
        %%% Deal with far-field
        % Find the deepest endpoint
        [Fmin1, Fmin1id] = min(sz1);
        [Fmin2, Fmin2id] = min(sz2);
        % which segment does it belong to?
        [~, mid] = min([Fmin1 Fmin2]);
        if mid == 1
            thisseg = Fmin1id;
            newsx1 = sx1(thisseg);
            newsz1 = sz1(thisseg);
        elseif mid == 2
            thisseg = Fmin2id;
            newsx1 = sx2(thisseg);
            newsz1 = sz2(thisseg);
        else 
            ErrorMessage;
        end
        
        dip             = -atan2((sz2(thisseg)-sz1(thisseg)),(sx2(thisseg)-sx1(thisseg)));
        
        % extend deepest segment
        dl = 3000;
        newsx2 = newsx1 + dl*cos(dip);
        newsz2 = newsz1 - dl*sin(dip);
        
%         keyboard
        
        % we want there to be one empty row at the end of the table
        if ~isempty(T2D.geoFList.Data{end,1})
            T2D.geoFList.Data = [T2D.geoFList.Data; cell(1,4)]; % adds new row to enter more
            
        end
        if ~isempty(T2D.geoSList.Data{end,1})
            T2D.geoSList.Data = [T2D.geoSList.Data; cell(1,1)];
%             slip(thisseg) = NaN;

        end
        if isempty(slip)
            T2D.deepSegment = [newsx1 newsz1 newsx2 newsz2];
        else
            T2D.deepSegment = [newsx1 newsz1 newsx2 newsz2 slip(thisseg)];
        end

        PlotModel(sx1,sz1,sx2,sz2,slip)
        
        %%% Pass
        Handles.T2D = T2D;
        set(gcf, 'userdata', Handles);
        
        
    case 'T2D.geoLoad'
        [filename, pathname] = uigetfile({'*.txt;*.csv','Text Files'},'Select Existing Geometry File','.');
        filename = fullfile(pathname,filename);
        if isempty(filename) 
            return;  
        end
        
        % Check to see how many headerlines, and how many columns are in the file
        fid = fopen(filename,'r');
        temp = fgetl(fid);
        nhead = 0;
        while strcmp(temp(1),'#')
            nhead = nhead+1;
            temp = fgetl(fid);
        end
        % how many columns?
        T = textscan(temp,'%f','Delimiter',' \t,;:','MultipleDelimsAsOne',1);
        nc = numel(T{1});
        fclose(fid);
        
        fid = fopen(filename,'r');
        if nc == 4
            T = textscan(fid,'%f %f %f %f','Delimiter',' \t,;:','Headerlines',nhead,'MultipleDelimsAsOne',1);
        elseif nc == 5
            T = textscan(fid,'%f %f %f %f %f','Delimiter',' \t,;:','Headerlines',nhead,'MultipleDelimsAsOne',1);
        end
        fclose(fid);
        
        T2D.geoFList.Data = [num2cell([T{1} T{2} T{3} T{4}]); cell(1,4)];
        
        sx1 = cell2mat(T2D.geoFList.Data(:,1));
        sz1 = cell2mat(T2D.geoFList.Data(:,2));
        sx2 = cell2mat(T2D.geoFList.Data(:,3));
        sz2 = cell2mat(T2D.geoFList.Data(:,4));
        
        %%% Deal with far-field
        % Find the deepest endpoint
        [Fmin1, Fmin1id] = min(sz1);
        [Fmin2, Fmin2id] = min(sz2);
        % which segment does it belong to?
        [~, mid] = min([Fmin1 Fmin2]);
        if mid == 1
            thisseg = Fmin1id;
            newsx1 = sx1(thisseg);
            newsz1 = sz1(thisseg);
        elseif mid == 2
            thisseg = Fmin2id;
            newsx1 = sx2(thisseg);
            newsz1 = sz2(thisseg);
        else 
            ErrorMessage;
        end
        
        dip             = -atan2((sz2(thisseg)-sz1(thisseg)),(sx2(thisseg)-sx1(thisseg)));
        
        % extend deepest segment
        dl = 3000;
        newsx2 = newsx1 + dl*cos(dip);
        newsz2 = newsz1 - dl*sin(dip);

        if nc == 5
            slip = cell2mat(num2cell([T{5}]));
            T2D.geoSList.Data = [num2cell([T{5}]); cell(1,1)];
            T2D.deepSegment = [newsx1 newsz1 newsx2 newsz2 slip(thisseg)];
        else
            slip = cell2mat(cell(numel(sx1),1));
            T2D.geoSList.Data = [cell(numel(sx1),1); cell(1,1)];
            T2D.deepSegment = [newsx1 newsz1 newsx2 newsz2 NaN];
        end
        
%         keyboard
        
        PlotModel(sx1,sz1,sx2,sz2,slip)
        %%% Pass
        Handles.T2D = T2D;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.geoSave'
        if ~isempty(T2D.geoFList.Data{1})
            if ~isempty(T2D.geoSList.Data{1})
                [filename, pathname] = uiputfile({'GeometryAndSlip.txt'});
                filename = fullfile(pathname,filename);
                TableToSave = [T2D.geoFList.Data T2D.geoSList.Data];
                ExportTable(TableToSave,filename,'geo');
            else
                [filename, pathname] = uiputfile({'Geometry.txt'});
                filename = fullfile(pathname,filename);
                TableToSave = T2D.geoFList.Data;
                ExportTable(TableToSave,filename,'geo');
            end
        else
            msgbox('Enter data first')
        end
        
        %%% Pass
        Handles.T2D = T2D;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.geoClear'
        T2D.geoFList.Data = cell(1,4);
        T2D.geoSList.Data = cell(1,1);
        
        axes(T2D.SegFig)
        h = findobj(gca,'Type','Line');
        delete(h);
        xl = get(gca,'xlim');
        hold on; plot(xl,[0 0],'-','Color',0.5*[0 1 0])
        
        %%% Pass
        Handles.T2D = T2D;
        set(gcf, 'userdata', Handles);
        
    case 'T2D.geoForward'
        if isempty(T2D.geoFList.Data{1})
            msgbox('Enter fault geometry to run Forward Model')
            return
        end
        if isempty(T2D.geoSList.Data{1})
            msgbox('Enter slip parameter to run Forward Model')
            return
        end
        
        %%% General Forward Model
        axes(T2D.SegFig)
        xl = get(gca,'xlim');
        x0 = linspace(xl(1),xl(2),1000)';
        z0 = zeros(size(x0));

        sx1 = [cell2mat(T2D.geoFList.Data(:,1)); T2D.deepSegment(1)];
        sz1 = [cell2mat(T2D.geoFList.Data(:,2)); T2D.deepSegment(2)];
        sx2 = [cell2mat(T2D.geoFList.Data(:,3)); T2D.deepSegment(3)];
        sz2 = [cell2mat(T2D.geoFList.Data(:,4)); T2D.deepSegment(4)];
        s = [cell2mat(T2D.geoSList.Data); T2D.deepSegment(5)];

        u1 = zeros(numel(x0),numel(sx1));
        u2 = zeros(numel(x0),numel(sx1));

        for ii = 1:numel(sx1)
            [u01, u02] = Thrust2DPartials(x0,z0,s(ii),sx1(ii),sz1(ii),sx2(ii),sz2(ii),0);
            u1(:,ii) = -u01;
            u2(:,ii) = -u02;
        end
        U1 = sum(u1,2);
        U2 = sum(u2,2);

        axes(T2D.DataFig)
%         keyboard
        
        PlotDataForward(x0,U1,U2);
        
        
        %%% Forward Model at Specific locations
        XD = cell2mat(T2D.dataList.Data(:,1));
        U1D = cell2mat(T2D.dataList.Data(:,2));
        U2D = cell2mat(T2D.dataList.Data(:,3));
        if ~isempty(XD) % there are observation locations entered
            u1 = zeros(numel(XD),numel(sx1));
            u2 = zeros(numel(XD),numel(sx1));
            for ii = 1:numel(sx1)
                [u01, u02] = Thrust2DPartials(XD,zeros(size(XD)),s(ii),sx1(ii),sz1(ii),sx2(ii),sz2(ii),0);
                u1(:,ii) = -u01;
                u2(:,ii) = -u02;
            end
            U1F = sum(u1,2);
            U2F = sum(u2,2);
            
            T2D.dataList.Data(1:end-1,4) = num2cell(U1F);
            T2D.dataList.Data(1:end-1,5) = num2cell(U2F);
%              keyboard   
             
            PlotDataForward_Obs(XD,U1F,U2F);
%             if isempty(U1F) && isempty(U2F) % but no observations
%                 
%                 
%                 ForwardFlag = [1 1];
%                 PlotData(X,U1,U2,ForwardFlag)
%             elseif isempty(U1F) && ~isempty(U2F)
%                 
%             elseif ~isempty(U1F) && isempty(U2F)
%             end
        end
        
        
        
        %%% Pass
        Handles.T2D = T2D;
        set(gcf, 'userdata', Handles);

    
    case 'T2D.geoInverse'
        keyboard
        if isempty(T2D.geoFList.Data{1})
            msgbox('Enter fault geometry to run Inverse Model')
            return
        end
        if ~isempty(T2D.geoSList.Data{1})
            msgbox('Inverse model will overwrite slip values')
            return
        end
        if isempty(T2D.dataList.Data{1})
            msgbox('Enter observations to run Inverse Model')
            return
        end
        
        X = cell2mat(T2D.dataList.Data(:,1));
        U1 = cell2mat(T2D.dataList.Data(:,2));
        U2 = cell2mat(T2D.dataList.Data(:,3));
        U = [U1; U2];
        
        sx1 = [cell2mat(T2D.geoFList.Data(:,1)); T2D.deepSegment(1)];
        sz1 = [cell2mat(T2D.geoFList.Data(:,2)); T2D.deepSegment(2)];
        sx2 = [cell2mat(T2D.geoFList.Data(:,3)); T2D.deepSegment(3)];
        sz2 = [cell2mat(T2D.geoFList.Data(:,4)); T2D.deepSegment(4)];
        
        for ii = 1:numel(sx1)
            [u01, u02] = Thrust2DPartials(X,zeros(size(X)),1,sx1(ii),sz1(ii),sx2(ii),sz2(ii),0);
            u1(:,ii) = -u01;
            u2(:,ii) = -u02;
        end
        
%         G1 = sum(u1,2);
%         G2 = sum(u2,2);
        G = [u1; u2];
        
        if numel(U) >= numel(sx1)
            mest = (inv(G'*G))*G'*U;
        else
            mest = G'*(inv(G'*G))*d
        end
        
        
        
        %%% Pass
        Handles.T2D = T2D;
        set(gcf, 'userdata', Handles);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Other Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function PlotData(X,U1,U2)
    axes(T2D.DataFig)
    h = findobj(gca,'Type','Line','Tag','HorizontalData');
    delete(h);
    h = findobj(gca,'Type','Line','Tag','VerticalData');
    delete(h);
    
    hold on;
    ph = plot(X,U1,'ok','MarkerSize',10,'MarkerFaceColor','y','Tag','HorizontalData');
    pv = plot(X,U2,'ok','MarkerSize',10,'MarkerFaceColor','g','Tag','VerticalData');
%     legend([ph pv],'horizontal obs','vertical obs');
    
    yr = max([U1; U2]) - min([U1; U2]);
    ymn = min([U1; U2]) - (yr/2);
    ymx = max([U1; U2]) + (yr/2);

    set(gca,'ylim',[ymn ymx]);
    
    DataLegend
end

function PlotDataForward(x0,U1,U2)
    axes(T2D.DataFig)
%     keyboard
    h = findobj(gca,'Type','Line','Tag','VerticalAll');
        delete(h);
        h = findobj(gca,'Type','Line','Tag','HorizontalAll');
        delete(h);
        
        xl = get(gca,'xlim');
        hold on; plot(xl,[0 0],'--','Color',0.5*[1 1 1])
    hold on; 
    ho = plot(x0,U1,'-','Color','y','LineWidth',2,'Tag','HorizontalAll');
    vo = plot(x0,U2,'-','Color','g','LineWidth',2,'Tag','VerticalAll');
%     keyboard
    
%     legend([ho vo],'horizontal model','vertical model');

    yr = max([U1; U2]) - min([U1; U2]);
    ymn = min([U1; U2]) - (yr/2);
    ymx = max([U1; U2]) + (yr/2);

    set(gca,'ylim',[ymn ymx]);
    
    DataLegend
end

function PlotDataForward_Obs(x0,U1,U2)
    axes(T2D.DataFig)
%     keyboard
    h = findobj(gca,'Type','Line','Tag','VerticalMod');
    delete(h);
    h = findobj(gca,'Type','Line','Tag','HorizontalMod');
    delete(h);
        
        xl = get(gca,'xlim');
        hold on; plot(xl,[0 0],'--','Color',0.5*[1 1 1])
    hold on; 
    ph = plot(x0,U1,'o','MarkerSize',8,'MarkerFaceColor',0.7*[1 1 0],'Tag','HorizontalMod','MarkerEdgeColor',0.5*[1 1 1]);
    pv = plot(x0,U2,'o','MarkerSize',8,'MarkerFaceColor',0.7*[0 1 0],'Tag','VerticalMod','MarkerEdgeColor',0.5*[1 1 1]);
%     legend([ph pv],'horizontal prediction','vertical prediction');

%     yr = max([U1; U2]) - min([U1; U2]);
%     ymn = min([U1; U2]) - (yr/2);
%     ymx = max([U1; U2]) + (yr/2);
    
    yr = max(U2) - min(U2);
    ymn = min(U2) - (yr/2);
    ymx = max([U1; U2]) + (yr/2);

    set(gca,'ylim',[ymn ymx]);
    
    DataLegend
%     keyboard
end

function PlotModel(sx1,sz1,sx2,sz2,slip)
    axes(T2D.SegFig)
    hold on;
    h = findobj(gca,'Type','Line');
    delete(h);
    
    for ss = 1:numel(sx1)
        plot([sx1(ss) sx2(ss)],[sz1(ss) sz2(ss)],'.-k','MarkerSize',10,'LineWidth',2)
    end
    
    if ~isempty(slip) % color code by slip rate (do this later)
        cmax = max(slip);
        cmin = min(slip);
        for ss = 1:numel(sx1)
            plot([sx1(ss) sx2(ss)],[sz1(ss) sz2(ss)],'.-k','MarkerSize',10,'LineWidth',2)
        end
    end
    
    set(findall(T2D.geoPanel, '-property', 'enable'), 'enable', 'on');
    % recenter
    xrange = max([sx1; sx2]) - min([sx1; sx2]);
    xmin = min([sx1; sx2])-xrange;
    xmax = max([sx1; sx2])+xrange;
    
    yrange = min([sz1; sz2]);
    ymin = yrange + yrange/2;
    ymax = 10;
    
    set(gca,'xlim',[xmin xmax]);
    set(gca,'ylim',[ymin ymax]);
    
    hold on; plot([min([sx1; sx2]) max([sx1; sx2])],[0 0],'-','Color',0.5*[0 1 0]);
    axes(T2D.SegFig)
    %%% Make this a "plot surface" function
    xl = get(gca,'xlim');
    hold on; plot(xl,[0 0],'-','Color',0.5*[0 1 0])
%     keyboard
    if isfield(T2D, 'deepSegment')
        plot([T2D.deepSegment(1) T2D.deepSegment(3)], [T2D.deepSegment(2) T2D.deepSegment(4)],'--','Color',0.5*[1 1 1]);
    end
    
    axes(T2D.DataFig)
    set(gca,'xlim',[xmin xmax]);
    hold on; plot(xl,[0 0],'--','Color',0.5*[1 1 1])
    
    DataLegend
%     keyboard
    
end

function ExportTable(data,filename,tabletype)

    sz = size(data);
    nfields = sz(2); %% 3 if data, 4 if fault endpoints, 5 if faults + slip OR observations+model
    nrows = sz(1);

    fid = fopen(filename,'w');
    switch nfields
        case 3
            fprintf(fid,'# Data file\n');
            fprintf(fid,'# All rows that do not contain data need to start with ''#''!\n');
            fprintf(fid,'# %s\t%s\t%s\n','X (km)','Horizontal (mm or mm/yr)', 'Vertical (mm or mm/yr)');
            for row = 1:nrows
                fprintf(fid,'%f\t%f\t%f\n',data{row,1},data{row,2},data{row,3});
            end
        case 4
            fprintf(fid,'# Fault Geometry file\n');
            fprintf(fid,'# All rows that do not contain data need to start with ''#''!\n');
            fprintf(fid,'# z-values should be negative for depth\n');
            fprintf(fid,'# %s\t%s\t%s\t%s\n','x1 (km)','z1 (km)','x2 (km)','z2 (km)');
            for row = 1:nrows
                fprintf(fid,'%f\t%f\t%f\t%f\n',data{row,1},data{row,2},data{row,3},data{row,4});
            end
        case 5
            if strcmp(tabletype,'geo')
            fprintf(fid,'# Fault Geometry file; this one has slip rates in it\n');
            fprintf(fid,'# All rows that do not contain data need to start with ''#''!\n');
            fprintf(fid,'# z-values should be negative for depth\n');
            fprintf(fid,'# %s\t%s\t%s\t%s\t%s\n','x1 (km)','z1 (km)','x2 (km)','z2 (km)','s (mm or mm/yr)');
            for row = 1:nrows
                fprintf(fid,'%f\t%f\t%f\t%f\t%f\n',data{row,1},data{row,2},data{row,3},data{row,4},data{row,5});
            end
            elseif strcmp(tabletype,'data')
                fprintf(fid,'# Data file\n');
                fprintf(fid,'# All rows that do not contain data need to start with ''#''!\n');
                fprintf(fid,'# %s\t%s\t%s\n','X (km)','Horizontal (mm or mm/yr)', 'Vertical (mm or mm/yr)');
            for row = 1:nrows
                fprintf(fid,'%f\t%f\t%f\n',data{row,1},data{row,2},data{row,3});
            end
            end
        otherwise
            ErrorMessage
            return
    end
    fclose(fid);
    
end

function DataLegend
    
    Tags = {'HorizontalData','VerticalData','HorizontalAll','VerticalAll','HorizontalMod','VerticalMod'};
    Strings = {'horizontal obs.','vertical obs.','horizontal model','vertical model','horizontal pred.','vertical pred.'};
    
    legendentries = zeros(size(Tags));
    O = [];
    for tt = 1:numel(Tags)
        o = findobj(gca,'Tag',Tags{tt});
        
        if ~isempty(o)
            legendentries(tt) = 1;
            O{tt} = o;
        end
        
    end
    if ~isempty(O)
        legend([O{logical(legendentries)}],Strings(logical(legendentries)));
    end
end


function ErrorMessage
        msgbox('Hmm. Something went wrong. Ask Dr. Evans.')
end

end

