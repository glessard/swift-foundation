//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#include "include/platform_shims.h"

#if __has_include(<crt_externs.h>)
#include <crt_externs.h>
#else
#include <unistd.h>
extern char **environ;
#endif

char **
_platform_shims_get_environ()
{
#if __has_include(<crt_externs.h>)
    return *_NSGetEnviron();
#else
    return environ;
#endif
}

#if __has_include(<libkern/OSThermalNotification.h>)
const char *
_platform_shims_kOSThermalNotificationPressureLevelName()
{
    return kOSThermalNotificationPressureLevelName;
}
#endif

