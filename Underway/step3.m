% extract all data and put them in the amt22 structure
clear all
%pkg load time

run('../input_parameters.m')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMMENTED 2019 10 23 FN
% Remove noise part to be done manually after final final file is created
% 
% 
% %%%% spurious BB3 (optics?) data (note the time here is still biased, i.e., 1 day behind with respect to the ship's time)
% 
% t2remove = load("noisy_bbp.dat");  % saved after running remove_bbp_noise.m
% t2remove = reshape(t2remove, 2, length(t2remove)/2)';
% 
% 
% t2remove_bb02 = load("noisy_bb02.dat");  % saved after running remove_bbp_noise.m
% t2remove_bb02 = reshape(t2remove_bb02, 2, length(t2remove_bb02)/2)';
% 
% 
% t2remove_cstar = load("noisy_cstar.dat");  % saved after running remove_bbp_noise.m
% t2remove_cstar = reshape(t2remove_cstar, 2, length(t2remove_cstar)/2)';
% 
% 
% t2remove_acs_cp = load("noisy_acs_cp.dat");  % saved after running remove_bbp_noise.m
% t2remove_acs_cp = reshape(t2remove_acs_cp, 2, length(t2remove_acs_cp)/2)';
% 
% 
% %t2remove_acs_ap = load("noisy_acs_ap.dat");  % saved after running remove_bbp_noise.m
% %t2remove_acs_ap = reshape(t2remove_acs_ap, 2, length(t2remove_acs_ap)/2)';
% 
% 
% t2remove_acs_chl = load("noisy_acs_chl.dat");  % saved after running remove_bbp_noise.m
% t2remove_acs_chl = reshape(t2remove_acs_chl, 2, length(t2remove_acs_chl)/2)';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Initialize amt_optics strucure

% acs
amt_optics.acs.chl   = [];
amt_optics.acs.ap    = [];
amt_optics.acs.ap_u  = [];
amt_optics.acs.bp    = [];
amt_optics.acs.bp_u  = [];
amt_optics.acs.cp    = [];
amt_optics.acs.cp_u  = [];
amt_optics.acs.N     = [];
amt_optics.acs.time  = [];

% ac9
amt_optics.ac9.chl   = [];
amt_optics.ac9.ap    = [];
amt_optics.ac9.ap_u  = [];
amt_optics.ac9.bp    = [];
amt_optics.ac9.bp_u  = [];
amt_optics.ac9.cp    = [];
amt_optics.ac9.cp_u  = [];
amt_optics.ac9.N     = [];
amt_optics.ac9.time  = [];

% bb3
amt_optics.bb3.bbp       = [];
amt_optics.bb3.bbp_err   = [];
amt_optics.bb3.bb02      = [];
amt_optics.bb3.bb02_err  = [];
    
%    flds_bdgt = fieldnames(out.bb3.bdgt);
%    for ibdgt = 1 : length(flds_bdgt)
%        amt_optics.bb3.bdgt.(flds_bdgt{ibdgt})  = [];
%    endfor

amt_optics.bb3.bdgt.X  = [];
amt_optics.bb3.bdgt.SF = [];
amt_optics.bb3.bdgt.C  = [];
amt_optics.bb3.bdgt.Bw  = [];
amt_optics.bb3.bdgt.DC = [];
amt_optics.bb3.bdgt.WE = [];

% transmissometer
amt_optics.cstar.cp      = [];
amt_optics.cstar.cp_err  = [];

% flow meter
amt_optics.flow = [];

% ctd
amt_optics.ctd.sst = [];
amt_optics.ctd.sal = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMMENTED 2019 10 23 FN
% Noisy section needs to be removed by hand
%
% %%%% remove spurious optics data
%         it_bbp = 1;       
%         [out, it_bbp]       =   rm_noisy_bbp(out, t2remove, it_bbp);
%             
%         it_bb02 = 1;        
%         [out, it_bb02]      =   rm_noisy_bb02(out, t2remove_bb02, it_bb02);
%             
%         it_bb02 = 1;        
%         [out, it_bdgt_X]      =   rm_noisy_bb02(out, t2remove_bb02, it_bb02);
%             
%         it_cstar = 1;           
%         [out, it_cstar]     =   rm_noisy_cstar(out, t2remove_cstar, it_cstar);
%     
%         it_acs_cp = 1;          
%         [out, it_acs_cp]    =   rm_noisy_acs_cp(out, t2remove_acs_cp, it_acs_cp);
%             
%         it_chl = 1; 
%         [out, it_chl]       =   rm_noisy_acs_chl(out, t2remove_acs_chl, it_chl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


din = DIR_STEP2;
fn = dir([din "*mat"]);

% Expected variables to be present:
# - uway
% - acs
% - ac9
% - bb3
% - cstar
% - flow
% Check each time if they are present or not among the file variablesi



for ifn = 1:size(fn,1)
    disp(["\n" fn(ifn).name])
    load([din fn(ifn).name]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMMENTED 2019 10 23 FN
    %
    % %%%% remove spurious optics data         
    %     [out, it_bbp]    = rm_noisy_bbp   (out, t2remove,        it_bbp    );
    %     [out, it_bb02]   = rm_noisy_bb02  (out, t2remove_bb02,   it_bb02   );
    %     [out, it_cstar]  = rm_noisy_cstar (out, t2remove_cstar,  it_cstar  );
    %     [out, it_acs_cp] = rm_noisy_acs_cp(out, t2remove_acs_cp, it_acs_cp );
    %     [out, it_chl] = rm_noisy_acs_chl(out, t2remove_acs_chl, it_chl);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        

    % Check if acs variable exists
    if ~isempty(intersect('acs', fieldnames(out)))
        % load acs data into amt_optics
        amt_optics.acs.time = [amt_optics.acs.time; out.acs.time];
        amt_optics.acs.chl  = [amt_optics.acs.chl;  chlacs(out.acs)];
        amt_optics.acs.ap   = [amt_optics.acs.ap;   out.acs.ap];
        amt_optics.acs.bp   = [amt_optics.acs.bp;   out.acs.bp];
        amt_optics.acs.cp   = [amt_optics.acs.cp;   out.acs.cp];
        amt_optics.acs.ap_u   = [amt_optics.acs.ap_u;   out.acs.ap_u];
        amt_optics.acs.bp_u   = [amt_optics.acs.bp_u;   out.acs.bp_u];
        amt_optics.acs.cp_u   = [amt_optics.acs.cp_u;   out.acs.cp_u];
        amt_optics.acs.N      = [amt_optics.acs.N;   out.acs.N];
        amt_optics.acs.wv   = [out.acs.wv];
    else
        disp('acs do not exist in file')
    endif

   % Check if ac9 variable exists
    if ~isempty(intersect('ac9', fieldnames(out)))
        % load ac9 data into amt_optics
        amt_optics.ac9.time = [amt_optics.ac9.time; out.ac9.time];
        amt_optics.ac9.chl  = [amt_optics.ac9.chl;  chlac9(out.ac9)];
        amt_optics.ac9.ap   = [amt_optics.ac9.ap;   out.ac9.ap];
        amt_optics.ac9.bp   = [amt_optics.ac9.bp;   out.ac9.bp];
        amt_optics.ac9.cp   = [amt_optics.ac9.cp;   out.ac9.cp];
        amt_optics.ac9.ap_u   = [amt_optics.ac9.ap_u;   out.ac9.ap_u];
        amt_optics.ac9.bp_u   = [amt_optics.ac9.bp_u;   out.ac9.bp_u];
        amt_optics.ac9.cp_u   = [amt_optics.ac9.cp_u;   out.ac9.cp_u];
        amt_optics.ac9.N      = [amt_optics.ac9.N;   out.ac9.N];
        amt_optics.ac9.wv   = [out.ac9.wv];
    else
        disp('ac9 do not exist in file')
    endif

    % Check if bb3 variable exists
    if ~isempty(intersect('bb3',fieldnames(out)))
        % load bb3 data into amt_optics
        amt_optics.bb3.bbp         = [amt_optics.bb3.bbp;       out.bb3.bbp];
        amt_optics.bb3.bbp_err     = [amt_optics.bb3.bbp_err;   out.bb3.bbp_err];
        amt_optics.bb3.bb02        = [amt_optics.bb3.bb02;      out.bb3.bb02];
        amt_optics.bb3.bb02_err    = [amt_optics.bb3.bb02_err;  out.bb3.bb02_err];

        amt_optics.bb3.bdgt.X      = [amt_optics.bb3.bdgt.X  ;  out.bb3.bdgt.X  ];
        amt_optics.bb3.bdgt.SF     = [amt_optics.bb3.bdgt.SF ;  out.bb3.bdgt.SF ];
        amt_optics.bb3.bdgt.C      = [amt_optics.bb3.bdgt.C  ;  out.bb3.bdgt.C  ];
        amt_optics.bb3.bdgt.Bw     = [amt_optics.bb3.bdgt.Bw ;  out.bb3.bdgt.Bw ];
        amt_optics.bb3.bdgt.DC     = [amt_optics.bb3.bdgt.DC ;  out.bb3.bdgt.DC ];
        amt_optics.bb3.bdgt.WE     = [amt_optics.bb3.bdgt.WE ;  out.bb3.bdgt.WE ];
    else
        disp('bb3 do not exists in file')

    endif
      
    
    % Check if cstar variable exists
    if ~isempty(intersect('cstar',fieldnames(out)))
        % load cstar data into amt_optics
        amt_optics.cstar.cp = [amt_optics.cstar.cp; out.cstar.cp];
        amt_optics.cstar.cp_err = [amt_optics.cstar.cp_err; out.cstar.cp_err];
    else
        amt_optics.cstar.cp = [amt_optics.cstar.cp; nan(1440,1)];
        amt_optics.cstar.cp_err = [amt_optics.cstar.cp_err; nan(1440,1)];
    endif

    % Check if flow variable exists
    if ~isempty(intersect('flow',fieldnames(out)))
        amt_optics.flow = [amt_optics.flow; out.flow.mean];      % NOTE the time of the flow has been match to the biased optics data in step1_make_optics_better_only_flow.m
    else
        disp('flow do not exist in file: What to do?')
        keyboard
    endif

    % Check if ctd variable exists
    if ~isempty(intersect('ctd',fieldnames(out)))
        amt_optics.ctd.sst = [amt_optics.ctd.sst; out.ctd.mean(:,1)];     
        amt_optics.ctd.sal = [amt_optics.ctd.sal; out.ctd.mean(:,3)];    
    else
        disp('ctd do not exist in file: What to do?')
        keyboard
    endif


    % Add ship's underway variables
    % Check if uway variable exists
    if ~isempty(intersect('uway',fieldnames(out)))
        fields = fieldnames(out.uway);
        for ifield = 1:length(fields);
            % Initialize the variables
            if ifn == 1
                total_uway.(fields{ifield}) = [];
            endif
            total_uway.(fields{ifield}) = [total_uway.(fields{ifield}); out.uway.(fields{ifield})];

        endfor
    else
        disp('uway do not exists in file: What to do?')
        keyboard
    endif

endfor


%stop  % <-----------------    uncomment this stop before using remove_bbp_noise.m

% Get current year from inidate
t0 = y0(str2num(inidate(1:4)));

amt_optics.time = amt_optics.acs.time + t0     ;%     
amt_optics.acs.time = amt_optics.acs.time + t0     ;%   
amt_optics.ac9.time = amt_optics.ac9.time + t0     ;%   
                                      

% Interpolate ship's underway on acs time  % tjor: p
% Starting from 2 removes time from the uway field
for ifield = 1:length(fields)
 %   amt_optics.uway.(fields{ifield}) = interp1(total_uway.time, total_uway.(fields{ifield}), amt_optics.time);
   amt_optics.uway.(fields{ifield}) = total_uway.(fields{ifield});
endfor


% wv532 = find(amt_optics.acs.wv>=532,1);
% 
% 
% %plot(amt_optics.time-t0, amt_optics.acs.cp(:,wv532), "b;cp(532);", amt_optics.time-t0, 10*amt_optics.acs.ap(:,wv532), "r;10*ap(532);")
% %set(gca, 'ylim', [0 0.4])
% %print -dpng test_cp532.png


%plot(amt_optics.time-t0, amt_optics.bb3.bbp(:,2))
%set(gca, 'ylim', [0 0.008])
%print -dpng test_bbp532.png


%compute bbp-bb02;
amt_optics.bb3.bbp_corr = amt_optics.bb3.bbp - amt_optics.bb3.bb02;


# scale ac9 chl to acs chl
run("cmp_chlACs2AC9_ratio");


% keyboard
eval([lower(CRUISE) '= amt_optics;']) # create amtXX structure




if ~exist(DIR_STEP3,'dir')
    mkdir(DIR_STEP3)
endif
save('-v6', [DIR_STEP3 lower(CRUISE) '_optics.mat'], lower(CRUISE))

% amt_chl.time = amt_optics.time;
% amt_chl.chl = amt_optics.acs.chl;
% amt_chl.lat = amt_optics.undwy.lat;
% amt_chl.lon = amt_optics.undwy.lon;
% 
% 
% save -v6 amt22_chl.mat amt_chl
% 
% 
% 
% %
% %
%  out = [amt_optics.time-t0 amt_optics.undwy.lat amt_optics.undwy.lon amt_optics.acs.ap(:,wv532) amt_optics.acs.cp(:,wv532) amt_optics.bb3.bbp(:,2)];
%  save -ascii surface_optics_amt22.dat out



