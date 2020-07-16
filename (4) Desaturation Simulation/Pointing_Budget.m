% Ross Smyth
% crsmyth@mtu.edu
% Version 0.5
% 2019/07/28
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

clear, clc, close all

% Constants
orb_data = xlsread('ADC-A-B01-Pointing_Budget.xlsx', 1);
[det_data, det_txt] = xlsread('ADC-A-B01-Pointing_Budget.xlsx', 2);
[con_data, con_txt] = xlsread('ADC-A-B01-Pointing_Budget.xlsx', 3);

interval = -10000:0.1:10000;

spacecraft.alt = orb_data(1, 1) * 1000;

% Makes PDF's for each angular-based sensor and puts them in a cell array
ang_func = {};
for i=1:length(det_data(:, 1))
    % Grabs a row (corresponds to a sensor)
    sensor = det_data(i, :);
    % Makes sure it isn't blank
    if any(~isnan(sensor(1:3)))
        pdf_funcs = cell(1, 3);
        
        % One PDF for each axis
        pdf_funcs{1} = @(x) normpdf(x, 0, sensor(1) / sensor(4));
        pdf_funcs{2} = @(x) normpdf(x, 0, sensor(2) / sensor(4));
        pdf_funcs{3} = @(x) normpdf(x, 0, sensor(3) / sensor(4));
        
        % Indexes each so the name can be accessed later
        ang_func{1, end + 1} = pdf_funcs;
        ang_func{2, end} = i;
    end
end

% Makes list of position-based angular uncertainty
% first calculates the total distance between them (at a min for most
% uncertainty)

% Converts to 1-sigma
pos_unc = det_data(:, 9) ./ det_data(:, 10);
% Gets rid of blank spaces
pos_unc(isnan(pos_unc)) = [];
% inputs angular based uncertainty (based on target)
pos_unc = atand(pos_unc / 6371000) * 3600;

% Combines uncertainty (PDF convolution)
combined_unc = ones(3, length(interval));
x_unc = [];
y_unc = [];
z_unc = [];
for i=1:length(ang_func(1, :))
    % Calculate discrete PDF's
    % If is nan (sensor doesn't measure that axis) it ignores it.
    sensor_x = ang_func{1, i}{1}(interval);
    if any(isnan(sensor_x))
        sensor_x = ones(1, length(sensor_x));
    end
    
    sensor_y = ang_func{1, i}{2}(interval);
    if any(isnan(sensor_y))
        sensor_y = ones(1, length(sensor_y));
    end
    
    sensor_z = ang_func{1, i}{3}(interval);
    if any(isnan(sensor_z))
        sensor_z = ones(1, length(sensor_z));
    end
    
    % norm the PDF's
    sensor_x = sensor_x / trapz(sensor_x);
    sensor_y = sensor_y / trapz(sensor_y);
    sensor_z = sensor_z / trapz(sensor_z);
    
    % Adds PDF's to matrices for plotting. If it is constant (aka the
    % sensor doesn't read that axis) it puts it in as nan so it doesn't
    % display
    x_unc(i, :) = sensor_x * ~~range(sensor_x);
    if ~range(sensor_x)
        x_unc(i, :) = nan;
    end
    y_unc(i, :) = sensor_y * ~~range(sensor_y);
    if ~range(sensor_y)
        y_unc(i, :) = nan;
    end
    z_unc(i, :) = sensor_z * ~~range(sensor_z);
    if ~range(sensor_z)
        z_unc(i, :) = nan;
    end
    
    % Convolute discrete PDF's
    combined_unc(1, :) = combined_unc(1, :) .* sensor_x;
    combined_unc(2, :) = combined_unc(2, :) .* sensor_y;
    combined_unc(3, :) = combined_unc(3, :) .* sensor_z;
    
    % norm the PDF's
    combined_unc(1, :) = combined_unc(1, :) / trapz(combined_unc(1, :) );
    combined_unc(2, :) = combined_unc(2, :) / trapz(combined_unc(2, :) );
    combined_unc(3, :) = combined_unc(3, :) / trapz(combined_unc(3, :) );
end

% Calculate discrete std of each axis
% Remember that it is calculating the 1-sigma uncertainty, not 3-sigma
combine_x_std = sqrt(sum(interval.^2 .* combined_unc(1, :)));
combine_y_std = sqrt(sum(interval.^2 .* combined_unc(2, :)));
combine_z_std = sqrt(sum(interval.^2 .* combined_unc(3, :)));

% Adds positional error, this only adds error so rss propagation is used
combine_x_std = sqrt(sum([combine_x_std, pos_unc].^2));
combine_y_std = sqrt(sum([combine_y_std, pos_unc].^2));
combine_z_std = sqrt(sum([combine_z_std, pos_unc].^2));

% Plotting the sensor axes
figure()
plot(interval, x_unc)
title('X axis sensor probability density functions')
xlabel('arcseconds')
ylabel('Probability')
legend(det_txt([ang_func{2, :}] + 1))
saveas(gcf, [pwd, '\Output Plots\x_axis.svg'])

figure()
plot(interval, y_unc)
title('Y axis sensor probability density functions')
xlabel('arcseconds')
ylabel('Probability')
legend(det_txt([ang_func{2, :}] + 1))
saveas(gcf, [pwd, '\Output Plots\y_axis.svg'])

figure()
plot(interval, z_unc)
title('Z axis sensor probability density functions')
xlabel('arcseconds')
ylabel('Probability')
legend(det_txt([ang_func{2, :}] + 1))
saveas(gcf, [pwd, '\Output Plots\z_axis.svg'])

%% Plotting the pointing PDF and STD plotty thing
interval = -10:0.1:10;

y_pdf = normpdf(interval, 0, combine_x_std);
x_pdf = normpdf(interval, 0, combine_y_std);

hold on
figure()
det_unc_pl = scatterhist(interval, interval);
title({'Auris attitude determination uncertainty'; 'cross-antenna plane towards target'})
xlabel('arcseconds')
ylabel('arcseconds')

cen_axis = det_unc_pl(1);
x_axis = det_unc_pl(2);
y_axis = det_unc_pl(3);

axes(cen_axis)
cen_axis.Children.YData = combine_y_std * sin(0:0.01:(2 * pi));
cen_axis.Children.XData = combine_x_std * cos(0:0.01:(2 * pi));
cen_axis.Children.LineStyle = '-';
cen_axis.Children.Marker = 'none';

axes(x_axis)
plot(interval, x_pdf)

axes(y_axis)
plot(interval, y_pdf)
hold off
y_axis.View = [-270, 90];

% Saves to put into Excel. Could automate this but maybe later.
saveas(gcf, [pwd, '\Output Plots\combined.svg'])

%run('ADC_Sim_init')