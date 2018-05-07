classdef audio < handle
    properties
        address 
        transcript_available = 0 
        words = []
        num_trials 
    end
    properties(Access=private)
        transcriber = 'python3 /Users/ryanlab/Des[ktop/AliT/Scripts/Google_Transcribtion/Audio_Transcriber.py --gui off --folders'
        output_folder 
        timestamp_folder 
    end
    methods
        
        function transcribe(obj)
            if obj.address
                transcriber_msg = [obj.transcriber,' ',  obj.address];
                %system(transcriber_msg)
                obj.transcript_available = 1;
                obj.output_folder = [ obj.address filesep 'GTranscriber_output'];
                obj.timestamp_folder = [obj.output_folder filesep 'Timetable'];
            end 
        end 
        
        function get_timestamps(obj)
            if obj.transcript_available
                csv_files = dir(obj.timestamp_folder);   
                obj.num_trials = length(csv_files) - 3;
                for trial = 4:obj.num_trials + 3
                    trial_file = [obj.timestamp_folder filesep csv_files(trial).name];
                    formatSpec = '%s%f%f%f%[^\n\r]';
                    fileID = fopen(trial_file,'r');
                    dataArray = textscan(fileID, formatSpec, 'Delimiter', ',', 'TextType', 'string',  'ReturnOnError', false);
                    fclose(fileID);
                    trial_number = ['trial_' int2str(trial - 3)];
                    participant_timetable = table(dataArray{1:end-1}, 'VariableNames', {'Word','start_time','end_time','duration'});
                    data_structure = table2struct(participant_timetable);
                    obj.words.(trial_number) =  data_structure;

                end
                
            end
            
        end 
    end 
end
     
    
    