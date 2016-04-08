################################################################################
#
#      Author: Zachary Patten <zpatten AT jovelabs DOT io>
#   Copyright: Copyright (c) Zachary Patten
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################
#!/bin/bash -eux

sudo apt-get -qy update

ssh -V
cat /etc/ssh/sshd_config
ls -la $HOME

eval `ssh-agent -s`
ssh-add -L

mkdir -p $HOME/.ssh
ssh-keygen -N '' -f $HOME/.ssh/id_rsa

ls -la $HOME/.ssh

cat $HOME/.ssh/id_rsa.pub | tee $HOME/.ssh/authorized_keys
cat $HOME/.ssh/id_rsa.pub | tee $HOME/.ssh/authorized_keys2

ssh-add $HOME/.ssh/id_rsa
ssh-add -L

ps aux | grep -i [s]sh

sudo iptables --list -v
