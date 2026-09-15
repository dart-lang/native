// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

// --- Functions ---
void regular_func(int a);
void regex_func(void);
int leaf_func(int a);
int leaf_regex_func(int a);
void variadic_func(int count, ...);
void sym_addr_func(void);
void sym_addr_regex_func(void);
void exp_typedef_func(int x);
void exp_typedef_regex_func(int x);
void func_param_rename(int old_param);
void func_regex_param_rename(int prefix_param_1, int swap_first_second);
void old_func(void);
void prefix_func_test(void);
void strip_func_test(void);
void swap_a_b(void);
void func_exclude(void);
void regex_exclude_func(void);

// --- Structs ---
struct RegularStruct {
  int a;
};
struct RegexStructA {
  int a;
};
struct Pack1Struct {
  char a;
  int b;
};
struct Pack2Struct {
  char a;
  int b;
};
struct Pack4Struct {
  char a;
  long long b;
};
struct Pack8Struct {
  char a;
  long long b;
};
struct Pack16Struct {
  char a;
  long long b;
};
struct PackNoneStruct {
  char a;
  int b;
};
struct FieldRenameStruct {
  int old_field;
};
struct RegexFieldStruct {
  int prefix_field_1;
  int swap_first_second;
};
struct StructRenameNoGroup {
  int a;
};
struct RegexStructNoGroup_test {
  int a;
};
struct StripStruct_test {
  int a;
};
struct Swap_Struct_first_second {
  int a;
};
struct OpaqueDepStruct {
  int a;
};
struct ExcludedStruct {
  int a;
};
struct RegexExcludedStructA {
  int a;
};
void func_with_opaque_dep(struct OpaqueDepStruct* s);

// --- Unions ---
union RegularUnion {
  int a;
  float b;
};
union RegexUnionA {
  int a;
  float b;
};
union ExcludedUnion {
  int a;
  float b;
};
union RegexExcludedUnionA {
  int a;
  float b;
};
union UnionOld {
  int a;
};
union FieldRenameUnion {
  int old_field;
  float prefix_field_1;
  double swap_first_second;
};
union OpaqueDepUnion {
  int a;
  float b;
};
void func_with_opaque_union(union OpaqueDepUnion* u);

// --- Enums ---
enum RegularEnum {
  REG_A,
  REG_B
};
enum RegexEnumA {
  REG_EX_A
};
enum ExcludedEnum {
  EXC_A
};
enum RegexExcludedEnumA {
  EXC_EX_A
};
enum EnumOld {
  ENUM_OLD_VAL
};
enum AsIntEnum {
  AS_INT_A,
  AS_INT_B
};
enum AsIntRegexEnum {
  AS_INT_REG_A,
  AS_INT_REG_B
};
enum MemberRenameEnum {
  OLD_CONST,
  OTHER_CONST
};
enum RegexMemberRenameEnum {
  OLD_PREFIX_FOO,
  SWAP_FIRST_SECOND
};

// --- Unnamed enums ---
enum {
  UNNAMED_OLD_CONST = 1,
  UNNAMED_PREFIX_FOO = 2,
  UNNAMED_PREFIX_BAR = 3,
  UNNAMED_EXCLUDED = 99,
  UNNAMED_REGEX_EXCLUDED_A = 100
};

// --- Globals ---
extern int regular_global;
extern int sym_addr_global;
extern int sym_addr_regex_global;
extern int excluded_global;
extern int regex_excluded_global;
extern int prefix_global_test;
extern int prefix_global_foo;

// --- Macros ---
#define MACRO_EXACT 100
#define MACRO_PREFIX_FOO 200
#define MACRO_EXCLUDE 999
#define MACRO_REGEX_EXCLUDE_A 1000

// --- Typedefs ---
typedef int mapped_typedef_t;
typedef double old_typedef_t;
typedef char regex_prefix_typedef_t;
typedef float excluded_typedef;
typedef int regex_excluded_typedef_t;
void func_using_mapped_type(mapped_typedef_t x);

// --- ObjC Interfaces ---
@interface ComprehensiveInterface : NSObject
@property int someProperty;
- (void)regularMethod;
- (void)filteredMethod;
- (void)regexFilteredMethod;
- (void)oldMethodName;
- (void)prefixMethod_test;
- (void)stripMethod_test;
- (void)swap_one_two;
@end

@interface RegexInterfaceA : NSObject
@end

@interface ExcludedInterface : NSObject
@end

@interface RegexExcludedInterfaceA : NSObject
@end

@interface InterfaceOld : NSObject
@end

// --- ObjC Protocols ---
@protocol ComprehensiveProtocol
- (void)protoFilteredMethod;
- (void)protoRegexFilteredMethod;
@end

@protocol RegexProtocolA
@end

@protocol ExcludedProtocol
@end

@protocol RegexExcludedProtocolA
@end

@protocol ProtocolOld
@end

// --- ObjC Categories ---
@interface ComprehensiveInterface (ComprehensiveCategory)
- (void)catRegularMethod;
- (void)catFilteredMethod;
- (void)catRegexFilteredMethod;
- (void)catOldMethodName;
- (void)catPrefixMethod_test;
@end

@interface ComprehensiveInterface (RegexCategoryA)
@end

@interface ComprehensiveInterface (ExcludedCategory)
@end

@interface ComprehensiveInterface (RegexExcludedCategoryA)
@end

@interface ComprehensiveInterface (CategoryOld)
@end
