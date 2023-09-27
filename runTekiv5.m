function runTekiv5(btag)

global TDT;

try
    if numel(btag)>1
        fprintf('\n\n----------------------- A new trial started -------------------\n')
        params = strsplit(btag,'SPKTeki');
        params = strsplit(params{2},'END');      
        params=strsplit(params{1},'.');
        disp(params)
        BF=str2double(params{2});
        disp(BF)
        beep_duration_str=params{7};
        ind_=strfind(params{7},'_');
        beep_duration=str2double(beep_duration_str(1:ind_-1));
        beep_frequency=str2double(params{6});
        cdt=str2double(params{5}) %trial condition takes from [-1,0,1,2,3,4] randomizez by labview
        N_back_pool=str2double(params{3}); %6
        N_fig_pool=str2double(params{4}); %4
        N_fig_add=3;
        N_repeats=1;
        
        TDT.NT = TDT.NT+1;
        TDT = TDT.updateCS(0);
        N_t=TDT.NT;
        %day=datetime('today');
        %day_str=datestr(day);
        day=datestr(now);
        index_sp=findstr(' ',day);
        day_str=day(1:index_sp-1);
        N_sets=3;
        
       
        if TDT.NT<=1
            for k=1:N_sets
                [frequencies_targ0,frequencies_back0]=freq_selector(BF,0,N_fig_pool+N_fig_add,N_back_pool);
                [frequencies_targm1,frequencies_backm1]=freq_selector(BF,-1,N_fig_pool,N_back_pool);
                [frequencies_targ1,frequencies_back1]=freq_selector(BF,1,N_fig_pool,N_back_pool);
                [frequencies_targ2,frequencies_back2]=freq_selector(BF,2,N_fig_pool,N_back_pool);
                [frequencies_targ3,frequencies_back3]=freq_selector(BF,3,N_fig_pool,N_back_pool);
                [frequencies_targ4,frequencies_back4]=freq_selector(BF,4,N_fig_pool,N_back_pool);

                save(['data_alux_',day_str,'/freq_targ0_back0_',num2str(k),'.mat'],'frequencies_targ0','frequencies_back0');
                save(['data_alux_',day_str,'/freq_targm1_backm1_',num2str(k),'.mat'],'frequencies_targm1','frequencies_backm1');
                save(['data_alux_',day_str,'/freq_targ1_back1_',num2str(k),'.mat'],'frequencies_targ1','frequencies_back1');
                save(['data_alux_',day_str,'/freq_targ2_back2_',num2str(k),'.mat'],'frequencies_targ2','frequencies_back2');
                save(['data_alux_',day_str,'/freq_targ3_back3_',num2str(k),'.mat'],'frequencies_targ3','frequencies_back3');
                save(['data_alux_',day_str,'/freq_targ4_back4_',num2str(k),'.mat'],'frequencies_targ4','frequencies_back4');
            end
        end 
        ind_select=randi(3)
        save(['data_alux_',day_str,'/trial_info_',num2str(TDT.NT),'.mat'],'N_t','cdt','ind_select')
        if cdt==0
            freqs=load(['data_alux_',day_str,'/freq_targ0_back0_',num2str(ind_select),'.mat']);
            frequencies_targ=freqs.frequencies_targ0
            frequencies_back=freqs.frequencies_back0
        elseif cdt==-1
            freqs=load(['data_alux_',day_str,'/freq_targm1_backm1_',num2str(ind_select),'.mat']);
            frequencies_targ=freqs.frequencies_targm1
            frequencies_back=freqs.frequencies_backm1
        elseif cdt==1
            freqs=load(['data_alux_',day_str,'/freq_targ1_back1_',num2str(ind_select),'.mat']); 
            frequencies_targ=freqs.frequencies_targ1
            frequencies_back=freqs.frequencies_back1           
        elseif cdt==2
            freqs=load(['data_alux_',day_str,'/freq_targ2_back2_',num2str(ind_select),'.mat']); 
            frequencies_targ=freqs.frequencies_targ2
            frequencies_back=freqs.frequencies_back2      
        elseif cdt==3
            freqs=load(['data_alux_',day_str,'/freq_targ3_back3_',num2str(ind_select),'.mat']); 
            frequencies_targ=freqs.frequencies_targ3
            frequencies_back=freqs.frequencies_back3    
        elseif cdt==4
            freqs=load(['data_alux_',day_str,'/freq_targ4_back4_',num2str(ind_select),'.mat']);  
            frequencies_targ=freqs.frequencies_targ4
            frequencies_back=freqs.frequencies_back4 
        end
        %disp('aaaaaaaaaaaaaaaaaaa')
        getTekiv5(TDT,beep_duration,frequencies_targ,frequencies_back,beep_frequency,cdt,N_fig_pool);
        i = 0;
        %save('params_teki.mat','N_coherence','N_on_off','N_repeats','beep_duration','beep_frequency','frequencies_targ','frequencies_back','i','cdt');
        save('params_teki.mat','N_repeats','beep_duration','beep_frequency','frequencies_targ','frequencies_back','i','cdt','N_fig_pool');
    else
        
        params_teki = load('params_teki.mat');
        i = params_teki.i; 
        frequencies_targ=params_teki.frequencies_targ;
        frequencies_back=params_teki.frequencies_back;
        cdt=params_teki.cdt;
        N_fig_pool=params_teki.N_fig_pool;
        N_repeats=params_teki.N_repeats;
       
   
        switch btag
            case '5' % ToneOn
              
                if i <= N_repeats-1
                   
                    fprintf('\nPlaying pre-target...\n');
                                 
                    TDT.triggerTDT(1);
                  
                    i = i+1;
                    
                    save('params_teki.mat','N_repeats','i','frequencies_targ','frequencies_back','cdt','N_fig_pool')
                else
                    fprintf('\nPlaying target...\n');
                 
                    TDT.triggerTDT(3);
                
                end
            case '9'
                
                fprintf('\nSound stopped.\n')
               
                TDT.triggerTDT(2); % turn off pre-target tone
                TDT.triggerTDT(4); % turn off target tone
                %TDT = TDT.updateCS(0); % reset state-list
                TDT.RP.ZeroTag('Streamfig1');
                TDT.RP.ZeroTag('Streamfig2');
                %fprintf('\n\n--------------- A new trial started ---------------\n\n')

        
        end
       
    end
catch
    
    %disp('!!! Pass to the next trial !!!')
end
