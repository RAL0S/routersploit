#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${RALPM_TMP_DIR}" ]]; then
    echo "RALPM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
    echo "RALPM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
    echo "RALPM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.9.13+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -O $RALPM_TMP_DIR/cpython-3.9.13.tar.gz
  tar xf $RALPM_TMP_DIR/cpython-3.9.13.tar.gz -C $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/cpython-3.9.13.tar.gz

  wget https://github.com/threat9/routersploit/archive/3fd394637f5566c4cf6369eecae08c4d27f93cda.tar.gz -O $RALPM_TMP_DIR/routersploit.tar.gz
  tar xf $RALPM_TMP_DIR/routersploit.tar.gz -C $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/routersploit.tar.gz
  mv $RALPM_PKG_INSTALL_DIR/routersploit-3fd394637f5566c4cf6369eecae08c4d27f93cda $RALPM_PKG_INSTALL_DIR/routersploit

  $RALPM_PKG_INSTALL_DIR/python/bin/pip3.9 install -r $RALPM_PKG_INSTALL_DIR/routersploit/requirements.txt
  (cd $RALPM_PKG_INSTALL_DIR/routersploit && $RALPM_PKG_INSTALL_DIR/python/bin/python3.9 setup.py install)

  ln -s $RALPM_PKG_INSTALL_DIR/python/bin/rsf.py $RALPM_PKG_BIN_DIR/
  echo "This package adds the command rsf.py"
}

uninstall() {
  rm -rf $RALPM_PKG_BIN_DIR/python
  rm -rf $RALPM_PKG_BIN_DIR/routersploit
  rm $RALPM_PKG_BIN_DIR/rsf.py
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1