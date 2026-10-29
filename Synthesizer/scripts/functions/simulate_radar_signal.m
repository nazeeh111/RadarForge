function signal_array = simulate_radar_signal(reflector_cart_v, snr_db)
% Synth Radar signal

% Simualte received radar signal in the receiver antenna array
% Input: "reflector_cart_v" coordinates of point reflectors in the scene 
% Output: "signal_array" FMCW beat signals in the antenna array

    if nargin < 2, snr_db = -10; end
    validateattributes(reflector_cart_v, {'numeric'}, {'2d','ncols',3,'real','finite'});
    validateattributes(snr_db, {'numeric'}, {'scalar','real','nonnan'});
    if isinf(snr_db) && snr_db < 0, error('RadarForge:InvalidSNR','SNR must not be -Inf'); end
    if any(sum(reflector_cart_v.^2,2) == 0)
        error('RadarForge:ZeroRange','Reflectors must not coincide with the RX origin');
    end
    variable_library_radar; % load radar configurations
        
    t_ax = 0:1/Rs:(Ts-1/Rs); t_ax = t_ax.'; % time axis
    t_matrix = repmat(t_ax,1,array_size(1),array_size(2));

    array_x_m = repmat(array_x_idx*array_gap(1),1,array_size(2));
    array_z_m = repmat(array_z_idx*array_gap(2),array_size(1),1);

    signal_array = zeros(length(t_ax),array_size(1),array_size(2));

    for kp = 1:size(reflector_cart_v,1)
        d_TX2reflector = sqrt((TX_pos(1)-reflector_cart_v(kp,1)).^2+(TX_pos(2)-reflector_cart_v(kp,2)).^2+ (TX_pos(3)-reflector_cart_v(kp,3)).^2);
        % distance between the TX antenna and the point reflector
        d_RX2reflector = reshape(sqrt((array_x_m-reflector_cart_v(kp,1)).^2 + reflector_cart_v(kp,2)^2 + (array_z_m-reflector_cart_v(kp,3)).^2),[1,array_size(1),array_size(2)]);
        % distance between each RX antenna and the point reflector
        tau = repmat((d_TX2reflector+d_RX2reflector)/c,[length(t_ax),1,1]); % round trip Time of Flight (ToF)
        if d_TX2reflector == 0 || any(d_RX2reflector(:) == 0)
            error('RadarForge:ZeroRange','Reflector coincides with an antenna');
        end
        path_loss = repmat(1 ./ (d_TX2reflector .* d_RX2reflector),[length(t_ax),1,1]);
        pt_signal = (path_loss.*exp(1j * 2 * pi * fc * tau)).* exp(1j * 2*pi * As * t_matrix .* tau); % beat signal from a single point reflector
        signal_array = signal_array + pt_signal; % summing up signals from all point reflector to get the received signal in the antenna array
    end
    
    % Preserve awgn's historical default: 0 dBW assumed signal power, not
    % measured signal power. Inf explicitly disables noise for numerical work.
    if ~isinf(snr_db)
        if exist('awgn','file') == 2
            signal_array = awgn(signal_array,snr_db);
        else
            noise_power = 10^(-snr_db/10);
            noise = sqrt(noise_power/2) .* (randn(size(signal_array)) + 1i*randn(size(signal_array)));
            signal_array = signal_array + noise;
        end
    end
end