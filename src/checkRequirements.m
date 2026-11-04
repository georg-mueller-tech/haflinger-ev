function T = checkRequirements(p, dl, tr, en, so)
% CHECKREQUIREMENTS  Prints a PASS/FAIL table against the spec sheet.

names = {
    'Gradient 65 % (torque)'
    'Gradient 65 % (adhesion)'
    'Front axle stays down at 65 %'
    'Top speed 80 km/h'
    'Continuous power'
    '80 km/day off-road on battery'
    'Solar >= 5 kWh/day'
    'Width <= 1.5 m'
    'Ground clearance >= 300 mm'
    'Planetary gear set valid'};

values = {
    sprintf('%.0f of %.0f Nm needed (i_low %.1f, min %.1f)', ...
            tr.T_wheel_avail, tr.T_wheel_req, dl.i_low, tr.i_low_min)
    sprintf('mu needed %.2f, assumed %.2f', tr.mu_req, p.terr.mu_off)
    sprintf('N_front = %.0f N', tr.N_front)
    sprintf('n_mot = %.0f rpm (max %d), P_el = %.1f kW', ...
            tr.n_mot_vmax, p.mot.n_max, tr.P_vmax/1e3)
    sprintf('%.1f kW needed, %.1f kW available', tr.P_cont_req/1e3, p.mot.P_cont/1e3)
    sprintf('%.1f kWh needed, %.1f kWh usable (%.0f Wh/km)', ...
            en.total_kWh, en.usable_kWh, en.Wh_per_km)
    sprintf('%.1f kWh/day, %.1f m^2 needed', so.E_day_kWh, so.area_req)
    sprintf('%.2f m', p.veh.width)
    sprintf('%.0f mm', p.veh.clearance*1000)
    sprintf('z_planet = %.1f, assembly ok = %d', dl.z_planet, dl.assembly_ok)};

ok = [tr.grade_ok; tr.adh_ok; tr.tip_ok; tr.vmax_ok; tr.cont_ok; ...
      en.range_ok; so.solar_ok; p.veh.width <= p.req.width_max; ...
      p.veh.clearance >= p.req.clearance_min; ...
      dl.coaxial_ok && dl.assembly_ok];

fprintf('\n%-32s %-6s %s\n', 'Requirement', 'Result', 'Details');
fprintf('%s\n', repmat('-', 1, 100));
for k = 1:numel(names)
    if ok(k), s = 'PASS'; else, s = 'FAIL'; end
    fprintf('%-32s %-6s %s\n', names{k}, s, values{k});
end
fprintf('\n');

T = table(names, ok, values, 'VariableNames', {'Requirement', 'Pass', 'Details'});
end
