% Carbon Balance for number hard coded code
function [Carbon, total_carbon] = Carbon_Balance(T,C)

% I found the order list by taking the ODE_Function code find and replacing
% to just have a list of the dy(numbers) in order

% This is the order of differential equations in the ODE function
% I need this for now because the concentrations are tied to the hard-coded
% numbers but the variable list is in the order of listed differential
% equations 
order = [1, 2, 3, 316, 317, 318, 319, 320, 321, 322, 323, 4, 5, 6, 7, 8, 9, 10, 11, 12, 17, 22,...
    27, 33, 43, 53, 63, 73, 38, 48, 58, 68, 78, 13, 18, 23, 28, 34, 44, 54, 64, 74, 39, 49, 59,...
    69, 79, 14, 19, 24, 29, 35, 45, 55, 65, 75, 32, 40, 50, 60, 70, 80, 15, 20, 25, 30, 36, 46,...
    56, 66, 76, 41, 51, 61, 71, 81, 16, 21, 26, 31, 37, 47, 57, 67, 77, 42, 52, 62, 72, 82, 83,...
    84, 85, 86, 87, 88, 89, 90, 324, 325, 326, 327, 328, 329, 330, 331, 91, 332, 333, 334,...
    335, 336, 337, 338, 339, 92, 340, 341, 342, 343, 344, 345, 346, 347, 93, 97, 112, 127,...
    142, 157, 172, 187, 202, 217, 226, 241, 256, 271, 286, 98, 113, 128, 143, 158, 173, 188,...
    203, 218, 227, 242, 257, 272, 287, 99, 114, 129, 144, 159, 174, 189, 204, 219, 228, 243,...
    258, 273, 288, 105, 120, 135, 150, 165, 180, 195, 210, 222, 234, 249, 264, 279, 291,...
    106, 121, 136, 151, 166, 181, 196, 211, 223, 301, 235, 250, 265, 280, 292, 94, 100, 115,...
    130, 145, 160, 175, 190, 205, 220, 229, 244, 259, 274, 289, 101, 116, 131, 146, 161,...
    176, 191, 206, 221, 230, 245, 260, 275, 290, 102, 117, 132, 147, 162, 177, 192, 207,...
    231, 246, 261, 276, 103, 118, 133, 148, 163, 178, 193, 208, 232, 247, 262, 277, 104,...
    119, 134, 149, 164, 179, 194, 209, 233, 248, 263, 278, 107, 122, 137, 152, 167, 182,...
    197, 212, 236, 251, 266, 281, 108, 123, 138, 153, 168, 183, 198, 213, 237, 252, 267,...
    282, 109, 124, 139, 154, 169, 184, 199, 214, 238, 253, 268, 283, 302, 303, 304, 95, 110,...
    125, 140, 155, 170, 185, 200, 215, 224, 239, 254, 269, 284, 96, 111, 126, 141, 156, 171,...
    186, 201, 216, 225, 240, 255, 270, 285, 297, 293, 294, 295, 296, 298, 299, 300, 305,...
    306, 307, 308, 309, 310, 311, 312, 313, 314, 315];

% This is the name of the species in the ODE function in the order their equations are listed
conc = {'c_ATP', 'c_C1_Bicarbonate', 'c_C2_AcCoA', 'c_C4_SucCoA', 'c_C6_HexCoA', 'c_C8_OcCoA', 'c_C10_DecCoA', 'c_C12_LauCoA', 'c_C14_EthCoA', 'c_C16_PalCoA', 'c_C18_OcDecCoA', 'c_ACP', 'c_NADPH', 'c_NADH', 'c_ADP',...
    'c_C3_MalCoA', 'c_CoA', 'c_MalACP', 'c_C1_CO2', 'c_C4_BKeACP', 'c_C6_BKeACP', 'c_C8_BKeACP', 'c_C10_BKeACP', 'c_C12_BKeACP', 'c_C14_BKeACP', 'c_C16_BKeACP', 'c_C18_BKeACP',...
    'c_C20_BKeACP', 'c_C12_BKeACP_un', 'c_C14_BKeACP_un', 'c_C16_BKeACP_un', 'c_C18_BKeACP_un', 'c_C20_BKeACP_un', 'c_C4_BHyAcACP', 'c_C6_BHyAcACP', 'c_C8_BHyAcACP',...
    'c_C10_BHyAcACP', 'c_C12_BHyAcACP', 'c_C14_BHyAcACP', 'c_C16_BHyAcACP', 'c_C18_BHyAcACP', 'c_C20_BHyAcACP', 'c_C12_BHyAcACP_un', 'c_C14_BHyAcACP_un',...
    'c_C16_BHyAcACP_un', 'c_C18_BHyAcACP_un', 'c_C20_BHyAcACP_un', 'c_C4_EnAcACP', 'c_C6_EnAcACP', 'c_C8_EnAcACP', 'c_C10_EnAcACP', 'c_C12_EnAcACP', 'c_C14_EnAcACP',...
    'c_C16_EnAcACP', 'c_C18_EnAcACP', 'c_C20_EnAcACP', 'c_C10_cis3EnAcACP', 'c_C12_EnAcACP_un', 'c_C14_EnAcACP_un', 'c_C16_EnAcACP_un', 'c_C18_EnAcACP_un',...
    'c_C20_EnAcACP_un', 'c_C4_AcACP', 'c_C6_AcACP', 'c_C8_AcACP', 'c_C10_AcACP', 'c_C12_AcACP', 'c_C14_AcACP', 'c_C16_AcACP', 'c_C18_AcACP', 'c_C20_AcACP',...
    'c_C12_AcACP_un', 'c_C14_AcACP_un', 'c_C16_AcACP_un', 'c_C18_AcACP_un', 'c_C20_AcACP_un', 'c_C4_FA', 'c_C6_FA', 'c_C8_FA', 'c_C10_FA', 'c_C12_FA', 'c_C14_FA',...
    'c_C16_FA', 'c_C18_FA', 'c_C20_FA', 'c_C12_FA_un', 'c_C14_FA_un', 'c_C16_FA_un', 'c_C18_FA_un', 'c_C20_FA_un', 'c_ACC_s1', 'c_C1_ACC_s2', 'c_C1_ACC_s3', 'c_C3_ACC_s4', 'c_C3_FabD_MalCoA',...
    'c_C3_FabD_Act', 'c_C3_FabD_Act_ACP', 'c_C2_FabH_CoA', 'c_C4_FabH_CoA', 'c_C6_FabH_CoA', 'c_C8_FabH_CoA', 'c_C10_FabH_CoA', 'c_C12_FabH_CoA', 'c_C14_FabH_CoA',...
    'c_C16_FabH_CoA', 'c_C18_FabH_CoA', 'c_C2_FabH_Act', 'c_C4_FabH_Act', 'c_C6_FabH_Act', 'c_C8_FabH_Act', 'c_C10_FabH_Act', 'c_C12_FabH_Act', 'c_C14_FabH_Act',...
    'c_C16_FabH_Act', 'c_C18_FabH_Act', 'c_C2_FabH_Act_MalACP', 'c_C4_FabH_Act_MalACP', 'c_C6_FabH_Act_MalACP', 'c_C8_FabH_Act_MalACP', 'c_C10_FabH_Act_MalACP',...
    'c_C12_FabH_Act_MalACP', 'c_C14_FabH_Act_MalACP', 'c_C16_FabH_Act_MalACP', 'c_C18_FabH_Act_MalACP', 'c_FabG_NADPH', 'c_C4_FabG_NADPH_BKeACP',...
    'c_C6_FabG_NADPH_BKeACP', 'c_C8_FabG_NADPH_BKeACP', 'c_C10_FabG_NADPH_BKeACP', 'c_C12_FabG_NADPH_BKeACP', 'c_C14_FabG_NADPH_BKeACP',...
    'c_C16_FabG_NADPH_BKeACP', 'c_C18_FabG_NADPH_BKeACP', 'c_C20_FabG_NADPH_BKeACP', 'c_C12_FabG_NADPH_BKeACP_un', 'c_C14_FabG_NADPH_BKeACP_un',...
    'c_C16_FabG_NADPH_BKeACP_un', 'c_C18_FabG_NADPH_BKeACP_un', 'c_C20_FabG_NADPH_BKeACP_un', 'c_C4_FabZ_BHyAcACP', 'c_C6_FabZ_BHyAcACP',...
    'c_C8_FabZ_BHyAcACP', 'c_C10_FabZ_BHyAcACP', 'c_C12_FabZ_BHyAcACP', 'c_C14_FabZ_BHyAcACP', 'c_C16_FabZ_BHyAcACP', 'c_C18_FabZ_BHyAcACP',...
    'c_C20_FabZ_BHyAcACP', 'c_C12_FabZ_BHyAcACP_un', 'c_C14_FabZ_BHyAcACP_un', 'c_C16_FabZ_BHyAcACP_un', 'c_C18_FabZ_BHyAcACP_un', 'c_C20_FabZ_BHyAcACP_un',...
    'c_C4_FabZ_EnAcACP', 'c_C6_FabZ_EnAcACP', 'c_C8_FabZ_EnAcACP', 'c_C10_FabZ_EnAcACP', 'c_C12_FabZ_EnAcACP', 'c_C14_FabZ_EnAcACP', 'c_C16_FabZ_EnAcACP',...
    'c_C18_FabZ_EnAcACP', 'c_C20_FabZ_EnAcACP', 'c_C12_FabZ_EnAcACP_un', 'c_C14_FabZ_EnAcACP_un', 'c_C16_FabZ_EnAcACP_un', 'c_C18_FabZ_EnAcACP_un',...
    'c_C20_FabZ_EnAcACP_un', 'c_C4_FabA_BHyAcACP', 'c_C6_FabA_BHyAcACP', 'c_C8_FabA_BHyAcACP', 'c_C10_FabA_BHyAcACP', 'c_C12_FabA_BHyAcACP',...
    'c_C14_FabA_BHyAcACP', 'c_C16_FabA_BHyAcACP', 'c_C18_FabA_BHyAcACP', 'c_C20_FabA_BHyAcACP', 'c_C12_FabA_BHyAcACP_un', 'c_C14_FabA_BHyAcACP_un',...
    'c_C16_FabA_BHyAcACP_un', 'c_C18_FabA_BHyAcACP_un', 'c_C20_FabA_BHyAcACP_un', 'c_C4_FabA_EnAcACP', 'c_C6_FabA_EnAcACP', 'c_C8_FabA_EnAcACP', 'c_C10_FabA_EnAcACP',...
    'c_C12_FabA_EnAcACP', 'c_C14_FabA_EnAcACP', 'c_C16_FabA_EnAcACP', 'c_C18_FabA_EnAcACP', 'c_C20_FabA_EnAcACP', 'c_C10_FabA_cis3EnAcACP', 'c_C12_FabA_EnAcACP_un',...
    'c_C14_FabA_EnAcACP_un', 'c_C16_FabA_EnAcACP_un', 'c_C18_FabA_EnAcACP_un', 'c_C20_FabA_EnAcACP_un', 'c_FabI_NADH', 'c_C4_FabI_NADH_EnAcACP',...
    'c_C6_FabI_NADH_EnAcACP', 'c_C8_FabI_NADH_EnAcACP', 'c_C10_FabI_NADH_EnAcACP', 'c_C12_FabI_NADH_EnAcACP', 'c_C14_FabI_NADH_EnAcACP',...
    'c_C16_FabI_NADH_EnAcACP', 'c_C18_FabI_NADH_EnAcACP', 'c_C20_FabI_NADH_EnAcACP', 'c_C12_FabI_NADH_EnAcACP_un', 'c_C14_FabI_NADH_EnAcACP_un',...
    'c_C16_FabI_NADH_EnAcACP_un', 'c_C18_FabI_NADH_EnAcACP_un', 'c_C20_FabI_NADH_EnAcACP_un', 'c_C4_TesA_AcACP', 'c_C6_TesA_AcACP', 'c_C8_TesA_AcACP',...
    'c_C10_TesA_AcACP', 'c_C12_TesA_AcACP', 'c_C14_TesA_AcACP', 'c_C16_TesA_AcACP', 'c_C18_TesA_AcACP', 'c_C20_TesA_AcACP', 'c_C12_TesA_AcACP_un', 'c_C14_TesA_AcACP_un',...
    'c_C16_TesA_AcACP_un', 'c_C18_TesA_AcACP_un', 'c_C20_TesA_AcACP_un', 'c_C4_FabF_AcACP', 'c_C6_FabF_AcACP', 'c_C8_FabF_AcACP', 'c_C10_FabF_AcACP',...
    'c_C12_FabF_AcACP', 'c_C14_FabF_AcACP', 'c_C16_FabF_AcACP', 'c_C18_FabF_AcACP', 'c_C12_FabF_AcACP_un', 'c_C14_FabF_AcACP_un', 'c_C16_FabF_AcACP_un',...
    'c_C18_FabF_AcACP_un', 'c_C4_FabF_Act', 'c_C6_FabF_Act', 'c_C8_FabF_Act', 'c_C10_FabF_Act', 'c_C12_FabF_Act', 'c_C14_FabF_Act', 'c_C16_FabF_Act', 'c_C18_FabF_Act',...
    'c_C12_FabF_Act_un', 'c_C14_FabF_Act_un', 'c_C16_FabF_Act_un', 'c_C18_FabF_Act_un', 'c_C4_FabF_Act_MalACP', 'c_C6_FabF_Act_MalACP', 'c_C8_FabF_Act_MalACP',...
    'c_C10_FabF_Act_MalACP', 'c_C12_FabF_Act_MalACP', 'c_C14_FabF_Act_MalACP', 'c_C16_FabF_Act_MalACP', 'c_C18_FabF_Act_MalACP', 'c_C12_FabF_Act_MalACP_un',...
    'c_C14_FabF_Act_MalACP_un', 'c_C16_FabF_Act_MalACP_un', 'c_C18_FabF_Act_MalACP_un', 'c_C4_FabB_AcACP', 'c_C6_FabB_AcACP', 'c_C8_FabB_AcACP', 'c_C10_FabB_AcACP',...
    'c_C12_FabB_AcACP', 'c_C14_FabB_AcACP', 'c_C16_FabB_AcACP', 'c_C18_FabB_AcACP', 'c_C12_FabB_AcACP_un', 'c_C14_FabB_AcACP_un', 'c_C16_FabB_AcACP_un',...
    'c_C18_FabB_AcACP_un', 'c_C4_FabB_Act', 'c_C6_FabB_Act', 'c_C8_FabB_Act', 'c_C10_FabB_Act', 'c_C12_FabB_Act', 'c_C14_FabB_Act', 'c_C16_FabB_Act', 'c_C18_FabB_Act',...
    'c_C12_FabB_Act_un', 'c_C14_FabB_Act_un', 'c_C16_FabB_Act_un', 'c_C18_FabB_Act_un', 'c_C4_FabB_Act_MalACP', 'c_C6_FabB_Act_MalACP', 'c_C8_FabB_Act_MalACP',...
    'c_C10_FabB_Act_MalACP', 'c_C12_FabB_Act_MalACP', 'c_C14_FabB_Act_MalACP', 'c_C16_FabB_Act_MalACP', 'c_C18_FabB_Act_MalACP', 'c_C12_FabB_Act_MalACP_un',...
    'c_C14_FabB_Act_MalACP_un', 'c_C16_FabB_Act_MalACP_un', 'c_C18_FabB_Act_MalACP_un', 'c_C10_FabB_cis3EnAcACP', 'c_C10_FabB_Act_cis3', 'c_C10_FabB_Act_cis3MalACP',...
    'c_C4_FabH_AcACP', 'c_C6_FabH_AcACP', 'c_C8_FabH_AcACP', 'c_C10_FabH_AcACP', 'c_C12_FabH_AcACP', 'c_C14_FabH_AcACP', 'c_C16_FabH_AcACP', 'c_C18_FabH_AcACP',...
    'c_C20_FabH_AcACP', 'c_C12_FabH_AcACP_un', 'c_C14_FabH_AcACP_un', 'c_C16_FabH_AcACP_un', 'c_C18_FabH_AcACP_un', 'c_C20_FabH_AcACP_un', 'c_C4_FabH_Act_AcACP',...
    'c_C6_FabH_Act_AcACP', 'c_C8_FabH_Act_AcACP', 'c_C10_FabH_Act_AcACP', 'c_C12_FabH_Act_AcACP', 'c_C14_FabH_Act_AcACP', 'c_C16_FabH_Act_AcACP', 'c_C18_FabH_Act_AcACP',...
    'c_C20_FabH_Act_AcACP', 'c_C12_FabH_Act_AcACP_un', 'c_C14_FabH_Act_AcACP_un', 'c_C16_FabH_Act_AcACP_un', 'c_C18_FabH_Act_AcACP_un', 'c_C20_FabH_Act_AcACP_un',...
    'c_TesA_ACP', 'c_FabH_ACP', 'c_FabG_ACP', 'c_FabZ_ACP', 'c_FabI_ACP', 'c_FabF_ACP', 'c_FabA_ACP', 'c_FabB_ACP', 'c_C2_FabB_AcCoA', 'c_C2_FabB_Act', 'c_C5_FabB_Act_MalACP', 'c_C2_FabF_AcCoA',...
    'c_C2_FabF_Act', 'c_C2_FabF_Act_MalACP', 'c_C3_FabB_MalACP', 'c_C2_AcACP', 'c_C2_FabB_AcACP', 'c_C3_FabF_MalACP', 'c_C2_FabF_AcACP'};

% Find all species with carbon
carbon_conc = {};
for i = 1:numel(conc)
    % Check for carbon
    matches = regexp(conc{i}, 'c_C(\d+)_.*', 'match');
    % If there is a match, add the element to carbon_conc
    if ~isempty(matches)
        carbon_conc = [carbon_conc, matches];
    end
end

% Find length of carbon
carbon_length = [];
for i = 1:numel(carbon_conc)
    % Find length from name
    match = regexp(carbon_conc{i}, 'c_C(\d+)_', 'tokens');
    number = str2double(match{1}{1});
    carbon_length = [carbon_length, number];
end

% Get differential equation number from carbon name in list
carbon_index = zeros(1,numel(carbon_length));
for j=1:numel(carbon_conc)
    carbon_index(j) = order(strcmp(conc, carbon_conc{j}));
end

% Calculates change in carbon for each run
Carbon = 0;
for j = 1:numel(carbon_index)
        carbon_change = C(end,carbon_index(j)) - C(1,carbon_index(j));
        Carbon = Carbon + carbon_change*carbon_length(j);
end

% Calculates total carbon at each time point
total_carbon = zeros(1,numel(C(:,1)));
for j=1:numel(C(:,1))
        sum=0;
        for i=1:numel(carbon_index)
            sum = sum +C(j,carbon_index(i))*carbon_length(i);
        end
        total_carbon(j)=sum;
end

figure()
plot(T,total_carbon)
xlabel('Time (sec)')
ylabel('Concentration (uM)')
title('Carbon Concentration vs Time')
axis('padded')

figure()
num_species = 10;
var_start = 1;
var_end = var_start+num_species-1;
legend_names = cell(num_species+1, 1);
for i=var_start:var_end
    j = i-var_start+1;
    legend_names{j} = conc{carbon_index(i)};
    legend_names{j} = legend_names{j}(3:end);
    legend_names{j} = strrep(legend_names{j}, '_', ' ');
    plot(T,C(:,carbon_index(i))*carbon_length(i));
    hold on
end

plot(T,total_carbon,'k')
xlabel('Time (sec)')
ylabel('Concentration (uM)')
legend_names{end} = 'Total Carbon';
legend(legend_names,'Location','bestoutside')