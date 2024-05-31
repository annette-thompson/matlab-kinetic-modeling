%Script for manipulating model inputs easily
%All units are uM and sec.

%Specify initial conditions
%vector of initial conditions (units of uM)
init_cond = zeros(304,1);

init_cond(3) = 500;%s3 (Acetyl-CoA)
init_cond(4) = 10;%s6 (holo ACP)
init_cond(5) = 1000;%s7 (NADPH)
init_cond(6) = 1000;%s8 (NADH)
init_cond(8) = 500;%p2 (malonyl-CoA)



%Specify enzyme concentrations
%vector of enzyme concentrations (units of uM)
%ORDER: (ACC FabD FabH FabG FabZ FabI TesA FabF FabA FabB)
enz_conc = [0  1    1    1    1    1   10   1   1    1];



%Specify time range to solve system (seconds)
time_range = [0 720];


[palm_equiv,dist,unsat,time_vals,conc_vals] = Combined_Pathway_Solver_function(init_cond,enz_conc,time_range);
%   palm_equiv: vector of palmitic acid equivalents at each time point
%   in time vals.
%   dist: vector of the amount of fatty acid of each chain length at each
%   time point in time vals (labels below).
%   unsat: fraction of unsaturated fatty acid at each time point in time
%   vals.
%   time_vals: vector of time points in the numerical solution (seconds)
%   conc_vals: matrix of concentration values for all components of the system
%   at the time points in time vals (time_vals,component). Use the labels
%   below to identify the component.


%labels for distribution
dist_labels = {'4','6','8','10','12','12:1','14','14:1','16','16:1','18','18:1','20','20:1'};


%list of labels of species in conc_vals
%Label identity
%s: substrate (s1:ATP, s2:bicarbonate, s3:acetyl-CoA, s6:ACP, s7:NADH, s8:NADPH)
%p: product (p1:ADP, p2:malonyl-CoA, p3:CoA, p4:malonyl-ACP, p5:CO2)
%Q_# or Q_#_un: (beta-ketoacyl-ACP with acyl chain of given length, "un"
%indicates the acyl chain is usaturated)
%M_# or M_#_un: (beta-hydroxy-acyl-ACP with acyl chain of given length, "un"
%indicates the acyl chain is usaturated)
%R_# or R_#_un: (enoyl-acyl-ACP with acyl chain of given length, "un"
%indicates the acyl chain is usaturated)
%T_# or T_#_un: (acyl-ACP with acyl chain of given length, "un"
%indicates the acyl chain is usaturated)
%F_# or F_#_un: (free fatty acid with acyl chain of given length, "un"
%indicates the acyl chain is usaturated)
%Enzymes: enzymes are listed as follows
%e1:ACC, e2:FabD, e3:FabH, e4:FabG, e5:FabZ, e6:FabI, e7:TesA, e8:FabF,
%e9:FabA, e10:FabB

%Enzymes binding complexes: enzyme complexes are named with the
%concatenation of the labels of free components of the complex. For
%example the complex of FabD (e2) and substrate malonyl-CoA (p2) would be
%called "e2p2".

%Activated enzyme intermediates: For ping pong mechanism enzymes (FabD,
%FabH, FabF and FabB) the enzyme is modified with the attachment of an acyl
%chain, this modified form of the enzyme is denoated as enzyme name
%followed by "act". For example activated FabD would be called "e2act". In
%addition, for FabF and FabB, different lengths of acyl chains are attached
%to the enzyme, and the length attached is specified after the "act" label.
%For example FabF with an 8 carbon acyl chain attached would be called
%"e8act8". As an additional example if FabB has a 14 carbon acyl chain that
%is also unsaturated, this would be called "e10act14_un".

%The FabA isomerization reaction product, cis-3-decenoyl-ACP is labeled as
%"R_10_un"
labels = {'s1';'s2';'s3';'s6';'s7';'s8';'p1';'p2';'p3';'p4';'p5';...
'Q_4';'M_4';'R_4';'T_4';'F_4';'Q_6';'M_6';'R_6';'T_6';'F_6';...
'Q_8';'M_8';'R_8';'T_8';'F_8';'Q_10';'M_10';'R_10';'T_10';'F_10';'R_10_un';...
'Q_12';'M_12';'R_12';'T_12';'F_12';'Q_12_un';'M_12_un';'R_12_un';'T_12_un';'F_12_un';...
'Q_14';'M_14';'R_14';'T_14';'F_14';'Q_14_un';'M_14_un';'R_14_un';'T_14_un';'F_14_un';...
'Q_16';'M_16';'R_16';'T_16';'F_16';'Q_16_un';'M_16_un';'R_16_un';'T_16_un';'F_16_un';...
'Q_18';'M_18';'R_18';'T_18';'F_18';'Q_18_un';'M_18_un';'R_18_un';'T_18_un';'F_18_un';...
'Q_20';'M_20';'R_20';'T_20';'F_20';'Q_20_un';'M_20_un';'R_20_un';'T_20_un';'F_20_un';...
'e1s1';'e1s1s2';'e1act';'e1acts3';'e2p2';'e2act';'e2acts6';'e3s3';'e3act';'e3actp4';'e4s7';'e6s8';...
'e3T_4';'e3actT_4';'e4s7Q_4';'e5M_4';'e5R_4';'e6s8R_4';'e7T_4';'e8T_4';'e8act4';'e8act4p4';'e9M_4';'e9R_4';'e10T_4';'e10act4';'e10act4p4';...
'e3T_6';'e3actT_6';'e4s7Q_6';'e5M_6';'e5R_6';'e6s8R_6';'e7T_6';'e8T_6';'e8act6';'e8act6p4';'e9M_6';'e9R_6';'e10T_6';'e10act6';'e10act6p4';...
'e3T_8';'e3actT_8';'e4s7Q_8';'e5M_8';'e5R_8';'e6s8R_8';'e7T_8';'e8T_8';'e8act8';'e8act8p4';'e9M_8';'e9R_8';'e10T_8';'e10act8';'e10act8p4';...
'e3T_10';'e3actT_10';'e4s7Q_10';'e5M_10';'e5R_10';'e6s8R_10';'e7T_10';'e8T_10';'e8act10';'e8act10p4';'e9M_10';'e9R_10';'e10T_10';'e10act10';'e10act10p4';...
'e3T_12';'e3actT_12';'e4s7Q_12';'e5M_12';'e5R_12';'e6s8R_12';'e7T_12';'e8T_12';'e8act12';'e8act12p4';'e9M_12';'e9R_12';'e10T_12';'e10act12';'e10act12p4';...
'e3T_14';'e3actT_14';'e4s7Q_14';'e5M_14';'e5R_14';'e6s8R_14';'e7T_14';'e8T_14';'e8act14';'e8act14p4';'e9M_14';'e9R_14';'e10T_14';'e10act14';'e10act14p4';...
'e3T_16';'e3actT_16';'e4s7Q_16';'e5M_16';'e5R_16';'e6s8R_16';'e7T_16';'e8T_16';'e8act16';'e8act16p4';'e9M_16';'e9R_16';'e10T_16';'e10act16';'e10act16p4';...
'e3T_18';'e3actT_18';'e4s7Q_18';'e5M_18';'e5R_18';'e6s8R_18';'e7T_18';'e8T_18';'e8act18';'e8act18p4';'e9M_18';'e9R_18';'e10T_18';'e10act18';'e10act18p4';...
'e3T_20';'e3actT_20';'e4s7Q_20';'e5M_20';'e5R_20';'e6s8R_20';'e7T_20';'e9M_20';'e9R_20';...
'e3T_12_un';'e3actT_12_un';'e4s7Q_12_un';'e5M_12_un';'e5R_12_un';'e6s8R_12_un';'e7T_12_un';'e8T_12_un';'e8act12_un';'e8act12_unp4';'e9M_12_un';'e9R_12_un';'e10T_12_un';'e10act12_un';'e10act12_unp4';...
'e3T_14_un';'e3actT_14_un';'e4s7Q_14_un';'e5M_14_un';'e5R_14_un';'e6s8R_14_un';'e7T_14_un';'e8T_14_un';'e8act14_un';'e8act14_unp4';'e9M_14_un';'e9R_14_un';'e10T_14_un';'e10act14_un';'e10act14_unp4';...
'e3T_16_un';'e3actT_16_un';'e4s7Q_16_un';'e5M_16_un';'e5R_16_un';'e6s8R_16_un';'e7T_16_un';'e8T_16_un';'e8act16_un';'e8act16_unp4';'e9M_16_un';'e9R_16_un';'e10T_16_un';'e10act16_un';'e10act16_unp4';...
'e3T_18_un';'e3actT_18_un';'e4s7Q_18_un';'e5M_18_un';'e5R_18_un';'e6s8R_18_un';'e7T_18_un';'e8T_18_un';'e8act18_un';'e8act18_unp4';'e9M_18_un';'e9R_18_un';'e10T_18_un';'e10act18_un';'e10act18_unp4';...
'e3T_20_un';'e3actT_20_un';'e4s7Q_20_un';'e5M_20_un';'e5R_20_un';'e6s8R_20_un';'e7T_20_un';'e9M_20_un';'e9R_20_un';'e3s6';'e4s6';'e5s6';'e6s6';'e7s6';'e8s6';'e9s6';'e10s6';...
'e9R_10_un';'e10R_10_un';'e10act10_un';'e10act10_unp4';...
};

%Make sure you change time to be the right amount of minutes!

% % Recreating figure 2B 
% unsat_frac_1 = zeros(20);
% unsat_frac_10 = zeros(20);
% FabZ_conc = zeros(20);
% for i = 1:20
%     FabZ_conc(i) = (i-1)/4;
%     enz_conc(5) = (i-1)/4;
%     
%     %For reference with conc FabA = 1uM
%     enz_conc(9) = 1;
%     [~,~,unsat,~,~] = Combined_Pathway_Solver_function(init_cond,enz_conc,time_range);
%     unsat_frac_1(i) = unsat(end);
%     
% %     %For FabA conc = 10 uM
% %     enz_conc(9) = 10;
% %     [~,~,unsat,~,~] = Combined_Pathway_Solver_function(init_cond,enz_conc,time_range);
% %     unsat_frac_10(i) = unsat(end);
% end
% figure(1)
% hold on
% plot(FabZ_conc,unsat_frac_1,FabZ_conc,unsat_frac_10)
% xlabel('FabZ concentration (uM)')
% ylabel('unsaturated fraction')
% title('Figure 2B')
% legend({'FabAz conc = 1uM', 'FabAz conc = 10uM'})
% hold off



% Attempt at creating Fig S2C
figure(2)
hold on
plot(time_vals,palm_equiv)
% p = polyfit(time_vals(1:end)/60,palm_equiv(1:end),1);
% ref(1) = p(1);
ref(1) = palm_equiv(end)/time_range(end)*60;

rate = zeros(4,1);
enz_conc(3) = 32; %FabH to 32
[palm_equiv,~,~,time_vals,~] = Combined_Pathway_Solver_function(init_cond,enz_conc,time_range);
plot(time_vals,palm_equiv)
% p = polyfit(time_vals(1:end)/60,palm_equiv(1:end),1);
% rate(1) = p(1)/ref(1);
rate(1) = palm_equiv(end)/time_range(end)*60/ref(1);

time_range = [0 30];
enz_conc(3) = 1; %FabH back to 1
enz_conc(5) = 10; %FabZ to 10
enz_conc(7) = 30; %TesA to 30
enz_conc(6) = 10; %FabI to 10
[palm_equiv,~,~,time_vals,~] = Combined_Pathway_Solver_function(init_cond,enz_conc,time_range);
plot(time_vals,palm_equiv)
% p = polyfit(time_vals(1:end)/60,palm_equiv(1:end),1);
% ref(2) = p(1);
ref(2) = palm_equiv(end)/time_range(end)*60;

enz_conc(5) = 0; %FabZ to 0
enz_conc(9) = 10; %FabA to 10
[palm_equiv,~,~,time_vals,~] = Combined_Pathway_Solver_function(init_cond,enz_conc,time_range);
plot(time_vals,palm_equiv)
% p = polyfit(time_vals(1:end)/60,palm_equiv(1:end),1);
% rate(2) = p(1)/ref(2);
rate(2) = palm_equiv(end)/time_range(end)*60/ref(2);

enz_conc(5) = 10; %FabZ back to 10
enz_conc(9) = 1; %FabA back to 1
enz_conc(10) = 10; %FabB to 10
[palm_equiv,~,~,time_vals,~] = Combined_Pathway_Solver_function(init_cond,enz_conc,time_range);
plot(time_vals,palm_equiv)
% p = polyfit(time_vals(1:end)/60,palm_equiv(1:end),1);
% rate(3) = p(1)/ref(2);
rate(3) = palm_equiv(end)/time_range(end)*60/ref(2);

enz_conc(10) = 1; %FabB back to 1
enz_conc(6) = 1; %FabI to 1
[palm_equiv,~,~,time_vals,~] = Combined_Pathway_Solver_function(init_cond,enz_conc,time_range);
plot(time_vals,palm_equiv)
% p = polyfit(time_vals(1:end)/60,palm_equiv(1:end),1);
% rate(4) = p(1)/ref(2);
rate(4) = palm_equiv(end)/time_range(end)*60/ref(2);

xlabel('time')
ylabel('palmitic acid equivalents')
legend({'ref1','1','ref2','2','3','4'})
hold off

figure(3)
bar(rate)
hold on
ylabel('relative initial rate')
title('Figure S2C')
% % 
% % %fminsearch
% % %safe toolbox
% % 


%Plot Fatty Acid Profile
figure()
barnames = {'C4','C6','C8','C10','C12','C12:1','C14','C14:1','C16','C16:1','C18','C18:1','C20','C20:1'};
bar(frac_FA(1:end))
set(gca,'xticklabel',barnames)
ylabel('Fraction FA')
title('FA profile with FabH/B/F as normal')


   

