function fig = plotEnergyBalance(en, so)
% PLOTENERGYBALANCE  Daily energy demand vs. battery and solar.

fig = figure('Name', 'Energy balance');

subplot(1, 2, 1);
bar(en.parts_kWh);
set(gca, 'XTickLabel', en.labels); xtickangle(30);
ylabel('Energy in kWh'); grid on;
title(sprintf('Demand per day: %.1f kWh', en.total_kWh));

subplot(1, 2, 2);
bar([en.total_kWh, en.usable_kWh, so.E_day_kWh]);
set(gca, 'XTickLabel', {'Demand', 'Battery usable', 'Solar'}); xtickangle(30);
ylabel('Energy in kWh'); grid on;
title('Supply vs. demand');
end
