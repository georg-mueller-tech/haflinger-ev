function printBattery(p, bp)
% PRINTBATTERY  Console summary of the battery pack.

fprintf('\n===== BATTERY PACK =====\n');
fprintf('%s, %ds%dp = %d cells\n', p.cell.name, p.pack.ns, p.pack.np, bp.n_cells);
fprintf('Voltage: %.0f V nominal, %.1f ... %.1f V\n', bp.U_nom, bp.U_min, bp.U_max);
fprintf('Energy: %.1f kWh nominal, %.1f kWh usable\n', bp.E_kWh, bp.E_use);
fprintf('Current: %.0f A continuous (%.2f C), %.0f A peak (%.2f C), cell limit %.0f A\n', ...
        bp.I_cont, bp.C_cont, bp.I_peak, bp.C_peak, bp.I_allowed);
fprintf('-> at 1C the motor gets at most %.1f kW at empty battery\n', bp.P_peak_at_1C/1e3);
fprintf('Cells: %d per row x %d rows, block %.0f x %.0f x %.0f mm\n', ...
        bp.cells_per_row, p.pack.rows, bp.dim_cells);
fprintf('Pack approx. %.0f x %.0f x %.0f mm, %.0f kg (cells %.0f kg)\n', ...
        bp.dim_pack, bp.mass_pack, bp.mass_cells);
fprintf('Cell cost approx. EUR %.0f\n', bp.cost_cells);

f = fieldnames(bp.check);
for k = 1:numel(f)
    if bp.check.(f{k}), r = 'PASS'; else, r = 'FAIL'; end
    fprintf('  %-12s %s\n', f{k}, r);
end
fprintf('\n');
end
