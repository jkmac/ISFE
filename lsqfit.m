function [x,x0,resnorm,residual] = lsqfit(sq, acu, mean, std)
	%prepare data for optimization, y'=y/x, redefine y for computation
	xdata = sq(:,1);
	ydata = sq(:,2)./xdata;
	%define optimization parameters
	global r
    max_shift = 100;	%max Y-shift
    high_lb = 80;		%max Y-height, may change according to your data
    low_lb = 20;		%min Y-height, may change according to your data
	ub = cat(1,abs(r), [high_lb;max_shift]);
    lb = 0.05*ones(size(ub));	%low bound on x parameter, rms >= 0.05
    lb(end) = -max_shift;
    lb(end-1) = low_lb;
	options = optimset('TolFun',10^acu,'MaxFunEvals',200000);
	%random initialization of rms (x0)
	x0 = abs(random('Normal', mean, std, length(r)+2, 1));
	%call the routine
    x0(end-1) = 50;	%initial Y-height, correct exp data Y-variation in intensity
    x0(end) = 0;	%initial Y shift, correct exp data Y-deviation from y=0
    flag=glcheck(x0, xdata);
	[x,resnorm,residual] = lsqcurvefit(@sqfactor, x0, xdata, ydata, lb, ub, options);
end
