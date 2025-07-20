# Colorer Schemes

Welcome! This repository contains the core library of syntax highlighting schemes (syntaxes and styles) used by the [Colorer library](http://colorer.sourceforge.net/). It includes all the necessary files and scripts to build and test the scheme library.

[![Check Build Status](https://github.com/colorer/Colorer-schemes/actions/workflows/checks.yml/badge.svg)](https://github.com/colorer/Colorer-schemes/actions/workflows/checks.yml)


## Project Structure

This project has two main parts: `base` and `src`.

*   **`base/`**: This directory contains the pre-built, ready-to-use HRC and HRD files.
    *   **This is what 99% of users and contributors will work with.** If you want to fix a syntax or add a keyword, you should edit the files here.

*   **`src/`**: This directory contains the source files and scripts used to *generate* some of the schemes in `base`.
    *   Modifying these files is an advanced task, needed only when you want to change the generation logic itself, which is very rare.

*   **`tests/`**: Scripts for testing the scheme library.
  

## How to Build

First, clone the repository:
```sh
git clone https://github.com/colorer/Colorer-schemes.git
cd Colorer-schemes
```

There are two main build workflows.

### Simple Build (from `base`)

This is the standard build process that creates the final library from the files in the `base` directory. It does not require any special dependencies.

Run the build script with a specific target:
```sh
./build.sh <target>
```

**Available Targets:**

| Target                 | Description                                                                          | Output Directory       |
| ---------------------- | ------------------------------------------------------------------------------------ | ---------------------- |
| `base`                 | Builds the standard schema library.                                                  | `_build/base`          |
| `base.packed`          | Builds the library and packages HRC files into a `common.zip`. (Recommended)         | `_build/base-packed`   |
| `base.unpacked`        | Builds the library but leaves all HRC files unpacked.                                | `_build/base-unpacked` |
| `base.allpacked`       | Builds the library and packages *all* files into a single `catalog.zip`.             | `_build/base-allpacked`|
| `base.distr-packed`    | Creates a distributable archive of the `base.packed` build.                          | `_build/`              |
| `base.distr-unpacked`  | Creates a distributable archive of the `base.unpacked` build.                        | `_build/`              |
| `base.distr-allpacked` | Creates a distributable archive of the `base.allpacked` build.                       | `_build/`              |

### Full Rebuild (from `src`)

This workflow is only for advanced developers who need to regenerate schemes from the `src` directory.

**Prerequisites:**
*   Ant 1.8+
*   Java Development Kit (JDK) 8+
*   Perl

**Build Steps:**
1.  Navigate to the `src` directory: `cd src`
2.  Run the build script: `./build.sh <target>`
    *   The build targets are the same as listed above.
    *   The output will be located in the `src/build` directory.

#### Platform Notes

*   **Linux (Ubuntu 24.04 example):**
    ```sh
    sudo apt-get install ant
    ```
    If you have `APT::Install-Recommends "False";` in your apt configuration, you may also need to install `ant-optional`.

*   **Windows:**
    Ensure that your `PATH` environment variable includes the paths to your JDK and Ant `bin` directories. You also need to set the `JAVA_HOME` variable.
    ```cmd
    set JAVA_HOME=C:\path\to\your\jdk
    set PATH=%JAVA_HOME%\bin;C:\path\to\your\ant\bin;%PATH%
    ```

## How to Contribute

We welcome contributions! The development process depends on what you want to change.

### Workflow for Modifying Existing Schemes (99% of cases)

This is the standard workflow for fixing highlighting or adding keywords.

1.  **Edit Files:** Make your changes directly to the scheme files located in the `base/hrc` directory.
2.  **Rebuild the Library:** Run a simple build to apply your changes.
    ```sh
    ./build.sh base
    ```
3.  **Run Tests:** Make sure the `colorer` command-line utility is available in the `bin/` directory and run the regression tests.
    ```sh
    ./build.sh test.parse
    ```
4.  **Analyze Results:** The script will check for differences against reference files. Any failures will be printed to the console and detailed in a `fails.html` file inside a new `_test/<timestamp>/` directory.
5.  **Update or Fix:**
    *   If the test reveals a mistake in your scheme, go back to step 1 and fix it.
    *   If your changes are correct and the test failed because the *reference file* is outdated, replace the old reference file with your new result.
        *   Reference files are in: `tests/_valid/`
        *   Your new output files are in: `_test/<timestamp>/result/`

### Workflow for Modifying Generated Schemes (Advanced)

This is only necessary if you are changing the file generation logic.

1.  **Edit `src`:** Make your changes to the files and scripts in the `src` directory.
2.  **Build from `src`:** Go to the `src` folder and run a build.
    ```sh
    cd src
    ./build.sh base
    ```
3.  **Copy to `base`:** Copy the newly generated files from `src/build/` over to the `base/` directory, replacing the old ones.
4.  **Test:** Return to the root directory (`cd ..`) and follow steps 3-5 from the standard workflow above to test your changes.

### Final Step

Before submitting your changes, please add a summary of your work to the `CHANGELOG` file.

## Links

*   **Project Main Page:** [http://colorer.sourceforge.net/](http://colorer.sourceforge.net/)
*   **Project New site:** [https://colorer.github.io](https://colorer.github.io)


## License

This project is licensed under the terms of the **GNU Lesser General Public License v2.1**.
A copy of the license is available in the `LICENSE` file in the root of the repository.
