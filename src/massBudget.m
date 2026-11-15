function [p, mb] = massBudget(p, file_parts, file_payload)
% MASSBUDGET  Mass, centre of gravity and axle loads from the CSV lists.
%   [p, mb] = massBudget(p) reads data/mass_budget.csv and data/payload.csv,
%   computes empty and loaded mass, CG position and axle loads, and writes
%   m_empty, m, h_cg and load_front back into p.veh.
%
%   Coordinates: x from the front axle towards the rear (m),
%                z height above ground (m). Rear axle at x = wheelbase.

root = fileparts(fileparts(mfilename('fullpath')));
if nargin < 2, file_parts   = fullfile(root, 'data', 'mass_budget.csv'); end
if nargin < 3, file_payload = fullfile(root, 'data', 'payload.csv');      end

opts = {'TextType', 'string', 'VariableNamingRule', 'preserve'};
T  = readtable(file_parts,   opts{:});
PL = readtable(file_payload, opts{:});

L = p.veh.wheelbase;

%% Empty vehicle
T.mass_kg = T.qty .* T.mass_each_kg;
mb.parts  = T;
mb.m_empty = sum(T.mass_kg);
mb.x_empty = sum(T.mass_kg .* T.x_m) / mb.m_empty;
mb.z_empty = sum(T.mass_kg .* T.z_m) / mb.m_empty;

%% Loaded vehicle (empty + persons + cargo)
mb.payload   = PL;
mb.m_payload = sum(PL.mass_kg);
mb.m_loaded  = mb.m_empty + mb.m_payload;
mb.x_loaded  = (mb.m_empty*mb.x_empty + sum(PL.mass_kg .* PL.x_m)) / mb.m_loaded;
mb.z_loaded  = (mb.m_empty*mb.z_empty + sum(PL.mass_kg .* PL.z_m)) / mb.m_loaded;

%% Static axle loads (kg)
mb.front_empty  = mb.m_empty  * (L - mb.x_empty)  / L;
mb.rear_empty   = mb.m_empty  - mb.front_empty;
mb.front_loaded = mb.m_loaded * (L - mb.x_loaded) / L;
mb.rear_loaded  = mb.m_loaded - mb.front_loaded;

%% Mass per group
[G, names] = findgroups(T.group);
mb.groups = table(names, splitapply(@sum, T.mass_kg, G), ...
                  'VariableNames', {'group', 'mass_kg'});
mb.groups = sortrows(mb.groups, 'mass_kg', 'descend');
mb.share_estimate = sum(T.mass_kg(T.source == "estimate")) / mb.m_empty;

%% Checks
alpha = atan(p.req.grade_max);
mb.front_min_share  = tan(alpha) * mb.z_loaded / L;      % front axle must not lift at max grade
mb.check.payload_ok = mb.m_payload >= p.req.payload;
mb.check.uphill_ok  = mb.front_loaded/mb.m_loaded > mb.front_min_share;

%% Write results back into the parameters
p.veh.m_empty    = mb.m_empty;
p.veh.m          = mb.m_loaded;
p.veh.h_cg       = mb.z_loaded;
p.veh.load_front = mb.front_loaded / mb.m_loaded;
end
