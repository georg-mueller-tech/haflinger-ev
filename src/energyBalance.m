function en = energyBalance(p)
% ENERGYBALANCE  Electrical energy for one off-road day vs. usable battery.

d   = p.req.range_day;            % m
eta = p.dl.eta * p.cyc.eta_el;    % wheel -> battery
m   = p.veh.m;
J2kWh = 1/3.6e6;

% Rolling + air at average speed on flat track
F_flat   = drivingResistance(p, p.cyc.v_avg, 0, p.terr.f_r_off);
E_flat   = F_flat * d / eta;

% Climbing and recuperation on the way down
E_pot    = m * p.g * p.cyc.h_up;
E_climb  = E_pot / eta;
E_recup  = p.cyc.recup * E_pot * eta;

% Auxiliaries
t_drive  = d / p.cyc.v_avg;
E_aux    = p.cyc.P_aux * t_drive;

en.parts_kWh = [E_flat, E_climb, -E_recup, E_aux] * J2kWh / p.bat.eta;
en.labels    = {'Rolling + air', 'Climbing', 'Recuperation', 'Auxiliaries'};
en.total_kWh = sum(en.parts_kWh);
en.Wh_per_km = en.total_kWh * 1000 / (d/1000);

en.usable_kWh  = p.bat.E_nom_kWh * p.bat.DoD;
en.deficit_kWh = max(en.total_kWh - en.usable_kWh, 0);
en.range_km    = en.usable_kWh / en.Wh_per_km * 1000;
en.bat_mass    = p.bat.E_nom_kWh / p.bat.e_spec;     % kg
en.range_ok    = en.deficit_kWh == 0;
end
