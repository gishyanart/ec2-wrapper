# Description

Wrapper script on [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [msshe(c2instanceconnectcli)](https://pypi.org/project/ec2instanceconnectcli/) to easily manage EC2 instances using IAM permissions with configuration preset.

## Requirements

- [bash](https://www.gnu.org/software/bash/) as shell
- [GNU grep](https://www.gnu.org/software/grep/manual/grep.html)
- [python3](https://www.python.org/)
- [python3-pip](https://github.com/pypa/pip)
- [mssh (ec2instanceconnectcli)](https://pypi.org/project/ec2instanceconnectcli/)
- [mikefarah/yq](https://github.com/mikefarah/yq)

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
bash --login
```

### To enable autocompletion, run

#### With `~/.bashrc`

```bash
echo "source <(${SCRIPT_NAME} completion)" >> ~/.bashrc
bash
```

#### With `bash-completion`

```bash
${SCRIPT_NAME} completion | sudo tee /usr/share/bash-completion/completions/"${SCRIPT_NAME}"
```
