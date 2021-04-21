; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -indvars -S | FileCheck %s
; RUN: opt < %s -passes=indvars -S | FileCheck %s

define void @test_signed(i32 %start) {
; CHECK-LABEL: @test_signed(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[COND:%.*]] = icmp ne i32 [[START:%.*]], -2147483648
; CHECK-NEXT:    br i1 [[COND]], label [[LOOP_PREHEADER:%.*]], label [[EXIT:%.*]]
; CHECK:       loop.preheader:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ [[IV_NEXT:%.*]], [[GUARDED:%.*]] ], [ [[START]], [[LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], -1
; CHECK-NEXT:    [[CHECK:%.*]] = icmp slt i32 [[IV_NEXT]], [[IV]]
; CHECK-NEXT:    br i1 [[CHECK]], label [[GUARDED]], label [[FAIL:%.*]]
; CHECK:       guarded:
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp ne i32 [[IV]], -2147483648
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; CHECK:       exit.loopexit:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
; CHECK:       fail:
; CHECK-NEXT:    unreachable
;
entry:
  %cond = icmp ne i32 %start, -2147483648
  br i1 %cond, label %loop, label %exit

loop:
  %iv = phi i32 [%start, %entry], [%iv.next, %guarded]
  %iv.next = add i32 %iv, -1
  %check = icmp slt i32 %iv.next, %iv
  br i1 %check, label %guarded, label %fail

guarded:
  %loop.cond = icmp ne i32 %iv, -2147483648
  br i1 %loop.cond, label %loop, label %exit

exit:
  ret void

fail:
  unreachable
}

define void @test_unsigned(i32 %start) {
; CHECK-LABEL: @test_unsigned(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[COND:%.*]] = icmp ne i32 [[START:%.*]], 0
; CHECK-NEXT:    br i1 [[COND]], label [[LOOP_PREHEADER:%.*]], label [[EXIT:%.*]]
; CHECK:       loop.preheader:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ [[IV_NEXT:%.*]], [[GUARDED:%.*]] ], [ [[START]], [[LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[IV_NEXT]] = add i32 [[IV]], -1
; CHECK-NEXT:    [[CHECK:%.*]] = icmp ult i32 [[IV_NEXT]], [[IV]]
; CHECK-NEXT:    br i1 [[CHECK]], label [[GUARDED]], label [[FAIL:%.*]]
; CHECK:       guarded:
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp ne i32 [[IV]], 0
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; CHECK:       exit.loopexit:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
; CHECK:       fail:
; CHECK-NEXT:    unreachable
;
entry:
  %cond = icmp ne i32 %start, 0
  br i1 %cond, label %loop, label %exit

loop:
  %iv = phi i32 [%start, %entry], [%iv.next, %guarded]
  %iv.next = add i32 %iv, -1
  %check = icmp ult i32 %iv.next, %iv
  br i1 %check, label %guarded, label %fail

guarded:
  %loop.cond = icmp ne i32 %iv, 0
  br i1 %loop.cond, label %loop, label %exit

exit:
  ret void

fail:
  unreachable
}
