%% XFOIL handout (xfoil_commands.pdf) -- SOLUTION
% Runs every part of the handout through XFOIL in batch, plots it the way XFOIL does, and
% puts the vortex panel method and the Lab 4 pressure taps (NACA 0021, Re = 5.8e6) on top.
% Run from the xfoil folder.

clear; close all
cd(fileparts(mfilename('fullpath')))

XF     = './xfoil';                % XFOIL launcher
labdir = '../Pressure_tap_lab';
Re     = 5.8e6;                    % the lab's highest Reynolds number (data_Re3)
al     = 0:2:30;                   % ASEQ 0 30 2
aCp    = [0 10];                   % angles the handout saves C_p at
n      = 160;                      % PANE

%% Wind tunnel: data_Re3
D   = readmatrix(fullfile(labdir, 'data_Re3.txt'), 'NumHeaderLines', 1);
aoa = D(:,1);  q = 0.5*D(:,3).*D(:,2).^2;  p = D(:,6:end);
c   = 0.17;  s = 0.255;            % model chord and span [m]

addpath(labdir)
cl_tap = zeros(size(aoa));
for i = 1:numel(aoa)
    [~, ~, ~, ny] = airfoil_normals(aoa(i));
    cl_tap(i) = -sum(p(i,:).*ny(:).')/(q(i)*c);     % taps: the section at mid-span
end
[xt, ~] = airfoil_normals(0);
rmpath(labdir)
cl_bal = D(:,4)./(q*c*s);          % balance: the whole AR = 1.5 wing
Cp_tap = p./q;
x_tap  = xt(:).'/c;
loop   = [1:32 1];                 % taps: TE -> bottom -> LE -> top -> TE

%% Vortex panel method (linear gamma, exact integrals -- vortex_panel_method_solution.m)
[cl_pan, Cp_pan, x_pan] = linvortex([0 0 21], n, al, aCp);

%% XFOIL, parts 1-4
pol_i = xfoil_polar(XF, '0021', 0,  al);      % part 1: inviscid
pol_v = xfoil_polar(XF, '0021', Re, al);      % part 3: viscous
pol_c = xfoil_polar(XF, '4421', Re, al);      % part 4: cambered
cp_i  = xfoil_cp(XF, '0021', 0,  aCp);
cp_v  = xfoil_cp(XF, '0021', Re, aCp);
cp_c  = xfoil_cp(XF, '4421', Re, aCp);
xy    = xfoil_coords(XF, '0021');

%% XFOIL, part 5: boundary layer at 4 deg
bl = { {},                 'natural, N_{crit} = 9'
       {'XTR 0.05 0.05'},  'trip at 5%'
       {'N 4'},            'N_{crit} = 4'
       {'N 12'},           'N_{crit} = 12' };
for k = 1:size(bl, 1)
    B(k) = xfoil_bl(XF, '0021', Re, 4, bl{k,1}); 
end

%% Figure 1 -- parts 1 & 3: lift curve (PPLO)
col = lines(4);
figure('Color', 'w', 'Name', 'Parts 1 & 3: lift curve'); hold on; grid on
plot(al, cl_pan,             '-',  'Color', col(1,:), 'LineWidth', 4)    % under XFOIL inviscid
plot(pol_i(:,1), pol_i(:,2), 'o-', 'Color', col(2,:))
plot(pol_v(:,1), pol_v(:,2), 's-', 'Color', col(3,:))
plot(aoa, cl_tap,            'k^-', 'MarkerFaceColor', 'k')
plot(aoa, cl_bal,            'k^--')
plot(al, 2*pi*deg2rad(al),   'k:')
xlim([0 30]); xlabel('\alpha (deg)'); ylabel('c_l')
legend('vortex panels', 'XFOIL inviscid', 'XFOIL viscous', 'tunnel, taps (section)', ...
       'tunnel, balance (AR 1.5 wing)', '2\pi\alpha', 'Location', 'northwest')
title(sprintf('NACA 0021,  Re = %.1e', Re))

%% Figure 2 -- part 2: CPV, XFOIL inviscid
% Pressure has no direction; the arrows are the FORCE it puts on the surface, -C_p n per unit
% area (n = outward normal).  C_p > 0 pushes in, C_p < 0 (suction) pulls out.
figure('Color', 'w', 'Name', 'Part 2: CPV', 'Position', [100 100 1100 360])
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact')
[~, t] = gradient(xy);  t = t./hypot(t(:,1), t(:,2));
nv = [t(:,2) -t(:,1)];                    % outward normal (XFOIL goes counter-clockwise)
sc = 0.08;                                % arrow length per unit C_p
for k = 1:numel(aCp)
    nexttile; hold on
    Cp   = cp_i{k}(:,2);
    base = xy + sc*max(Cp, 0).*nv;        % pressure arrows end on the surface
    j    = 1:2:size(xy, 1);
    fill(xy(:,1), xy(:,2), [0.9 0.9 0.9])
    u    = -sc*Cp.*nv;
    sk   = j(Cp(j) <  0);  quiver(base(sk,1), base(sk,2), u(sk,1), u(sk,2), 0, 'r')
    pr   = j(Cp(j) >= 0);  quiver(base(pr,1), base(pr,2), u(pr,1), u(pr,2), 0, 'b')
    quiver(-0.2 - 0.2*cosd(aCp(k)), -0.2*sind(aCp(k)), 0.2*cosd(aCp(k)), 0.2*sind(aCp(k)), 0, ...
           'k', 'LineWidth', 1.5, 'MaxHeadSize', 0.8)
    text(-0.4, -0.1, 'V_\infty')
    axis equal off
    legend('', 'C_p < 0: pulls out', 'C_p > 0: pushes in', 'Location', 'south', 'NumColumns', 2)
    title({sprintf('\\alpha = %d^\\circ,  C_{p,min} = %.2f', aCp(k), min(Cp)), 'force on the surface, -C_p n'})
end

%% Figure 3 -- parts 1 & 3: C_p, everything on one plot
figure('Color', 'w', 'Name', 'Parts 1 & 3: C_p', 'Position', [100 100 1000 420])
for k = 1:numel(aCp)
    subplot(1, 2, k); hold on; grid on
    plot(x_pan, Cp_pan(:,k),         '-', 'Color', col(1,:), 'LineWidth', 1.5)
    plot(cp_i{k}(:,1), cp_i{k}(:,2), '-', 'Color', col(2,:))
    plot(cp_v{k}(:,1), cp_v{k}(:,2), '-', 'Color', col(3,:))
    plot(x_tap(loop), Cp_tap(aoa == aCp(k), loop), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4)
    set(gca, 'YDir', 'reverse'); ylim([-4 1.2])
    xlabel('x/c'); ylabel('C_p'); title(sprintf('NACA 0021,  \\alpha = %d^\\circ', aCp(k)))
    legend('vortex panels', 'XFOIL inviscid', 'XFOIL viscous', 'tunnel taps', 'Location', 'southeast')
end

%% Figure 4 -- part 4: NACA 4421 vs 0021, both viscous
figure('Color', 'w', 'Name', 'Part 4: camber', 'Position', [100 100 1000 700])
for k = 1:numel(aCp)
    subplot(2, 2, k); hold on; grid on
    plot(cp_v{k}(:,1), cp_v{k}(:,2), '-', 'Color', col(3,:))
    plot(cp_c{k}(:,1), cp_c{k}(:,2), '-', 'Color', col(4,:), 'LineWidth', 1.5)
    set(gca, 'YDir', 'reverse')
    xlabel('x/c'); ylabel('C_p'); title(sprintf('\\alpha = %d^\\circ', aCp(k)))
    legend('0021', '4421', 'Location', 'southeast')
end
subplot(2, 2, 3); hold on; grid on
plot(pol_v(:,1), pol_v(:,2), 's-', 'Color', col(3,:))
plot(pol_c(:,1), pol_c(:,2), 'd-', 'Color', col(4,:))
xlabel('\alpha (deg)'); ylabel('c_l'); legend('0021', '4421', 'Location', 'southeast')
subplot(2, 2, 4); hold on; grid on
plot(pol_v(:,3), pol_v(:,2), 's-', 'Color', col(3,:))
plot(pol_c(:,3), pol_c(:,2), 'd-', 'Color', col(4,:))
xlabel('c_d'); ylabel('c_l'); legend('0021', '4421', 'Location', 'southeast')

%% Figure 5 -- part 5: boundary layer, NACA 0021 at 4 deg
figure('Color', 'w', 'Name', 'Part 5: boundary layer', 'Position', [100 100 1100 480])
tiledlayout(1, 2, 'TileSpacing', 'compact')
qty = {'Cf', 'skin friction  C_f'; 'Dstar', 'displacement thickness  \delta^*/c'};
for f = 1:2
    nexttile; hold on; grid on
    for k = 1:numel(B)
        h(k) = plot(B(k).top.x, B(k).top.(qty{f,1}), '-',  'Color', col(k,:), 'LineWidth', 1.2); %#ok<SAGROW>
        plot(B(k).bot.x, B(k).bot.(qty{f,1}), '--', 'Color', col(k,:))
    end
    xlim([0 1]); xlabel('x/c'); ylabel(qty{f,2})
end
ylim(nexttile(1), [0 0.01])
h(end+1) = plot(NaN, NaN, 'k-');  h(end+1) = plot(NaN, NaN, 'k--');
leg = arrayfun(@(k) sprintf('%s:  transition x/c = %.2f top, %.2f bottom,  c_d = %.5f', bl{k,2}, ...
               B(k).pol(6), B(k).pol(7), B(k).pol(3)), 1:numel(B), 'UniformOutput', false);
lg = legend(h, [leg, {'top surface', 'bottom surface'}], 'NumColumns', 2);  lg.Layout.Tile = 'south';

%% Numbers
fit = @(a, cl) polyfit(deg2rad(a(a <= 10)), cl(a <= 10), 1);
P = {al(:), cl_pan(:); pol_i(:,1), pol_i(:,2); pol_v(:,1), pol_v(:,2); aoa, cl_tap; aoa, cl_bal};
nm = {'vortex panels', 'XFOIL inviscid', 'XFOIL viscous', 'tunnel taps', 'tunnel balance'};
fprintf('\n%-16s %10s %16s %10s %8s\n', '', 'c_l(10)', 'dc_l/da [1/rad]', 'c_l,max', 'at deg')
for k = 1:numel(nm)
    a = P{k,1};  cl = P{k,2};  sl = fit(a, cl);  [m, im] = max(cl);
    fprintf('%-16s %10.3f %16.2f %10.3f %8g\n', nm{k}, interp1(a, cl, 10), sl(1), m, a(im))
end
fprintf('%-16s %10.3f %16.2f\n', '2 pi alpha', 2*pi*deg2rad(10), 2*pi)

%% ---------------- XFOIL plumbing -------------------------------------------------------
function P = xfoil_polar(XF, foil, Re, al)
% Polar over an alpha sweep.  Re = 0 runs inviscid.  Columns: alpha CL CD CDp CM Top_Xtr Bot_Xtr
f   = 'xf_polar.txt';
cmd = [xfoil_start(foil, Re), {'PACC', f, '', sprintf('ASEQ %g %g %g', al(1), al(end), al(2)-al(1)), ...
       'PACC', '', 'QUIT'}];
xfoil_run(XF, cmd, {f});
P = xfoil_readpolar(f);
end

function C = xfoil_cp(XF, foil, Re, alphas)
% Surface C_p (columns x/c, C_p) at each alpha, ramping up from 0 so the viscous solver converges
cmd = xfoil_start(foil, Re);  f = {};
for k = 1:numel(alphas)
    f{k} = sprintf('xf_cp%d.txt', k);   %#ok<AGROW>
    cmd  = [cmd, {'ALFA 0'}];                                    %#ok<AGROW>
    if alphas(k) > 0, cmd = [cmd, {sprintf('ASEQ 2 %g 2', alphas(k))}]; end   %#ok<AGROW>
    cmd  = [cmd, {['CPWR ' f{k}]}];                              %#ok<AGROW>
end
xfoil_run(XF, [cmd, {'', 'QUIT'}], f);
C = cellfun(@(g) readmatrix(g, 'FileType', 'text', 'NumHeaderLines', 1), f, 'UniformOutput', false);
end

function xy = xfoil_coords(XF, foil)
% Paneled airfoil, same points and order as CPWR (TE -> top -> LE -> bottom -> TE)
f = 'xf_foil.dat';
xfoil_run(XF, {'PLOP', 'G F', '', ['NACA ' foil], 'PANE', ['SAVE ' f], 'QUIT'}, {f});
xy = readmatrix(f, 'FileType', 'text', 'NumHeaderLines', 1);
end

function B = xfoil_bl(XF, foil, Re, a, vpar)
% Boundary layer on each surface (B.top, B.bot: x, Dstar, Theta, Cf, H) plus the polar line
f   = {'xf_polar.txt', 'xf_bl.txt'};
cmd = [xfoil_start(foil, Re), {'VPAR'}, vpar, {'', 'PACC', f{1}, '', sprintf('ALFA %g', a), 'PACC', ...
       ['DUMP ' f{2}], '', 'QUIT'}];
xfoil_run(XF, cmd, f);
B.pol = xfoil_readpolar(f{1});
M = readmatrix(f{2}, 'FileType', 'text', 'NumHeaderLines', 1);
M = M(~isnan(M(:,9)), :);                % drop the wake (its rows are shorter)
T = array2table(M(:,[2 5 6 7 8]), 'VariableNames', {'x', 'Dstar', 'Theta', 'Cf', 'H'});
B.top = T(M(:,4) >= 0, :);               % DUMP runs TE -> top -> LE -> bottom -> TE,
B.bot = T(M(:,4) <  0, :);               % and Ue/Vinf changes sign at the stagnation point
delete('*.bl')                           % scratch files XFOIL leaves behind
end

function cmd = xfoil_start(foil, Re)
cmd = {'PLOP', 'G F', '', ['NACA ' foil], 'PANE', 'OPER'};     % graphics off
if Re > 0, cmd = [cmd, {sprintf('VISC %g', Re), 'ITER 200'}]; end
end

function P = xfoil_readpolar(f)
fid = fopen(f);
C   = textscan(fid, repmat('%f', 1, 9), 'HeaderLines', 12, 'CollectOutput', true);
fclose(fid);
P = C{1};
end

function xfoil_run(XF, cmd, outfiles)
for k = 1:numel(outfiles)                            % XFOIL will not overwrite silently
    if exist(outfiles{k}, 'file'), delete(outfiles{k}); end
end
fid = fopen('xf_cmd.txt', 'w');  fprintf(fid, '%s\n', cmd{:});  fclose(fid);
system(sprintf('%s < xf_cmd.txt > xf_log.txt 2>&1', XF));
for k = 1:numel(outfiles)
    assert(exist(outfiles{k}, 'file') == 2, 'XFOIL did not write %s -- read xf_log.txt', outfiles{k})
end
end

%% ---------------- Vortex panel method (from vortex_panel_method_solution.m) ------------
function [cl, Cp, xcp] = linvortex(code, n, alphas, aCp)
% Linear-strength vortex panels, V = c = 1.  c_l over alphas; C_p (one column per aCp)
[X, Y] = naca4(code, n);
xcp = (X(1:end-1) + X(2:end))/2;  ycp = (Y(1:end-1) + Y(2:end))/2;
dx = diff(X);  dy = diff(Y);  S = hypot(dx, dy);
tx = dx./S;  ty = dy./S;  nx = -dy./S;  ny = dx./S;

An = zeros(n, n+1);  At = zeros(n, n+1);
for i = 1:n
    for j = 1:n
        P1 = [X(j) Y(j)];  P2 = [X(j+1) Y(j+1)];  P = [xcp(i) ycp(i)];
        v1 = panelvel(P1, P2, 1, 0, P);
        v2 = panelvel(P1, P2, 0, 1, P);
        An(i,j)   = An(i,j)   + v1*[nx(i); ny(i)];
        An(i,j+1) = An(i,j+1) + v2*[nx(i); ny(i)];
        At(i,j)   = At(i,j)   + v1*[tx(i); ty(i)];
        At(i,j+1) = At(i,j+1) + v2*[tx(i); ty(i)];
    end
end

cl = zeros(size(alphas));  Cp = zeros(n, numel(aCp));
for k = 1:numel(alphas)
    a = alphas(k);
    A = An;  b = -(cosd(a)*nx + sind(a)*ny).';
    A(n+1, :) = 0;  b(n+1) = 0;
    A(n+1, [1 n+1]) = 1;                             % Kutta
    g = A\b(:);
    cl(k) = 2*sum((g(1:n) + g(2:n+1))/2 .* S.');
    if any(aCp == a)
        Vt = (cosd(a)*tx + sind(a)*ty).' + At*g;
        Cp(:, aCp == a) = 1 - Vt.^2;
    end
end
end

function [X, Y] = naca4(code, n)
% NACA 4-digit, cosine spacing, TE -> bottom -> LE -> top -> TE
m = code(1)/100;  p = code(2)/10;  t = code(3)/100;
x  = (1 - cos(linspace(0, pi, n/2 + 1)))/2;
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

function v = panelvel(P1, P2, g1, g2, P)
% Velocity at P from a linear-strength vortex panel P1 -> P2 (exact integrals)
d = P2 - P1;  L = norm(d);  t = d/L;  nv = [-d(2) d(1)]/L;
r = P - P1;  x = r*t.';  z = r*nv.';
r1 = hypot(x, z);  r2 = hypot(x - L, z);
if abs(z) < 1e-12
    dth = pi*(x > 0 && x < L);
    zA0 = dth;  zA1 = x*dth;
else
    zA0 = atan2(z, x - L) - atan2(z, x);
    zA1 = x*zA0 - z*log(r1/r2);
end
B0 = log(r1/r2);  B1 = x*B0 - L + z*zA0;
u =  ( g1*zA0 + (g2 - g1)*zA1/L )/(2*pi);
w = -( g1*B0  + (g2 - g1)*B1 /L )/(2*pi);
v = u*t + w*nv;
end
