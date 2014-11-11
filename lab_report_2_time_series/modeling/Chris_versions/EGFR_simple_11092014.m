


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
actTACE = 10;
EGF = 100;
TGFa = 100;
actTGFa = 0;
actTGFa_EGFR = 0;
TACE = 100;
x = [actEGF	EGFR	actEGF_EGFR	SOS	actSOS	RAS	actRAS	RAF	actRAF	MEK	actMEK	ERK	actERK	ERK_SOS	ERK_RAF	actTACE	EGF	TGFa	actTGFa	actTGFa_EGFR    TACE];

%test run
testing = ode_fun_v2_11092014(x, s, w, exp);

%Running simulation
steps = 200; %number of reps in simulation
stored_data = zeros(steps,21); %update with number of different molecules 
times = zeros(1, steps);
new_data = x;
stored_data(1, :) = x;
times(1) = 1;
for i=2:steps;
    change = ode_fun_v2_11092014(new_data, s, w, exp);
    new_data = new_data + change;
 %   new_data2 = max(new_data, 0); %setting negatives to 0
%    stored_data(i, :) = new_data2;
    stored_data(i, :) = new_data;
    times(i) = i;
end;

stored_data
plot( times, stored_data(:,1), times, stored_data(:,13) );
%set(gca,'XScale','log');
ylabel('Concentration (Molecules)');
xlabel('Iteration #');
legend('active EGF', 'active ERK');


