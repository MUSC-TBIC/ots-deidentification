
The Key Shell Scripts
=====================

This repository contains a collection of (mostly) shell scripts,
configuration files, and other sundry to help run an array of
de-identification systems against an array of de-identification
annotated corpora.

New corpora and new systems can be added by following the general
pattern of the pre-existing examples.

For instance, each system is run according to a function named for the
de-identification system.  every system.  Adding a new system entails
copying one of the pre-existing functions (e.g.,
`run_physionet_deid()` or `run_mist()`) and adapting it to your new
system.  

This function, in turn, calls `run_etude()`.  As such, you'll likely
need to add customizations to the arguments passed to ETUDE for
scoring the new system.  Evaluation examples for ETUDE are provided to
count and evaluation both "All Patterns" and just the "Names"
categories.

New corpora can be added by copying and adapting one of the large
`for` loops near the bottom of the shell script (that is, starting
with `if [[ -n $RESYNTH2014 ]]; then` would be modified if your new
corpus was most similar to the resynthesized variant of the 2014
corpus).

The last adaptation that would need to done to add a new
de-identification system or a new corpus would be to create a
configuration file to tell ETUDE how to parse the files.  (If,
however, you would prefer to use your own custom evaluation script,
then you can simply replace the `run_etude()` function with your own
custom call.)

In theory, you will need to download the datasets that you wish to
evaluation against, set up your environment variables (as described
below), and install whichever systems that you want to benchmark (as
linked to below).  Then you can run `deientification_tests.sh` and
then review the scores generated in the log files.

In practice, it is a good idea to stub out a sample corpus for each
format that you want to test.  I do this by copying over 5-10 notes
for each corpus and folder into a parallel folder.  It allows me to
run the entire pipeline (similar to smoke testing) to make sure I have
all my de-identification systems set up, ETUDE is working, all my
configs are in the right place, etc.  Then I run the script on the
full corpora.

The other useful practice habit is to actually use the `run-all.sh`
shell script to set your custom environment variables and log file(s)
and run that instead of directly setting them in your shell.

Environment Variables
=====================

The following environment variables should be defined in order to
allow processing of the relevant corpora with the relevant
tools. Omitting a variable means that corpus and/or tool will be
ignored for a given run.

The `OTS_DIR` should point to the root of this repository so we know
how to find all our tools.

```
$OTS_DIR
```

Each corpus needs a variable pointing to its root directory. We assume
a directory structure under each folder as shown:

```

$CORPUS2006
├── test
│   ├── txt
│   └── xml
└── train
    ├── txt
    └── xml

$CORPUS2014
├── test
│   ├── txt
│   └── xml
└── train
    ├── txt
    └── xml

$CORPUS2016
├── test
│   ├── txt
│   └── xml
└── train
    ├── txt
    └── xml

$MUSC_CORPUS

```

The `OUTPUT_ROOT` is the base directory that we will write all system
output and log files to. Within this folder, you'll find a
subdirectory for each deidentification system and for logs. Within
each system folder will be another subdirectory for each corpus
split. A full run clocks in at just under 4G of diskspace.

```
$OUTPUT_ROOT
```

The default output log file is formatted is fairly human readable
plain text. If you want a slightly more structured output that matches
emacs org-mode formatting, set this environment variable.

```
$ORG_FILE
```

The `ETUDE_DIR` needs to point the root of the `ETUDE evaluation
engine repository <https://github.com/MUSC-TBIC/etude-engine>`_ so
that we can run all the scoring scripts. Skip this if you want to run
your own scoring scripts. The `ETUDE_BIN` should point to your
anaconda environment bin with all the appropriate requirements
installed (or your system bin if you installed ETUDE's requirements at
the system level).

```
$ETUDE_DIR
$ETUDE_BIN
```

The `CLINIDEID_ROOT` path is the root of your local installation of
CliniDeID.

```
$CLINIDEID_ROOT
```

Set your `MAT_PKG_HOME` path as explained in the installation
instructions for Mitre's MIST (e.g., `MIST_2_0_4/src/MAT`).

```
$MAT_PKG_HOME
```

The `NEURONER_ROOT` path should point to your local copy of the
`NeuroNER <https://github.com/Franck-Dernoncourt/NeuroNER/>`_
tool. Because this tools requires special additional packages to be
installed, the `NEURONER_BIN` should point to the `bin/` folder of
your anaconda environment correctly configured for NeuroNER (or to
your system's `bin/` if you have installed the additional requirements
at the system level).

```
$NEURONER_ROOT
$NEURONER_BIN
```

The `PHILTER_ROOT` points to the base of your local `Philter
repository <https://github.com/BCHSI/philter-ucsf>`_.

```
$PHILTER_ROOT
$PHILTER_BIN
```

The `PHYSIONET_DEID_ROOT` should point to a local installation of PhysioNET's deid v1.1.

```
$PHYSIONET_DEID_ROOT
```

The output of the NLM Scrubber needs to be converted to a format that
we can score. This script is available from our `corpus-utils
<https://github.com/MUSC-TBIC/corpus-utils>`_ repository. Set
`CORPUS_UTILS` path to point to your local checkout of said
repository.

```
$SCRUBBER_ROOT
$CORPUS_UTILS
```

Installing Individual Components
================================

CliniDeID
---------

See https://github.com/clinacuity/clinideid

MIST
----

See https://mist-deid.sourceforge.net/docs_2_0_4/html/index.html

Run using (v2.0.4).

NeuroNER
--------

See https://github.com/Franck-Dernoncourt/NeuroNER

Run using (commit 3817fea).

Philter
-------

See https://github.com/BCHSI/philter-ucsf

Run using (commit 780da99).

PhysioNet deid
--------------

See https://physionet.org/content/deid/1.1/

Run using (v 1.1).

NLM Scrubber
------------

See https://lhncbc.nlm.nih.gov/scrubber/download.html

Run using (v.19.0403L Linux x86 64).

```
wget https://scrubber.nlm.nih.gov/files/linux/scrubber.19.0403L.zip

unzip scrubber.19.0403L.zip
```
