% Author: Mallios Dimitris
% 
%
%x = SpeedToDopplerShift(0);
freq = 1e9;				%Radar frequency
observer_speed = 10;
car_speed = 0;
lightspeed = 299792458; % Speed of light in m/s
%v = 23.0;

measured_freq = freq * (lightspeed + observer_speed)/(lightspeed + car_speed); 
doppler_shift = freq - measured_freq 
%lambda = lightspeed/freq;
%dopplershift = speed2dop(v,lambda)
