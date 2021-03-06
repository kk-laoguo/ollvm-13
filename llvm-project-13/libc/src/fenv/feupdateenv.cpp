//===-- Implementation of feupdateenv function ----------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/fenv/feupdateenv.h"
#include "src/__support/common.h"
#include "utils/FPUtil/FEnvUtils.h"

#include <fenv.h>

namespace __llvm_libc {

LLVM_LIBC_FUNCTION(int, feupdateenv, (const fenv_t *envp)) {
  int current_excepts = fputil::testExcept(FE_ALL_EXCEPT);
  if (fputil::setEnv(envp) != 0)
    return -1;
  return fputil::raiseExcept(current_excepts);
}

} // namespace __llvm_libc
