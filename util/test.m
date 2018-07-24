            p_folder = {
                        'testdata/raw/id02ma.edf'};


for p_num = 1:length(p_folder)
    myparticipant = participant(['/Users/ryanlab/Desktop/AliT/Scripts/ALItrack/' ,p_folder{p_num}]);
    myparticipant.set_trials()
    num_trials = myparticipant.NUM_TRIALS;
    myparticipant.set_base(1:num_trials);
end


%'testdata/raw/2003.edf';

