# This is an example script of the MNE complete, calculating noise covariance, 
# calculate foward and inverse solution, create trial averaged STC files,
# and project raw data into the source space for list of ROIs (labels).
# 
# For creating head model, see the create_head_model.sh example script.
# Last update 6.15.2014. Kai

#!/bin/bash
cwd=$(pwd)

# the input is subject number
for s in $1;  do

	#setup source space
	#mne_setup_source_space --subject $1 --spacing 7 --overwrite 
	#mne_setup_forward_model --subject $1 --surf --ico 4 --homog
	
	cd ${cwd}/${s}/MEG/
	
	# do filtering
	for n in 1 2 3 4 5 6 7 8; do
		mne_process_raw --raw ${cwd}/${s}/MEG/${s}_anti_run${n}_dn_ds_sss_raw.fif \
		--highpass 1 --lowpass 80 \
		--save ${cwd}/${s}/MEG/${s}_anti_run${n}_dn_ds_f_sss_raw.fif --projon
	done
	
	# note including all trials for covariance matrix. Need enough tirals
	#calculate noise covariance (or use empty room?)
	mne_process_raw \
	--raw ${cwd}/${s}/MEG/${s}_anti_run1_dn_ds_f_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run2_dn_ds_f_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run3_dn_ds_f_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run4_dn_ds_f_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run5_dn_ds_f_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run6_dn_ds_f_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run7_dn_ds_f_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run8_dn_ds_f_sss_raw.fif \
	--events ${cwd}/${s}/MEG/${s}_all-run1-All-Clean.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run2-All-Clean.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run3-All-Clean.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run4-All-Clean.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run5-All-Clean.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run6-All-Clean.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run7-All-Clean.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run8-All-Clean.eve \
	--projon \
	--digtrig STI101 \
	--cov ~/bin/MEGScripts/MEG_Scripts/anti.cov \
	--gcov ${s}_anti_cov.fif
	
	
	#do offline averaging for each condition
	for cond in anti vgs all; do
	
	# all trials (both correct and incorrect)
		mne_process_raw \
		--raw ${cwd}/${s}/MEG/${s}_anti_run1_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run2_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run3_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run4_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run5_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run6_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run7_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run8_dn_ds_f_sss_raw.fif \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run1-All-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run2-All-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run3-All-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run4-All-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run5-All-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run6-All-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run7-All-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run8-All-Clean.eve \
		--projon \
		--lowpass 40 \
		--ave ~/bin/MEGScripts/MEG_Scripts/${cond}-All.ave \
		--gave ${s}_${cond}_all_ave.fif 
	
		#only correct trials
		mne_process_raw \
		--raw ${cwd}/${s}/MEG/${s}_anti_run1_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run2_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run3_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run4_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run5_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run6_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run7_dn_ds_f_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run8_dn_ds_f_sss_raw.fif \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run1-Correct-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run2-Correct-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run3-Correct-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run4-Correct-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run5-Correct-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run6-Correct-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run7-Correct-Clean.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run8-Correct-Clean.eve \
		--projon \
		--lowpass 40 \
		--ave ~/bin/MEGScripts/MEG_Scripts/${cond}-Correct.ave \
		--gave ${s}_${cond}_Correct_ave.fif 
	
	done
	
	
	#do forward solution
	mne_do_forward_solution --src ${s}-7-src.fif \
	--megonly --mindist 5 --overwrite \
	--meas ${s}_all_all_ave.fif \
	--fwd ${s}_anti_vgs_all_fwd.fif \
	--subject ${s}
		
	# do inverse solution
	mne_do_inverse_operator --fwd ${s}_anti_vgs_all_fwd.fif \
	--depth --loose 0.2 --meg --senscov ${s}_anti_cov.fif \
	--subject ${s}
	
	#morph maps
	mne_make_morph_maps --from ${s} --to fsaverage --redo
	
	
	# Create anatomical labels.
	# Note here we are using anatomical parcellation as ROIs.
	# Other matlab scripts have been created to futher process this anatomical ROIs to
	# create functional labels.

	cd $SUBJECTS_DIR/${s}/label
	mne_annot2labels --subject ${s} --parc aparc.a2009s
	mkdir ${cwd}/${s}/MEG/labels/
	cp S_intrapariet_and_P_trans-rh.label ${cwd}/${s}/MEG/labels/IPS-rh.label
	cp S_intrapariet_and_P_trans-lh.label ${cwd}/${s}/MEG/labels/IPS-lh.label
	cp S_front_middle-rh.label ${cwd}/${s}/MEG/labels/MFG-rh.label
	cp S_front_middle-lh.label ${cwd}/${s}/MEG/labels/MFG-lh.label
	cp S_precentral-inf-part-rh.label ${cwd}/${s}/MEG/labels/iFEF-rh.label
	cp S_precentral-inf-part-lh.label ${cwd}/${s}/MEG/labels/iFEF-lh.label
	cp S_precentral-sup-part-rh.label ${cwd}/${s}/MEG/labels/sFEF-rh.label
	cp S_precentral-sup-part-lh.label ${cwd}/${s}/MEG/labels/sFEF-lh.label
	cp S_front_inf-rh.label ${cwd}/${s}/MEG/labels/IFG-rh.label
	cp S_front_inf-lh.label ${cwd}/${s}/MEG/labels/IFG-lh.label
	cp G_and_S_cingul-Ant-rh.label ${cwd}/${s}/MEG/labels/ACC-rh.label
	cp G_and_S_cingul-Ant-lh.label ${cwd}/${s}/MEG/labels/ACC-lh.label
	cp S_occipital_ant-rh.label ${cwd}/${s}/MEG/labels/OCC-rh.label
	cp S_occipital_ant-lh.label ${cwd}/${s}/MEG/labels/OCC-lh.label
	cp S_calcarine-rh.label ${cwd}/${s}/MEG/labels/V1-rh.label
	cp S_calcarine-lh.label ${cwd}/${s}/MEG/labels/V1-lh.label
	
	
	cd ${cwd}/${s}/MEG/
	#create STC files of current estimates in averaged surface
	#for cond in anti_Correct anti_all vgs_Correct vgs_all all_Correct all_all; do
	for cond in anti_Correct anti_all vgs_Correct vgs_all all_Correct all_all; do
		mne_make_movie \
		--subject ${s} \
		--inv ${s}_anti_vgs_all_fwd.fif-meg-inv.fif \
		--meas ${s}_${cond}_ave.fif \
		--morph fsaverage \
		--smooth 5 \
		--integ 4 \
		--tmin -1992 \
		--tmax 500 \
		--bmin -1992\
		--bmax -1700 \
		--stc ${s}_${cond}_fsaverage
		
		mne_make_movie \
		--subject ${s} \
		--inv ${s}_anti_vgs_all_fwd.fif-meg-inv.fif \
		--meas  ${s}_${cond}_ave.fif \
		--morph fsaverage \
		--smooth 5 \
		--integ 4 \
		--tmin -1992 \
		--tmax 500 \
		--bmin -1992 \
		--bmax -1700 \
		--spm \
		--stc ${s}_${cond}_spm_fsaverage
	done
	
	#Create STC files in native space
	for cond in anti_Correct anti_all vgs_Correct vgs_all all_Correct all_all; do
		mne_make_movie \
		--subject ${s} \
		--inv ${s}_anti_vgs_all_fwd.fif-meg-inv.fif \
		--meas ${s}_${cond}_ave.fif \
		--integ 4 \
		--tmin -1992 \
		--tmax 500 \
		--bmin -1992 \
		--bmax -1700 \
		--stc ${s}_${cond}_native
		
		mne_make_movie \
		--subject ${s} \
		--inv ${s}_anti_vgs_all_fwd.fif-meg-inv.fif \
		--meas  ${s}_${cond}_ave.fif \
		--integ 4 \
		--tmin -1992 \
		--tmax 500 \
		--bmin -1992 \
		--bmax -1700 \
		--spm \
		--stc ${s}_${cond}_spm_native
	done
	
	
	
	#Do raw to source projection
	for rn in 1 2 3 4 5 6 7 8; do
		mne_compute_raw_inverse --in ${cwd}/${s}/MEG/${s}_anti_run${rn}_dn_ds_sss_raw.fif \
		--inv ${cwd}/${s}/MEG/${s}_anti_vgs_all_fwd.fif-meg-inv.fif \
		--picknormalcomp \
		--align_z \
		--labeldir ${cwd}/${s}/MEG/Labels \
		--orignames \
		--digtrig STI101 \
		--out ${cwd}/Source_Estimates/${s}_anti_run${rn}_label_source > \
		${cwd}/Source_Estimates/${s}_anti_run${rn}_label_source.log 2>&1 &
	done
done
