%% Prandtl's lifting line

%
% Here we get the circultation of wing and work out the downwash, the
% effective angle, the lift, the induced drag, and the twist the wing must have.
%
% Lines marked "% Fill in" are the equations you write.  The script will not run until
% every one of them is filled in.

clear; close all

U  = 1;  rho = 1;     % freestream speed, density
B  = 8;  AR  = 8;     % span, aspect ratio
S  = B^2/AR;          % wing area
CL = 0.5;             % lift coefficient the wing has to carry

%% 1. The wing is a row of horseshoe vortices

N  = 8;
ye = linspace(-B/2, B/2, N + 1);          % panel edges    -> trailing vortices
yc = (ye(1:end-1) + ye(2:end))/2;         % panel centres  -> control points
fprintf('edges   '); fprintf('%6.2f', ye); fprintf('\n');
fprintf('centres '); fprintf('%6.2f', yc); fprintf('\n\n');

G  = sqrt(1 - (2*yc/B).^2);               % some loading
dG = diff([0 G 0]);   % Fill in:  strength shed at each edge, tips included

% draw it, each trailing vortex as thick as the circulation it sheds
ys = linspace(-B/2, B/2, 300);
cs = 4*S/(pi*B)*sqrt(1 - (2*ys/B).^2);    % an elliptic planform, for the picture
green = [0.17 0.63 0.17];
figure('Color', 'w', 'Position', [100 100 900 450]); hold on
fill([ys fliplr(ys)], [-0.25*cs fliplr(0.75*cs)], 0.9*[1 1 1], 'EdgeColor', 'none', 'HandleVisibility', 'off')
plot([-B/2 B/2], [0 0], 'k-', 'LineWidth', 2, 'DisplayName', 'bound vortices (quarter chord)')
for j = 1:N+1
    plot([ye(j) ye(j)], [0 4], 'Color', green, 'LineWidth', 0.5 + 6*abs(dG(j))/max(abs(dG)), ...
         'HandleVisibility', 'off')
end
plot(nan, nan, 'Color', green, 'LineWidth', 2, 'DisplayName', 'trailing vortices')
plot(yc, 0*yc, 'rx', 'MarkerSize', 9, 'LineWidth', 2.5, 'DisplayName', 'control points')
set(gca, 'YDir', 'reverse'); ylim([-1.2 4])     % downstream is down the page
xlabel('y  (span)'); ylabel('x  (downstream)')
legend('Location', 'south', 'Orientation', 'horizontal', 'Box', 'off')

%% 2. Downwash, lift and induced drag of three loadings
% Each trailing vortex is semi-infinite, so it induces HALF what a full line vortex would:
%   w(y_i) = sum_j  dGamma_j / (4 pi (y_i - y_j))
% Vortices on edges, downwash at centres, so y_i = y_j never happens (the 1/4-3/4 trick again).
%   L   = rho U int Gamma dy   ->  C_L  = 2 int Gamma dy / (U S)
%   D_i = rho int Gamma w dy   ->  C_Di = 2 int Gamma w dy / (U^2 S)
names  = {'elliptic', 'root-loaded', 'tip-loaded'};
shapes = {@(e) sqrt(1 - e.^2), ...
          @(e) 1 - e.^2, ...
          @(e) sqrt(1 - e.^2).*(1 + 0.6*(2*e.^2 - 1))};

N  = 200;
ye = linspace(-B/2, B/2, N + 1);
yc = (ye(1:end-1) + ye(2:end))/2;
dy = diff(ye);
m  = abs(yc) < 0.95*B/2;       % the outermost panels can't resolve the square-root tip: don't plot them

Gs = zeros(3, N);  ws = zeros(3, N);  CLs = zeros(1, 3);  CDs = zeros(1, 3);
for k = 1:3
    G = shapes{k}(2*yc/B);
    G = G*0.5*CL*U*S/sum(G.*dy);          % scale it so the wing carries C_L

    dG = diff([0 G 0]);   % Fill in:  strength shed at each edge
    w  = zeros(1, N);
    for i = 1:N
        w(i) = sum(dG./(4*pi*(yc(xi) - ye)));   % Fill in: Downwash at each point on span
    end

    CLs(k) = 2*sum(G.*dy)/(U*S);   % Fill in - Cl
    CDs(k) = 2*sum(G.*w.*dy)/(U^2*S);   % Fill in - Cdi
    Gs(k,:) = G;  ws(k,:) = w;
end

% the elliptic wing: both classical results
fprintf('alpha_i at the root   %.4f deg\n', rad2deg(ws(1,N/2)/U));
fprintf('C_L / (pi AR)         %.4f deg\n\n', rad2deg(CLs(1)/(pi*AR)));
fprintf('C_Di                  %.5f\n', CDs(1));
fprintf('C_L^2 / (pi AR)       %.5f\n\n', CLs(1)^2/(pi*AR));

%% 3. So what wing is this?
% A thin airfoil at alpha_eff has cl = 2 pi alpha_eff, and cl = 2 Gamma/(U c), so
%   alpha_eff = Gamma/(pi U c)        alpha = alpha_eff + alpha_i
% Hand over the elliptic Gamma and the twist comes out as an answer, not an input.
G = Gs(1,:);  w = ws(1,:);
c_ell = 4*S/(pi*B)*sqrt(1 - (2*yc/B).^2);         % elliptic planform
c_rec = S/B*ones(1, N);                           % rectangular planform, same area

figure('Color', 'w', 'Position', [150 100 1000 650])
subplot(2,2,1)
plot(2*yc/B, G, 'k-'); grid on
xlabel('y / (b/2)'); ylabel('\Gamma'); title(sprintf('elliptic loading, C_L = %.1f', CL))
subplot(2,2,2)
plot(2*yc(m)/B, rad2deg(w(m)/U), 'k-', [-1 1], rad2deg(CL/(pi*AR))*[1 1], 'r--'); grid on
ylim([0 2]); legend('code', 'C_L/\pi AR')
xlabel('y / (b/2)'); ylabel('\alpha_i (deg)'); title('downwash is the same everywhere')

planforms = {'elliptic planform', 'rectangular planform'};
chords    = {c_ell, c_rec};
for k = 1:2
    c = chords{k};
    a_eff = G./(pi*U*c);   % Fill in:  cl = 2 Gamma/(U c) = 2 pi alpha_eff
    a_geo = a_eff + w/U;   % Fill in:  geometric angle the strip must be set at
    subplot(2,2,3); hold on; plot(2*yc/B, c, 'DisplayName', planforms{k})
    subplot(2,2,4); hold on; plot(2*yc(m)/B, rad2deg(a_geo(m)), 'DisplayName', planforms{k})
    fprintf('%-22s alpha root %5.2f deg,  alpha at 95%% span %5.2f deg\n', ...
            planforms{k}, rad2deg(a_geo(N/2)), rad2deg(a_geo(find(m, 1, 'last'))));
end
subplot(2,2,3); grid on; ylim([0 1.5]); legend('Location', 'south')
xlabel('y / (b/2)'); ylabel('c'); title('chord')
subplot(2,2,4); grid on; legend('Location', 'south')
xlabel('y / (b/2)'); ylabel('\alpha (deg)'); title('twist needed for elliptic loading')

%% 4. Any other loading is worse
% Span efficiency: how far the induced drag sits above the elliptic value,
%   e = C_L^2 / (pi AR C_Di)
e = CLs.^2./(pi*AR*CDs);   % Fill in:  span efficiency

fprintf('\nloading         C_L      C_Di        e\n');
figure('Color', 'w', 'Position', [200 150 1300 400])
for k = 1:3
    fprintf('%-14s %6.3f   %.5f   %6.3f\n', names{k}, CLs(k), CDs(k), e(k));
    subplot(1,3,1); hold on; plot(2*yc/B, Gs(k,:), 'DisplayName', names{k})
    subplot(1,3,2); hold on; plot(2*yc(m)/B, rad2deg(ws(k,m)/U), 'DisplayName', names{k})
    subplot(1,3,3); hold on; plot(2*yc(m)/B, rho*Gs(k,m).*ws(k,m), ...    % dD_i/dy = rho Gamma w
                                  'DisplayName', sprintf('%s,  C_{D_i} = %.5f', names{k}, CDs(k)))
end
subplot(1,3,1); grid on; legend('Location', 'south')
xlabel('y / (b/2)'); ylabel('\Gamma'); title('same C_L, same area under each curve')
subplot(1,3,2); grid on; yline(0, 'k', 'HandleVisibility', 'off'); legend('Location', 'north')
xlabel('y / (b/2)'); ylabel('\alpha_i (deg)'); title('downwash')
subplot(1,3,3); grid on; yline(0, 'k', 'HandleVisibility', 'off'); legend('Location', 'north', 'FontSize', 8)
xlabel('y / (b/2)'); ylabel('dD_i/dy'); title('induced drag: C_{D_i} is the area')
