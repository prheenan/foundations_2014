

%%%%%%%% first, generate x (cencentrations) from the end of hour 0 simulation

% inhibitor constant for EGF inhibitor = 0.0001 or lower

%instructions for changing inhibitor target (need to automate this soon):
   % #1, change the stoichiometry in ode_fun_v2.m (forgot this in the past)
   % #2, change the stoichiometry in the excel file model values simple
   % #3, change plot titles at the bottom of this file
   
%note: can't increase concentration of inhibitor above 100, or else get
%negative concentrations

%note: can't increase inhibition rate above certain amount, around .1 ish,
%or else get negative concentrations

%calling load excel script
LoadExcel_v2_11092014

%initial concentrations
actEGF = 100;
EGFR = 100;
actEGF_EGFR = 0;
SOS	= 100;
actSOS = 0;
RAS	= 100;
actRAS = 0;
RAF	= 100;
actRAF = 0;
MEK	= 100;
actMEK = 0;
ERK	= 100;
actERK = 0;
ERK_SOS = 0;
ERK_RAF = 0;
actTACE = 0; %need some to start with, or else EGF not cleaved
EGF = 0;
TGFa = 100;
actTGFa = 0;
actTGFa_EGFR = 0;
TACE = 100;
Inhib = 0;
x = [actEGF	EGFR	actEGF_EGFR	SOS	actSOS	RAS	actRAS	RAF	actRAF	MEK	actMEK	ERK	actERK	ERK_SOS	ERK_RAF	actTACE	EGF	TGFa	actTGFa	actTGFa_EGFR    TACE    Inhib];

%Running simulation
steps = 3000; %number of reps in simulation
no_inhib = zeros(steps,length(x)); 
times = zeros(1, steps);
new_data = x;
no_inhib(1, :) = x;
times(1) = 1;
for i=2:steps;
    change = ode_fun_v2_11092014(new_data, s, w, exp);
    new_data = new_data + change;
 %   new_data2 = max(new_data, 0); %setting negatives to 0
%    stored_data(i, :) = new_data2;
    no_inhib(i, :) = new_data;
    times(i) = i;
end;




%%%%%%%%%%%%%%%%%%%%%%%%%%% now simulate starting at hour 6, no inhib

%initial concentrations
    % this new_data should be taken from the FIRST HALF of the 0 hour
old_data = new_data;
x = old_data;

%Running simulation (from equilibrium, and no inhibitor)
steps = 3000; %number of reps in simulation
no_inhib = zeros(steps,length(x)); 
times = zeros(1, steps);
new_data = x;
no_inhib(1, :) = x;
times(1) = 1;
for i=2:steps;
    change = ode_fun_v2_11092014(new_data, s, w, exp);
    new_data = new_data + change;
 %   new_data2 = max(new_data, 0); %setting negatives to 0
%    stored_data(i, :) = new_data2;
    no_inhib(i, :) = new_data;
    times(i) = i;
end;
%     concentration vs time plot; uniform line, because at equilibrium
% figure;
% plot(times, no_inhib(:,1), times, no_inhib(:,13) );
% set(gca,'XScale','log');
% ylabel('Concentration (Molecules)');
% xlabel('Iteration #');
% legend('active EGF', 'active ERK');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for 100 different concentrations of inhibitor, simulation

%up to time:
steps = 3000;

%storing data:
my_data = zeros(100, steps, 22);

%simulation
for inhib=1:100 % for 100 different concentrations of inhibitor
    %initial concentrations from end of hour 0 simulation
    x = old_data;
    %setting inhib concentration added
    Inhib = inhib; %don't add more than 100 inhibitor, or else get negative EGF
    x(22) = Inhib;
    %storing data for plots here
    stored_data = zeros(steps,length(x)); %update with number of different molecules 
    times = zeros(1, steps);
    new_data = x;
    for i=1:steps %time up to 3000
        change = ode_fun_v2_11092014(new_data, s, w, exp);
        new_data = new_data + change;
        stored_data(i, :) = new_data;
        times(i) = i;        
    end
    my_data(inhib,:,:) = stored_data;
    inhib
end

%getting IC50s. 
IC50s = zeros(steps, 1);
for i=1:steps
    IC50_at_this_time = 0;
    for inhib=1:100
        concentrations(inhib) = inhib; %just getting concentrations for plotting
        actERK = no_inhib(i,13);
        half = actERK/2;
        %now, want the concentration of inhibitor to bring act ERK below
        %"half"
        inhib_ERK = my_data(inhib, i, 13);
        if IC50_at_this_time == 0;       
            if inhib_ERK <= half;
                IC50_at_this_time = inhib;
            end
        end
    end
    IC50s(i) = IC50_at_this_time;
end

figure;
subplot(2,1,1);
plot(times, my_data(50, :, 13), 'r.', times, my_data(50, :, 1), 'b.' );
set(gca,'XScale','log');
ylabel('Concentration (Molecules)');
xlabel('Iteration #');
legend('active ERK', 'active EGF');

subplot(2,1,2);
plot(IC50s/100,'r.');
set(gca,'XScale','log');
title('EGF inhibitor')
ylabel('IC50 (molecules Inhibitor/EGF)');
xlabel('Iteration #');

figure;
colors = colormap(winter(100));
set(gca, 'ColorOrder', colors);
hold all;
for i = 1:100
  plot( times, my_data(i, :, 13)/100 );
end
legend('Inhibitor concentration increases from blue to green')
title('EGF inhibitor')
ylabel('ERK activity (molecules ERK/EGF)');
xlabel('Iteration #');

figure;
colors = colormap(autumn(100));
set(gca, 'ColorOrder', colors);
hold all;
for i = 1:30:3000
  plot(concentrations, my_data(:, i, 13)/100 );
end
legend('Time increases from red to yellow')
title('EGF inhibitor')
ylabel('EGFR activity (molecules ERK/EGF)');
xlabel('Inhubitor concentration (molecules)');



