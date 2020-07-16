%{
Desaturation Sim - Doesn't work
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

classdef Wheel
    %Wheel: Represents the reaction wheels
    %
    %   Constant Properties:
    %       maxMomentum = Maximum Angular momentum that can be supplied (m*n*s)
    %       maxTorque   = Maximum Torque that can be supplied (m*n)
    %       maxVelocity = Maximum angular velocity that can be supplied (rad/sec)
    %       inertia     = Moment of inertia of each wheel (kg*m^2)
    %
    %   Properties:
    %       momentum  = Current momentum vector (m*n*s)
    %       torque    = Current torque vector (m*n*s)
    %       saturated = Current saturation array (bool)
    
    properties (Constant)
        maxMomentum = 3.4e-3 %n*m*s
        maxTorque   = 2e-3 %n*m
        maxVelocity = 7000 * 0.104719755 %rad / sec, vonverts from 7000rpm
        inertia     = Wheel.maxMomentum / Wheel.maxVelocity %kg*m^2
    end
    
    properties
        momentum
        torque
        saturated
    end
    
    methods
            function obj = Wheel()
            
            obj.momentum  = [0; 0; 0];
            obj.torque    = [0; 0; 0];
            obj.saturated = [false; false; false];
            
        end
    end
    
end

