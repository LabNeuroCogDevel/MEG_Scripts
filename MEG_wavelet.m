function [ Output ] = MEG_wavelet( Data, trials, FOIs, width)
% This function will perform time domain wavelet convultion on MEG source
% timecourses.  
%   
%   Usage: [ wav ] = MEG_PLV( Data, trials, FOIs,
%    width)
%
%   Input:
%       Data - In filedtrip format. Will lookf for Data.trial
%            ROI by time by number of trial
%       trials - vector of trials to be included. use [] to analyze all
%       trials.
%       FOIs - frequency of interst vector, i.e., 1:100
%       width - number of cycles to be used for wavelet, usually 7
%
%   Output:
%       Output.wav = wavelet coefficients. ROIs x trial x freq x time. 
%       Output.time = time vector
%       Output.FOIs = FOIs
%
%   Note this function utilizes parralel computing toolbox (parfor). Open
%   matlabpool if thats an option. REMOVED ON JULY 12. 2012!!!
%
%   Last update 7 11. 2012, by Kai

% reorganize Data.trial format in ROI by time by number of trial
% add option to include all trials.
% 7.12.2012 removed parfor in loop

Fs = Data.fsample;
tv = Data.time{1};
Output.label = Data.label;
Output.trialinfo = Data.trialinfo;
Output.Subj = Data.Subj;

if isempty(trials)
    Data = cat(3,Data.trial{1:end});
else
    Data = cat(3,Data.trial{trials});
end

wav = zeros(size(Data,1), size(Data,3), length(FOIs), size(Data,2));

for nc = 1: size(Data,1)
    for nt = 1:size(Data,3) 
        TrialData = squeeze(Data(nc,:,nt));
        %remove line noise
        %TrialData = cca_multitaper(TrialData,Fs,60,50);
    
        for fn = 1:length(FOIs)
            f = FOIs(fn);
            wav(nc,nt,fn,:) = phasevec(f, TrialData, Fs, width);
        end
    
    end
end

Output.wav = wav;
Output.time = tv;
Output.FOIs = FOIs;
end


function y = phasevec(f,s,Fs,width)
% function y = phasevec(f,s,Fs,width)
%
% Return a the phase as a function of time for frequency f. 
% The phase is calculated using Morlet's wavelets. 
% Kai note: not phase, wavelet coef..??
%
% Fs: sampling frequency
% width : width of Morlet wavelet (>= 5 suggested).
%
% Ref: Tallon-Baudry et al., J. Neurosci. 15, 722-734 (1997)


dt = 1/Fs;
sf = f/width;
st = 1/(2*pi*sf);

t=-3.5*st:dt:3.5*st;
m = morlet(f,t,width);

y = conv(s,m);

%l = abs(y) == 0; 
%y(l) = 1;

%normalize power to 1
%y = y./abs(y);
%y(l) = 0;
   
% remove edges
y = y(ceil(length(m)/2):length(y)-floor(length(m)/2));
end



function y = morlet(f,t,width)
% function y = morlet(f,t,width)
% 
% Morlet's wavelet for frequency f and time t. 
% The wavelet will be normalized so the total energy is 1.
% width defines the ``width'' of the wavelet. 
% A value >= 5 is suggested.
%
% Ref: Tallon-Baudry et al., J. Neurosci. 15, 722-734 (1997)
%
%
% Ole Jensen, August 1998 

sf = f/width;
st = 1/(2*pi*sf);
A = 1/sqrt(st*sqrt(pi));
y = A*exp(-t.^2/(2*st^2)).*exp(i*2*pi*f.*t);
end

