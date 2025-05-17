// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <stdint.h>

#if _WIN32
#define MYLIB_EXPORT __declspec(dllexport)
#else
#define MYLIB_EXPORT
#endif

// <fcntl.h>
MYLIB_EXPORT int64_t my_open(const char *pathname, int64_t flags, int64_t mode);

// <stdio.h>
MYLIB_EXPORT int my_rename(const char *old, const char *new);

// <unistd.h>

MYLIB_EXPORT int64_t my_close(int64_t fd);
MYLIB_EXPORT int64_t my_unlinkat(int64_t dirfd, const char *pathname,
                              int64_t flags);

// <errno.h>
MYLIB_EXPORT void my_seterrno(int64_t err);
MYLIB_EXPORT int64_t my_errno(void);

// <stdlib.h>
MYLIB_EXPORT char *my_getenv(const char *name);
MYLIB_EXPORT char *my_mkdtemp(char *template);

// <dirent.h>

struct my_dirent {
  int64_t d_ino;
  char d_name[512];
};

typedef struct {
  struct my_dirent my_dirent;
  void *_dir;
} my_DIR;

MYLIB_EXPORT int64_t my_closedir(my_DIR *d);
MYLIB_EXPORT my_DIR *my_opendir(const char *path);
MYLIB_EXPORT struct my_dirent *my_readdir(my_DIR *d);

// <sys/stat.h>
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

MYLIB_EXPORT int64_t my_mkdir(const char *pathname, int64_t mode);
MYLIB_EXPORT int64_t my_stat(const char *path, struct my_Stat *buf);
MYLIB_EXPORT int64_t my_lstat(const char *path, struct my_Stat *buf);
MYLIB_EXPORT int64_t my_fstat(int64_t fd, struct my_Stat *buf);
