function printGearbox(p, gl, gs, sh, br)
% PRINTGEARBOX  Console summary of all gearbox results.

fprintf('\n===== GEARBOX =====\n');
if ~gl.check_ratio
    fprintf('WARNING: bevel z2/z1 = %.2f does not match p.dl.i_bevel = %.2f\n', ...
            p.gb.bev.z2/p.gb.bev.z1, p.dl.i_bevel);
end
s = sum(p.gb.lc(:,1));
if abs(s - 1) > 1e-6
    fprintf('WARNING: load collective shares add up to %.2f, not 1\n', s);
end

%% Loads per case
fprintf('\n%-16s %5s %8s %8s %9s %9s %9s %9s\n', 'Load case', 'Gear', ...
        'T_mot', 'n_mot', 'T_sun', 'T_carr', 'T_brake', 'T_clutch');
for k = 1:numel(gl.share)
    fprintf('%-16s %5d %8.0f %8.0f %9.0f %9.0f %9.0f %9.0f\n', gl.names{k}, ...
        gl.gear(k), gl.T_pinion(k), gl.n_pinion(k), gl.T_sun(k), ...
        gl.T_carrier(k), gl.T_brake(k), gl.T_clutch(k));
end
fprintf('(torques in Nm, speeds in rpm)\n');

%% Gears
fprintf('\n%-30s %4s %9s %6s %6s %7s %7s %s\n', 'Gear', 'z', 'Cycles', ...
        'S_F', 'S_H', 'S_F,st', 'S_H,st', 'Result');
for g = gs.gear
    if g.ok, r = 'PASS'; else, r = 'FAIL'; end
    fprintf('%-30s %4.0f %9.2e %6.2f %6.2f %7.2f %7.2f %s\n', g.name, g.z, ...
            g.N, g.S_F, g.S_H, g.S_Fst, g.S_Hst, r);
end
fprintf('Required: S_F >= %.1f, S_H >= %.1f\n', p.mat.S_Fmin, p.mat.S_Hmin);
fprintf('Planetary: a = %.1f mm, coaxial %d, assembly %d, planets clear %d, ring approx. %.0f mm\n', ...
        gs.geo.center_distance, gs.geo.coaxial_ok, gs.geo.assembly_ok, ...
        gs.geo.neighbour_ok, gs.geo.d_ring_root);
fprintf('Bevel: d_m1 = %.0f mm, d_m2 = %.0f mm, delta1 = %.1f deg\n', ...
        gs.bev.d_m1, gs.bev.d_m2, gs.bev.delta1_deg);

%% Shafts
fprintf('\n%-28s %8s %8s %8s %8s %8s\n', 'Shaft', 'T_eq', 'T_peak', 'n_max', 'd_fat', 'd_min');
for s = sh.shaft
    fprintf('%-28s %8.0f %8.0f %8.0f %8.1f %8.1f\n', s.name, s.T_eq, s.T_peak, ...
            s.n_max, s.d_fat, s.d_min);
end
fprintf('(Nm, rpm, mm; torsion-only pre-sizing)\n');

%% Bearings
fprintf('\nPlanet bearing: C_req = %.1f kN at n_max = %.0f rpm, peak load %.1f kN\n', ...
        br.planet.C_req/1e3, br.planet.n_max, br.planet.P_peak/1e3);
fprintf('Bevel pinion at peak: Ft = %.0f N, Fr = %.0f N, Fa = %.0f N\n\n', ...
        br.bevel.Ft(end), br.bevel.Fr(end), br.bevel.Fa(end));
end
