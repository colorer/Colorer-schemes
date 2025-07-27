#!/bin/bash

BUILD_DIR="_build"
TEST_DIR="_test"
BASE_BUILD_DIR="${BUILD_DIR}/base"

build_base() {
    
    local dest_dir=${CUR_DIR}/${BASE_BUILD_DIR}
    mkdir -p ${dest_dir}

    cd ${CUR_DIR}/base/hrc && find . -type f ! -name 'readme.md' | cpio -pdmu --quiet ${dest_dir}/hrc
    cd ${CUR_DIR}/base/hrd && find . -type f ! -name 'readme.md' | cpio -pdmu --quiet ${dest_dir}/hrd
    cp ${CUR_DIR}/base/catalog.base.xml ${dest_dir}/catalog.xml
    
    cd ${CUR_DIR}

    echo "Base schemes successfully created on '$dest_dir'."
}

build_unpacked() {

    if [ $# -ne 1 ]; then
        build_base
    fi

    local dest_dir=${CUR_DIR}/${BUILD_DIR}/base-unpacked
    mkdir -p ${dest_dir}

    cp -R ${CUR_DIR}/${BASE_BUILD_DIR}/* ${dest_dir}
    cp ${CUR_DIR}/CHANGELOG.md ${dest_dir}

    cd ${CUR_DIR}

    echo "Base-unpacked schemes successfully created on '$dest_dir'."
}

build_allpacked() {

    if [ $# -ne 1 ]; then
        build_base
    fi

    local dest_dir=${CUR_DIR}/${BUILD_DIR}/base-allpacked
    mkdir -p ${dest_dir}

    cd ${BASE_BUILD_DIR}/
    zip -rq ${dest_dir}/common.zip ./hrc ./hrd
    cd ${CUR_DIR}
    cp ${CUR_DIR}/base/catalog.allpacked.xml ${dest_dir}/catalog.xml
    cp ${CUR_DIR}/CHANGELOG.md ${dest_dir}
    cp -R ${CUR_DIR}/base/hrc/auto ${dest_dir}

    cd ${CUR_DIR}

    echo "Base-allpacked schemes successfully created on '$dest_dir'."
}

build_packed() {

    if [ $# -ne 1 ]; then
        build_base
    fi

    local dest_dir=${CUR_DIR}/${BUILD_DIR}/base-packed
    mkdir -p ${dest_dir}
    mkdir -p ${dest_dir}/hrc

    cd ${BASE_BUILD_DIR}/hrc
    zip -rq ${dest_dir}/hrc/common.zip base db inet lib misc rare scripts xml
   
    cd ${CUR_DIR}
    cp ${CUR_DIR}/base/hrc/*.hrc ${dest_dir}/hrc
    find ${dest_dir}/hrc -maxdepth 1 -type f -name "*.hrc" -exec sed -i 's/link="/link="jar:common.zip!/g' {} +
    cp -R ${CUR_DIR}/base/hrc/auto ${dest_dir}/hrc
    cp -R ${CUR_DIR}/base/hrd ${dest_dir}
    cp ${CUR_DIR}/CHANGELOG.md ${dest_dir}
    cp ${CUR_DIR}/base/catalog.base.xml ${dest_dir}/catalog.xml

    cd ${CUR_DIR}

    echo "Base-packed schemes successfully created on '$dest_dir'."
}

zip_distr() {
    local type="$1"
    local postfix="$2"
    local archive_name="${CUR_DIR}/${BUILD_DIR}/colorer-base.${type}.${postfix}.zip"

    cd ${CUR_DIR}/${BUILD_DIR}/base-${type}
    zip -rq ${archive_name} .

    echo "Distributive for '$type' successfully archived to '$archive_name'."
}

# --- Main part of the script ---

# Check the number of arguments passed
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <action>"
    echo "Actions: 'base', 'base.unpacked', 'base.allpacked', 'base.packed', 'base.distr-unpacked', 'base.distr-packed', 'base.distr-allpacked', "
    echo " 'base.distr-all', 'clean', 'test.load', 'test.parse', 'test.clean'"
    exit 1
fi

CUR_DIR="${PWD}"
ACTION=$1

# Select action based on the input parameter
case "$ACTION" in
    base)
        build_base
        ;;
    base.unpacked)
        build_unpacked
        ;;
    base.packed)
        build_packed
        ;;
    base.allpacked)
        build_allpacked
        ;;
    base.distr-unpacked)
        build_unpacked
        zip_distr unpacked "$2"
        ;;
    base.distr-packed)
        build_packed
        zip_distr packed "$2"
        ;;
    base.distr-allpacked)
        build_allpacked
        zip_distr allpacked "$2"
        ;;
    base.distr-all)
        build_base
        build_unpacked 1
        build_packed 1
        build_allpacked 1
        zip_distr unpacked "$2"
        zip_distr packed "$2"
        zip_distr allpacked "$2"
        ;;
    base.unpacked.clean)
        rm -rf ${CUR_DIR}/${BUILD_DIR}/base-unpacked
        ;;
    base.packed.clean)
        rm -rf ${CUR_DIR}/${BUILD_DIR}/base-packed
        ;;
    base.allpacked.clean)
        rm -rf ${CUR_DIR}/${BUILD_DIR}/base-allpacked
        ;;
    clean)
        rm -rf ${CUR_DIR}/${BUILD_DIR}
        ;;
    test.load)
        ./tests/test_load/test_fullload.sh $2
        ;;
    test.parse)
        python3 ./tests/test/runtest.py $2
        if [ $? -eq 0 ]; then
            echo "✅ Success."
        else
            echo "❌ Error: the result of the parsing does not match the expected. Please fix it."
            exit 1
        fi
        ;;
    test.clean)
        rm -rf ${CUR_DIR}/${TEST_DIR}
        ;;
    *)
        echo "Error: Invalid action '$ACTION'."
        exit 1
        ;;
esac

# $? contains the exit code of the last executed command (our function in this case).
# If the function returned an error (return 1), the script will also exit with an error.
exit $?