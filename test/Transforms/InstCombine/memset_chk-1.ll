; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; Test lib call simplification of __memset_chk calls with various values
; for dstlen and len.
;
; RUN: opt < %s -instcombine -S | FileCheck %s
; rdar://7719085

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"

%struct.T = type { [100 x i32], [100 x i32], [1024 x i8] }
@t = common global %struct.T zeroinitializer

; Check cases where dstlen >= len.

define i8* @test_simplify1() {
; CHECK-LABEL: @test_simplify1(
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* nonnull align 4 dereferenceable(1824) bitcast (%struct.T* @t to i8*), i8 0, i64 1824, i1 false)
; CHECK-NEXT:    ret i8* bitcast (%struct.T* @t to i8*)
;
  %dst = bitcast %struct.T* @t to i8*

  %ret = call i8* @__memset_chk(i8* %dst, i32 0, i64 1824, i64 1824)
  ret i8* %ret
}

define i8* @test_simplify2() {
; CHECK-LABEL: @test_simplify2(
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* nonnull align 4 dereferenceable(1824) bitcast (%struct.T* @t to i8*), i8 0, i64 1824, i1 false)
; CHECK-NEXT:    ret i8* bitcast (%struct.T* @t to i8*)
;
  %dst = bitcast %struct.T* @t to i8*

  %ret = call i8* @__memset_chk(i8* %dst, i32 0, i64 1824, i64 3648)
  ret i8* %ret
}

define i8* @test_simplify3() {
; CHECK-LABEL: @test_simplify3(
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* nonnull align 4 dereferenceable(1824) bitcast (%struct.T* @t to i8*), i8 0, i64 1824, i1 false)
; CHECK-NEXT:    ret i8* bitcast (%struct.T* @t to i8*)
;
  %dst = bitcast %struct.T* @t to i8*

  %ret = call i8* @__memset_chk(i8* %dst, i32 0, i64 1824, i64 -1)
  ret i8* %ret
}

; Check cases where dstlen < len.

define i8* @test_no_simplify1() {
; CHECK-LABEL: @test_no_simplify1(
; CHECK-NEXT:    [[RET:%.*]] = call i8* @__memset_chk(i8* bitcast (%struct.T* @t to i8*), i32 0, i64 1824, i64 400)
; CHECK-NEXT:    ret i8* [[RET]]
;
  %dst = bitcast %struct.T* @t to i8*

  %ret = call i8* @__memset_chk(i8* %dst, i32 0, i64 1824, i64 400)
  ret i8* %ret
}

define i8* @test_no_simplify2() {
; CHECK-LABEL: @test_no_simplify2(
; CHECK-NEXT:    [[RET:%.*]] = call i8* @__memset_chk(i8* bitcast (%struct.T* @t to i8*), i32 0, i64 1824, i64 0)
; CHECK-NEXT:    ret i8* [[RET]]
;
  %dst = bitcast %struct.T* @t to i8*

  %ret = call i8* @__memset_chk(i8* %dst, i32 0, i64 1824, i64 0)
  ret i8* %ret
}

; Test that RAUW in SimplifyLibCalls for __memset_chk generates valid IR
define i32 @test_rauw(i8* %a, i8* %b, i8** %c) {
; CHECK-LABEL: @test_rauw(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CALL49:%.*]] = call i64 @strlen(i8* nonnull dereferenceable(1) [[A:%.*]])
; CHECK-NEXT:    [[ADD180:%.*]] = add i64 [[CALL49]], 1
; CHECK-NEXT:    [[YO107:%.*]] = call i64 @llvm.objectsize.i64.p0i8(i8* [[B:%.*]], i1 false, i1 false, i1 false)
; CHECK-NEXT:    [[CALL50:%.*]] = call i8* @__memmove_chk(i8* [[B]], i8* [[A]], i64 [[ADD180]], i64 [[YO107]])
; CHECK-NEXT:    [[STRLEN:%.*]] = call i64 @strlen(i8* nonnull dereferenceable(1) [[B]])
; CHECK-NEXT:    [[STRCHR1:%.*]] = getelementptr i8, i8* [[B]], i64 [[STRLEN]]
; CHECK-NEXT:    [[D:%.*]] = load i8*, i8** [[C:%.*]], align 8
; CHECK-NEXT:    [[SUB182:%.*]] = ptrtoint i8* [[D]] to i64
; CHECK-NEXT:    [[SUB183:%.*]] = ptrtoint i8* [[B]] to i64
; CHECK-NEXT:    [[SUB184:%.*]] = sub i64 [[SUB182]], [[SUB183]]
; CHECK-NEXT:    [[ADD52_I_I:%.*]] = add nsw i64 [[SUB184]], 1
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* align 1 [[STRCHR1]], i8 0, i64 [[ADD52_I_I]], i1 false)
; CHECK-NEXT:    ret i32 4
;
entry:
  %call49 = call i64 @strlen(i8* %a)
  %add180 = add i64 %call49, 1
  %yo107 = call i64 @llvm.objectsize.i64.p0i8(i8* %b, i1 false, i1 false, i1 false)
  %call50 = call i8* @__memmove_chk(i8* %b, i8* %a, i64 %add180, i64 %yo107)
  %call51i = call i8* @strrchr(i8* %b, i32 0)
  %d = load i8*, i8** %c, align 8
  %sub182 = ptrtoint i8* %d to i64
  %sub183 = ptrtoint i8* %b to i64
  %sub184 = sub i64 %sub182, %sub183
  %add52.i.i = add nsw i64 %sub184, 1
  %call185 = call i8* @__memset_chk(i8* %call51i, i32 0, i64 %add52.i.i, i64 -1)
  ret i32 4
}

declare i8* @__memmove_chk(i8*, i8*, i64, i64)
declare i8* @strrchr(i8*, i32)
declare i64 @strlen(i8* nocapture)
declare i64 @llvm.objectsize.i64.p0i8(i8*, i1, i1, i1)

declare i8* @__memset_chk(i8*, i32, i64, i64)

; FIXME: memset(malloc(x), 0, x) -> calloc(1, x)

define float* @pr25892(i64 %size) #0 {
; CHECK-LABEL: @pr25892(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CALL:%.*]] = tail call i8* @malloc(i64 [[SIZE:%.*]]) [[ATTR3:#.*]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8* [[CALL]], null
; CHECK-NEXT:    br i1 [[CMP]], label [[CLEANUP:%.*]], label [[IF_END:%.*]]
; CHECK:       if.end:
; CHECK-NEXT:    [[BC:%.*]] = bitcast i8* [[CALL]] to float*
; CHECK-NEXT:    [[CALL2:%.*]] = tail call i64 @llvm.objectsize.i64.p0i8(i8* nonnull [[CALL]], i1 false, i1 false, i1 false)
; CHECK-NEXT:    [[CALL3:%.*]] = tail call i8* @__memset_chk(i8* nonnull [[CALL]], i32 0, i64 [[SIZE]], i64 [[CALL2]]) [[ATTR3]]
; CHECK-NEXT:    br label [[CLEANUP]]
; CHECK:       cleanup:
; CHECK-NEXT:    [[RETVAL_0:%.*]] = phi float* [ [[BC]], [[IF_END]] ], [ null, [[ENTRY:%.*]] ]
; CHECK-NEXT:    ret float* [[RETVAL_0]]
;
entry:
  %call = tail call i8* @malloc(i64 %size) #1
  %cmp = icmp eq i8* %call, null
  br i1 %cmp, label %cleanup, label %if.end
if.end:
  %bc = bitcast i8* %call to float*
  %call2 = tail call i64 @llvm.objectsize.i64.p0i8(i8* nonnull %call, i1 false, i1 false, i1 false)
  %call3 = tail call i8* @__memset_chk(i8* nonnull %call, i32 0, i64 %size, i64 %call2) #1
  br label %cleanup
cleanup:
  %retval.0 = phi float* [ %bc, %if.end ], [ null, %entry ]
  ret float* %retval.0

}

define i8* @test_no_incompatible_attr(i8* %mem, i32 %val, i32 %size) {
; CHECK-LABEL: @test_no_incompatible_attr(
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* nonnull align 4 dereferenceable(1824) bitcast (%struct.T* @t to i8*), i8 0, i64 1824, i1 false)
; CHECK-NEXT:    ret i8* bitcast (%struct.T* @t to i8*)
;
  %dst = bitcast %struct.T* @t to i8*

  %ret = call dereferenceable(1) i8* @__memset_chk(i8* %dst, i32 0, i64 1824, i64 1824)
  ret i8* %ret
}

declare noalias i8* @malloc(i64) #1

attributes #0 = { nounwind ssp uwtable }
attributes #1 = { nounwind }
attributes #2 = { nounwind readnone }

