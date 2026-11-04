function fig = plotTractionDiagram(p, dl)
% PLOTTRACTIONDIAGRAM  Traction force of both gears vs. resistance curves.

r   = p.veh.r_dyn;
eta = p.dl.eta;
v   = linspace(0, 1.1*p.req.v_max, 400);           % m/s

fig = figure('Name', 'Traction diagram'); hold on; grid on;

gears = [dl.i_low, dl.i_high];
gearNames = {'Low gear', 'High gear'};
for k = 1:2
    n_mot = v / r * 60/(2*pi) * gears(k);
    F = motorTorque(p, n_mot) * gears(k) * eta / r;
    F(F == 0) = NaN;
    plot(v*3.6, F/1e3, 'LineWidth', 2, 'DisplayName', gearNames{k});
end

grades = [0 0.2 0.4 p.req.grade_max];
for g = grades
    F_res = drivingResistance(p, v, g, p.terr.f_r_off);
    plot(v*3.6, F_res/1e3, '--', 'DisplayName', sprintf('%.0f %% grade', g*100));
end

xlabel('Speed in km/h');
ylabel('Force at wheels in kN');
title('Traction diagram (off-road rolling resistance)');
legend('Location', 'northeast');
end
