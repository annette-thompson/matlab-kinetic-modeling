% Give access to all necessary folders

my_dir = '/Users/Annette/Library/CloudStorage/OneDrive-UCB-O365/Annie Thompson/Git Repository/Matlab Current Projects';
cd(my_dir)
addpath(genpath(my_dir))

%% Variables

% Run variable code
S = set_vars();

% Set ODE solver options
ODE_options = odeset('RelTol',1e-6,'MaxOrder',5,'Vectorized','on');

%% ACC Balance using Michaelis-Menton
% Need to have ran the beginning of the real code

S.labels = {'c_ATP','c_BC_ATP','c_C1_Bicarbonate','c_ADP','c_C1_BC_Pi_HCO3','c_C1_BCCP_Biotin_CO2','c_C1_CT_Act','c_C2_AcCoA','c_C3_MalCoA'};

S.range = [0 150]; %2.5 mins (initial rate)

S.num = length(S.labels); %how many diff eqs there are

% New order from var_name code
S.init_cond = zeros(S.num,1);
S.init_cond(1) = 1000; % ATP
S.init_cond(3) = 1000; % Bicarbonate
S.init_cond(8) = 600; % Acetyl-CoA

% (ACC,FabD,FabH,FabG,FabZ,FabI,TesA,FabF,FabA,FabB)
enz_conc = [1 0 0 0 0 0 0 0 0 0]; 

S.enzyme_conc = enz_conc;

P = Param_Function(S);

P.kcat1_1 = 85.17/60*30; % s^-1 bigger
P.Km1_1 = 170; % uM
P.kcat1_2 = 73.8/60*30; % s^-1 bigger
P.Km1_2 = 370; % uM
P.kcat1_3 = 1000.8/60*30; % s^-1 bigger
P.Km1_3 = 160; % uM
P.kcat1_4 = 2031.8/60*30; % s^-1 bigger
P.Km1_4 = 450; % uM
P.kcat1_5 = 30.1*30; % s^-1
P.Km1_5 = 48.7; % uM

parameterized_ODEs = @(t,c) ODE_Function_ACC(t,c,P);
tic
[T_ACC,C_ACC] = ode15s(parameterized_ODEs,S.range,S.init_cond,ODE_options);
toc
[~, rel_rate_ACC] = Calc_Function(T_ACC,C_ACC,S);

[balance_conc_ACC, balances_ACC, total_conc_ACC, carbon_ACC] = mass_balance(C_ACC,P);

figure()
plot(T_ACC,C_ACC)
legend(S.labels)

function dcdt = ODE_Function_ACC(t,c,P)

% Assign values to each variable
for var = 1:numel(P.labels)
    % Get the variable name
    var_name = P.labels{var};
    
    % Assign the value to the variable in the workspace
    eval([var_name ' = c(var, :);']);
end

% ACC
% BC (AccC)
c_ACC_C = P.ACC_Ctot - c_BC_ATP - c_C1_BC_Pi_HCO3;
% BCCP-Biotin (AccB-Biotin)
c_ACC_B = P.ACC_Btot - c_C1_BCCP_Biotin_CO2;
% CT (AccAD)
c_ACC_AD = P.ACC_ADtot - c_C1_CT_Act;

% Set of differential equations
% ATP
d_ATP = -P.kcat1_1.*c_ACC_C.*c_ATP./(P.Km1_1 + c_ATP);

% BC-ATP
d_BC_ATP = P.kcat1_1.*c_ACC_C.*c_ATP./(P.Km1_1 + c_ATP) - P.kcat1_2.*c_BC_ATP.*c_C1_Bicarbonate./(P.Km1_2 + c_C1_Bicarbonate);

% Bicarbonate
d_C1_Bicarbonate = -P.kcat1_2.*c_BC_ATP.*c_C1_Bicarbonate./(P.Km1_2 + c_C1_Bicarbonate);

% ADP
d_ADP = P.kcat1_2.*c_BC_ATP.*c_C1_Bicarbonate./(P.Km1_2 + c_C1_Bicarbonate);

% BC-Pi-HCO3
d_C1_BC_Pi_HCO3 = P.kcat1_2.*c_BC_ATP.*c_C1_Bicarbonate./(P.Km1_2 + c_C1_Bicarbonate) - P.kcat1_3.*c_ACC_B.*c_C1_BC_Pi_HCO3./(P.Km1_3 + c_C1_BC_Pi_HCO3);

% BCCP-Biotin-CO2
d_C1_BCCP_Biotin_CO2 = P.kcat1_3.*c_ACC_B.*c_C1_BC_Pi_HCO3./(P.Km1_3 + c_C1_BC_Pi_HCO3) - P.kcat1_4.*c_ACC_AD.*c_C1_BCCP_Biotin_CO2./(P.Km1_4 + c_C1_BCCP_Biotin_CO2);

% CT*
d_C1_CT_Act = P.kcat1_4.*c_ACC_AD.*c_C1_BCCP_Biotin_CO2./(P.Km1_4 + c_C1_BCCP_Biotin_CO2) - P.kcat1_5.*c_C1_CT_Act.*c_C2_AcCoA./(P.Km1_5 + c_C2_AcCoA);

% Acetyl-CoA
d_C2_AcCoA = -P.kcat1_5.*c_C1_CT_Act.*c_C2_AcCoA./(P.Km1_5 + c_C2_AcCoA);

% Malonyl-CoA
d_C3_MalCoA = P.kcat1_5.*c_C1_CT_Act.*c_C2_AcCoA./(P.Km1_5 + c_C2_AcCoA); 

dcdt = [d_ATP;d_BC_ATP;d_C1_Bicarbonate;d_ADP;d_C1_BC_Pi_HCO3;d_C1_BCCP_Biotin_CO2;d_C1_CT_Act;d_C2_AcCoA;d_C3_MalCoA];

end
