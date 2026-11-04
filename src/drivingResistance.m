function [F, parts] = drivingResistance(p, v, grade, f_r)
% DRIVINGRESISTANCE  Steady-state resistance force at the wheels.
%   [F, parts] = drivingResistance(p, v, grade, f_r)
%   v      speed in m/s (scalar or vector)
%   grade  gradient as fraction, e.g. 0.65 for 65 %
%   f_r    rolling resistance coefficient
%   F      total force in N, parts = struct with roll, grade, air

alpha = atan(grade);
m = p.veh.m;

parts.roll  = m * p.g * f_r .* cos(alpha) .* ones(size(v));
parts.grade = m * p.g .* sin(alpha) .* ones(size(v));
parts.air   = 0.5 * p.rho_air * p.veh.cw * p.veh.A .* v.^2;

F = parts.roll + parts.grade + parts.air;
end
