%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    6/11/2018 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%%%%%%%%%%%
% Export Table         %
%%%%%%%%%%%%%%%%%%%%%%%%
function ExportTable(data,filename)

    sz = size(data);
    nfields = sz(2); %% 4 if control, 3 if data
    nrows = sz(1);

    fid = fopen(filename,'w');
    switch nfields
        case 3
            fprintf(fid,'%s\t%s\t%s\n','X (Pixel)','Y (Pixel)','Value (Data)');
            for row = 1:nrows
                fprintf(fid,'%f\t%f\t%f\n',data{row,1},data{row,2},data{row,3});
            end
        case 5
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','X (Pixel)','Y (Pixel)','Lon (Control)','Lat (Control)','Name');
            for row = 1:nrows
                fprintf(fid,'%f\t%f\t%f\t%f\t%s\n',data{row,1},data{row,2},data{row,3},data{row,4},data{row,5});
            end
        otherwise
            return
    end
    fclose(fid);
    
end
