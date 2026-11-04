function sh = shaftDesign(p, gl)
% SHAFTDESIGN  Minimum shaft diameters (pre-sizing, torsion only).
%   d_fat : from equivalent torque of the collective and p.sh.tau_pre
%           (tau_pre is kept low to cover bending and notches)
%   d_stat: from peak torque (incl. K_A) against yield, tau = 0.58*Re/S
%   Use the larger value as starting point for the CAD, then check
%   the final shaft with bending moments and notch factors (DIN 743).

names = {'Motor / bevel pinion shaft', 'Bevel wheel / sun shaft', ...
         'Carrier / output shaft', 'Axle input shaft'};
T = [gl.T_pinion, gl.T_sun, gl.T_carrier, gl.T_axle_in];
n = [gl.n_pinion, gl.n_sun, gl.n_carrier, gl.n_axle_in];

fat = 1:numel(gl.share)-1;
tau_stat = 0.58 * p.sh.Re / p.sh.S_static;

for k = 1:numel(names)
    w    = gl.hours(fat) .* n(fat,k);                       % revolutions weight
    T_eq = (sum(w .* T(fat,k).^p.sh.k) / sum(w))^(1/p.sh.k);
    T_pk = T(end,k);                                        % already incl. K_A

    d_fat  = (16 * T_eq*1e3 / (pi * p.sh.tau_pre))^(1/3);   % mm
    d_stat = (16 * T_pk*1e3 / (pi * tau_stat))^(1/3);       % mm

    sh.shaft(k).name   = names{k};
    sh.shaft(k).T_eq   = T_eq;
    sh.shaft(k).T_peak = T_pk;
    sh.shaft(k).n_max  = max(n(fat,k));
    sh.shaft(k).d_fat  = d_fat;
    sh.shaft(k).d_stat = d_stat;
    sh.shaft(k).d_min  = max(d_fat, d_stat);
end
end
