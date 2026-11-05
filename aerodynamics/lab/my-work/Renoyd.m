clc;
clear;

%% Read data
filePath = 'C:\Users\Administrator\Downloads\data_Re1.txt';
data = readmatrix(filePath);

%% Extract variables
alpha = data(:,1);       % Angle of attack [deg]
V     = data(:,2);       % Velocity [m/s]
rho   = data(:,3);       % Density [kg/m^3]

%% Parameters
c = 0.14;                % Airfoil chord [m]
b = 0.255;               % Wing span [m]
mu = 1.81e-5;            % Dynamic viscosity [Pa*s]

%% Reynolds number
re1 = rho .* V .* c ./ mu;

%% Mean Reynolds number
re1_mean = mean(re1, 'omitnan');

%% Display
fprintf('Mean Reynolds number = %.4e\n', re1_mean);

disp(table(alpha, V, rho, re1, ...
    'VariableNames', {'Alpha_deg','Velocity','Density','Re'}));