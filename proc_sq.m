%process data and return the interpolated data in range [qi,qf]
%garrantee that data population exceeds parameter space size
%Therefore trust-region algorithm is garranteed in use
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
