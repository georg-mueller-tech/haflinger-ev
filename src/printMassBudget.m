function printMassBudget(p, mb)
% PRINTMASSBUDGET  Console summary of the mass budget.

fprintf('\n===== MASS BUDGET =====\n');
disp(mb.groups);
fprintf('Empty:  %6.0f kg, CG x = %.2f m behind front axle, z = %.2f m\n', ...
        mb.m_empty, mb.x_empty, mb.z_empty);
fprintf('        front %4.0f kg (%2.0f %%), rear %4.0f kg\n', ...
        mb.front_empty, 100*mb.front_empty/mb.m_empty, mb.rear_empty);
fprintf('Loaded: %6.0f kg, CG x = %.2f m, z = %.2f m\n', mb.m_loaded, mb.x_loaded, mb.z_loaded);
fprintf('        front %4.0f kg (%2.0f %%), rear %4.0f kg\n', ...
        mb.front_loaded, 100*mb.front_loaded/mb.m_loaded, mb.rear_loaded);
fprintf('Front share needed at %.0f %% grade: > %.0f %%\n', ...
        100*p.req.grade_max, 100*mb.front_min_share);
fprintf('%.0f %% of the empty mass is still estimated\n', 100*mb.share_estimate);

f = fieldnames(mb.check);
for k = 1:numel(f)
    if mb.check.(f{k}), r = 'PASS'; else, r = 'FAIL'; end
    fprintf('  %-12s %s\n', f{k}, r);
end
fprintf('\n');
end
