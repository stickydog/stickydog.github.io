%% Vortex Panel Method
%
% gamma_j is constant over each panel:
% n unknowns, n tangency equations + Kutta condition.
%
% One tangency equation (i = n/2) is replaced by
% gamma_1 + gamma_n = 0.
%

clear;
close all;
clc;

V     = 1;            % freestream speed
alpha = 5;            % angle of attack (deg)

naca  = [0 0 21];     % NACA m p tt
                       % [0 0 21] = NACA 0021
                       % [2 2 21] = NACA 2221

n     = 60;           % number of panels (even)
c     = 1;            % chord


%% =========================================================
%% 1. Panel geometry
% n+1 endpoints:
% TE -> bottom surface -> LE -> top surface -> TE

[X,Y] = naca4(naca,n);


% Control points = panel midpoints
xc = (X(1:end-1) + X(2:end))/2;
yc = (Y(1:end-1) + Y(2:end))/2;


% Panel vectors
dx = diff(X);
dy = diff(Y);


% Panel lengths
S = hypot(dx,dy);


% Outward unit normal
% Panels run clockwise
nx = -dy./S;
ny =  dx./S;



%% =========================================================
%% 2. Influence of panel j on control point i
%
% d(theta_ij)/dn_i =
%
% [-(y_i-y_j)n_x,i + (x_i-x_j)n_y,i]
% ------------------------------------------------
%       (x_i-x_j)^2 + (y_i-y_j)^2
%
%
% J_ij ~= d(theta_ij)/dn_i * S_j
%
% J_ii = 0

J = zeros(n,n);

for j = 1:n

    for i = 1:n

        % Self influence
        if i == j
            J(i,j) = 0;
            continue
        end


        % Distance from panel j midpoint
        % to control point i
        rx = xc(i) - xc(j);
        ry = yc(i) - yc(j);


        % Normal derivative of theta_ij
        dtheta_dn = ...
            (-ry*nx(i) + rx*ny(i)) ...
            /(rx^2 + ry^2);


        % Panel influence coefficient
        J(i,j) = dtheta_dn*S(j);

    end

end



%% =========================================================
%% 3. Solve vortex strength gamma
%
% V_inf*cos(beta_i)
% - sum_j gamma_j/(2*pi)*J_ij = 0
%
% => A*gamma = b

alphas = -5:1:15;

cl = zeros(size(alphas));


for k = 1:numel(alphas)

    a = alphas(k);


    % -----------------------------------------------------
    % Influence matrix
    A = -J/(2*pi);


    % -----------------------------------------------------
    % Freestream normal velocity
    %
    % V_inf*cos(beta_i)
    % =
    % V_inf*(cos(alpha)*nx + sin(alpha)*ny)

    b = -V*(cosd(a)*nx + sind(a)*ny);


    % -----------------------------------------------------
    % Kutta condition
    %
    % gamma_1 + gamma_n = 0
    %
    % Replace tangency equation at i = n/2

    q = n/2;

    A(q,:) = 0;

    A(q,1) = 1;
    A(q,n) = 1;

    b(q) = 0;


    % -----------------------------------------------------
    % Solve gamma

    gam = pinv(A,1e-3)*b(:);


    % -----------------------------------------------------
    % Total circulation
    %
    % Gamma = sum gamma_j*S_j

    Gamma = sum(gam(:).*S(:));


    % -----------------------------------------------------
    % Lift coefficient
    %
    % Cl = 2*Gamma/(V_inf*c)

    cl(k) = 2*Gamma/(V*c);


    % -----------------------------------------------------
    % Store results at selected alpha

    if a == alpha

        % Cp_i = 1 - (gamma_i/V_inf)^2
        Cp = 1 - (gam/V).^2;

        clA  = cl(k);
        gamA = gam;

    end

end



%% =========================================================
%% 4. Plot preparation

bot = 1:n/2;
top = n/2+1:n;


% Sort both surfaces from LE -> TE
[xTop,idxTop] = sort(xc(top));
[xBot,idxBot] = sort(xc(bot));


CpTop = Cp(top);
CpTop = CpTop(idxTop);

CpBot = Cp(bot);
CpBot = CpBot(idxBot);


gamTop = gamA(top);
gamTop = gamTop(idxTop);

gamBot = gamA(bot);
gamBot = gamBot(idxBot);



%% =========================================================
%% 5. Plots

figure( ...
    'Color','w', ...
    'Position',[100 80 1200 760]);


t = tiledlayout(2,2, ...
    'TileSpacing','compact', ...
    'Padding','compact');


%% ---------------------------------------------------------
% Airfoil geometry

nexttile

plot(X,Y,'k.-', ...
    'LineWidth',1.2, ...
    'MarkerSize',7);

hold on

quiver( ...
    xc,yc,nx,ny,0.18, ...
    'r', ...
    'LineWidth',0.8);


axis equal
grid on
box on

xlim([-0.05 1.05])
ylim([-0.25 0.25])

xlabel('x/c')
ylabel('y/c')

title(sprintf( ...
    'NACA %d%d%02d — %d panels', ...
    naca(1),naca(2),naca(3),n));



%% ---------------------------------------------------------
% Vortex strength

nexttile

plot( ...
    xTop,gamTop/V, ...
    'b.-', ...
    'LineWidth',1.2, ...
    'MarkerSize',7);

hold on

plot( ...
    xBot,gamBot/V, ...
    'r.-', ...
    'LineWidth',1.2, ...
    'MarkerSize',7);


yline(0,'k:');

grid on
box on

xlabel('x/c')
ylabel('\gamma / V_\infty')

legend( ...
    'Top', ...
    'Bottom', ...
    'Location','best');

title('Vortex strength');



%% ---------------------------------------------------------
% Pressure coefficient

nexttile

plot( ...
    xTop,CpTop, ...
    'b.-', ...
    'LineWidth',1.2, ...
    'MarkerSize',7);

hold on

plot( ...
    xBot,CpBot, ...
    'r.-', ...
    'LineWidth',1.2, ...
    'MarkerSize',7);


% Standard aerodynamic Cp convention:
% negative Cp plotted upward
set(gca,'YDir','reverse');

grid on
box on

xlabel('x/c')
ylabel('C_p')

legend( ...
    'Top', ...
    'Bottom', ...
    'Location','best');

title(sprintf( ...
    '\\alpha = %.1f^\\circ,   c_l = %.3f', ...
    alpha,clA));



%% ---------------------------------------------------------
% Lift curve

nexttile

plot( ...
    alphas,cl, ...
    'o-', ...
    'LineWidth',1.4, ...
    'MarkerSize',6);

hold on


% Thin-airfoil theory
cl_thin = 2*pi*deg2rad(alphas);

plot( ...
    alphas,cl_thin, ...
    'k--', ...
    'LineWidth',1.2);


xline(0,'k:');
yline(0,'k:');

grid on
box on

xlabel('\alpha (deg)')
ylabel('c_l')

legend( ...
    'Vortex panels', ...
    'Thin airfoil: 2\pi\alpha', ...
    'Location','northwest');

title('Lift curve');



%% ---------------------------------------------------------
% Overall title

sgtitle(sprintf( ...
    'Vortex Panel Method — NACA %d%d%02d', ...
    naca(1),naca(2),naca(3)), ...
    'FontWeight','bold');



%% =========================================================
%% NACA 4-digit airfoil
%
% TE -> bottom -> LE -> top -> TE
%

function [X,Y] = naca4(code,n)

m = code(1)/100;
p = code(2)/10;
t = code(3)/100;


x = linspace(0,1,n/2+1);


% Thickness distribution
yt = 5*t*( ...
      0.2969*sqrt(x) ...
    - 0.1260*x ...
    - 0.3516*x.^2 ...
    + 0.2843*x.^3 ...
    - 0.1036*x.^4);


% Camber line
yc  = zeros(size(x));
dyc = zeros(size(x));


if m > 0

    f = x < p;


    yc(f) = ...
        m/p^2 .* ...
        (2*p*x(f) - x(f).^2);


    yc(~f) = ...
        m/(1-p)^2 .* ...
        ((1-2*p) + 2*p*x(~f) - x(~f).^2);


    dyc(f) = ...
        2*m/p^2 .* ...
        (p-x(f));


    dyc(~f) = ...
        2*m/(1-p)^2 .* ...
        (p-x(~f));

end


% Camber-line angle
th = atan(dyc);


% Coordinate construction
X = [ ...
    fliplr(x + yt.*sin(th)), ...
    x(2:end) - yt(2:end).*sin(th(2:end)) ...
    ];


Y = [ ...
    fliplr(yc - yt.*cos(th)), ...
    yc(2:end) + yt(2:end).*cos(th(2:end)) ...
    ];

end