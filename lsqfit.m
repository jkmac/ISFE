function [x,x0,resnorm,residual] = lsqfit(sq, lbt, acu, mean, std)
	%prepare data for optimization, y'=y/x, redefine y for computation
	xdata = sq(:,1);
	ydata = sq(:,2)./xdata;
	%define optimization parameters
	global r
% 	if lbt == 0aaaaa
% 	    lb = [];
% 	else
% 	    lb = lbt*ones(length(r)+2,1);
% 	end
	ub = cat(1,abs(r), [inf;inf]);
    lb = -ub;
	options = optimset('TolFun',10^acu,'MaxFunEvals',150000);
	%random initialization of rms (x0)
	x0 = random('Normal', mean, std, length(r)+2, 1);
	%call the routine
    x0(end-1) = 1;
    x0(end) = 0;
    flag=glcheck(x0, xdata);
	[x,resnorm,residual] = lsqcurvefit(@myfit1, x0, xdata, ydata, lb, ub, options);
end