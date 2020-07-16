% Ross Smyth
% 7/28/2019
% Version 0.1
% Run before running Auris ADC sim. Should be run by the main pointing
% budget program and not by itself.
%{
Pointing Budget - Simulates and calculates pointing information on a spacecraft.
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

clc
clearvars -except combine_x_std combine_y_std combine_z_std orb_data

inertia = [81003318.75, -1368024.54, -2504545.93; ...
           -1368024.54, 84475865.36, -1809946.52; ...
           -2504545.93, -1809946.52, 49552447.44;];% g*mm^2
conversion = 1.0e-09;
inertia = inertia * conversion; % kg*m^2

% seconds
starting_time = juliandate(date);

initial_euler = [0, 0, 180]; % Degrees

initial_ang_rate = [0, 0, 0]; % deg/s

%==================== Read stuff in from a TLE=============================
tle = read_tloes('ISS_TLE.txt');

% Seconds
epoch = juliandate(tle.epoch.year, 1, 1) + tle.epoch.day * 86400;

% Meters
semi_major = (((86400 / tle.mean_motion) / (2 * pi))^2 * 398.6e12)^(1 / 3);

% Degrees
true_anomaly = tle.mean_anomaly + (2 * exp(1) - 1 / 4 * exp(3)) * sind(tle.mean_anomaly) + 5 / 4 * exp(2) * sind(2 * tle.mean_anomaly) + 13/12 * exp(3) * sind(3 * tle.mean_anomaly);

%====================== Output and Plots ==================================

out = sim('Auris_ES14.slx'); % Runs simulation

%% Next finding the STD from zero error to know the control accuracy

figure()
plot(out.angle_error)
ylabel('Angle Error from reference (deg)')
title('Spacecraft Attitude Error')
ylim([-10, 10])

settling_time = 250; % Needs to find a way to find settling time programmatically

start_index = find(out.angle_error.Time == settling_time); % Index after settled
end_index = min([find(out.rw_saturated.Data(:, 1), 1), find(out.rw_saturated.Data(:, 2), 1), find(out.rw_saturated.Data(:, 3), 1)]); % Index when saturated

if isempty(end_index) % If never saturates in simulation time
    adc_std = rms(out.angle_error.Data(start_index:end, :));
else
    adc_std = rms(out.angle_error.Data(start_index:end_index, :));
end

refline([0;0;0], adc_std')
refline([0;0;0], -adc_std')
line([200, 200], [-10, 10], 'LineStyle', '--')

x_label = sprintf('X Axis STD, %0.2g deg', adc_std(1));
y_label = sprintf('Y Axis STD, %0.2g deg', adc_std(2));
z_label = sprintf('Z Axis STD, %0.2g deg', adc_std(3));

legend({'X Axis', 'Y Axis', 'Z Axis', x_label, y_label, z_label, 'Settling Time, 250 s'})
saveas(gcf, [pwd, '\Output Plots\angular_error.svg'])

figure()
plot(out.rw_mom)
ylabel('Reaction Wheel Momentum (N*m*s)')
title('Reaction Wheel Momentum')
ylim([-30e-3, 30e-3])
legend({'X Axis', 'Y Axis', 'Z Axis'})

saveas(gcf, [pwd, '\Output Plots\reaction_wheel.svg'])