function so = solarYield(p)
% SOLARYIELD  Daily yield of the foldable panels on a clear day.

so.P_peak_W  = p.sol.area * p.sol.eta * 1000;                  % at 1000 W/m^2
so.E_day_kWh = p.sol.area * p.sol.eta * p.sol.H_day * p.sol.PR;
so.area_req  = p.req.solar_day_kWh / (p.sol.eta * p.sol.H_day * p.sol.PR);
so.solar_ok  = so.E_day_kWh >= p.req.solar_day_kWh;
end
