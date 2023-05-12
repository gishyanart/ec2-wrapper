# Description

Wrapper script on [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [mssh(c2instanceconnectcli)](https://pypi.org/project/ec2instanceconnectcli/) to easily manage EC2 instances using IAM permissions with configuration preset.

## Requirements

- [bash](https://www.gnu.org/software/bash/) as shell
- [GNU grep](https://www.gnu.org/software/grep/manual/grep.html)
- [python3](https://www.python.org/)
- [python3-pip](https://github.com/pypa/pip)
- [mssh (ec2instanceconnectcli)](https://pypi.org/project/ec2instanceconnectcli/)
- [mikefarah/yq](https://github.com/mikefarah/yq)
- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (optional)

## Installation

Clone the repo

```bash
git clone https://github.com/gishyanart/ec2-wrapper
cd ec2-wrapper
```

Make `ec2` executable and put somewhere in the `$PATH`

```bash
export SCRIPT_NAME=ec2.sh # Or any name you prefer
cp ec2.sh ~/.local/bin/"${SCRIPT_NAME}"
chmod +x ~/.local/bin/"${SCRIPT_NAME}"
exec bash --login
```

### To enable autocompletion, run

#### With `~/.bashrc`

```bash
echo "source <(${SCRIPT_NAME} completion)" >> ~/.bashrc
exec bash
```

#### With `bash-completion`

```bash
${SCRIPT_NAME} completion | sudo tee /usr/share/bash-completion/completions/"${SCRIPT_NAME}"
```

## Usage

```bash
  Usage: ec2.sh command [INSTANCE_NAME]
  Commands:
    ec2.sh add     [INSTANCE_NAME]:        Add configuration preset
    ec2.sh connect   INSTANCE_NAME:        Connect to AWS EC2 instance using InstanceID attached to INSTANCE_NAME in ~/.config/ec2.sh.yaml using 'mssh'
    ec2.sh delete  [INSTANCE_NAME]:        Delete configuration presets for INSTANCE_ID
    ec2.sh start     INSTANCE_NAME:        Start AWS EC2 instance using InstanceID attached to INSTANCE_NAME in ~/.config/ec2.sh.yaml using 'aws'
    ec2.sh stop      INSTANCE_NAME:        Stop AWS EC2 instance using InstanceID attached to INSTANCE_NAME in ~/.config/ec2.sh.yaml using 'aws'
    ec2.sh reboot    INSTANCE_NAME:        Reboot AWS EC2 instance using InstanceID attached to INSTANCE_NAME in ~/.config/ec2.sh.yaml using 'aws'
    ec2.sh terminate INSTANCE_NAME:        Terminate AWS EC2 instance using InstanceID attached to INSTANCE_NAME in ~/.config/ec2.sh.yaml using 'aws'
    ec2.sh state     INSTANCE_NAME:        Return the Ec2 instance state attached to INSTANCE_NAME using 'aws'
    ec2.sh set-type  INSTANCE_NAME TYPE:   Set the Ec2 instance type attached to INSTANCE_NAME using 'aws'
    ec2.sh get-type  INSTANCE_NAME:        Return the Ec2 instance type attached to INSTANCE_NAME using 'aws'
    ec2.sh completion:                     Output bash completion script
    ec2.sh show:                           Show preset configuration
    ec2.sh init:                           Create config file in ~/.config and check requirements: grep, python3, python3-pip, mssh(ec2instanceconnectcli), mikefarah/yq
  Arguments:
    INSTANCE_NAME: EC2 instance name defined in the '~/.config/ec2.sh.yaml' file
  Options:
    -h, --help:   Print this message and exit
```
