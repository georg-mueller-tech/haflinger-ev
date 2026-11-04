function gg = gearGeometry(p)
% GEARGEOMETRY  Full geometry of all gears for the CAD model.
%   Spur gears of the planetary set and straight bevel stage,
%   reference profile 20 deg, no profile shift (x = 0).
%   All lengths in mm, angles in deg.
%
%   Output
%   gg.spur   table: sun, planet, ring
%   gg.bevel  table: pinion, wheel
%   gg.mesh   center distance, contact ratios, clearances
%   gg.check  geometry checks (logical)

al = deg2rad(p.gb.alpha);
ha = p.gb.ha;  hf = p.gb.hf;
m  = p.gb.pl.m;  b = p.gb.pl.b;
zs = p.dl.z_sun;  zr = p.dl.z_ring;  zp = (zr - zs)/2;
np = p.dl.n_planets;

%% Planetary set (spur gears)
name = {'Sun'; 'Planet'; 'Ring (internal)'};
z    = [zs; zp; zr];
sgn  = [1; 1; -1];                     % -1 = internal gear
d    = m * z;                          % pitch (reference) diameter
d_a  = d + sgn * 2*ha*m;               % tip diameter (internal: smaller)
d_f  = d - sgn * 2*hf*m;               % root diameter (internal: larger)
d_b  = d * cos(al);                    % base circle
s    = pi*m/2 * ones(3,1);             % tooth thickness on pitch circle
pt   = pi*m * ones(3,1);               % pitch
h    = (ha + hf)*m * ones(3,1);        % tooth height
bw   = b * ones(3,1);
mm   = m * ones(3,1);

gg.spur = table(name, z, mm, d, d_a, d_f, d_b, s, pt, h, bw, ...
    'VariableNames', {'Gear','z','m','d','d_a','d_f','d_b','s','p','h','b'});

% Mesh data
a   = m*(zs + zp)/2;                   % center distance sun-planet = planet-ring
p_b = pi*m*cos(al);                    % base pitch
r_a = d_a/2;  r_b = d_b/2;
eps_sp = (sqrt(r_a(1)^2 - r_b(1)^2) + sqrt(r_a(2)^2 - r_b(2)^2) - a*sin(al)) / p_b;
eps_pr = (sqrt(r_a(2)^2 - r_b(2)^2) - sqrt(r_a(3)^2 - r_b(3)^2) + a*sin(al)) / p_b;

gg.mesh.a              = a;
gg.mesh.d_planet_circle = 2*a;                         % carrier pitch circle
gg.mesh.c              = (hf - ha)*m;                  % tip clearance
gg.mesh.eps_sun_planet = eps_sp;
gg.mesh.eps_planet_ring = eps_pr;
gg.mesh.planet_gap     = 2*a*sin(pi/np) - d_a(2);      % tip-to-tip between planets
gg.mesh.planet_angle   = 360/np;

% Space for planet bearing and ring outer diameter
s_R = p.gb.rim_fac * m;
gg.mesh.planet_bore_max = d_f(2) - 2*s_R;              % max. bearing outer diameter
gg.mesh.ring_OD_min     = d_f(3) + 2*s_R;
gg.mesh.sun_bore_max    = d_f(1) - 2*s_R;

%% Bevel stage (straight bevel, shaft angle 90 deg)
bv = p.gb.bev;
zb = [bv.z1; bv.z2];
delta = [atan(bv.z1/bv.z2); pi/2 - atan(bv.z1/bv.z2)];
d_m = bv.m * zb;                                       % mean pitch diameter
R_m = d_m(1) / (2*sin(delta(1)));                      % mean cone distance
R_e = R_m + bv.b/2;                                    % outer cone distance
m_e = bv.m * R_e / R_m;                                % outer module
d_e = m_e * zb;                                        % outer pitch diameter
d_ae = d_e + 2*ha*m_e*cos(delta);                      % outer tip diameter
th_a = atan(ha*m_e/R_e);                               % addendum angle
th_f = atan(hf*m_e/R_e);                               % dedendum angle
z_v = zb ./ cos(delta);                                % virtual number of teeth

bname = {'Bevel pinion'; 'Bevel wheel'};
gg.bevel = table(bname, zb, rad2deg(delta), d_m, d_e, d_ae, ...
    rad2deg(delta + th_a), rad2deg(delta - th_f), z_v, ...
    bv.b*ones(2,1), ...
    'VariableNames', {'Gear','z','delta','d_m','d_e','d_ae', ...
                      'delta_a','delta_f','z_v','b'});
gg.bev.R_m = R_m;  gg.bev.R_e = R_e;  gg.bev.m_e = m_e;
gg.bev.b_Re = bv.b / R_e;
gg.bev.th_a = rad2deg(th_a);  gg.bev.th_f = rad2deg(th_f);

%% Checks
z_min = 2*ha / sin(al)^2;                              % undercut limit, ~17
gg.check.no_undercut_spur  = all(z(1:2) >= floor(z_min));
gg.check.no_undercut_bevel = all(z_v >= floor(z_min));
gg.check.coaxial           = mod(zr - zs, 2) == 0;
gg.check.assembly          = mod(zs + zr, np) == 0;
gg.check.planets_clear     = gg.mesh.planet_gap > 2;
gg.check.contact_ratio     = eps_sp >= 1.2 && eps_pr >= 1.2;
gg.check.bevel_b_Re        = gg.bev.b_Re <= 0.3;
gg.check.ring_internal_ok  = (zr - zp) >= 10;          % avoids tip interference (rule of thumb)
gg.all_ok = all(cellfun(@(f) gg.check.(f), fieldnames(gg.check)));
end
