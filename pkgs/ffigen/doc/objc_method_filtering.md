# Objective-C method filtering

Methods and properties on ObjC interfaces and protocols can be filtered using
the `member-filter` option under `objc-interfaces`, `objc-protocols`, and
`objc-categories`. For simplicity we'll focus on interface methods,
but the same rules apply to properties, protocols, and categories.
There are two parts to the filtering process: matching
the interface, and then filtering the method.

The syntax of `member-filter` is a YAML map from a pattern to some
`include`/`exclude` rules, and `include` and `exclude` are each a list of
patterns.

```yaml
objc-interfaces:
  member-filter:
    MyInterface:  # Matches an interface.
      include:
        - "someMethod:withArg:"  # Matches a method.
      exclude:
        - someOtherMethod  # Matches a method.
```

The interface matching logic is the same as the matching logic for the
`member-rename` option:

- The pattern is compared against the original name of the interface (before any
  renaming is applied).
- The pattern may be a string or a regexp, but in either case they must match
  the entire interface name.
- If the pattern contains only alphanumeric characters, or `_`, it is treated as
  a string rather than a regex.
- String patterns take precedence over regexps. That is, if an interface matches
  both a regexp pattern, and a string pattern, it uses the string pattern's
  `include`/`exclude` rules.

The method filtering logic uses the same `include`/`exclude` rules as the rest
of the config:

- `include` and `exclude` are a list of patterns.
- The patterns are compared against the original name of the method, before
  renaming.
- The patterns can be strings or regexps, but must match the entire method name.
- The method name is in ObjC selector syntax, which means that the method name
  and all the external parameter names are concatenated together with `:`
  characters. This is the same name you'll see in ObjC's API documentation.
- **NOTE:** Since the pattern must match the entire method name, and most ObjC
  method names end with a `:`, it's a good idea to surround the pattern with
  quotes, `"`. Otherwise, YAML will think you're defining a map key.
- If no  `include` or `exclude` rules are defined, all methods are included,
  regardless of the top level `exclude-all-by-default` rule.
- If only `include` rules are `defined`, all non-matching methods are excluded.
- If only `exclude` rules are `defined`, all non-matching methods are included.
- If both `include` and `exclude` rules are defined, the `exclude` rules take
  precedence. That is, if a method name matches both an `include` rule and an
  `exclude` rule, the method is excluded. All non-matching methods are also
  excluded.

The property filtering rules live in the same `objc-interfaces.member-filter`
option as the methods. There is no distinction between methods and properties in
the filters. The protocol filtering rules live in
`objc-protocols.member-filter`, and for categories they're in
`objc-categories.member-filter`.
