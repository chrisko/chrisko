#!/bin/sh

COMMAND_NAME=`basename $0`
USAGE="$COMMAND_NAME [test|release]"
BUILD_TYPE=$1; [[ -z "$BUILD_TYPE" ]] && BUILD_TYPE="test"
if [[ "$BUILD_TYPE" != "test" && "$BUILD_TYPE" != "release" ]]; then
    echo "Invalid build type \"$BUILD_TYPE\"; must be \"test\" or \"release\"."
    exit 1
fi

################################################################################
## Verifying the Environment ###################################################
################################################################################
# For my purposes, this script will always run within the safety of a yroot.
# Since it might clobber the yinst environment a bit, I want to run this check.
if [[ -z "$YROOT_NAME" ]]; then
    echo "As a precaution, $COMMAND_NAME will not run outside of a yroot."
    exit 1
fi

# Try to verify that we're running in a YSFE source directory, otherwise we
# have nothing to build. Accomplish this by looking for a ChangeLog, and in
# particular grepping for a phrase from the first YSFE commit.
NEED_YSFE_SRCDIR="Error: $COMMAND_NAME working directory \"`pwd`\" does not \
                  seem to contain the YSFE source. Cannot build."
[[ ! -e "ChangeLog" ]] && { echo $NEED_YSFE_SRCDIR; exit 1; }
if [[ `grep "First functional fragmentary" ChangeLog | wc -l` -ne 1 ]]; then
    echo $NEED_YSFE_SRCDIR; exit 1;
fi

# We obviously need to have yinst available:
yinst version &> /dev/null
[[ $? -ne 0 ]] && { echo "$COMMAND_NAME failed to execute yinst."; exit 1; }

# Now we'll make sure yahoo_cfg_dev (including yinst_create) is installed:
yinst ls yahoo_cfg_dev
if [[ $? -ne 0 ]]; then
    echo "Cannot find yahoo_cfg_dev. Installing version 2.8.14..."
    # This particular version is required by the build package:
    sudo yinst install yahoo_cfg_dev-2.8.14 perlbase perl58_compat
    [[ $? -ne 0 ]] && { echo "Install of yahoo_cfg_dev failed."; exit 1; }
fi

################################################################################
## Building and Installing the YSFE Build Package ##############################
################################################################################
# Now, let's create the YSFE build package from the yicf, and install it:
echo "Creating the YSFE build package from its yicf..."
rm pkg/ysfe_build-*.tgz &> /dev/null
(cd pkg && yinst_create --clean -t $BUILD_TYPE ysfe_build.yicf)
if [[ `ls pkg/ysfe_build-*.tgz | wc -l` -eq 0 ]]; then
    echo "Failed to create ysfe_build package."; exit 1;
fi

echo "Installing newly-built YSFE build package..."
sudo yinst install -br test pkg/ysfe_build-*.tgz
[[ $? -ne 0 ]] && { echo "Install of build package failed."; exit 1; }

################################################################################
## Building the YSFE Source ####################################################
################################################################################
# Things seem ready, so let's run the build:
echo "Building the YSFE source..."
(cd src && make)
[[ $? -ne 0 ]] && { echo "YSFE source build failed."; exit 1; }

# That went well, so let's make the unit tests:
echo "Building the YSFE unit tests..."
(cd tests && make)
[[ $? -ne 0 ]] && { echo "Build of the YSFE unit tests failed."; exit 1; }

# Now let's try executing the tools directory build:
echo "Building the YSFE tools..."
(cd tools && make)
[[ $? -ne 0 ]] && { echo "Build of the YSFE tools failed."; exit 1; }

################################################################################
## Running the Unit Tests and Building the Documentation #######################
################################################################################
echo "Building the YSFE HTML documentation pages..."
rm -rf doc/html &> /dev/null
make documentation
if [[ ! -d doc/html ]]; then
    echo "Failed to generate YSFE documentation."; exit 1;
fi

echo "Executing YSFE unit tests..."
rm -f tests/test_results.xml &> /dev/null
(cd tests && ./testCommonRunner xml)
if [[ ! -e tests/test_results.xml ]]; then
    echo "Failed to generate test output."; exit 1;
fi

################################################################################
## Installation and Packaging ##################################################
################################################################################
# Clears any older yicfs already generated, plus their derived packages:
(cd pkg && make clean &> /dev/null)

# Build and install both the YSFE server package, ysfe, and the YSFE config
# package, ysfe_conf. This is important to do here because other packages (the
# metapackages) will depend on their being installed (since their version
# numbers are referenced via "ROOT ROOT_MAX").
echo "Creating the YSFE server package..."
rm -rf pkg/ysfe-*.tgz &> /dev/null
(cd pkg && yinst_create -t $BUILD_TYPE ysfe.yicf)
[[ $? -ne 0 ]] && { echo "Failed to create YSFE server package."; exit 1; }
echo "Server package created, installing..."
sudo yinst install -br test pkg/ysfe-*.tgz
[[ $? -ne 0 ]] && { echo "Failed to install YSFE server package."; exit 1; }

echo "Creating the YSFE config package..."
rm -rf pkg/ysfe_conf-*.tgz &> /dev/null
(cd pkg && yinst_create -t $BUILD_TYPE ysfe_conf.yicf)
[[ $? -ne 0 ]] && { echo "Failed to create YSFE config package."; exit 1; }
echo "Conf package created, installing..."
sudo yinst install -br test pkg/ysfe_conf-*.tgz
[[ $? -ne 0 ]] && { echo "Failed to install YSFE config package."; exit 1; }

# Now we can build all the conf and meta package yicfs using the pkg/ perl
# scripts, and from the yicfs we'll build the packages themselves.
echo "Creating YSFE dev package yicfs via the gen_dev target..."
(cd pkg && make gen_dev)
[[ $? -ne 0 ]] && { echo "Failed to generate dev yicfs."; exit 1; }
echo "Building YSFE $BUILD_TYPE packages..."
(cd pkg && make package-$BUILD_TYPE)
[[ $? -ne 0 ]] && { echo "Problem building packages."; exit 1; }
# Remove the new build/server/conf packages, in favor of the existing ones:
(cd pkg && rm `ls -t ysfe-*.tgz | head -1`)
(cd pkg && rm `ls -t ysfe_build-*.tgz | head -1`)
(cd pkg && rm `ls -t ysfe_conf-*.tgz | head -1`)
echo "Generating and building YSFE flattened strict metapackage..."
(cd pkg && make flat_strict_meta_yicf)
[[ $? -ne 0 ]] && { echo "Problem building flat strict meta yicf."; exit 1; }
(cd pkg && yinst_create -t $BUILD_TYPE ysfe_flat_strict_meta.yicf)
[[ $? -ne 0 ]] && { echo "Problem building flat strict metapackage."; exit 1; }

# Don't forget to build the tools/ source, as well.
#echo "Building YSFE tools source..."
#(cd tools && make)
#[[ $? -ne 0 ]] && { echo "Failed to build tools source."; exit 1; }

echo "Success! YSFE built successfully."
