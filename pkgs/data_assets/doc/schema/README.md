These schemas document the protocol for build and link hooks with data assets.

* If you are a hook author, you should likely be using this package's Dart API
  which abstracts away from syntactic changes.
* If you are a hook-helper-package author, you should likely be using this
  package's Dart API which abstracts away from syntactic changes. If you do want
  to directly interact with the JSON, you can find the relevant schemas in
  [hook/](hook/).
* If you are an SDK author, you should likely be using the SDK helper package
  (`package:hooks_runner`) which abstracts away from syntactic changes.
  If you do want to directly interact with the JSON, you can find the relevant
  schemas in [sdk/](sdk/).

These schemas are an extension of the base protocol:

* [`package:hooks`/doc/schema](../../../hooks/doc/schema/)
