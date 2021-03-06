function [ bad_trials, good_trials ] = MEG_reject_trial( input, eventfile, newEventfile, prestim, poststim, MAGthresh, GRADthresh, MOTthresh )
%This function will check for sensor artifacts and instantaneous head
%motion for each trial, and reject trials that head motion or peak-to-peak
%amplitude exceed a preset threshold. The cleaned event list will be write
%out to a new file.
%
%Usage: [ bad_triallist ] = MEG_reject_trial( input, eventfile, prestim, 
%       poststim, MAGthresh, GRADthresh, MOTthresh )
%
%   input      - fiff file to be loaded
%   eventfile  - event file in mne format that defines tials to be examined
%   newEventfile - new event file name
%   prestim    - prestimulus length in seconds  (For AS task, value = 2.5 )
%   poststim   - poststimulus length in seconds (For AS task, value = 1   )
%   MAGthresh  - threshold for magnetometers    (suggest value is 1e-11)
%                if peak to peak value in any magnetometer channel exceeds
%                this threshold, trial will be removed from trial list.
%   GRADthresh - threshold for gradiometers    (suggest value is 3e-10)
%                if peak to peak value in any gradiometer channel exceeds
%                this threshold, trial will be removed from trial list.
%   MOTthresh  - theshold for motion in mm      (initial value tested = 5)
%                displace determined using norm of difference in sesnsor
%                movement in head space
%
%
%   bad_trials = a list of bad trials
%   good_trials = a list of good trials
%
%   The cleaned events will be written to the same event file.
%
% update 4.23.2012 by Kai
% update 4.20.2012 by Will Foran the Great.

%update logs
% 4.18.2012, Add motion rejection. - WH
% 4.22.2012, Update comments. -KH
% 4.23.2012, change outputs to list of good trials and bad trials. - KH.

% convert to ms since MEG_load_sensor_trial defines time in ms.
% blame Kai for this inconsistency.
prestim =  prestim*1000;
poststim = poststim*1000;

% load output struct for each event/trial + displacement channel"
[output, events] = MEG_load_sensor_trial(input,eventfile, prestim, poststim, 1);
bad_triallist = [];

if isempty(output) 
  error('load sensor data empty, aborting', 'MEG_reject');
 return;
end

Thresholds = {  ...
 % cRegexp        cThres
 {'displacement', MOTthresh  }  % motion
 {'M*1',          MAGthresh  }  % magnetometers
 {'M*2',          GRADthresh }  % gradiometers, longitude or latitude
 {'M*3',          GRADthresh }  % gradiometers, longitude or latitude
};

%% check every channel matching each regexp (type) for each threshold type

for t = 1:length(Thresholds)
   cRegexp = Thresholds{t}{1};
   cThres  = Thresholds{t}{2};


   % get the name of every channel matching the regexp
   channel_list = ft_channelselection(cRegexp,output.label);

   if isempty(channel_list)
    fprintf('%s has no channel!\n',cRegexp);
    disp(output.label(end-2:end))
   end

   % go through each trial
   for i = 1:size(output.trial,2)
       % and each regexp match
       for n = 1:size(channel_list,1)

           % find the channel number matching this specific match of the regexp
           r = find(strcmp(output.label,channel_list(n)));

           % get the maximum difference
           maxi = max(output.trial{i}(r,:));

           % min is 0 for motion, this is likely not necessary
           % actual min elsewhere
           if strcmp(cRegexp,'displacement')
              mini = 0;
           else
              mini = min(output.trial{i}(r,:));
           end

           peaktopeak = maxi-mini;

           % drop if too high
           if peaktopeak > cThres 
               bad_triallist = [bad_triallist, i];
               fprintf('Dumping trial %3i: %s: max-min %g > thres %g \n',i,cRegexp, maxi,cThres);
               break % from all cRegexp matching channels in this trial -- move to next channel type in same trial
           end
       end % channels
   end % trial
end % thresholds

%% write out cleaned trial list
if any(bad_triallist)
    bad_triallist = unique(bad_triallist);
    fprintf('\n*\n*\n*\n')
    disp(['Bad trials found:' num2str(length(bad_triallist)) ]);
    fprintf('\n*\n*\n*\n')
    bad_triallist = bad_triallist +1; %the first line in event file is all zero
end

if isempty(bad_triallist)
    bad_trials=[];
else
    bad_trials = events(bad_triallist,:);
    events(bad_triallist,:)=[];
end

if isempty(events)
    warning('ATTENTION!!!!!! NO GOOD TRIALS LEFT!!!!!!!')
    return
end
good_trials = events(2:end,:); %the first line in event file is all zero

dlmwrite(newEventfile, events, 'delimiter', '\t',  'precision', 10);



end % of function

