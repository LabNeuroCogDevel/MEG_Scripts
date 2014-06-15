function MEG_vertices_label( stc_file, label_file, label_out, tmin, tmax, percentage )
%This function will find the most activated vertices within an anatomical
%label created by freesurfer. Theses vertices will be written to a new
%label file.
%
% Usage: MEG_vertices_label( stc_file, label_file, label_out, tmin, tmax, percentage )
%   stc_file - stc file, can be dSPM.
%   label_file - the anatomical label.
%   label_out - file name of the new label.
%   tmin - the onset time of the trial activity to be considered
%   tmax - the ned time of trial activity. Activity will be summed between
%   tmin and tmax. Then ranked
%   percentage - the percentage of vertices to be preserved.
%
% Last update July 10. 2012. Kai

stc = mne_read_stc_file(stc_file);
label = mne_read_label_file(label_file);
[vertices, ia, ~] = intersect(double(stc.vertices),double(label.vertices));

%find start and end
tstart = abs(stc.tmin-tmin)/stc.tstep;
tend = abs(stc.tmin-tmax)/stc.tstep;

%sort the vertices with highest amount of activity
[~, I]=sort(sum(stc.data(ia,tstart:tend)'));

[selected_vertices, is, ~] =intersect(double(label.vertices),double(vertices(I(end-round(percentage*length(I)):end))));
%the following will only select 1 vertice
%[selected_vertices, is, ~] =intersect(double(label.vertices),double(vertices(I(end-1:end))));
new_label.comment = label.comment;
new_label.vertices = label.vertices(is);
new_label.pos = label.pos(is,:);
new_label.values = label.values(:,is);
mne_write_label_file(label_out,new_label);


end

