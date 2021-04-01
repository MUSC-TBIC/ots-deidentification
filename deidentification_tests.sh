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

if [[ -z $ORG_FILE ]]; then
    export ORG_FILE=/dev/null
fi

export LOG_DIR=${OUTPUT_ROOT}/logs
mkdir -p ${LOG_DIR}

print_section() {
    depth=$1
    header=$2
    cl_prefix=""
    org_prefix="* "
    if [ $depth -eq 2 ]; then
	cl_prefix=" -- "
	org_prefix="** "
    fi
    if [ $depth -eq 3 ]; then
	cl_prefix="    - "
	org_prefix="*** "
    fi
    echo "${cl_prefix}$header"
    echo "${org_prefix}$header" >> ${ORG_FILE}
}

run_neuroner() {
    SHORT_CORPUS=$1
    print_section 2 "NeuroNER (${SHORT_CORPUS})"
    ##echo " -- NeuroNER (${SHORT_CORPUS})"
    ##echo " -- NeuroNER (${SHORT_CORPUS})" >> ${ORG_FILE}
    export SHORT_SYSTEM=neuroner
    export OUTPUT_DIR=${OUTPUT_ROOT}/${SHORT_SYSTEM}
    mkdir -p ${OUTPUT_DIR}
    ## NeuroNER requires a very specific directory structure for its
    ## input directory. We need to copy the source corpus files into
    ## NeuroNER's preferred tree.
    TMP_CORPUS_ROOT=/tmp/neuroner_tmp_corpus
    TMP_CORPUS=${TMP_CORPUS_ROOT}/${SHORT_CORPUS}
    mkdir -p $TMP_CORPUS/test
    CORPUS_ROOT=$2
    cp $CORPUS_ROOT/*.txt ${TMP_CORPUS}/test/.
    cd ${NEURONER_ROOT}
    ( time ${NEURONER_BIN}/neuroner \
        --train_model=False \
        --use_pretrained_model=True \
        --dataset_text_folder=${TMP_CORPUS} \
        --pretrained_model_folder=${NEURONER_ROOT}/trained_models/i2b2_2014_glove_spacy_bioes \
        --output_folder=${OUTPUT_DIR} \
        1> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stdout \
        2> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stderr ) 2>> $ORG_FILE
    echo "    - The temporary folders created under '${TMP_CORPUS_ROOT}' can be deleted."
}

if [[ -n $CORPUS2014 ]]; then
    print_section 1 "2014 i2b2 Corpus"
    ####
    ## Clinacuity's CliniDeID
    ####
    if [[ -n $CLINIDEID_ROOT ]]; then
        print_section 2 "CliniDeID"
        export SHORT_SYSTEM=clinideid
        cd ${CLINIDEID_ROOT}
        export OUTPUT_DIR=${OUTPUT_ROOT}/clinideid_cli
        mkdir -p ${OUTPUT_DIR}
        time ./runCliniDeIDcommandLine.sh \
             --inputFile --inputDir "$CORPUS2014/train/txt" \
             --outputFile --outputDir ${OUTPUT_DIR} \
             --level beyond \
             --outputTypes filtered \
             1> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stdout \
             2> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stderr
    else
        print_section 2 "Skipping CliniDeID"
    fi
    ####
    ## NLM's Scrubber
    ####
    if [[ -n $SCRUBBER_ROOT ]]; then
        print_section 2 "NLM Scrubber"
        export SHORT_SYSTEM=scrubber
        cd ${SCRUBBER_ROOT}
        export OUTPUT_DIR=${OUTPUT_ROOT}/${SHORT_SYSTEM}
        mkdir -p ${OUTPUT_DIR}
        time ./scrubber.19.0403.lnx \
            $OTS_DIR/nlm-scrubber/i2b2_2014_train.conf \
            1> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stdout \
            2> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stderr
        if [[ -z $CORPUS_UTILS ]]; then
            echo "Skipping nlm2brat conversion because the variable \$CORPUS_UTILS is not set.  It is available here:  https://github.com/MUSC-TBIC/corpus-utils.git"
        else
            python3 ${CORPUS_UTILS}/nlm-scrubber/nlm2brat.py \
                --raw-dir ${CORPUS2014}/train/txt \
                --processed-dir ${OUTPUT_DIR} \
                --output-dir ${OUTPUT_DIR}_brat
        fi
    else
        print_section 2 "Skipping NLM Scrubber"
    fi
    ####
    ## NeuroNER
    ####
    if [[ -n $NEURONER_BIN ]] && [[ -n $NEURONER_ROOT ]]; then
	run_neuroner \
	    2014_train \
	    $CORPUS2014/train/txt
	run_neuroner \
	    2014_test \
	    $CORPUS2014/test/txt
    else
        print_section 2 "Skipping NeuroNER"
    fi

else
    print_section 1 "Skipping 2014 i2b2 Corpus"
fi

if [[ -n $CORPUS2016 ]]; then
    print_section 2 "2016 i2b2 Corpus"
    ####
    ## NeuroNER
    ####
    if [[ -n $NEURONER_BIN ]] && [[ -n $NEURONER_ROOT ]]; then
	run_neuroner \
	    2016_train \
	    $CORPUS2016/train/txt
	run_neuroner \
	    2016_test \
	    $CORPUS2016/test/txt
    else
        print_section 2 "Skipping NeuroNER"
    fi
else
    print_section 1 "Skipping 2016 i2b2 Corpus"
fi

if [[ -n $CORPUS2006 ]]; then
    print_section 1 "2006 i2b2 Corpus"
    ####
    ## NeuroNER
    ####
    if [[ -n $NEURONER_BIN ]] && [[ -n $NEURONER_ROOT ]]; then
	run_neuroner \
	    2006_train \
	    $CORPUS2006/train/txt
	run_neuroner \
	    2006_test \
	    $CORPUS2006/test/txt
    else
        print_section 2 "Skipping NeuroNER"
    fi
else
    print_section 1 "Skipping 2006 i2b2 Corpus"
fi
