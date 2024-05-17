## Create a new folder for the executables

mkdir ~/programs

## Create the environment variable for the executables

echo 'export PATH=$PATH:~/programs' >> ~/.bashrc

## Update the environment variable

source ~/.bashrc

## Download miniforge

wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge-pypy3-Linux-x86_64.sh

## Install miniforge
bash Miniforge-pypy3-Linux-x86_64.sh

## Add bioconda channels

conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

## Install fastp

mamba install fastp