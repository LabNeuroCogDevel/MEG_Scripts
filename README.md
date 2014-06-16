MEG_Scripts
===========

First make sure you read through our wiki pages for an overview
\n
http://arnold.wpic.upmc.edu/dokuwiki/doku.php?id=howto:meg:process_meg_data
\n
http://arnold.wpic.upmc.edu/dokuwiki/doku.php?id=howto:meg:meg

Scripts for analyzing MEG data

You will need the following install.

MNE http://martinos.org/mne/stable/index.html

Fieldtrip http://fieldtrip.fcdonders.nl/

Statistical Resampling toolkit http://www.mathworks.com/matlabcentral/fileexchange/27960-resampling-statistical-toolkit

Export_fig http://www.mathworks.com/matlabcentral/fileexchange/23629-export-fig

Standard Error Bars http://www.mathworks.com/matlabcentral/fileexchange/26311-shadederrorbar

In here are a collection of matlab functions that will help you preprocess the MEG data, including ICA noise detection, motion detection, and trial rejection.
In addition, there are a few other matlab functions that will do wavelect, oscillatory power, and PLV analyses.

Other example scripts including scripts for running maxfilter (on wallace), calling MNE binaries to calculate head model, perform the overall MNE pipeline, and example setup files for averaging and calculating noise covariance. 
