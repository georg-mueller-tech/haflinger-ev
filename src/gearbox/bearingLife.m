function br = bearingLife(p, gl, gs)
% BEARINGLIFE  Required dynamic load rating C for the planet bearings
%   and tooth forces of the bevel stage for the shaft/bearing model in CAD.
%
%   Planet bearing: the planet is pushed by sun and ring with F_t each
%   -> radial load 2*F_t, speed = planet speed relative to carrier.

zs = p.dl.z_sun;  m = p.gb.pl.m;
fat = 1:numel(gl.share)-1;
alpha = deg2rad(20);

%% Planet bearings
Ft  = 2000 * gl.T_sun_mesh / (m*zs);        % N per planet (incl. K_gamma)
P   = 2 * Ft;
n   = gl.n_planet_rel;
br.planet.C_req = requiredC(P(fat), n(fat), gl.hours(fat), p.br.p);
br.planet.P_peak = P(end);                  % static load -> check C0 >= 1.5*P_peak
br.planet.n_max  = max(n(fat));

%% Bevel stage tooth forces (on pinion), every load case
delta1 = deg2rad(gs.bev.delta1_deg);
Ft_b   = 2000 * gl.T_pinion / gs.bev.d_m1;
br.bevel.Ft = Ft_b;
br.bevel.Fr = Ft_b * tan(alpha) * cos(delta1);   % radial on pinion
br.bevel.Fa = Ft_b * tan(alpha) * sin(delta1);   % axial on pinion
br.bevel.names = gl.names;
end

%% ------------------------------------------------------------------
function C = requiredC(P, n, hours, pexp)
% REQUIREDC  Required dynamic load rating in N for a load collective.
%   P load per case (N), n speed (rpm), hours per case, pexp = 3 or 10/3.
rev  = n(:) * 60 .* hours(:);                      % revolutions per case
if sum(rev) == 0, C = 0; return; end
P_eq = (sum(rev .* P(:).^pexp) / sum(rev))^(1/pexp);
C    = P_eq * (sum(rev)/1e6)^(1/pexp);
end
