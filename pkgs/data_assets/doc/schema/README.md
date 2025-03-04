These schemas document the protocol for build and link hooks with data assets.

* If you are a hook author, you should likely be using a hook-helper-package's
  Dart API (such as `package:native_assets_cli`) which abstracts away from
  syntactic changes.
* If you are a hook-helper-package author, you should likely be using a
  hook-helper-package's Dart API (such as `package:native_assets_cli`) which
  abstracts away from syntactic changes. If you do want to directly interact
  with the JSON, you can find the relevant schemas in [hook/](hook/).
* If you are an SDK author, you should likely be using the SDK helper package
  (`package:native_assets_builder`) which abstracts away from syntactic changes.
  If you do want to directly interact with the JSON, you can find the relevant
  schemas in [sdk/](sdk/).

These schemas are an extension of the base protocol:

* [`package:hook`/doc/schema](../../../hook/doc/schema/)
