function [x,x0,fval] = lsqfit_gs(sq, acu, mean, std)
	%prepare data for optimization, y'=y/x, redefine y for computation
	xdata = sq(:,1);
	ydata = sq(:,2)./xdata;
	%define optimization parameters
	global r
    max_shift = 50;	%max Y-shift
    high_lb = 50;		%max Y-height, may change according to your data
    low_lb = 0;		%min Y-height, may change according to your data
	ub = cat(1,abs(r)/15, [high_lb;max_shift]);
    %ub = cat(1,0.2*ones(size(r)), [high_lb;max_shift]);
    lb = 0.04*ones(size(ub));	%low bound on x parameter, rms >= 0.05
    lb(end) = -max_shift;
    lb(end-1) = low_lb;
    
	%options = optimset('Algorithm', 'trust-region-reflective','TolFun',10^acu,'MaxFunEvals',200000, 'MaxIter', 800, 'Display', 'iter');
	%random initialization of rms (x0)
	x0 = abs(random('Normal', mean, std, length(r)+2, 1));
	%call the routine
    x0(end-1) = 10;	%initial Y-height, correct exp data Y-variation in intensity
    x0(end) = 0;	%initial Y shift, correct exp data Y-deviation from y=0
    flag=glcheck(x0, xdata);
    
    opts = optimoptions(@fmincon, 'Algorithm','interior-point','TolFun',10^acu);  % TR needs gradient and GradOgj='on'
    problem = createOptimProblem('fmincon', 'objective', @sqfactor, ...             %fmincon obj take x0 only, need to modify sqfactor
    'xdata', xdata, 'ydata', ydata, 'x0', x0, 'lb', lb, 'ub', ub, 'options', opts);
    gs = GlobalSearch('Display','iter','MaxTime',300,'TolFun',10^acu,...
    'StartPointsToRun', 'bounds');
    [x,fval] = run(gs,problem);
end
