; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature
; RUN: opt < %s -S -early-cse -earlycse-debug-hash | FileCheck %s --check-prefixes=CHECK,NO_ASSUME
; RUN: opt < %s -S -early-cse --enable-knowledge-retention | FileCheck %s --check-prefixes=CHECK,USE_ASSUME
; RUN: opt < %s -S -passes=early-cse | FileCheck %s --check-prefixes=CHECK,NO_ASSUME

declare {}* @llvm.invariant.start.p0i8(i64, i8* nocapture) nounwind readonly
declare void @llvm.invariant.end.p0i8({}*, i64, i8* nocapture) nounwind

; Check that we do load-load forwarding over invariant.start, since it does not
; clobber memory
define i8 @test_bypass1(i8 *%P) {
; NO_ASSUME-LABEL: define {{[^@]+}}@test_bypass1
; NO_ASSUME-SAME: (i8* [[P:%.*]])
; NO_ASSUME-NEXT:    [[V1:%.*]] = load i8, i8* [[P]], align 1
; NO_ASSUME-NEXT:    [[I:%.*]] = call {}* @llvm.invariant.start.p0i8(i64 1, i8* [[P]])
; NO_ASSUME-NEXT:    ret i8 0
;
; USE_ASSUME-LABEL: define {{[^@]+}}@test_bypass1
; USE_ASSUME-SAME: (i8* [[P:%.*]])
; USE_ASSUME-NEXT:    [[V1:%.*]] = load i8, i8* [[P]], align 1
; USE_ASSUME-NEXT:    [[I:%.*]] = call {}* @llvm.invariant.start.p0i8(i64 1, i8* [[P]])
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i8* [[P]], i64 1), "nonnull"(i8* [[P]]) ]
; USE_ASSUME-NEXT:    ret i8 0
;

  %V1 = load i8, i8* %P
  %i = call {}* @llvm.invariant.start.p0i8(i64 1, i8* %P)
  %V2 = load i8, i8* %P
  %Diff = sub i8 %V1, %V2
  ret i8 %Diff
}


; Trivial Store->load forwarding over invariant.start
define i8 @test_bypass2(i8 *%P) {
; NO_ASSUME-LABEL: define {{[^@]+}}@test_bypass2
; NO_ASSUME-SAME: (i8* [[P:%.*]])
; NO_ASSUME-NEXT:    store i8 42, i8* [[P]], align 1
; NO_ASSUME-NEXT:    [[I:%.*]] = call {}* @llvm.invariant.start.p0i8(i64 1, i8* [[P]])
; NO_ASSUME-NEXT:    ret i8 42
;
; USE_ASSUME-LABEL: define {{[^@]+}}@test_bypass2
; USE_ASSUME-SAME: (i8* [[P:%.*]])
; USE_ASSUME-NEXT:    store i8 42, i8* [[P]], align 1
; USE_ASSUME-NEXT:    [[I:%.*]] = call {}* @llvm.invariant.start.p0i8(i64 1, i8* [[P]])
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i8* [[P]], i64 1), "nonnull"(i8* [[P]]) ]
; USE_ASSUME-NEXT:    ret i8 42
;

  store i8 42, i8* %P
  %i = call {}* @llvm.invariant.start.p0i8(i64 1, i8* %P)
  %V1 = load i8, i8* %P
  ret i8 %V1
}

; We can DSE over invariant.start calls, since the first store to
; %P is valid, and the second store is actually unreachable based on semantics
; of invariant.start.
define void @test_bypass3(i8* %P) {
; NO_ASSUME-LABEL: define {{[^@]+}}@test_bypass3
; NO_ASSUME-SAME: (i8* [[P:%.*]])
; NO_ASSUME-NEXT:    [[I:%.*]] = call {}* @llvm.invariant.start.p0i8(i64 1, i8* [[P]])
; NO_ASSUME-NEXT:    store i8 60, i8* [[P]], align 1
; NO_ASSUME-NEXT:    ret void
;
; USE_ASSUME-LABEL: define {{[^@]+}}@test_bypass3
; USE_ASSUME-SAME: (i8* [[P:%.*]])
; USE_ASSUME-NEXT:    [[I:%.*]] = call {}* @llvm.invariant.start.p0i8(i64 1, i8* [[P]])
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i8* [[P]], i64 1), "nonnull"(i8* [[P]]) ]
; USE_ASSUME-NEXT:    store i8 60, i8* [[P]], align 1
; USE_ASSUME-NEXT:    ret void
;

  store i8 50, i8* %P
  %i = call {}* @llvm.invariant.start.p0i8(i64 1, i8* %P)
  store i8 60, i8* %P
  ret void
}


; FIXME: Now the first store can actually be eliminated, since there is no read within
; the invariant region, between start and end.
define void @test_bypass4(i8* %P) {
; CHECK-LABEL: define {{[^@]+}}@test_bypass4
; CHECK-SAME: (i8* [[P:%.*]])
; CHECK-NEXT:    store i8 50, i8* [[P]], align 1
; CHECK-NEXT:    [[I:%.*]] = call {}* @llvm.invariant.start.p0i8(i64 1, i8* [[P]])
; CHECK-NEXT:    call void @llvm.invariant.end.p0i8({}* [[I]], i64 1, i8* [[P]])
; CHECK-NEXT:    store i8 60, i8* [[P]], align 1
; CHECK-NEXT:    ret void
;


  store i8 50, i8* %P
  %i = call {}* @llvm.invariant.start.p0i8(i64 1, i8* %P)
  call void @llvm.invariant.end.p0i8({}* %i, i64 1, i8* %P)
  store i8 60, i8* %P
  ret void
}


declare void @clobber()
declare {}* @llvm.invariant.start.p0i32(i64 %size, i32* nocapture %ptr)
declare void @llvm.invariant.end.p0i32({}*, i64, i32* nocapture) nounwind

define i32 @test_before_load(i32* %p) {
; NO_ASSUME-LABEL: define {{[^@]+}}@test_before_load
; NO_ASSUME-SAME: (i32* [[P:%.*]])
; NO_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; NO_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; NO_ASSUME-NEXT:    call void @clobber()
; NO_ASSUME-NEXT:    ret i32 0
;
; USE_ASSUME-LABEL: define {{[^@]+}}@test_before_load
; USE_ASSUME-SAME: (i32* [[P:%.*]])
; USE_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; USE_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; USE_ASSUME-NEXT:    call void @clobber()
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i32* [[P]], i64 4), "nonnull"(i32* [[P]]), "align"(i32* [[P]], i64 4) ]
; USE_ASSUME-NEXT:    ret i32 0
;
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  %v1 = load i32, i32* %p
  call void @clobber()
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

define i32 @test_before_clobber(i32* %p) {
; NO_ASSUME-LABEL: define {{[^@]+}}@test_before_clobber
; NO_ASSUME-SAME: (i32* [[P:%.*]])
; NO_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; NO_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; NO_ASSUME-NEXT:    call void @clobber()
; NO_ASSUME-NEXT:    ret i32 0
;
; USE_ASSUME-LABEL: define {{[^@]+}}@test_before_clobber
; USE_ASSUME-SAME: (i32* [[P:%.*]])
; USE_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; USE_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; USE_ASSUME-NEXT:    call void @clobber()
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i32* [[P]], i64 4), "nonnull"(i32* [[P]]), "align"(i32* [[P]], i64 4) ]
; USE_ASSUME-NEXT:    ret i32 0
;
  %v1 = load i32, i32* %p
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  call void @clobber()
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

define i32 @test_duplicate_scope(i32* %p) {
; NO_ASSUME-LABEL: define {{[^@]+}}@test_duplicate_scope
; NO_ASSUME-SAME: (i32* [[P:%.*]])
; NO_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; NO_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; NO_ASSUME-NEXT:    call void @clobber()
; NO_ASSUME-NEXT:    [[TMP2:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; NO_ASSUME-NEXT:    ret i32 0
;
; USE_ASSUME-LABEL: define {{[^@]+}}@test_duplicate_scope
; USE_ASSUME-SAME: (i32* [[P:%.*]])
; USE_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; USE_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; USE_ASSUME-NEXT:    call void @clobber()
; USE_ASSUME-NEXT:    [[TMP2:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i32* [[P]], i64 4), "nonnull"(i32* [[P]]), "align"(i32* [[P]], i64 4) ]
; USE_ASSUME-NEXT:    ret i32 0
;
  %v1 = load i32, i32* %p
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  call void @clobber()
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

define i32 @test_unanalzyable_load(i32* %p) {
; NO_ASSUME-LABEL: define {{[^@]+}}@test_unanalzyable_load
; NO_ASSUME-SAME: (i32* [[P:%.*]])
; NO_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; NO_ASSUME-NEXT:    call void @clobber()
; NO_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; NO_ASSUME-NEXT:    call void @clobber()
; NO_ASSUME-NEXT:    ret i32 0
;
; USE_ASSUME-LABEL: define {{[^@]+}}@test_unanalzyable_load
; USE_ASSUME-SAME: (i32* [[P:%.*]])
; USE_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; USE_ASSUME-NEXT:    call void @clobber()
; USE_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; USE_ASSUME-NEXT:    call void @clobber()
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i32* [[P]], i64 4), "nonnull"(i32* [[P]]), "align"(i32* [[P]], i64 4) ]
; USE_ASSUME-NEXT:    ret i32 0
;
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  call void @clobber()
  %v1 = load i32, i32* %p
  call void @clobber()
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

define i32 @test_negative_after_clobber(i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@test_negative_after_clobber
; CHECK-SAME: (i32* [[P:%.*]])
; CHECK-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; CHECK-NEXT:    [[V2:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 [[V1]], [[V2]]
; CHECK-NEXT:    ret i32 [[SUB]]
;
  %v1 = load i32, i32* %p
  call void @clobber()
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

define i32 @test_merge(i32* %p, i1 %cnd) {
; NO_ASSUME-LABEL: define {{[^@]+}}@test_merge
; NO_ASSUME-SAME: (i32* [[P:%.*]], i1 [[CND:%.*]])
; NO_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; NO_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; NO_ASSUME-NEXT:    br i1 [[CND]], label [[MERGE:%.*]], label [[TAKEN:%.*]]
; NO_ASSUME:       taken:
; NO_ASSUME-NEXT:    call void @clobber()
; NO_ASSUME-NEXT:    br label [[MERGE]]
; NO_ASSUME:       merge:
; NO_ASSUME-NEXT:    ret i32 0
;
; USE_ASSUME-LABEL: define {{[^@]+}}@test_merge
; USE_ASSUME-SAME: (i32* [[P:%.*]], i1 [[CND:%.*]])
; USE_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; USE_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; USE_ASSUME-NEXT:    br i1 [[CND]], label [[MERGE:%.*]], label [[TAKEN:%.*]]
; USE_ASSUME:       taken:
; USE_ASSUME-NEXT:    call void @clobber()
; USE_ASSUME-NEXT:    br label [[MERGE]]
; USE_ASSUME:       merge:
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i32* [[P]], i64 4), "nonnull"(i32* [[P]]), "align"(i32* [[P]], i64 4) ]
; USE_ASSUME-NEXT:    ret i32 0
;
  %v1 = load i32, i32* %p
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  br i1 %cnd, label %merge, label %taken

taken:
  call void @clobber()
  br label %merge
merge:
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

define i32 @test_negative_after_mergeclobber(i32* %p, i1 %cnd) {
; CHECK-LABEL: define {{[^@]+}}@test_negative_after_mergeclobber
; CHECK-SAME: (i32* [[P:%.*]], i1 [[CND:%.*]])
; CHECK-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    br i1 [[CND]], label [[MERGE:%.*]], label [[TAKEN:%.*]]
; CHECK:       taken:
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    br label [[MERGE]]
; CHECK:       merge:
; CHECK-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; CHECK-NEXT:    [[V2:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 [[V1]], [[V2]]
; CHECK-NEXT:    ret i32 [[SUB]]
;
  %v1 = load i32, i32* %p
  br i1 %cnd, label %merge, label %taken

taken:
  call void @clobber()
  br label %merge
merge:
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

; In theory, this version could work, but earlycse is incapable of
; merging facts along distinct paths.
define i32 @test_false_negative_merge(i32* %p, i1 %cnd) {
; CHECK-LABEL: define {{[^@]+}}@test_false_negative_merge
; CHECK-SAME: (i32* [[P:%.*]], i1 [[CND:%.*]])
; CHECK-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    br i1 [[CND]], label [[MERGE:%.*]], label [[TAKEN:%.*]]
; CHECK:       taken:
; CHECK-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    br label [[MERGE]]
; CHECK:       merge:
; CHECK-NEXT:    [[V2:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 [[V1]], [[V2]]
; CHECK-NEXT:    ret i32 [[SUB]]
;
  %v1 = load i32, i32* %p
  br i1 %cnd, label %merge, label %taken

taken:
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  call void @clobber()
  br label %merge
merge:
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

define i32 @test_merge_unanalyzable_load(i32* %p, i1 %cnd) {
; NO_ASSUME-LABEL: define {{[^@]+}}@test_merge_unanalyzable_load
; NO_ASSUME-SAME: (i32* [[P:%.*]], i1 [[CND:%.*]])
; NO_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; NO_ASSUME-NEXT:    call void @clobber()
; NO_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; NO_ASSUME-NEXT:    br i1 [[CND]], label [[MERGE:%.*]], label [[TAKEN:%.*]]
; NO_ASSUME:       taken:
; NO_ASSUME-NEXT:    call void @clobber()
; NO_ASSUME-NEXT:    br label [[MERGE]]
; NO_ASSUME:       merge:
; NO_ASSUME-NEXT:    ret i32 0
;
; USE_ASSUME-LABEL: define {{[^@]+}}@test_merge_unanalyzable_load
; USE_ASSUME-SAME: (i32* [[P:%.*]], i1 [[CND:%.*]])
; USE_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; USE_ASSUME-NEXT:    call void @clobber()
; USE_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; USE_ASSUME-NEXT:    br i1 [[CND]], label [[MERGE:%.*]], label [[TAKEN:%.*]]
; USE_ASSUME:       taken:
; USE_ASSUME-NEXT:    call void @clobber()
; USE_ASSUME-NEXT:    br label [[MERGE]]
; USE_ASSUME:       merge:
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i32* [[P]], i64 4), "nonnull"(i32* [[P]]), "align"(i32* [[P]], i64 4) ]
; USE_ASSUME-NEXT:    ret i32 0
;
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  call void @clobber()
  %v1 = load i32, i32* %p
  br i1 %cnd, label %merge, label %taken

taken:
  call void @clobber()
  br label %merge
merge:
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

define void @test_dse_before_load(i32* %p, i1 %cnd) {
; NO_ASSUME-LABEL: define {{[^@]+}}@test_dse_before_load
; NO_ASSUME-SAME: (i32* [[P:%.*]], i1 [[CND:%.*]])
; NO_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; NO_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; NO_ASSUME-NEXT:    call void @clobber()
; NO_ASSUME-NEXT:    ret void
;
; USE_ASSUME-LABEL: define {{[^@]+}}@test_dse_before_load
; USE_ASSUME-SAME: (i32* [[P:%.*]], i1 [[CND:%.*]])
; USE_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; USE_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; USE_ASSUME-NEXT:    call void @clobber()
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i32* [[P]], i64 4), "nonnull"(i32* [[P]]), "align"(i32* [[P]], i64 4) ]
; USE_ASSUME-NEXT:    ret void
;
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  %v1 = load i32, i32* %p
  call void @clobber()
  store i32 %v1, i32* %p
  ret void
}

define void @test_dse_after_load(i32* %p, i1 %cnd) {
; NO_ASSUME-LABEL: define {{[^@]+}}@test_dse_after_load
; NO_ASSUME-SAME: (i32* [[P:%.*]], i1 [[CND:%.*]])
; NO_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; NO_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; NO_ASSUME-NEXT:    call void @clobber()
; NO_ASSUME-NEXT:    ret void
;
; USE_ASSUME-LABEL: define {{[^@]+}}@test_dse_after_load
; USE_ASSUME-SAME: (i32* [[P:%.*]], i1 [[CND:%.*]])
; USE_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; USE_ASSUME-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; USE_ASSUME-NEXT:    call void @clobber()
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i32* [[P]], i64 4), "nonnull"(i32* [[P]]), "align"(i32* [[P]], i64 4) ]
; USE_ASSUME-NEXT:    ret void
;
  %v1 = load i32, i32* %p
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  call void @clobber()
  store i32 %v1, i32* %p
  ret void
}


; In this case, we have a false negative since MemoryLocation is implicitly
; typed due to the user of a Value to represent the address.  Note that other
; passes will canonicalize away the bitcasts in this example.
define i32 @test_false_negative_types(i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@test_false_negative_types
; CHECK-SAME: (i32* [[P:%.*]])
; CHECK-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; CHECK-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    [[PF:%.*]] = bitcast i32* [[P]] to float*
; CHECK-NEXT:    [[V2F:%.*]] = load float, float* [[PF]], align 4
; CHECK-NEXT:    [[V2:%.*]] = bitcast float [[V2F]] to i32
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 [[V1]], [[V2]]
; CHECK-NEXT:    ret i32 [[SUB]]
;
  call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  %v1 = load i32, i32* %p
  call void @clobber()
  %pf = bitcast i32* %p to float*
  %v2f = load float, float* %pf
  %v2 = bitcast float %v2f to i32
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

define i32 @test_negative_size1(i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@test_negative_size1
; CHECK-SAME: (i32* [[P:%.*]])
; CHECK-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 3, i32* [[P]])
; CHECK-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    [[V2:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 [[V1]], [[V2]]
; CHECK-NEXT:    ret i32 [[SUB]]
;
  call {}* @llvm.invariant.start.p0i32(i64 3, i32* %p)
  %v1 = load i32, i32* %p
  call void @clobber()
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

define i32 @test_negative_size2(i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@test_negative_size2
; CHECK-SAME: (i32* [[P:%.*]])
; CHECK-NEXT:    [[TMP1:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 0, i32* [[P]])
; CHECK-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    [[V2:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 [[V1]], [[V2]]
; CHECK-NEXT:    ret i32 [[SUB]]
;
  call {}* @llvm.invariant.start.p0i32(i64 0, i32* %p)
  %v1 = load i32, i32* %p
  call void @clobber()
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

define i32 @test_negative_scope(i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@test_negative_scope
; CHECK-SAME: (i32* [[P:%.*]])
; CHECK-NEXT:    [[SCOPE:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; CHECK-NEXT:    call void @llvm.invariant.end.p0i32({}* [[SCOPE]], i64 4, i32* [[P]])
; CHECK-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    [[V2:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 [[V1]], [[V2]]
; CHECK-NEXT:    ret i32 [[SUB]]
;
  %scope = call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  call void @llvm.invariant.end.p0i32({}* %scope, i64 4, i32* %p)
  %v1 = load i32, i32* %p
  call void @clobber()
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

define i32 @test_false_negative_scope(i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@test_false_negative_scope
; CHECK-SAME: (i32* [[P:%.*]])
; CHECK-NEXT:    [[SCOPE:%.*]] = call {}* @llvm.invariant.start.p0i32(i64 4, i32* [[P]])
; CHECK-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    call void @clobber()
; CHECK-NEXT:    [[V2:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    call void @llvm.invariant.end.p0i32({}* [[SCOPE]], i64 4, i32* [[P]])
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 [[V1]], [[V2]]
; CHECK-NEXT:    ret i32 [[SUB]]
;
  %scope = call {}* @llvm.invariant.start.p0i32(i64 4, i32* %p)
  %v1 = load i32, i32* %p
  call void @clobber()
  %v2 = load i32, i32* %p
  call void @llvm.invariant.end.p0i32({}* %scope, i64 4, i32* %p)
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

; Invariant load defact starts an invariant.start scope of the appropriate size
define i32 @test_invariant_load_scope(i32* %p) {
; NO_ASSUME-LABEL: define {{[^@]+}}@test_invariant_load_scope
; NO_ASSUME-SAME: (i32* [[P:%.*]])
; NO_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4, !invariant.load !0
; NO_ASSUME-NEXT:    call void @clobber()
; NO_ASSUME-NEXT:    ret i32 0
;
; USE_ASSUME-LABEL: define {{[^@]+}}@test_invariant_load_scope
; USE_ASSUME-SAME: (i32* [[P:%.*]])
; USE_ASSUME-NEXT:    [[V1:%.*]] = load i32, i32* [[P]], align 4, !invariant.load !0
; USE_ASSUME-NEXT:    call void @clobber()
; USE_ASSUME-NEXT:    call void @llvm.assume(i1 true) [ "dereferenceable"(i32* [[P]], i64 4), "nonnull"(i32* [[P]]), "align"(i32* [[P]], i64 4) ]
; USE_ASSUME-NEXT:    ret i32 0
;
  %v1 = load i32, i32* %p, !invariant.load !{}
  call void @clobber()
  %v2 = load i32, i32* %p
  %sub = sub i32 %v1, %v2
  ret i32 %sub
}

; USE_ASSUME: declare void @llvm.assume(i1 noundef)
