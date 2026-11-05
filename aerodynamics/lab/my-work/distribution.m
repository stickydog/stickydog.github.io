clc;
clear;

%% Read data
filePath = 'C:\Users\Administrator\Downloads\data_Re1.txt';

data = readmatrix(filePath);

%% Basic variables
alpha = data(:,1);
V     = data(:,2);
rho   = data(:,3);

%% Geometry and viscosity
c = 0.14;          % chord length [m]
mu = 1.81e-5;      % dynamic viscosity [Pa*s]

%% Reynolds number
Re = rho .* V .* c ./ mu;

Re_mean = mean(Re,'omitnan');

fprintf('Mean Reynolds number = %.4e\n',Re_mean);

%% Find alpha = 0 deg
[~,idx0] = min(abs(alpha));

fprintf('Selected alpha = %.2f deg\n',alpha(idx0));

%% Flow condition at alpha = 0
V0   = V(idx0);
rho0 = rho(idx0);

q_inf = 0.5 * rho0 * V0^2;

fprintf('Dynamic pressure = %.2f Pa\n',q_inf);

%% Extract 32 pressure taps
% columns 1-5:
% alpha, velocity, density, lift, drag
%
% columns 6-37:
% 32 pressure taps

p = data(idx0,6:37);

%% Separate top and bottom surfaces
% Assumption:
% Tap 1-16: top surface, TE -> LE
% Tap 17-32: bottom surface, LE -> TE

p_top    = flip(p(1:16));
p_bottom = p(17:32);

%% Normalize pressure -> Cp
Cp_top    = p_top ./ q_inf;
Cp_bottom = p_bottom ./ q_inf;

%% Normalized chord coordinate
% Only use this if pressure taps are approximately equally spaced.
% If actual x/c positions are available, replace this array.

x_c = linspace(0,1,16);

%% Plot Cp distribution
figure;

plot(x_c,Cp_top,'-o','LineWidth',1.5);
hold on;

plot(x_c,Cp_bottom,'-s','LineWidth',1.5);

grid on;

xlabel('x/c');
ylabel('C_p');

legend('Top surface','Bottom surface',...
       'Location','best');

title(sprintf('Pressure Distribution at \\alpha = 0^\\circ, Re = %.2e',...
              Re(idx0)));

% Standard aerodynamic Cp convention
set(gca,'YDir','reverse');