function printBattery(p, bp)
% PRINTBATTERY  Console summary of the battery pack.

fprintf('\n===== BATTERY =====\n');
fprintf('%s, %ds%dp = %d cells, one BMS, %d boxes in series\n', ...
        p.cell.name, p.pack.ns, p.pack.np, bp.n_cells, p.pack.n_boxes);
fprintf('Voltage: %.0f V nominal, %.1f ... %.1f V\n', bp.U_nom, bp.U_min, bp.U_max);
fprintf('Energy: %.1f kWh nominal, %.1f kWh usable\n', bp.E_kWh, bp.E_use);
fprintf('Current: %.0f A cont. (%.2f C), %.0f A peak (%.2f C), allowed %.0f A\n', ...
        bp.I_cont, bp.C_cont, bp.I_peak, bp.C_peak, bp.I_allowed);
fprintf('Max. motor power at empty battery: %.1f kW\n', bp.P_max_empty/1e3);
fprintf('Per box: %d groups (%d cells), %.0f x %.0f x %.0f mm, approx. %.0f kg, max %.1f V\n', ...
        bp.groups_per_box, bp.box_cells, bp.dim_box, bp.mass_box, bp.box_U_max);
fprintf('Both boxes + tunnel: %.0f x %.0f x %.0f mm\n', bp.dim_total);
fprintf('Total mass approx. %.0f kg, cell cost approx. EUR %.0f\n', bp.mass_pack, bp.cost_cells);

f = fieldnames(bp.check);
for k = 1:numel(f)
    if bp.check.(f{k}), r = 'PASS'; else, r = 'FAIL'; end
    fprintf('  %-12s %s\n', f{k}, r);
end
fprintf('\n');
end
