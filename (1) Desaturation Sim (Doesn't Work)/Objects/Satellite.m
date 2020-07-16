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

classdef Satellite
    %Satellite: Properties of the satellite
    %
    %   Constant Properties:
    %       altitude               = Altitude in above Earth (meters)
    %       inclination            = Orbital inclination (degrees)
    %       linearSpeed            = Linear orbital speed (meters/second)
    %       maxArea                = The largest area on the satellite
    %       orbitalAngularVelocity = Angluar orbital speed (radians/second)
    %       radius                 = Radius (meters)
    %   
    %   Properties:
    %       angles         = Where the payload is facing with Euler angles
    %       centerMass     = The center of mass of the satellite (meters)
    %       centerPressure = The center of pressure of the satellite (meters)
    %       dt             = Time delta for the simulation
    %       index          = Stores the index of the current loop 
    %       inertia        = Mass moment of inertia tensor (kg*m^2)
    %       magneticMoment = Torque Coils total magnetic moment vector (A*m^2)
    %       momentum       = Satellite's angular momentum
    %       position       = Current position of the Satellite 
    %       target         = The position of the pointing target
    %       time           = Time vector
    %       unitVector     = Unit vector where payload is facing
    %       wheel          = Reaction wheel class
    %                        See also Wheel

    properties (Constant, Access = private)
        earth = Earth
    end
    
    properties (Constant)
        altitude               = 400 * 1000
        inclination            = 50
        linearSpeed            = sqrt(Satellite.earth.parameter / Satellite.radius)
        maxArea                = 5*0.03405 
        orbitalAngularVelocity = -Satellite.linearSpeed / Satellite.radius
        radius                 = Satellite.earth.radius + Satellite.altitude               
    end
    
    properties
        angles
        centerMass
        centerPressure
        dt
        index
        inertia
        magneticMoment
        momentum
        position
        target
        time
        unitVector
        wheel
    end
    
    methods
        function obj = Satellite(inertia, angles, unitVector, momentum, targetPoint, centerMass, centerPressure, magneticMoment)
            %Constructor
            %   All vectors are column vectors
            %   1 - inertia        = Mass moment of inertia tensor (kg*m^2)
            %   2 - angles         = Euler angles vector (radians)
            %   3 - unitVector     = Initial vector where Stratus's camera is facing
            %   4 - momentum       = Intial momentum vector (n*m*s)
            %   5 - targetPoint    = Where the target is ([x; y; z])
            %   6 - centerMass     = Center of mass vector (meters)
            %   7 - centerPressure = Center of pressure vector (meters)
            %   8 - magneticMoment = Magnetic moment vector (A*m^2)
            
            obj.angles         = angles;
            obj.centerMass     = centerMass;
            obj.centerPressure = centerPressure;
            obj.index          = 1;
            obj.inertia        = inertia;
            obj.magneticMoment = magneticMoment;
            obj.momentum       = momentum;
            obj.unitVector     = unitVector;
            obj.target         = targetPoint;
            obj.wheel          = Wheel;
            
        end
    end 
end

