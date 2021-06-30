# Nemar Tool Proof Of Concept

A simple docker application running Octave and some EEGLAB scripts.

## Usage

```
$ docker build --tag=octavedock13 .
$ docker run --rm -it octavedock13
$ # Then at the Octave prompt, install the signal processing toolbox (this should really be done in the Docker file)
$ pkg install -forge control
$ pkg install -forge signal
$ pkg load signal
$ # Then run script
$ script_test
```

Run the script file directly (for a modified version that would include the signal processing toolbox)

```
$ docker run --rm -it octavedock script_test.m arg1  # Run the example file
```
