Colorer schemes
========================
The library of schemes is a basic set of descriptions of syntaxes and styles of the coloring, used by Colorer library.
The project contains files and scripts for creation of library of schemes.

Structure
------------------------

  * hrc - basic set of descriptions of syntaxes (hrc-files) and their generators
  * hrd - basic set of styles of a coloring (hrd-files), their generators and additions
  * shared - shared colorer xml schemes
  * javalib - required java libs
  
How to build from source
------------------------

###Common###

For build the library of schemes must

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

###Features of build under Windows###

Before starting the build scripts, make sure that the PATH environment variable contains the path to the jdk and ant.
The same must be set the environment variable *JAVA_HOME*.

    set PATH=v:\apps\jdk\bin;v:\apps\ant\bin;%PATH%
    set JAVA_HOME=v:\apps\jdk

###Features of build under Linux###

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

Links
------------------------

* Project main page: [http://colorer.sourceforge.net/](http://colorer.sourceforge.net/)
