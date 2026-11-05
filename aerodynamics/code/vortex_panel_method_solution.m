%% Vortex panel method  (Anderson, Fundamentals of Aerodynamics, Sec. 4.10)
%
%   V_inf cos(beta_i) - sum_j 1/(2 pi) * integral_j gamma(s) d(theta_ij)/d(n_i) ds_j = 0
%   gamma_1 + gamma_n = 0   (Kutta, the two panels at the trailing edge)
%
% gamma_j is constant over each panel: n unknowns, n tangency equations + Kutta.
% That is one equation too many, so the tangency condition at one panel is dropped.
% (c_l comes out right, but C_p zig-zags panel to panel: a known flaw of constant gamma.)
%
% BIG QUESTIONS -- use this code to answer them
%   1. Where does lift come from?  Is    the top surface being sucked up, or the bottom
%      pushed up?  Which part of the chord does most of the work?
%   2. What is the Kutta condition physically doing?  Comment out the Kutta line and
%      look at the lift.  Why can't the flow-tangency equations pick the answer alone?
%   3. Does a thicker airfoil make more lift at the same angle?  Try 0006, 0012, 0024.
%   4. This code says lift keeps rising with alpha forever.  Real wings stall.  Watch
%      the pressure near the leading edge as alpha goes up -- what would real air,
%      with viscosity, have a hard time doing?
%   5. Camber (e.g. 4412) vs just tilting a symmetric airfoil: same lift, different how?
%
% Lines ending in "% KEY" are the equations you write.  They are commented out, so the
% script will not run until they are filled in.

clear; close all

V     = 1;            % freestream speed
alpha = 5;            % angle of attack (deg)
naca  = [0 0 12];     % NACA m p tt, e.g. [0 0 12] = 0012, [4 4 12] = 4412
n     = 60;           % number of panels (even)
c     = 1;            % chord

%% 1. Panels: n+1 end points, clockwise from the trailing edge (bottom, LE, top)
[X, Y] = naca4(naca, n);

xc = (X(1:end-1) + X(2:end))/2;       % control point = panel midpoint
yc = (Y(1:end-1) + Y(2:end))/2;
dx = diff(X);  dy = diff(Y);
S  = hypot(dx, dy);                   % panel lengths

% outward unit normal of each panel (panels run clockwise)
 nx = -dy./S;  ny = dx./S;   % KEY
%% 2. Geometry integrals:  normal velocity at control point i from the gamma on panel j
%  theta_ij = atan2(yc_i - y, xc_i - x),  so  d(theta)/dx_i = -ry/r^2,  d(theta)/dy_i = rx/r^2
%  and  d(theta)/dn_i = (gradient of theta) . n_i
%  One point per panel: J(i,j) ~ d(theta)/dn_i at the midpoint of panel j, times S_j.
%  A panel induces no normal velocity at its own midpoint, so J(i,i) = 0.
J = zeros(n, n);                     % J(i,j) = integral_j d(theta_ij)/d(n_i) ds_j
for j = 1:n
    for i = 1:n
        if i == j, continue; end
        rx = xc(i) - xc(j);  ry = yc(i) - yc(j);
         dth_dn = (-ry*nx(i) + rx*ny(i)) / (rx^2 + ry^2);   % KEY   d(theta_ij)/d(n_i)
        J(i,j) = dth_dn*S(j);
    end
end

%% 3. Solve for gamma.  J does not depend on alpha: build it once, sweep alpha.
alphas = -5:1:15;
cl = zeros(size(alphas));
for k = 1:numel(alphas)
    a = alphas(k);
    A = -J/(2*pi);                    % A*gamma = b,  n equations
    b = -V*(cosd(a)*nx + sind(a)*ny).';   % KEY   V_inf cos(beta_i) = V_inf . n_i

    % n+1 equations, n unknowns: drop the tangency condition at panel idrop, put Kutta there
    idrop = n/2;                      % a panel at the leading edge
    A(idrop, :) = 0;  b(idrop) = 0;
     A(idrop, [1 n]) = 1;   % KEY   gamma_1 + gamma_n = 0

    % A is nearly singular: a +,-,+,- sawtooth in gamma induces almost no normal velocity,
    % so the equations barely constrain it and A\b amplifies it to +/-200.  pinv with a
    % tolerance throws that direction away instead of amplifying it.  It is a patch, not
    % a cure: C_p still wiggles and the suction peak is ~50% high.  Section 5 is the cure.
    gam = pinv(A, 1e-3)*b(:);
    cl(k) = 2*sum(gam .* S.')/(V*c);   % KEY   L' = rho V Gamma,  Gamma = sum gamma_j s_j
    if a == alpha
         Cp = 1 - (gam/V).^2;   % KEY   surface speed = gamma
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

% gamma is the surface speed, so it should be of order V_inf.  C_p squares it and
% hides the sign, so plot gamma itself to see what the solution is really doing.
subplot(2,3,[2 5])
plot(xc(top), gamA(top), 'b.-', xc(bot), gamA(bot), 'r.-'); grid on
legend('top', 'bottom'); xlabel('x/c'); ylabel('\gamma / V_\infty')
title('vortex strength')

subplot(2,3,[3 6])
plot(alphas, cl, 'o-', alphas, 2*pi*deg2rad(alphas), 'k--'); grid on
legend('vortex panels', 'thin airfoil  2\pi\alpha', 'Location', 'northwest')
xlabel('\alpha (deg)'); ylabel('c_l'); title('lift curve')

%% 5. The same vortex panel method, done properly
% Two things were wrong above, and neither is in the physics:
%   (a) J_ij was approximated by one point per panel.  The integral has a closed form.
%   (b) gamma was constant on each panel, so a +,-,+,- sawtooth was almost invisible to
%       the flow-tangency equations.  pinv hides it; it does not remove it.
% Fix both: store gamma at the n+1 panel END POINTS and let it vary linearly along each
% panel (neighbours share a value, so the sawtooth cannot exist), and integrate each
% panel exactly.  n tangency equations + Kutta = n+1 equations for n+1 unknowns, so no
% equation is dropped either, and backslash is enough.  See linvortex below.
[cl2, Cp2, xcp2, gam2, X2] = linvortex(naca, n, V, c, alphas, alpha);
cl2A = cl2(alphas == alpha);
fprintf('c_l at %d deg:  lecture method %.4f,  linear gamma + exact integrals %.4f\n', ...
        alpha, clA, cl2A);

figure('Color', 'w', 'Position', [150 150 1100 400])
bot2 = 1:n/2+1;  top2 = n/2+1:n+1;      % end points; control points are one fewer

subplot(1,3,1)
plot(X2(top2), gam2(top2), 'b.-', X2(bot2), gam2(bot2), 'r.-'); grid on
legend('top', 'bottom', 'Location', 'southeast'); xlabel('x/c'); ylabel('\gamma / V_\infty')
title('vortex strength')

subplot(1,3,2)
plot(xcp2(n/2+1:n), Cp2(n/2+1:n), 'b.-', xcp2(1:n/2), Cp2(1:n/2), 'r.-')
set(gca, 'YDir', 'reverse'); grid on
legend('top', 'bottom'); xlabel('x/c'); ylabel('C_p')
title(sprintf('\\alpha = %d^\\circ,  c_l = %.3f', alpha, cl2A))

subplot(1,3,3)
plot(alphas, cl, 'o-', alphas, cl2, 's-', alphas, 2*pi*deg2rad(alphas), 'k--'); grid on
legend('lecture method', 'linear \gamma, exact', '2\pi\alpha', 'Location', 'northwest')
xlabel('\alpha (deg)'); ylabel('c_l'); title('lift curve')

%% 6. Compare with the Lab 4 wind tunnel data
% The tunnel model is a NACA 0021 (not 0012), c = 17 cm, s = 25.5 cm, so AR = s/c = 1.5.
% The panel method is two dimensional, i.e. infinite span, so it should over-predict the
% slope: the real wing sheds tip vortices and the downwash lowers its effective angle of
% attack.  The measured slope is about 0.070 /deg against 0.127 /deg here.  Nothing else
% inviscid explains the rest of the plot: all three Reynolds numbers lie on one line
% below stall, and at about 24 deg the flow separates and c_l collapses, which no
% inviscid method can reproduce.
labdir = 'Lab 4';
if ~isfolder(labdir)
    warning('Lab 4 folder not found, skipping the comparison');
else
addpath(labdir)
cLab = 0.17;  sLab = 0.255;
alab = 0:1:20;                                   % below stall, where inviscid theory can work
[clLab, CpLab, xcpLab] = linvortex([0 0 21], n, V, c, alab, 6);   % 0021 to match the model

figure('Color', 'w', 'Position', [150 150 1000 420])
subplot(1,2,1); hold on; grid on
mk = {'o','s','^'};
for f = 1:3
    D = readmatrix(fullfile(labdir, sprintf('data_Re%d.txt', f)), 'NumHeaderLines', 1);
    aoa = D(:,1);  u = D(:,2);  rho = D(:,3);  press = D(:,6:end);
    Lp = zeros(size(aoa));
    for i = 1:numel(aoa)                          % lift from the pressure taps
        [~, ~, ~, nyt] = airfoil_normals(aoa(i));
        Lp(i) = -sum(press(i,:).*nyt(:).')*sLab;
    end
    cLp = Lp ./ (0.5*rho.*u.^2*cLab*sLab);
    Re  = mean(rho.*u)*cLab/1.8e-5;
    plot(aoa, cLp, ['k' mk{f} '-'], 'MarkerSize', 4, 'DisplayName', sprintf('Re = %.1f mio', Re/1e6))
    if f == 3, aoaH = aoa;  CpH = press ./ (0.5*rho.*u.^2); end
end
plot(alab, clLab, 'b-', 'LineWidth', 1.5, 'DisplayName', 'panel, 2D')
xlabel('\alpha (deg)'); ylabel('c_l'); legend('Location','southeast'); title('NACA 0021: lab vs panel method')

subplot(1,2,2); hold on; grid on          % pressure distribution at 6 deg, highest Re
i6 = find(aoaH == 6, 1);
[xt, ~] = airfoil_normals(0);             % tap x positions, unrotated
xtc = xt/cLab;  topT = [17:32 1];  botT = 1:17;
plot(xtc(topT), CpH(i6,topT), 'ko-', 'MarkerSize', 4, 'DisplayName', 'lab, top')
plot(xtc(botT), CpH(i6,botT), 'ks-', 'MarkerSize', 4, 'DisplayName', 'lab, bottom')
plot(xcpLab(n/2+1:n), CpLab(n/2+1:n), 'b-', 'DisplayName', 'panel, top')
plot(xcpLab(1:n/2), CpLab(1:n/2), 'r-', 'DisplayName', 'panel, bottom')
set(gca, 'YDir', 'reverse'); xlabel('x/c'); ylabel('C_p'); legend('Location','southeast')
title('C_p at \alpha = 6^\circ, Re = 5.9 mio')
rmpath(labdir)
end

%% NACA 4-digit airfoil, TE -> bottom -> LE -> top -> TE
% Spacing matters, and which one is better depends on the method.  With constant gamma
% (sections 1-4) cosine spacing packs tiny panels at the nose, and a +/- pair on two tiny
% panels induces almost nothing, so the sawtooth there reaches +/-200; uniform spacing
% keeps it near +/-2.  With linear gamma and exact integrals (section 5) there is no
% sawtooth at all, and cosine spacing is simply better: it resolves the leading edge.
function [X, Y] = naca4(code, n, spacing)
m = code(1)/100;  p = code(2)/10;  t = code(3)/100;
if nargin > 2 && strcmp(spacing, 'cosine')
    x = (1 - cos(linspace(0, pi, n/2 + 1)))/2;
else
    x = linspace(0, 1, n/2 + 1);
end
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

%% Linear-strength vortex panels: gamma at the n+1 end points, linear along each panel.
% Returns the lift curve over alphas, plus gamma and C_p at the single angle aCp.
function [cl, Cp, xcp, gam, X, Y] = linvortex(code, n, V, c, alphas, aCp)
[X, Y] = naca4(code, n, 'cosine');
xcp = (X(1:end-1) + X(2:end))/2;  ycp = (Y(1:end-1) + Y(2:end))/2;
dx = diff(X);  dy = diff(Y);  S = hypot(dx, dy);
tx = dx./S;  ty = dy./S;  nx = -dy./S;  ny = dx./S;

% column j of An = normal velocity at every control point from gamma_j = 1,
% column j of At = the tangential velocity, which is what the pressure needs afterwards
An = zeros(n, n+1);  At = zeros(n, n+1);
for i = 1:n
    for j = 1:n
        P1 = [X(j) Y(j)];  P2 = [X(j+1) Y(j+1)];  P = [xcp(i) ycp(i)];
        v1 = panelvel(P1, P2, 1, 0, P);      % unit gamma at the panel's first end point
        v2 = panelvel(P1, P2, 0, 1, P);      % unit gamma at its second end point
        An(i,j)   = An(i,j)   + v1*[nx(i); ny(i)];
        An(i,j+1) = An(i,j+1) + v2*[nx(i); ny(i)];
        At(i,j)   = At(i,j)   + v1*[tx(i); ty(i)];
        At(i,j+1) = At(i,j+1) + v2*[tx(i); ty(i)];
    end
end

cl = zeros(size(alphas));  Cp = [];  gam = [];
for k = 1:numel(alphas)
    a = alphas(k);
    A = An;  b = -V*(cosd(a)*nx + sind(a)*ny).';     % cancel the freestream normal part
    A(n+1, :) = 0;  b(n+1) = 0;
    A(n+1, [1 n+1]) = 1;                             % Kutta: gamma_1 + gamma_n+1 = 0
    g = A\b(:);
    cl(k) = 2*sum((g(1:n) + g(2:n+1))/2 .* S.')/(V*c);
    if a == aCp
        gam = g;
        Vt = V*(cosd(a)*tx + sind(a)*ty).' + At*g;   % surface speed at the control points
        Cp = 1 - (Vt/V).^2;
    end
end
end

%% Velocity at P from one linear-strength vortex panel P1 -> P2, gamma going g1 -> g2.
% In panel coordinates (x along the panel, z normal, panel from 0 to L):
%   u =  1/(2pi) [ g1 (th2 - th1) + (g2-g1)/L ( x(th2-th1) - z ln(r1/r2) ) ]
%   w = -1/(2pi) [ g1 ln(r1/r2)   + (g2-g1)/L ( x ln(r1/r2) - L + z(th2-th1) ) ]
% These are the exact integrals of the point-vortex velocity along the panel, so they
% also handle the panel's own control point (z = 0), where th2 - th1 = pi.
function v = panelvel(P1, P2, g1, g2, P)
d = P2 - P1;  L = norm(d);  t = d/L;  nv = [-d(2) d(1)]/L;
r = P - P1;  x = r*t.';  z = r*nv.';
r1 = hypot(x, z);  r2 = hypot(x - L, z);
if abs(z) < 1e-12                          % on the panel's own line
    dth = pi*(x > 0 && x < L);
    zA0 = dth;  zA1 = x*dth;
else
    zA0 = atan2(z, x - L) - atan2(z, x);   % = th2 - th1
    zA1 = x*zA0 - z*log(r1/r2);
end
B0 = log(r1/r2);  B1 = x*B0 - L + z*zA0;
u =  ( g1*zA0 + (g2 - g1)*zA1/L )/(2*pi);
w = -( g1*B0  + (g2 - g1)*B1 /L )/(2*pi);
v = u*t + w*nv;
end
