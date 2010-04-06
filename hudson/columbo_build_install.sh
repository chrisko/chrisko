# For my purposes, this script will always run within the safety of a yroot.
# Since it might clobber the yinst environment a bit, I want to run this check.
if [[ -z "$YROOT_NAME" ]]; then
    echo "As a precaution, $COMMAND_NAME will not run outside of a yroot."
    exit 1
fi

yinst install yinst_create
[[ $? -ne 0 ]] && { echo "Failure installing yinst_create."; exit 1; }

(cd ~/src/columbo/pkg && rm ./*.tgz &> /dev/null)
(cd ~/src/columbo/pkg && yinst_create ./yellowstone_columbo_perl.yicf)
[[ $? -ne 0 ]] && { echo "Failure running yinst_create."; exit 1; }

(cd ~/src/columbo/pkg && yinst install -br test ./yellowstone_columbo_perl-*.tgz)
[[ $? -ne 0 ]] && { echo "Failure running yinst install."; exit 1; }
