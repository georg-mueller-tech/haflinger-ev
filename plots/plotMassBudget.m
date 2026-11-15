function fig = plotMassBudget(p, mb)
% PLOTMASSBUDGET  Side view with every part as a circle (area ~ mass)
%   and the centre of gravity empty and loaded.

T  = mb.parts;
PL = mb.payload;
L  = p.veh.wheelbase;
r  = p.veh.r_dyn;

fig = figure('Name', 'Mass budget'); hold on; grid on; axis equal;

% Ground, wheels
plot([-0.8 L+0.8], [0 0], 'k', 'LineWidth', 1.5);
t = linspace(0, 2*pi, 100);
for xw = [0 L]
    plot(xw + r*cos(t), r + r*sin(t), 'k', 'LineWidth', 1);
end

% Parts, coloured by group
[G, names] = findgroups(T.group);
cols = lines(numel(names));
for k = 1:numel(names)
    idx = (G == k);
    scatter(T.x_m(idx), T.z_m(idx), 3*T.mass_kg(idx), cols(k,:), 'filled', ...
            'MarkerFaceAlpha', 0.6, 'DisplayName', names(k));
end
scatter(PL.x_m, PL.z_m, 3*PL.mass_kg, [0.5 0.5 0.5], 'DisplayName', 'Payload');

% Centres of gravity
plot(mb.x_empty,  mb.z_empty,  'kx', 'MarkerSize', 14, 'LineWidth', 2.5, 'DisplayName', 'CG empty');
plot(mb.x_loaded, mb.z_loaded, 'k+', 'MarkerSize', 14, 'LineWidth', 2.5, 'DisplayName', 'CG loaded');

xlabel('x behind front axle in m');
ylabel('Height in m');
title(sprintf('Mass budget: %.0f kg empty, %.0f kg loaded, %.0f %% on front axle', ...
      mb.m_empty, mb.m_loaded, 100*mb.front_loaded/mb.m_loaded));
legend('Location', 'eastoutside');
xlim([-0.8 L+0.8]); ylim([-0.1 1.8]);
end
