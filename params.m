function p = params()
% PARAMS  All inputs for the Haflinger EV calculations in one place.
%   SI units unless the name says otherwise (_kWh, _rpm, _kmh ...).
%   Values marked (A) are assumptions -> replace with real data later.

%% Requirements (spec sheet / Lastenheft)
p.req.persons       = 2;
p.req.payload       = 500;        % kg
p.req.range_day     = 80e3;       % m, off-road per day
p.req.grade_max     = 0.65;       % 65 % gradient
p.req.v_max         = 80/3.6;     % m/s
p.req.width_max     = 1.5;        % m
p.req.clearance_min = 0.30;       % m
p.req.solar_day_kWh = 5;          % kWh on a clear day
p.req.cont_grade    = 0.15;       % (A) gradient for continuous-power case
p.req.cont_speed    = 20/3.6;     % (A) m/s for continuous-power case

%% Constants
p.g       = 9.81;                 % m/s^2
p.rho_air = 1.2;                  % kg/m^3

%% Vehicle
% Layout: motor + gearbox at the front under the cab, propshaft to the rear
% axle in a tunnel between the two battery boxes under the load bed.
p.veh.m_empty   = 1200;           % (A) kg, incl. 30s2p battery (~390 kg)
p.veh.m         = p.veh.m_empty + p.req.payload;   % kg, fully loaded
p.veh.cw        = 0.8;            % (A) drag coefficient
p.veh.A         = 2.5;            % (A) m^2 frontal area
p.veh.r_dyn     = 0.35;           % (A) m dynamic tyre radius
p.veh.wheelbase = 1.90;           % (A) m, battery boxes must fit in front of rear axle
p.veh.h_cg      = 0.75;           % (A) m centre of gravity height
p.veh.load_front = 0.45;          % (A) static share of weight on front axle
p.veh.L_batt_space = 1.25;        % (A) m free length between gearbox and rear axle housing
p.veh.width     = 1.45;           % (A) m
p.veh.clearance = 0.32;           % (A) m

%% Terrain
p.terr.f_r_road = 0.015;          % rolling resistance on asphalt
p.terr.f_r_off  = 0.06;           % (A) gravel / forest track
p.terr.mu_off   = 0.8;            % (A) tyre-ground friction, dry off-road

%% Electric motor: PMSM 20/40 kW 96 V kit (EV Evolution), incl. inverter
% Source: ev-evolution.eu/product/pmsm-motor-20-40-kw-96v (Nov 2026, EUR 3600)
p.mot.name   = 'PMSM 20/40 kW 96V (EV Evolution)';
p.mot.T_peak = 210;               % Nm
p.mot.T_cont = 59;                % Nm rated
p.mot.P_peak = 40e3;              % W
p.mot.P_cont = 20e3;              % W
p.mot.n_max  = 7000;              % rpm
p.mot.U_max  = 120;               % V max. DC input of the inverter
p.mot.mass   = 38;                % kg, water-cooled, IP67

%% Driveline: bevel stage -> 2-speed planetary -> axle diffs (with lockers)
% Low gear: sun in, ring fixed, carrier out -> i = 1 + z_ring/z_sun
% High gear: planetary locked              -> i = 1
p.dl.z_sun     = 30;              % i_planet = 1 + 66/30 = 3.2
p.dl.z_ring    = 66;
p.dl.n_planets = 3;
p.dl.i_bevel   = 2.0;             % (A)
p.dl.i_axle    = 5.5;             % (A) axle drive incl. hub reduction
p.dl.eta       = 0.90;            % (A) total mechanical efficiency

%% Battery cell: EVE LF280K (LFP, prismatic)
% Source: eu.nkon.nl (Nov 2026, approx. EUR 72-78 per cell incl. VAT)
p.cell.name   = 'EVE LF280K';
p.cell.U_nom  = 3.2;              % V
p.cell.U_max  = 3.65;             % V charge end
p.cell.U_min  = 2.8;              % V cut-off used in operation (datasheet 2.5)
p.cell.C_Ah   = 280;              % Ah
p.cell.I_cont = 280;              % A (1C)
p.cell.mass   = 5.45;             % kg
p.cell.dim    = [72 173.7 207.5]; % mm thickness x width x height
p.cell.price  = 75;               % EUR per cell (approx.)

%% Battery pack: 30s2p = ONE battery, one BMS, one main contactor
% 2 cells in parallel form a cell group, 30 groups in series.
% Split into 2 boxes left/right of the propshaft tunnel under the load bed:
% box 1 = groups 1-15, box 2 = groups 16-30, connected in series by one
% cable with a service disconnect. Each box alone is 48 V (< 60 V touch-safe).
p.pack.ns       = 30;             % cell groups in series (30s keeps U_max < 120 V)
p.pack.np       = 2;              % cells in parallel per group
p.pack.n_boxes  = 2;              % housings, connected in series
p.pack.tunnel   = 250;            % (A) mm tunnel width between boxes (central tube + shaft)
p.pack.f_mass   = 1.20;           % (A) pack mass / cell mass (BMS, busbars, housing)
p.pack.gap      = 1.0;            % (A) mm gap between cells (insulation)
p.pack.endplate = 15;             % (A) mm compression end plate thickness
p.pack.margin   = 25;             % (A) mm housing wall + space around cells

p.bat.E_nom_kWh = p.pack.ns*p.pack.np*p.cell.U_nom*p.cell.C_Ah/1000;  % kWh
p.bat.U_nom     = p.pack.ns*p.cell.U_nom;                              % V
p.bat.DoD       = 0.90;           % usable share
p.bat.eta       = 0.95;           % charge/discharge efficiency
p.bat.e_spec    = p.cell.U_nom*p.cell.C_Ah/1000 / (p.cell.mass*p.pack.f_mass); % kWh/kg

%% Daily off-road cycle
p.cyc.v_avg     = 20/3.6;         % (A) m/s average speed
p.cyc.h_up      = 1500;           % (A) m elevation gain per day
p.cyc.recup     = 0.5;            % (A) share of potential energy recovered downhill
p.cyc.eta_el    = 0.85;           % (A) motor + inverter efficiency
p.cyc.P_aux     = 300;            % (A) W lights, cooling, electronics

%% Solar (foldable panels in side boxes + fixed roof panel)
p.sol.area   = 4.5;               % (A) m^2 unfolded
p.sol.eta    = 0.21;              % (A) module efficiency
p.sol.H_day  = 5.5;               % (A) kWh/m^2 per clear day (alpine summer)
p.sol.PR     = 0.80;              % (A) performance ratio (MPPT, angle, dirt)

%% Range extender (petrol, charges at standstill only)
p.rex.P_el     = 10e3;            % W electrical output
p.rex.bsfc     = 300;             % (A) g/kWh mechanical
p.rex.eta_gen  = 0.92;            % (A) generator + rectifier
p.rex.tank_L   = 20;              % (A) litres
p.rex.rho_fuel = 0.745;           % kg/L petrol

%% ===================== GEARBOX =====================
% Load collective (duty cycle). One row per load case:
%   [time share, motor torque / T_peak, motor speed in rpm, gear (1=low, 2=high)]
% Shares must add up to 1. Motor torque must lie below the motor curve.
% Check: torque * speed must stay below P_peak (40 kW), long cases below P_cont.
p.gb.lc = [ 0.02  1.00  1000  1     % max. gradient, crawling       (22 kW)
            0.10  0.60  2500  1     % steep off-road                (33 kW)
            0.38  0.20  4000  1     % normal off-road               (18 kW)
            0.40  0.12  6000  2     % road, constant speed          (16 kW)
            0.10  0.50  3500  2 ];  % road, acceleration / hills    (38 kW)
p.gb.lc_names = {'Max grade', 'Steep off-road', 'Off-road', 'Road cruise', 'Road accel'};
p.gb.L_h      = 3000;             % (A) design life in operating hours

% Load factors (ISO 6336 style, simplified)
p.gb.K_A      = 1.5;              % (A) application factor for peak/shock (off-road)
p.gb.K_v      = 1.1;              % (A) dynamic factor
p.gb.K_beta   = 1.3;              % (A) face load factor
p.gb.K_gamma  = 1.15;             % (A) load sharing between planets
p.gb.axle_share_max = 1.0;        % worst case: all torque to one axle (lockers)

% Bevel stage (90 deg, motor transverse). Values at mean cone diameter.
p.gb.bev.z1 = 17;                 % pinion (motor)
p.gb.bev.z2 = 34;                 % wheel  -> i = z2/z1 should match p.dl.i_bevel
p.gb.bev.m  = 3.5;                % mm mean normal module (210 Nm motor)
p.gb.bev.b  = 23;                 % mm face width (keep b/R_e <= 0.3)

% Planetary set (uses p.dl.z_sun, p.dl.z_ring, p.dl.n_planets)
p.gb.pl.m   = 3.0;                % mm module (also gives room for planet bearing)
p.gb.pl.b   = 30;                 % mm face width

% Tooth geometry (reference profile DIN 867 / ISO 53, no profile shift)
p.gb.alpha    = 20;               % deg pressure angle
p.gb.ha       = 1.0;              % addendum factor  (h_a = ha*m)
p.gb.hf       = 1.25;             % dedendum factor  (h_f = hf*m)
p.gb.rim_fac  = 3.0;              % (A) min. rim thickness below root = rim_fac*m

% Gear material: case-hardened steel, e.g. 18CrNiMo7-6
p.mat.sigma_Flim = 430;           % MPa tooth root endurance limit (conservative)
p.mat.sigma_Hlim = 1500;          % MPa flank endurance limit
p.mat.Z_E        = 189.8;         % sqrt(MPa) elasticity factor steel/steel
p.mat.S_Fmin     = 1.4;           % required safety tooth root
p.mat.S_Hmin     = 1.1;           % required safety flank

% Shafts: 42CrMo4 quenched and tempered
p.sh.Re        = 650;             % MPa yield strength
p.sh.S_static  = 1.5;             % safety against yield at peak torque
p.sh.tau_pre   = 60;              % (A) MPa allowable torsion stress for pre-sizing,
                                  %     covers unknown bending and notches
p.sh.k         = 6;               % Woehler exponent for equivalent torque

% Bearings
p.br.p = 10/3;                    % life exponent (roller/needle bearings)
end
