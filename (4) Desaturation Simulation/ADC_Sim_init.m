% Ross Smyth
% 8/2/2019
% Version 1
% Run before running Auris desaturation sim.
%{
Desaturation Simulation - Simulates a spacecraft's desaturation with magnetorquers.
Copyright (C) 2020 Ross Smyth

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
%}
clc, clear

inertia = [81003318.75, -1368024.54, -2504545.93; ...
           -1368024.54, 84475865.36, -1809946.52; ...
           -2504545.93, -1809946.52, 49552447.44;];% g*mm^2
conversion = 1.0e-09;
inertia = inertia * conversion; % kg*m^2

% seconds
starting_time = juliandate(date);

initial_euler = [74, 36, 33]; % Degrees

initial_ang_rate = [15, 15, 15]; % deg/s

magnetic_dipole = 0.66; % A*m^2

%==================== Read stuff in from a TLE=============================
tle = read_tloes('ISS_TLE.txt');

% Seconds
epoch = juliandate(tle.epoch.year, 1, 1) + tle.epoch.day * 86400;

% Meters
semi_major = (((86400 / tle.mean_motion) / (2 * pi))^2 * 398.6e12)^(1 / 3);

% Degrees
true_anomaly = tle.mean_anomaly + (2 * exp(1) - 1 / 4 * exp(3)) * sind(tle.mean_anomaly) + 5 / 4 * exp(2) * sind(2 * tle.mean_anomaly) + 13/12 * exp(3) * sind(3 * tle.mean_anomaly);

%====================== Output and Plots ==================================

%out = sim('Auris_Desaturation.slx'); % Runs simulation
