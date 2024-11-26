import 'simple_elements.dart';

class UserExcluder extends Visitor {
  @override
  void visitClass(SimpleClassDecl c) {
    if (c.binaryName.contains('y')) {
      c.isExcluded = true;
    }
  }

  @override
  void visitMethod(SimpleMethod method) {
    if (method.name.compareTo('Bar') == 0) {
      method.isExcluded = true;
    }
  }

  @override
  void visitField(SimpleField field) {
    if (field.name.compareTo('Bar') == 0) {
      field.isExcluded = true;
    }
  }
}
