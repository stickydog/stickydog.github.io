% This function reads in an angle of attack, and returns the
% coordinates of the pressure taps, and their normal vectors
% Claudia Brunner 03/29/2020
% Modified Akhil Borra 9/2026

% OUTPUTS: xtap,ytap tap positions measured from leading edge of airfoil [m]
% nx,ny are the x (freestream) and y (perpendicular) components of the outward surface normals, scaled by
% the surface length each tap acts on [m], i.e. area per unit span
% Plots are only drawn when the function is called without outputs.

function [ xtap, ytap, nx, ny ] = airfoil_normals( aoadeg )

% convert angle of attack to radians
aoa = deg2rad(aoadeg);

% load locations of pressure taps. Make sure the file is in your folder.
load('NACA0021_taps.mat');

% Chord [m] and thickness [-] of the airfoil%
c = 0.17 ;
t = 0.21;

% eqn to generate contour of NACA 4-series airfoil (t as a fraction of chord)%
naca = @(x,t,c) 5 .* t .* c .* (0.2969 .* sqrt(x./c) ...
                - 0.1260 .* (x./c) - 0.3516 .* (x./c).^2 ...
                + 0.2843 .* (x./c).^3 - 0.1015 .* (x./c).^4 );

%% draw NACA airfoil outline

% top half
xs = c .* [0:0.01:1];
ys = naca(xs,t,c);

% bottom half
xs = [xs fliplr(xs)];
ys = [ys -fliplr(ys)];

% Rotate Airfoil to given angle of attack
x_a = xs .* cos(aoa) + ys .* sin(aoa);
y_a = ys .* cos(aoa) - xs .* sin(aoa);

%% read in the pressure tap locations%

% the Taps struct was read in from the 'NACA0021_taps.mat' file
% Taps.dim is in [mm], convert to [m]
X = Taps.dim.x(1:32) / 1000;
Y = Taps.dim.y(1:32) / 1000;

% Rotate Airfoil
xtap = X .* cos(aoa) + Y .* sin(aoa);
ytap = Y .* cos(aoa) - X .* sin(aoa);

%% Find x and y surface normals%
% the size of the surface normals accounts for the size of the area they
% act on, while the ratio between x- and y-component accounts for the slant
% of the surface

%Generate vectors with the coordinates of the neighbouring taps
xL = circshift(xtap,1);
xR = circshift(xtap,-1);

yL = circshift(ytap,1);
yR = circshift(ytap,-1);

% assume that pressure at each tap acts on the area between the halfway
% points to the neighbouring taps. At the leading edge, taps are spaced more
% closely, so the areas they act on are smaller.
% The trailing edge tap needs no special treatment: its neighbours are the
% last taps on the upper and lower surface, which gives the correct
% (small, aft-facing) normal there.
dx = (xR - xL) / 2;
dy = (yL - yR) / 2;

% outward normal times surface length [m]
nx = dy;
ny = dx;

if nargout == 0
    figure
    hold on
    plot(x_a,y_a,'b-');
    plot(xtap,ytap,'bo')
    quiver(xtap,ytap,nx,ny,'b');
    axis equal
    xlabel('x [m]')
    ylabel('y [m]')
end

end
