%load experimental SofQ data from file
function [sofq] = readsq(path)
    fid = fopen(path, 'r');
    sofq = fscanf(fid, '%g', [2, inf]);
    fclose(fid);
    xdata = sofq(1,:);
    ydata = sofq(2,:);
    sofq = [xdata', ydata'];
end
