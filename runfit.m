% [qi, qf] is the fitting range, and should be subset of [min_Q, max_Q]
%
% lb is the lower bound of RMS value, set a positive large value would
% damp the function at high-Q. Set 0 would give lsqcurvefit function full control.
%
% acu is the termination tolerance on the function value, a positive
% scalar. -4 will be converted to 10e-4 when calling optimization routine
%
% Initial RMS value is randomly sampled from Gaussian. For the least-square-fitting
% algorithm, it's very likely that the fitting result is local minimum, not
% global minimum. So the choice of initial rms value determine which local
% minumum area you are looking at. Based on Narten's paper and other
% references, it's reasonable to initialize rms around 0.05 with small
% deviation. So mean = 0.5, std = 0.2 would make sure that all initialized
% rms is around this number.

function [x,resnorm,residual,q,ffit,intra,x0,norm_sofq] = runfit(qi, qf, acu, mean, std, path_coord, path_sq, ffpath, sname)
clear x; clear resnorm; clear residual; tic;
lmt = 15;   %max atom atom distance r will be used for lsqfit
%%
fid1 = fopen(path_coord,'r');
%load atoms coordinatfion
global atom_type 
a = textscan(fid1,'%s %s %f %f %f');
s = a{1};
t = char(a{1});
if size(t,2) == 1
    for i=1:size(t,1)
        if length(s{i}) == 1
            s(i) = strcat(s(i), {blanks(1)});
        end
    end
    atom_type = char(s);
elseif size(t,2) == 2
    atom_type = t;
end
fclose(fid1);
pos = [a{3},a{4},a{5}];

global dim
dim = size(pos,1);
pos = pos';

%%%%%%%%%%%%%%%%%%%
global atomff_index
fid2 = fopen(ffpath,'r');
ff = textscan(fid2,'%s %f %f %f %f %f %f %f %f %f %f %f');
atomff_index = char(ff{1});
fclose(fid2);
global formf
formf = [ff{2:12}];
clear a ff s t;
%%%%%%%%%%%%%%%%%%%

%calculate atom-atom distance r, declare r as global to pass it to member
%funtions
%variable size r, should not be a problem for small dim. For extremely large
%dim, there is possible memory leak/overflow. For that case, pre-allocate r.
global r pinfo1 pinfo2
k = 1;
for i = 1:(dim-1)
    for j = (i+1):dim
        temp = sqrt((pos(1,i)-pos(1,j))^2+(pos(2,i)-pos(2,j))^2+(pos(3,i)-pos(3,j))^2);
        if temp < lmt                   %set limit on allowed atom-atom pair, large vaule
            k = k + 1;
        end
    end
end

r = zeros(k-1,1);
k = 1;
for i = 1:(dim-1)
    for j = (i+1):dim
        temp = sqrt((pos(1,i)-pos(1,j))^2+(pos(2,i)-pos(2,j))^2+(pos(3,i)-pos(3,j))^2);
        if temp < lmt                   %set limit on allowed atom-atom pair, large vaule
            r(k) = temp;      %to include all pairs, small value to keep nearest neighbour pairs
            k = k + 1;
        end
    end
end
pinfo1 = char(zeros(length(r), 2));
pinfo2 = char(zeros(length(r), 2));
k = 1;
for i = 1:(dim-1)
    for j = (i+1):dim
        temp = sqrt((pos(1,i)-pos(1,j))^2+(pos(2,i)-pos(2,j))^2+(pos(3,i)-pos(3,j))^2);
        if temp < lmt 
            pinfo1(k,:) = atom_type(i,:);
            pinfo2(k,:) = atom_type(j,:);
            k = k + 1;
        end
    end
end
%input information
atom_type = atom_type';
atomff_index = atomff_index';
pinfo1 = pinfo1';
pinfo2 = pinfo2';
formf = formf';

disp(sprintf('Fitting range:\t\t\t [%d, %d]', qi, qf));
disp(sprintf('rms population:\t\t\t %d', length(r)));
disp(sprintf('Fitting accuracy:\t\t 10e%d', acu));
disp(sprintf('\nrms initialization parameter (Random Gaussian Distribution)\n Mean:\t\t\t %g\n Std:\t\t\t %g', mean, std));

%%
%calculate normalized and interpolated SofQ data by calling normsq(drug_name) function
global dq
dq = 0.005;
norm_sofq = normsq(path_sq);
minq = min(norm_sofq(:,1));
maxq = max(norm_sofq(:,1));
for i = 1:size(norm_sofq,1)
    if norm_sofq(i,1) == qi
        idxi = i;
    elseif norm_sofq(i,1) == qf
        idxf = i;
    end
end
fit_range = norm_sofq(idxi:idxf, :);
%script, call fitting function to fit on select Q range
[x,x0,resnorm,residual] = lsqfit(fit_range, acu, mean, std);

%%
q = minq:dq:maxq;
q = q';
ffit = sqfactor(x,q);
ffit = q.*ffit;
%%
disp(sprintf('x(end-1) and X(end):\t\t %g  %g', x(end-1), x(end)));

intra = norm_sofq(:,2) - ffit;
rslt = [q, norm_sofq(:,2), ffit, intra];
outname = 'SQ.txt';
outname = strcat(datestr(now, '_HHMM_'), outname);
outname = strcat(sname, outname);
dlmwrite(outname, rslt, 'delimiter', '\t', 'precision', 4);

figure
plot(q, ffit, norm_sofq(:,1),norm_sofq(:,2),'-r');
legend('Fitted Intra-Struct-Factor F(Q)', 'Normalized Experimental SofQ')
axis([0 23 -2.5 4]);
figure
plot(q, intra)
title('Q\times(S(Q) - F(Q)) Intermolecule structure factor')
axis([0 23 -2.5 4]);

filename = 'RMS_stat.txt';
filename = strcat(datestr(now, '_HHMM_'), filename);
filename = strcat(sname, filename);
fid = fopen(filename,'w');
pinfo1 = pinfo1';
pinfo2 = pinfo2';
fprintf(fid, 'atom1\tatom2\tr\trms\n');
for i = 1:length(r)
    if r(i) <= lmt
    fprintf(fid,'%s\t%s\t%4.2f\t%4.3f\n', pinfo1(i), pinfo2(i), r(i), abs(x(i)));
    end
end
fclose(fid);
toc;
end
