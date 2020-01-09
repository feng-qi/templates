#!/bin/bash


set -e                          # exit on error

clone_repo_if_not_exist() {
    local source=$1
    local to_clone=$2
    shift 2
    if [ -e "${to_clone}" ]; then
        echo -e "${WARN} ${COLR_GREEN}${to_clone}${COLR_NC} already cloned! Skipped!"
    else
        git clone $@ "${source}" "${to_clone}"
    fi
}



mkdir -p $HOME/repos

clone_repo_if_not_exist http://gerrit.mirror.cn.oss.arm.com/enterprise-llt/jdk/jdk $HOME/repos/jdk
clone_repo_if_not_exist http://gerrit.mirror.cn.oss.arm.com/enterprise-llt/jdk/panama $HOME/repos/panama

cd $HOME
clone_repo_if_not_exist https://github.com/feng-qi/spacemacs.d $HOME/.spacemacs.d
clone_repo_if_not_exist https://github.com/syl20bnr/spacemacs $HOME/.emacs.d --depth=1 -b develop
clone_repo_if_not_exist https://github.com/feng-qi/dotfiles $HOME/dotfiles
bash -i $HOME/dotfiles/install.sh link

mkdir -p $HOME/github
clone_repo_if_not_exist git@github.com:feng-qi/notes.git $HOME/github/notes
clone_repo_if_not_exist git@github.com:feng-qi/templates.git $HOME/github/templates


sudo apt-get install -y jq silversearcher-ag tree tmux emacs25
sudo apt-get install -y \
     libx11-dev libxext-dev libxrender-dev libxrandr-dev libxtst-dev libxt-dev \
     libcups2-dev libfontconfig1-dev libasound2-dev
