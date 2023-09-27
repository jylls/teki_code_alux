function getTekiv5(TDT,boop_duration,frequency_targ, frequency_back,beep_frequency,cdt,N_fig_pool)

%%%%%%%%%%%%%%%%%%%%%%%%%Figuring out tone onsets%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
duration_tone=50;
freq_spacing=2;
N_freq_targ=length(frequency_targ);
N_freq_back=length(frequency_back);
back_duration=floor(boop_duration/2);
targ_duration=floor(boop_duration/2);
N_slots_targ=floor(targ_duration/duration_tone);
N_slots_back=floor(back_duration/duration_tone);
N_power=3; %used to be 2 until 05/26/22

onsets_back=gen_rand_bin_mat(N_freq_back,N_slots_back,N_power);
onsets_targ_back=gen_rand_bin_mat(N_freq_back,N_slots_back,N_power);

if cdt==0
    onsets_targ_targ=gen_rand_bin_mat(N_freq_targ,N_slots_targ,N_fig_pool); 
else
    onsets_targ_targ=ones(N_freq_targ,N_slots_targ);
end
%day=datetime('today');
%day_str=datestr(day);
day=datestr(now);
index_sp=findstr(' ',day);
day_str=day(1:index_sp-1);

%load(['data_alux_',day_str,'/random_tone_matrix_',day_str,'.mat']);
onsets={}
onsets{1}={onsets_back,onsets_targ_back,onsets_targ_targ};
save(['data_alux_',day_str,'/random_mats/random_tone_matrix_',day_str,'_',num2str(TDT.NT),'.mat'],'onsets')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Tone generation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs = TDT.RP.GetSFreq();
disp(fs)
tone_level=70;
ttotal_back=0:1/fs:(back_duration)/1000;
ttotal_back=ttotal_back(1:length(ttotal_back)-1);
tt = 0:1/fs:duration_tone/1000;
tt=tt(1:length(tt)-1);
N_samples_tone=length(tt);
N_total_back=length(ttotal_back);
boop_back=zeros(N_freq_back,N_total_back);

rampLength=10; %ms
cosRamp = (rampLength/1000)*fs;

%tone_level_back_ind=freq_spacing*round((tone_level-10*log10(N_power))/freq_spacing)
tone_level_back_ind=round((tone_level-10*log10(N_power)));
disp(['tone_level_back_ind ',num2str(tone_level_back_ind)]);
%tone_level_back_ind=70
for i=1:N_freq_back
    if mod(tone_level_back_ind,freq_spacing)~=0
        TDT.getTDT_sV(frequency_back(i),tone_level_back_ind-1);
        lev_down=TDT.TNR;
        TDT.getTDT_sV(frequency_back(i),tone_level_back_ind+1);
        lev_up=TDT.TNR;
        T_voltage(i)=(lev_up+lev_down)/2;
     
    else
        TDT.getTDT_sV(frequency_back(i),tone_level_back_ind);
        T_voltage(i)=TDT.TNR;
    end
    for j=1:N_slots_back
        if onsets_back(i,j)==1
            temp=T_voltage(i)*sin(2*pi*frequency_back(i)*tt);
            boop_back(i,(j-1)*N_samples_tone+1:j*N_samples_tone)=temp;
        end
    end
end

boop_chord_back=sum(boop_back,1);%/sqrt(N_power); 
%boop_chord_back=pa_ramp(boop_chord_back,cosRamp, fs)

for j=1:N_slots_back
    boop_chord_back(1,(j-1)*N_samples_tone+1:j*N_samples_tone)=pa_ramp(boop_chord_back(1,(j-1)*N_samples_tone+1:j*N_samples_tone), cosRamp, fs);
end


%%%%%%Constructing targ_back%%%%%%%%%%%%%%
%tone_level_targ_back_ind=freq_spacing*round((tone_level-10*log10(N_power+N_freq_targ))/freq_spacing)
%tone_level_targ_back_ind=tone_level

tone_level_targ_back_ind=round(tone_level-10*log10(N_power+N_fig_pool));

disp(['tone_level_targ_back_ind ',num2str(tone_level_targ_back_ind)]);
%disp(['tone_level_targ_back_ind',num2str(tone_level_targ_back_ind)])
ttotal_targ=0:1/fs:(targ_duration)/1000;
ttotal_targ=ttotal_targ(1:length(ttotal_targ)-1);
N_total_targ=length(ttotal_targ);
boop_targ_back=zeros(N_freq_back,N_total_targ);
boop_targ_targ=zeros(N_fig_pool,N_total_targ);
disp('iiiiiiiiiiiiii')
for i=1:N_freq_back
    if mod(tone_level_targ_back_ind,freq_spacing)~=0
        TDT.getTDT_sV(frequency_back(i),tone_level_targ_back_ind-1);
        lev_down=TDT.TNR;
        TDT.getTDT_sV(frequency_back(i),tone_level_targ_back_ind+1);
        lev_up=TDT.TNR;
        T_voltage(i)=(lev_up+lev_down)/2;
        
    else
        TDT.getTDT_sV(frequency_back(i),tone_level_targ_back_ind);
        T_voltage(i)=TDT.TNR;
    end
    for j=1:N_slots_targ
        if onsets_targ_back(i,j)==1
            temp=T_voltage(i)*sin(2*pi*frequency_back(i)*tt);
            boop_targ_back(i,(j-1)*N_samples_tone+1:j*N_samples_tone)=temp;
        end
    end
end

%%%%%%Constructing targ_targ%%%%%%%%%%%%%%

for i=1:N_freq_targ
   if mod(tone_level_targ_back_ind,freq_spacing)~=0
        TDT.getTDT_sV(frequency_targ(i),tone_level_targ_back_ind-1);
        lev_down=TDT.TNR;
        TDT.getTDT_sV(frequency_targ(i),tone_level_targ_back_ind+1);
        lev_up=TDT.TNR;
        T_voltage(i)=(lev_up+lev_down)/2;        
    else
        TDT.getTDT_sV(frequency_targ(i),tone_level_targ_back_ind);
        T_voltage(i)=TDT.TNR;
    end
    for j=1:N_slots_targ
        if onsets_targ_targ(i,j)==1
            temp=T_voltage(i)*sin(2*pi*frequency_targ(i)*tt);
            boop_targ_targ(i,(j-1)*N_samples_tone+1:j*N_samples_tone)=temp;
        end
    end
end

boop_targ=cat(1,boop_targ_back,boop_targ_targ);
boop_chord_targ=sum(boop_targ,1);%/sqrt(N_power+N_freq_targ); 

for j=1:N_slots_back
    disp(size(pa_ramp(boop_chord_targ(1,(j-1)*N_samples_tone+1:j*N_samples_tone), cosRamp, fs)))
    boop_chord_targ(1,(j-1)*N_samples_tone+1:j*N_samples_tone)=pa_ramp(boop_chord_targ(1,(j-1)*N_samples_tone+1:j*N_samples_tone), cosRamp, fs);
end

boop_chord=cat(2,boop_chord_back,boop_chord_targ);

%day=datetime('today');
%day_str=datestr(day);
day=datestr(now);
index_sp=findstr(' ',day);
day_str=day(1:index_sp-1);

%load(['data_alux_',day_str,'/boop_chords_matrix_',day_str,'.mat'])
boop_chords={}
boop_chords{1}={boop_chord};
save(['data_alux_',day_str,'/boop_chords/boop_chords_matrix_',day_str,'_',num2str(TDT.NT),'.mat'],'boop_chords')
disp('gggggggggggggg')
%%%%%%%Constructing beep%%%%%%%%%%%%%%
ttbeep=0:1/fs:boop_duration/1000;
disp(length(ttbeep));
ttbeep=ttbeep(1:length(ttbeep)-1);
TDT.getTDT_sV(beep_frequency,tone_level);
beep_voltage=TDT.TNR;
beep=beep_voltage*sin(2*pi*beep_frequency*ttbeep);
beep=pa_ramp(beep, cosRamp, fs);
%save('beep.mat','beep')
bufferBoop = ceil(fs*boop_duration/1000);
bufferBeep = ceil(fs*boop_duration/1000);

%% Upload to RX8
fprintf('  -->  Uploading Stimulus... ')
% common stuffs
%TDT.RP.SetTagVal('Buffer', toneBuffer); % Set buffer size


TDT.RP.SetTagVal('Buffer1',bufferBoop); % Set buffer size
TDT.RP.SetTagVal('Buffer2',bufferBeep); % Set buffer size
% full stream A to speaker location A
%RP.SetTagVal('DAC_RChan', A_loc); % Speaker Switching Code

TDT.RP.WriteTagVEX('Stream1', 0, 'F32', boop_chord);   
TDT.RP.WriteTagVEX('Stream2', 0, 'F32', beep);
% full stream T to speaker location A
%TDT.RP.WriteTagVEX('Stream2', 0, 'F32', stream2);

fprintf('done!\n')


end






