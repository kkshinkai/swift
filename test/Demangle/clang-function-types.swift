// NOTE: manglings.txt should be kept in sync with the manglings in this file.

// Make sure we are testing the right manglings.
// RUN: %target-swift-frontend(mock-sdk: %clang-importer-sdk) %s -emit-sil -o - -I %S/../Inputs/custom-modules -use-clang-function-types -module-name tmp -enable-objc-interop | %FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-%target-os-%target-cpu

// Check that demangling works.

// %t.input: "A ---> B" ==> "A"
// RUN: sed -ne '/--->/s/ *--->.*$//p' < %S/Inputs/manglings-with-clang-types.txt > %t.input
// %t.check: "A ---> B" ==> "B"
// RUN: sed -ne '/--->/s/^.*---> *//p' < %S/Inputs/manglings-with-clang-types.txt > %t.check
// RUN: swift-demangle -classify < %t.input > %t.output
// RUN: diff %t.check %t.output

// Other tests already check mangling for Windows, so we don't need to
// check that here again.

// UNSUPPORTED: OS=windows-msvc
// UNSUPPORTED: OS=linux-android, OS=linux-androideabi

import ctypes

#if os(macOS) && arch(x86_64)
import ObjectiveC

// BOOL == signed char on x86_64 macOS
public func h(_ k: @convention(block, cType: "void (^)(BOOL)") (Bool) -> ()) {
  let _ = k(true)
}
h(A.setGlobal) // OK: check that importing preserves Clang types

// CHECK-macosx-x86_64: sil @$s3tmp1hyyySbXzB24_ZTSU13block_pointerFvaEF
#endif

public func f(_ k: @convention(c, cType: "size_t (*)(void)") () -> Int) {
  let _ = k()
}
f(ctypes.returns_size_t) // OK: check that importing preserves Clang type

// CHECK: sil @$s3tmp1fyySiyXzC9_ZTSPFmvEF
