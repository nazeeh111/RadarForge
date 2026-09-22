function varargout = radar_forge(varargin)
% RadarForge: Synthesize and inspect radar scenes.
% Passes arguments and outputs directly to radar_dsp.
root = fileparts(mfilename('fullpath'));
previousPath = path;
cleanup = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
addpath(fullfile(root, 'Synthesizer', 'scripts', 'functions'));
addpath(fullfile(root, 'Synthesizer', 'scripts'));
[varargout{1:nargout}] = radar_dsp(varargin{:});
end
