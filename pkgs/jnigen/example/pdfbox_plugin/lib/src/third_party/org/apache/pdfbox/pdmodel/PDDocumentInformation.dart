// Generated from Apache PDFBox library which is licensed under the Apache License 2.0.
// The following copyright from the original authors applies.
//
// Licensed to the Apache Software Foundation (ASF) under one or more
// contributor license agreements.  See the NOTICE file distributed with
// this work for additional information regarding copyright ownership.
// The ASF licenses this file to You under the Apache License, Version 2.0
// (the "License"); you may not use this file except in compliance with
// the License.  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Autogenerated by jnigen. DO NOT EDIT!

// ignore_for_file: annotate_overrides
// ignore_for_file: argument_type_not_assignable
// ignore_for_file: camel_case_extensions
// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names
// ignore_for_file: doc_directive_unknown
// ignore_for_file: file_names
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: no_leading_underscores_for_local_identifiers
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: only_throw_errors
// ignore_for_file: overridden_fields
// ignore_for_file: unnecessary_cast
// ignore_for_file: unused_element
// ignore_for_file: unused_field
// ignore_for_file: unused_import
// ignore_for_file: unused_local_variable
// ignore_for_file: unused_shown_name
// ignore_for_file: use_super_parameters

import "dart:ffi" as ffi;
import "dart:isolate" show ReceivePort;

import "package:jni/internal_helpers_for_jnigen.dart";
import "package:jni/jni.dart" as jni;

/// from: org.apache.pdfbox.pdmodel.PDDocumentInformation
///
/// This is the document metadata.  Each getXXX method will return the entry if
/// it exists or null if it does not exist.  If you pass in null for the setXXX
/// method then it will clear the value.
///@author Ben Litchfield
///@author Gerardo Ortiz
class PDDocumentInformation extends jni.JObject {
  @override
  late final jni.JObjType<PDDocumentInformation> $type = type;

  PDDocumentInformation.fromReference(
    jni.JReference reference,
  ) : super.fromReference(reference);

  static final _class =
      jni.JClass.forName(r"org/apache/pdfbox/pdmodel/PDDocumentInformation");

  /// The type which includes information such as the signature of this class.
  static const type = $PDDocumentInformationType();
  static final _id_new0 = _class.constructorId(
    r"()V",
  );

  static final _new0 = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>("globalEnv_NewObject")
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: public void <init>()
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// Default Constructor.
  factory PDDocumentInformation() {
    return PDDocumentInformation.fromReference(
        _new0(_class.reference.pointer, _id_new0 as jni.JMethodIDPtr)
            .reference);
  }

  static final _id_new1 = _class.constructorId(
    r"(Lorg/apache/pdfbox/cos/COSDictionary;)V",
  );

  static final _new1 = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JniResult Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          "globalEnv_NewObject")
      .asFunction<
          jni.JniResult Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: public void <init>(org.apache.pdfbox.cos.COSDictionary dic)
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// Constructor that is used for a preexisting dictionary.
  ///@param dic The underlying dictionary.
  factory PDDocumentInformation.new1(
    jni.JObject dic,
  ) {
    return PDDocumentInformation.fromReference(_new1(_class.reference.pointer,
            _id_new1 as jni.JMethodIDPtr, dic.reference.pointer)
        .reference);
  }

  static final _id_getCOSObject = _class.instanceMethodId(
    r"getCOSObject",
    r"()Lorg/apache/pdfbox/cos/COSDictionary;",
  );

  static final _getCOSObject = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>("globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: public org.apache.pdfbox.cos.COSDictionary getCOSObject()
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// This will get the underlying dictionary that this object wraps.
  ///@return The underlying info dictionary.
  jni.JObject getCOSObject() {
    return _getCOSObject(
            reference.pointer, _id_getCOSObject as jni.JMethodIDPtr)
        .object(const jni.JObjectType());
  }

  static final _id_getPropertyStringValue = _class.instanceMethodId(
    r"getPropertyStringValue",
    r"(Ljava/lang/String;)Ljava/lang/Object;",
  );

  static final _getPropertyStringValue = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JniResult Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          "globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: public java.lang.Object getPropertyStringValue(java.lang.String propertyKey)
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// Return the properties String value.
  ///
  /// Allows to retrieve the
  /// low level date for validation purposes.
  ///
  ///
  ///@param propertyKey the dictionaries key
  ///@return the properties value
  jni.JObject getPropertyStringValue(
    jni.JString propertyKey,
  ) {
    return _getPropertyStringValue(
            reference.pointer,
            _id_getPropertyStringValue as jni.JMethodIDPtr,
            propertyKey.reference.pointer)
        .object(const jni.JObjectType());
  }

  static final _id_getTitle = _class.instanceMethodId(
    r"getTitle",
    r"()Ljava/lang/String;",
  );

  static final _getTitle = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>("globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: public java.lang.String getTitle()
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// This will get the title of the document.  This will return null if no title exists.
  ///@return The title of the document.
  jni.JString getTitle() {
    return _getTitle(reference.pointer, _id_getTitle as jni.JMethodIDPtr)
        .object(const jni.JStringType());
  }

  static final _id_setTitle = _class.instanceMethodId(
    r"setTitle",
    r"(Ljava/lang/String;)V",
  );

  static final _setTitle = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JThrowablePtr Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          "globalEnv_CallVoidMethod")
      .asFunction<
          jni.JThrowablePtr Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: public void setTitle(java.lang.String title)
  ///
  /// This will set the title of the document.
  ///@param title The new title for the document.
  void setTitle(
    jni.JString title,
  ) {
    _setTitle(reference.pointer, _id_setTitle as jni.JMethodIDPtr,
            title.reference.pointer)
        .check();
  }

  static final _id_getAuthor = _class.instanceMethodId(
    r"getAuthor",
    r"()Ljava/lang/String;",
  );

  static final _getAuthor = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>("globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: public java.lang.String getAuthor()
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// This will get the author of the document.  This will return null if no author exists.
  ///@return The author of the document.
  jni.JString getAuthor() {
    return _getAuthor(reference.pointer, _id_getAuthor as jni.JMethodIDPtr)
        .object(const jni.JStringType());
  }

  static final _id_setAuthor = _class.instanceMethodId(
    r"setAuthor",
    r"(Ljava/lang/String;)V",
  );

  static final _setAuthor = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JThrowablePtr Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          "globalEnv_CallVoidMethod")
      .asFunction<
          jni.JThrowablePtr Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: public void setAuthor(java.lang.String author)
  ///
  /// This will set the author of the document.
  ///@param author The new author for the document.
  void setAuthor(
    jni.JString author,
  ) {
    _setAuthor(reference.pointer, _id_setAuthor as jni.JMethodIDPtr,
            author.reference.pointer)
        .check();
  }

  static final _id_getSubject = _class.instanceMethodId(
    r"getSubject",
    r"()Ljava/lang/String;",
  );

  static final _getSubject = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>("globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: public java.lang.String getSubject()
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// This will get the subject of the document.  This will return null if no subject exists.
  ///@return The subject of the document.
  jni.JString getSubject() {
    return _getSubject(reference.pointer, _id_getSubject as jni.JMethodIDPtr)
        .object(const jni.JStringType());
  }

  static final _id_setSubject = _class.instanceMethodId(
    r"setSubject",
    r"(Ljava/lang/String;)V",
  );

  static final _setSubject = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JThrowablePtr Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          "globalEnv_CallVoidMethod")
      .asFunction<
          jni.JThrowablePtr Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: public void setSubject(java.lang.String subject)
  ///
  /// This will set the subject of the document.
  ///@param subject The new subject for the document.
  void setSubject(
    jni.JString subject,
  ) {
    _setSubject(reference.pointer, _id_setSubject as jni.JMethodIDPtr,
            subject.reference.pointer)
        .check();
  }

  static final _id_getKeywords = _class.instanceMethodId(
    r"getKeywords",
    r"()Ljava/lang/String;",
  );

  static final _getKeywords = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>("globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: public java.lang.String getKeywords()
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// This will get the keywords of the document.  This will return null if no keywords exists.
  ///@return The keywords of the document.
  jni.JString getKeywords() {
    return _getKeywords(reference.pointer, _id_getKeywords as jni.JMethodIDPtr)
        .object(const jni.JStringType());
  }

  static final _id_setKeywords = _class.instanceMethodId(
    r"setKeywords",
    r"(Ljava/lang/String;)V",
  );

  static final _setKeywords = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JThrowablePtr Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          "globalEnv_CallVoidMethod")
      .asFunction<
          jni.JThrowablePtr Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: public void setKeywords(java.lang.String keywords)
  ///
  /// This will set the keywords of the document.
  ///@param keywords The new keywords for the document.
  void setKeywords(
    jni.JString keywords,
  ) {
    _setKeywords(reference.pointer, _id_setKeywords as jni.JMethodIDPtr,
            keywords.reference.pointer)
        .check();
  }

  static final _id_getCreator = _class.instanceMethodId(
    r"getCreator",
    r"()Ljava/lang/String;",
  );

  static final _getCreator = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>("globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: public java.lang.String getCreator()
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// This will get the creator of the document.  This will return null if no creator exists.
  ///@return The creator of the document.
  jni.JString getCreator() {
    return _getCreator(reference.pointer, _id_getCreator as jni.JMethodIDPtr)
        .object(const jni.JStringType());
  }

  static final _id_setCreator = _class.instanceMethodId(
    r"setCreator",
    r"(Ljava/lang/String;)V",
  );

  static final _setCreator = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JThrowablePtr Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          "globalEnv_CallVoidMethod")
      .asFunction<
          jni.JThrowablePtr Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: public void setCreator(java.lang.String creator)
  ///
  /// This will set the creator of the document.
  ///@param creator The new creator for the document.
  void setCreator(
    jni.JString creator,
  ) {
    _setCreator(reference.pointer, _id_setCreator as jni.JMethodIDPtr,
            creator.reference.pointer)
        .check();
  }

  static final _id_getProducer = _class.instanceMethodId(
    r"getProducer",
    r"()Ljava/lang/String;",
  );

  static final _getProducer = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>("globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: public java.lang.String getProducer()
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// This will get the producer of the document.  This will return null if no producer exists.
  ///@return The producer of the document.
  jni.JString getProducer() {
    return _getProducer(reference.pointer, _id_getProducer as jni.JMethodIDPtr)
        .object(const jni.JStringType());
  }

  static final _id_setProducer = _class.instanceMethodId(
    r"setProducer",
    r"(Ljava/lang/String;)V",
  );

  static final _setProducer = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JThrowablePtr Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          "globalEnv_CallVoidMethod")
      .asFunction<
          jni.JThrowablePtr Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: public void setProducer(java.lang.String producer)
  ///
  /// This will set the producer of the document.
  ///@param producer The new producer for the document.
  void setProducer(
    jni.JString producer,
  ) {
    _setProducer(reference.pointer, _id_setProducer as jni.JMethodIDPtr,
            producer.reference.pointer)
        .check();
  }

  static final _id_getCreationDate = _class.instanceMethodId(
    r"getCreationDate",
    r"()Ljava/util/Calendar;",
  );

  static final _getCreationDate = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>("globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: public java.util.Calendar getCreationDate()
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// This will get the creation date of the document.  This will return null if no creation date exists.
  ///@return The creation date of the document.
  jni.JObject getCreationDate() {
    return _getCreationDate(
            reference.pointer, _id_getCreationDate as jni.JMethodIDPtr)
        .object(const jni.JObjectType());
  }

  static final _id_setCreationDate = _class.instanceMethodId(
    r"setCreationDate",
    r"(Ljava/util/Calendar;)V",
  );

  static final _setCreationDate = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JThrowablePtr Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          "globalEnv_CallVoidMethod")
      .asFunction<
          jni.JThrowablePtr Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: public void setCreationDate(java.util.Calendar date)
  ///
  /// This will set the creation date of the document.
  ///@param date The new creation date for the document.
  void setCreationDate(
    jni.JObject date,
  ) {
    _setCreationDate(reference.pointer, _id_setCreationDate as jni.JMethodIDPtr,
            date.reference.pointer)
        .check();
  }

  static final _id_getModificationDate = _class.instanceMethodId(
    r"getModificationDate",
    r"()Ljava/util/Calendar;",
  );

  static final _getModificationDate = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>("globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: public java.util.Calendar getModificationDate()
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// This will get the modification date of the document.  This will return null if no modification date exists.
  ///@return The modification date of the document.
  jni.JObject getModificationDate() {
    return _getModificationDate(
            reference.pointer, _id_getModificationDate as jni.JMethodIDPtr)
        .object(const jni.JObjectType());
  }

  static final _id_setModificationDate = _class.instanceMethodId(
    r"setModificationDate",
    r"(Ljava/util/Calendar;)V",
  );

  static final _setModificationDate = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JThrowablePtr Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          "globalEnv_CallVoidMethod")
      .asFunction<
          jni.JThrowablePtr Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: public void setModificationDate(java.util.Calendar date)
  ///
  /// This will set the modification date of the document.
  ///@param date The new modification date for the document.
  void setModificationDate(
    jni.JObject date,
  ) {
    _setModificationDate(reference.pointer,
            _id_setModificationDate as jni.JMethodIDPtr, date.reference.pointer)
        .check();
  }

  static final _id_getTrapped = _class.instanceMethodId(
    r"getTrapped",
    r"()Ljava/lang/String;",
  );

  static final _getTrapped = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>("globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: public java.lang.String getTrapped()
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// This will get the trapped value for the document.
  /// This will return null if one is not found.
  ///@return The trapped value for the document.
  jni.JString getTrapped() {
    return _getTrapped(reference.pointer, _id_getTrapped as jni.JMethodIDPtr)
        .object(const jni.JStringType());
  }

  static final _id_getMetadataKeys = _class.instanceMethodId(
    r"getMetadataKeys",
    r"()Ljava/util/Set;",
  );

  static final _getMetadataKeys = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JniResult Function(
                ffi.Pointer<ffi.Void>,
                jni.JMethodIDPtr,
              )>>("globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(
            ffi.Pointer<ffi.Void>,
            jni.JMethodIDPtr,
          )>();

  /// from: public java.util.Set<java.lang.String> getMetadataKeys()
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// This will get the keys of all metadata information fields for the document.
  ///@return all metadata key strings.
  ///@since Apache PDFBox 1.3.0
  jni.JSet<jni.JString> getMetadataKeys() {
    return _getMetadataKeys(
            reference.pointer, _id_getMetadataKeys as jni.JMethodIDPtr)
        .object(const jni.JSetType(jni.JStringType()));
  }

  static final _id_getCustomMetadataValue = _class.instanceMethodId(
    r"getCustomMetadataValue",
    r"(Ljava/lang/String;)Ljava/lang/String;",
  );

  static final _getCustomMetadataValue = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JniResult Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          "globalEnv_CallObjectMethod")
      .asFunction<
          jni.JniResult Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: public java.lang.String getCustomMetadataValue(java.lang.String fieldName)
  /// The returned object must be released after use, by calling the [release] method.
  ///
  /// This will get the value of a custom metadata information field for the document.
  ///  This will return null if one is not found.
  ///@param fieldName Name of custom metadata field from pdf document.
  ///@return String Value of metadata field
  jni.JString getCustomMetadataValue(
    jni.JString fieldName,
  ) {
    return _getCustomMetadataValue(
            reference.pointer,
            _id_getCustomMetadataValue as jni.JMethodIDPtr,
            fieldName.reference.pointer)
        .object(const jni.JStringType());
  }

  static final _id_setCustomMetadataValue = _class.instanceMethodId(
    r"setCustomMetadataValue",
    r"(Ljava/lang/String;Ljava/lang/String;)V",
  );

  static final _setCustomMetadataValue = ProtectedJniExtensions.lookup<
          ffi.NativeFunction<
              jni.JThrowablePtr Function(
                  ffi.Pointer<ffi.Void>,
                  jni.JMethodIDPtr,
                  ffi.VarArgs<
                      (
                        ffi.Pointer<ffi.Void>,
                        ffi.Pointer<ffi.Void>
                      )>)>>("globalEnv_CallVoidMethod")
      .asFunction<
          jni.JThrowablePtr Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Void>)>();

  /// from: public void setCustomMetadataValue(java.lang.String fieldName, java.lang.String fieldValue)
  ///
  /// Set the custom metadata value.
  ///@param fieldName The name of the custom metadata field.
  ///@param fieldValue The value to the custom metadata field.
  void setCustomMetadataValue(
    jni.JString fieldName,
    jni.JString fieldValue,
  ) {
    _setCustomMetadataValue(
            reference.pointer,
            _id_setCustomMetadataValue as jni.JMethodIDPtr,
            fieldName.reference.pointer,
            fieldValue.reference.pointer)
        .check();
  }

  static final _id_setTrapped = _class.instanceMethodId(
    r"setTrapped",
    r"(Ljava/lang/String;)V",
  );

  static final _setTrapped = ProtectedJniExtensions.lookup<
              ffi.NativeFunction<
                  jni.JThrowablePtr Function(
                      ffi.Pointer<ffi.Void>,
                      jni.JMethodIDPtr,
                      ffi.VarArgs<(ffi.Pointer<ffi.Void>,)>)>>(
          "globalEnv_CallVoidMethod")
      .asFunction<
          jni.JThrowablePtr Function(ffi.Pointer<ffi.Void>, jni.JMethodIDPtr,
              ffi.Pointer<ffi.Void>)>();

  /// from: public void setTrapped(java.lang.String value)
  ///
  /// This will set the trapped of the document.  This will be
  /// 'True', 'False', or 'Unknown'.
  ///@param value The new trapped value for the document.
  ///@throws IllegalArgumentException if the parameter is invalid.
  void setTrapped(
    jni.JString value,
  ) {
    _setTrapped(reference.pointer, _id_setTrapped as jni.JMethodIDPtr,
            value.reference.pointer)
        .check();
  }
}

final class $PDDocumentInformationType
    extends jni.JObjType<PDDocumentInformation> {
  const $PDDocumentInformationType();

  @override
  String get signature => r"Lorg/apache/pdfbox/pdmodel/PDDocumentInformation;";

  @override
  PDDocumentInformation fromReference(jni.JReference reference) =>
      PDDocumentInformation.fromReference(reference);

  @override
  jni.JObjType get superType => const jni.JObjectType();

  @override
  final superCount = 1;

  @override
  int get hashCode => ($PDDocumentInformationType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == ($PDDocumentInformationType) &&
        other is $PDDocumentInformationType;
  }
}
