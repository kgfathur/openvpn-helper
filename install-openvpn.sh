#!/bin/bash

work_dir=$(pwd)

if [[ "$EUID" -ne 0 ]]; then
	echo "This installer needs to be run with superuser privileges."
	exit
fi


function yesno()
{
    local ans
    local ok=0
    local timeout=0
    local default
    local t

    while [[ "$1" ]]
    do
        case "$1" in
        --default)
            shift
            default=$1
            if [[ ! "$default" ]]; then error "Missing default value"; fi
            t=$(tr '[:upper:]' '[:lower:]' <<<$default)

            if [[ "$t" != 'y'  &&  "$t" != 'yes'  &&  "$t" != 'n'  &&  "$t" != 'no' ]]; then
                error "Illegal default answer: $default"
            fi
            default=$t
            shift
            ;;

        --timeout)
            shift
            timeout=$1
            if [[ ! "$timeout" ]]; then error "Missing timeout value"; fi
            if [[ ! "$timeout" =~ ^[0-9][0-9]*$ ]]; then error "Illegal timeout value: $timeout"; fi
            shift
            ;;

        -*)
            error "Unrecognized option: $1"
            ;;

        *)
            break
            ;;
        esac
    done

    if [[ $timeout -ne 0  &&  ! "$default" ]]; then
        error "Non-zero timeout requires a default answer"
    fi

    if [[ ! "$*" ]]; then error "Missing question"; fi

    while [[ $ok -eq 0 ]]
    do
        if [[ $timeout -ne 0 ]]; then
            if ! read -t $timeout -p "$*" ans; then
                ans=$default
            else
                # Turn off timeout if answer entered.
                timeout=0
                if [[ ! "$ans" ]]; then ans=$default; fi
            fi
        else
            read -p "$*" ans
            if [[ ! "$ans" ]]; then
                ans=$default
            else
                ans=$(tr '[:upper:]' '[:lower:]' <<<$ans)
            fi 
        fi

        if [[ "$ans" == 'y'  ||  "$ans" == 'yes'  ||  "$ans" == 'n'  ||  "$ans" == 'no' ]]; then
            ok=1
        fi

        if [[ $ok -eq 0 ]]; then warning "Valid answers are: Y|YES|Yes|yes|y N|NO|No|no|n"; fi
    done
    [[ "$ans" = "y" || "$ans" == "yes" ]]
}

install_dir="/opt/openvpn-setup"
if [ ! -d $install_dir ]; the
    mkdir $install_dir
else
    echo "$install_dir already exist!"
fi

if [ -f $install_dir/openvpn-setup ]; then
    if yesno --default No "$install_dir/openvpn-setup already exist! Overwrite? ";then    
        cp $work_dir/openvpn-setup $install_dir/
        chmod u+x $install_dir/openvpn-setup
    fi
fi

echo "Install update-alternatives..."
update-alternatives --install /usr/bin/openvpn-setup openvpn-setup /opt/openvpn-setup/openvpn-setup 0

echo ""
echo "Testing symlink..."
which openvpn-setup

echo ""