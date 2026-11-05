function potential_flow_elements
% Elementary potential flows, and superposition.  MATLAB version of 03_potential_flow_elements.
%
%   keys:  1 source (negative strength = sink) · 2 vortex · 3 doublet
%          u  uniform stream on/off,   z  undo,   d  delete everything
%   left-click places the selected element, right-click removes the nearest one.
%   Each element is numbered; its slider below the plot sets its strength (units of 2*pi).
%   Vortex strength is positive CLOCKWISE, so Gamma > 0 in a stream along +x gives lift
%   L' = rho*U*Gamma upward.

LIM = 3; N = 220;
STRENGTH = 2*pi;          % default strength; with U=1 this puts features at r ~ 1
U_INF = 1; ALPHA = 0;     % uniform stream speed and angle (radians)

g = linspace(-LIM, LIM, N);
[X, Y] = meshgrid(g, g);
h = g(2) - g(1);

els = struct('kind', {}, 'x', {}, 'y', {}, 'S', {});
kind = 'source'; uniform = true;
KEYS = {'source', 'vortex', 'doublet'};
STYLE.source  = {'+', [0.84 0.15 0.16], 13};
STYLE.sink    = {'x', [0.12 0.47 0.71], 11};     % a source with S < 0
STYLE.vortex  = {'o', [0.17 0.63 0.17], 9};
STYLE.doublet = {'p', [0.58 0.40 0.74], 13};

fig = figure('Name', 'Potential flow elements', 'Color', 'w', 'Position', [60 60 1450 720], ...
             'WindowButtonDownFcn', @onClick, 'WindowKeyPressFcn', @onKey);
for i = 1:3
    ax(i) = axes(fig, 'Position', [0.03 + 0.33*(i-1), 0.33, 0.29, 0.56]); %#ok<AGROW>
    hold(ax(i), 'on'); box(ax(i), 'on');
end
header = annotation(fig, 'textbox', [0 0.91 1 0.08], 'EdgeColor', 'none', ...
                    'HorizontalAlignment', 'center', 'FontSize', 11);
panel = uipanel(fig, 'Position', [0.03 0.01 0.94 0.25], 'BorderType', 'none', ...
                'BackgroundColor', 'w');
redraw();

    % ---- superposition, literally a sum ------------------------------------------------
    function [u, v, psi, phi] = field()
        u = zeros(size(X)); v = u; psi = u; phi = u;
        if uniform
            ca = cos(ALPHA); sa = sin(ALPHA);
            u = u + U_INF*ca; v = v + U_INF*sa;
            psi = psi + U_INF*(Y*ca - X*sa); phi = phi + U_INF*(X*ca + Y*sa);
        end
        for e = els
            dx = X - e.x; dy = Y - e.y;
            r2 = max(dx.^2 + dy.^2, 1e-9);
            th = atan2(dy, dx);
            k = e.S/(2*pi);
            switch e.kind
                case 'source'
                    u = u + k*dx./r2;       v = v + k*dy./r2;
                    psi = psi + k*th;       phi = phi + 0.5*k*log(r2);
                case 'vortex'                              % clockwise positive
                    u = u + k*dy./r2;       v = v - k*dx./r2;
                    psi = psi + 0.5*k*log(r2); phi = phi - k*th;
                case 'doublet'
                    u = u + k*(dy.^2 - dx.^2)./r2.^2; v = v - 2*k*dx.*dy./r2.^2;
                    psi = psi - k*dy./r2;             phi = phi + k*dx./r2;
            end
        end
    end

    % ---- contour levels: evenly spaced, strongest element of `kname` gets 24 rays -------
    % offset by half a step so no level sits on a theta = +-pi cut, and lines match up
    % across it; percentiles ignore the blow-up at the singularities
    function lv = levels(F, kname)
        n = 24; most = 60;
        s = sort(F(:)); lo = s(round(0.02*(end-1))+1); hi = s(round(0.98*(end-1))+1);
        S = abs([els(strcmp({els.kind}, kname)).S]); S = S(S ~= 0);
        if isempty(S)
            lv = linspace(lo, hi, n);
            return
        end
        d = max(S)/n;
        for m = [1 2 3 4 6 8 12 24]      % too many lines -> coarsen by a divisor of n
            if (hi - lo)/(m*d) <= most, break, end
        end
        d = d*m;
        lv = d*((floor(lo/d) - 1 : ceil(hi/d) + 1) + 0.5);
    end

    % blank the grid rows either side of each element's cut, so contour does not stack
    % every level onto that one fake jump
    function F = maskCuts(F, kname)
        for e = els(strcmp({els.kind}, kname))
            F(X < e.x & abs(Y - e.y) < h) = NaN;
        end
    end

    % ---- drawing ------------------------------------------------------------------------
    function redraw()
        [u, v, psi, phi] = field();
        for a = ax, cla(a); end

        if ~isempty(els) || uniform          % nothing to contour on an empty, still field
            contour(ax(1), X, Y, maskCuts(psi, 'source'), levels(psi, 'source'), ...
                    'LineColor', [0.12 0.47 0.71], 'LineWidth', 0.8);
            contour(ax(2), X, Y, maskCuts(phi, 'vortex'), levels(phi, 'vortex'), ...
                    'LineColor', [0.84 0.15 0.16], 'LineWidth', 0.8);
        end
        title(ax(1), 'stream function \psi   (= streamlines)');
        title(ax(2), 'velocity potential \phi   (= equipotentials)');

        speed = hypot(u, v);
        % cap the scale near the singularities, or they wash out the whole picture
        if uniform, vmax = 3*U_INF; else, s = sort(speed(:)); vmax = max(s(round(0.9*end)), 1e-6); end
        imagesc(ax(3), g, g, min(speed, vmax)); set(ax(3), 'YDir', 'normal');
        clim(ax(3), [0 vmax]); colormap(ax(3), parula);
        hs = streamslice(ax(3), X, Y, u, v, 1.1);
        set(hs, 'Color', 'w', 'LineWidth', 0.6);
        title(ax(3), 'velocity field  (colour = speed)');

        for a = ax
            for i = 1:numel(els)
                e = els(i);
                sty = STYLE.(e.kind);
                if strcmp(e.kind, 'source') && e.S < 0, sty = STYLE.sink; end
                plot(a, e.x, e.y, sty{1}, 'Color', sty{2}, 'MarkerSize', sty{3}, 'LineWidth', 2.5);
                text(a, e.x + 0.12, e.y + 0.18, num2str(i), 'Color', sty{2}, ...
                     'FontWeight', 'bold', 'FontSize', 9);
            end
            set(a, 'XLim', [-LIM LIM], 'YLim', [-LIM LIM], 'DataAspectRatio', [1 1 1]);
        end

        onoff = {'OFF', 'ON'};
        net_src = sum([els(strcmp({els.kind}, 'source')).S]);
        circ    = sum([els(strcmp({els.kind}, 'vortex')).S]);
        header.String = {sprintf('tool = %s  [1 source · 2 vortex · 3 doublet]   |   uniform stream %s', ...
                                 upper(kind), onoff{uniform + 1}), ...
                         sprintf('%d elements,  net source = %+.2f,  total circulation = %+.2f   (lift = rho*U*Gamma)', ...
                                 numel(els), net_src, circ)};
        drawnow limitrate
    end

    % one strength slider per element, numbered to match the plot (5 per column)
    function makeSliders()
        delete(panel.Children);
        for i = 1:numel(els)
            c = floor((i-1)/5); r = mod(i-1, 5);
            y = 1 - 0.2*(r + 1) + 0.03;
            uicontrol(panel, 'Style', 'text', 'Units', 'normalized', 'Position', [c/2 y 0.1 0.14], ...
                      'String', sprintf('%d  %s', i, els(i).kind), 'BackgroundColor', 'w', ...
                      'HorizontalAlignment', 'left', 'FontSize', 10);
            val = uicontrol(panel, 'Style', 'text', 'Units', 'normalized', 'Position', [c/2 + 0.4 y 0.06 0.14], ...
                            'String', sprintf('%+.2f', els(i).S/(2*pi)), 'BackgroundColor', 'w', 'FontSize', 10);
            uicontrol(panel, 'Style', 'slider', 'Units', 'normalized', 'Position', [c/2 + 0.1 y 0.29 0.14], ...
                      'Min', -3, 'Max', 3, 'Value', els(i).S/(2*pi), 'SliderStep', [0.05 0.5]/6, ...
                      'Callback', @(src, ~) setStrength(i, src.Value, val));
        end
    end

    function setStrength(i, value, label)
        els(i).S = 2*pi*value;
        label.String = sprintf('%+.2f', value);
        redraw();
    end

    % ---- interaction --------------------------------------------------------------------
    function onClick(~, ~)
        for a = ax
            p = a.CurrentPoint(1, 1:2);
            if all(abs(p) <= LIM)
                if strcmp(fig.SelectionType, 'alt') && ~isempty(els)   % remove the nearest one
                    [dmin, i] = min(hypot([els.x] - p(1), [els.y] - p(2)));
                    if dmin < 0.6, els(i) = []; end
                elseif strcmp(fig.SelectionType, 'normal')
                    els(end+1) = struct('kind', kind, 'x', p(1), 'y', p(2), 'S', STRENGTH);
                end
                makeSliders(); redraw();
                return
            end
        end
    end

    function onKey(~, evt)
        switch evt.Character
            case {'1', '2', '3'}, kind = KEYS{str2double(evt.Character)};
            case 'u', uniform = ~uniform;
            case 'z', if ~isempty(els), els(end) = []; end
            case 'd', els(:) = [];
            otherwise, return
        end
        makeSliders(); redraw();
    end
end
