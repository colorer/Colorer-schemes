[![Travis](https://img.shields.io/travis/colorer/Colorer-schemes.svg)](https://travis-ci.org/colorer/Colorer-schemes)

Colorer schemes
========================
The library of schemes is a basic set of descriptions of syntaxes and styles of the coloring, used by Colorer library.
The project contains files and scripts for creation of library of schemes.

*improvements of translation of the file into English it is welcomed*

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
  * java development kit 6 (jdk) or higher
  * perl

Download the source from git repository:

    git clone https://github.com/colorer/Colorer-schemes.git

or update git repository:

    git pull

Run build

    build.cmd target

where the *target* is one of the values

  * base        - simple build of the schema library. Folder build/base
  * base.pack   - build the schema library with the packed hrc-files in the archive. Folder build/basep
  * base.far    - build the schema library for distribution with FarColorer distribution kit. Folder build/basefar
  * base.update - archive base.pack. Folder build

### Features of build under Windows ###

Before starting the build scripts, make sure that the *PATH* environment variable contains the path to the jdk and ant.
The same must be set the environment variable *JAVA_HOME*. For example:

    set PATH=v:\apps\jdk\bin;v:\apps\ant\bin;%PATH%
    set JAVA_HOME=v:\apps\jdk

### Features of build under Linux ###

On the example of Debian Wheezy.

Install ant and jdk

    apt-get install ant openjdk-6-jdk

If specified in the apt config `APT::Install-Recommends "False";`, you must also install `ant-optional`.

In the file */usr/share/ant/bin/ant* commenting lines

    # Add the Xerces 2 XML parser in the Debian version
    if [ -z "$LOCALCLASSPATH" ] ; then
      LOCALCLASSPATH="/usr/share/java/xmlParserAPIs.jar:/usr/share/java/xercesImpl.jar"
    else
      LOCALCLASSPATH="/usr/share/java/xmlParserAPIs.jar:/usr/share/java/xercesImpl.jar:$LOCALCLASSPATH"
    fi

This action corrects the error `Warning: XML resolver not found; external catalogs will be ignored`  when building schemes.
A more detailed description of the error [in Debian bug-tracker](http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=552032).

## Develop ##

Descriptions of syntaxes (scheme) divided into static and generated. Static there are in a directory hrc/hrc, generated in hrc/src.

After scheme change, it is necessary to make testing of changes for regressions. For this purpose it is necessary:

  1. build the library of schemes `build base`
  2. to be convinced that in bin directory in a root of the project lies colorer.exe (the utility for work with library of schemes)
  3. in a directory of hrc/test to start a script `perl runtest.pl --full`. or analog of `runtest.py` 
  4. during work of a script the result of a coloring of the file with a standard will be checked, the result is output in the console and in the fails.html file in hrc/test/*time_of_test* directory.
  5. after the analysis of divergences in case of mistakes it is necessary to correct the scheme. If the current coloring is considered true, it is necessary to replace the standard file with the new.
     Files standards are in hrc/test/_valid. New files in hrc/test/*time_of_test*

As before modification of a repository, it is recommended to edit the hrc/hrc/CHANGELOG file

Links
------------------------

* Project main page: [http://colorer.sourceforge.net/](http://colorer.sourceforge.net/)
