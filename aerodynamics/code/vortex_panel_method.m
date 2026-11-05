%% Vortex panel method 
%
% gamma_j is constant over each panel: n unknowns, n tangency equations + Kutta.
% That is one equation too many, so the tangency condition at one panel is dropped.
%%
%Run for NACA0021 airfoil, NACA2221
%Compare NACA0021 to results from yesterday

clear; close all

V     = 1;            % freestream speed
alpha = 5;            % angle of attack (deg)
naca  = [0 0 21];     % NACA m p tt, e.g. [0 0 12] = 0012, [4 4 12] = 4412
n     = 60;           % number of panels (even)
c     = 1;            % chord



%% 1. Panels: n+1 end points, clockwise from the trailing edge (bottom, LE, top)
[X, Y] = naca4(naca, n);

xc = (X(1:end-1) + X(2:end))/2;       % control point = panel midpoint
yc = (Y(1:end-1) + Y(2:end))/2;
dx = diff(X);  dy = diff(Y);
S  = hypot(dx, dy);                   % panel lengths

% outward unit normal of each panel (panels run clockwise)
 nx = -dy./S;  ny = dx./S; 


%% 2. Geometry integrals:  normal velocity at control point i from the gamma on panel j
J = zeros(n, n);                    
for j = 1:n
    for i = 1:n
        if i == j, continue; end
         dth =   %Fill in
         J(i,j) =    %Fill in
    end
end

%% 3. Solve for gamma.  J does not depend on alpha: build it once, sweep alpha.
alphas = -5:1:15;
cl = zeros(size(alphas));
for k = 1:numel(alphas)
    a = alphas(k);
    A = -J/(2*pi);                    % A*gamma = b,  n equations
    b =                               % Enforce flow tangency

    % n+1 equations, n unknowns: drop the tangency condition at a panel, put Kutta there
   

    gam = pinv(A, 1e-3)*b(:);    

    cl(k) = 
    if a == alpha
         Cp = ;   
        clA = cl(k);  gamA = gam;   % keep gamma at this alpha for the plot
    end
end

%% 4. Plots
figure('Color', 'w', 'Position', [100 100 1100 700])

subplot(2,3,1)
plot(X, Y, 'k.-'); hold on
quiver(xc, yc, nx, ny, 0.3, 'r')
axis equal; title(sprintf('NACA %d%d%02d, %d panels', naca, n)); xlabel('x/c')

subplot(2,3,4)
bot = 1:n/2;  top = n/2+1:n;          % panels: bottom half first, then top
plot(xc(top), Cp(top), 'b.-', xc(bot), Cp(bot), 'r.-')
set(gca, 'YDir', 'reverse'); grid on
legend('top', 'bottom'); xlabel('x/c'); ylabel('C_p')
title(sprintf('\\alpha = %d^\\circ,  c_l = %.3f', alpha, clA))

subplot(2,3,[2 5])
plot(xc(top), gamA(top), 'b.-', xc(bot), gamA(bot), 'r.-'); grid on
legend('top', 'bottom'); xlabel('x/c'); ylabel('\gamma / V_\infty')
title('vortex strength')

subplot(2,3,[3 6])
plot(alphas, cl, 'o-', alphas, 2*pi*deg2rad(alphas), 'k--'); grid on
legend('vortex panels', 'thin airfoil  2\pi\alpha', 'Location', 'northwest')
xlabel('\alpha (deg)'); ylabel('c_l'); title('lift curve')

%% NACA 4-digit airfoil, TE -> bottom -> LE -> top -> TE, uniform spacing
function [X, Y] = naca4(code, n)
m = code(1)/100;  p = code(2)/10;  t = code(3)/100;
x  = linspace(0, 1, n/2 + 1);
yt = 5*t*(0.2969*sqrt(x) - 0.1260*x - 0.3516*x.^2 + 0.2843*x.^3 - 0.1036*x.^4);
yc = zeros(size(x));  dyc = yc;
if m > 0
    f = x < p;
    yc(f)   = m/p^2*(2*p*x(f) - x(f).^2);
    yc(~f)  = m/(1-p)^2*((1 - 2*p) + 2*p*x(~f) - x(~f).^2);
    dyc(f)  = 2*m/p^2*(p - x(f));
    dyc(~f) = 2*m/(1-p)^2*(p - x(~f));
end
th = atan(dyc);
X = [fliplr(x + yt.*sin(th)), x(2:end) - yt(2:end).*sin(th(2:end))];
Y = [fliplr(yc - yt.*cos(th)), yc(2:end) + yt(2:end).*cos(th(2:end))];
end
