%Plot of profiles

p_vec = [130157.368705725,4812.72121015092,3.46221047687037,17051.6934979162,924.433870278525,0.0525778925170454,2.66701424433824,0.00349275110661883,0.293814247545723,-0.313775721113438,2.66655052022994,0.271673954221911,148.204532874920,1267.69556520898,1.7959,0.1244,0.0384,0.0116];

init_cond1 = zeros(336,1);
init_cond1(3) = 300;%s3 (Acetyl-CoA)
init_cond1(4) = 10;%s6 (holo ACP)
init_cond1(5) = 1300;%s7 (NADPH)
init_cond1(6) = 1300;%s8 (NADH)
init_cond1(8) = 1500;%p2 (malonyl-CoA)
compart=1E-3*6.7e-16;
init_cond1(309) = 9.61452e-19/compart;%s3 (FtsH)
init_cond1(310) = 6.39307e-19/compart;%s6 (LpxC)
init_cond1(311) = 2.54062e-19/compart;%s8 (KdtA)
init_cond2 = zeros(336,1);
init_cond2(3) = 100;%s3 (Acetyl-CoA)
init_cond2(4) = 10;%s6 (holo ACP)
init_cond2(5) = 650;%s7 (NADPH)
init_cond2(6) = 650;%s8 (NADH)
init_cond2(8) = 500;%p2 (malonyl-CoA)
compart=1E-3*6.7e-16;
init_cond2(309) = 9.61452e-19/compart;%s3 (FtsH)
init_cond2(310) = 6.39307e-19/compart;%s6 (LpxC)
init_cond2(311) = 2.54062e-19/compart;%s8 (KdtA)
init_cond3 = zeros(336,1);
init_cond3(3) = 100;%s3 (Acetyl-CoA)
init_cond3(4) = 10;%s6 (holo ACP)
init_cond3(5) = 650;%s7 (NADPH)
init_cond3(6) = 650;%s8 (NADH)
init_cond3(8) = 500;%p2 (malonyl-CoA)
compart=1E-3*6.7e-16;
init_cond3(309) = 9.61452e-19/compart;%s3 (FtsH)
init_cond3(310) = 6.39307e-19/compart;%s6 (LpxC)
init_cond3(311) = 2.54062e-19/compart;%s8 (KdtA)


% init_condref = zeros(336,1);
% init_condref(3) = 500;%s3 (Acetyl-CoA)
% init_condref(4) = 10;%s6 (holo ACP)
% init_condref(5) = 1000;%s7 (NADPH)
% init_condref(6) = 1000;%s8 (NADH)
% init_condref(8) = 500;%p2 (malonyl-CoA) %%CHECK THESE
% compart=1E-3*6.7e-16;
% init_condref(309) = 9.61452e-19/compart;%s3 (FtsH)
% init_condref(310) = 6.39307e-19/compart;%s6 (LpxC)
% init_condref(311) = 2.54062e-19/compart;%s8 (KdtA)

time_range1 = [0 3600]; % 1 hr
%enz_conc1(1,:) = [0  1    1    1    1    1    10   0.1    1    0];
enz_conc1(1,:) = [0  1    1    1    1    1    0.1  10     1    0];
%enz_conc1(3,:) = [0  1    10   1    1    1    10   0.1    1    0];
%enz_conc1(4,:) = [0  1    10   1    1    1    0.1  10     1    0];
%enz_conc1(5,:) = [0  1    1    1    1    1    10   0.1    1    1];
%enz_conc1(6,:) = [0  1    1    1    1    1    0.1  10     1    1];
enz_conc1(2,:) = [0  1    10   1    1    1    10   0.1    1    1];
%enz_conc1(4,:) = [0  1    10   1    1    1    0.1  10     1    1];
%enz_conc1(5,:) = [0  1    1    1    1    1    10   1      1    0];
%enz_conc1(6,:) =[0  1    1    1    1    1    10   1      1    1];
%exp1(1,:) = [0 2.168486017 24.39594036 7.90387355 17.41622867 3.039333788 0.689964308 0 0 0 0 0.726819949 0 0];
exp1(1,:) = [0 0 0 0 1.494924162 0.090608913 3.791664462 0.169429445 0.964545567 0.471425038 0 23.03313483 0 0];
%exp1(3,:) = [16.92426167 54.65381843 64.63058567 9.407122053 6.345893864 1.511914835 0.613137699 0 1.289343669 0.454747483 0.849199473 1.822479584 0 0];
%exp1(4,:) = [0.891846414 0 1.025978231 2.07691023 9.400966407 6.099182024 5.81258534 4.475121857 0.989693554 6.461007329 0.809499105 15.2593983 0 0];
%exp1(5,:) = [2.657489573 1.897445627 5.541502644 0.688299411 3.560745231 23.0398156 2.075321957 15.24074366 3.435862659 32.12663655 3.241741695 4.09786886 0 0];
%exp1(6,:) = [3.556597128 0 0.097590051 0.43928286 1.778681705 0.40015387 1.952643874 0 2.873318978 1.328774246 2.390143516 37.54845012 0 0];
exp1(2,:) = [7.713106927 9.565592906 20.91100715 3.763357605 4.854988007 33.1822702 0.913651805 15.64168686 0 9.106442357 0 1.45965174 0 0];
%exp1(4,:) = [0 0.69317392 2.01515014 2.331918971 8.750358592 9.78128212 3.521249447 8.154846576 1.784788575 10.09995169 0.758838091 18.25192434 0 0];
%exp1(5,:) = [0 4.662101399 14.32520268 1.294387599 12.50759041 13.56107719 3.887120611 10.76863764 0.448629624 15.02999584 0.095868038 2.849149515 0 0];
%exp1(6,:) = [0 1.794417407 8.496798352 0.880335356 2.327168884 16.31107212 1.659048189 12.52292947 3.40233702 22.85247058 2.755947152 3.362791504 0 0];

dist_FA_norm = zeros(1,14);
figure()
for j = 1:2
    [~,~,~,dist_FA,~,~] = CPS_Base_opt_solv(p_vec,init_cond1,enz_conc1(j,:),time_range1);
    subplot(2,2,j)
    bar_labels = {'4','6','8','10','12','12:1','14','14:1','16','16:1','18','18:1','20','20:1'};
    dist_FA_norm = dist_FA./sum(dist_FA)*sum(exp1(j,:));
    bar([exp1(j,:);dist_FA_norm]')
    set(gca,'XTick',1:length(bar_labels),'XTickLabel',bar_labels);
    legend('exp','model','Location','best')
    ylabel('Concentration (\muM)')
    if j == 1
        xlabel('H1 T0.1 F10 B0')
    else
        xlabel('H10  T10 F0.1 B1')
    end
end

%Plot of Time rate of change
%runs solver
enz_conc2 = [0 1 1 1 1 1 10 1 1 1];
time_range2 = [0 900]; %15 mins
warning('off','all')
validation_data = readtable('palm_v_time.csv','ReadRowNames',false);
plot_data = readtable('Katie PNAS 4A.csv','ReadRowNames',false);
warning('on','all')
time_data = validation_data.Time_min_;
conc_data = validation_data.Concentration_uM_;
time_plot = plot_data.Time_min_;
conc_plot = plot_data.Concentration_uM_;
[~,F_weighted,~,~,T,~] = CPS_Base_opt_solv(p_vec,init_cond2,enz_conc2,time_range2);

subplot(2,2,3)
hold on
plot(T/60,F_weighted,'Color','black','LineWidth',1.5)
plot(time_plot,conc_plot,'Color','red','LineWidth',1.5)
plot(time_data,conc_data,'LineStyle','none','Marker','o','MarkerSize',7.5,'Color','black')
legend('model','exp')
xlabel('Time (min)')
ylabel('Palmitic Equiv (\muM)')
hold off

%Plot initial Rates
enz_conc3 = zeros(8,10);
time_range3 = [0 150]; %2.5 mins
model_rate = zeros(1,8);
%No Fab Data
%enz_conc3(1,:) = [0 1 1 1 1 1 10 1 1 1];
%enz_conc3(2,:) = [0 1 0 1 1 1 10 1 1 1];
enz_conc3(1,:) = [0 1 0 1 1 1 10 0 1 1];
enz_conc3(2,:) = [0 1 0 1 1 1 10 1 1 0];
enz_conc3(3,:) = [0 1 0 1 1 1 10 1 1 1];
enz_conc3(4,:) = [0 1 0 1 1 1 10 0 1 1];
%enz_conc3(7,:) = [0 1 0 1 1 1 10 1 1 0];
%PNAS Data (4B)
%enz_conc3(8,:) = [0 1 1 1 1 1 10 1 1 1];
enz_conc3(5,:) = [0 1 30 1 1 1 10 1 1 1];
enz_conc3(6,:) = [0 1 1 1 1 1 10 10 1 1];
enz_conc3(7,:) = [0 1 1 1 1 10 10 1 1 1];
%enz_conc3(12,:) = [0 1 1 1 0 1 10 1 1 1];
enz_conc3(8,:) = [0 1 1 1 0 1 10 1 10 1];

%exp_rate = [4.655129552 2.41772584 1.796165966 2.976304272 2.91667542 0.893110994 2.428676471 3.93 9.99 2.27 5.38 0.84 2.55];
exp_rate = [                       1.796165966 2.976304272 2.91667542 0.893110994                  9.99 2.27 5.38      2.55];
for i = 1:8
    if i <= 2 
        init_cond3(3) = 500; %AcCoA
    elseif i >= 3 && i <=4
        init_cond3(3) = 0;
    else
        init_cond3(3) = 100;
    end
    [~,F_weighted,~,~,~,~] = CPS_Base_opt_solv(p_vec,init_cond3,enz_conc3(i,:),time_range3);
    model_rate(i) = F_weighted(end)/150*60;
end  
subplot(2,2,4)
bar([exp_rate;model_rate]')
ylabel('Initial Rate (\muM C16/min)')
legend('exp','model')
hold off



%% Intermediates of Initiation Reactions:
figure()
[~,~,~,~,T,C] = CPS_Base_opt_solv(p_vec,init_cond2,enz_conc2,time_range2);
subplot(1,2,1)
plot(T,C(:,326:331))
legend('aACP','FabF.mACP','FabF.aACP','FabF*','FabF.aCoA','FabF*.mACP')
axis([0 900 0 1])
xlabel('Time (s)')
ylabel('Concentration (\muM)')
subplot(1,2,2)
plot(T,C(:,332:336))
legend('FabB.mACP','FabB.aACP','FabB*','FabB.aCoA','FabB*.mACP')
axis([0 900 0 1])
xlabel('Time (s)')
ylabel('Concentration (\muM)')