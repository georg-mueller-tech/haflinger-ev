function gl = gearboxLoads(p, dl)
% GEARBOXLOADS  Torques and speeds of every element for each load case.
%   Rows of every field = load cases from p.gb.lc, plus a peak case at the end.
%   Torques in Nm, speeds in rpm. No losses (conservative for sizing).
%
%   Low gear : ring fixed (brake), sun in, carrier out
%   High gear: sun and carrier locked (clutch), planetary turns as a block

lc  = p.gb.lc;
zs  = p.dl.z_sun;  zr = p.dl.z_ring;  zp = (zr - zs)/2;
ib  = p.gb.bev.z2 / p.gb.bev.z1;
ipl = 1 + zr/zs;

% Load cases + peak case (full motor torque * K_A, low gear, slow)
T_m  = [lc(:,2) * p.mot.T_peak;  p.mot.T_peak * p.gb.K_A];
n_m  = [lc(:,3);                 1000];
gear = [lc(:,4);                 1];
gl.share = [lc(:,1); 0];           % peak case has no time share
gl.names = [p.gb.lc_names, {'Peak (K_A)'}];

low = (gear == 1);

% Bevel stage
gl.T_pinion = T_m;            gl.n_pinion = n_m;
gl.T_sun    = T_m * ib;       gl.n_sun    = n_m / ib;

% Planetary output (carrier)
gl.T_carrier = gl.T_sun .* (low*ipl + ~low);
gl.n_carrier = gl.n_sun ./ (low*ipl + ~low);

% Relative speeds inside the planetary (zero in high gear)
gl.n_sun_rel    = (gl.n_sun - gl.n_carrier) .* low;      % sun vs. carrier
gl.n_planet_rel = gl.n_sun_rel * zs / zp;                % planet vs. carrier
gl.n_ring_rel   = gl.n_carrier .* low;                   % ring vs. carrier

% Torque per planet mesh (only in low gear), incl. load sharing
gl.T_sun_mesh = gl.T_sun .* low / p.dl.n_planets * p.gb.K_gamma;

% Shift elements
gl.T_brake  = gl.T_sun * zr/zs .* low;     % ring brake holding torque
gl.T_clutch = gl.T_sun .* ~low;            % lock-up clutch torque

% Axles (worst-case split)
gl.T_axle_in = gl.T_carrier * p.gb.axle_share_max;
gl.n_axle_in = gl.n_carrier;
gl.T_wheels  = gl.T_carrier * p.dl.i_axle;   % sum of all wheels

% Hours per load case
gl.hours = gl.share * p.gb.L_h;
gl.gear  = gear;
gl.check_ratio = abs(ib - p.dl.i_bevel) < 1e-6;
end
