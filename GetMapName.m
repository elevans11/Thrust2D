function filenameFull = GetMapName(hEditbox)
% GetFilename
%
%    filenameFull = GetFilename(hEditbox)
%
% This function gets a user-specified filename
%
% Inputs:
%   hEditbox : Handle of the GUI editbox that holds the filename
%
% Outputs:
%   filenameFull : full filename path of the user-selected file
%     keyboard
    filename = get(hEditbox, 'string');
%     defaultdir = '.';
    if exist(filename, 'file')
        filenameFull = which(filename);  %=fullfile(pwd, filename);
        if isempty(filenameFull)
            filenameFull = filename;
        end
    else
%         keyboard
        [filename, pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files - not vector'},'Select Map File','.');
        
        if filename == 0
            set(hEditbox, 'string', '');
            filenameFull = '';
            return;
        else
            filenameFull = fullfile(pathname, filename);
            set(hEditbox, 'string', filenameFull);  % filename);
        end
    end
end
