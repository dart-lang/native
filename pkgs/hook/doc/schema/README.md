These schemas document the protocol for build and link hooks.

* If you are a hook author, you should likely be using a hook-helper-package
  Dart API (such as `package:native_toolchain_c`) instead of directly consuming
  and producing JSON.
* If you are a hook-helper-package author, you should likely be using a
  hook-helper-package's Dart API (such as `package:native_assets_cli`) which
  abstracts away from syntactic changes. If you do want to directly interact
  with the JSON, you can find the relevant schemas in [hook/](hook/).
* If you are an SDK author, you should likely be using the SDK helper package
  (`package:native_assets_builder`) which abstracts away from syntactic changes.
  If you do want to directly interact with the JSON, you can find the relevant
  schemas in [sdk/](sdk/).

The base hook protocol without any extensions does not provide much use. See the
documentation for known extensions:

* [`package:code_assets`/doc/schema](../../../code_assets/doc/schema/)
* [`package:data_assets`/doc/schema](../../../data_assets/doc/schema/)
