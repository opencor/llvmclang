; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -instcombine %s -S -o - | FileCheck %s

; Clamp positive to allOnes:
; E.g., clamp255 implemented in a shifty way, could be optimized as v > 255 ? 255 : v, where sub hasNoSignedWrap.
; int32 clamp255(int32 v) {
;   return (((255 - (v)) >> 31) | (v)) & 255;
; }
;

; Scalar Types

define i32 @clamp255_i32(i32 %x) {
; CHECK-LABEL: @clamp255_i32(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 [[X:%.*]], 255
; CHECK-NEXT:    [[OR:%.*]] = select i1 [[TMP1]], i32 [[X]], i32 255
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[OR]], 255
; CHECK-NEXT:    ret i32 [[AND]]
;
  %sub = sub nsw i32 255, %x
  %shr = ashr i32 %sub, 31
  %or = or i32 %shr, %x
  %and = and i32 %or, 255
  ret i32 %and
}

define i8 @sub_ashr_or_i8(i8 %x, i8 %y) {
; CHECK-LABEL: @sub_ashr_or_i8(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i8 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[OR:%.*]] = select i1 [[TMP1]], i8 -1, i8 [[X]]
; CHECK-NEXT:    ret i8 [[OR]]
;
  %sub = sub nsw i8 %y, %x
  %shr = ashr i8 %sub, 7
  %or = or i8 %shr, %x
  ret i8 %or
}

define i16 @sub_ashr_or_i16(i16 %x, i16 %y) {
; CHECK-LABEL: @sub_ashr_or_i16(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i16 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[OR:%.*]] = select i1 [[TMP1]], i16 -1, i16 [[X]]
; CHECK-NEXT:    ret i16 [[OR]]
;
  %sub = sub nsw i16 %y, %x
  %shr = ashr i16 %sub, 15
  %or = or i16 %shr, %x
  ret i16 %or
}

define i32 @sub_ashr_or_i32(i32 %x, i32 %y) {
; CHECK-LABEL: @sub_ashr_or_i32(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[OR:%.*]] = select i1 [[TMP1]], i32 -1, i32 [[X]]
; CHECK-NEXT:    ret i32 [[OR]]
;
  %sub = sub nsw i32 %y, %x
  %shr = ashr i32 %sub, 31
  %or = or i32 %shr, %x
  ret i32 %or
}

define i64 @sub_ashr_or_i64(i64 %x, i64 %y) {
; CHECK-LABEL: @sub_ashr_or_i64(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i64 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[OR:%.*]] = select i1 [[TMP1]], i64 -1, i64 [[X]]
; CHECK-NEXT:    ret i64 [[OR]]
;
  %sub = sub nsw i64 %y, %x
  %shr = ashr i64 %sub, 63
  %or = or i64 %shr, %x
  ret i64 %or
}

; nuw nsw

define i32 @sub_ashr_or_i32_nuw_nsw(i32 %x, i32 %y) {
; CHECK-LABEL: @sub_ashr_or_i32_nuw_nsw(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[OR:%.*]] = select i1 [[TMP1]], i32 -1, i32 [[X]]
; CHECK-NEXT:    ret i32 [[OR]]
;
  %sub = sub nuw nsw i32 %y, %x
  %shr = ashr i32 %sub, 31
  %or = or i32 %shr, %x
  ret i32 %or
}

; Commute

define i32 @sub_ashr_or_i32_commute(i32 %x, i32 %y) {
; CHECK-LABEL: @sub_ashr_or_i32_commute(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[OR:%.*]] = select i1 [[TMP1]], i32 -1, i32 [[X]]
; CHECK-NEXT:    ret i32 [[OR]]
;
  %sub = sub nsw i32 %y, %x
  %shr = ashr i32 %sub, 31
  %or = or i32 %x, %shr  ; commute %shr and %x
  ret i32 %or
}

; Vector Types

define <4 x i32> @sub_ashr_or_i32_vec(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: @sub_ashr_or_i32_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt <4 x i32> [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[OR:%.*]] = select <4 x i1> [[TMP1]], <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, <4 x i32> [[X]]
; CHECK-NEXT:    ret <4 x i32> [[OR]]
;
  %sub = sub nsw <4 x i32> %y, %x
  %shr = ashr <4 x i32> %sub, <i32 31, i32 31, i32 31, i32 31>
  %or = or <4 x i32> %shr, %x
  ret <4 x i32> %or
}

define <4 x i32> @sub_ashr_or_i32_vec_nuw_nsw(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: @sub_ashr_or_i32_vec_nuw_nsw(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt <4 x i32> [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[OR:%.*]] = select <4 x i1> [[TMP1]], <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, <4 x i32> [[X]]
; CHECK-NEXT:    ret <4 x i32> [[OR]]
;
  %sub = sub nuw nsw <4 x i32> %y, %x
  %shr = ashr <4 x i32> %sub, <i32 31, i32 31, i32 31, i32 31>
  %or = or <4 x i32> %shr, %x
  ret <4 x i32> %or
}

define <4 x i32> @sub_ashr_or_i32_vec_commute(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: @sub_ashr_or_i32_vec_commute(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt <4 x i32> [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[OR:%.*]] = select <4 x i1> [[TMP1]], <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, <4 x i32> [[X]]
; CHECK-NEXT:    ret <4 x i32> [[OR]]
;
  %sub = sub nsw <4 x i32> %y, %x
  %shr = ashr <4 x i32> %sub, <i32 31, i32 31, i32 31, i32 31>
  %or = or <4 x i32> %x, %shr
  ret <4 x i32> %or
}

; Extra uses

define i32 @sub_ashr_or_i32_extra_use_sub(i32 %x, i32 %y, i32* %p) {
; CHECK-LABEL: @sub_ashr_or_i32_extra_use_sub(
; CHECK-NEXT:    [[SUB:%.*]] = sub nsw i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    store i32 [[SUB]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 [[Y]], [[X]]
; CHECK-NEXT:    [[OR:%.*]] = select i1 [[TMP1]], i32 -1, i32 [[X]]
; CHECK-NEXT:    ret i32 [[OR]]
;
  %sub = sub nsw i32 %y, %x
  store i32 %sub, i32* %p
  %shr = ashr i32 %sub, 31
  %or = or i32 %shr, %x
  ret i32 %or
}

define i32 @sub_ashr_or_i32_extra_use_or(i32 %x, i32 %y, i32* %p) {
; CHECK-LABEL: @sub_ashr_or_i32_extra_use_or(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[OR:%.*]] = select i1 [[TMP1]], i32 -1, i32 [[X]]
; CHECK-NEXT:    store i32 [[OR]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    ret i32 [[OR]]
;
  %sub = sub nsw i32 %y, %x
  %shr = ashr i32 %sub, 31
  %or = or i32 %shr, %x
  store i32 %or, i32* %p
  ret i32 %or
}

; Negative Tests

define i32 @sub_ashr_or_i32_extra_use_ashr(i32 %x, i32 %y, i32* %p) {
; CHECK-LABEL: @sub_ashr_or_i32_extra_use_ashr(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp slt i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[SHR:%.*]] = sext i1 [[TMP1]] to i32
; CHECK-NEXT:    store i32 [[SHR]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[OR:%.*]] = or i32 [[SHR]], [[X]]
; CHECK-NEXT:    ret i32 [[OR]]
;
  %sub = sub nsw i32 %y, %x
  %shr = ashr i32 %sub, 31
  store i32 %shr, i32* %p
  %or = or i32 %shr, %x
  ret i32 %or
}

define i32 @sub_ashr_or_i32_no_nsw_nuw(i32 %x, i32 %y) {
; CHECK-LABEL: @sub_ashr_or_i32_no_nsw_nuw(
; CHECK-NEXT:    [[SUB:%.*]] = sub i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[SHR:%.*]] = ashr i32 [[SUB]], 31
; CHECK-NEXT:    [[OR:%.*]] = or i32 [[SHR]], [[X]]
; CHECK-NEXT:    ret i32 [[OR]]
;
  %sub = sub i32 %y, %x
  %shr = ashr i32 %sub, 31
  %or = or i32 %shr, %x
  ret i32 %or
}

define <4 x i32> @sub_ashr_or_i32_vec_undef1(<4 x i32> %x) {
; CHECK-LABEL: @sub_ashr_or_i32_vec_undef1(
; CHECK-NEXT:    [[SUB:%.*]] = sub <4 x i32> <i32 255, i32 255, i32 undef, i32 255>, [[X:%.*]]
; CHECK-NEXT:    [[SHR:%.*]] = ashr <4 x i32> [[SUB]], <i32 31, i32 31, i32 31, i32 31>
; CHECK-NEXT:    [[OR:%.*]] = or <4 x i32> [[SHR]], [[X]]
; CHECK-NEXT:    ret <4 x i32> [[OR]]
;
  %sub = sub <4 x i32> <i32 255, i32 255, i32 undef, i32 255>, %x
  %shr = ashr <4 x i32> %sub, <i32 31, i32 31, i32 31, i32 31>
  %or = or <4 x i32> %shr, %x
  ret <4 x i32> %or
}

define <4 x i32> @sub_ashr_or_i32_vec_undef2(<4 x i32> %x) {
; CHECK-LABEL: @sub_ashr_or_i32_vec_undef2(
; CHECK-NEXT:    [[SUB:%.*]] = sub nsw <4 x i32> <i32 255, i32 255, i32 255, i32 255>, [[X:%.*]]
; CHECK-NEXT:    [[SHR:%.*]] = ashr <4 x i32> [[SUB]], <i32 undef, i32 31, i32 31, i32 31>
; CHECK-NEXT:    [[OR:%.*]] = or <4 x i32> [[SHR]], [[X]]
; CHECK-NEXT:    ret <4 x i32> [[OR]]
;
  %sub = sub nsw <4 x i32> <i32 255, i32 255, i32 255, i32 255>, %x
  %shr = ashr <4 x i32> %sub, <i32 undef, i32 31, i32 31, i32 31>
  %or = or <4 x i32> %shr, %x
  ret <4 x i32> %or
}

define i32 @sub_ashr_or_i32_shift_wrong_bit(i32 %x, i32 %y) {
; CHECK-LABEL: @sub_ashr_or_i32_shift_wrong_bit(
; CHECK-NEXT:    [[SUB:%.*]] = sub nsw i32 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[SHR:%.*]] = ashr i32 [[SUB]], 11
; CHECK-NEXT:    [[OR:%.*]] = or i32 [[SHR]], [[X]]
; CHECK-NEXT:    ret i32 [[OR]]
;
  %sub = sub nsw i32 %y, %x
  %shr = ashr i32 %sub, 11
  %or = or i32 %shr, %x
  ret i32 %or
}
