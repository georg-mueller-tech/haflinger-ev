function bp = batteryPack(p)
% BATTERYPACK  Electrical data, layout, mass and cost of the battery.
%   Electrically one battery: ns groups in series, each group np cells in
%   parallel, one BMS. Mechanically split into n_boxes housings that sit
%   left and right of the propshaft tunnel and are connected in series.
%
%   Box layout: cells of a group side by side (np x cell width),
%   groups stacked along the vehicle (thickness direction).

c  = p.cell;  pk = p.pack;
n  = pk.ns * pk.np;

%% Electrical (whole battery)
bp.n_cells = n;
bp.U_nom   = pk.ns * c.U_nom;
bp.U_max   = pk.ns * c.U_max;
bp.U_min   = pk.ns * c.U_min;
bp.C_Ah    = pk.np * c.C_Ah;
bp.E_kWh   = bp.U_nom * bp.C_Ah / 1000;
bp.E_use   = bp.E_kWh * p.bat.DoD;

eta = p.cyc.eta_el;
bp.I_cont = p.mot.P_cont / eta / bp.U_min;          % A at empty battery
bp.I_peak = p.mot.P_peak / eta / bp.U_min;
bp.C_cont = bp.I_cont / bp.C_Ah;
bp.C_peak = bp.I_peak / bp.C_Ah;
bp.I_allowed   = pk.np * c.I_cont;                  % continuous
bp.I_allowed_pk = pk.np * c.I_peak;                 % peak, max. 30 s
bp.P_max_empty = min(bp.I_allowed * bp.U_min * eta, p.mot.P_peak);   % W

%% Boxes
g_box = ceil(pk.ns / pk.n_boxes);                   % groups per box
L = g_box*c.dim(1) + (g_box - 1)*pk.gap + 2*pk.endplate;
W = pk.np*c.dim(2) + (pk.np - 1)*pk.gap;
H = c.dim(3);
bp.groups_per_box = g_box;
bp.box_cells = g_box * pk.np;
bp.box_U_max = g_box * c.U_max;                     % V when service disconnect is open
bp.dim_box   = [L W H] + 2*pk.margin + [0 0 30];    % mm, +30 busbars/BMS on top
bp.dim_total = [bp.dim_box(1), pk.n_boxes*bp.dim_box(2) + (pk.n_boxes - 1)*pk.tunnel, ...
                bp.dim_box(3)];

bp.mass_cells = n * c.mass;
bp.mass_pack  = bp.mass_cells * pk.f_mass;
bp.mass_box   = bp.mass_pack / pk.n_boxes;
bp.cost_cells = n * c.price;

%% Checks
bp.check.voltage_ok  = bp.U_max <= p.mot.U_max - 2;          % margin for regen
bp.check.cont_current_ok = bp.I_cont <= bp.I_allowed;       % motor continuous power at 1C
bp.check.peak_current_ok = bp.I_peak <= bp.I_allowed_pk;    % motor peak power within 2C pulse
bp.check.box_safe_ok = bp.box_U_max < 60;                    % touch-safe single box
bp.check.width_ok    = bp.dim_total(2) <= p.req.width_max*1000 - 300;  % 150 mm/side frame + solar boxes
bp.check.length_ok   = bp.dim_box(1) <= p.veh.L_batt_space*1000;
end
