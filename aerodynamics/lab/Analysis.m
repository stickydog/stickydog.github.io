clear all; close all; clc

% load and extract data
data_low = dlmread('data_Re1.txt',',',1,0);
data_med = dlmread('data_Re2.txt',',',1,0);
data_high = dlmread('data_Re3.txt',',',1,0);

aoa = data_low(:,1);
u_low = data_low(:,2);
rho_low = data_low(:,3);
lift_low = data_low(:,4);
drag_low = data_low(:,5);
pressure_low = data_low(:,6:end);

u_med = data_med(:,2);
rho_med = data_med(:,3);
lift_med = data_med(:,4);
drag_med = data_med(:,5);
pressure_med = data_med(:,6:end);

u_high = data_high(:,2);
rho_high = data_high(:,3);
lift_high = data_high(:,4);
drag_high = data_high(:,5);
pressure_high = data_high(:,6:end);

% constants
c = 0.17;   % chord
s = 0.255;  % span

% calculate c_L from force sensor
cLf_low = lift_low ./ (0.5 * rho_low .* u_low.^2 .* c .* s);
cLf_med = lift_med ./ (0.5 * rho_med .* u_med.^2 .* c .* s);
cLf_high = lift_high ./ (0.5 * rho_high .* u_high.^2 .* c .* s);

% calculate c_D from force sensor
cDf_low = drag_low ./ (0.5 * rho_low .* u_low.^2 .* c .* s);
cDf_med = drag_med ./ (0.5 * rho_med .* u_med.^2 .* c .* s);
cDf_high = drag_high ./ (0.5 * rho_high .* u_high.^2 .* c .* s);

% calculate c_L from pressures
for i = 1:length(aoa)
    [xtap(i,:), ytap(i,:), nx(i,:), ny(i,:)] = airfoil_normals(aoa(i));   % [m]
    % force = -(pressure x normal x tap length) summed, times span
    Lp_low(i) = -sum(pressure_low(i,:) .* ny(i,:)) * s;  % [N]
    Lp_med(i) = -sum(pressure_med(i,:) .* ny(i,:)) * s;  % [N]
    Lp_high(i) = -sum(pressure_high(i,:) .* ny(i,:)) * s;  % [N]
    
    Dp_low(i) = -sum(pressure_low(i,:) .* nx(i,:)) * s;  % [N]
    Dp_med(i) = -sum(pressure_med(i,:) .* nx(i,:)) * s;  % [N]
    Dp_high(i) = -sum(pressure_high(i,:) .* nx(i,:)) * s;  % [N]
end

%% pressure coefficient
% taps: 1 = trailing edge, 2:16 = bottom, 17 = leading edge, 18:32 = top
q_high = 0.5 * rho_high .* u_high.^2;   % dynamic pressure [Pa]
Cp_high = pressure_high ./ q_high;
xc = xtap(1,:) / c;                       % x/c of the taps (aoa = 0, unrotated)
top = [17:32,1];
bottom = 1:17;

%% top side before and after stall
figure
hold on
for i = 16:17
plot(xc(top),Cp_high(i,top),'o-')
end
set(gca,'YDir','reverse')
xlabel('x/c')
ylabel('C_p')
legend(sprintf('Before Stall (%g deg)',aoa(16)),sprintf('After Stall (%g deg)',aoa(17)))

%% top and bottom at zero angle of attack
figure
hold on
i = 1;
plot(xc(bottom),Cp_high(i,bottom),'o-')
plot(xc(top),Cp_high(i,top),'o-')
set(gca,'YDir','reverse')
xlabel('x/c')
ylabel('C_p')
legend('Bottom','Top')

%%
% calculate c_L from pressure transducers
cLp_low = Lp_low' ./ (0.5 .* rho_low .* u_low.^2 .* c .* s);
cLp_med = Lp_med' ./ (0.5 .* rho_med .* u_med.^2 .* c .* s);
cLp_high = Lp_high' ./ (0.5 .* rho_high .* u_high.^2 .* c .* s);

% calculate c_D from pressure transducers
cDp_low = Dp_low' ./ (0.5 .* rho_low .* u_low.^2 .* c .* s);
cDp_med = Dp_med' ./ (0.5 .* rho_med .* u_med.^2 .* c .* s);
cDp_high = Dp_high' ./ (0.5 .* rho_high .* u_high.^2 .* c .* s);

% comparing forces from pressure transducers and force sensors
% these should include error bars but I haven't written the code for that
% yet
figure
hold on
plot(aoa,cLp_low)
plot(aoa,cLf_low)
plot(aoa,cDp_low)
plot(aoa,cDf_low)
title('Re = 3 mio')
xlabel('Angle of attack')
ylabel('Lift and drag coefficients')
legend('c_L from pressure','c_L from force sensor','c_D from pressure','c_D from force sensor')

figure
hold on
plot(aoa,cLp_med)
plot(aoa,cLf_med)
plot(aoa,cDp_med)
plot(aoa,cDf_med)
title('Re = 4 mio')
xlabel('Angle of attack')
ylabel('Lift and drag coefficients')
legend('c_L from pressure','c_L from force sensor','c_D from pressure','c_D from force sensor')

figure
hold on
plot(aoa,cLp_high)
plot(aoa,cLf_high)
plot(aoa,cDp_high)
plot(aoa,cDf_high)
title('Re = 5 mio')
xlabel('Angle of attack')
ylabel('Lift and drag coefficients')
legend('c_L from pressure','c_L from force sensor','c_D from pressure','c_D from force sensor')

% comparing lift and drag coefficients at different Reynolds numbers
figure
hold on
plot(aoa,cLp_low)
plot(aoa,cLp_med)
plot(aoa,cLp_high)
xlabel('Angle of attack')
ylabel('Lift coefficient')
legend('Re = 3 mio','Re = 4 mio','Re = 5 mio')