#include <stdio.h>

#if _WIN32
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT
#endif

FFI_EXPORT void my_func()
{
  // Using a long (512B) string here so that treeshaking this function actually affects binary size on disk.
  // On windows, treeshaking just a small string (<512B) out of a binary has no effect on raw size because of padding
  // and alignment (FileAlignment of sections defaults to 512B in a Windows DLL).
  printf(
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis dui lacus, volutpat nec consequat at, hendrerit et "
    "lorem. Etiam porttitor velit massa, vitae aliquet elit bibendum quis. Vivamus vestibulum ligula ac nisl faucibus "
    "convallis. Morbi accumsan elit vel varius gravida. Ut nec interdum sapien, vitae mattis libero. Donec ac placerat "
    "lorem. Proin mattis mauris et felis consectetur, et tempor diam tincidunt. Nunc malesuada massa at lectus "
    "volutpat, luctus congue lectus facilisis. Vivamus in cursus velit."
  );
}
