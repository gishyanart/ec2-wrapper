# Description

AWS provides `mssh` command ([ec2instanceconnectcli](https://pypi.org/project/ec2instanceconnectcli/)) to easily connect EC2 instances using IAM permissions. By itself it doesn't provide configuration. This script is a wrapper on `mssh` that allows:

- creation of configuration presets for instances and using them to easily connect after
- start/stop instances

## Requirements

- [bash](https://www.gnu.org/software/bash/) as shell
- [GNU grep](https://www.gnu.org/software/grep/manual/grep.html)
- [python3](https://www.python.org/)
- [python3-pip](https://github.com/pypa/pip)
- [mssh (ec2instanceconnectcli)](https://pypi.org/project/ec2instanceconnectcli/)
- [mikefarah/yq](https://github.com/mikefarah/yq)

## Installation

Make `mssh_c` executable and put somewhere in the `$PATH`

```bash
chmod +x ./mssh_c
cp mssh_c ~/.local/bin/
```

To enable autocompletion, run:

```bash
# Put it on .bashrc
echo 'source <(mssh_c completion)' >> ~/.bashrc
```

or, if you have `bash-completion` installed, put it in the file of `bash-completion` directory:

### For `pacman` distros

```bash
mssh_c completion | sudo tee /usr/share/bash-completion/completions/mssh_c
```

### For `deb` distros

```bash
mssh_c completion | sudo tee /etc/bash_completion.d/mssh_c
```

### For `rpm` distros

```bash
mssh_c completion | sudo tee /usr/share/bash-completion/mssh_c
```
