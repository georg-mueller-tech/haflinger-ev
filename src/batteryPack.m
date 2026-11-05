function bp = batteryPack(p)
% BATTERYPACK  Size, voltage window, currents, mass, cost of the pack.
%   Cells are stacked in p.pack.rows rows, thickness direction along the row.

c  = p.cell;  pk = p.pack;
n  = pk.ns * pk.np;

%% Electrical
bp.n_cells = n;
bp.U_nom   = pk.ns * c.U_nom;
bp.U_max   = pk.ns * c.U_max;
bp.U_min   = pk.ns * c.U_min;
bp.C_Ah    = pk.np * c.C_Ah;
bp.E_kWh   = bp.U_nom * bp.C_Ah / 1000;
bp.E_use   = bp.E_kWh * p.bat.DoD;

% Currents: continuous and peak motor power at lowest voltage
eta = p.cyc.eta_el;
bp.I_cont = p.mot.P_cont / eta / bp.U_min;
bp.I_peak = p.mot.P_peak / eta / bp.U_min;
bp.C_cont = bp.I_cont / bp.C_Ah;
bp.C_peak = bp.I_peak / bp.C_Ah;
bp.I_allowed = pk.np * c.I_cont;
bp.P_peak_at_1C = bp.I_allowed * bp.U_min * eta;    % W, if current limited to 1C

%% Mechanical (cells only, then housing)
per_row = ceil(n / pk.rows);
L_cells = per_row*c.dim(1) + (per_row - 1)*pk.gap + 2*pk.endplate;
W_cells = pk.rows*c.dim(2) + (pk.rows - 1)*pk.gap;
H_cells = c.dim(3);
bp.cells_per_row = per_row;
bp.dim_cells = [L_cells W_cells H_cells];                 % mm
bp.dim_pack  = bp.dim_cells + 2*pk.margin + [0 0 30];     % +30 mm busbars/BMS on top
bp.mass_cells = n * c.mass;
bp.mass_pack  = bp.mass_cells * pk.f_mass;
bp.cost_cells = n * c.price;

%% Checks
bp.check.voltage_ok = bp.U_max <= p.mot.U_max - 2;        % 2 V margin for regen
bp.check.cont_ok    = bp.I_cont <= bp.I_allowed;
bp.check.peak_ok    = bp.I_peak <= bp.I_allowed;          % 1C is the datasheet limit
bp.check.width_ok   = bp.dim_pack(2) <= p.req.width_max*1000;
end
