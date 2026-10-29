% Actual synthesis and independent scalar phase/path-loss reference.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(root,fullfile(root,'Synthesizer','scripts'),fullfile(root,'Synthesizer','scripts','functions'),fullfile(root,'examples'));
variable_library_radar;
for points={ [0,6,0], [0,6,0;0.3,7,0.2], [0,6,0;0.3,7,0.2;-0.5,5,-0.2;0.7,8,0.1] }
    reflectors=points{1}; actual=simulate_radar_signal(reflectors,Inf);
    assert(isequal(size(actual),[N_FFT,array_size]));
    for sample=[1,17,400]
        for x=[1,20,40]
            for z=[1,20,40]
                expected=0;
                for p=1:size(reflectors,1)
                    dtx=norm(TX_pos-reflectors(p,:));
                    drx=norm([array_x_idx(x)*array_gap(1),0,array_z_idx(z)*array_gap(2)]-reflectors(p,:));
                    delay=(dtx+drx)/c;t=(sample-1)/Rs;
                    expected=expected+exp(1i*2*pi*(fc+As*t)*delay)/(dtx*drx);
                end
                assert(abs(actual(sample,x,z)-expected)<1e-9);
            end
        end
    end
end
% Plane wave at a chosen range/azimuth/elevation verifies array ordering/sign.
k=range_bin_FoV(30); pbin=21; tbin=12;
x=reshape(array_x_idx,1,[],1);z=reshape(array_z_idx,1,1,[]);
steering=exp(-1i*2*pi/lambda*(array_gap(1)*x*cos(phi(pbin))*sin(theta(tbin))+array_gap(2)*z*cos(theta(tbin))));
plane=exp(1i*2*pi*(k-1)*(0:N_FFT-1)'/N_FFT).*steering;
map=radar_dsp(plane);[~,idx]=max(map(:));[r,p,t]=ind2sub(size(map),idx);
assert(isequal([r,p,t],[30,pbin,tbin]));
expected_peak=(N_FFT*prod(array_size)*range_bin(k))^2;
assert(abs(map(r,p,t)/expected_peak-1)<1e-12);
% Historical AWGN assumes 0dBW signal power, even for weak targets.
signal=simulate_radar_signal([0,6,0],Inf);
rng(17); noisy=simulate_radar_signal([0,6,0],-10);
noise=noisy-signal;
assert(abs(mean(abs(noise(:)).^2)-10)<0.1); % original awgn 0dBW convention
assert(abs(mean(noise(:)))<0.03);
assert(abs(mean(real(noise(:)).^2)-mean(imag(noise(:)).^2))<0.1);
failed=false;try, simulate_radar_signal([0,0,0],Inf);catch,failed=true;end;assert(failed);
output1=tempname;output2=tempname;
a=scene_to_heatmap(output1,6,42);b=scene_to_heatmap(output2,8,43);
assert(isequal(a.heatmap_size,[96,64,32]));
assert(abs(a.peak_range_m-5.6)<0.3);
assert(abs(b.peak_range_m-7.6)<0.3);
assert(b.peak_range_m>a.peak_range_m+1.5);
% Keep outputs available for inspection rather than deleting newly computed data.
fprintf('PASS synthesis independent scalar reference, AWGN power, scenes 6m/8m: %s %s\n',output1,output2);
