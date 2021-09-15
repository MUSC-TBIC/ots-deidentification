
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
each system folder will be another subdirectory for each corpus split. A full run clocks in at just under 4G of diskspace.

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

NLM Scrubber
------------

```
wget https://scrubber.nlm.nih.gov/files/linux/scrubber.19.0403L.zip

unzip scrubber.19.0403L.zip
```
