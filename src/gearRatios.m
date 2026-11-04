function dl = gearRatios(p)
% GEARRATIOS  Overall ratios of the 2-speed planetary driveline.
%   Low gear : ring fixed, sun in, carrier out -> i = 1 + z_ring/z_sun
%   High gear: planetary locked                -> i = 1

zs = p.dl.z_sun;
zr = p.dl.z_ring;

dl.i_planet_low  = 1 + zr/zs;
dl.i_planet_high = 1;
dl.i_fixed       = p.dl.i_bevel * p.dl.i_axle;

dl.i_low  = dl.i_fixed * dl.i_planet_low;
dl.i_high = dl.i_fixed * dl.i_planet_high;
dl.step   = dl.i_low / dl.i_high;

% Planetary geometry checks
dl.z_planet     = (zr - zs)/2;                          % coaxiality
dl.coaxial_ok   = mod(zr - zs, 2) == 0;
dl.assembly_ok  = mod(zs + zr, p.dl.n_planets) == 0;    % equal spacing
end
