
## Overview
      To create a Matlab package that is able to create features for any given EDF file in a user friendly manner. 
      Furthermore, it aims to provide certain utility-like feature detection functionalities for eye_movement data processed elsewhere. 
      The package builds on top of (inherits) iTrack by Jason Hubbard, as modified by Dr.Liu . It aims to build on top of iTrack as well
      as improve certain existing functionalities. iTrack itself is no longer being developed. 
      
Available features : 
* Reading EDF data into Matlab
* Getting all listed features for all or any selected trials in any given edf file in a few minutes (as of last test, it took 261 seconds to prepare all features for an experiment with 864 trials)
* Total number of trials 
* Raw data
* Reading behavioural data
* Basic trial features such as polar data, adaptable onset temporal values, blink removal
* Basic Saccade features found in dataviewer (Eg: duration, amplitude, max/min of sensible feature, location)
* Second order saccade features not found in dataviewer ( Eg: Zcsore, standard deviations, ...)
* Basic fixation features found in dataviewer (see saccades)
* Second order Fixation features not found in dataviwer ( see saccades)
* Trial Specific spatial ROI's  (user defined masks, grids, rectangular, circular, elliptic masks)
* Trial specific temporal ROI's ( Event based  or temporal based trial onset and offset)
* ROI (temporal or spatial ) specific feature detection (EG: number of saccades in a specified period at a specified location)
* Eyelink like saccade detection (EG: detecting saccades using the eyelinkmethod after cleaning the data)

In development features: these features have either not been tested yet or have not been fully implemented. However, they are expected to be fully functional in the immediate future and can be used as-is for the sample data used in development.

* Entropy 1,2 measures
* Recurrence measures 

Next steps: 
* Testing the package on more and more EDF data to encounter potential errors
* (?)


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

