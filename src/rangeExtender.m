function rx = rangeExtender(p, en, E_missing_kWh)
% RANGEEXTENDER  Charging time and fuel to cover a missing energy amount.
%   E_missing_kWh: energy the battery still needs (after solar).

E_bat     = E_missing_kWh;                         % into the battery
E_el      = E_bat / p.bat.eta;                     % generator output
E_mech    = E_el / p.rex.eta_gen;                  % engine shaft
fuel_kg   = E_mech * p.rex.bsfc / 1000;

rx.t_charge_h = E_el / (p.rex.P_el/1000);
rx.fuel_L     = fuel_kg / p.rex.rho_fuel;

% Extra range from one full tank
E_tank_bat     = p.rex.tank_L * p.rex.rho_fuel * 1000 / p.rex.bsfc ...
                 * p.rex.eta_gen * p.bat.eta;      % kWh into battery
rx.range_tank_km = E_tank_bat / en.Wh_per_km * 1000;
end
