%load experimental SofQ data and normalize/postprocessing it for
%least-square fitting
function [sofq] = normsq(path)
    global dq
    fid = fopen(path, 'r');
    sofq = fscanf(fid, '%g', [2, inf]);
    fclose(fid);
    xdata = sofq(1,:);
    ydata = sofq(2,:);
    maxq = max(xdata);
    minq = min(xdata);
    minq = round(minq*10)/10;   %round to first decimal place
    q = minq:dq:maxq;
    % 1-D interpolation with spline method
    y0 = interp1(xdata, ydata, q, 'spline');
    sofq = [q', y0'];
end
