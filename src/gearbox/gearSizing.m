function gs = gearSizing(p, gl)
% GEARSIZING  Tooth root and flank safety, simplified after ISO 6336.
%   Fatigue: equivalent stress from the load collective (Miner), K_A = 1
%            because the collective already describes the real loads.
%   Static : peak case (motor peak torque * K_A) with static life factors.
%   Bevel gears are calculated as virtual spur gears (Tredgold).
%   Planet teeth see reverse bending -> Y_M = 0.7.

np  = p.dl.n_planets;
zs  = p.dl.z_sun;  zr = p.dl.z_ring;  zp = (zr - zs)/2;
K   = p.gb.K_v * p.gb.K_beta;          % K_A added only for peak case
nC  = numel(gl.share);                 % last row = peak case
fat = 1:nC-1;

%% Mesh 1: bevel stage
b  = p.gb.bev;
delta1 = atan(b.z1/b.z2);  delta2 = pi/2 - delta1;
zv1 = b.z1/cos(delta1);    zv2 = b.z2/cos(delta2);
mesh(1) = makeMesh('Bevel pinion / wheel', b.m, b.b, zv1, zv2, b.m*zv1, false, ...
    gl.T_pinion, b.m*b.z1, gl.n_pinion, 1, gl.n_pinion*b.z1/b.z2, 1, 1, 1);

%% Mesh 2: sun / planet (pinion = planet, smaller gear)
m = p.gb.pl.m;  bw = p.gb.pl.b;
mesh(2) = makeMesh('Sun / planet', m, bw, zp, zs, m*zp, false, ...
    gl.T_sun_mesh, m*zs, gl.n_planet_rel, 1, gl.n_sun_rel, np, 0.7, 1);

%% Mesh 3: planet / ring (internal)
mesh(3) = makeMesh('Planet / ring', m, bw, zp, zr, m*zp, true, ...
    gl.T_sun_mesh, m*zs, gl.n_planet_rel, 1, gl.n_ring_rel, np, 0.7, 1);

%% Evaluate
for k = 1:3
    M = mesh(k);
    Ft = 2000 * M.T ./ M.d_ref;                          % N per mesh
    u  = M.z2 / M.z1;
    if M.internal, uf = (u-1)/u; else, uf = (u+1)/u; end

    sigF0 = Ft / (M.b * M.m);                            % nominal root stress
    sigH0 = 2.49 * p.mat.Z_E * 0.9 * sqrt(Ft / (M.d1 * M.b) * uf);  % Z_H*Z_E*Z_eps

    for g = 1:2                                          % gear 1 and gear 2
        z = M.z(g);
        Y_FS = 3.45 + 13.2/z;                            % approx. form + stress factor
        sF = sigF0 * Y_FS * K;
        sH = sigH0 * sqrt(K);

        N_i = M.n(:,g) * 60 .* gl.hours * M.cyc(g);      % load cycles per case
        N   = sum(N_i(fat));

        % Equivalent stresses (Miner, Woehler exponents for case-hardened steel)
        sF_eq = (sum(N_i(fat) .* sF(fat).^8.74) / max(N,1))^(1/8.74);
        sH_eq = (sum(N_i(fat) .* sH(fat).^13.2) / max(N,1))^(1/13.2);

        Y_NT = min(max((3e6/max(N,1))^(1/8.74), 1), 2.5);
        Z_NT = min(max((5e7/max(N,1))^(1/13.2), 1), 1.6);

        r.name   = sprintf('%s - %s', M.name, M.gearName{g});
        r.z      = z;
        r.N      = N;
        r.S_F    = p.mat.sigma_Flim * 2 * Y_NT * M.Y_M(g) / sF_eq;
        r.S_H    = p.mat.sigma_Hlim * Z_NT / sH_eq;
        r.S_Fst  = p.mat.sigma_Flim * 2 * 2.5 * M.Y_M(g) / (sF(end) * p.gb.K_A);
        r.S_Hst  = p.mat.sigma_Hlim * 1.6 / (sH(end) * sqrt(p.gb.K_A));
        r.Ft_peak = Ft(end);
        r.ok = r.S_F >= p.mat.S_Fmin && r.S_H >= p.mat.S_Hmin && ...
               r.S_Fst >= p.mat.S_Fmin && r.S_Hst >= p.mat.S_Hmin;
        gs.gear((k-1)*2 + g) = r;
    end
end

%% Planetary geometry
a_sp = m*(zs + zp)/2;   a_pr = m*(zr - zp)/2;
gs.geo.center_distance = a_sp;
gs.geo.coaxial_ok   = abs(a_sp - a_pr) < 1e-9;
gs.geo.assembly_ok  = mod(zs + zr, np) == 0;
gs.geo.neighbour_ok = 2*a_sp*sin(pi/np) > m*(zp + 2) + 2;   % 2 mm gap tip-tip
gs.geo.d_ring_root  = m*(zr + 2.5);                         % approx. ring outer limit

%% Bevel geometry
gs.bev.delta1_deg = rad2deg(delta1);
gs.bev.d_m1 = b.m*b.z1;  gs.bev.d_m2 = b.m*b.z2;

gs.all_ok = all([gs.gear.ok]) && gs.geo.coaxial_ok && gs.geo.assembly_ok && gs.geo.neighbour_ok;
end

%% ------------------------------------------------------------------
function M = makeMesh(name, m, b, z1, z2, d1, internal, T, d_ref, n1, c1, n2, c2, Ym1, Ym2)
% Collects mesh data. T acts on the gear with reference diameter d_ref.
M.name = name;  M.m = m;  M.b = b;
M.z1 = z1;  M.z2 = z2;  M.z = [z1 z2];
M.d1 = d1;  M.internal = internal;
M.T = T;    M.d_ref = d_ref;
M.n = [n1(:) n2(:)];  M.cyc = [c1 c2];
M.Y_M = [Ym1 Ym2];
M.gearName = {'gear 1', 'gear 2'};
if contains(name, 'Bevel'), M.gearName = {'pinion', 'wheel'}; end
if contains(name, 'Sun'),   M.gearName = {'planet', 'sun'};   end
if contains(name, 'ring'),  M.gearName = {'planet', 'ring'};  end
end
