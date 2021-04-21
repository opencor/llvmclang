; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=skylake-avx512 -mattr=prefer-256-bit | FileCheck %s

define void @test(<64 x i8>* %a0) #0 {
; CHECK-LABEL: test:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vmovdqu (%rdi), %xmm0
; CHECK-NEXT:    vpblendd {{.*#+}} xmm0 = mem[0],xmm0[1,2,3]
; CHECK-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[4,4,5,5,0,0,1,1,u,u,u,u,u,u,u,u]
; CHECK-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],mem[0],xmm0[1],mem[1]
; CHECK-NEXT:    vpternlogq $15, %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    vpextrb $1, %xmm0, (%rax)
; CHECK-NEXT:    vpextrb $4, %xmm0, (%rax)
; CHECK-NEXT:    vpextrb $8, %xmm0, (%rax)
; CHECK-NEXT:    retq
  %load = load <64 x i8>, <64 x i8>* %a0, align 1
  %shuf = shufflevector <64 x i8> %load, <64 x i8> undef, <16 x i32> <i32 0, i32 4, i32 8, i32 12, i32 16, i32 20, i32 24, i32 28, i32 32, i32 36, i32 40, i32 44, i32 48, i32 52, i32 56, i32 60>
  %xor = xor <16 x i8> %shuf, <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>
  %i1 = extractelement <16 x i8> %xor, i32 1
  %i2 = extractelement <16 x i8> %xor, i32 4
  %i3 = extractelement <16 x i8> %xor, i32 8
  store i8 %i1, i8* undef, align 1
  store i8 %i2, i8* undef, align 1
  store i8 %i3, i8* undef, align 1
  ret void
}

attributes #0 = { "min-legal-vector-width"="0" "target-cpu"="skylake-avx512" }
