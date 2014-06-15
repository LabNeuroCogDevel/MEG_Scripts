function [ pow ] = MEG_power( tfr, baseline, trial, trialsN )
%Function to calculate trial by trial power from MEG_wavelet outputs.
%This function express differences in power estimates between task period 
%and baseline in percent change.
%s
% Usage: [ pow ] = MEG_power( tfr, baseline, trial, trialsN )
%               tfr - output from MEG_wavelet. wavelet coefficients.
%               baseline - start and end of basline period, in seconds.
%               For example [-2.5, -2.0]
%               trial - start and end of task period, in seconds. For
%               example [-1.5 1]
%               trialsN - vector of trials to be included into the
%               analysis. For example to select correct trials, you can use
%               find(WAV.trialinfo==1). If want to include all
%               trials just give an empty [] input.
%
%               Output
%               pow - output structure. 
%
%
%Last update 7.12.2012 by Kai

% 7.12.2012 - use outputs from MEG_wavelet instead of ft_freqanalysis

% check input argument
if isempty(tfr.wav)
    error('no wavelet output structure!')
end

%find baseline start and end indeces 
bstart = find(min(abs(tfr.time-(baseline(1))))==abs(tfr.time-(baseline(1))));
bend = find(min(abs(tfr.time-(baseline(2))))==abs(tfr.time-(baseline(2))));

%find trial start and end indeces 
tstart = find(min(abs(tfr.time-(trial(1))))==abs(tfr.time-(trial(1))));
tend = find(min(abs(tfr.time-(trial(2))))==abs(tfr.time-(trial(2))));

% convert wavelet or fourier coefficeints into power
tfr.powspctrm = abs(tfr.wav).^2;
% rearrange order
tfr.powspctrm = permute(tfr.powspctrm,[2 1 3 4]);

%compute ouutput
if isempty(trialsN)
    pow.powspctrm = squeeze(nanmean(tfr.powspctrm(:,:,:,:),1));
else
    pow.powspctrm = squeeze(nanmean(tfr.powspctrm(trialsN,:,:,:),1));
end

% change ft field code to cheat ft
%tfr.dold = tfr.dimord;
%tfr.dimord = 'rpt_chan_freq_time';

% computate standard error using jackknife procedure
%cfg = [];
%cfg.jackknife = 'yes';
%if isempty(trialsN)
%    cfg.trials = 'all';
%else
%    cfg.trials = trialsN;
%end

%cfg.keeptrials = 'yes';
%pow = ft_freqdescriptives(cfg,tfr);

baseline_mean = squeeze(nanmean(pow.powspctrm(:,:,bstart:bend),3));
%baseline_se = nanmean(tfr.powspctrmsem(:,:,bstart:bend),3);

%do t-test
b_mean = repmat(baseline_mean, [1 1 tend-tstart+1]);
%size(b_mean)
%b_se = repmat(baseline_se, [1 1 tend-tstart+1]);
%if isempty(trialsN)
%    dof = size(tfr.fourierspctrm,1)-2;
%else
%    dof = length(pow.cfg.trials)-2;
%end

% t = (mean1-mean2)/sqrt(se1.^2 + se2.^2)
%t = (pow.powspctrm(:,:,tstart:tend)-b_mean)./sqrt(pow.powspctrmsem(:,:,tstart:tend).^2+b_se.^2);
%size(pow.powspctrm)
pow.pow_percent_change = ((pow.powspctrm(:,:,tstart:tend)./b_mean)-1).*100;
pow.pow_db = 10.*log10(pow.powspctrm(:,:,tstart:tend)./b_mean);
dbp = 10.*log10(pow.powspctrm(:,:,:));
baseline_mean = squeeze(nanmean(dbp(:,:,bstart:bend),3));
b_mean = repmat(baseline_mean, [1 1 tend-tstart+1]);
pow.pow_db_percent_change = ((dbp(:,:,tstart:tend)./b_mean)-1).*100;
% convert to z 
%pow.powzscore = norminv(cdf('t',t,dof),0,1);
%pow.powtscore = t;

% save single trial power estimates
if isempty(trialsN)
    pow.singletrial_powspctrm = (tfr.powspctrm(:,:,:,tstart:tend));
    %baseline_mean = nanmean((tfr.powspctrm(:,:,:,bstart:bend)),4);
    %baseline_mean = nanmean(baseline_mean);
    %b_mean=repmat(baseline_mean,[1,1,1,size(pow.singletrial_powspctrm,4)]);
   % b_mean = repmat(baseline_mean, [size(tfr.powspctrm,1),size(tfr.powspctrm,2),size(tfr.powspctrm,3), tend-tstart+1]);
    %pow.singletrial_powspctrm = ((pow.singletrial_powspctrm./b_mean)-1).*100;
else
    pow.singletrial_powspctrm = (tfr.powspctrm(trialsN,:,:,tstart:tend));
    %baseline_mean = nanmean((tfr.powspctrm(trialsN,:,:,bstart:bend)),4);
    %baseline_mean = nanmean(baseline_mean);
    %b_mean=repmat(baseline_mean,[1,1,1,size(pow.singletrial_powspctrm,4)]);
 %   b_mean=permute(repmat(baseline_mean,[1,1,tend-tstart+1,length(trialsN)]),[4 1 2 3]);
 %   b_mean = repmat(baseline_mean, [length(trialsN),size(tfr.powspctrm,2),size(tfr.powspctrm,3), tend-tstart+1]);
    %pow.singletrial_powspctrm = ((pow.singletrial_powspctrm./b_mean)-1).*100;
end

%save time axis
pow.pow_time = tfr.time(tstart:tend);
pow.time = tfr.time;

%save outputs
pow.label = tfr.label;
pow.trialinfo = tfr.trialinfo;
pow.Subj = tfr.Subj;
pow.FOIs = tfr.FOIs;

end

