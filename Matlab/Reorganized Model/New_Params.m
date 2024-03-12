function dy = ODE_Function(t,y,S)
%Contains all the differential equations and enzyme balances that define
%the FAS model
%   Input:
%       t: time values (required as input for MATLAB ODE solver, sec)
%       y: concentration values (all components and intermediates, uM)
%       param_list: structure containing all kinetic parameters
%       opt_struct: structure containining additional parameters of
%       model(such as initial enzyme concentration)
%   Output:
%       dy: values of differential equations for given 
%       concentrations and kinetic parameters

%% Parameters

% changes struct to variables
names = fieldnames(S);
for i = 1:numel(names)
    assignin('caller', names{i}, S.(names{i}));
end

% searches for the index in which the first elongation step occurs (this is
% why param_names needs to have all initiation steps listed first)
for i = 1:length(param_names)
    param_val = char(param_names(i));
    first_char = param_val(1:2);
    if first_char == char('k4')
        split_index = i;
        break
    end
end

num_elong_steps = 9;%number of elongation steps

% if the parameter is kcat, then scale each estimated kcat value from the 
% table using the appropriate kcat scaling terms

kcat7 = param_table{'kcat7','parameter_values'}*scaling_factor_kcat_term; %termination scaling for TesA

% elongation scaling for FabG,FabI,FabF,FabA,FabB
kcat4 = param_table{'kcat4','parameter_values'}*scaling_factor_kcat;
kcat6 = param_table{'kcat6','parameter_values'}*scaling_factor_kcat;
kcat8 = param_table{'kcat8','parameter_values'}*scaling_factor_kcat;
kcat9 = param_table{'kcat9','parameter_values'}*scaling_factor_kcat;
kcat10 = param_table{'kcat10','parameter_values'}*scaling_factor_kcat;

kcat5 = param_table{'kcat5','parameter_values'}*scaling_factor_FabAZ_kcat;%FabZ (c4) scaling

% initiation scaling for FabD,FabH
kcat1_1 = param_table{'kcat1_1','parameter_values'}*scaling_factor_kcat_init;
kcat1_2 = param_table{'kcat1_2','parameter_values'}*scaling_factor_kcat_init;
kcat3 = param_table{'kcat3','parameter_values'}*scaling_factor_kcat_init;
 
% if the parameter is kon or koff, then scale both using the appropriate 
% scaling factors. Kon is further modified using the estimated Kd values 
% such that kd_est = koff_final/kon_final
 
% For FabD,FabH use "a1" scaling
k2_1r = param_table{'k2_1r','parameter_values'}*scaling_factor_init;
k2_3r = param_table{'k2_3r','parameter_values'}*scaling_factor_init;
k3_1r = param_table{'k3_1r','parameter_values'}*scaling_factor_init;
k3_3r = param_table{'k3_3r','parameter_values'}*scaling_factor_init;
k2_1f = k2_1r/km_table{'k2_1f','parameter_values'};
k2_3f = k2_3r/km_table{'k2_3f','parameter_values'};
k3_1f = k3_1r/km_table{'k3_1f','parameter_values'};
k3_3f = k3_3r/km_table{'k3_3f','parameter_values'};

% For TesA use parameter "a3"
k7_1f = param_table{'k7_1f','parameter_values'}*scaling_factor_term;
k7_1r = param_table{'k7_1r','parameter_values'}*scaling_factor_term;

% For FabF and FabB use paramter "a2" (seperated as scaling_factor_fabf in 
% case different scalings are desired, note scaling_factor_fabf=a2 here)
k8_1r = param_table{'k8_1r','parameter_values'}*scaling_factor_fabf;
k10_1r = param_table{'k10_1r','parameter_values'}*scaling_factor_fabf;
k8_1f = k8_1r/km_table{'k8_1f','parameter_values'};
k10_1f = k10_1r/km_table{'k10_1f','parameter_values'};

% This paramter modification step differs from other steps in thatit is not 
% a binding step, but a reverse catalytic step. For FabZ and FabA reverse 
% use parameter "c4" and "c2." Note that FabZ and FabA are reversible 
% reactions, the forward reaction is denoted by kcat5 and kcat9, the 
% reverse reaction by k5_2r and k9_2r. As both forward and reverse are 
% scaled by the same constant the ratio (Keq) is maintained.
k5_2r = param_table{'k5_2r','parameter_values'}*scaling_factor_FabAZ_kcat;
k9_2r = param_table{'k9_2r','parameter_values'}*scaling_factor_kcat;

 
% For FabD,FabH,FabF,FabB forward and reverse intermediate reaction steps 
% (the intermediate reaction of the ping-pong mechanism) use scaling "b1"
k2_2r = param_table{'k2_2r','parameter_values'}*kd_fits(3);
k2_4r = param_table{'k2_4r','parameter_values'}*kd_fits(3);
k3_2r = param_table{'k3_2r','parameter_values'}*kd_fits(3);
k8_2r = param_table{'k8_2r','parameter_values'}*kd_fits(3);
k10_2r = param_table{'k10_2r','parameter_values'}*kd_fits(3);

% For FabZ use parameter "a2"
k5_1r = param_table{'k5_1r','parameter_values'}*scaling_factor_elon;
k5_1f = k5_1r/km_table{'k5_1f','parameter_values'};

% For FabG,FabI,FabF,FabA,FabB use parameter "a2"
k4_1r = param_table{'k4_1r','parameter_values'}*scaling_factor_elon;
k4_2r = param_table{'k4_2r','parameter_values'}*scaling_factor_elon;
k6_1r = param_table{'k6_1r','parameter_values'}*scaling_factor_elon;
k6_2r = param_table{'k6_2r','parameter_values'}*scaling_factor_elon;
k8_3r = param_table{'k8_3r','parameter_values'}*scaling_factor_elon;
k9_1r = param_table{'k9_1r','parameter_values'}*scaling_factor_elon;
k10_3r = param_table{'k10_3r','parameter_values'}*scaling_factor_elon;

k4_1f = k4_1r/km_table{'k4_1f','parameter_values'};
k4_2f = k4_2r/km_table{'k4_2f','parameter_values'};
k6_1f = k6_1r/km_table{'k6_1f','parameter_values'};
k6_2f = k6_2r/km_table{'k6_2f','parameter_values'};
k8_3f = k8_3r/km_table{'k8_3f','parameter_values'};
k9_1f = k9_1r/km_table{'k9_1f','parameter_values'};
k10_3f = k10_3r/km_table{'k10_3f','parameter_values'};

% ACC and FabH
k1_1f = param_table{'k1_1f','parameter_values'}*scaling_factor_elon;
k1_1r = param_table{'k1_1r','parameter_values'}*scaling_factor_elon;
k1_2f = param_table{'k1_2f','parameter_values'}*scaling_factor_elon;
k1_2r = param_table{'k1_2r','parameter_values'}*scaling_factor_elon;
k1_3f = param_table{'k1_3f','parameter_values'}*scaling_factor_elon;
k1_3r = param_table{'k1_3r','parameter_values'}*scaling_factor_elon;

k3_5f = param_table{'k3_5f','parameter_values'}*scaling_factor_elon;
k3_5r = param_table{'k3_5r','parameter_values'}*scaling_factor_elon;

% After the initial paramter assignment, additional parameters are
% assigned, and modified (for example incorporating substrate specificity)

% For FabH inhibition use appropriate on/off rates (note that inhibition has
% two types, noncompetitive (k3_4*) with respect to acetyl-CoA
% and competitive (k3_5*)with respect to malonyl-ACP

% Noncompetitive inhibition with respect to acetyl-CoA (binding FabH)
k3_4f = zeros(1,num_elong_steps);
k3_4r = zeros(1,num_elong_steps);

for i = 1:length(num_elong_steps)
    if i <= 5
        k3_4f(i) = inhibition_on_rates(1); %inhibition for acyl-ACPs of 4-12 has the same value
        k3_4r(i) = inhibition_kds(1,1)*inhibition_on_rates(1);%on rate calculation from Kds are same value for all chain lengths)
    else
        k3_4f(i) = inhibition_on_rates(1);
        k3_4r(i) = inhibition_kds(i-4,1)*inhibition_on_rates(1);
    end
end
 
% Competitive inhibition with respect to malonyl-ACP (binding FabH*)
k3_5f = zeros(1,num_elong_steps);
k3_5r = zeros(1,num_elong_steps);

for i = 1:length(num_elong_steps)
    if i <= 5
        k3_5f(i) = inhibition_on_rates(2);%inhibition for acyl-ACPs of 4-12 has the same value
        k3_5r(i) = inhibition_kds(1,2)*inhibition_on_rates(2);%inhibition for acyl-ACPs of 4-12 has the same value
    else
        k3_5f(i) = inhibition_on_rates(2);
        k3_5r(i) = inhibition_kds(i-4,2)*inhibition_on_rates(2);
    end
end

% Specify chain length dependence of kon and kcat for TesA
kcat70 = kcat7;
k7_1f = zeros(1,num_elong_steps);
kcat7 = zeros(1,num_elong_steps); 
 
% Specify source of measurments, 'Pf'; Pfleger group measurements, 'Fox'; Fox group measurements
% Implements TesA kcat chain length dependence as relative scaling (of base 
% value which is fit)
if strcmp(TesA_fitting_source,'Pf')
    kd_12 = exp(lin_slope*(12) + lin_int);%kd estimated from linear free energy relationship for chain lengths 12-20
    ratio_val = kd_12/Pf_scaling;%ratio used to match kd at chain length 12
    kd_est = (ratio_val).*Pf_kd_est_scaling;%Kds for 4,6 and 8-12, estimated Kd is scaled to match linear free energy values
    kcat_scaling = Pf_kcat_scaling;
elseif strcmp(TesA_fitting_source,'Fox')
    kd_12 = exp(lin_slope*(12) + lin_int);
    ratio_val = kd_12/Fox_scaling;
    kd_est = (ratio_val).*Fox_kd_est_scaling;
    kcat_scaling = Fox_kcat_scaling;
elseif strcmp(TesA_fitting_source,'Non-native')
    kd_est = Non_kd_est;
    kcat_scaling = Non_kcat_scaling;
end

for i = 1:num_elong_steps
    kd_long = exp(lin_slope*(i*2+2) + lin_int);
    kcat7(i) = kcat70*kcat_scaling(i);
    if i < 5
        k7_1f(i) = k7_1r/kd_est(i);%for 4-12 use linear free energy values
    elseif strcmp(TesA_fitting_source,'Non-native')
        k7_1f(i) = k7_1r/kd_est(i);
    else
        k7_1f(i) = k7_1r/kd_long;%for 12-20 use scaled estimates
    end
end

% FabF and FabB on rates can be further modified by restricting elongation
% here by changing the value of i (i = 5 is chain length 12) and modifying
% the if/else statement
k8_1f0 = k8_1f;
k10_1f0 = k10_1f;
k8_1f = zeros(1,num_elong_steps);
k10_1f = zeros(1,num_elong_steps);
for i = 1:num_elong_steps
    if i > 5
        k8_1f(i) = k8_1f0;
        k10_1f(i) = k10_1f0;
    else
        k8_1f(i) = k8_1f0;%change if using restricted elongation mutant
        k10_1f(i) = k10_1f0;%change if using restricted elongation mutant
    end
end
 
% Acyl transfer step k_fwd and k_rvs are determined by the fit parameters 
% b2 and b3, which are the Keq values for the transfer step
% b2 is Keq for FabD (first step) only
% b3 is Keq for FabD (second step), FabH, FabF, and FabB

% FabD first transfer step
k2_2f = k2_2r/kd_fits(1);%b2

% FabH transfer step
k3_2f = k3_2r/kd_fits(2);%b3

% FabF transfer step and FabB transfer step
k8_2f = zeros(1,num_elong_steps);
k10_2f = zeros(1,num_elong_steps);
for i = 1:num_elong_steps
    k8_2f(i) = k8_2r/kd_fits(2);%b3
    k10_2f(i) = k10_2r/kd_fits(2);%b3
end
 
% FabD second transfer step
k2_4f = k2_4r/kd_fits(2);%b3
 
% Chain length specificities for FabZ,FabF,FabA,FabB
kcat50 = kcat5;
kcat5 = zeros(1,num_elong_steps);
kcat80 = kcat8;
kcat8 = zeros(1,num_elong_steps);
kcat90 = kcat9;
kcat9 = zeros(1,num_elong_steps);
kcat100 = kcat10;
kcat10 = zeros(1,num_elong_steps);
for i = 1:num_elong_steps
    kcat5(i) = kcat50*kcat_scaling_fabZ(i);% FabZ chain length kcat scaling
    kcat8(i) = kcat80*kcat_scaling_fabF(i);%FabF chain length kcat scaling
    kcat9(i) = kcat90*kcat_scaling_fabA(i);%FabA chain length kcat scaling
    kcat10(i) = kcat100*kcat_scaling_fabB(i);%FabB chain length kcat scaling
end

%For FabZ and FabA chain length specificities of k_rvs (reverse reaction
%rate 'k5_2r' and 'k9_2r') and kon
k5_2r0 = k5_2r;
k5_2r = zeros(1,num_elong_steps);
k9_2r0 = k9_2r;
k9_2r = zeros(1,num_elong_steps);
k5_1f0 = k5_1f;
k5_1f = zeros(1,num_elong_steps);
k9_1f0 = k9_1f;
k9_1f = zeros(1,num_elong_steps);
for i = 1:num_elong_steps
    k5_2r(i) = k5_2r0*kcat_scaling_fabZ(i);%FabZ chain length k_rvs scaling
    k9_2r(i) = k9_2r0*kcat_scaling_fabA(i);%FabA chain length k_rvs scaling
    k5_1f(i) = k5_1f0*kon_scaling_fabZ(i);%FabZ chain length kon scaling
    k9_1f(i) = k9_1f0*kon_scaling_fabA(i);%FabA chain length kon scaling
end

% Remaining parameters that need to be vectors for elongation
k4_1f = k4_1f.*ones(1,num_elong_steps);
k4_1r = k4_1r.*ones(1,num_elong_steps);
k4_2f = k4_2f.*ones(1,num_elong_steps);
k4_2r = k4_2r.*ones(1,num_elong_steps);
kcat4 = kcat4.*ones(1,num_elong_steps);
k5_1r = k5_1r.*ones(1,num_elong_steps);
k6_1f = k6_1f.*ones(1,num_elong_steps);
k6_1r = k6_1r.*ones(1,num_elong_steps);
k6_2f = k6_2f.*ones(1,num_elong_steps);
k6_2r = k6_2r.*ones(1,num_elong_steps);
kcat6 = kcat6.*ones(1,num_elong_steps);
k7_1r = k7_1r.*ones(1,num_elong_steps);
k8_1r = k8_1r.*ones(1,num_elong_steps);
k8_2r = k8_2r.*ones(1,num_elong_steps);
k8_3f = k8_3f.*ones(1,num_elong_steps);
k8_3r = k8_3r.*ones(1,num_elong_steps);
k9_1r = k9_1r.*ones(1,num_elong_steps);
k10_1r = k10_1r.*ones(1,num_elong_steps);
k10_2r = k10_2r.*ones(1,num_elong_steps);
k10_3f = k10_3f.*ones(1,num_elong_steps);
k10_3r = k10_3r.*ones(1,num_elong_steps);

% Other params

% ACC (not used)
e1tot = enzyme_conc(1);

% FabD
e2tot = enzyme_conc(2);

% FabH
k3_inh_f = ACP_inh(1);
k3_inh_r = ACP_inh(2);
e3tot = enzyme_conc(3);

% FabG
k4_inh_f = ACP_inh(3);
k4_inh_r = ACP_inh(4);
e4tot = enzyme_conc(4);

% FabZ
k5_3f = k5_1r;
k5_3r = k5_1f;
k5_inh_f = ACP_inh(5);
k5_inh_r = ACP_inh(6);
e5tot = enzyme_conc(5);

% FabI
k6_inh_f = ACP_inh(7);
k6_inh_r = ACP_inh(8);
e6tot = enzyme_conc(6);

% TesA
k7_inh_f = ACP_inh(9);
k7_inh_r = ACP_inh(10);
e7tot = enzyme_conc(7);

% FabF
kcat8_un = kcat8(4).*kcat_scaling_fabF_unsat;%specificity of reaction with unsaturated acyl chains
k8_inh_f = ACP_inh(11);
k8_inh_r = ACP_inh(12);
e8tot = enzyme_conc(8);

% FabA
k9_3f = k9_1r;
k9_3r = k9_1f;
k9_1f_un = k9_1f.*scaling_vector_fabA_unsat;%specificity of reaction with unsaturated acyl chains
k9_1r_un = k9_1r;
kcat9_un = kcat9.*kcat_scaling_fabA_unsat;
k9_2r_un = k9_2r;
k9_3f_un = k9_3f;
k9_3r_un = k9_3r;
k9_inh_f = ACP_inh(13);
k9_inh_r = ACP_inh(14);
e9tot = enzyme_conc(9);

% FabB
kcat10_un = kcat10(5).*kcat_scaling_fabB_unsat;%specificity of reaction with unsaturated acyl chains
k10_inh_f = ACP_inh(15);
k10_inh_r = ACP_inh(16);
e10tot = enzyme_conc(10);

%% ODEs

% Enzyme concentration balance equations
e1 = e1tot - y(83,:) - y(84,:) - y(85,:) - y(86,:);%ACC
e2 = e2tot - y(87,:) - y(88,:) - y(89,:);%FabD
e3 = e3tot - y(90,:) - y(91,:) - y(92,:) - y(95,:) - y(110,:) - y(125,:) - y(140,:) - y(155,:) - y(170,:) - y(185,:) - y(200,:) - y(215,:)...
    - y(96,:) - y(111,:) - y(126,:) - y(141,:) - y(156,:) - y(171,:) - y(186,:) - y(201,:) - y(216,:) - y(293,:);%FabH
e4 = e4tot - y(93,:) - y(97,:) - y(112,:) - y(127,:) - y(142,:) - y(157,:) - y(172,:) - y(187,:)...
    - y(202,:) - y(217,:) - y(226,:) - y(241,:) - y(256,:) - y(271,:) - y(286,:) - y(294,:);%FabG
e5 = e5tot - y(98,:) - y(113,:) - y(128,:) - y(143,:) - y(158,:) - y(173,:) - y(188,:) - y(203,:) - y(218,:)...
    - y(227,:) - y(242,:) - y(257,:) - y(272,:) - y(287,:)...
    - y(99,:) - y(114,:) - y(129,:) - y(144,:) - y(159,:) - y(174,:) - y(189,:) - y(204,:) - y(219,:)...
    - y(228,:) - y(243,:) - y(258,:) - y(273,:) - y(288,:)...
    - y(295,:);%FabZ
e6 = e6tot - y(94,:) - y(100,:) - y(115,:) - y(130,:) - y(145,:) - y(160,:) - y(175,:) - y(190,:)...
    - y(205,:) - y(220,:) - y(229,:) - y(244,:) - y(259,:) - y(274,:) - y(289,:) - y(296,:);%FabI
e7 = e7tot - y(101,:) - y(116,:) - y(131,:) - y(146,:) - y(161,:) - y(176,:) - y(191,:) - y(206,:) - y(221,:)...
    - y(230,:) - y(245,:) - y(260,:) - y(275,:) - y(290,:) - y(297,:);%TesA
e8 = e8tot - y(102,:) - y(103,:) - y(104,:) - y(117,:) - y(118,:) - y(119,:) - y(132,:) - y(133,:) - y(134,:)...
     - y(147,:) - y(148,:) - y(149,:) - y(162,:) - y(231,:) - y(163,:) - y(232,:) - y(164,:) - y(233,:)...
     - y(177,:) - y(246,:) - y(178,:) - y(247,:) - y(179,:) - y(248,:)...
     - y(192,:) - y(261,:) - y(193,:) - y(262,:) - y(194,:) - y(263,:)...
     - y(207,:) - y(276,:) - y(208,:) - y(277,:) - y(209,:) - y(278,:) - y(298,:);%FabF
e9 = e9tot - y(105,:) - y(120,:) - y(135,:) - y(150,:) - y(165,:) - y(180,:) - y(195,:) - y(210,:) - y(222,:)...
    - y(234,:) - y(249,:) - y(264,:) - y(279,:) - y(291,:)...
    - y(106,:) - y(121,:) - y(136,:) - y(151,:) - y(166,:) - y(181,:) - y(196,:) - y(211,:) - y(223,:)...
    - y(235,:) - y(250,:) - y(265,:) - y(280,:) - y(292,:) - y(301,:)...
    - y(299,:);%FabA
e10 = e10tot - y(107,:) - y(108,:) - y(109,:) - y(122,:) - y(123,:) - y(124,:) - y(137,:) - y(138,:) - y(139,:)...
     - y(152,:) - y(153,:) - y(154,:) - y(167,:) - y(236,:) - y(168,:) - y(237,:) - y(169,:) - y(238,:)...
     - y(182,:) - y(251,:) - y(183,:) - y(252,:) - y(184,:) - y(253,:)...
     - y(197,:) - y(266,:) - y(198,:) - y(267,:) - y(199,:) - y(268,:)...
     - y(212,:) - y(281,:) - y(213,:) - y(282,:) - y(214,:) - y(283,:)...
     - y(302,:) - y(303,:) - y(304,:) - y(300,:);%FabB


dy = zeros(304,size(y,2));

% Set of differential equations
dy(1,:) = k1_1r.*y(83,:) - k1_1f.*e1.*y(1,:);
dy(2,:) = k1_2r.*y(84,:) - k1_2f.*y(83,:).*y(2,:);
dy(3,:) = k1_3r.*y(86,:) + k3_1r.*y(90,:) - k1_3f.*y(85,:).*y(3,:) - k3_1f.*e3.*y(3,:);
dy(4,:) = k2_3r.*y(89,:) - k2_3f.*y(88,:).*y(4,:)...
    + kcat7(1).*y(101,:)...
    + kcat7(2).*y(116,:)...
    + kcat7(3).*y(131,:)...
    + kcat7(4).*y(146,:)...
    + kcat7(5).*y(161,:)...
    + kcat7(6).*y(176,:)...
    + kcat7(7).*y(191,:)...
    + kcat7(8).*y(206,:)...
    + kcat7(9).*y(221,:)...
    + kcat7(5).*y(230,:)...
    + kcat7(6).*y(245,:)...
    + kcat7(7).*y(260,:)...
    + kcat7(8).*y(275,:)...
    + kcat7(9).*y(290,:)...
    + k8_2f(1).*y(102,:) - k8_2r(1).*y(103,:).*y(4,:)...
    + k8_2f(2).*y(117,:) - k8_2r(2).*y(118,:).*y(4,:)...
    + k8_2f(3).*y(132,:) - k8_2r(3).*y(133,:).*y(4,:)...
    + k8_2f(4).*y(147,:)- k8_2r(4).*y(148,:).*y(4,:)...
    + k8_2f(5).*y(162,:)- k8_2r(5).*y(163,:).*y(4,:)...
    + k8_2f(6).*y(177,:)- k8_2r(6).*y(178,:).*y(4,:)...
    + k8_2f(7).*y(192,:)- k8_2r(7).*y(193,:).*y(4,:)...
    + k8_2f(8).*y(207,:)- k8_2r(8).*y(208,:).*y(4,:)...
    + k8_2f(5).*y(231,:)- k8_2r(5).*y(232,:).*y(4,:)...
    + k8_2f(6).*y(246,:)- k8_2r(6).*y(247,:).*y(4,:)...
    + k8_2f(7).*y(261,:)- k8_2r(7).*y(262,:).*y(4,:)...
    + k8_2f(8).*y(276,:)- k8_2r(8).*y(277,:).*y(4,:)...
    + k10_2f(1).*y(107,:) - k10_2r(1).*y(108,:).*y(4,:)...
    + k10_2f(2).*y(122,:) - k10_2r(2).*y(123,:).*y(4,:)...
    + k10_2f(3).*y(137,:) - k10_2r(3).*y(138,:).*y(4,:)...
    + k10_2f(4).*y(152,:)- k10_2r(4).*y(153,:).*y(4,:)...
    + k10_2f(5).*y(167,:)- k10_2r(5).*y(168,:).*y(4,:)...
    + k10_2f(6).*y(182,:)- k10_2r(6).*y(183,:).*y(4,:)...
    + k10_2f(7).*y(197,:)- k10_2r(7).*y(198,:).*y(4,:)...
    + k10_2f(8).*y(212,:)- k10_2r(8).*y(213,:).*y(4,:)...
    + k10_2f(5).*y(236,:)- k10_2r(5).*y(237,:).*y(4,:)...
    + k10_2f(6).*y(251,:)- k10_2r(6).*y(252,:).*y(4,:)...
    + k10_2f(7).*y(266,:)- k10_2r(7).*y(267,:).*y(4,:)...
    + k10_2f(8).*y(281,:)- k10_2r(8).*y(282,:).*y(4,:)...
    + k10_2f(4).*y(302,:)- k10_2r(4).*y(303,:).*y(4,:)...
    + k3_inh_r.*y(293,:)  - k3_inh_f.*e3.*y(4,:)...
    + k4_inh_r.*y(294,:)  - k4_inh_f.*e4.*y(4,:)...
    + k5_inh_r.*y(295,:)  - k5_inh_f.*e5.*y(4,:)...
    + k6_inh_r.*y(296,:)  - k6_inh_f.*e6.*y(4,:)...
    + k7_inh_r.*y(297,:)  - k7_inh_f.*e7.*y(4,:)...
    + k8_inh_r.*y(298,:)  - k8_inh_f.*e8.*y(4,:)...
    + k9_inh_r.*y(299,:)  - k9_inh_f.*e9.*y(4,:)...
    + k10_inh_r.*y(300,:)  - k10_inh_f.*e10.*y(4,:)...
    ;
dy(5,:) = k4_1r(1).*y(93,:) - k4_1f(1).*e4.*y(5,:);
dy(6,:) = k6_1r(1).*y(94,:) - k6_1f(1).*e6.*y(6,:);

dy(7,:) = kcat1_2.*y(86,:);
dy(8,:) = kcat1_2.*y(86,:) + k2_1r.*y(87,:) - k2_1f.*e2.*y(8,:);
dy(9,:) = k2_2f.*y(87,:) + k3_2f.*y(90,:) - k2_2r.*y(88,:).*y(9,:) - k3_2r.*y(91,:).*y(9,:);
dy(10,:) = k2_4f.*y(89,:) + k3_3r.*y(92,:) - k2_4r.*e2.*y(10,:) - k3_3f.*y(91,:).*y(10,:)...
    + k8_3r(1).*y(104,:) - k8_3f(1).*y(103,:).*y(10,:)...
    + k8_3r(2).*y(119,:) - k8_3f(2).*y(118,:).*y(10,:)...
    + k8_3r(3).*y(134,:) - k8_3f(3).*y(133,:).*y(10,:)...
    + k8_3r(4).*y(149,:)- k8_3f(4).*y(148,:).*y(10,:)...
    + k8_3r(5).*y(164,:)- k8_3f(5).*y(163,:).*y(10,:)...
    + k8_3r(6).*y(179,:)- k8_3f(6).*y(178,:).*y(10,:)...
    + k8_3r(7).*y(194,:)- k8_3f(7).*y(193,:).*y(10,:)...
    + k8_3r(8).*y(209,:)- k8_3f(8).*y(208,:).*y(10,:)...
    + k8_3r(5).*y(233,:)- k8_3f(5).*y(232,:).*y(10,:)...
    + k8_3r(6).*y(248,:)- k8_3f(6).*y(247,:).*y(10,:)...
    + k8_3r(7).*y(263,:)- k8_3f(7).*y(262,:).*y(10,:)...
    + k8_3r(8).*y(278,:)- k8_3f(8).*y(277,:).*y(10,:)...
    + k10_3r(1).*y(109,:) - k10_3f(1).*y(108,:).*y(10,:)...
    + k10_3r(2).*y(124,:) - k10_3f(2).*y(123,:).*y(10,:)...
    + k10_3r(3).*y(139,:) - k10_3f(3).*y(138,:).*y(10,:)...
    + k10_3r(4).*y(154,:)- k10_3f(4).*y(153,:).*y(10,:)...
    + k10_3r(5).*y(169,:)- k10_3f(5).*y(168,:).*y(10,:)...
    + k10_3r(6).*y(184,:)- k10_3f(6).*y(183,:).*y(10,:)...
    + k10_3r(7).*y(199,:)- k10_3f(7).*y(198,:).*y(10,:)...
    + k10_3r(8).*y(214,:)- k10_3f(8).*y(213,:).*y(10,:)...
    + k10_3r(5).*y(238,:)- k10_3f(5).*y(237,:).*y(10,:)...
    + k10_3r(6).*y(253,:)- k10_3f(6).*y(252,:).*y(10,:)...
    + k10_3r(7).*y(268,:)- k10_3f(7).*y(267,:).*y(10,:)...
    + k10_3r(8).*y(283,:)- k10_3f(8).*y(282,:).*y(10,:)...
    + k10_3r(4).*y(304,:)- k10_3f(4).*y(303,:).*y(10,:)...
    ;
dy(11,:) = kcat3.*y(92,:) + kcat8(1).*y(104,:) + kcat8(2).*y(119,:) + kcat8(3).*y(134,:) + kcat8(4).*y(149,:)...
    + kcat8(5).*y(164,:) + kcat8(6).*y(179,:) + kcat8(7).*y(194,:) + kcat8(8).*y(209,:)...
    + kcat8_un(5).*y(233,:) + kcat8_un(6).*y(248,:) + kcat8_un(7).*y(263,:) + kcat8_un(8).*y(278,:)...
    + kcat10(1).*y(109,:) + kcat10(2).*y(124,:) + kcat10(3).*y(139,:) + kcat10(4).*y(154,:)...
    + kcat10(5).*y(169,:) + kcat10(6).*y(184,:) + kcat10(7).*y(199,:) + kcat10(8).*y(214,:)...
    + kcat10_un(4).*y(304,:) + kcat10_un(5).*y(238,:) + kcat10_un(6).*y(253,:) + kcat10_un(7).*y(268,:) + kcat10_un(8).*y(283,:)...
;

dy(12,:) = kcat3.*y(92,:) + k4_2r(1).*y(97,:) - k4_2f(1).*y(93,:).*y(12,:);

dy(17,:) =  kcat8(1).*y(104,:) + kcat10(1).*y(109,:) + k4_2r(2).*y(112,:) - k4_2f(2).*y(93,:).*y(17,:);
dy(22,:) =  kcat8(2).*y(119,:) + kcat10(2).*y(124,:) + k4_2r(3).*y(127,:) - k4_2f(3).*y(93,:).*y(22,:);
dy(27,:) = kcat8(3).*y(134,:) + kcat10(3).*y(139,:) + k4_2r(4).*y(142,:)- k4_2f(4).*y(93,:).*y(27,:);
dy(33,:) = kcat8(4).*y(149,:)+ kcat10(4).*y(154,:)+ k4_2r(5).*y(157,:)- k4_2f(5).*y(93,:).*y(33,:);
dy(43,:) = kcat8(5).*y(164,:)+ kcat10(5).*y(169,:) + k4_2r(6).*y(172,:)- k4_2f(6).*y(93,:).*y(43,:);
dy(53,:) = kcat8(6).*y(179,:)+ kcat10(6).*y(184,:) + k4_2r(7).*y(187,:)- k4_2f(7).*y(93,:).*y(53,:);
dy(63,:) = kcat8(7).*y(194,:)+ kcat10(7).*y(199,:) + k4_2r(8).*y(202,:)- k4_2f(8).*y(93,:).*y(63,:);
dy(73,:) = kcat8(8).*y(209,:)+ kcat10(8).*y(214,:) + k4_2r(9).*y(217,:)- k4_2f(9).*y(93,:).*y(73,:);



dy(38,:) =                         kcat10_un(4).*y(304,:) + k4_2r(5).*y(226,:)- k4_2f(5).*y(93,:).*y(38,:);
dy(48,:) = kcat8_un(5).*y(233,:) + kcat10_un(5).*y(238,:) + k4_2r(6).*y(241,:)- k4_2f(6).*y(93,:).*y(48,:);
dy(58,:) = kcat8_un(6).*y(248,:) + kcat10_un(6).*y(253,:) + k4_2r(7).*y(256,:)- k4_2f(7).*y(93,:).*y(58,:);
dy(68,:) = kcat8_un(7).*y(263,:) + kcat10_un(7).*y(268,:) + k4_2r(8).*y(271,:)- k4_2f(8).*y(93,:).*y(68,:);
dy(78,:) = kcat8_un(8).*y(278,:) + kcat10_un(8).*y(283,:) + k4_2r(9).*y(286,:)- k4_2f(9).*y(93,:).*y(78,:);

dy(13,:) =  kcat4(1).*y(97,:) + k5_1r(1).*y(98,:) - k5_1f(1).*e5.*y(13,:) + k9_1r(1).*y(105,:) - k9_1f(1).*e9.*y(13,:);
dy(18,:) =  kcat4(2).*y(112,:) + k5_1r(2).*y(113,:) - k5_1f(2).*e5.*y(18,:) + k9_1r(2).*y(120,:) - k9_1f(2).*e9.*y(18,:);
dy(23,:) =  kcat4(3).*y(127,:) + k5_1r(3).*y(128,:) - k5_1f(3).*e5.*y(23,:) + k9_1r(3).*y(135,:) - k9_1f(3).*e9.*y(23,:);
dy(28,:) = kcat4(4).*y(142,:)+ k5_1r(4).*y(143,:)- k5_1f(4).*e5.*y(28,:)+ k9_1r(4).*y(150,:)- k9_1f(4).*e9.*y(28,:);
dy(34,:) = kcat4(5).*y(157,:)+ k5_1r(5).*y(158,:)- k5_1f(5).*e5.*y(34,:)+ k9_1r(5).*y(165,:)- k9_1f(5).*e9.*y(34,:);
dy(44,:) = kcat4(6).*y(172,:)+ k5_1r(6).*y(173,:)- k5_1f(6).*e5.*y(44,:)+ k9_1r(6).*y(180,:)- k9_1f(6).*e9.*y(44,:);
dy(54,:) = kcat4(7).*y(187,:)+ k5_1r(7).*y(188,:)- k5_1f(7).*e5.*y(54,:)+ k9_1r(7).*y(195,:)- k9_1f(7).*e9.*y(54,:);
dy(64,:) = kcat4(8).*y(202,:)+ k5_1r(8).*y(203,:)- k5_1f(8).*e5.*y(64,:)+ k9_1r(8).*y(210,:)- k9_1f(8).*e9.*y(64,:);
dy(74,:) = kcat4(9).*y(217,:)+ k5_1r(9).*y(218,:)- k5_1f(9).*e5.*y(74,:)+ k9_1r(9).*y(222,:)- k9_1f(9).*e9.*y(74,:);

dy(39,:) = kcat4(5).*y(226,:)+ k5_1r(5).*y(227,:)- k5_1f(5).*e5.*y(39,:)+ k9_1r_un(5).*y(234,:)- k9_1f_un(5).*e9.*y(39,:);
dy(49,:) = kcat4(6).*y(241,:)+ k5_1r(6).*y(242,:)- k5_1f(6).*e5.*y(49,:)+ k9_1r_un(6).*y(249,:)- k9_1f_un(6).*e9.*y(49,:);
dy(59,:) = kcat4(7).*y(256,:)+ k5_1r(7).*y(257,:)- k5_1f(7).*e5.*y(59,:)+ k9_1r_un(7).*y(264,:)- k9_1f_un(7).*e9.*y(59,:);
dy(69,:) = kcat4(8).*y(271,:)+ k5_1r(8).*y(272,:)- k5_1f(8).*e5.*y(69,:)+ k9_1r_un(8).*y(279,:)- k9_1f_un(8).*e9.*y(69,:);
dy(79,:) = kcat4(9).*y(286,:)+ k5_1r(9).*y(287,:)- k5_1f(9).*e5.*y(79,:)+ k9_1r_un(9).*y(291,:)- k9_1f_un(9).*e9.*y(79,:);



dy(14,:) =  k5_3f(1).*y(99,:) - k5_3r(1).*e5.*y(14,:) +k9_3f(1).*y(106,:) - k9_3r(1).*e9.*y(14,:) + k6_2r(1).*y(100,:) - k6_2f(1).*y(94,:).*y(14,:);
dy(19,:) =  k5_3f(2).*y(114,:) - k5_3r(2).*e5.*y(19,:) +k9_3f(2).*y(121,:) - k9_3r(2).*e9.*y(19,:) + k6_2r(2).*y(115,:) - k6_2f(2).*y(94,:).*y(19,:);
dy(24,:) =  k5_3f(3).*y(129,:) - k5_3r(3).*e5.*y(24,:) +k9_3f(3).*y(136,:) - k9_3r(3).*e9.*y(24,:) + k6_2r(3).*y(130,:) - k6_2f(3).*y(94,:).*y(24,:);
dy(29,:) = k5_3f(4).*y(144,:) -k5_3r(4).*e5.*y(29,:)+k9_3f(4).*y(151,:) -k9_3r(4).*e9.*y(29,:)+ k6_2r(4).*y(145,:)- k6_2f(4).*y(94,:).*y(29,:);
dy(35,:) = k5_3f(5).*y(159,:) -k5_3r(5).*e5.*y(35,:)+k9_3f(5).*y(166,:) -k9_3r(5).*e9.*y(35,:)+ k6_2r(5).*y(160,:)- k6_2f(5).*y(94,:).*y(35,:);
dy(45,:) = k5_3f(6).*y(174,:) -k5_3r(6).*e5.*y(45,:)+k9_3f(6).*y(181,:) -k9_3r(6).*e9.*y(45,:)+ k6_2r(6).*y(175,:)- k6_2f(6).*y(94,:).*y(45,:);
dy(55,:) = k5_3f(7).*y(189,:) -k5_3r(7).*e5.*y(55,:)+k9_3f(7).*y(196,:) -k9_3r(7).*e9.*y(55,:)+ k6_2r(7).*y(190,:)- k6_2f(7).*y(94,:).*y(55,:);
dy(65,:) = k5_3f(8).*y(204,:) -k5_3r(8).*e5.*y(65,:)+k9_3f(8).*y(211,:) -k9_3r(8).*e9.*y(65,:)+ k6_2r(8).*y(205,:)- k6_2f(8).*y(94,:).*y(65,:);
dy(75,:) = k5_3f(9).*y(219,:) -k5_3r(9).*e5.*y(75,:)+k9_3f(9).*y(223,:) -k9_3r(9).*e9.*y(75,:)+ k6_2r(9).*y(220,:)- k6_2f(9).*y(94,:).*y(75,:);

dy(32,:) = k9_3f_un(4).*y(301,:) - k9_3r_un(4).*e9.*y(32,:) + k10_1r(4).*y(302,:) - k10_1f(4).*e10.*y(32,:);
dy(40,:) = k5_3f(5).*y(228,:) -k5_3r(5).*e5.*y(40,:)+k9_3f(5).*y(235,:) -k9_3r(5).*e9.*y(40,:)+ k6_2r(5).*y(229,:)- k6_2f(5).*y(94,:).*y(40,:);
dy(50,:) = k5_3f(6).*y(243,:) -k5_3r(6).*e5.*y(50,:)+k9_3f(6).*y(250,:) -k9_3r(6).*e9.*y(50,:)+ k6_2r(6).*y(244,:)- k6_2f(6).*y(94,:).*y(50,:);
dy(60,:) = k5_3f(7).*y(258,:) -k5_3r(7).*e5.*y(60,:)+k9_3f(7).*y(265,:) -k9_3r(7).*e9.*y(60,:)+ k6_2r(7).*y(259,:)- k6_2f(7).*y(94,:).*y(60,:);
dy(70,:) = k5_3f(8).*y(273,:) -k5_3r(8).*e5.*y(70,:)+k9_3f(8).*y(280,:) -k9_3r(8).*e9.*y(70,:)+ k6_2r(8).*y(274,:)- k6_2f(8).*y(94,:).*y(70,:);
dy(80,:) = k5_3f(9).*y(288,:) -k5_3r(9).*e5.*y(80,:)+k9_3f(9).*y(292,:) -k9_3r(9).*e9.*y(80,:)+ k6_2r(9).*y(289,:)- k6_2f(9).*y(94,:).*y(80,:);

dy(15,:) =   kcat6(1).*y(100,:) + k7_1r(1).*y(101,:) + k8_1r(1).*y(102,:)+  k10_1r(1).*y(107,:)  - k7_1f(1).*e7.*y(15,:) - k8_1f(1).*e8.*y(15,:) - k10_1f(1).*e10.*y(15,:) - k3_4f(1).*e3.*y(15,:) + k3_4r(1).*y(95,:) - k3_5f(1).*y(91,:).*y(15,:) + k3_5r(1).*y(96,:);
dy(20,:) =   kcat6(2).*y(115,:) + k7_1r(2).*y(116,:) + k8_1r(2).*y(117,:)+  k10_1r(2).*y(122,:)  - k7_1f(2).*e7.*y(20,:) - k8_1f(2).*e8.*y(20,:) - k10_1f(2).*e10.*y(20,:) - k3_4f(2).*e3.*y(20,:) + k3_4r(2).*y(110,:) - k3_5f(2).*y(91,:).*y(20,:) + k3_5r(2).*y(111,:);
dy(25,:) =   kcat6(3).*y(130,:) + k7_1r(3).*y(131,:) + k8_1r(3).*y(132,:)+  k10_1r(3).*y(137,:)  - k7_1f(3).*e7.*y(25,:) - k8_1f(3).*e8.*y(25,:) - k10_1f(3).*e10.*y(25,:) - k3_4f(3).*e3.*y(25,:) + k3_4r(3).*y(125,:) - k3_5f(3).*y(91,:).*y(25,:) + k3_5r(3).*y(126,:);
dy(30,:) =  kcat6(4).*y(145,:)+ k7_1r(4).*y(146,:)+ k8_1r(4).*y(147,:)+ k10_1r(4).*y(152,:) - k7_1f(4).*e7.*y(30,:)- k8_1f(4).*e8.*y(30,:)- k10_1f(4).*e10.*y(30,:)- k3_4f(4).*e3.*y(30,:)+ k3_4r(4).*y(140,:)- k3_5f(4).*y(91,:).*y(30,:)+ k3_5r(4).*y(141,:);
dy(36,:) =  kcat6(5).*y(160,:)+ k7_1r(5).*y(161,:)+ k8_1r(5).*y(162,:)+ k10_1r(5).*y(167,:) - k7_1f(5).*e7.*y(36,:)- k8_1f(5).*e8.*y(36,:)- k10_1f(5).*e10.*y(36,:)- k3_4f(5).*e3.*y(36,:)+ k3_4r(5).*y(155,:)- k3_5f(5).*y(91,:).*y(36,:)+ k3_5r(5).*y(156,:);
dy(46,:) =  kcat6(6).*y(175,:)+ k7_1r(6).*y(176,:)+ k8_1r(6).*y(177,:)+ k10_1r(6).*y(182,:) - k7_1f(6).*e7.*y(46,:)- k8_1f(6).*e8.*y(46,:)- k10_1f(6).*e10.*y(46,:)- k3_4f(6).*e3.*y(46,:)+ k3_4r(6).*y(170,:)- k3_5f(6).*y(91,:).*y(46,:)+ k3_5r(6).*y(171,:);
dy(56,:) =  kcat6(7).*y(190,:)+ k7_1r(7).*y(191,:)+ k8_1r(7).*y(192,:)+ k10_1r(7).*y(197,:) - k7_1f(7).*e7.*y(56,:)- k8_1f(7).*e8.*y(56,:)- k10_1f(7).*e10.*y(56,:)- k3_4f(7).*e3.*y(56,:)+ k3_4r(7).*y(185,:)- k3_5f(7).*y(91,:).*y(56,:)+ k3_5r(7).*y(186,:);
dy(66,:) =  kcat6(8).*y(205,:)+ k7_1r(8).*y(206,:)+ k8_1r(8).*y(207,:)+ k10_1r(8).*y(212,:) - k7_1f(8).*e7.*y(66,:)- k8_1f(8).*e8.*y(66,:)- k10_1f(8).*e10.*y(66,:)- k3_4f(8).*e3.*y(66,:)+ k3_4r(8).*y(200,:)- k3_5f(8).*y(91,:).*y(66,:)+ k3_5r(8).*y(201,:);
dy(76,:) =  kcat6(9).*y(220,:)+ k7_1r(9).*y(221,:)                  - k7_1f(9).*e7.*y(76,:)                  - k3_4f(9).*e3.*y(76,:)+ k3_4r(9).*y(215,:)- k3_5f(9).*y(91,:).*y(76,:)+ k3_5r(9).*y(216,:);


dy(41,:) =  kcat6(5).*y(229,:)+ k7_1r(5).*y(230,:)+ k8_1r(5).*y(231,:)+ k10_1r(5).*y(236,:) - k7_1f(5).*e7.*y(41,:)- k8_1f(5).*e8.*y(41,:)- k10_1f(5).*e10.*y(41,:)- k3_4f(5).*e3.*y(41,:)+ k3_4r(5).*y(224,:)- k3_5f(5).*y(91,:).*y(41,:)+ k3_5r(5).*y(225,:);
dy(51,:) =  kcat6(6).*y(244,:)+ k7_1r(6).*y(245,:)+ k8_1r(6).*y(246,:)+ k10_1r(6).*y(251,:) - k7_1f(6).*e7.*y(51,:)- k8_1f(6).*e8.*y(51,:)- k10_1f(6).*e10.*y(51,:)- k3_4f(6).*e3.*y(51,:)+ k3_4r(6).*y(239,:)- k3_5f(6).*y(91,:).*y(51,:)+ k3_5r(6).*y(240,:);
dy(61,:) =  kcat6(7).*y(259,:)+ k7_1r(7).*y(260,:)+ k8_1r(7).*y(261,:)+ k10_1r(7).*y(266,:) - k7_1f(7).*e7.*y(61,:)- k8_1f(7).*e8.*y(61,:)- k10_1f(7).*e10.*y(61,:)- k3_4f(7).*e3.*y(61,:)+ k3_4r(7).*y(254,:)- k3_5f(7).*y(91,:).*y(61,:)+ k3_5r(7).*y(255,:);
dy(71,:) =  kcat6(8).*y(274,:)+ k7_1r(8).*y(275,:)+ k8_1r(8).*y(276,:)+ k10_1r(8).*y(281,:) - k7_1f(8).*e7.*y(71,:)- k8_1f(8).*e8.*y(71,:)- k10_1f(8).*e10.*y(71,:)- k3_4f(8).*e3.*y(71,:)+ k3_4r(8).*y(269,:)- k3_5f(8).*y(91,:).*y(71,:)+ k3_5r(8).*y(270,:);
dy(81,:) =  kcat6(9).*y(289,:)+ k7_1r(9).*y(290,:)                  - k7_1f(9).*e7.*y(81,:)                  - k3_4f(9).*e3.*y(81,:)+ k3_4r(9).*y(284,:)- k3_5f(9).*y(91,:).*y(81,:)+ k3_5r(9).*y(285,:);

dy(16,:) =  kcat7(1).*y(101,:);
dy(21,:) =  kcat7(2).*y(116,:);
dy(26,:) =  kcat7(3).*y(131,:);
dy(31,:) = kcat7(4).*y(146,:);
dy(37,:) = kcat7(5).*y(161,:);
dy(47,:) = kcat7(6).*y(176,:);
dy(57,:) = kcat7(7).*y(191,:);
dy(67,:) = kcat7(8).*y(206,:);
dy(77,:) = kcat7(9).*y(221,:);

dy(42,:) = kcat7(5).*y(230,:);
dy(52,:) = kcat7(6).*y(245,:);
dy(62,:) = kcat7(7).*y(260,:);
dy(72,:) = kcat7(8).*y(275,:);
dy(82,:) = kcat7(9).*y(290,:);

dy(83,:) = k1_1f.*e1.*y(1,:) + k1_2r.*y(84,:) - k1_1r.*y(83,:) - k1_2f.*y(83,:).*y(2,:);
dy(84,:) = k1_2f.*y(83,:).*y(2,:) - k1_2r.*y(84,:) - kcat1_1.*y(84,:);
dy(85,:) = kcat1_1.*y(84,:) + k1_3r.*y(86,:) - k1_3f.*y(85,:).*y(3,:);
dy(86,:) = k1_3f.*y(85,:).*y(3,:) - k1_3r.*y(86,:) - kcat1_2.*y(86,:);

dy(87,:) = k2_1f.*e2.*y(8,:) + k2_2r.*y(88,:).*y(9,:) - k2_1r.*y(87,:) - k2_2f.*y(87,:);
dy(88,:) = k2_2f.*y(87,:) + k2_3r.*y(89,:) - k2_2r.*y(88,:).*y(9,:) - k2_3f.*y(88,:).*y(4,:);
dy(89,:) = k2_3f.*y(88,:).*y(4,:) + k2_4r.*e2.*y(10,:) - k2_3r.*y(89,:) - k2_4f.*y(89,:);

dy(90,:) = k3_1f.*e3.*y(3,:) + k3_2r.*y(91,:).*y(9,:) - k3_1r.*y(90,:) - k3_2f.*y(90,:);
dy(91,:) = k3_2f.*y(90,:) + k3_3r.*y(92,:) - k3_2r.*y(91,:).*y(9,:) - k3_3f.*y(91,:).*y(10,:)...
    + k3_5r(1).*y(96,:)  - k3_5f(1).*y(91,:).*y(15,:)...
    + k3_5r(2).*y(111,:)  - k3_5f(2).*y(91,:).*y(20,:)...
    + k3_5r(3).*y(126,:)  - k3_5f(3).*y(91,:).*y(25,:)...
    + k3_5r(4).*y(141,:) - k3_5f(4).*y(91,:).*y(30,:)...
    + k3_5r(5).*y(156,:) - k3_5f(5).*y(91,:).*y(36,:)...
    + k3_5r(6).*y(171,:) - k3_5f(6).*y(91,:).*y(46,:)...
    + k3_5r(7).*y(186,:) - k3_5f(7).*y(91,:).*y(56,:)...
    + k3_5r(8).*y(201,:) - k3_5f(8).*y(91,:).*y(66,:)...
    + k3_5r(9).*y(216,:) - k3_5f(9).*y(91,:).*y(76,:)...
    + k3_5r(5).*y(225,:) - k3_5f(5).*y(91,:).*y(41,:)...
    + k3_5r(6).*y(240,:) - k3_5f(6).*y(91,:).*y(51,:)...
    + k3_5r(7).*y(255,:) - k3_5f(7).*y(91,:).*y(61,:)...
    + k3_5r(8).*y(270,:) - k3_5f(8).*y(91,:).*y(71,:)...
    + k3_5r(9).*y(285,:) - k3_5f(9).*y(91,:).*y(81,:)...
    ;
dy(92,:) = k3_3f.*y(91,:).*y(10,:) - k3_3r.*y(92,:) - kcat3.*y(92,:);
dy(93,:) = k4_1f(1).*e4.*y(5,:) - k4_1r(1).*y(93,:)...
    + k4_2r(1).*y(97,:) - k4_2f(1).*y(93,:).*y(12,:)...
    + k4_2r(2).*y(112,:) - k4_2f(2).*y(93,:).*y(17,:)...
    + k4_2r(3).*y(127,:) - k4_2f(3).*y(93,:).*y(22,:)...
    + k4_2r(4).*y(142,:)- k4_2f(4).*y(93,:).*y(27,:)...
    + k4_2r(5).*y(157,:)- k4_2f(5).*y(93,:).*y(33,:)...
    + k4_2r(6).*y(172,:)- k4_2f(6).*y(93,:).*y(43,:)...
    + k4_2r(7).*y(187,:)- k4_2f(7).*y(93,:).*y(53,:)...
    + k4_2r(8).*y(202,:)- k4_2f(8).*y(93,:).*y(63,:)...
    + k4_2r(9).*y(217,:)- k4_2f(9).*y(93,:).*y(73,:)...
    + k4_2r(5).*y(226,:)- k4_2f(5).*y(93,:).*y(38,:)...
    + k4_2r(6).*y(241,:)- k4_2f(6).*y(93,:).*y(48,:)...
    + k4_2r(7).*y(256,:)- k4_2f(7).*y(93,:).*y(58,:)...
    + k4_2r(8).*y(271,:)- k4_2f(8).*y(93,:).*y(68,:)...
    + k4_2r(9).*y(286,:)- k4_2f(9).*y(93,:).*y(78,:)...
;
dy(97,:) =  k4_2f(1).*y(93,:).*y(12,:) - k4_2r(1).*y(97,:) - kcat4(1).*y(97,:);
dy(112,:) =  k4_2f(2).*y(93,:).*y(17,:) - k4_2r(2).*y(112,:) - kcat4(2).*y(112,:);
dy(127,:) =  k4_2f(3).*y(93,:).*y(22,:) - k4_2r(3).*y(127,:) - kcat4(3).*y(127,:);
dy(142,:) = k4_2f(4).*y(93,:).*y(27,:)- k4_2r(4).*y(142,:)- kcat4(4).*y(142,:);
dy(157,:) = k4_2f(5).*y(93,:).*y(33,:)- k4_2r(5).*y(157,:)- kcat4(5).*y(157,:);
dy(172,:) = k4_2f(6).*y(93,:).*y(43,:)- k4_2r(6).*y(172,:)- kcat4(6).*y(172,:);
dy(187,:) = k4_2f(7).*y(93,:).*y(53,:)- k4_2r(7).*y(187,:)- kcat4(7).*y(187,:);
dy(202,:) = k4_2f(8).*y(93,:).*y(63,:)- k4_2r(8).*y(202,:)- kcat4(8).*y(202,:);
dy(217,:) = k4_2f(9).*y(93,:).*y(73,:)- k4_2r(9).*y(217,:)- kcat4(9).*y(217,:);

dy(226,:) = k4_2f(5).*y(93,:).*y(38,:)- k4_2r(5).*y(226,:)- kcat4(5).*y(226,:);
dy(241,:) = k4_2f(6).*y(93,:).*y(48,:)- k4_2r(6).*y(241,:)- kcat4(6).*y(241,:);
dy(256,:) = k4_2f(7).*y(93,:).*y(58,:)- k4_2r(7).*y(256,:)- kcat4(7).*y(256,:);
dy(271,:) = k4_2f(8).*y(93,:).*y(68,:)- k4_2r(8).*y(271,:)- kcat4(8).*y(271,:);
dy(286,:) = k4_2f(9).*y(93,:).*y(78,:)- k4_2r(9).*y(286,:)- kcat4(9).*y(286,:);

dy(98,:) =  k5_1f(1).*e5.*y(13,:) - k5_1r(1).*y(98,:) - kcat5(1).*y(98,:) + k5_2r(1).*y(99,:);
dy(113,:) =  k5_1f(2).*e5.*y(18,:) - k5_1r(2).*y(113,:) - kcat5(2).*y(113,:) + k5_2r(2).*y(114,:);
dy(128,:) =  k5_1f(3).*e5.*y(23,:) - k5_1r(3).*y(128,:) - kcat5(3).*y(128,:) + k5_2r(3).*y(129,:);
dy(143,:) = k5_1f(4).*e5.*y(28,:)- k5_1r(4).*y(143,:)- kcat5(4).*y(143,:) +k5_2r(4).*y(144,:);
dy(158,:) = k5_1f(5).*e5.*y(34,:)- k5_1r(5).*y(158,:)- kcat5(5).*y(158,:) +k5_2r(5).*y(159,:);
dy(173,:) = k5_1f(6).*e5.*y(44,:)- k5_1r(6).*y(173,:)- kcat5(6).*y(173,:) +k5_2r(6).*y(174,:);
dy(188,:) = k5_1f(7).*e5.*y(54,:)- k5_1r(7).*y(188,:)- kcat5(7).*y(188,:) +k5_2r(7).*y(189,:);
dy(203,:) = k5_1f(8).*e5.*y(64,:)- k5_1r(8).*y(203,:)- kcat5(8).*y(203,:) +k5_2r(8).*y(204,:);
dy(218,:) = k5_1f(9).*e5.*y(74,:)- k5_1r(9).*y(218,:)- kcat5(9).*y(218,:) +k5_2r(9).*y(219,:);

dy(227,:) = k5_1f(5).*e5.*y(39,:)- k5_1r(5).*y(227,:)- kcat5(5).*y(227,:) + k5_2r(5).*y(228,:);
dy(242,:) = k5_1f(6).*e5.*y(49,:)- k5_1r(6).*y(242,:)- kcat5(6).*y(242,:) + k5_2r(6).*y(243,:);
dy(257,:) = k5_1f(7).*e5.*y(59,:)- k5_1r(7).*y(257,:)- kcat5(7).*y(257,:) + k5_2r(7).*y(258,:);
dy(272,:) = k5_1f(8).*e5.*y(69,:)- k5_1r(8).*y(272,:)- kcat5(8).*y(272,:) + k5_2r(8).*y(273,:);
dy(287,:) = k5_1f(9).*e5.*y(79,:)- k5_1r(9).*y(287,:)- kcat5(9).*y(287,:) + k5_2r(9).*y(288,:);


dy(99,:) =  kcat5(1).*y(98,:) - k5_2r(1).*y(99,:) - k5_3f(1).*y(99,:) + k5_3r(1).*e5.*y(14,:);
dy(114,:) =  kcat5(2).*y(113,:) - k5_2r(2).*y(114,:) - k5_3f(2).*y(114,:) + k5_3r(2).*e5.*y(19,:);
dy(129,:) =  kcat5(3).*y(128,:) - k5_2r(3).*y(129,:) - k5_3f(3).*y(129,:) + k5_3r(3).*e5.*y(24,:);
dy(144,:) = kcat5(4).*y(143,:)- k5_2r(4).*y(144,:)- k5_3f(4).*y(144,:)+ k5_3r(4).*e5.*y(29,:);
dy(159,:) = kcat5(5).*y(158,:)- k5_2r(5).*y(159,:)- k5_3f(5).*y(159,:)+ k5_3r(5).*e5.*y(35,:);
dy(174,:) = kcat5(6).*y(173,:)- k5_2r(6).*y(174,:)- k5_3f(6).*y(174,:)+ k5_3r(6).*e5.*y(45,:);
dy(189,:) = kcat5(7).*y(188,:)- k5_2r(7).*y(189,:)- k5_3f(7).*y(189,:)+ k5_3r(7).*e5.*y(55,:);
dy(204,:) = kcat5(8).*y(203,:)- k5_2r(8).*y(204,:)- k5_3f(8).*y(204,:)+ k5_3r(8).*e5.*y(65,:);
dy(219,:) = kcat5(9).*y(218,:)- k5_2r(9).*y(219,:)- k5_3f(9).*y(219,:)+ k5_3r(9).*e5.*y(75,:);

dy(228,:) = kcat5(5).*y(227,:) - k5_2r(5).*y(228,:) - k5_3f(5).*y(228,:) + k5_3r(5).*e5.*y(40,:);
dy(243,:) = kcat5(6).*y(242,:) - k5_2r(6).*y(243,:) - k5_3f(6).*y(243,:) + k5_3r(6).*e5.*y(50,:);
dy(258,:) = kcat5(7).*y(257,:) - k5_2r(7).*y(258,:) - k5_3f(7).*y(258,:) + k5_3r(7).*e5.*y(60,:);
dy(273,:) = kcat5(8).*y(272,:) - k5_2r(8).*y(273,:) - k5_3f(8).*y(273,:) + k5_3r(8).*e5.*y(70,:);
dy(288,:) = kcat5(9).*y(287,:) - k5_2r(9).*y(288,:) - k5_3f(9).*y(288,:) + k5_3r(9).*e5.*y(80,:);


dy(105,:) =  k9_1f(1).*e9.*y(13,:) - k9_1r(1).*y(105,:) - kcat9(1).*y(105,:) + k9_2r(1).*y(106,:);
dy(120,:) =  k9_1f(2).*e9.*y(18,:) - k9_1r(2).*y(120,:) - kcat9(2).*y(120,:) + k9_2r(2).*y(121,:);
dy(135,:) =  k9_1f(3).*e9.*y(23,:) - k9_1r(3).*y(135,:) - kcat9(3).*y(135,:) + k9_2r(3).*y(136,:);
dy(150,:) = k9_1f(4).*e9.*y(28,:)- k9_1r(4).*y(150,:)- kcat9(4).*y(150,:) +k9_2r(4).*y(151,:);
dy(165,:) = k9_1f(5).*e9.*y(34,:)- k9_1r(5).*y(165,:)- kcat9(5).*y(165,:) +k9_2r(5).*y(166,:);
dy(180,:) = k9_1f(6).*e9.*y(44,:)- k9_1r(6).*y(180,:)- kcat9(6).*y(180,:) +k9_2r(6).*y(181,:);
dy(195,:) = k9_1f(7).*e9.*y(54,:)- k9_1r(7).*y(195,:)- kcat9(7).*y(195,:) +k9_2r(7).*y(196,:);
dy(210,:) = k9_1f(8).*e9.*y(64,:)- k9_1r(8).*y(210,:)- kcat9(8).*y(210,:) +k9_2r(8).*y(211,:);
dy(222,:) = k9_1f(9).*e9.*y(74,:)- k9_1r(9).*y(222,:)- kcat9(9).*y(222,:) +k9_2r(9).*y(223,:);

dy(234,:) = k9_1f_un(5).*e9.*y(39,:)- k9_1r_un(5).*y(234,:)- kcat9(5).*y(234,:) + k9_2r(5).*y(235,:);
dy(249,:) = k9_1f_un(6).*e9.*y(49,:)- k9_1r_un(6).*y(249,:)- kcat9(6).*y(249,:) + k9_2r(6).*y(250,:);
dy(264,:) = k9_1f_un(7).*e9.*y(59,:)- k9_1r_un(7).*y(264,:)- kcat9(7).*y(264,:) + k9_2r(7).*y(265,:);
dy(279,:) = k9_1f_un(8).*e9.*y(69,:)- k9_1r_un(8).*y(279,:)- kcat9(8).*y(279,:) + k9_2r(8).*y(280,:);
dy(291,:) = k9_1f_un(9).*e9.*y(79,:)- k9_1r_un(9).*y(291,:)- kcat9(9).*y(291,:) + k9_2r(9).*y(292,:);

dy(106,:) =  kcat9(1).*y(105,:) - k9_2r(1).*y(106,:) - k9_3f(1).*y(106,:) + k9_3r(1).*e9.*y(14,:);
dy(121,:) =  kcat9(2).*y(120,:) - k9_2r(2).*y(121,:) - k9_3f(2).*y(121,:) + k9_3r(2).*e9.*y(19,:);
dy(136,:) =  kcat9(3).*y(135,:) - k9_2r(3).*y(136,:) - k9_3f(3).*y(136,:) + k9_3r(3).*e9.*y(24,:);
dy(151,:) = kcat9(4).*y(150,:)- k9_2r(4).*y(151,:)- k9_3f(4).*y(151,:)+ k9_3r(4).*e9.*y(29,:) - kcat9_un(4).*y(151,:) + k9_2r_un(4).*y(301,:);
dy(166,:) = kcat9(5).*y(165,:)- k9_2r(5).*y(166,:)- k9_3f(5).*y(166,:)+ k9_3r(5).*e9.*y(35,:);
dy(181,:) = kcat9(6).*y(180,:)- k9_2r(6).*y(181,:)- k9_3f(6).*y(181,:)+ k9_3r(6).*e9.*y(45,:);
dy(196,:) = kcat9(7).*y(195,:)- k9_2r(7).*y(196,:)- k9_3f(7).*y(196,:)+ k9_3r(7).*e9.*y(55,:);
dy(211,:) = kcat9(8).*y(210,:)- k9_2r(8).*y(211,:)- k9_3f(8).*y(211,:)+ k9_3r(8).*e9.*y(65,:);
dy(223,:) = kcat9(9).*y(222,:)- k9_2r(9).*y(223,:)- k9_3f(9).*y(223,:)+ k9_3r(9).*e9.*y(75,:);

dy(301,:) = kcat9_un(4).*y(151,:) - k9_2r_un(4).*y(301,:) - k9_3f_un(4).*y(301,:) + k9_3r_un(4).*e9.*y(32,:);

dy(235,:) = kcat9(5).*y(234,:) - k9_2r(5).*y(235,:) - k9_3f(5).*y(235,:) + k9_3r(5).*e9.*y(40,:);
dy(250,:) = kcat9(6).*y(249,:) - k9_2r(6).*y(250,:) - k9_3f(6).*y(250,:) + k9_3r(6).*e9.*y(50,:);
dy(265,:) = kcat9(7).*y(264,:) - k9_2r(7).*y(265,:) - k9_3f(7).*y(265,:) + k9_3r(7).*e9.*y(60,:);
dy(280,:) = kcat9(8).*y(279,:) - k9_2r(8).*y(280,:) - k9_3f(8).*y(280,:) + k9_3r(8).*e9.*y(70,:);
dy(292,:) = kcat9(9).*y(291,:) - k9_2r(9).*y(292,:) - k9_3f(9).*y(292,:) + k9_3r(9).*e9.*y(80,:);


dy(94,:) = k6_1f(1).*e6.*y(6,:) - k6_1r(1).*y(94,:)...
    + k6_2r(1).*y(100,:) - k6_2f(1).*y(94,:).*y(14,:)...
    + k6_2r(2).*y(115,:) - k6_2f(2).*y(94,:).*y(19,:)...
    + k6_2r(3).*y(130,:) - k6_2f(3).*y(94,:).*y(24,:)...
    + k6_2r(4).*y(145,:)- k6_2f(4).*y(94,:).*y(29,:)...
    + k6_2r(5).*y(160,:)- k6_2f(5).*y(94,:).*y(35,:)...
    + k6_2r(6).*y(175,:)- k6_2f(6).*y(94,:).*y(45,:)...
    + k6_2r(7).*y(190,:)- k6_2f(7).*y(94,:).*y(55,:)...
    + k6_2r(8).*y(205,:)- k6_2f(8).*y(94,:).*y(65,:)...
    + k6_2r(9).*y(220,:)- k6_2f(9).*y(94,:).*y(75,:)...
    + k6_2r(5).*y(229,:)- k6_2f(5).*y(94,:).*y(40,:)...
    + k6_2r(6).*y(244,:)- k6_2f(6).*y(94,:).*y(50,:)...
    + k6_2r(7).*y(259,:)- k6_2f(7).*y(94,:).*y(60,:)...
    + k6_2r(8).*y(274,:)- k6_2f(8).*y(94,:).*y(70,:)...
    + k6_2r(9).*y(289,:)- k6_2f(9).*y(94,:).*y(80,:)...
;
dy(100,:) =  k6_2f(1).*y(94,:).*y(14,:) - k6_2r(1).*y(100,:) - kcat6(1).*y(100,:);
dy(115,:) =  k6_2f(2).*y(94,:).*y(19,:) - k6_2r(2).*y(115,:) - kcat6(2).*y(115,:);
dy(130,:) =  k6_2f(3).*y(94,:).*y(24,:) - k6_2r(3).*y(130,:) - kcat6(3).*y(130,:);
dy(145,:) = k6_2f(4).*y(94,:).*y(29,:)- k6_2r(4).*y(145,:)- kcat6(4).*y(145,:);
dy(160,:) = k6_2f(5).*y(94,:).*y(35,:)- k6_2r(5).*y(160,:)- kcat6(5).*y(160,:);
dy(175,:) = k6_2f(6).*y(94,:).*y(45,:)- k6_2r(6).*y(175,:)- kcat6(6).*y(175,:);
dy(190,:) = k6_2f(7).*y(94,:).*y(55,:)- k6_2r(7).*y(190,:)- kcat6(7).*y(190,:);
dy(205,:) = k6_2f(8).*y(94,:).*y(65,:)- k6_2r(8).*y(205,:)- kcat6(8).*y(205,:);
dy(220,:) = k6_2f(9).*y(94,:).*y(75,:)- k6_2r(9).*y(220,:)- kcat6(9).*y(220,:);

dy(229,:) = k6_2f(5).*y(94,:).*y(40,:)- k6_2r(5).*y(229,:)- kcat6(5).*y(229,:);
dy(244,:) = k6_2f(6).*y(94,:).*y(50,:)- k6_2r(6).*y(244,:)- kcat6(6).*y(244,:);
dy(259,:) = k6_2f(7).*y(94,:).*y(60,:)- k6_2r(7).*y(259,:)- kcat6(7).*y(259,:);
dy(274,:) = k6_2f(8).*y(94,:).*y(70,:)- k6_2r(8).*y(274,:)- kcat6(8).*y(274,:);
dy(289,:) = k6_2f(9).*y(94,:).*y(80,:)- k6_2r(9).*y(289,:)- kcat6(9).*y(289,:);

dy(101,:) =  k7_1f(1).*e7.*y(15,:) - k7_1r(1).*y(101,:) - kcat7(1).*y(101,:);
dy(116,:) =  k7_1f(2).*e7.*y(20,:) - k7_1r(2).*y(116,:) - kcat7(2).*y(116,:);
dy(131,:) =  k7_1f(3).*e7.*y(25,:) - k7_1r(3).*y(131,:) - kcat7(3).*y(131,:);
dy(146,:) = k7_1f(4).*e7.*y(30,:)- k7_1r(4).*y(146,:)- kcat7(4).*y(146,:);
dy(161,:) = k7_1f(5).*e7.*y(36,:)- k7_1r(5).*y(161,:)- kcat7(5).*y(161,:);
dy(176,:) = k7_1f(6).*e7.*y(46,:)- k7_1r(6).*y(176,:)- kcat7(6).*y(176,:);
dy(191,:) = k7_1f(7).*e7.*y(56,:)- k7_1r(7).*y(191,:)- kcat7(7).*y(191,:);
dy(206,:) = k7_1f(8).*e7.*y(66,:)- k7_1r(8).*y(206,:)- kcat7(8).*y(206,:);
dy(221,:) = k7_1f(9).*e7.*y(76,:)- k7_1r(9).*y(221,:)- kcat7(9).*y(221,:);

dy(230,:) = k7_1f(5).*e7.*y(41,:)- k7_1r(5).*y(230,:)- kcat7(5).*y(230,:);
dy(245,:) = k7_1f(6).*e7.*y(51,:)- k7_1r(6).*y(245,:)- kcat7(6).*y(245,:);
dy(260,:) = k7_1f(7).*e7.*y(61,:)- k7_1r(7).*y(260,:)- kcat7(7).*y(260,:);
dy(275,:) = k7_1f(8).*e7.*y(71,:)- k7_1r(8).*y(275,:)- kcat7(8).*y(275,:);
dy(290,:) = k7_1f(9).*e7.*y(81,:)- k7_1r(9).*y(290,:)- kcat7(9).*y(290,:);

dy(102,:) =  k8_1f(1).*e8.*y(15,:) + k8_2r(1).*y(103,:).*y(4,:) - k8_1r(1).*y(102,:) - k8_2f(1).*y(102,:);
dy(117,:) =  k8_1f(2).*e8.*y(20,:) + k8_2r(2).*y(118,:).*y(4,:) - k8_1r(2).*y(117,:) - k8_2f(2).*y(117,:);
dy(132,:) =  k8_1f(3).*e8.*y(25,:) + k8_2r(3).*y(133,:).*y(4,:) - k8_1r(3).*y(132,:) - k8_2f(3).*y(132,:);
dy(147,:) = k8_1f(4).*e8.*y(30,:)+ k8_2r(4).*y(148,:).*y(4,:)- k8_1r(4).*y(147,:)- k8_2f(4).*y(147,:);
dy(162,:) = k8_1f(5).*e8.*y(36,:)+ k8_2r(5).*y(163,:).*y(4,:)- k8_1r(5).*y(162,:)- k8_2f(5).*y(162,:);
dy(177,:) = k8_1f(6).*e8.*y(46,:)+ k8_2r(6).*y(178,:).*y(4,:)- k8_1r(6).*y(177,:)- k8_2f(6).*y(177,:);
dy(192,:) = k8_1f(7).*e8.*y(56,:)+ k8_2r(7).*y(193,:).*y(4,:)- k8_1r(7).*y(192,:)- k8_2f(7).*y(192,:);
dy(207,:) = k8_1f(8).*e8.*y(66,:)+ k8_2r(8).*y(208,:).*y(4,:)- k8_1r(8).*y(207,:)- k8_2f(8).*y(207,:);

dy(231,:) = k8_1f(5).*e8.*y(41,:)+ k8_2r(5).*y(232,:).*y(4,:)- k8_1r(5).*y(231,:)- k8_2f(5).*y(231,:);
dy(246,:) = k8_1f(6).*e8.*y(51,:)+ k8_2r(6).*y(247,:).*y(4,:)- k8_1r(6).*y(246,:)- k8_2f(6).*y(246,:);
dy(261,:) = k8_1f(7).*e8.*y(61,:)+ k8_2r(7).*y(262,:).*y(4,:)- k8_1r(7).*y(261,:)- k8_2f(7).*y(261,:);
dy(276,:) = k8_1f(8).*e8.*y(71,:)+ k8_2r(8).*y(277,:).*y(4,:)- k8_1r(8).*y(276,:)- k8_2f(8).*y(276,:);


dy(103,:) =  k8_2f(1).*y(102,:) + k8_3r(1).*y(104,:) - k8_2r(1).*y(103,:).*y(4,:) - k8_3f(1).*y(103,:).*y(10,:);
dy(118,:) =  k8_2f(2).*y(117,:) + k8_3r(2).*y(119,:) - k8_2r(2).*y(118,:).*y(4,:) - k8_3f(2).*y(118,:).*y(10,:);
dy(133,:) =  k8_2f(3).*y(132,:) + k8_3r(3).*y(134,:) - k8_2r(3).*y(133,:).*y(4,:) - k8_3f(3).*y(133,:).*y(10,:);
dy(148,:) = k8_2f(4).*y(147,:)+ k8_3r(4).*y(149,:)- k8_2r(4).*y(148,:).*y(4,:)- k8_3f(4).*y(148,:).*y(10,:);
dy(163,:) = k8_2f(5).*y(162,:)+ k8_3r(5).*y(164,:)- k8_2r(5).*y(163,:).*y(4,:)- k8_3f(5).*y(163,:).*y(10,:);
dy(178,:) = k8_2f(6).*y(177,:)+ k8_3r(6).*y(179,:)- k8_2r(6).*y(178,:).*y(4,:)- k8_3f(6).*y(178,:).*y(10,:);
dy(193,:) = k8_2f(7).*y(192,:)+ k8_3r(7).*y(194,:)- k8_2r(7).*y(193,:).*y(4,:)- k8_3f(7).*y(193,:).*y(10,:);
dy(208,:) = k8_2f(8).*y(207,:)+ k8_3r(8).*y(209,:)- k8_2r(8).*y(208,:).*y(4,:)- k8_3f(8).*y(208,:).*y(10,:);

dy(232,:) = k8_2f(5).*y(231,:)+ k8_3r(5).*y(233,:)- k8_2r(5).*y(232,:).*y(4,:)- k8_3f(5).*y(232,:).*y(10,:);
dy(247,:) = k8_2f(6).*y(246,:)+ k8_3r(6).*y(248,:)- k8_2r(6).*y(247,:).*y(4,:)- k8_3f(6).*y(247,:).*y(10,:);
dy(262,:) = k8_2f(7).*y(261,:)+ k8_3r(7).*y(263,:)- k8_2r(7).*y(262,:).*y(4,:)- k8_3f(7).*y(262,:).*y(10,:);
dy(277,:) = k8_2f(8).*y(276,:)+ k8_3r(8).*y(278,:)- k8_2r(8).*y(277,:).*y(4,:)- k8_3f(8).*y(277,:).*y(10,:);


dy(104,:) =  k8_3f(1).*y(103,:).*y(10,:) - k8_3r(1).*y(104,:) - kcat8(1).*y(104,:);
dy(119,:) =  k8_3f(2).*y(118,:).*y(10,:) - k8_3r(2).*y(119,:) - kcat8(2).*y(119,:);
dy(134,:) =  k8_3f(3).*y(133,:).*y(10,:) - k8_3r(3).*y(134,:) - kcat8(3).*y(134,:);
dy(149,:) = k8_3f(4).*y(148,:).*y(10,:)- k8_3r(4).*y(149,:)- kcat8(4).*y(149,:);
dy(164,:) = k8_3f(5).*y(163,:).*y(10,:)- k8_3r(5).*y(164,:)- kcat8(5).*y(164,:);
dy(179,:) = k8_3f(6).*y(178,:).*y(10,:)- k8_3r(6).*y(179,:)- kcat8(6).*y(179,:);
dy(194,:) = k8_3f(7).*y(193,:).*y(10,:)- k8_3r(7).*y(194,:)- kcat8(7).*y(194,:);
dy(209,:) = k8_3f(8).*y(208,:).*y(10,:)- k8_3r(8).*y(209,:)- kcat8(8).*y(209,:);

dy(233,:) = k8_3f(5).*y(232,:).*y(10,:)- k8_3r(5).*y(233,:)- kcat8_un(5).*y(233,:);
dy(248,:) = k8_3f(6).*y(247,:).*y(10,:)- k8_3r(6).*y(248,:)- kcat8_un(6).*y(248,:);
dy(263,:) = k8_3f(7).*y(262,:).*y(10,:)- k8_3r(7).*y(263,:)- kcat8_un(7).*y(263,:);
dy(278,:) = k8_3f(8).*y(277,:).*y(10,:)- k8_3r(8).*y(278,:)- kcat8_un(8).*y(278,:);


dy(107,:) =  k10_1f(1).*e10.*y(15,:) + k10_2r(1).*y(108,:).*y(4,:) - k10_1r(1).*y(107,:) - k10_2f(1).*y(107,:);
dy(122,:) =  k10_1f(2).*e10.*y(20,:) + k10_2r(2).*y(123,:).*y(4,:) - k10_1r(2).*y(122,:) - k10_2f(2).*y(122,:);
dy(137,:) =  k10_1f(3).*e10.*y(25,:) + k10_2r(3).*y(138,:).*y(4,:) - k10_1r(3).*y(137,:) - k10_2f(3).*y(137,:);
dy(152,:) = k10_1f(4).*e10.*y(30,:)+ k10_2r(4).*y(153,:).*y(4,:)- k10_1r(4).*y(152,:)- k10_2f(4).*y(152,:);
dy(167,:) = k10_1f(5).*e10.*y(36,:)+ k10_2r(5).*y(168,:).*y(4,:)- k10_1r(5).*y(167,:)- k10_2f(5).*y(167,:);
dy(182,:) = k10_1f(6).*e10.*y(46,:)+ k10_2r(6).*y(183,:).*y(4,:)- k10_1r(6).*y(182,:)- k10_2f(6).*y(182,:);
dy(197,:) = k10_1f(7).*e10.*y(56,:)+ k10_2r(7).*y(198,:).*y(4,:)- k10_1r(7).*y(197,:)- k10_2f(7).*y(197,:);
dy(212,:) = k10_1f(8).*e10.*y(66,:)+ k10_2r(8).*y(213,:).*y(4,:)- k10_1r(8).*y(212,:)- k10_2f(8).*y(212,:);

dy(236,:) = k10_1f(5).*e10.*y(41,:)+ k10_2r(5).*y(237,:).*y(4,:)- k10_1r(5).*y(236,:)- k10_2f(5).*y(236,:);
dy(251,:) = k10_1f(6).*e10.*y(51,:)+ k10_2r(6).*y(252,:).*y(4,:)- k10_1r(6).*y(251,:)- k10_2f(6).*y(251,:);
dy(266,:) = k10_1f(7).*e10.*y(61,:)+ k10_2r(7).*y(267,:).*y(4,:)- k10_1r(7).*y(266,:)- k10_2f(7).*y(266,:);
dy(281,:) = k10_1f(8).*e10.*y(71,:)+ k10_2r(8).*y(282,:).*y(4,:)- k10_1r(8).*y(281,:)- k10_2f(8).*y(281,:);


dy(108,:) =  k10_2f(1).*y(107,:) + k10_3r(1).*y(109,:) - k10_2r(1).*y(108,:).*y(4,:) - k10_3f(1).*y(108,:).*y(10,:);
dy(123,:) =  k10_2f(2).*y(122,:) + k10_3r(2).*y(124,:) - k10_2r(2).*y(123,:).*y(4,:) - k10_3f(2).*y(123,:).*y(10,:);
dy(138,:) =  k10_2f(3).*y(137,:) + k10_3r(3).*y(139,:) - k10_2r(3).*y(138,:).*y(4,:) - k10_3f(3).*y(138,:).*y(10,:);
dy(153,:) = k10_2f(4).*y(152,:)+ k10_3r(4).*y(154,:)- k10_2r(4).*y(153,:).*y(4,:)- k10_3f(4).*y(153,:).*y(10,:);
dy(168,:) = k10_2f(5).*y(167,:)+ k10_3r(5).*y(169,:)- k10_2r(5).*y(168,:).*y(4,:)- k10_3f(5).*y(168,:).*y(10,:);
dy(183,:) = k10_2f(6).*y(182,:)+ k10_3r(6).*y(184,:)- k10_2r(6).*y(183,:).*y(4,:)- k10_3f(6).*y(183,:).*y(10,:);
dy(198,:) = k10_2f(7).*y(197,:)+ k10_3r(7).*y(199,:)- k10_2r(7).*y(198,:).*y(4,:)- k10_3f(7).*y(198,:).*y(10,:);
dy(213,:) = k10_2f(8).*y(212,:)+ k10_3r(8).*y(214,:)- k10_2r(8).*y(213,:).*y(4,:)- k10_3f(8).*y(213,:).*y(10,:);

dy(237,:) = k10_2f(5).*y(236,:)+ k10_3r(5).*y(238,:)- k10_2r(5).*y(237,:).*y(4,:)- k10_3f(5).*y(237,:).*y(10,:);
dy(252,:) = k10_2f(6).*y(251,:)+ k10_3r(6).*y(253,:)- k10_2r(6).*y(252,:).*y(4,:)- k10_3f(6).*y(252,:).*y(10,:);
dy(267,:) = k10_2f(7).*y(266,:)+ k10_3r(7).*y(268,:)- k10_2r(7).*y(267,:).*y(4,:)- k10_3f(7).*y(267,:).*y(10,:);
dy(282,:) = k10_2f(8).*y(281,:)+ k10_3r(8).*y(283,:)- k10_2r(8).*y(282,:).*y(4,:)- k10_3f(8).*y(282,:).*y(10,:);


dy(109,:) =  k10_3f(1).*y(108,:).*y(10,:) - k10_3r(1).*y(109,:) - kcat10(1).*y(109,:);
dy(124,:) =  k10_3f(2).*y(123,:).*y(10,:) - k10_3r(2).*y(124,:) - kcat10(2).*y(124,:);
dy(139,:) =  k10_3f(3).*y(138,:).*y(10,:) - k10_3r(3).*y(139,:) - kcat10(3).*y(139,:);
dy(154,:) = k10_3f(4).*y(153,:).*y(10,:)- k10_3r(4).*y(154,:)- kcat10(4).*y(154,:);
dy(169,:) = k10_3f(5).*y(168,:).*y(10,:)- k10_3r(5).*y(169,:)- kcat10(5).*y(169,:);
dy(184,:) = k10_3f(6).*y(183,:).*y(10,:)- k10_3r(6).*y(184,:)- kcat10(6).*y(184,:);
dy(199,:) = k10_3f(7).*y(198,:).*y(10,:)- k10_3r(7).*y(199,:)- kcat10(7).*y(199,:);
dy(214,:) = k10_3f(8).*y(213,:).*y(10,:)- k10_3r(8).*y(214,:)- kcat10(8).*y(214,:);

dy(238,:) = k10_3f(5).*y(237,:).*y(10,:)- k10_3r(5).*y(238,:)- kcat10_un(5).*y(238,:);
dy(253,:) = k10_3f(6).*y(252,:).*y(10,:)- k10_3r(6).*y(253,:)- kcat10_un(6).*y(253,:);
dy(268,:) = k10_3f(7).*y(267,:).*y(10,:)- k10_3r(7).*y(268,:)- kcat10_un(7).*y(268,:);
dy(283,:) = k10_3f(8).*y(282,:).*y(10,:)- k10_3r(8).*y(283,:)- kcat10_un(8).*y(283,:);


dy(302,:) = k10_1f(4).*e10.*y(32,:)+ k10_2r(4).*y(303,:).*y(4,:)- k10_1r(4).*y(302,:)- k10_2f(4).*y(302,:);
dy(303,:) = k10_2f(4).*y(302,:)+ k10_3r(4).*y(304,:)- k10_2r(4).*y(303,:).*y(4,:)- k10_3f(4).*y(303,:).*y(10,:);
dy(304,:) = k10_3f(4).*y(303,:).*y(10,:)- k10_3r(4).*y(304,:)- kcat10_un(4).*y(304,:);


dy(95,:)  = k3_4f(1).*e3.*y(15,:) - k3_4r(1).*y(95,:);
dy(110,:)  = k3_4f(2).*e3.*y(20,:) - k3_4r(2).*y(110,:);
dy(125,:)  = k3_4f(3).*e3.*y(25,:) - k3_4r(3).*y(125,:);
dy(140,:) = k3_4f(4).*e3.*y(30,:)- k3_4r(4).*y(140,:);
dy(155,:) = k3_4f(5).*e3.*y(36,:)- k3_4r(5).*y(155,:);
dy(170,:) = k3_4f(6).*e3.*y(46,:)- k3_4r(6).*y(170,:);
dy(185,:) = k3_4f(7).*e3.*y(56,:)- k3_4r(7).*y(185,:);
dy(200,:) = k3_4f(8).*e3.*y(66,:)- k3_4r(8).*y(200,:);
dy(215,:) = k3_4f(9).*e3.*y(76,:)- k3_4r(9).*y(215,:);

dy(224,:) = k3_4f(5).*e3.*y(41,:)- k3_4r(5).*y(224,:);
dy(239,:) = k3_4f(6).*e3.*y(51,:)- k3_4r(6).*y(239,:);
dy(254,:) = k3_4f(7).*e3.*y(61,:)- k3_4r(7).*y(254,:);
dy(269,:) = k3_4f(8).*e3.*y(71,:)- k3_4r(8).*y(269,:);
dy(284,:) = k3_4f(9).*e3.*y(81,:)- k3_4r(9).*y(284,:);

dy(96,:)  = k3_5f(1).*y(91,:).*y(15,:)  - k3_5r(1).*y(96,:);
dy(111,:)  = k3_5f(2).*y(91,:).*y(20,:)  - k3_5r(2).*y(111,:);
dy(126,:)  = k3_5f(3).*y(91,:).*y(25,:)  - k3_5r(3).*y(126,:);
dy(141,:) = k3_5f(4).*y(91,:).*y(30,:) - k3_5r(4).*y(141,:);
dy(156,:) = k3_5f(5).*y(91,:).*y(36,:) - k3_5r(5).*y(156,:);
dy(171,:) = k3_5f(6).*y(91,:).*y(46,:) - k3_5r(6).*y(171,:);
dy(186,:) = k3_5f(7).*y(91,:).*y(56,:) - k3_5r(7).*y(186,:);
dy(201,:) = k3_5f(8).*y(91,:).*y(66,:) - k3_5r(8).*y(201,:);
dy(216,:) = k3_5f(9).*y(91,:).*y(76,:) - k3_5r(9).*y(216,:);

dy(225,:) = k3_5f(5).*y(91,:).*y(41,:) - k3_5r(5).*y(225,:);
dy(240,:) = k3_5f(6).*y(91,:).*y(51,:) - k3_5r(6).*y(240,:);
dy(255,:) = k3_5f(7).*y(91,:).*y(61,:) - k3_5r(7).*y(255,:);
dy(270,:) = k3_5f(8).*y(91,:).*y(71,:) - k3_5r(8).*y(270,:);
dy(285,:) = k3_5f(9).*y(91,:).*y(81,:) - k3_5r(9).*y(285,:);


% Binding of ACP to TesA
dy(297,:) = k7_inh_f.*e7.*y(4,:) - k7_inh_r.*y(297,:);


% Binding of ACP to FabH FabG FabZ FabI FabF
dy(293,:) = k3_inh_f.*e3.*y(4,:) - k3_inh_r.*y(293,:);
dy(294,:) = k4_inh_f.*e4.*y(4,:) - k4_inh_r.*y(294,:);
dy(295,:) = k5_inh_f.*e5.*y(4,:) - k5_inh_r.*y(295,:);
dy(296,:) = k6_inh_f.*e6.*y(4,:) - k6_inh_r.*y(296,:);
dy(298,:) = k8_inh_f.*e8.*y(4,:) - k8_inh_r.*y(298,:);

% Binding of ACP to FabA FabB
dy(299,:) = k9_inh_f.*e9.*y(4,:) - k9_inh_r.*y(299,:);
dy(300,:) = k10_inh_f.*e10.*y(4,:) - k10_inh_r.*y(300,:);
