## 0.2.0-wip

- Added support for inout parameters. Preserve inout types in AST and generate
  correct & pass-by-reference invocation syntax.
- Added support for Swift subscripts. Non-representable subscripts (static, 
  throwing, async, or with multiple/optional parameters) are automatically
  transformed into `@objc` methods.

## 0.1.0

- MVP version.
