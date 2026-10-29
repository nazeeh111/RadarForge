function result = scene_to_heatmap(output_dir, distance, seed)
% Recomputable original box surface -> visibility -> reflectors -> signal -> DSP.
% Synthetic scene only. Coordinates in metres: x right, y forward, z up.
if nargin < 2, distance = 6; end
if nargin < 3, seed = 42; end
validateattributes(distance,{'numeric'},{'scalar','real','finite','>=',4,'<=',12});
validateattributes(seed,{'numeric'},{'scalar','integer','nonnegative'});
if exist(output_dir,'file') || exist(output_dir,'dir')
    error('RadarForge:OutputExists','Choose a new output directory');
end
root = fileparts(fileparts(mfilename('fullpath')));
old_path = path; path_cleanup = onCleanup(@() path(old_path)); %#ok<NASGU>
addpath(root,fullfile(root,'Synthesizer','scripts'),fullfile(root,'Synthesizer','scripts','functions'));
old_rng = rng; rng_cleanup = onCleanup(@() rng(old_rng)); %#ok<NASGU>
rng(seed,'twister');
[x,z] = meshgrid(linspace(-0.9,0.9,13),linspace(-0.7,0.7,11));
[y,z2] = meshgrid(linspace(distance-0.4,distance+0.4,9),linspace(-0.7,0.7,11));
[x2,y2] = meshgrid(linspace(-0.9,0.9,13),linspace(distance-0.4,distance+0.4,9));
points = unique([x(:),repmat(distance-0.4,numel(x),1),z(:); ...
 x(:),repmat(distance+0.4,numel(x),1),z(:); ...
 repmat(-0.9,numel(y),1),y(:),z2(:);repmat(0.9,numel(y),1),y(:),z2(:); ...
 x2(:),y2(:),repmat(-0.7,numel(x2),1);x2(:),y2(:),repmat(0.7,numel(x2),1)],'rows');
[bx,by,bz] = meshgrid([-0.9,0.9],[distance-0.4,distance+0.4],[-0.7,0.7]);
scene = struct('cart_v',points,'N_pt',size(points,1),'bbox',[bx(:),by(:),bz(:)]);
started = tic;
visible = remove_occlusion(scene);
reflectors = model_point_reflector(visible,scene.bbox,'base');
assert(~isempty(reflectors),'Scene must generate visible reflectors');
signal = simulate_radar_signal(reflectors,Inf);
heatmap = radar_forge(signal);
variable_library_radar;
[peak_power,idx] = max(heatmap(:));[ri,pi,ti] = ind2sub(size(heatmap),idx);
assert(all(isfinite(heatmap(:))) && peak_power>0);
result = struct('evidence','synthetic surface-to-heatmap; no measured radar or neural model', ...
 'seed',seed,'distance_m',distance,'surface_points',size(points,1),'visible_points',size(visible,1), ...
 'reflectors',size(reflectors,1),'signal_size',size(signal),'heatmap_size',size(heatmap), ...
 'peak_range_m',rho(ri),'peak_azimuth_deg',phi_deg(pi),'peak_elevation_deg',theta_deg(ti), ...
 'peak_power',peak_power,'elapsed_s',toc(started));
mkdir(output_dir);
save(fullfile(output_dir,'scene.mat'),'scene','visible','reflectors','signal','heatmap','rho','phi_deg','theta_deg','result','-v7');
fid=fopen(fullfile(output_dir,'measurements.json'),'w');
if fid<0, error('RadarForge:Output','Cannot open measurements'); end
cleanup=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s\n',jsonencode(result));
disp(result);
end
