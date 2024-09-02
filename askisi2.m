clear all; clc;

top_dir = 'C:\\Users\\Άννα\\Desktop\\exer3\\dhp_marcel\\';
gesture_dirs = {'Clic', 'No', 'Rotate', 'StopGraspOk'};

gesture_map = struct();
for g = 1:length(gesture_dirs)
    gesture_map.(gesture_dirs{g}) = g;
end


window_size = 50; 
k_val = 3; 
gesture_features = struct();

for g = 1:length(gesture_dirs)
    seq_folders = dir(fullfile(top_dir, gesture_dirs{g}, 'Seq*'));
    gesture_features.(gesture_dirs{g}) = cell(1, length(seq_folders));
    
    for s = 1:length(seq_folders)
        video_file = fullfile(seq_folders(s).folder, seq_folders(s).name, 'output.avi');
        video = VideoReader(video_file);
        num_frames = video.NumFrames;        
        binary_frames = zeros(video.Height, video.Width, num_frames);
        color_frames = zeros(video.Height, video.Width, 3, num_frames);
        
        for i = 1:num_frames
            frame = read(video, i);
            frame_gray = rgb2gray(frame);
            binary_frame = imbinarize(frame_gray);
            binary_frames(:, :, i) = binary_frame;
            color_frames(:, :, :, i) = frame;
        end


        features = extract_features(binary_frames, color_frames);
        normalized_features = (features - min(features)) ./ (max(features) - min(features));
        gesture_features.(gesture_dirs{g}){s} = normalized_features;
    end
end

training_features = {};
training_labels = {};
test_features = {};
test_labels = {};

for g = 1:length(gesture_dirs)
    for s = 1:length(gesture_features.(gesture_dirs{g}))
        features = gesture_features.(gesture_dirs{g}){s};
        
        if s <= 5
            training_features{end+1} = features;
            training_labels{end+1} = gesture_map.(gesture_dirs{g});

        else
            test_features{end+1} = features;
            test_labels{end+1} = gesture_map.(gesture_dirs{g});

        end
    end
end

distances = zeros(length(training_features), length(test_features));
for i = 1:length(training_features)
    for j = 1:length(test_features)
        distances(i, j) = DTW(training_features{i}, test_features{j}, window_size);
    end
end


for k = k_val
    predicted_labels = zeros(length(test_features), 1);
    for i = 1:length(test_features)
        [~, idx] = mink(distances(:, i), k);
        votes = histc(cell2mat(training_labels(idx)), 1:length(gesture_dirs));
        [~, predicted_labels(i)] = max(votes);
    end
    
    confusion_matrix = confusionmat(cell2mat(test_labels), predicted_labels);

    figure;
    confusionchart(confusion_matrix, gesture_dirs, 'Normalization', 'row-normalized');
    title('Confusion Matrix');
    disp(confusion_matrix);
 
end
