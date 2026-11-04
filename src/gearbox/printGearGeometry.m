function printGearGeometry(gg, br)
% PRINTGEARGEOMETRY  Console output of the gear geometry for the CAD.

fprintf('\n===== GEAR GEOMETRY (mm, deg) =====\n');
fprintf('Planetary set, alpha = 20 deg, x = 0\n');
disp(gg.spur);

M = gg.mesh;
fprintf('Center distance a          = %.2f mm\n', M.a);
fprintf('Planet pitch circle (2a)   = %.2f mm, planets every %.0f deg\n', ...
        M.d_planet_circle, M.planet_angle);
fprintf('Tip clearance c            = %.3f mm\n', M.c);
fprintf('Contact ratio sun/planet   = %.2f\n', M.eps_sun_planet);
fprintf('Contact ratio planet/ring  = %.2f\n', M.eps_planet_ring);
fprintf('Gap between planet tips    = %.1f mm\n', M.planet_gap);
fprintf('Max. planet bore (bearing OD) = %.1f mm\n', M.planet_bore_max);
fprintf('Max. sun bore              = %.1f mm\n', M.sun_bore_max);
fprintf('Min. ring outer diameter   = %.1f mm\n', M.ring_OD_min);
if nargin > 1
    fprintf('-> planet bearing must fit in OD <= %.1f mm with C >= %.1f kN\n', ...
            M.planet_bore_max, br.planet.C_req/1e3);
end

fprintf('\nBevel stage (straight, 90 deg)\n');
disp(gg.bevel);
fprintf('Mean cone distance R_m = %.2f mm, outer R_e = %.2f mm\n', gg.bev.R_m, gg.bev.R_e);
fprintf('Outer module m_e = %.3f mm, b/R_e = %.2f\n', gg.bev.m_e, gg.bev.b_Re);
fprintf('Addendum angle = %.2f deg, dedendum angle = %.2f deg\n', gg.bev.th_a, gg.bev.th_f);

fprintf('\nGeometry checks\n');
f = fieldnames(gg.check);
for k = 1:numel(f)
    if gg.check.(f{k}), r = 'PASS'; else, r = 'FAIL'; end
    fprintf('  %-20s %s\n', f{k}, r);
end
fprintf('\n');
end
