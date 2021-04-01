#!/bin/bash

if [[ -z $OTS_DIR ]]; then
    echo "The variable \$OTS_DIR is not set. It should be set to the directory containing this script."
    exit 0
fi

if [[ -z $ETUDE_DIR ]]; then
    echo "The variable \$ETUDE_DIR is not set"
    exit 0
fi

if [[ -n $OUTPUT_ROOT ]]; then
    echo "Using '${OUTPUT_ROOT}' as root directory for output"
else
    export OUTPUT_ROOT=/tmp
    echo "Using '${OUTPUT_ROOT}' as root directory for output"
fi

export LOG_DIR=${OUTPUT_ROOT}/logs
mkdir -p ${LOG_DIR}
		      
if [[ -n $CORPUS2014 ]]; then
    echo "2014 i2b2 Corpus"
    export SHORT_CORPUS=2014_train
    if [[ -n $CLINIDEID_ROOT ]]; then
	echo "CliniDeID"
	export SHORT_SYSTEM=clinideid
	cd ${CLINIDEID_ROOT}
	export OUTPUT_DIR=${OUTPUT_ROOT}/clinideid_cli
	mkdir -p ${OUTPUT_DIR}
	time ./runCliniDeIDcommandLine.sh \
	     --inputFile --inputDir "$CORPUS2014/train/txt" \
	     --outputFile --outputDir ${OUTPUT_DIR} \
	     --level beyond \
	     --outputTypes filtered \
	     1> ${LOG_ROOT}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stdout \
	     2> ${LOG_ROOT}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stderr
    else
	echo "Skipping CliniDeID"
    fi
    ####
    ## NLM Scrubber
    ####
    if [[ -n $SCRUBBER_ROOT ]]; then
	echo "NLM Scrubber"
	export SHORT_SYSTEM=scrubber
	cd ${SCRUBBER_ROOT}
	export OUTPUT_DIR=${OUTPUT_ROOT}/${SHORT_SYSTEM}
	mkdir -p ${OUTPUT_DIR}
	#time ./scrubber.19.0403.lnx \
	#    $OTS_DIR/nlm-scrubber/i2b2_2014_train.conf \
	#    1> $LOG_DIR/scrubber_2014_train.stdout \
	#    2> $LOG_DIR/scrubber_2014_train.stderr
	if [[ -z $CORPUS_UTILS ]]; then
	    echo "Skipping nlm2brat conversion because the variable \$CORPUS_UTILS is not set.  It is available here:  https://github.com/MUSC-TBIC/corpus-utils.git"
	else
	    python3 ${CORPUS_UTILS}/nlm-scrubber/nlm2brat.py \
		--raw-dir ${CORPUS2014}/train/txt \
		--processed-dir ${OUTPUT_DIR} \
		--output-dir ${OUTPUT_DIR}_brat
	fi
    else
	echo "Skipping NLM Scrubber"
    fi

else
    echo "Skipping 2014 i2b2 Corpus"
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
