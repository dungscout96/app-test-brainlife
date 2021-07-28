# Docker commands
docker login

docker pull dtyoung/eeglab-pipeline:1.1
docker image list
docker run fce893a28159 ./app.m eeglab_data_epochs_ica.set


# Git clone
https://github.com/dungscout96/app-test-brainlife
docker build -t eeglab-octave:1.2 .

docker tag octave-eeglab:1.2 arnodelorme/octave-eeglab:1.2
docker tag eeglab-octave:1.2 arnodelorme/eeglab-octave:1.2
docker push arnodelorme/eeglab-octave:1.2
docker pull arnodelorme/octave-eeglab:1.2

# Files 
Dockerfile  - docker configuration
main        - brainlife executable
config.json - provided by brainlife

