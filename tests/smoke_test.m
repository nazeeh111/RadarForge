% Offline checks; run from repository root.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);
addpath(fullfile(root,'Synthesizer','scripts'));
addpath(fullfile(root,'Synthesizer','scripts','functions'));
variable_library_radar;
% Deterministic nonzero plane wave at the first selected range bin.
signal=complex(zeros(N_FFT,array_size(1),array_size(2)));
signal(:,1,1)=exp(1i*2*pi*(range_bin_FoV(1)-1)*(0:N_FFT-1)'/N_FFT);
actual=radar_forge(signal);
expected=radar_dsp(signal);
assert(isequaln(actual,expected));
assert(isequal(size(actual),[N_rho N_phi N_theta]));
assert(all(isfinite(actual(:))) && all(actual(:)>=0));
assert(any(actual(:)>0));
[~,peak]=max(squeeze(actual(:,1,1))); assert(peak==1);
fprintf('PASS RadarForge: full %dx%dx%d radar DSP tensor, exact facade parity and expected range peak\n',size(actual));
