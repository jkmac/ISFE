%load experimental SofQ data and normalize/postprocessing it for
%least-square fitting
function [Iq_range] = proc_sq(SQ)

    global data_pop
    xdata = SQ(:,1)'; %xdata row vector
    ydata = SQ(:,2)';
    maxq = max(xdata);
    minq = min(xdata);
    dq = (maxq-minq)/data_pop;
    q = minq:dq:maxq;
    % 1-D interpolation with spline method
    y0 = interp1(xdata, ydata, q, 'spline');
    Iq_range = [q', y0']; %colum vector, Nx2 dimension
end
