%{
Pointing Sim - Doesn't work
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

classdef Earth
    %Earth: Properties of Earth
    %
    %   Properties:
    %       radius       = Equitorial radius in meters
    %       mass         = Mass in kilograms
    %       parameter    = Orbital parameter
    %       eccentricity = Ratio of geometric minor axis to it's major axis 
    properties (Constant)
        radius         = 6378136.6
        mass           = 5.9723e24
        parameter      = 6.67408e-11*Earth.mass
        eccentricitity = 0.9966
    end
end

