// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "native_add_library.h"

#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#ifdef DEBUG
#include <stdio.h>
#endif

int64_t my_open(const char *pathname, int64_t flags, int64_t mode) {
  return open(pathname, flags, mode);
}

int my_rename(const char *old, const char *new) { return rename(old, new); }

int64_t my_close(int64_t fd) { return close(fd); }

int64_t my_unlinkat(int64_t dirfd, const char *pathname, int64_t flags) {
  return unlinkat(dirfd, pathname, flags);
}

void my_seterrno(int64_t err) { errno = err; }

int64_t my_errno(void) { return errno; }

char *my_getenv(const char *name) { return getenv(name); }

char *my_mkdtemp(char *template) { return mkdtemp(template); }

int64_t my_closedir(my_DIR *d) {
  int r = closedir(d->_dir);
  free(d);
  return r;
}

my_DIR *my_opendir(const char *path) {
  my_DIR *myd = malloc(sizeof(my_DIR));

  DIR *d = opendir(path);
  if (d == NULL) {
    return NULL;
  }
  myd->_dir = d;
  return myd;
}

struct my_dirent *my_readdir(my_DIR *myd) {
  struct dirent *d = readdir(myd->_dir);
  if (d == NULL) {
    return NULL;
  }

  myd->my_dirent.d_ino = d->d_ino;
  strncpy(myd->my_dirent.d_name, d->d_name, sizeof(myd->my_dirent.d_name));
  return &(myd->my_dirent);
}

static void _fill(struct my_Stat *buf, struct stat *s) {
  buf->st_dev = s->st_dev;
  buf->st_ino = s->st_ino;
  buf->st_mode = s->st_mode;
  buf->st_nlink = s->st_nlink;
  buf->std_uid = s->st_uid;
#ifdef __APPLE__
  buf->st_atim.tv_sec = s->st_atimespec.tv_sec;
  buf->st_atim.tv_nsec = s->st_atimespec.tv_nsec;

  buf->st_ctim.tv_sec = s->st_ctimespec.tv_sec;
  buf->st_ctim.tv_nsec = s->st_ctimespec.tv_nsec;

  buf->st_mtim.tv_sec = s->st_mtimespec.tv_sec;
  buf->st_mtim.tv_nsec = s->st_mtimespec.tv_nsec;

  buf->st_btime.tv_sec = s->st_birthtimespec.tv_sec;
  buf->st_btime.tv_nsec = s->st_birthtimespec.tv_nsec;

  buf->st_flags = s->st_flags;
#elif
  // https://man7.org/linux/man-pages/man3/stat.3type.html

  buf->st_atim.tv_sec = s->st_atim.tv_sec;
  buf->st_atim.tv_nsec = s->st_atim.tv_nsec;

  buf->st_ctim.tv_sec = s->st_ctim.tv_sec;
  buf->st_ctim.tv_nsec = s->st_ctim.tv_nsec;

  buf->st_mtim.tv_sec = s->st_mtim.tv_sec;
  buf->st_mtim.tv_nsec = s->st_mtim.tv_nsec;
#endif
}

int64_t my_mkdir(const char *pathname, int64_t mode) {
  return mkdir(pathname, mode);
}

int64_t my_stat(const char *path, struct my_Stat *buf) {
  struct stat s;
  int r = stat(path, &s);
  if (r != -1) {
    _fill(buf, &s);
  }
  return r;
}

int64_t my_lstat(const char *path, struct my_Stat *buf) {
  struct stat s;
  int r = lstat(path, &s);
  if (r != -1) {
    _fill(buf, &s);
  }
  return r;
}

int64_t my_fstat(int64_t fd, struct my_Stat *buf) {
  struct stat s;
  int r = fstat(fd, &s);
  if (r != -1) {
    _fill(buf, &s);
  }
  return r;
}
