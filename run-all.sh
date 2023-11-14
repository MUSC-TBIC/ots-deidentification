#!/bin/bash

## Directory containing standard ETUDE configuration files.  A public
## version is available at:
## https://github.com/MUSC-TBIC/ots-deidentification.git"
export OTS_DIR=/data/software/ots-deidentification

## Directory containing the nlp2brat conversion script.  A public
## version is available at:
## https://github.com/MUSC-TBIC/corpus-utils.git
export CORPUS_UTILS=/data/software/corpus-utils

## Directory containing the ETUDE evaluation engine. A public version
## is available at: https://github.com/MUSC-TBIC/etude-engine.git
export ETUDE_DIR=/data/software/etude

export ETUDE_BIN=/data/software/anaconda3/envs/etude/bin

## The root directory for writing all output to.  If not explicitly
## set, this defaults to: /tmp
export OUTPUT_ROOT=/data/experiments/deid-eval

## An org-mode formatted output file for collecting progress through
## the script. Timing metrics, evaluation scores, and descriptive
## stats are all collected in this file. If not explicitly set, then
## these output statements and metrics will be written to /dev/null
## (that is, effectively ignored).

export ORG_FILE=/data/experiments/deid-eval/eval_all.org
export CORPUS2006=/data/deid/i2b2/2006deid 
export CORPUS2014=/data/deid/i2b2/2014deid
export CORPUS2016=/data/deid/i2b2/2016deid
export CORPUSMUSC=/data/deid/musc/combined

##export ORG_FILE=/data/experiments/deid-eval/sample_all.org
##export CORPUS2006=/data/deid/sample-deid/i2b2/2006deid 
##export CORPUS2014=/data/deid/sample-deid/i2b2/2014deid
##export CORPUS2016=/data/deid/sample-deid/i2b2/2016deid
##export CORPUSMUSC=/data/deid/sample-deid/musc/combined

export CLINIDEID_ROOT=/data/software/CliniDeID-Mac_v1.6.1
export MAT_PKG_HOME=/data/software/MIST_2_0_4/src/MAT
export SCRUBBER_ROOT=/data/software/scrubber.19.0403L
export NEURONER_ROOT=/data/software/neuroner
export NEURONER_BIN=/data/software/anaconda3/envs/neuroner/bin
export PHYSIONET_DEID_ROOT=/data/software/physionet_deid_v1.1
export PHILTER_ROOT=/data/software/philter-ucsf
export PHILTER_BIN=/data/software/anaconda3/envs/philter-ucsf/bin

deidentification-tests.sh

unset CORPUS2006
unset CORPUS2014
unset CORPUS2016
unset CORPUSMUSC

unset CLINIDEID_ROOT
unset MAT_PKG_HOME
unset SCRUBBER_ROOT
unset NEURONER_ROOT
unset NEURONER_BIN
unset PHYSIONET_DEID_ROOT
unset PHILTER_ROOT
unset PHILTER_BIN
