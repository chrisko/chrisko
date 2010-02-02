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

# Try to verify that we're running in an affiliate source directory, otherwise
# we have nothing to build. Accomplish this by looking for a ChangeLog.
NEED_AFFIL_SRCDIR="Error: $COMMAND_NAME working directory \"`pwd`\" does not \
                   seem to contain the affiliate perl source. Cannot build."
[[ ! -e "search/ss/server/ChangeLog" ]] && { echo $NEED_AFFIL_SRCDIR; exit 1; }

# We obviously need to have yinst available:
yinst version &> /dev/null
[[ $? -ne 0 ]] && { echo "$COMMAND_NAME failed to execute yinst."; exit 1; }

#IS_POPTECL_CODEBASE=

# Now we'll make sure yahoo_cfg_dev (including yinst_create) is installed:
yinst ls yahoo_cfg_dev
if [[ $? -ne 0 ]]; then
    echo "Cannot find yahoo_cfg_dev. Installing from stable branch..."
    # This particular version is required by the build package:
    sudo yinst install yahoo_cfg_dev-2.8.14
    [[ $? -ne 0 ]] && { echo "Install of yahoo_cfg_dev failed."; exit 1; }
fi

BUILD_SUFFIX=""
if [[ `grep search/ss/server/ChangeLog.poptecl 'Version 2.61.0.0.0.5' | wc -l` -ne 0 ]]; then
    # The affiliate trunk branch only has a single older Version, and not this one.
    # We're assuming that this is the poptecl code, based on this. Kind of iffy...
    BUILD_SUFFIX="-s poptecl"
fi

yinst install -br test skeletor-stable over_glib-stable

(cd search/ss/server && ./build -t $BUILD_TYPE $BUILD_SUFFIX)
