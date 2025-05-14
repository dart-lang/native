#include <sys/stat.h>

#include "constants.g.h"


int64_t my_get_S_IEXEC(void) {
#ifdef S_IEXEC
  return S_IEXEC;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IFBLK(void) {
#ifdef S_IFBLK
  return S_IFBLK;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IFCHR(void) {
#ifdef S_IFCHR
  return S_IFCHR;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IFDIR(void) {
#ifdef S_IFDIR
  return S_IFDIR;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IFIFO(void) {
#ifdef S_IFIFO
  return S_IFIFO;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IFLNK(void) {
#ifdef S_IFLNK
  return S_IFLNK;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IFMT(void) {
#ifdef S_IFMT
  return S_IFMT;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IFREG(void) {
#ifdef S_IFREG
  return S_IFREG;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IFSOCK(void) {
#ifdef S_IFSOCK
  return S_IFSOCK;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IFWHT(void) {
#ifdef S_IFWHT
  return S_IFWHT;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IREAD(void) {
#ifdef S_IREAD
  return S_IREAD;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IRGRP(void) {
#ifdef S_IRGRP
  return S_IRGRP;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IROTH(void) {
#ifdef S_IROTH
  return S_IROTH;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IRUSR(void) {
#ifdef S_IRUSR
  return S_IRUSR;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IRWXG(void) {
#ifdef S_IRWXG
  return S_IRWXG;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IRWXO(void) {
#ifdef S_IRWXO
  return S_IRWXO;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IRWXU(void) {
#ifdef S_IRWXU
  return S_IRWXU;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_ISGID(void) {
#ifdef S_ISGID
  return S_ISGID;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_ISTXT(void) {
#ifdef S_ISTXT
  return S_ISTXT;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_ISUID(void) {
#ifdef S_ISUID
  return S_ISUID;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_ISVTX(void) {
#ifdef S_ISVTX
  return S_ISVTX;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IWGRP(void) {
#ifdef S_IWGRP
  return S_IWGRP;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IWOTH(void) {
#ifdef S_IWOTH
  return S_IWOTH;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IWRITE(void) {
#ifdef S_IWRITE
  return S_IWRITE;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IWUSR(void) {
#ifdef S_IWUSR
  return S_IWUSR;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IXGRP(void) {
#ifdef S_IXGRP
  return S_IXGRP;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IXOTH(void) {
#ifdef S_IXOTH
  return S_IXOTH;
#endif
  return my_UNDEFINED;
}
int64_t my_get_S_IXUSR(void) {
#ifdef S_IXUSR
  return S_IXUSR;
#endif
  return my_UNDEFINED;
}
int64_t my_get_UF_APPEND(void) {
#ifdef UF_APPEND
  return UF_APPEND;
#endif
  return my_UNDEFINED;
}
int64_t my_get_UF_HIDDEN(void) {
#ifdef UF_HIDDEN
  return UF_HIDDEN;
#endif
  return my_UNDEFINED;
}
