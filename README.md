

An object-oriented Matlab program for reading participant data, transcribing audio_files, and outputing features.

## Getting Started

Download the repo and add it to your matlab path. 
Check example.m for sample usage of the repo. 

### Prerequisites

  Matlab
  https://github.com/jashubbard/iTrack/tree/master/support/edfImport

```
Give examples
```

### Installing


```
Give the example
```

And repeat

```
until finished
```


## Running the tests

Explain how to run the automated tests for this system



```
Give an example
```

## Deployment

### using Participant Class 
myparticipant = participant(2003, '/Users/ryanlab/Desktop/AliT/Data/ALItracker_Data/2003');\
myparticipant.setdata()\
myparticipant.setaudio()\

myparticipant.word_saccade_correlator(3,'duration', 'before' , 100  , 'after', 200) 

myparticipant.get_trial_features(1:12)\
trial = myparticipant.gettrial(1);

### using Trial class directly 
trial = gettrial(myparticipant,1); \
trial.number_of_fixation
trial.number_of_saccade
trial.duration_of_fixation
trial.duration_of_saccade
trial.location_of_fixation
trial.location_of_saccade_endpoints
trial.amplitude_of_saccade
trial.deviation_of_duration_of_fixation
trial.deviation_of_duration_of_saccade
trial.regionsofinterest



## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D


## Authors

* **Alireza Tajadod** - *Initial work* - [Repo](https://github.com/ATajadod94/ALITrack)

Under direct supervision of Dr.Zhongxu liu


## Acknowledgments

* Hat tip to anyone who's code was used

