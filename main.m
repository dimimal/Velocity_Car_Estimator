% Author: Mallios Dimitris
% Velocity Car Estimation
%

pkg load signal;
pkg load communications;

%x = SpeedToDopplerShift(0);
freq_radar = 100;				% Radar frequency(100hz)
car_speed = 10;					% m/s
time = 10;						% Measure for 10 seconds
%

% This is a communication simulating Rayleigh Flat Fading Channel
% for one and 2 antennas at the receiver respectively


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialize Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% N is the number of bits for transmision(ip)
%N = 10^3;
ip = [-1 1 -1 1]; %This is for debug purposes
%ip = randi([0,1],N,1);
ip(ip==0) = -1;

oversampling = 10;

% ----------------  input dialog box   ------------------------------------------ %
% Create input dialog box, car_velocity holds the velocity of 
% the car we estimating in km/h
% prompt = ['Velocity(km/h)'];
% car_speed = inputdlg(prompt, 'Enter the velocity of the car', 1)
car_speed = car_speed(1)*1000/3600;	% convert from km/h -> m/s
padded_ip = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%% Pad signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(ip)
    padded_ip = [padded_ip ip(i) zeros(1,oversampling-1)];
end


%Fix points for tx_filter
time = 0:1/oversampling:1 - (1/oversampling);
tx_filter = heaviside(time,1);

%%%%%%%%%%%%%%%%%%%%%%%%% Convolution of Tx Filter with padded signal %%%%%%%%%%%%%
signal = conv(padded_ip,tx_filter);
signal = (1/sqrt(oversampling)) .* signal(1:end-oversampling+1);

tx = zeros(length(signal));



for time = 1:0.01:10
	
	w = [randn(1,length(signal)) + j * randn(1,length(signal))];

	h = 1/sqrt(2)*[randn(1,length(signal)) + j*randn(1,length(signal))]; 

	%Transmitted signal
	tx(time,:) = h .* signal + w;
    
    % Linear Estimator (L.M.M.S.E)
    %size(signal)
    %size(xcov(signal,tx(time,:),'unbiased'))
	%x_hat = xcov(signal,tx(time,:),'unbiased') * pinv(xcov(tx(time,:))) * (tx(time,:) - mean(tx(time,:))) + mean(signal);
    
    % Equalization to remove fading effects
	% rx(time,:) = tx ./ h;

end

% -------------------------------------------------------------------------        
% Uncomment this to plot scatterplot of transmited
% signal, change the first value to obtain the desired
% SNR value
%scatterplot(rx);
%title('signal');
%pause;


% Define receiver's sampler
sampler = oversampling:oversampling:length(ip)*oversampling;

% Match filter at Receivers part and sampling
temp = conv(tx(1,:),tx_filter);
decoded_signal = temp(sampler);

estimate_H = pinv(signal)*(tx(1,:) - w);

figure;
scatterplot(estimate_H(:));
pause;
x_hat = (h * pinv(cov(w)) * h' + cov(decoded_signal)) * (h * pinv(cov(w)) * (tx(1,:) - h' * mean(decoded_signal)))+ mean(tx(1,:));
size(x_hat)
plot([0:length(signal)-1],tx(1,:),'*r',[0:length(signal)-1],x_hat, '*b'); 
%axis tight;
pause;