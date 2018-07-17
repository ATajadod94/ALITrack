%% Loading an EDF file into Matlab


p_folder = 'testdata/aj031ro.edf'; % step 1 : Link to the edf file 
myparticipant = partiparticipantcpant(p_folder); % step 2 : Create your participant


%{
Common Errors 

1)
    Error using iTrack (line 41)
        Can not find file, Please check your directory (pwd)


CAUSE: 
    Your input folder does not point to an existing edf file. This is
    likely caused because your input present working directory (pwd) does 
    not point to an EDF as you expect.  
    
%}



