Colorer schemes
========================
The library of schemes is a basic set of descriptions of syntaxes and styles of the coloring, used by Colorer library.
The project contains files and scripts for creation of library of schemes.
[![check build](https://github.com/colorer/Colorer-schemes/actions/workflows/checks.yml/badge.svg)](https://github.com/colorer/Colorer-schemes/actions/workflows/checks.yml)

*Improvements of translation of this file to English are welcome*

Structure
------------------------

  * hrc - basic set of descriptions of syntaxes (hrc-files) and their generators
  * hrd - basic set of styles of a coloring (hrd-files), their generators and additions
  * shared - shared colorer xml schemes
  * javalib - required java libs
  
How to build from source
------------------------

### Common ###

To build the library of schemes, you will need:

  * git
  * ant 1.8 or higher
  * java development kit 8 (jdk) or higher
  * perl

Download the source from git repository:

```sh
git clone https://github.com/colorer/Colorer-schemes.git
```

Run build

```sh
build.cmd target
```

where the *target* is one of the values

  * base                 - simple build of the schema library. Folder 'build/base'
  * base.packed          - build the schema library with the hrc-files packed into an zip file. Folder 'build/base-packed'
  * base.unpacked        - build the schema library with the hrc-files don`t packed into an zip file. Folder 'build/base-unpacked'
  * base.allpacked       - build the schema library with all files packed into a zip file. Folder 'build/base-allpacked'
  * base.distr-packed    - archive base.packed. Folder 'build'
  * base.distr-unpacked  - archive base.unpacked. Folder 'build'
  * base.distr-allpacked - archive base.allpacked. Folder 'build'

### Features of build under Windows ###

Before starting the build scripts, make sure that the *PATH* environment variable contains the path to jdk and ant.
Also you need the environment variable *JAVA_HOME* set. For example:

```cmd
set PATH=v:\apps\jdk\bin;v:\apps\ant\bin;%PATH%
set JAVA_HOME=v:\apps\jdk
```

### Features of build under Linux ###

Here is an example on Ubuntu 20.04.

Install ant

```sh
apt-get install ant
```

If the apt config contains `APT::Install-Recommends "False";`, then you must also install `ant-optional`.

## Develop ##

Descriptions of syntaxes (scheme) are divided into static and generated. Static are in a directory hrc/hrc, generated in hrc/src.

After scheme change, it is necessary test changes for regressions. For this purpose it is necessary:

  1. to build the library of schemes `build base`
  2. check that bin directory in the root of the project has colorer.exe (the utility for working with library of schemes)
  3. in hrc/test directory start script `perl runtest.pl --full`, or its alternative `runtest.py` 
  4. script will check the result of coloring of reference file, the result is output to the console and fails.html file in hrc/test/*time_of_test* directory.
  5. after the analysis of divergences in case of mistakes it is necessary to correct the scheme. If the current coloring is considered correct, it is necessary to replace the reference file with the new one.
     Reference files reside in hrc/test/_valid. New files reside in hrc/test/*time_of_test*

Also before modification of a repository it is recommended to edit the hrc/hrc/CHANGELOG file

Links
------------------------

* Project main page: [http://colorer.sourceforge.net/](http://colorer.sourceforge.net/)
