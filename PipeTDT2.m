classdef PipeTDT2< handle
    
    % Class of matlab objects used to connect to TDT using the RP activeX
    % control and to control stimulus parameters and generation in TDT
    
    % connect to obj RZ6 ands set parameters
    properties
        calib = []; % tone calibration data
        RP = [];
        RCX = []; % rcx filename and path
        TT = []; % TaskType
        TNR = []
        freq = 2000;
        % functions
        fns = {'Pick A Function','';'runTekiv5','vico_v3.rcx';}
            
        % Task Types
        TaskT = {}; 
        NT = 0;     % Number of Trials
        CS = 1; % CurrentStep
        evalfn = [];
        evalfn_name = [];
        dummy = [];
        V = [];
        fs = []; %sampling freq
        bufferLength = 0;
      
    end
    methods
        % Setup, Connect & Load rcx file
        function obj = PipeTDT2(circ)
            obj.RCX = circ;
            % setup
            obj.RP = actxcontrol('RPco.x',[5 5 26 26]);
            % connect
            if obj.RP.ConnectRZ6('GB',1)
                disp('connected')
            else
                error('Unable to connect')
            end
            cd 'D:\Users\cohen\dwnlds\Documents\Documents\MATLAB\Calibration'
            if  exist('calib_20230410.mat','file')==2%exist('calib_20220315.mat','file')==2
                dt = dir('calib_20230410.mat');
                obj.dummy = load('calib_20230410.mat');
                obj.calib = obj.dummy.calib;
                st = strcat('Loaded Calibration file dated:',dt.date);
                disp(st);
            end
            
        end
        
        % set Parameter Tag Value
        function setTDT_PT(obj,tag,val)
            %disp(tag);
            e = obj.RP.SetTagVal(tag,val);
            if e~=1
                error('set parameter failed')
            end
        end
        
        function writeTDT_TV(obj,tag,val)
            e = obj.RP.WriteTagV(tag,0,val);
            if e~=1
                error('write parameter failed')
            end
        end
        
        % Trigger Software Trigger
        function triggerTDT(obj,tag)
            e = obj.RP.SoftTrg(tag);
            if e~=1
                error('trigger failed')
            end
        end
        
        % Setup & Run RCX file
        function runTDT(obj)
            FN = obj.fns{obj.evalfn+(numel(obj.fns)./2)};
            obj.evalfn_name = FN;
            disp(FN)
            FN = strcat(obj.RCX,FN);
            % Loads circuit file
            obj.RP.ClearCOF()
            e = obj.RP.LoadCOF(FN);
            if e==0
                disp 'Error loading circuit'
            elseif obj.RP.Run();
                d = strcat('Running TDT circuit..',FN);
                disp(d);
            end
        end
        
        
        % Halt & Reset
        function haltTDT(obj)
            if obj.RP.Halt() && obj.RP.ClearCOF();
                disp('Halted RZ6 & Reset..');
            else
                disp('Reset failed');
            end         
        end
        
        % Update current state
        function obj = updateCS(obj,flag)
           if flag==0
               obj.CS = 1; % reset states
           elseif flag==1
               obj.CS = obj.CS+1; % Next state
           end
        end
        
        
        % get TDT voltage from calibration data for switchingTones task
        function obj = getTDT_sV(obj,fs,dbs)
            if ~isempty(obj.calib)
                dB = obj.calib(1,:,2);
                %disp(dB)
                F = obj.calib(:,1,1);
                Vol = obj.calib(:,:,3);
                Vol(Vol>1.22) = NaN; % error check
              
                % First figure out which Std freq to use
                if fs<500 || fs>12000
                    error('Frequency out of range')
                else
                    [~,Fi] = min(abs(F-fs));
                end
                obj.freq = F(Fi);
                % Figure out V
                dBi = dB==dbs;
                %disp(dBi)
                obj.TNR = Vol(Fi,dBi);
                disp(obj.TNR)
                % error check
                if obj.TNR>1.22
                    error('Voltage over 1.22V')
                end
            end
        end
        
      
        % get TDT sampling frequency
        function obj = getTDT_sFreq(obj)
            obj.fs = obj.RP.GetSFreq();
        end
        
        function obj = setTDT_bufferLength(obj,bLength)
            obj.bufferLength = bLength;
        end
        
        % write data to a serial buffer
        function obj = writeTDT_buffer(obj,bufName,dataIn)
            e1 = obj.RP.WriteTagVEX(bufName, 0, 'F32', dataIn);
            %disp('e1')
            %disp(e1)
            if ~e1
                error('Cound not write to buffer');
            end
        end
    end
end