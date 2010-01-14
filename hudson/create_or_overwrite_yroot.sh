#!/bin/sh

# Given the name of a yroot (plus any addition command-line arguments to give
# to "yroot --create", like "--i386" or "4.8-20090518"), this will remove any
# existing yroot of that name, and create it anew.

# Read and remove the name of the executable:
CMD_NAME=`basename $0`;
USAGE="usage: $CMD_NAME <yroot_name> [<yroot_arguments>]"

# Check for a help argument, in short or long form:
[[ "$1" = "-h" ]] && { echo $USAGE; exit 0; }
[[ "$1" = "--help" ]] && { echo $USAGE; exit 0; }

# Pop off the first argument, which should be the name of the new yroot:
NEW_YROOT_NAME=$1; shift 1;
[[ -z "$NEW_YROOT_NAME" ]] && { echo $USAGE; exit 1; }

# Make sure we ourselves are not in a yroot, otherwise fail immediately.
# (This YROOT_NAME environment variable is set by yroot itself.)
if [[ ! -z "$YROOT_NAME" ]]; then
    echo "$CMD_NAME seems to be running within a yroot, $YROOT_NAME. Failing."
    exit 1;
fi

# Check that the yroot executable is accessible:
yroot --list &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "Failed to find yroot in your PATH. Please yinst install yroot."
    exit 1;
fi

# If a yroot by this name already exists, remove it, so we can start fresh.
if [[ `yroot --list | grep -P "^\s*$NEW_YROOT_NAME\s+" | wc -l` -eq 1 ]]; then
    echo "Found existing yroot at $NEW_YROOT_NAME. Removing."
    sudo yroot --remove $NEW_YROOT_NAME
    [[ $? -ne 0 ]] && { echo "yroot --remove failed. Exiting $CMD_NAME."; exit 1; }
fi

# Finally, create the yroot, passing in any remaining command-line arguments:
YROOT_COMMAND="sudo yroot --create --nosudoers $NEW_YROOT_NAME $@"
echo "Executing \"$YROOT_COMMAND\"..."
$YROOT_COMMAND
[[ $? -ne 0 ]] && { echo "yroot --create failed. Exiting $CMD_NAME."; exit 1; }

echo "Creation of yroot $NEW_YROOT_NAME succeeded."
