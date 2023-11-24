# This is the rules file which prevents `proguard` from aggressively
# removing the classes which appear to be unused, in release mode.
#
# Since JNI is based on runtime lookup for classes, proguard will not have
# a way to know EmojiCompat class in our example is actually used. Therefore
# we have to explicitly list it in this file to prevent the application from
# crashing with ClassNotFoundException.
#
# This doesn't apply to builtin classes, eg: those in `android.` namespace Since
# they are already present on the device.
# For the Java code which is written by yourself, you can add `androidx.annotation.Keep`
# instead. (As done in `AndroidUtils.java`).
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

-keep class androidx.emoji2.text.EmojiCompat { public *; }
