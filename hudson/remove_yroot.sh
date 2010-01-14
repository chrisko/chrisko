#!/bin/sh

# Given the name of a yroot, this will wrap a "yroot --remove" command.

# Read and remove the name of the executable:
CMD_NAME=`basename $0`;
USAGE="usage: $CMD_NAME <yroot_name>"

# Check for a help argument, in short or long form:
[[ "$1" = "-h" ]] && { echo $USAGE; exit 0; }
[[ "$1" = "--help" ]] && { echo $USAGE; exit 0; }

# Pop off the first argument, which should be the name of the new yroot:
CONDEMNED_YROOT=$1;
[[ -z "$CONDEMNED_YROOT" ]] && { echo $USAGE; exit 1; }

if [[ ! -z "$2" ]]; then
    echo "Unknown additional command-line options to $CMD_NAME."
    echo $USAGE; exit 1;
fi

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

# If a yroot of this name doesn't exist, note and exit.
if [[ `yroot --list | grep -P "^\s*$CONDEMNED_YROOT\s+" | wc -l` -eq 0 ]]; then
    yroot --list
    echo "No yroot named $CONDEMNED_YROOT. Exiting successfully."
    exit 0;
fi

REMOVAL_COMMAND="sudo yroot --remove $CONDEMNED_YROOT"
echo "Executing \"$REMOVAL_COMMAND\"..."
$REMOVAL_COMMAND
[[ $? -ne 0 ]] && { echo "yroot --remove failed. Exiting $CMD_NAME."; exit 1; }
echo "Removal of yroot $CONDEMNED_YROOT succeeded."
