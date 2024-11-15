function [idx, Data] = MoveScPoint(Data)
% Graphically move an intersection

    ud = get(gcf,'UserData');
    DT = ud.DT;
    title(DT.mapAx, 'Select and drag a point', 'FontSize',12);

    %% Dynamically highlight fault endpoints
    set(gcf, 'WindowButtonDownFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    hMarker = findobj(DT.mapAx, 'Tag','SelectedPoint');
    if isempty(hMarker)
        hMarker = plot(DT.mapAx, 0,0,'or', 'Tag','SelectedBlock','MarkerSize',12);
    end
    while ~getappdata(gcf, 'doneClick')
        cp = get(DT.mapAx, 'CurrentPoint');
        x = cp(1,1); y = cp(1,2);
        d2 = (Data(:,1) - x).^2 + (Data(:,2) - y).^2;
        [minDVal, minDIdx] = min(d2); %#ok<ASGLU>
        set(hMarker, 'xdata',Data(minDIdx,1), 'ydata',Data(minDIdx,2));
        drawnow; pause(0.02);
    end
    set(gcf, 'WindowButtonDownFcn', '');
    idx = minDIdx;
%     keyboard
    %% Move the lines till the next click
    set(gcf, 'WindowButtonUpFcn', 'ButtonDown');
    done = 0;
    setappdata(gcf, 'doneClick', done);
    while ~done
        done = getappdata(gcf, 'doneClick');
        cp = get(DT.mapAx, 'CurrentPoint');
        x = cp(1,1); y = cp(1,2);
%         set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', npi2pi(x), x, y));
        set(hMarker, 'xData',x, 'yData',y);
        drawnow;
    end
    set(gcf, 'WindowButtonUpFcn', '');
    title(DT.mapAx, '');
    
    
%     keyboard
    %% Update and move positions of old interior point
    Data(idx,1) = x;
    Data(idx,2) = y;
    
    %set(findobj('Tag', strcat('Block.', num2str(minDIdx))), 'xData',Block.interiorLon(minDIdx), 'yData',Block.interiorLat(minDIdx));
    delete(hMarker);
    drawnow;