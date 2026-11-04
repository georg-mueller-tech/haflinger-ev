function tr = tractionAnalysis(p, dl)
% TRACTIONANALYSIS  Gradeability, top speed, motor power, adhesion, tipping.

r     = p.veh.r_dyn;
eta   = p.dl.eta;
m     = p.veh.m;
alpha = atan(p.req.grade_max);

%% 1) Max gradient in low gear (crawling, v ~ 0)
F_req = drivingResistance(p, 0, p.req.grade_max, p.terr.f_r_off);
tr.T_wheel_req   = F_req * r;                               % Nm, all wheels
tr.T_wheel_avail = p.mot.T_peak * dl.i_low * eta;
tr.grade_ok      = tr.T_wheel_avail >= tr.T_wheel_req;
tr.i_low_min     = tr.T_wheel_req / (p.mot.T_peak * eta);   % needed ratio

%% 2) Top speed in high gear (asphalt, flat)
n_wheel_vmax = p.req.v_max / r * 60/(2*pi);                 % rpm
tr.n_mot_vmax = n_wheel_vmax * dl.i_high;
tr.i_high_max = p.mot.n_max / n_wheel_vmax;
F_vmax        = drivingResistance(p, p.req.v_max, 0, p.terr.f_r_road);
tr.P_vmax     = F_vmax * p.req.v_max / (eta * p.cyc.eta_el); % W electrical
tr.vmax_ok    = tr.n_mot_vmax <= p.mot.n_max && ...
                F_vmax * p.req.v_max / eta <= p.mot.P_peak;

%% 3) Continuous power case (long climb)
F_cont    = drivingResistance(p, p.req.cont_speed, p.req.cont_grade, p.terr.f_r_off);
tr.P_cont_req = F_cont * p.req.cont_speed / eta;            % W at motor shaft
tr.cont_ok    = tr.P_cont_req <= p.mot.P_cont;

%% 4) Adhesion at max gradient (4WD, all diffs locked)
tr.F_adh    = p.terr.mu_off * m * p.g * cos(alpha);
tr.F_req    = F_req;
tr.adh_ok   = tr.F_adh >= F_req;
tr.mu_req   = F_req / (m * p.g * cos(alpha));

%% 5) Axle loads uphill at max gradient -> front axle must not lift
L   = p.veh.wheelbase;
l_r = p.veh.load_front * L;            % distance CG -> rear axle
h   = p.veh.h_cg;
tr.N_front = m * p.g * (cos(alpha)*l_r - sin(alpha)*h) / L;
tr.N_rear  = m * p.g * cos(alpha) - tr.N_front;
tr.tip_ok  = tr.N_front > 0;
end
