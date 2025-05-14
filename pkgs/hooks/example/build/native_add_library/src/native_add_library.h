// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <stdint.h>

#if _WIN32
#define MYLIB_EXPORT __declspec(dllexport)
#else
#define MYLIB_EXPORT
#endif

MYLIB_EXPORT int64_t my_open(const char *pathname, int64_t flags, int64_t mode);

struct my_dirent {
    int64_t d_ino;
    char d_name[512];
};

typedef struct {
    struct my_dirent my_dirent;
    void * _dir;
} my_DIR;

MYLIB_EXPORT int64_t my_closedir(my_DIR *d);
MYLIB_EXPORT my_DIR *my_opendir(const char *path);
MYLIB_EXPORT struct my_dirent *my_readdir(my_DIR *d);

struct my_timespec {
    int64_t tv_sec;
    int64_t tv_nsec;
};

struct my_Stat {
    int64_t st_dev;
    int64_t st_ino;
    int64_t st_mode;
    int64_t st_nlink;
    int64_t std_uid;

    struct my_timespec st_atim;
    struct my_timespec st_mtim;
    struct my_timespec st_ctim;
    // Only valid on macOS/iOS
    struct my_timespec st_btime;

    // Only valid on macOS/iOS
    int64_t st_flags; 
};


MYLIB_EXPORT int64_t my_stat(const char *path, struct my_Stat *buf);

const int64_t my_UNDEFINED = 9223372036854775807;

int64_t my_get_UF_HIDDEN();
int64_t my_get_S_IFMT();