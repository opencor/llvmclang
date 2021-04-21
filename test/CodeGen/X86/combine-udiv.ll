; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,SSE,SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefixes=CHECK,SSE,SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx  | FileCheck %s --check-prefixes=CHECK,AVX,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=CHECK,AVX,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx,+xop | FileCheck %s --check-prefixes=CHECK,XOP

; fold (udiv x, 1) -> x
define i32 @combine_udiv_by_one(i32 %x) {
; CHECK-LABEL: combine_udiv_by_one:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  %1 = udiv i32 %x, 1
  ret i32 %1
}

define <4 x i32> @combine_vec_udiv_by_one(<4 x i32> %x) {
; CHECK-LABEL: combine_vec_udiv_by_one:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retq
  %1 = udiv <4 x i32> %x, <i32 1, i32 1, i32 1, i32 1>
  ret <4 x i32> %1
}

; fold (udiv x, -1) -> select((icmp eq x, -1), 1, 0)
define i32 @combine_udiv_by_negone(i32 %x) {
; CHECK-LABEL: combine_udiv_by_negone:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    cmpl $-1, %edi
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    retq
  %1 = udiv i32 %x, -1
  ret i32 %1
}

define <4 x i32> @combine_vec_udiv_by_negone(<4 x i32> %x) {
; SSE-LABEL: combine_vec_udiv_by_negone:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE-NEXT:    pcmpeqd %xmm1, %xmm0
; SSE-NEXT:    psrld $31, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_udiv_by_negone:
; AVX:       # %bb.0:
; AVX-NEXT:    vpcmpeqd %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpcmpeqd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpsrld $31, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_by_negone:
; XOP:       # %bb.0:
; XOP-NEXT:    vpcmpeqd %xmm1, %xmm1, %xmm1
; XOP-NEXT:    vpcomeqd %xmm1, %xmm0, %xmm0
; XOP-NEXT:    vpsrld $31, %xmm0, %xmm0
; XOP-NEXT:    retq
  %1 = udiv <4 x i32> %x, <i32 -1, i32 -1, i32 -1, i32 -1>
  ret <4 x i32> %1
}

; fold (udiv x, INT_MIN) -> (srl x, 31)
define i32 @combine_udiv_by_minsigned(i32 %x) {
; CHECK-LABEL: combine_udiv_by_minsigned:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    shrl $31, %eax
; CHECK-NEXT:    retq
  %1 = udiv i32 %x, -2147483648
  ret i32 %1
}

define <4 x i32> @combine_vec_udiv_by_minsigned(<4 x i32> %x) {
; SSE-LABEL: combine_vec_udiv_by_minsigned:
; SSE:       # %bb.0:
; SSE-NEXT:    psrld $31, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_udiv_by_minsigned:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsrld $31, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_by_minsigned:
; XOP:       # %bb.0:
; XOP-NEXT:    vpsrld $31, %xmm0, %xmm0
; XOP-NEXT:    retq
  %1 = udiv <4 x i32> %x, <i32 -2147483648, i32 -2147483648, i32 -2147483648, i32 -2147483648>
  ret <4 x i32> %1
}

; fold (udiv 0, x) -> 0
define i32 @combine_udiv_zero(i32 %x) {
; CHECK-LABEL: combine_udiv_zero:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    retq
  %1 = udiv i32 0, %x
  ret i32 %1
}

define <4 x i32> @combine_vec_udiv_zero(<4 x i32> %x) {
; SSE-LABEL: combine_vec_udiv_zero:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_udiv_zero:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_zero:
; XOP:       # %bb.0:
; XOP-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; XOP-NEXT:    retq
  %1 = udiv <4 x i32> zeroinitializer, %x
  ret <4 x i32> %1
}

; fold (udiv x, x) -> 1
define i32 @combine_udiv_dupe(i32 %x) {
; CHECK-LABEL: combine_udiv_dupe:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $1, %eax
; CHECK-NEXT:    retq
  %1 = udiv i32 %x, %x
  ret i32 %1
}

define <4 x i32> @combine_vec_udiv_dupe(<4 x i32> %x) {
; SSE-LABEL: combine_vec_udiv_dupe:
; SSE:       # %bb.0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [1,1,1,1]
; SSE-NEXT:    retq
;
; AVX1-LABEL: combine_vec_udiv_dupe:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovaps {{.*#+}} xmm0 = [1,1,1,1]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_vec_udiv_dupe:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vbroadcastss {{.*#+}} xmm0 = [1,1,1,1]
; AVX2-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_dupe:
; XOP:       # %bb.0:
; XOP-NEXT:    vmovaps {{.*#+}} xmm0 = [1,1,1,1]
; XOP-NEXT:    retq
  %1 = udiv <4 x i32> %x, %x
  ret <4 x i32> %1
}

; fold (udiv x, (1 << c)) -> x >>u c
define <4 x i32> @combine_vec_udiv_by_pow2a(<4 x i32> %x) {
; SSE-LABEL: combine_vec_udiv_by_pow2a:
; SSE:       # %bb.0:
; SSE-NEXT:    psrld $2, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_udiv_by_pow2a:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsrld $2, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_by_pow2a:
; XOP:       # %bb.0:
; XOP-NEXT:    vpsrld $2, %xmm0, %xmm0
; XOP-NEXT:    retq
  %1 = udiv <4 x i32> %x, <i32 4, i32 4, i32 4, i32 4>
  ret <4 x i32> %1
}

define <4 x i32> @combine_vec_udiv_by_pow2b(<4 x i32> %x) {
; SSE2-LABEL: combine_vec_udiv_by_pow2b:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrld $4, %xmm1
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    psrld $3, %xmm2
; SSE2-NEXT:    punpckhqdq {{.*#+}} xmm2 = xmm2[1],xmm1[1]
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrld $2, %xmm1
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,3],xmm2[0,3]
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_udiv_by_pow2b:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    psrld $3, %xmm1
; SSE41-NEXT:    pblendw {{.*#+}} xmm1 = xmm0[0,1,2,3],xmm1[4,5,6,7]
; SSE41-NEXT:    psrld $4, %xmm0
; SSE41-NEXT:    psrld $2, %xmm2
; SSE41-NEXT:    pblendw {{.*#+}} xmm2 = xmm2[0,1,2,3],xmm0[4,5,6,7]
; SSE41-NEXT:    pblendw {{.*#+}} xmm1 = xmm1[0,1],xmm2[2,3],xmm1[4,5],xmm2[6,7]
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX1-LABEL: combine_vec_udiv_by_pow2b:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpsrld $4, %xmm0, %xmm1
; AVX1-NEXT:    vpsrld $2, %xmm0, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm2[0,1,2,3],xmm1[4,5,6,7]
; AVX1-NEXT:    vpsrld $3, %xmm0, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm2[4,5,6,7]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3],xmm0[4,5],xmm1[6,7]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_vec_udiv_by_pow2b:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpsrlvd {{.*}}(%rip), %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_by_pow2b:
; XOP:       # %bb.0:
; XOP-NEXT:    vpshld {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    retq
  %1 = udiv <4 x i32> %x, <i32 1, i32 4, i32 8, i32 16>
  ret <4 x i32> %1
}

define <4 x i32> @combine_vec_udiv_by_pow2c(<4 x i32> %x, <4 x i32> %y) {
; SSE2-LABEL: combine_vec_udiv_by_pow2c:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    psrld %xmm2, %xmm3
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    psrld %xmm4, %xmm2
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm4
; SSE2-NEXT:    psrld %xmm3, %xmm4
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    psrld %xmm1, %xmm0
; SSE2-NEXT:    punpckhqdq {{.*#+}} xmm0 = xmm0[1],xmm4[1]
; SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,3],xmm0[0,3]
; SSE2-NEXT:    movaps %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_udiv_by_pow2c:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pshuflw {{.*#+}} xmm2 = xmm1[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    psrld %xmm2, %xmm3
; SSE41-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,2,3]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm4 = xmm2[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm5
; SSE41-NEXT:    psrld %xmm4, %xmm5
; SSE41-NEXT:    pblendw {{.*#+}} xmm5 = xmm3[0,1,2,3],xmm5[4,5,6,7]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    psrld %xmm1, %xmm3
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm2[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    psrld %xmm1, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm3[0,1,2,3],xmm0[4,5,6,7]
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1],xmm5[2,3],xmm0[4,5],xmm5[6,7]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: combine_vec_udiv_by_pow2c:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpsrldq {{.*#+}} xmm2 = xmm1[12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vpsrld %xmm2, %xmm0, %xmm2
; AVX1-NEXT:    vpsrlq $32, %xmm1, %xmm3
; AVX1-NEXT:    vpsrld %xmm3, %xmm0, %xmm3
; AVX1-NEXT:    vpblendw {{.*#+}} xmm2 = xmm3[0,1,2,3],xmm2[4,5,6,7]
; AVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpunpckhdq {{.*#+}} xmm3 = xmm1[2],xmm3[2],xmm1[3],xmm3[3]
; AVX1-NEXT:    vpsrld %xmm3, %xmm0, %xmm3
; AVX1-NEXT:    vpmovzxdq {{.*#+}} xmm1 = xmm1[0],zero,xmm1[1],zero
; AVX1-NEXT:    vpsrld %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm3[4,5,6,7]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_vec_udiv_by_pow2c:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_by_pow2c:
; XOP:       # %bb.0:
; XOP-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; XOP-NEXT:    vpsubd %xmm1, %xmm2, %xmm1
; XOP-NEXT:    vpshld %xmm1, %xmm0, %xmm0
; XOP-NEXT:    retq
  %1 = shl <4 x i32> <i32 1, i32 1, i32 1, i32 1>, %y
  %2 = udiv <4 x i32> %x, %1
  ret <4 x i32> %2
}

; fold (udiv x, (shl c, y)) -> x >>u (log2(c)+y) iff c is power of 2
define <4 x i32> @combine_vec_udiv_by_shl_pow2a(<4 x i32> %x, <4 x i32> %y) {
; SSE2-LABEL: combine_vec_udiv_by_shl_pow2a:
; SSE2:       # %bb.0:
; SSE2-NEXT:    paddd {{.*}}(%rip), %xmm1
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    psrld %xmm2, %xmm3
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    psrld %xmm4, %xmm2
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm4
; SSE2-NEXT:    psrld %xmm3, %xmm4
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    psrld %xmm1, %xmm0
; SSE2-NEXT:    punpckhqdq {{.*#+}} xmm0 = xmm0[1],xmm4[1]
; SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,3],xmm0[0,3]
; SSE2-NEXT:    movaps %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_udiv_by_shl_pow2a:
; SSE41:       # %bb.0:
; SSE41-NEXT:    paddd {{.*}}(%rip), %xmm1
; SSE41-NEXT:    pshuflw {{.*#+}} xmm2 = xmm1[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    psrld %xmm2, %xmm3
; SSE41-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,2,3]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm4 = xmm2[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm5
; SSE41-NEXT:    psrld %xmm4, %xmm5
; SSE41-NEXT:    pblendw {{.*#+}} xmm5 = xmm3[0,1,2,3],xmm5[4,5,6,7]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    psrld %xmm1, %xmm3
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm2[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    psrld %xmm1, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm3[0,1,2,3],xmm0[4,5,6,7]
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1],xmm5[2,3],xmm0[4,5],xmm5[6,7]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: combine_vec_udiv_by_shl_pow2a:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpaddd {{.*}}(%rip), %xmm1, %xmm1
; AVX1-NEXT:    vpsrldq {{.*#+}} xmm2 = xmm1[12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vpsrld %xmm2, %xmm0, %xmm2
; AVX1-NEXT:    vpsrlq $32, %xmm1, %xmm3
; AVX1-NEXT:    vpsrld %xmm3, %xmm0, %xmm3
; AVX1-NEXT:    vpblendw {{.*#+}} xmm2 = xmm3[0,1,2,3],xmm2[4,5,6,7]
; AVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpunpckhdq {{.*#+}} xmm3 = xmm1[2],xmm3[2],xmm1[3],xmm3[3]
; AVX1-NEXT:    vpsrld %xmm3, %xmm0, %xmm3
; AVX1-NEXT:    vpmovzxdq {{.*#+}} xmm1 = xmm1[0],zero,xmm1[1],zero
; AVX1-NEXT:    vpsrld %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm3[4,5,6,7]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_vec_udiv_by_shl_pow2a:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm2 = [2,2,2,2]
; AVX2-NEXT:    vpaddd %xmm2, %xmm1, %xmm1
; AVX2-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_by_shl_pow2a:
; XOP:       # %bb.0:
; XOP-NEXT:    vmovdqa {{.*#+}} xmm2 = [4294967294,4294967294,4294967294,4294967294]
; XOP-NEXT:    vpsubd %xmm1, %xmm2, %xmm1
; XOP-NEXT:    vpshld %xmm1, %xmm0, %xmm0
; XOP-NEXT:    retq
  %1 = shl <4 x i32> <i32 4, i32 4, i32 4, i32 4>, %y
  %2 = udiv <4 x i32> %x, %1
  ret <4 x i32> %2
}

define <4 x i32> @combine_vec_udiv_by_shl_pow2b(<4 x i32> %x, <4 x i32> %y) {
; SSE2-LABEL: combine_vec_udiv_by_shl_pow2b:
; SSE2:       # %bb.0:
; SSE2-NEXT:    paddd {{.*}}(%rip), %xmm1
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    psrld %xmm2, %xmm3
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    psrld %xmm4, %xmm2
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm4
; SSE2-NEXT:    psrld %xmm3, %xmm4
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    psrld %xmm1, %xmm0
; SSE2-NEXT:    punpckhqdq {{.*#+}} xmm0 = xmm0[1],xmm4[1]
; SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,3],xmm0[0,3]
; SSE2-NEXT:    movaps %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_udiv_by_shl_pow2b:
; SSE41:       # %bb.0:
; SSE41-NEXT:    paddd {{.*}}(%rip), %xmm1
; SSE41-NEXT:    pshuflw {{.*#+}} xmm2 = xmm1[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    psrld %xmm2, %xmm3
; SSE41-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,2,3]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm4 = xmm2[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm5
; SSE41-NEXT:    psrld %xmm4, %xmm5
; SSE41-NEXT:    pblendw {{.*#+}} xmm5 = xmm3[0,1,2,3],xmm5[4,5,6,7]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    psrld %xmm1, %xmm3
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm2[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    psrld %xmm1, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm3[0,1,2,3],xmm0[4,5,6,7]
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1],xmm5[2,3],xmm0[4,5],xmm5[6,7]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: combine_vec_udiv_by_shl_pow2b:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpaddd {{.*}}(%rip), %xmm1, %xmm1
; AVX1-NEXT:    vpsrldq {{.*#+}} xmm2 = xmm1[12,13,14,15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX1-NEXT:    vpsrld %xmm2, %xmm0, %xmm2
; AVX1-NEXT:    vpsrlq $32, %xmm1, %xmm3
; AVX1-NEXT:    vpsrld %xmm3, %xmm0, %xmm3
; AVX1-NEXT:    vpblendw {{.*#+}} xmm2 = xmm3[0,1,2,3],xmm2[4,5,6,7]
; AVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpunpckhdq {{.*#+}} xmm3 = xmm1[2],xmm3[2],xmm1[3],xmm3[3]
; AVX1-NEXT:    vpsrld %xmm3, %xmm0, %xmm3
; AVX1-NEXT:    vpmovzxdq {{.*#+}} xmm1 = xmm1[0],zero,xmm1[1],zero
; AVX1-NEXT:    vpsrld %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm3[4,5,6,7]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_vec_udiv_by_shl_pow2b:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpaddd {{.*}}(%rip), %xmm1, %xmm1
; AVX2-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_by_shl_pow2b:
; XOP:       # %bb.0:
; XOP-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,4294967294,4294967293,4294967292]
; XOP-NEXT:    vpsubd %xmm1, %xmm2, %xmm1
; XOP-NEXT:    vpshld %xmm1, %xmm0, %xmm0
; XOP-NEXT:    retq
  %1 = shl <4 x i32> <i32 1, i32 4, i32 8, i32 16>, %y
  %2 = udiv <4 x i32> %x, %1
  ret <4 x i32> %2
}

; fold (udiv x, c1)
define i32 @combine_udiv_uniform(i32 %x) {
; CHECK-LABEL: combine_udiv_uniform:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %ecx
; CHECK-NEXT:    movl $2987803337, %eax # imm = 0xB21642C9
; CHECK-NEXT:    imulq %rcx, %rax
; CHECK-NEXT:    shrq $36, %rax
; CHECK-NEXT:    # kill: def $eax killed $eax killed $rax
; CHECK-NEXT:    retq
  %1 = udiv i32 %x, 23
  ret i32 %1
}

define <8 x i16> @combine_vec_udiv_uniform(<8 x i16> %x) {
; SSE-LABEL: combine_vec_udiv_uniform:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa {{.*#+}} xmm1 = [25645,25645,25645,25645,25645,25645,25645,25645]
; SSE-NEXT:    pmulhuw %xmm0, %xmm1
; SSE-NEXT:    psubw %xmm1, %xmm0
; SSE-NEXT:    psrlw $1, %xmm0
; SSE-NEXT:    paddw %xmm1, %xmm0
; SSE-NEXT:    psrlw $4, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_udiv_uniform:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm1
; AVX-NEXT:    vpsubw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpsrlw $1, %xmm0, %xmm0
; AVX-NEXT:    vpaddw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpsrlw $4, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_uniform:
; XOP:       # %bb.0:
; XOP-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm1
; XOP-NEXT:    vpsubw %xmm1, %xmm0, %xmm0
; XOP-NEXT:    vpsrlw $1, %xmm0, %xmm0
; XOP-NEXT:    vpaddw %xmm1, %xmm0, %xmm0
; XOP-NEXT:    vpsrlw $4, %xmm0, %xmm0
; XOP-NEXT:    retq
  %1 = udiv <8 x i16> %x, <i16 23, i16 23, i16 23, i16 23, i16 23, i16 23, i16 23, i16 23>
  ret <8 x i16> %1
}

define <8 x i16> @combine_vec_udiv_nonuniform(<8 x i16> %x) {
; SSE2-LABEL: combine_vec_udiv_nonuniform:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm1 = [65535,65535,65535,0,65535,65535,65535,65535]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pand %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    psrlw $3, %xmm3
; SSE2-NEXT:    pandn %xmm3, %xmm1
; SSE2-NEXT:    por %xmm2, %xmm1
; SSE2-NEXT:    pmulhuw {{.*}}(%rip), %xmm1
; SSE2-NEXT:    psubw %xmm1, %xmm0
; SSE2-NEXT:    pmulhuw {{.*}}(%rip), %xmm0
; SSE2-NEXT:    paddw %xmm1, %xmm0
; SSE2-NEXT:    movdqa {{.*#+}} xmm1 = [65535,65535,65535,0,0,65535,65535,0]
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    pmulhuw {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_udiv_nonuniform:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    psrlw $3, %xmm1
; SSE41-NEXT:    pblendw {{.*#+}} xmm1 = xmm0[0,1,2],xmm1[3],xmm0[4,5,6,7]
; SSE41-NEXT:    pmulhuw {{.*}}(%rip), %xmm1
; SSE41-NEXT:    psubw %xmm1, %xmm0
; SSE41-NEXT:    pmulhuw {{.*}}(%rip), %xmm0
; SSE41-NEXT:    paddw %xmm1, %xmm0
; SSE41-NEXT:    movdqa {{.*#+}} xmm1 = <4096,2048,8,u,u,2,2,u>
; SSE41-NEXT:    pmulhuw %xmm0, %xmm1
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm1[0,1,2],xmm0[3,4],xmm1[5,6],xmm0[7]
; SSE41-NEXT:    retq
;
; AVX-LABEL: combine_vec_udiv_nonuniform:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsrlw $3, %xmm0, %xmm1
; AVX-NEXT:    vpblendw {{.*#+}} xmm1 = xmm0[0,1,2],xmm1[3],xmm0[4,5,6,7]
; AVX-NEXT:    vpmulhuw {{.*}}(%rip), %xmm1, %xmm1
; AVX-NEXT:    vpsubw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    vpaddw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm1
; AVX-NEXT:    vpblendw {{.*#+}} xmm0 = xmm1[0,1,2],xmm0[3,4],xmm1[5,6],xmm0[7]
; AVX-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_nonuniform:
; XOP:       # %bb.0:
; XOP-NEXT:    vpshlw {{.*}}(%rip), %xmm0, %xmm1
; XOP-NEXT:    vpmulhuw {{.*}}(%rip), %xmm1, %xmm1
; XOP-NEXT:    vpsubw %xmm1, %xmm0, %xmm0
; XOP-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    vpaddw %xmm1, %xmm0, %xmm0
; XOP-NEXT:    vpshlw {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    retq
  %1 = udiv <8 x i16> %x, <i16 23, i16 34, i16 -23, i16 56, i16 128, i16 -1, i16 -256, i16 -32768>
  ret <8 x i16> %1
}

define <8 x i16> @combine_vec_udiv_nonuniform2(<8 x i16> %x) {
; SSE2-LABEL: combine_vec_udiv_nonuniform2:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [0,65535,65535,65535,65535,65535,65535,65535]
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    psrlw $1, %xmm0
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm1
; SSE2-NEXT:    pmulhuw {{.*}}(%rip), %xmm1
; SSE2-NEXT:    pmulhuw {{.*}}(%rip), %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_udiv_nonuniform2:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    psrlw $1, %xmm1
; SSE41-NEXT:    pblendw {{.*#+}} xmm1 = xmm1[0],xmm0[1,2,3,4,5,6,7]
; SSE41-NEXT:    pmulhuw {{.*}}(%rip), %xmm1
; SSE41-NEXT:    pmulhuw {{.*}}(%rip), %xmm1
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: combine_vec_udiv_nonuniform2:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsrlw $1, %xmm0, %xmm1
; AVX-NEXT:    vpblendw {{.*#+}} xmm0 = xmm1[0],xmm0[1,2,3,4,5,6,7]
; AVX-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_nonuniform2:
; XOP:       # %bb.0:
; XOP-NEXT:    vpshlw {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    vpshlw {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    retq
  %1 = udiv <8 x i16> %x, <i16 -34, i16 35, i16 36, i16 -37, i16 38, i16 -39, i16 40, i16 -41>
  ret <8 x i16> %1
}

define <8 x i16> @combine_vec_udiv_nonuniform3(<8 x i16> %x) {
; SSE-LABEL: combine_vec_udiv_nonuniform3:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa {{.*#+}} xmm1 = [9363,25645,18351,12137,2115,23705,1041,517]
; SSE-NEXT:    pmulhuw %xmm0, %xmm1
; SSE-NEXT:    psubw %xmm1, %xmm0
; SSE-NEXT:    psrlw $1, %xmm0
; SSE-NEXT:    paddw %xmm1, %xmm0
; SSE-NEXT:    pmulhuw {{.*}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_udiv_nonuniform3:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm1
; AVX-NEXT:    vpsubw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpsrlw $1, %xmm0, %xmm0
; AVX-NEXT:    vpaddw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_nonuniform3:
; XOP:       # %bb.0:
; XOP-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm1
; XOP-NEXT:    vpsubw %xmm1, %xmm0, %xmm0
; XOP-NEXT:    vpsrlw $1, %xmm0, %xmm0
; XOP-NEXT:    vpaddw %xmm1, %xmm0, %xmm0
; XOP-NEXT:    vpshlw {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    retq
  %1 = udiv <8 x i16> %x, <i16 7, i16 23, i16 25, i16 27, i16 31, i16 47, i16 63, i16 127>
  ret <8 x i16> %1
}

define <16 x i8> @combine_vec_udiv_nonuniform4(<16 x i8> %x) {
; SSE2-LABEL: combine_vec_udiv_nonuniform4:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pxor %xmm3, %xmm3
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm3[0],xmm0[1],xmm3[1],xmm0[2],xmm3[2],xmm0[3],xmm3[3],xmm0[4],xmm3[4],xmm0[5],xmm3[5],xmm0[6],xmm3[6],xmm0[7],xmm3[7]
; SSE2-NEXT:    pmullw {{.*}}(%rip), %xmm0
; SSE2-NEXT:    psrlw $8, %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    psrlw $7, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_udiv_nonuniform4:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    pmovzxbw {{.*#+}} xmm2 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; SSE41-NEXT:    pmullw {{.*}}(%rip), %xmm2
; SSE41-NEXT:    psrlw $8, %xmm2
; SSE41-NEXT:    packuswb %xmm2, %xmm2
; SSE41-NEXT:    psrlw $7, %xmm2
; SSE41-NEXT:    pand {{.*}}(%rip), %xmm2
; SSE41-NEXT:    movaps {{.*#+}} xmm0 = [0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
; SSE41-NEXT:    pblendvb %xmm0, %xmm1, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: combine_vec_udiv_nonuniform4:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovzxbw {{.*#+}} xmm1 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX-NEXT:    vpmullw {{.*}}(%rip), %xmm1, %xmm1
; AVX-NEXT:    vpsrlw $8, %xmm1, %xmm1
; AVX-NEXT:    vpackuswb %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpsrlw $7, %xmm1, %xmm1
; AVX-NEXT:    vpand {{.*}}(%rip), %xmm1, %xmm1
; AVX-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
; AVX-NEXT:    vpblendvb %xmm2, %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
;
; XOP-LABEL: combine_vec_udiv_nonuniform4:
; XOP:       # %bb.0:
; XOP-NEXT:    vpmovzxbw {{.*#+}} xmm1 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; XOP-NEXT:    vpmullw {{.*}}(%rip), %xmm1, %xmm1
; XOP-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; XOP-NEXT:    vpperm {{.*#+}} xmm1 = xmm1[1,3,5,7,9,11,13,15],xmm2[1,3,5,7,9,11,13,15]
; XOP-NEXT:    movl $249, %eax
; XOP-NEXT:    vmovd %eax, %xmm2
; XOP-NEXT:    vpshlb %xmm2, %xmm1, %xmm1
; XOP-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
; XOP-NEXT:    vpblendvb %xmm2, %xmm0, %xmm1, %xmm0
; XOP-NEXT:    retq
  %div = udiv <16 x i8> %x, <i8 -64, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>
  ret <16 x i8> %div
}

define <8 x i16> @pr38477(<8 x i16> %a0) {
; SSE2-LABEL: pr38477:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [0,4957,57457,4103,16385,35545,2048,2115]
; SSE2-NEXT:    pmulhuw %xmm0, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psubw %xmm2, %xmm1
; SSE2-NEXT:    pmulhuw {{.*}}(%rip), %xmm1
; SSE2-NEXT:    paddw %xmm2, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [65535,65535,65535,65535,65535,65535,0,65535]
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    pandn %xmm1, %xmm3
; SSE2-NEXT:    pmulhuw {{.*}}(%rip), %xmm1
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    por %xmm3, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [0,65535,65535,65535,65535,65535,65535,65535]
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: pr38477:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movdqa {{.*#+}} xmm2 = [0,4957,57457,4103,16385,35545,2048,2115]
; SSE41-NEXT:    pmulhuw %xmm0, %xmm2
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    psubw %xmm2, %xmm1
; SSE41-NEXT:    pmulhuw {{.*}}(%rip), %xmm1
; SSE41-NEXT:    paddw %xmm2, %xmm1
; SSE41-NEXT:    movdqa {{.*#+}} xmm2 = <u,1024,1024,16,4,1024,u,4096>
; SSE41-NEXT:    pmulhuw %xmm1, %xmm2
; SSE41-NEXT:    pblendw {{.*#+}} xmm1 = xmm2[0,1,2,3,4,5],xmm1[6],xmm2[7]
; SSE41-NEXT:    pblendw {{.*#+}} xmm1 = xmm0[0],xmm1[1,2,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: pr38477:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm1
; AVX-NEXT:    vpsubw %xmm1, %xmm0, %xmm2
; AVX-NEXT:    vpmulhuw {{.*}}(%rip), %xmm2, %xmm2
; AVX-NEXT:    vpaddw %xmm1, %xmm2, %xmm1
; AVX-NEXT:    vpmulhuw {{.*}}(%rip), %xmm1, %xmm2
; AVX-NEXT:    vpblendw {{.*#+}} xmm1 = xmm2[0,1,2,3,4,5],xmm1[6],xmm2[7]
; AVX-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0],xmm1[1,2,3,4,5,6,7]
; AVX-NEXT:    retq
;
; XOP-LABEL: pr38477:
; XOP:       # %bb.0:
; XOP-NEXT:    vpmulhuw {{.*}}(%rip), %xmm0, %xmm1
; XOP-NEXT:    vpsubw %xmm1, %xmm0, %xmm2
; XOP-NEXT:    vpmulhuw {{.*}}(%rip), %xmm2, %xmm2
; XOP-NEXT:    vpaddw %xmm1, %xmm2, %xmm1
; XOP-NEXT:    vpshlw {{.*}}(%rip), %xmm1, %xmm1
; XOP-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0],xmm1[1,2,3,4,5,6,7]
; XOP-NEXT:    retq
  %1 = udiv <8 x i16> %a0, <i16 1, i16 119, i16 73, i16 -111, i16 -3, i16 118, i16 32, i16 31>
  ret <8 x i16> %1
}

define i1 @bool_udiv(i1 %x, i1 %y) {
; CHECK-LABEL: bool_udiv:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    # kill: def $al killed $al killed $eax
; CHECK-NEXT:    retq
  %r = udiv i1 %x, %y
  ret i1 %r
}

define <4 x i1> @boolvec_udiv(<4 x i1> %x, <4 x i1> %y) {
; CHECK-LABEL: boolvec_udiv:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retq
  %r = udiv <4 x i1> %x, %y
  ret <4 x i1> %r
}
