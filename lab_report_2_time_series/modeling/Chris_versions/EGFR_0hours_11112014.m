
%%%%%%%%%%%% first, plot for 0 inhibitor

%calling load excel script
LoadExcel_v2_11092014

%initial concentrations
actEGF = 0;
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
actTACE = 10; %need some to start with, or else EGF not cleaved
EGF = 100;
TGFa = 100;
actTGFa = 0;
actTGFa_EGFR = 0;
TACE = 100;
Inhib = 95;
x = [actEGF	EGFR	actEGF_EGFR	SOS	actSOS	RAS	actRAS	RAF	actRAF	MEK	actMEK	ERK	actERK	ERK_SOS	ERK_RAF	actTACE	EGF	TGFa	actTGFa	actTGFa_EGFR    TACE    Inhib];

%Running simulation
steps = 4000; %number of reps in simulation
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

no_inhib

    %concentration vs time
plot(times, no_inhib(:,1), times, no_inhib(:,13) );
set(gca,'XScale','log');
ylabel('Concentration (Molecules)');
xlabel('Iteration #');
legend('active EGF', 'active ERK');





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for 100 different concentrations of inhibitor.
%I want to do for 30 times between 0 and 3000.
%get simulation data

%calling load excel script
%LoadExcel_v2_11092014

%initial concentrations
actEGF = 0;
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
actTACE = 10; %need some to start with, or else EGF not cleaved
EGF = 100;
TGFa = 100;
actTGFa = 0;
actTGFa_EGFR = 0;
TACE = 100;
Inhib = 0;

%up to time:
steps = 3000;

%storing data:
my_data = zeros(100, steps, 22);

%simulation
for inhib=1:100 % for 100 different concentrations of inhibitor
    %setting inhib concentration added
    Inhib = inhib;
    x = [actEGF	EGFR	actEGF_EGFR	SOS	actSOS	RAS	actRAS	RAF	actRAF	MEK	actMEK	ERK	actERK	ERK_SOS	ERK_RAF	actTACE	EGF	TGFa	actTGFa	actTGFa_EGFR    TACE    Inhib];
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

inhibitor = 90;
figure;
subplot(2,1,1);
plot(times, my_data(inhibitor,:, 1), times, my_data(inhibitor,:,13),'r.');
set(gca,'XScale','log');
set(gca,'YScale','log');
ylabel('Concentration (Molecules)');
xlabel('Iteration #');
legend('active EGF', 'active ERK');


%getting IC50s. 
IC50s = zeros(steps, 1);
for i=1:steps
    IC50_at_this_time = 0;
    for inhib=1:100
        actERK = no_inhib(i,13);
        half = actERK/2;
        %now, want the concentration of inhibitor to bring act ERK below
        %"half"
        inhib_ERK = my_data(inhib, i, 13);
        if IC50_at_this_time ==0;
            if inhib_ERK <= half;
                IC50_at_this_time = inhib_ERK;
            end
        end
    end
    IC50s(i) = IC50_at_this_time;
end

subplot(2,1,2);
plot(IC50s,'r.')
set(gca,'XScale','log');
ylabel('ERK by EGFR-inhibitor IC50');
xlabel('Iteration #');




