function T = motorTorque(p, n_rpm)
% MOTORTORQUE  Peak torque curve: constant torque, then constant power.
%   T = motorTorque(p, n_rpm), T in Nm, zero above n_max.

omega = n_rpm * 2*pi/60;
T = min(p.mot.T_peak, p.mot.P_peak ./ max(omega, eps));
T(n_rpm > p.mot.n_max) = 0;
end
