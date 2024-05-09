%FAS solver Function
%Solves the system of ordindary differential equations consisting of the kinetic equations of the alkane pathway 
%   Input:
%       init_cond: vector (n,1) of initial condition values for all
%       components.
%       enz_conc: vector of enzyme concentration values for each enzyme
%       time_range: vector of two values specifying the start and end time
%       point of the solution (seconds).
%   Output:
%       F_weighted: vector of palmitic acid equivalents at each time point
%       in "T".
%       F_raw_all: vector of the amount of fatty acid of each chain length
%       in concentration (uM) at each time point in "T".
%       unsat_out: fraction of unsaturated fatty acid at each time point in
%       "T".
%       T: vector of time points in the numerical solution (seconds)
%       C: matrix of concentration values for all components of the system
%       at the time points in "T".

%All units are uM and seconds.

function results = CPS_Alk_solv_GUI(user)

enz_conc = user.fas_enz;
aux_enz = user.aux_enz;
fas_com = user.fas_com;
TE = user.TE;
init_cond = zeros(346,1);
init_cond(1:11) = fas_com;

compart=1E-3*6.7e-16;
init_cond(309) = 9.61452e-19/compart;%s3 (FtsH)
init_cond(310) = 6.39307e-19/compart;%s6 (LpxC)
init_cond(311) = 2.54062e-19/compart;%s8 (KdtA)


time_range = user.time;

%vector of model parameter values (fit values)
p_vec = [130157.368705725,4812.72121015092,3.46221047687037,17051.6934979162,924.433870278525,0.0525778925170454,2.66701424433824,0.00349275110661883,0.293814247545723,-0.313775721113438,2.66655052022994,0.271673954221911,148.204532874920,1267.69556520898,1.79590000000000,0.124400000000000,0.0384000000000000,0.0116000000000000];
p_vec_k = [0.0154482766181948	94.5603925895629];



%list of labels of species in model (in order of concentration matrix solution)
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

labels = {'s1';'s2';'s3';'s6';'s7';'s8';'p1';'p2';'p3';'p4';'p5';... %1-11
'Q_4';'M_4';'R_4';'T_4';'F_4';'Q_6';'M_6';'R_6';'T_6';'F_6';... %20-21
'Q_8';'M_8';'R_8';'T_8';'F_8';'Q_10';'M_10';'R_10';'T_10';'F_10';'R_10_un';... %22-32
'Q_12';'M_12';'R_12';'T_12';'F_12';'Q_12_un';'M_12_un';'R_12_un';'T_12_un';'F_12_un';... %33-42
'Q_14';'M_14';'R_14';'T_14';'F_14';'Q_14_un';'M_14_un';'R_14_un';'T_14_un';'F_14_un';... %43-52
'Q_16';'M_16';'R_16';'T_16';'F_16';'Q_16_un';'M_16_un';'R_16_un';'T_16_un';'F_16_un';... %53-62
'Q_18';'M_18';'R_18';'T_18';'F_18';'Q_18_un';'M_18_un';'R_18_un';'T_18_un';'F_18_un';... %63-72
'Q_20';'M_20';'R_20';'T_20';'F_20';'Q_20_un';'M_20_un';'R_20_un';'T_20_un';'F_20_un';... %73-82
'e1s1';'e1s1s2';'e1act';'e1acts3';'e2p2';'e2act';'e2acts6';'e3s3';'e3act';'e3actp4';'e4s7';'e6s8';... %83-94
'e3T_4';'e3actT_4';'e4s7Q_4';'e5M_4';'e5R_4';'e6s8R_4';'e7T_4';'e8T_4';'e8act4';'e8act4p4';'e9M_4';'e9R_4';'e10T_4';'e10act4';'e10act4p4';... %95-109
'e3T_6';'e3actT_6';'e4s7Q_6';'e5M_6';'e5R_6';'e6s8R_6';'e7T_6';'e8T_6';'e8act6';'e8act6p4';'e9M_6';'e9R_6';'e10T_6';'e10act6';'e10act6p4';... %110-124
'e3T_8';'e3actT_8';'e4s7Q_8';'e5M_8';'e5R_8';'e6s8R_8';'e7T_8';'e8T_8';'e8act8';'e8act8p4';'e9M_8';'e9R_8';'e10T_8';'e10act8';'e10act8p4';... %125-139
'e3T_10';'e3actT_10';'e4s7Q_10';'e5M_10';'e5R_10';'e6s8R_10';'e7T_10';'e8T_10';'e8act10';'e8act10p4';'e9M_10';'e9R_10';'e10T_10';'e10act10';'e10act10p4';... %140-154
'e3T_12';'e3actT_12';'e4s7Q_12';'e5M_12';'e5R_12';'e6s8R_12';'e7T_12';'e8T_12';'e8act12';'e8act12p4';'e9M_12';'e9R_12';'e10T_12';'e10act12';'e10act12p4';... %155-169
'e3T_14';'e3actT_14';'e4s7Q_14';'e5M_14';'e5R_14';'e6s8R_14';'e7T_14';'e8T_14';'e8act14';'e8act14p4';'e9M_14';'e9R_14';'e10T_14';'e10act14';'e10act14p4';... %170-184
'e3T_16';'e3actT_16';'e4s7Q_16';'e5M_16';'e5R_16';'e6s8R_16';'e7T_16';'e8T_16';'e8act16';'e8act16p4';'e9M_16';'e9R_16';'e10T_16';'e10act16';'e10act16p4';... %185-199
'e3T_18';'e3actT_18';'e4s7Q_18';'e5M_18';'e5R_18';'e6s8R_18';'e7T_18';'e8T_18';'e8act18';'e8act18p4';'e9M_18';'e9R_18';'e10T_18';'e10act18';'e10act18p4';... %200-214
'e3T_20';'e3actT_20';'e4s7Q_20';'e5M_20';'e5R_20';'e6s8R_20';'e7T_20';'e9M_20';'e9R_20';... %215-223
'e3T_12_un';'e3actT_12_un';'e4s7Q_12_un';'e5M_12_un';'e5R_12_un';'e6s8R_12_un';'e7T_12_un';'e8T_12_un';'e8act12_un';'e8act12_unp4';'e9M_12_un';'e9R_12_un';'e10T_12_un';'e10act12_un';'e10act12_unp4';... %224-238
'e3T_14_un';'e3actT_14_un';'e4s7Q_14_un';'e5M_14_un';'e5R_14_un';'e6s8R_14_un';'e7T_14_un';'e8T_14_un';'e8act14_un';'e8act14_unp4';'e9M_14_un';'e9R_14_un';'e10T_14_un';'e10act14_un';'e10act14_unp4';... %239-253
'e3T_16_un';'e3actT_16_un';'e4s7Q_16_un';'e5M_16_un';'e5R_16_un';'e6s8R_16_un';'e7T_16_un';'e8T_16_un';'e8act16_un';'e8act16_unp4';'e9M_16_un';'e9R_16_un';'e10T_16_un';'e10act16_un';'e10act16_unp4';... %254-268
'e3T_18_un';'e3actT_18_un';'e4s7Q_18_un';'e5M_18_un';'e5R_18_un';'e6s8R_18_un';'e7T_18_un';'e8T_18_un';'e8act18_un';'e8act18_unp4';'e9M_18_un';'e9R_18_un';'e10T_18_un';'e10act18_un';'e10act18_unp4';... %269-283
'e3T_20_un';'e3actT_20_un';'e4s7Q_20_un';'e5M_20_un';'e5R_20_un';'e6s8R_20_un';'e7T_20_un';'e9M_20_un';'e9R_20_un';'e3s6';'e4s6';'e5s6';'e6s6';'e7s6';'e8s6';'e9s6';'e10s6';... %284-300
'e9R_10_un';'e10R_10_un';'e10act10_un';'e10act10_unp4';... %301-304
%New Fab acitivites/lipidA/phospholipid components are unlabeled
'T_2';'e8p4';'e8T_2';'e8act2';'e8act2p4';'e10p4';'e10T_2';'e10act2';'e10s3';'e10act2p4';... %326-336
};

%list of rate constant labels for binding/unbinding and cataltyic steps
%All forward and reverse steps are labeled with "k" followed by a number
%indicating the enzyme to which the kinetic constant refers. Hence "k2" is
%FabD. The next number after the underscore indicates the order of the step
%in the reaction mechanism of the enzyme. Hence "k2_1" refers to the first
%binding step of FabD. The letter at the end refers to forward "f" or
%reverse "r" direction of the reaction. Hence "k2_1f" refers to the forward
%binding constant, k_on, of the binding reaction of FabD with its first
%substrate, malonyl-CoA. Catalytic constants, kcat, are labeled as "kcat"
%followed by the enzyme number. For FabA and FabZ, "kcat9" and "kcat5"
%refer to the forward rate constant, while "k9_2r" and "k5_2r" refer to
%the reverse rate constant.
param_names = {{'k1_1f';'k1_1r';'k1_2f';'k1_2r';'kcat1_1';'k1_3f';'k1_3r';...
'kcat1_2';'k2_1f';'k2_1r';'k2_2f';'k2_2r';'k2_3f';'k2_3r';'k2_4f';...
'k2_4r';'k3_1f';'k3_1r';'k3_2f';'k3_2r';'k3_3f';'k3_3r';'k3_4f';'k3_4r';'k3_5f';'k3_5r';'kcat3';...
'k8_4f';'k8_4r';'k8_5f';'k8_5r';'k8_6f';'k8_6r';'k8_7f';'k8_7r';'k8_8f';'k8_8r';'k8_9f';'k8_9r';'kcat8_H';'kcat8_CO2';...
'k10_4f';'k10_4r';'k10_5f';'k10_5r';'k10_6f';'k10_6r';'k10_7f';'k10_7r';'k10_8f';'k10_8r';'k10_9f';'k10_9r';'kcat10_H';'kcat10_CO2';...
'k4_1f';'k4_1r';'k4_2f';'k4_2r';'kcat4';'k5_1f';'k5_1r';...
'kcat5';'k5_2r';'k6_1f';'k6_1r';'k6_2f';'k6_2r';'kcat6';'k7_1f';'k7_1r';...
'kcat7';'k8_1f';'k8_1r';'k8_2f';'k8_2r';'k8_3f';'k8_3r';'kcat8';...
'k9_1f';'k9_1r';'kcat9';'k9_2r';'k10_1f';'k10_1r';'k10_2f';'k10_2r';'k10_3f';'k10_3r';'kcat10'...
}};

%set of parameter values that are varied (or likely subject to change) in
%structure sent to parameterization function param_func.m
acp_bind = p_vec(12);%parameter "e"
field5 = 'opt_name'; val5 = {{'k2_4f','k3_4f','k3_4r','k3_5f','k3_5r','k7_1f','kcat7','k8_1f','k8_2f','k10_1f','k10_2f','kcat5','kcat8','kcat9','kcat10','k5_2r','k9_2r','k5_1f','k9_1f'}};%parameters with unique modifications in param_func
field6 = 'param_names'; val6 = param_names;
field10 = 'scaling_factor_init'; val10 = p_vec(1);%parameter "a1"
field11 = 'scaling_factor_elon'; val11 = p_vec(2);%parameter "a2"
field12 = 'scaling_factor_kcat'; val12 = p_vec(5);%parameter "c2"
field13 = 'scaling_factor_term'; val13 = p_vec(3);%parameter "a3"
field14 = 'scaling_factor_fabf'; val14 = p_vec(2);%parameter "a2" (option here to modify FabF scaling seperately)
field15 = 'scaling_factor_kcat_term'; val15 = p_vec(6);%parameter "c3"
%ACP_inh lists kon,koff (in this order) for inhibitory ACP binding
%[FabH,FabG,FabZ,FabI,TesA,FabF,FabA,FabB]
field16 = 'ACP_inh'; val16 = [acp_bind*2.41E-04,4.22*2.17E-02,2.41E-03,4.22*2.17E-02,2.41E-03,4.22*2.17E-02,2.41E-03,4.22*2.17E-02,2.41E-03,4.22*2.17E-02,acp_bind*2.41E-03,4.22*2.17E-02,2.41E-03,4.22*2.17E-02,2.41E-03,4.22*2.17E-02];
field17 = 'enzyme_conc'; val17 = enz_conc;%Initial enzyme conentrations (ACC,FabD,FabH,FabG,FabZ,FabI,TesA,FabF,FabA,FabB)
field18 = 'inhibition_kds';val18 = (1/acp_bind).*[4335.05,23.67;824.7,30.1;967.5,7.55;251.52,8.484;128.78,2.509];%(Acyl-ACP binding FabH Kd values in pairs (binding to FabH and FabH*), first two values are Kd for 4-12, subsequent values are 14-20)
field19 = 'inhibition_on_rates';val19 = [0.3088,1.552];%On rates of acyl-ACP binding FabH (binding to FabH and FabH*)
field20 = 'kd_fits';val20 = [p_vec(8),p_vec(9),p_vec(4),p_vec(9)]; %[b2,b3,b1,b3] %Keq or Kd values that are fit
field21 = 'lin_param';val21=[p_vec(10) p_vec(11)];% [d1 d2]; TesA linear free energy slope and intercept (as a function of chain length)
field22 = 'scaling_factor_kcat_init';val22 = p_vec(7);%parameter "c1"
field23 = 'scaling_factor_FabA_unsat';val23 = p_vec(13);%parameter "f"
field24 = 'scaling_factor_FabAZ_kcat';val24 = p_vec(14);%parameter "c4"
field25 = 'TesA_fitting_source';val25 = TE;%source of thioesterase fitting ('Pf'; Pfleger group measurements, 'Fox'; Fox group measurements', 'Non-native'; For alternative thioesterases)
field26 = 'scaling_factor_kcat8_CO2';val26 = p_vec(15);%scaling kcat8_CO2
field27 = 'scaling_factor_kcat10_CO2';val27 = p_vec(16);%scaling kcat10_CO2
field28 = 'scaling_factor_k8_7f'; val28 = p_vec(17); %scaling k8_7f
field29 = 'scaling_factor_k10_4f';val29 = p_vec(18); %scaling k10_4f
field30 = 'aux_enz'; val30 = aux_enz;


%parameter options structure
opt_struct = struct(field5,val5,field6,val6,field10,val10,field11,val11,field12,val12,field13,val13,field14,val14,field15,val15,...
    field16,val16,field17,val17,field18,val18,field19,val19,field20,val20,field21,val21,field22,val22,field23,val23,field24,val24,field25,val25,...
    field26,val26,field27,val27,field28,val28,field29,val29,field30, val30);


%loads the estimated kon, koff, and kcat values from "est_param.csv"
%and the estimated km values from "km_est.csv"
tables = struct;
tables.('param_table') = readtable('est_param.csv','ReadRowNames',true);
tables.('km_table') = readtable('km_est.csv','ReadRowNames',true);

%generates the parameter values in paramter structure from the parameter
%function (using inputs of the options structure and the parameter table)
param_struct = struct;
for i = 1:length(param_names{1})
    param_struct.(param_names{1}{i}) = param_func(param_names{1}{i},i,opt_struct,tables);
end


%model function with all constants from the parameterization
parameterized_Combined_Pathway_Model = @(t,c) Combined_Pathway_Model_Alk(t,c,param_struct,opt_struct,p_vec_k);


%Time range (sec)
range = time_range;

%options for the solver
%RelTol: relative error tolerance of solution (minor impact on solve time)
%MaxOrder: Max order of numerical differention equation (default, minor impact on solve time)
%JPattern: Matrix defining sparsity pattern of the Jacobian (1 for all non
%zero elements in the Jacobian, 0 otherwise). Included to reduce solve
%time.
%Vectorized: Specififies that the model is formatted in a vector format
%(signfiicantly impacts solve time)
options = odeset('RelTol',1e-6,'AbsTol',1e-6,'MaxOrder',5,'Vectorized','on');

%Numerical solution is found with solver ode15s (ideal for stiff systems)
%T: Time (sec)
%C: Matrix of concentration values of each species (columns) at each time
%point in T (rows)
[T,C] = ode15s(parameterized_Combined_Pathway_Model,range,init_cond,options);

%Data Handling

%Calculates palmitic acid equivalents (F_weighted) by converting the amount
%of fatty acid of each chain length to palmitic equivalents
F_weighted = zeros(length(T),1);
F_saved = zeros(1,14);
F_raw_all = zeros(length(T),14);
weight_vec = [4,6,8,10,12,12,14,14,16,16,18,18,20,20]/16;
count = 1;
for ind = 1:length(labels)
    label_val = char(labels(ind));
    first_char = label_val(1);
    if first_char == char('F')
        F_saved(count) = weight_vec(count)*(C(end,ind));
        F_raw_all(:,count) = C(:,ind);
        F_weighted = weight_vec(count)*(C(:,ind)) + F_weighted;
        count = count + 1;
    end
end
total_FA = sum(F_raw_all(end,:));%total fatty acid (concentration)

Alk = C(end,343:346);
Alk_raw = C(:,343:346);

results.acyl_ACP_dist = 0;
results.aldehyde_dist = 0;
results.alkane_dist = Alk;

results.acyl_ACP_time = C(:,15)+C(:,20)+C(:,25)+C(:,30)+C(:,36)+C(:,46)+C(:,56)+C(:,66)+C(:,76)+C(:,41)+C(:,51)+C(:,61)+C(:,71)+C(:,81);
results.aldehyde_time = sum(C(:,337:342),2);
results.alkane_time = sum(Alk_raw,2);
results.time = T;
