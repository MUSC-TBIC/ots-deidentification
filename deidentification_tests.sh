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

run_etude() {
    ## Variables passed as arguments
    shared_suffix=""
    sys_suffix="${shared_suffix}$1"
    ## Variables fully determinable from other variables
    score_key="i2b2 14/16"
    sys_config="${OTS_DIR}/etude_confs/${SHORT_SYSTEM}.conf"
    ref_config="${OTS_DIR}/etude_confs/${SHORT_CORPUS}.conf"
    ## Variables determined relative to other variables
    if [[ "${SHORT_CORPUS}" == "2006_train" || \
        "${SHORT_CORPUS}" == "2006_test" ]]; then
        ref_dir=${CORPUS_ROOT}/../xml
        ref_suffix="${shared_suffix}.xml"
        ref_config="${OTS_DIR}/etude_confs/i2b2_2006.conf"
    elif [[ "${SHORT_CORPUS}" == "2006_nTrain" || \
        "${SHORT_CORPUS}" == "2006_nTest" ]]; then
        ref_dir=${CORPUS_ROOT}/../xml_normed
        ref_suffix="${shared_suffix}.xml"
        ref_config="${OTS_DIR}/etude_confs/i2b2_2006.conf"
    elif [[ "${SHORT_CORPUS}" == "2014_train" || \
        "${SHORT_CORPUS}" == "2014_test" || \
        "${SHORT_CORPUS}" == "2016_train" || \
        "${SHORT_CORPUS}" == "2016_test" ]]; then
        ref_dir=${CORPUS_ROOT}/../xml
        ref_suffix="${shared_suffix}.xml"
        ref_config="${OTS_DIR}/etude_confs/i2b2_2016.conf"
    elif [[ "${SHORT_CORPUS}" == "2014_nTrain" || \
        "${SHORT_CORPUS}" == "2014_nTest" || \
        "${SHORT_CORPUS}" == "2016_nTrain" || \
        "${SHORT_CORPUS}" == "2016_nTest" ]]; then
        ref_dir=${CORPUS_ROOT}/../xml_normed
        ref_suffix="${shared_suffix}.xml"
        ref_config="${OTS_DIR}/etude_confs/i2b2_2016.conf"
    elif [ "${SHORT_CORPUS}" == "mimic" ]; then
        ref_dir=${CORPUS_ROOT}/../xml
    fi
    if [[ "${SHORT_SYSTEM}" == "neuroner" ]]; then
        sys_dir=`ls -dt ${OUTPUT_DIR}/${SHORT_CORPUS}_* | head -n 1`"/brat/test"
    elif [[ "${SHORT_SYSTEM}" == "scrubber" ]]; then
        sys_dir="${OUTPUT_DIR}/${SHORT_CORPUS}_brat"
    else
        sys_dir="${OUTPUT_DIR}"
    fi
    ###################################
    print_section 3 "Annotation Counts"
    print_section 3 "ls ${ref_dir}/${ref_suffix}"
    print_section 3 "ls ${sys_dir}/${sys_suffix}"
    ${ETUDE_BIN}/python3 ${ETUDE_DIR}/etude.py \
        --print-counts \
        --no-metrics \
        --reference-input "${sys_dir}" \
        --reference-config "${sys_config}" \
        --by-type \
        --file-suffix "${sys_suffix}" \
        --pretty-print
    ###################################
    print_section 3 "Evaluation"
    ${ETUDE_BIN}/python3 ${ETUDE_DIR}/etude.py \
        --reference-input "${ref_dir}" \
        --reference-config "${ref_config}" \
        --score-key "${score_key}" \
        --test-input "${sys_dir}" \
        --test-config "${sys_config}" \
        --collapse-all-patterns \
        --by-type \
        --metrics TP FP FN Recall Precision F1 \
        --fuzzy-match-flags exact partial \
        --file-suffix "${ref_suffix}" "${sys_suffix}"
}

run_mist() {
    SHORT_CORPUS=$1
    CORPUS_ROOT=$2
    print_section 2 "MIST"
    export SHORT_SYSTEM=mist
    cd ${MAT_PKG_HOME}
    export OUTPUT_DIR=${OUTPUT_ROOT}/${SHORT_SYSTEM}/${SHORT_CORPUS}
    mkdir -p ${OUTPUT_DIR}
    ( time ${MAT_PKG_HOME}/bin/MATEngine \
        --task 'AMIA Deidentification' \
        --workflow Demo \
        --steps 'zone,tag' \
        --tagger_local \
        --input_dir ${CORPUS_ROOT} \
        --input_file_re ".*[.]txt" \
        --input_file_type raw \
        --output_dir ${OUTPUT_DIR} \
        --output_file_type mat-json \
        --output_fsuff ".json" \
        1> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stdout \
        2> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stderr ) 2>> $ORG_FILE
}

run_scrubber() {
    SHORT_CORPUS=$1
    CORPUS_ROOT=$2
    CORPUS_CONFIG=$3
    print_section 2 "NLM Scrubber"
    export SHORT_SYSTEM=scrubber
    cd ${SCRUBBER_ROOT}
    export OUTPUT_DIR=${OUTPUT_ROOT}/${SHORT_SYSTEM}
    mkdir -p ${OUTPUT_DIR}
    ( time ./scrubber.19.0403.lnx \
        $OTS_DIR/nlm-scrubber/${CORPUS_CONFIG} \
        1> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stdout \
        2> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stderr ) 2>> $ORG_FILE
    if [[ -z $CORPUS_UTILS ]]; then
        echo "Skipping nlm2brat conversion because the variable \$CORPUS_UTILS is not set.  It is available here:  https://github.com/MUSC-TBIC/corpus-utils.git"
    else
        mkdir -p ${OUTPUT_DIR}/${SHORT_CORPUS}_brat
        ${ETUDE_BIN}/python3 ${CORPUS_UTILS}/nlm-scrubber/nlm2brat.py \
            --raw-dir ${CORPUS_ROOT} \
            --processed-dir ${OUTPUT_DIR}/${SHORT_CORPUS}_nphi \
            --output-dir ${OUTPUT_DIR}/${SHORT_CORPUS}_brat
    fi
    ####
    run_etude \
        ".ann"
}

run_clinideid() {
    SHORT_CORPUS=$1
    CORPUS_ROOT=$2
    FILTER_LEVEL=$3
    print_section 2 "Clinacuity's CliniDeID (${SHORT_CORPUS})"
    export SHORT_SYSTEM=clinideid
    export OUTPUT_DIR=${OUTPUT_ROOT}/${SHORT_SYSTEM}/${SHORT_CORPUS}
    mkdir -p ${OUTPUT_DIR}
    cd ${CLINIDEID_ROOT}
    ( time ./runCliniDeIDcommandLine.sh \
        --inputFile \
        --inputDir ${CORPUS_ROOT} \
        --outputFile \
        --outputDir ${OUTPUT_DIR} \
        --level ${FILTER_LEVEL} \
        --outputTypes filtered \
        1> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stdout \
        2> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stderr ) 2>> $ORG_FILE
    run_etude \
        ".filtered-system-output.xml"
}

run_neuroner() {
    SHORT_CORPUS=$1
    CORPUS_ROOT=$2
    print_section 2 "NeuroNER (${SHORT_CORPUS})"
    export SHORT_SYSTEM=neuroner
    export OUTPUT_DIR=${OUTPUT_ROOT}/${SHORT_SYSTEM}
    mkdir -p ${OUTPUT_DIR}
    ## NeuroNER requires a very specific directory structure for its
    ## input directory. We need to copy the source corpus files into
    ## NeuroNER's preferred tree.
    TMP_CORPUS_ROOT=/tmp/neuroner_tmp_corpus
    TMP_CORPUS=${TMP_CORPUS_ROOT}/${SHORT_CORPUS}
    mkdir -p $TMP_CORPUS/test
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
    run_etude \
        ".ann"
}

run_philter_ucsf() {
    SHORT_CORPUS=$1
    CORPUS_ROOT=$2
    print_section 2 "UCSF's Philter"
    export SHORT_SYSTEM=philter
    cd ${PHILTER_ROOT}
    export OUTPUT_DIR=${OUTPUT_ROOT}/${SHORT_SYSTEM}/${SHORT_CORPUS}
    ## Philter needs a clean directory with only text files in it.
    TMP_CORPUS_ROOT=/tmp/philter_tmp_corpus
    TMP_CORPUS=${TMP_CORPUS_ROOT}/${SHORT_CORPUS}
    mkdir -p $TMP_CORPUS
    cp $CORPUS_ROOT/*.txt ${TMP_CORPUS}/.
    ## A handful of files cause Philter to stall. We need to check if
    ## they're present in this run and remove them, if so.
    if [[ ${SHORT_CORPUS} == "2006_train" ]]; then
        for i in 174.txt 210.txt 215.txt 270.txt 277.txt 285.txt \
                 322.txt 398.txt 47.txt 54.txt 68.txt 93.txt; do \
            if [[ -f "${TMP_CORPUS}/$i" ]]; then
                rm "${TMP_CORPUS}/$i"
            fi
        done
    fi
    if [[ ${SHORT_CORPUS} == "2006_test" ]]; then
        for i in 437.txt 458.txt; do \
            if [[ -f "${TMP_CORPUS}/$i" ]]; then
                rm "${TMP_CORPUS}/$i"
            fi
        done
    fi
    ## Trailing slash is required for the input and output directories
    mkdir -p ${OUTPUT_DIR}
    ( time ${PHILTER_BIN}/python3 -m philter_ucsf \
        -i ${TMP_CORPUS}/ \
        -o ${OUTPUT_DIR}/ \
        -f ./configs/philter_delta.json \
        --prod=True \
        1> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stdout \
        2> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stderr ) 2>> $ORG_FILE
    echo "    - The temporary folders created under '${TMP_CORPUS_ROOT}' can be deleted."
    run_etude \
        ".xml"
}

run_physionet_deid() {
    SHORT_CORPUS=$1
    CORPUS_ROOT=$2
    print_section 2 "PhysioNet's deid (${SHORT_CORPUS})"
    export SHORT_SYSTEM=physionet_deid
    cd ${PHYSIONET_DEID_ROOT}
    export OUTPUT_DIR=${OUTPUT_ROOT}/${SHORT_SYSTEM}/${SHORT_CORPUS}
    mkdir -p ${OUTPUT_DIR}
    ## PhysioNet's deid can only run on one file at a time and it must
    ## end in .text
    TMP_CORPUS_ROOT=/tmp/physionet_tmp_corpus
    TMP_CORPUS=${TMP_CORPUS_ROOT}/${SHORT_CORPUS}
    mkdir -p $TMP_CORPUS
    ( time for i in $CORPUS_ROOT/*.txt; do
        FILEBASE="$(basename $i .txt)"; \
            TMP_FILE="$TMP_CORPUS/$FILEBASE"; \
            echo "START_OF_RECORD=1||||1||||" > $TMP_FILE.text; \
            cat $CORPUS_ROOT/$FILEBASE.txt >> $TMP_FILE.text; \
            echo "||||END_OF_RECORD" >> $TMP_FILE.text; \
            perl deid.pl $TMP_FILE deid-output.config \
            1>> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stdout \
            2>> ${LOG_DIR}/${SHORT_SYSTEM}_${SHORT_CORPUS}.stderr; \
            cp $TMP_FILE.phi $OUTPUT_DIR/.; \
            cp $TMP_FILE.text $OUTPUT_DIR/.; \
            cp $TMP_FILE.res $OUTPUT_DIR/.; \
            cp $TMP_FILE.info $OUTPUT_DIR/.; \
            done ) 2>> $ORG_FILE
    echo "    - The temporary folders created under '${TMP_CORPUS_ROOT}' can be deleted."
    run_etude \
        ".phi"
}

if [[ -n $CORPUS2014 ]]; then
    print_section 1 "2014 i2b2 Corpus"
    ####
    ## Clinacuity's CliniDeID
    ####
    if [[ -n $CLINIDEID_ROOT ]]; then
        ## Original Corpora
        run_clinideid \
            2014_train \
            $CORPUS2014/train/txt \
            beyond
        run_clinideid \
            2014_test \
            $CORPUS2014/test/txt \
            beyond
    else
        print_section 2 "Skipping Clinacuity's CliniDeID"
    fi
    ####
    ## MIST
    ####
    if [[ -n $MAT_PKG_HOME ]]; then
        run_mist \
            2014_train \
            $CORPUS2014/train/txt
        run_mist \
            2014_test \
            $CORPUS2014/test/txt
    else
        print_section 2 "Skipping MIST"
    fi
    ####
    ## NLM's Scrubber
    ####
    if [[ -n $SCRUBBER_ROOT ]]; then
        ## Original Corpora
        run_scrubber \
            2014_train \
            $CORPUS2014/train/txt \
            i2b2_2014_train.conf
        run_scrubber \
            2014_test \
            $CORPUS2014/test/txt \
            i2b2_2014_test.conf
        ## Normalized Date Corpora
        run_scrubber \
            2014_nTrain \
            $CORPUS2014/train/txt_normed \
            i2b2_2014_nTrain.conf
        run_scrubber \
            2014_nTest \
            $CORPUS2014/test/txt_normed \
            i2b2_2014_nTest.conf
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
    ####
    ## PhysioNet's deid
    ####
    if [[ -n $PHYSIONET_DEID_ROOT ]]; then
        run_physionet_deid \
            2014_train \
            $CORPUS2014/train/txt
        run_physionet_deid \
            2014_test \
            $CORPUS2014/test/txt
    else
        print_section 2 "Skipping PhysioNet's deid"
    fi
    ####
    ## UCSF's Philter
    ####
    if [[ -n $PHILTER_ROOT ]]; then
        run_philter_ucsf \
            2014_train \
            $CORPUS2014/train/txt
        run_philter_ucsf \
            2014_test \
            $CORPUS2014/test/txt
    else
        print_section 2 "Skipping UCSF's Philter"
    fi

else
    print_section 1 "Skipping 2014 i2b2 Corpus"
fi

if [[ -n $CORPUS2016 ]]; then
    print_section 1 "2016 i2b2 Corpus"
    ####
    ## Clinacuity's CliniDeID
    ####
    if [[ -n $CLINIDEID_ROOT ]]; then
        run_clinideid \
            2016_train \
            $CORPUS2016/train/txt \
            beyond
        run_clinideid \
            2016_test \
            $CORPUS2016/test/txt \
            beyond
    else
        print_section 2 "Skipping Clinacuity's CliniDeID"
    fi
    ####
    ## MIST
    ####
    if [[ -n $MAT_PKG_HOME ]]; then
        run_mist \
            2016_train \
            $CORPUS2016/train/txt
        run_mist \
            2016_test \
            $CORPUS2016/test/txt
    else
        print_section 2 "Skipping MIST"
    fi
    ####
    ## NLM's Scrubber
    ####
    if [[ -n $SCRUBBER_ROOT ]]; then
        ## Original Corpus
        run_scrubber \
            2016_train \
            $CORPUS2016/train/txt \
            i2b2_2016_train.conf
        run_scrubber \
            2016_test \
            $CORPUS2016/test/txt \
            i2b2_2016_test.conf
        ## Normalized Date Corpus
        run_scrubber \
            2016_nTrain \
            $CORPUS2016/train/txt_normed \
            i2b2_2016_nTrain.conf
        run_scrubber \
            2016_nTest \
            $CORPUS2016/test/txt_normed \
            i2b2_2016_nTest.conf
    else
        print_section 2 "Skipping NLM Scrubber"
    fi
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
    ####
    ## PhysioNet's deid
    ####
    if [[ -n $PHYSIONET_DEID_ROOT ]]; then
        run_physionet_deid \
            2016_train \
            $CORPUS2016/train/txt
        run_physionet_deid \
            2016_test \
            $CORPUS2016/test/txt
    else
        print_section 2 "Skipping PhysioNet's deid"
    fi
    ####
    ## UCSF's Philter
    ####
    if [[ -n $PHILTER_ROOT ]]; then
        run_philter_ucsf \
            2016_train \
            $CORPUS2016/train/txt
        run_philter_ucsf \
            2016_test \
            $CORPUS2016/test/txt
    else
        print_section 2 "Skipping UCSF's Philter"
    fi
else
    print_section 1 "Skipping 2016 i2b2 Corpus"
fi

if [[ -n $CORPUS2006 ]]; then
    print_section 1 "2006 i2b2 Corpus"
    ####
    ## Clinacuity's CliniDeID
    ####
    if [[ -n $CLINIDEID_ROOT ]]; then
        run_clinideid \
            2006_train \
            $CORPUS2006/train/txt \
            beyond
        run_clinideid \
            2006_test \
            $CORPUS2006/test/txt \
            beyond
    else
        print_section 2 "Skipping Clinacuity's CliniDeID"
    fi
    ####
    ## MIST
    ####
    if [[ -n $MAT_PKG_HOME ]]; then
        run_mist \
            2006_train \
            $CORPUS2006/train/txt
        run_mist \
            2006_test \
            $CORPUS2006/test/txt
    else
        print_section 2 "Skipping MIST"
    fi
    ####
    ## NLM's Scrubber
    ####
    if [[ -n $SCRUBBER_ROOT ]]; then
        ## Original Corpus
        run_scrubber \
            2006_train \
            $CORPUS2006/train/txt \
            i2b2_2006_train.conf
        run_scrubber \
            2006_test \
            $CORPUS2006/test/txt \
            i2b2_2006_test.conf
        ## Normalized Date Corpus
        run_scrubber \
            2006_nTrain \
            $CORPUS2006/train/txt_normed \
            i2b2_2006_nTrain.conf
        run_scrubber \
            2006_nTest \
            $CORPUS2006/test/txt_normed \
            i2b2_2006_nTest.conf
    else
        print_section 2 "Skipping NLM Scrubber"
    fi
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
    ####
    ## PhysioNet's deid
    ####
    if [[ -n $PHYSIONET_DEID_ROOT ]]; then
        run_physionet_deid \
            2006_train \
            $CORPUS2006/train/txt
        run_physionet_deid \
            2006_test \
            $CORPUS2006/test/txt
    else
        print_section 2 "Skipping PhysioNet's deid"
    fi
    ####
    ## UCSF's Philter
    ####
    if [[ -n $PHILTER_ROOT ]]; then
        run_philter_ucsf \
            2006_train \
            $CORPUS2006/train/txt
        run_philter_ucsf \
            2006_test \
            $CORPUS2006/test/txt
    else
        print_section 2 "Skipping UCSF's Philter"
    fi
else
    print_section 1 "Skipping 2006 i2b2 Corpus"
fi
