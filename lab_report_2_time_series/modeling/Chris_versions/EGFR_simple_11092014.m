


%calling load excel script
LoadExcel_v2_11092014

%initial concentrations
EGF	= 1000; 
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
TACE = 0;
TGFa = 1000;
actTGFa = 0;
x = [EGF	EGFR	EGF_EGFR	SOS	actSOS	RAS	actRAS	RAF	actRAF	MEK	actMEK	ERK	actERK ERK_SOS ERK_RAF];

%test run
testing = ode_fun_v2_11092014(x, s, w, exp);

%Running simulation
steps = 10000; %number of reps in simulation
stored_data = zeros(steps,15);
times = zeros(1, steps);
new_data = x;
stored_data(1, :) = x;
times(1) = 1;
for i=2:steps;
    change = ode_fun_v2_11092014(new_data, s, w, exp);
    new_data = new_data + change;
    stored_data(i, :) = new_data;
    times(i) = i;
end;

stored_data
plot( times, (stored_data(:,1)), times, (stored_data(:,13)) );
set(gca,'XScale','log');
ylabel('Concentration (Molecules)');
xlabel('Iteration #');
legend('EGF', 'active ERK');
