% EEGLAB history file generated on the 25-Apr-2019
% ------------------------------------------------

disk_prefix = 'K';

data_root_folder = [disk_prefix, ':\EEG_Experiments\Preprocessed_for_eeglab\'];
electrode_location_file = [disk_prefix, ':\\eeglab14_1_2b\\sample_locs\\gGAMMAcap32ch_10-20.locs'];
output_folder = [disk_prefix, ':\EEG_Experiments\EEGLAB_eSports_datasets\'];
ERPLAB_scripts_folder = [disk_prefix, ':\eeglab14_1_2b\ERPLAB_Scripts_for_eSports\'];
combined_results_output_folder = [disk_prefix, ':\EEG_Experiments\EEGLAB_Combined_res_for_pro_npro\'];

% exp_id = '1_1_2'; target_type = [1]; target_bin = 1; epoch_boundary = [-200.0,  450.0];
% ar_rm_from_ch = 1; mwpp_thld = 80; tstep_thld = 50; stim_duration_ms = 250;%ms

% exp_id = '1_2_2'; target_type = [1]; target_bin = 1; epoch_boundary = [-200.0,  700.0]; ar_rm_from_ch = 8; mwpp_thld = 80; tstep_thld = 50; stim_duration_ms = 250;%ms 

exp_id = '2_2_2'; target_type = [8:14]; target_bin = 1; epoch_boundary = [-200.0,  700.0];
ar_rm_from_ch = 8; mwpp_thld = 80; tstep_thld = 50; stim_duration_ms = 400;%ms

% exp_id = '2_2_4'; target_type = [8:14]; target_bin = 1; epoch_boundary = [-200.0,  700.0];
% ar_rm_from_ch = 8; mwpp_thld = 80; tstep_thld = 50; stim_duration_ms = 400;%ms

% exp_id = '2_2_5'; target_type = [1:5]; target_bin = 1; epoch_boundary = [-200.0,  700.0];
% ar_rm_from_ch = 8; mwpp_thld = 80; tstep_thld = 50; stim_duration_ms = 400;%ms

% exp_id = '3_2_3'; target_type = [1]; target_bin = 1; epoch_boundary = [-200.0,  700.0];
% ar_rm_from_ch = 8; mwpp_thld = 80; tstep_thld = 50; stim_duration_ms = 900;%ms

import_data_flag = 1;
plot_initial_data = 0;
reject_bad_channels_flag = 1;
run_ICA_flag = 0;
event_list_and_epochs_flag = 1;
artifact_removal_flag = 1;
plot_final_data = 0;
save_epoched_as_cont_flag = 0;
comp_neural_corr_flag = 1;
plot_ERP_flag = 0;
plot_animation_flag = 0;
plot_ERP_Im_flag = 0;

sampling_rate = 250; % Hz
data_folders = dir(data_root_folder); data_folders = data_folders(3:end);
num_subjects = 0;
for df_idx=1:size(data_folders,1)
    num_subjects = num_subjects + data_folders(df_idx).isdir;
end
num_channels = 32;
neural_corr = cell(num_subjects, 4);

for sub_idx = 1:num_subjects
    folder_struct = data_folders(sub_idx);
    folder_name = folder_struct.name;
    sub_folder_path = [folder_struct.folder, '\', folder_name, '\'];
    sub_ID = folder_name(4:7);
    
    if folder_struct.isdir
        exp_files = dir(sub_folder_path); exp_files = exp_files(3:end);
        
        for exp_file_idx = 1:size(exp_files, 1)
            exp_file_struct = exp_files(exp_file_idx);
            exp_file_name = exp_file_struct.name;
            exp_file_path = [exp_file_struct.folder, '\', exp_file_name];
            cur_exp_id = exp_file_name(9:13);
            
            if strcmp(cur_exp_id, exp_id)
                %% Import data
                set_name = ['sub', sub_ID, '_', cur_exp_id];
                output_folder_cur = [output_folder, 'sub', sub_ID, '\', cur_exp_id, '\'];
                if ~exist(output_folder_cur, 'dir')
                    mkdir(output_folder_cur)
                end
                output_suffix = 'init';
                if import_data_flag
                    [EEG] = Import_data(exp_file_path, set_name, sub_ID, output_suffix, output_folder_cur, sampling_rate, electrode_location_file);
                    EEG = eeg_checkset( EEG );
                else
                    EEG = pop_loadset('filename',[set_name,'_',output_suffix,'.set'],'filepath',output_folder_cur);
                end
                %% Plot initial data
                if plot_initial_data
                    pop_eegplot( EEG, 1, 1, 1);
                end
                %% Reject bad channels
                output_suffix = 'rejch';
                if reject_bad_channels_flag
                    [EEG] = Remove_bad_channels(EEG, set_name, output_suffix, output_folder_cur);
                    EEG = eeg_checkset( EEG );
                else
                    EEG = pop_loadset('filename',[set_name,'_',output_suffix,'.set'],'filepath',output_folder_cur);
                end
                %% Run_ICA
                output_suffix = 'after_ICA';
                if run_ICA_flag
                    EEG = pop_runica(EEG, 'extended',1,'interupt','on');
                    %% Plot ICA components
                    pop_eegplot( EEG, 0, 1, 1);
                    EEG = pop_subcomp( EEG);
                    EEG = eeg_checkset( EEG );
                    output_set_name = [set_name, '_', output_suffix, '.set'];
                    EEG = pop_saveset( EEG, 'filename',output_set_name,'filepath',output_folder_cur);
                else
                    %EEG = pop_loadset('filename',[set_name,'_',output_suffix,'.set'],'filepath',output_folder_cur);
                end
                %% Load Eventlist and split data into epochs
                output_suffix = 'be';
                elist_name = ['elist_', cur_exp_id, '_short.txt'];
                elist_path = [ERPLAB_scripts_folder, 'Exp_', cur_exp_id, '\', elist_name];
                if event_list_and_epochs_flag
                    [EEG] = Event_list_and_epochs(EEG, epoch_boundary, elist_path, set_name, output_suffix, output_folder_cur);
                    EEG = eeg_checkset( EEG );
                else
                    EEG = pop_loadset('filename',[set_name,'_',output_suffix,'.set'],'filepath',output_folder_cur);
                end
                %% Remove trials with artifacts
                output_suffix = 'ar';
                if artifact_removal_flag
                    [EEG] = Artifact_removal(EEG, epoch_boundary, ar_rm_from_ch, mwpp_thld, tstep_thld, set_name, output_suffix, output_folder_cur);
                    EEG = eeg_checkset( EEG );
                else
                    EEG = pop_loadset('filename',[set_name,'_',output_suffix,'.set'],'filepath',output_folder_cur);
                end
                %% Plot final data
                if plot_final_data
                    pop_eegplot( EEG, 1, 1, 1);
                end
                %% Save epoched EEG as continious data
                if save_epoched_as_cont_flag
                    [EEG_output] = Append_EEG_epochs(EEG, stim_duration_ms, sampling_rate, target_type, set_name, output_folder_cur);
                end
                %% Compute neural correlates
                if comp_neural_corr_flag
                    [mental_conc, visuospatial_att, emotion_state] = Neural_correlates(EEG, epoch_boundary);
                    neural_corr{sub_idx, 1} = sub_ID;
                    neural_corr{sub_idx, 2} = mental_conc;
                    neural_corr{sub_idx, 3} = visuospatial_att;
                    neural_corr{sub_idx, 4} = emotion_state;
                    output_folder_neural = [combined_results_output_folder, cur_exp_id, '\'];
                    if ~exist(output_folder_neural, 'dir')
                        mkdir(output_folder_neural)
                    end
                    save([output_folder_neural, 'neural_corr.mat'], 'neural_corr')
                end
                %% Compute ERPs
                [ERP] = Compute_averaged_ERP(EEG, set_name, output_folder_cur);
                %% Plot ERPs
                if plot_ERP_flag
                    [ERP] = Plot_ERP_waveforms(ERP, EEG.nbchan, epoch_boundary, ar_rm_from_ch, set_name, output_folder_cur, plot_animation_flag);
                end
                %% Plot ERP images
                if plot_ERP_Im_flag
                    for channel_idx = 1:EEG.nbchan
                        Plot_ERP_Image(EEG, target_bin, set_name, output_folder_cur, channel_idx)
                    end
                end
            end
            
        end
    end
end