#!/bin/bash
# Copyright (c) 2013 The Native Client Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

source pkg_info
source ../../../build_tools/common.sh

export EXTRA_LIBS="-ltar -lppapi_simple -lnacl_io -lppapi -lppapi_cpp"
export EXTRA_CONFIGURE_ARGS="--prefix= --exec-prefix="

PatchStep() {
  DefaultPatchStep
  ChangeDir ${NACL_PACKAGES_REPOSITORY}/${PACKAGE_DIR}
  cp ${START_DIR}/nano_pepper.c src/nano_pepper.c
}

InstallStep() {
  MakeDir ${PUBLISH_DIR}
  local ASSEMBLY_DIR="${PUBLISH_DIR}/nano"

  export INSTALL_TARGETS="install DESTDIR=${ASSEMBLY_DIR}/nanotar"
  DefaultInstallStep

  ChangeDir ${ASSEMBLY_DIR}/nanotar
  cp bin/nano ../nano_${NACL_ARCH}${NACL_EXEEXT}
  rm -rf bin
  rm -rf share/man
  tar cf ${ASSEMBLY_DIR}/nano.tar .
  rm -rf ${ASSEMBLY_DIR}/nanotar
  cp ${START_DIR}/nano.html ${ASSEMBLY_DIR}
  cd ${ASSEMBLY_DIR}
  python ${NACL_SDK_ROOT}/tools/create_nmf.py \
      ${NACL_CREATE_NMF_FLAGS} \
      nano_*${NACL_EXEEXT} \
      -s . \
      -o nano.nmf

  local CHROMEAPPS=${NACL_SRC}/libraries/hterm/src/chromeapps
  local LIB_DOT=${CHROMEAPPS}/libdot
  local NASSH=${CHROMEAPPS}/nassh
  LIBDOT_SEARCH_PATH=${CHROMEAPPS} ${LIB_DOT}/bin/concat.sh \
      -i ${NASSH}/concat/nassh_deps.concat \
      -o ${ASSEMBLY_DIR}/hterm.concat.js
  LogExecute cp ${START_DIR}/*.js ${ASSEMBLY_DIR}
  LogExecute cp ${NACL_SRC}/build_tools/naclterm.js ${ASSEMBLY_DIR}
  LogExecute cp ${START_DIR}/manifest.json ${ASSEMBLY_DIR}
  LogExecute cp ${START_DIR}/icon_16.png ${ASSEMBLY_DIR}
  LogExecute cp ${START_DIR}/icon_48.png ${ASSEMBLY_DIR}
  LogExecute cp ${START_DIR}/icon_128.png ${ASSEMBLY_DIR}
  ChangeDir ${PUBLISH_DIR}
  LogExecute zip -r nano-7.3.zip nano
}

PackageInstall
exit 0