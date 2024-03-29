#!/usr/bin/env bash

usage() {
    echo "
  Usage: ${0##*/} command [INSTANCE_NAME]
  Commands:
    add     [INSTANCE_NAME]:        Add configuration preset
    connect   INSTANCE_NAME:        Connect to AWS EC2 instance using InstanceID attached to INSTANCE_NAME using 'mssh'
    delete  [INSTANCE_NAME]:        Delete configuration presets for INSTANCE_ID
    start     INSTANCE_NAME:        Start AWS EC2 instance using InstanceID attached to INSTANCE_NAME using 'aws'
    stop      INSTANCE_NAME:        Stop AWS EC2 instance using InstanceID attached to INSTANCE_NAME using 'aws'
    reboot    INSTANCE_NAME:        Reboot AWS EC2 instance using InstanceID attached to INSTANCE_NAME using 'aws'
    terminate INSTANCE_NAME:        Terminate AWS EC2 instance using InstanceID attached to INSTANCE_NAME using 'aws'
    state     INSTANCE_NAME:        Return the Ec2 instance state attached to INSTANCE_NAME using 'aws'
    set-type  INSTANCE_NAME TYPE:   Set the Ec2 instance type attached to INSTANCE_NAME using 'aws'
    get-type  INSTANCE_NAME:        Return the Ec2 instance type attached to INSTANCE_NAME using 'aws'
    completion:                     Output bash completion script
    show:                           Show preset configuration
    init:                           Create config file '~/.config/${0##*/}.yaml' and check requirements: 
                                        grep, python3, python3-pip, mssh(ec2instanceconnectcli), mikefarah/yq
  Arguments:
    INSTANCE_NAME: EC2 instance name defined in the '~/.config/${0##*/}.yaml' file
  Options:
    -h, --help:   Print this message and exit
"

}

completion() {

echo "
__complete_mssh_c() {
  local instance_names prev
  declare -A command_names=(
  	[add]=1
	[connect]=1
	[delete]=1
	[start]=1
	[stop]=1
	[reboot]=1
	[terminate]=1
	[state]=1
	[set-type]=1
	[get-type]=1
	[completion]=1
	[show]=1
    [list]=1
	[init]=1
  )
  prev=\"\${COMP_WORDS[COMP_CWORD-1]}\"
  if [[ \${COMP_CWORD} -eq 1 ]]
  then
     mapfile -t COMPREPLY <<< \"\$(compgen -W \"\${!command_names[*]}\" -- \"\${COMP_WORDS[1]}\")\"
     return
  elif [[ \${COMP_CWORD} -eq 2 ]]
  then
    if ! [ \${command_names[\${prev}]} ] || [ \"\${prev}\" == 'add' ] || [ \"\${prev}\" == 'completion' ] || [ \"\${prev}\" == 'init' ] || [ \"\${prev}\" == 'list' ]
    then
        return
    fi
    mapfile -t instance_names <<<\"\$(yq '.configs | keys' \"\$HOME/.config/${0##*/}.yaml\"  | cut -d' ' -f2)\"
    mapfile -t COMPREPLY <<<\"\$(compgen -W \"\${instance_names[*]}\" -- \"\${COMP_WORDS[2]}\")\"
    return
  else
    return
  fi
}

if [[ \$(type -t compopt) = \"builtin\" ]]; then
    complete  -F __complete_mssh_c ${0##*/}
else
    complete  -o nospace -F __complete_mssh_c ${0##*/}
fi
"

}

init() {
    local error
    error=False

    if ! ( type grep &>/dev/null )
    then
        echo "Error: requirement 'grep (GNU grep)' is not available"
        error=True
    elif ! ( type python3 &>/dev/null )
    then
        echo "Error: requrement 'python3' is not available"
        error=True
    elif ! ( python3 -m pip -V &>/dev/null )
    then
        echo "Error: requirement 'pip for python3' is not available"
        error=True
    elif ! ( command -v yq &>/dev/null )
    then
      echo "Error: requirement 'mikefarah/yq' is not available"
    elif ! ( grep -F 'https://github.com/mikefarah/yq/' <<< "$(yq --version)" &>/dev/null )
    then
        echo "Error: requirement 'mikefarah/yq' is not available"
        error=True
    elif ! ( python3 -m pip show ec2instanceconnectcli &>/dev/null )
    then
        echo "Error: python package 'ec2instanceconnectcli' is not installed"
        error=True
    elif ! ( type mssh &>/dev/null )
    then
        echo "Error: requirement 'mssh' is not available"
        error=True
    elif ! ( grep -F 'from ec2instanceconnectcli' "$(command -v mssh)" &>/dev/null )
    then
        echo "Error: requirement 'mssh' is not an part of 'ec2instanceconnectcli' python3 package"
        error=True
    elif ! [ -x "$(command -v mssh)" ]
    then
        echo "Error: requirement 'mssh' does not have an execute permission on it"
        error=True
    fi

    if [ "${error}" == 'True' ]
    then
        exit 1
    fi

    if ! ( command -v aws &>/dev/null )
    then
        echo -e "\033[01;33m  Warning. Exectable 'aws' not fount. Commands delete,start,stop,reboot,terminate,state won't be available\033[00m"
    fi

    if ! [ -f "$HOME/.config/${0##*/}.yaml" ] || ! ( grep '^configs:' "$HOME/.config/${0##*/}.yaml" &>/dev/null )
    then
        mkdir -p "$HOME/.config/"
        echo 'configs: {}' > "$HOME/.config/${0##*/}.yaml"
        chmod 600 "$HOME/.config/${0##*/}.yaml"
        echo "Configuration file '$HOME/.config/${0##*/}.yaml' created."
    else
        echo "Valid configuration file '$HOME/.config/${0##*/}.yaml' exists"
        chmod 600 "$HOME/.config/${0##*/}.yaml"
    fi

}

show() {
    local answer
    if [ "${1}" ]
    then
        answer="$(yq ".configs.${1}" "$HOME/.config/${0##*/}.yaml")"
    else
        answer="$(yq ".configs" "$HOME/.config/${0##*/}.yaml")"
    fi

    if [ "${answer}" == 'null' ]
    then
        echo "Configuration for ${1} does not exist"
    else
        echo "${answer}" | yq
    fi

}


add() {
    if [ "${1}" ]
    then
        _name="${1}"
    else
        read -r -p "Input Name of the instance that you will use: " _name
    fi
    read -r -p 'Input EC2 InstanceID (required): ' _id
    if ! [ "${_id}" ]
    then
        echo "Error: InstanceID is not passed"
        exit 1
    elif ! ( echo "${_id}" | grep -E '^i-[a-f0-9]{17}' &>/dev/null )
    then
        echo "Error: ${_id} does not match pattern '^i-[a-f0-9]{17}', Example: i-0cc2f0c02f0ae1f34"
        exit 1
    fi
    read -r -p "Input AWS_PROFILE (optional): " _profile
    if ! [ "${_profile}" ]
    then
        read -r -s -p "Input AWS_ACCESS_KEY_ID (optional): " _access_key
    fi
    if [ "${_profile}" ] && ! ( grep '\[.*\]' "$HOME/.aws/config" | grep -F " ${_profile}]" &>/dev/null )
    then
        echo -e "\033[33mWarning: Profile ${_profile} does not exist in $HOME/.aws/config\033[00m"
    fi
    if ! [ "${_profile}" ] && ! [ "${_access_key}" ]
    then
        echo Error: None of AWS_PROFILE or AWS_ACCESS_KEY_ID provided
        exit 1
    fi
    if [ "${_access_key}" ]
    then
        read -r -s -p "Input AWS_SECRET_ACCESS_KEY (optional, required if AWS_ACCESS_KEY_ID provided): " _secret_key
    fi
    if [ "${_access_key}" ] && ! [ "${_secret_key}" ]
    then
        echo Error: AWS_SECRET_ACCESS_KEY is not provided
        exit 1
    fi
    read -r -p "Input AWS_REGION (optional). Default is us-east-1: " _region
    if ! [ "${_region}" ]
    then
        _region='us-east-1'
    fi
    read -r -p 'OS username (default: 'ec2-user') : ' _user
    if ! [ "${_user}" ]
    then
        _user='ec2-user'
    fi
    export ID="${_id}"
    export NAME="${_name}"
    yq eval -i ".configs.[env(NAME)].instance_id = env(ID)" "$HOME/.config/${0##*/}.yaml"
    if [ "${_profile}" ]
    then
        PROFILE="${_profile}" yq eval -i ".configs.[env(NAME)].profile = env(PROFILE)" "$HOME/.config/${0##*/}.yaml"
    fi
    if [ "${_access_key}" ] && [ "${_secret_key}" ]
    then
        KEY="${_access_key}" yq eval -i ".configs.[env(NAME)].access_key = env(KEY)" "$HOME/.config/${0##*/}.yaml"
        SECRET="${_secret_key}" yq eval -i ".configs.[env(NAME)].secret_key = env(SECRET)" "$HOME/.config/${0##*/}.yaml"
    fi
    REGION="${_region}" yq eval -i ".configs.[env(NAME)].region = env(REGION)" "$HOME/.config/${0##*/}.yaml"
    I_USER="${_user}" yq eval -i ".configs.[env(NAME)].user = env(I_USER)" "$HOME/.config/${0##*/}.yaml"

}

delete() {
    local _name
    if [ "${1}" ]
    then
        _name="${1}"
    else
        read -r -p 'Input EC2 InstanceID (required): ' _name
    fi
    NAME="${_name}" yq eval -i 'del(.configs.[env(NAME)])' "$HOME/.config/${0##*/}.yaml"

}

__do_work() {
    if ! ( command -v aws &>/dev/null )
    then
        echo -e "\033[01;31m  Error. Exectable 'aws' not fount\033[00m\n  Install from: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    if [ "${1}" ]
    then
        _name="${1}"
    else
        echo -e "\033[01;31No instance name specified\033[00m"
        exit 1
    fi

    export NAME="${_name}"
    name="$(yq '.configs.[env(NAME)]' "$HOME/.config/${0##*/}.yaml")"
    if ! [ "${name}" ]
    then
        echo -e "\n  Configuration preset for ${NAME} is missing.\n Try '${0##*/} add [NAME]' to configure.\n"
        exit 1
    fi
    _id="$(yq '.configs.[env(NAME)].instance_id' "$HOME/.config/${0##*/}.yaml")"
    _profile="$(yq '.configs.[env(NAME)].profile' "$HOME/.config/${0##*/}.yaml")"
    _access_key="$(yq '.configs.[env(NAME)].access_key' "$HOME/.config/${0##*/}.yaml")"
    _secret_key="$(yq '.configs.[env(NAME)].secret_key' "$HOME/.config/${0##*/}.yaml")"
    _region="$(yq '.configs.[env(NAME)].region' "$HOME/.config/${0##*/}.yaml")"
    shift
    if [ "${_profile}" ]
    then
        export AWS_PROFILE="${_profile}"
        aws ec2 "$@" "${INSTANCE_ARGUMENT}" "${_id}" --region "${_region}"
    else
        export AWS_ACCESS_KEY_ID="${_access_key}"
        export AWS_SECRET_ACCESS_KEY="${_secret_key}"
        aws ec2 "$@" "${INSTANCE_ARGUMENT}" "${_id}" --region "${_region}"
    fi
}

list() {
    yq '(.configs | keys)[]' "$HOME/.config/${0##*/}.yaml"
}

connect() {
    export NAME="${1}"
    CONFIG_NAME="$(yq '.configs.[env(NAME)]' "$HOME/.config/${0##*/}.yaml")"
    if [ "${CONFIG_NAME}" == 'null' ]
    then
        echo -e "\n  Configuration preset for ${NAME} is missing.\n Try '${0##*/} add [NAME]' to configure.\n"
        exit 1
    else
        _id="$(yq '.configs.[env(NAME)].instance_id' "$HOME/.config/${0##*/}.yaml")"
        _profile="$(yq '.configs.[env(NAME)].profile' "$HOME/.config/${0##*/}.yaml")"
        _access_key="$(yq '.configs.[env(NAME)].access_key' "$HOME/.config/${0##*/}.yaml")"
        _secret_key="$(yq '.configs.[env(NAME)].secret_key' "$HOME/.config/${0##*/}.yaml")"
        _region="$(yq '.configs.[env(NAME)].region' "$HOME/.config/${0##*/}.yaml")"
        _user="$(yq '.configs.[env(NAME)].user' "$HOME/.config/${0##*/}.yaml")"
        _connect_host="${_user}@${_id}"

        if [ "${_profile}" ]
        then
            export AWS_PROFILE="${_profile}"
            mssh "${_connect_host}" -r "${_region}"
        else
            export AWS_ACCESS_KEY_ID="${_access_key}"
            export AWS_SECRET_ACCESS_KEY="${_secret_key}"
            mssh "${_connect_host}" -r "${_region}"
        fi
    fi
}

__unset_aws() {
    unset AWS_PROFILE
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN

}


for i in "$@"
do
    if [ "${i}" == '-h' ] || [ "${i}" == '-help' ]
    then
        usage
        exit
    fi
done

INSTANCE_ARGUMENT='--instance-ids'

case "${1}" in
    add)
        add "${2}"
    ;;
    delete)
        delete "${2}"
    ;;
    start)
        __unset_aws
        __do_work "${2}" "start-instances"
    ;;
    stop)
        __unset_aws
        __do_work "${2}" "stop-instances"
    ;;
    reboot)
        __unset_aws
        __do_work "${2}" "reboot-instances"
    ;;
    terminate)
        __unset_aws
        __do_work "${2}" "terminate-instances"
    ;;
    get-type)
        __unset_aws
        __do_work "${2}" describe-instances --query "Reservations[*].Instances[*].InstanceType" --output text
    ;;
    set-type)
        INSTANCE_ARGUMENT='--instance-id'
        __unset_aws
        __do_work "${2}" modify-instance-attribute --instance-type "${3}"
    ;;
    state)
        __unset_aws
        __do_work "${2}" describe-instances --query "Reservations[*].Instances[*].[State.Name]" --output text
    ;;
    completion)
        completion
    ;;
    connect)
        __unset_aws
        connect "${2}"
    ;;
    show)
        show "${2}"
    ;;
    list)
        list
    ;;
    init)
        init
    ;;
    *)
        usage
        exit 1
    ;;
esac
