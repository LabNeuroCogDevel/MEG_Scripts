function [ output, events ] = MEG_load_sensor_trial( inputfile, eventfile, preStim, postStim, dispFlag )
%This function will load trial by trial sensor data, then read trial timing
%from the event file, chop data into trial epochs, and compile trials into
%a fieldtrip data structure.
%   
%   usage: [ output, events ] = MEG_load_sensor_trial( inputfile,
%   eventfile, pretStim, postStim )
%
%   Input:
%       inputfile - fiff file
%       eventfile - event file listing trials of interest, in mne format
%       postStim - trial length, specify in ms 
%       preStim - length of presitm baseline, in ms
%       dispFlag - set to 1 if want to calcuate displacement.
%
%   Output:
%       output.label     - cell-array containing strings, Nchan X 1
%       output.fsample   - sampling frequency in Hz 
%       output.trial     - cell-array containing a data matrix for each 
%                          trial (1 X Ntrial), each data matrix is 
%                          Nchan X Nsamples
%       output.time      - cell-array containing a time axis for each trial
%                          (1 X Ntrial), each time axis is a 1 X Nsamples 
%                          vector. In Seconds.
%       output.trialinfo - trigger code.
%       events           - events in mne event file format
%
%   update 9.17.2012, by Kai
%   update 4.17.2012 by WF

%update log
%4.17.2012 add motion displacement channel, by WF.
%4.22.2012 use MEG_mean_disp.
%4.25.2012 made changes so it will work with fiff files with no initial
%skip and event files with initial skip (the MGH dataset). -KH

%load fiff data
[hdr,data] = read_fiff(inputfile);
output = [];

%remove trigger line
data(end,:) = [];

%load event files
trigs = load(eventfile);

% if there is an offset and trigger file has no offset
% e.g. data that hasn't been through ICA
if hdr.first_samp > 0 && trigs(1,1) == 0   
 trigs(:,1) = trigs(:,1) + double(hdr.first_samp);
 trigs(:,2) = trigs(:,2).*4/1000;
end

% if there is no offset and trigger file has an offset
% e.g. data that hasn't been through ICA
if hdr.first_samp == 0 && trigs(1,1) > 0  
 trigs(:,1) = trigs(:,1) - trigs(1,1);
 trigs(:,2) = trigs(:,2) - trigs(1,2);
end

% events never used, trigs never modified?
events = trigs;

%check initial offset and sampling frequency
if trigs(1,1)~=hdr.first_samp
   fprintf('\n\t ******* ATTENTION!! initial offset betwen event and fiff file does not match. Wrong event file? Exiting ******* \n\n')
   return 
end

SamplingRate = hdr.info.sfreq;
%  if hdr.info.sfreq~=SamplingRate
%     fprintf('\n\t ******* ATTENTION!! Samplingrate mismatch. Wrong event file? Exiting ******* \n\n')
%     return
%  end

%label names
output.label = hdr.info.ch_names(1:end-1)';

%sampling frequency
output.fsample = hdr.info.sfreq;
epochLength = preStim+postStim;

% add displacement channel
if dispFlag ==1
    output.label{end+1} = 'displacement';
    data(end+1,:)       = MEG_mean_disp(hdr,data)';
end

output.trial = [];
for n = 2:1:size(trigs,1)

    trialStart = round(trigs(n,1)-trigs(1,1) - (preStim/(1000/SamplingRate)));
    trialEnd = trialStart + round(epochLength/(1000/SamplingRate));
    
    if trialStart <0
        fprintf('\n\t ******* ATTENTION!! event onset <0?? Wrong event file? Exiting ******* \n\n')
        return
    end

    
    %chop trial epochs
    Epoch = data(:,trialStart:trialEnd);
    
    output.trial{n-1} = Epoch;
    output.trialinfo(n-1,1) = trigs(n,4);
    output.time{n-1} = -preStim/1000:1/SamplingRate:postStim/1000; % in seconds
end
%put fiff header into output structure
output.hdr = hdr;

fclose('all');
end

