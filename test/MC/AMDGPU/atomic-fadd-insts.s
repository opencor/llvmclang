// RUN: not llvm-mc -arch=amdgcn -mcpu=gfx908 -show-encoding %s | FileCheck --check-prefix=GFX908 %s
// RUN: not llvm-mc -arch=amdgcn -mcpu=gfx908 %s 2>&1 | FileCheck --check-prefix=GFX908-ERR --implicit-check-not=error: %s

buffer_atomic_add_f32 v5, off, s[8:11], s3 offset:4095
// GFX908: encoding: [0xff,0x0f,0x34,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_add_f32 v255, off, s[8:11], s3 offset:4095
// GFX908: encoding: [0xff,0x0f,0x34,0xe1,0x00,0xff,0x02,0x03]

buffer_atomic_add_f32 v5, off, s[12:15], s3 offset:4095
// GFX908: encoding: [0xff,0x0f,0x34,0xe1,0x00,0x05,0x03,0x03]

buffer_atomic_add_f32 v5, off, s[96:99], s3 offset:4095
// GFX908: encoding: [0xff,0x0f,0x34,0xe1,0x00,0x05,0x18,0x03]

buffer_atomic_add_f32 v5, off, s[8:11], s101 offset:4095
// GFX908: encoding: [0xff,0x0f,0x34,0xe1,0x00,0x05,0x02,0x65]

buffer_atomic_add_f32 v5, off, s[8:11], m0 offset:4095
// GFX908: encoding: [0xff,0x0f,0x34,0xe1,0x00,0x05,0x02,0x7c]

buffer_atomic_add_f32 v5, off, s[8:11], 0 offset:4095
// GFX908: encoding: [0xff,0x0f,0x34,0xe1,0x00,0x05,0x02,0x80]

buffer_atomic_add_f32 v5, off, s[8:11], -1 offset:4095
// GFX908: encoding: [0xff,0x0f,0x34,0xe1,0x00,0x05,0x02,0xc1]

buffer_atomic_add_f32 v5, v0, s[8:11], s3 idxen offset:4095
// GFX908: encoding: [0xff,0x2f,0x34,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_add_f32 v5, v0, s[8:11], s3 offen offset:4095
// GFX908: encoding: [0xff,0x1f,0x34,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_add_f32 v5, off, s[8:11], s3
// GFX908: encoding: [0x00,0x00,0x34,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_add_f32 v5, off, s[8:11], s3
// GFX908: encoding: [0x00,0x00,0x34,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_add_f32 v5, off, s[8:11], s3 offset:7
// GFX908: encoding: [0x07,0x00,0x34,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_add_f32 v5, off, s[8:11], s3 offset:4095 glc
// GFX908-ERR: error: invalid operand for instruction

buffer_atomic_add_f32 v5, off, s[8:11], s3 offset:4095 slc
// GFX908: encoding: [0xff,0x0f,0x36,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_pk_add_f16 v5, off, s[8:11], s3 offset:4095
// GFX908: encoding: [0xff,0x0f,0x38,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_pk_add_f16 v255, off, s[8:11], s3 offset:4095
// GFX908: encoding: [0xff,0x0f,0x38,0xe1,0x00,0xff,0x02,0x03]

buffer_atomic_pk_add_f16 v5, off, s[12:15], s3 offset:4095
// GFX908: encoding: [0xff,0x0f,0x38,0xe1,0x00,0x05,0x03,0x03]

buffer_atomic_pk_add_f16 v5, off, s[96:99], s3 offset:4095
// GFX908: encoding: [0xff,0x0f,0x38,0xe1,0x00,0x05,0x18,0x03]

buffer_atomic_pk_add_f16 v5, off, s[8:11], s101 offset:4095
// GFX908: encoding: [0xff,0x0f,0x38,0xe1,0x00,0x05,0x02,0x65]

buffer_atomic_pk_add_f16 v5, off, s[8:11], m0 offset:4095
// GFX908: encoding: [0xff,0x0f,0x38,0xe1,0x00,0x05,0x02,0x7c]

buffer_atomic_pk_add_f16 v5, off, s[8:11], 0 offset:4095
// GFX908: encoding: [0xff,0x0f,0x38,0xe1,0x00,0x05,0x02,0x80]

buffer_atomic_pk_add_f16 v5, off, s[8:11], -1 offset:4095
// GFX908: encoding: [0xff,0x0f,0x38,0xe1,0x00,0x05,0x02,0xc1]

buffer_atomic_pk_add_f16 v5, v0, s[8:11], s3 idxen offset:4095
// GFX908: encoding: [0xff,0x2f,0x38,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_pk_add_f16 v5, v0, s[8:11], s3 offen offset:4095
// GFX908: encoding: [0xff,0x1f,0x38,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_pk_add_f16 v5, off, s[8:11], s3
// GFX908: encoding: [0x00,0x00,0x38,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_pk_add_f16 v5, off, s[8:11], s3
// GFX908: encoding: [0x00,0x00,0x38,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_pk_add_f16 v5, off, s[8:11], s3 offset:7
// GFX908: encoding: [0x07,0x00,0x38,0xe1,0x00,0x05,0x02,0x03]

buffer_atomic_pk_add_f16 v5, off, s[8:11], s3 offset:4095 glc
// GFX908-ERR: error: invalid operand for instruction

buffer_atomic_pk_add_f16 v5, off, s[8:11], s3 offset:4095 slc
// GFX908: encoding: [0xff,0x0f,0x3a,0xe1,0x00,0x05,0x02,0x03]

global_atomic_add_f32 v[1:2], v2, off offset:-1
// GFX908: encoding: [0xff,0x9f,0x34,0xdd,0x01,0x02,0x7f,0x00]

global_atomic_add_f32 v[1:2], v255, off offset:-1
// GFX908: encoding: [0xff,0x9f,0x34,0xdd,0x01,0xff,0x7f,0x00]

global_atomic_add_f32 v[1:2], v2, off
// GFX908: encoding: [0x00,0x80,0x34,0xdd,0x01,0x02,0x7f,0x00]

global_atomic_pk_add_f16 v[1:2], v2, off offset:-1
// GFX908: encoding: [0xff,0x9f,0x38,0xdd,0x01,0x02,0x7f,0x00]

global_atomic_pk_add_f16 v[1:2], v255, off offset:-1
// GFX908: encoding: [0xff,0x9f,0x38,0xdd,0x01,0xff,0x7f,0x00]

global_atomic_pk_add_f16 v[1:2], v2, off
// GFX908: encoding: [0x00,0x80,0x38,0xdd,0x01,0x02,0x7f,0x00]
