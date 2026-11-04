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
p.veh.m_empty   = 1000;           % (A) kg, incl. battery
p.veh.m         = p.veh.m_empty + p.req.payload;   % kg, fully loaded
p.veh.cw        = 0.8;            % (A) drag coefficient
p.veh.A         = 2.5;            % (A) m^2 frontal area
p.veh.r_dyn     = 0.35;           % (A) m dynamic tyre radius
p.veh.wheelbase = 1.80;           % (A) m
p.veh.h_cg      = 0.75;           % (A) m centre of gravity height
p.veh.load_front = 0.50;          % (A) static share of weight on front axle
p.veh.width     = 1.45;           % (A) m
p.veh.clearance = 0.32;           % (A) m

%% Terrain
p.terr.f_r_road = 0.015;          % rolling resistance on asphalt
p.terr.f_r_off  = 0.06;           % (A) gravel / forest track
p.terr.mu_off   = 0.8;            % (A) tyre-ground friction, dry off-road

%% Electric motor (central motor, placeholder values)
p.mot.T_peak = 120;               % (A) Nm
p.mot.T_cont = 60;                % (A) Nm
p.mot.P_peak = 50e3;              % (A) W
p.mot.P_cont = 25e3;              % (A) W
p.mot.n_max  = 8000;              % (A) rpm

%% Driveline: bevel stage -> 2-speed planetary -> axle diffs (with lockers)
% Low gear: sun in, ring fixed, carrier out -> i = 1 + z_ring/z_sun
% High gear: planetary locked              -> i = 1
p.dl.z_sun     = 24;
p.dl.z_ring    = 60;
p.dl.n_planets = 3;
p.dl.i_bevel   = 2.0;             % (A)
p.dl.i_axle    = 5.5;             % (A) axle drive incl. hub reduction
p.dl.eta       = 0.90;            % (A) total mechanical efficiency

%% Battery
p.bat.E_nom_kWh = 30;             % kWh nominal
p.bat.U_nom     = 102;            % V
p.bat.DoD       = 0.90;           % usable share
p.bat.eta       = 0.95;           % charge/discharge efficiency
p.bat.e_spec    = 0.16;           % (A) kWh/kg on pack level

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
p.gb.lc = [ 0.02  1.00  1000  1     % max. gradient, crawling
            0.10  0.60  2500  1     % steep off-road
            0.38  0.30  4000  1     % normal off-road
            0.40  0.20  6000  2     % road, constant speed
            0.10  0.80  3500  2 ];  % road, acceleration / hills
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
p.gb.bev.m  = 3.0;                % mm mean normal module
p.gb.bev.b  = 20;                 % mm face width (keep b/R_e <= 0.3)

% Planetary set (uses p.dl.z_sun, p.dl.z_ring, p.dl.n_planets)
p.gb.pl.m   = 2.5;                % mm module
p.gb.pl.b   = 25;                 % mm face width

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
