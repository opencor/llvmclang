; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn-amd-amdhsa < %s | FileCheck %s

; FIXME: Inefficient codegen which skips an optimization of load +
; extractelement when the vector element type is not byte-sized.
define i1 @extractloadi1(<8 x i1> *%ptr, i32 %idx) {
; CHECK-LABEL: extractloadi1:
; CHECK:       ; %bb.0:
; CHECK-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; CHECK-NEXT:    flat_load_ubyte v0, v[0:1]
; CHECK-NEXT:    v_and_b32_e32 v1, 7, v2
; CHECK-NEXT:    v_lshr_b32_e64 v9, s32, 6
; CHECK-NEXT:    v_or_b32_e32 v1, v9, v1
; CHECK-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; CHECK-NEXT:    v_bfe_u32 v2, v0, 1, 1
; CHECK-NEXT:    v_bfe_u32 v3, v0, 2, 2
; CHECK-NEXT:    v_bfe_u32 v4, v0, 3, 1
; CHECK-NEXT:    v_lshrrev_b32_e32 v5, 4, v0
; CHECK-NEXT:    v_bfe_u32 v6, v0, 5, 1
; CHECK-NEXT:    v_lshrrev_b32_e32 v7, 6, v0
; CHECK-NEXT:    v_lshrrev_b32_e32 v8, 7, v0
; CHECK-NEXT:    buffer_store_byte v0, off, s[0:3], s32
; CHECK-NEXT:    buffer_store_byte v8, off, s[0:3], s32 offset:7
; CHECK-NEXT:    buffer_store_byte v7, off, s[0:3], s32 offset:6
; CHECK-NEXT:    buffer_store_byte v6, off, s[0:3], s32 offset:5
; CHECK-NEXT:    buffer_store_byte v5, off, s[0:3], s32 offset:4
; CHECK-NEXT:    buffer_store_byte v4, off, s[0:3], s32 offset:3
; CHECK-NEXT:    buffer_store_byte v3, off, s[0:3], s32 offset:2
; CHECK-NEXT:    buffer_store_byte v2, off, s[0:3], s32 offset:1
; CHECK-NEXT:    buffer_load_ubyte v0, v1, s[0:3], 0 offen
; CHECK-NEXT:    s_waitcnt vmcnt(0)
; CHECK-NEXT:    s_setpc_b64 s[30:31]
  %val = load <8 x i1>, <8 x i1> *%ptr
  %ret = extractelement <8 x i1> %val, i32 %idx
  ret i1 %ret
}
