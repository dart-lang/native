# Ref count testing

How to write a reliable ref counting test:

- Rather than trying to read the object ref count, use `ReferenceTracker`.
  Alternatively, arc_test and ref_count_test use a `int32_t* counter` pattern,
  but the idea is the same. Rather than checking the actual ref counts, these
  patterns just watch for when the destructor is called.
- Move creation of any ObjC objects, blocks, or lambda functions into a separate
  function, to avoid accidental capturing of variables inside closures, or other
  unexpected variable lifetimes.
- Mark such functions with `@pragma('vm:never-inline')`.
- An alternative to serparate functions, to force drop Dart references to an
  object, is to make the object variable nullable, and then set it to null.
- Use `expect(object, isNotNull)` to ensure that `object` stays alive until
  then.
- Use `doGC()` to force run GC. If you're on a platform that doesn't support
  `doGC()` (ie `canDoGC` is false), use `flutterDoGC()` (though it's slower,
  not 100% reliable, and breaks autorelease pools, so should be avoided).
- If you're working with blocks, you'll likely need to
  `await Future<void>.delayed(Duration.zero)` to allow the disposal message to
  be sent back to the owner isolate so that the registered closure is cleaned
  up. After that you'll need to call `doGC()` again to make sure the closure is
  destroyed.
- You can use `blockHasRegisteredClosure` to test that the closure is destroyed.
- Got nested blocks? Repeat that process until everything is destroyed.
- Objects still living too long, despite all that? ObjC might be doing an
  autorelease somewhere. If your test doesn't have an explicit autorelease pool,
  it will be added to a pool that outlives the test (likely thread scoped). To
  fix this, wrap your test in `objc_autoreleasePoolPush/Pop`. Make sure not to
  do any async/await stuff in between the push and pop.
