#!/bin/zsh

if [[ -z $ETUDE_DIR ]]; then
    echo "The variable \$ETUDE_DIR is not set"
    exit 0
fi

if [[ -z $ETUDE_CONFIGS ]]; then
    echo "The variable \$ETUDE_CONFIGS is not set"
    exit 0
fi

if [[ -n $OUTPUT_ROOT ]]; then
    echo "Using '${OUTPUT_ROOT}' as root directory for output"
else
    export OUTPUT_ROOT=/tmp
    echo "Using '${OUTPUT_ROOT}' as root directory for output"
fi

mkdir -p ${OUTPUT_ROOT}/logs
		      
if [[ -n $CLINIDEID_ROOT ]]; then
    echo "CliniDeID"
    if [[ -n $CORPUS2014 ]]; then
	echo "2014 i2b2 Corpus"
	cd ${CLINIDEID_ROOT}
	export OUTPUT_DIR=${OUTPUT_ROOT}/clinideid_cli
	mkdir -p ${OUTPUT_DIR}
	time ./runCliniDeIDcommandLine.sh \
	     --inputFile --inputDir "$CORPUS2014/2014deidCorrectionsYoung/train/txt" \
	     --outputFile --outputDir ${OUTPUT_DIR} \
	     --level beyond \
	     --outputTypes filtered \
	     1> ${OUTPUT_ROOT}/logs/2014_train.stdout \
	     2> ${OUTPUT_ROOT}/logs/2014_train.stderr
    fi
else
    echo "Skipping CliniDeID"
fi

if [[ -n $CORPUS2016 ]]; then
    echo "2016 i2b2 Corpus"
else
    echo "Skipping 2016 i2b2 Corpus"
fi

if [[ -n $CORPUS2006 ]]; then
    echo "2006 i2b2 Corpus"
else
    echo "Skipping 2006 i2b2 Corpus"
fi
