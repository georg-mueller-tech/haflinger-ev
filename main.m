%% Haflinger EV - main calculation script
% Runs all calculations with the values from params.m,
% prints a requirement check and saves plots + results.

clear; clc; close all;
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'src'), fullfile(root, 'src', 'gearbox'), fullfile(root, 'plots'));

%% Inputs
p = params();
[p, mb] = massBudget(p);    % mass, CG and axle loads from data/*.csv

%% Calculations
dl = gearRatios(p);              % driveline ratios
tr = tractionAnalysis(p, dl);    % grade, top speed, adhesion, tipping
en = energyBalance(p);           % daily energy demand
so = solarYield(p);              % solar yield
bp = batteryPack(p);             % pack layout, voltage, currents, mass

E_missing = max(en.total_kWh - en.usable_kWh - so.E_day_kWh, 0);
rx = rangeExtender(p, en, E_missing);

%% Output
fprintf('Gear ratios: low %.1f, high %.1f (step %.2f)\n', dl.i_low, dl.i_high, dl.step);
fprintf('Battery: %.0f kWh, approx. %.0f kg\n', p.bat.E_nom_kWh, en.bat_mass);
fprintf('Range on battery: %.0f km off-road\n', en.range_km);
fprintf('Missing after battery + solar: %.1f kWh -> REX %.1f h, %.1f L petrol\n', ...
        E_missing, rx.t_charge_h, rx.fuel_L);
fprintf('Extra range per tank: %.0f km\n', rx.range_tank_km);

T = checkRequirements(p, dl, tr, en, so);
printBattery(p, bp);
printMassBudget(p, mb);

%% Gearbox
gl = gearboxLoads(p, dl);        % torques and speeds per load case
gs = gearSizing(p, gl);          % tooth root + flank safety
sh = shaftDesign(p, gl);         % minimum shaft diameters
br = bearingLife(p, gl, gs);     % planet bearings, bevel forces
printGearbox(p, gl, gs, sh, br);
gg = gearGeometry(p);            % pitch, tip, root, base circles etc.
printGearGeometry(gg, br);

%% Plots and results
resDir = fullfile(root, 'results');
if ~exist(resDir, 'dir'), mkdir(resDir); end

f1 = plotTractionDiagram(p, dl);
saveas(f1, fullfile(resDir, 'traction_diagram.png'));
f2 = plotEnergyBalance(en, so);
saveas(f2, fullfile(resDir, 'energy_balance.png'));
f3 = plotMassBudget(p, mb);
saveas(f3, fullfile(resDir, 'mass_budget.png'));

save(fullfile(resDir, 'results.mat'), 'p', 'dl', 'tr', 'en', 'so', 'rx', 'T', ...
     'gl', 'gs', 'sh', 'br', 'gg', 'bp', 'mb');
writetable(gg.spur,  fullfile(resDir, 'gear_geometry_planetary.csv'));
writetable(gg.bevel, fullfile(resDir, 'gear_geometry_bevel.csv'));
writetable(T, fullfile(resDir, 'requirements_check.csv'));
