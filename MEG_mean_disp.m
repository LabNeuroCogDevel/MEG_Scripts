function [meanD, varargout] =  MEG_mean_disp(head,fif)
% This function will calculate the device to head cooridnate transformation
% for each timepoint, convert the sensor coordinates into head space, and
% calculate the average displacement of all sensors for each timepoint
% (Wehner et al 2008 NeuroImage). This is effectively equivalent of
% caluclating the instantaneous head motion. If cHPI channels do not exist
% (head motion not recorded), then output will be set to zero.
%
%   Usage: [meanD, varargout] =  MEG_mean_disp(head,fif)
%   head and fiff are header and data strucutures from read_fiff.m
%   When called with one output argument, just return difference of each
%   timepoint to the next as #####x1 vector in mm When called with two
%   return movie of motion (displayed as it's made)
%
% Author: Will Foran the Great, 4.20.2012

%Update log
% Intially written by Will

 %% check arguments
 if(length(nargout)>2)
  error('MEG_mean_disp','too many outputs expected');
  return
 end

 %% Find CHPI channels
 CHPIs    = {'CHPI001' 'CHPI002' 'CHPI003' 'CHPI004' 'CHPI005' 'CHPI006'};
 CHPIidxs = zeros(1,length(CHPIs));

 for c = 1:length(CHPIs); 
  % find index matching each CHPI channel name
  ci = find( strcmp(head.info.ch_names, CHPIs{c}) );
  % set channel number to zero if no cHPI exist.
  if isempty(ci)
    ci = 0;
  end
  CHPIidxs(c) = ci;
 end

 % if we didnt find any CHPI channels (idxs is still all 0)
 % send back motion is all zeros (no motion checking)
 if all(CHPIidxs == 0)
   fprintf('****** No CHPI channels = no motion check *******\n'); 
   meanD = zeros(1,length(fif));
   return
 end

 % ensure head.info.chs.coil_trans represents postion: graph it
 %  count=0; for i=1:length(h.info.chs); if(length(h.info.chs(i).coil_trans)>3);count=count+1;  a(count,:)=h.info.chs(i).coil_trans(1:3,4);end; end; plot3(a(:,1),a(:,2),a(:,3),'k.')

 %% get sensor positions
 % if censor has info (>3 entries)
 % add to censor cords
 count=0; 
 for i=1:length(head.info.chs)
   trans=head.info.chs(i).coil_trans;
   if(length(trans)>3)
     count=count+1;  
     sense_cords(:,count)=trans(1:3,4)';
   end
 end

 % sense_cords like [ x1 x2 x3 x4;
 %                    y1 y2 y3 y4;
 %                    z1 z2 z3 z4 ] ;
 %


 % disp([length(a) length(unique(a,'rows'))]) % =   306   102
 % remove duplicate positions  (3 sesors at each position)
 sense_cords = unique(sense_cords','rows')';

 num_sense   = length(sense_cords(1,:));

 % initialze per step displacments
 coor_cur    = zeros(3,num_sense);
 coor_prev   = coor_cur;
 %init displacement: will be (t1-t0) for all fif measurements
 meanD = zeros(length(fif),1);

 % are we making a movie?
 if(nargout>1)
    motionfigure=figure;
    % make the plot window 800wx700h
    %set(motionfigure,'Position',[ 0 0 800 700]);
    varargout{1}=getframe(gcf); % first frame empty
    %varargout{1}=getframe; % first frame empty
 end
 picidx=0
 if(nargout>2)
   picidx=1;
 end

 %fig=figure('Visible', 'off');
 %set(fig,'Visible','off')
 
 %% find the start of recording
 % and give 0s while not started
 recordIdx=1;
 while( all( fif(CHPIidxs,recordIdx) == 0) )
      meanD(recordIdx) = 0;   
      recordIdx=recordIdx+1;
 end

 numpics=1
 %% calc mean displacement (Wehner, 2008)
 for i = recordIdx:length(fif)
    if i==1
        meanD(i) = 0;
        continue;
    end
    % if no motion change 
    % set displacement to zero and move to next
    if( all(fif(CHPIidxs,i) == fif(CHPIidxs,i-1)) )
        meanD(i) = 0;
        continue;
    end
    
    % build current head space coordinates of all unique sensor positions
    for j = 1:num_sense
       % cal R using first 3 (+ 0 to be solved for) CHPIs
       rots  = R( fif(CHPIidxs(1),i) ,fif(CHPIidxs(2),i), fif(CHPIidxs(3),i));

       % use last 3 as trans
       trans = fif(CHPIidxs(4:6),i);

       % coordinates at current time
       coor_cur(:,j) =  rots*sense_cords(:,j) + trans;
    end
    
    %Visualize
    if(nargout>1)
       plot3(coor_cur(1,:),coor_cur(2,:),coor_cur(3,:),'k.');
       view(-140,20);
       numpics=numpics+1;
       %% subplot's are a cooler graph but produce broken avi
       %subplot(2,3,1);plot3(coor_cur(1,:),coor_cur(2,:),coor_cur(3,:),'k.'); view(-90,90);       
       %subplot(2,3,[2,3]);plot3(coor_cur(1,:),coor_cur(2,:),coor_cur(3,:),'k.'); view(-90,0);
       %subplot(2,3,[4,5,6]);plot3(coor_cur(1,:),coor_cur(2,:),coor_cur(3,:),'k.'); view(-140,20);
       drawnow;
       if(picidx>0)
          [varargout{2}{picidx},~]=getframe;
          picidx=picidx+1;
       end
       varargout{1}(end+1)=getframe(gcf); 
       % http://www.mathworks.com/matlabcentral/newsreader/view_thread/293880
       % but includes most of window (axes in addition to what's plotted)

       %varargout{1}(end+1)=getframe;
    end
    
    
   % finish early 
   %numpics
   %if(numpics> 20) fprintf('done'); break; end
    
   % when there is something to compare
   if i>recordIdx+1
      for j = 1:num_sense
        meanD(i) = meanD(i) + norm( coor_cur(:,j) - coor_prev(:,j) );
      end
   end

   % push current to prev
   coor_prev = coor_cur;
 end

 % div all sums by number of sensors
 meanD = meanD./num_sense .* 1000;
 
 % save movie for visual inspection
 %save('subjMotionVideo.mat', 'motion_anim');

end

%% rotation matrix 
% Appendex D.2 (pg 77) of MaxFilter 2.1 User's Manual
function r=R(q1, q2, q3)
 q0 = sqrt( 1 - (q1^2 + q2^2 + q3^2) ); %sum q0..3 = 1

 %rot matrix
 r  = [  (q0^2 + q1^2 - q2^2 -q3^2),       2*(q1*q2 - q0*q3)      ,        2*(q1*q3 + q0*q2)        ; 
             2*(q1*q2 + q0*q3)     ,    (q0^2 + q2^2 - q1^2 -q3^2),        2*(q2*q3 + q0*q1)        ; 
             2*(q1*q3 - q0*q2)     ,       2*(q2*q3 + q0*q1)      ,   (q0^2 + q3^2 - q1^2 -q2^2)  ] ;

end
