//===-- RISCVSubtarget.h - Define Subtarget for the RISCV -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares the RISCV specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_RISCV_RISCVSUBTARGET_H
#define LLVM_LIB_TARGET_RISCV_RISCVSUBTARGET_H

#include "MCTargetDesc/RISCVBaseInfo.h"
#include "RISCVFrameLowering.h"
#include "RISCVISelLowering.h"
#include "RISCVInstrInfo.h"
#include "llvm/CodeGen/GlobalISel/CallLowering.h"
#include "llvm/CodeGen/GlobalISel/InstructionSelector.h"
#include "llvm/CodeGen/GlobalISel/LegalizerInfo.h"
#include "llvm/CodeGen/GlobalISel/RegisterBankInfo.h"
#include "llvm/CodeGen/SelectionDAGTargetInfo.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/Target/TargetMachine.h"

#define GET_SUBTARGETINFO_HEADER
#include "RISCVGenSubtargetInfo.inc"

namespace llvm {
class StringRef;

class RISCVSubtarget : public RISCVGenSubtargetInfo {
  virtual void anchor();
  bool HasStdExtM = false;
  bool HasStdExtA = false;
  bool HasStdExtF = false;
  bool HasStdExtD = false;
  bool HasStdExtC = false;
  bool HasStdExtB = false;
  bool HasStdExtZba = false;
  bool HasStdExtZbb = false;
  bool HasStdExtZbc = false;
  bool HasStdExtZbe = false;
  bool HasStdExtZbf = false;
  bool HasStdExtZbm = false;
  bool HasStdExtZbp = false;
  bool HasStdExtZbr = false;
  bool HasStdExtZbs = false;
  bool HasStdExtZbt = false;
  bool HasStdExtZbproposedc = false;
  bool HasStdExtV = false;
  bool HasStdExtZvlsseg = false;
  bool HasStdExtZvamo = false;
  bool HasStdExtZfh = false;
  bool HasRV64 = false;
  bool IsRV32E = false;
  bool EnableLinkerRelax = false;
  bool EnableRVCHintInstrs = true;
  bool EnableSaveRestore = false;
  unsigned XLen = 32;
  MVT XLenVT = MVT::i32;
  RISCVABI::ABI TargetABI = RISCVABI::ABI_Unknown;
  BitVector UserReservedRegister;
  RISCVFrameLowering FrameLowering;
  RISCVInstrInfo InstrInfo;
  RISCVRegisterInfo RegInfo;
  RISCVTargetLowering TLInfo;
  SelectionDAGTargetInfo TSInfo;

  /// Initializes using the passed in CPU and feature strings so that we can
  /// use initializer lists for subtarget initialization.
  RISCVSubtarget &initializeSubtargetDependencies(const Triple &TT,
                                                  StringRef CPU,
                                                  StringRef TuneCPU,
                                                  StringRef FS,
                                                  StringRef ABIName);

public:
  // Initializes the data members to match that of the specified triple.
  RISCVSubtarget(const Triple &TT, StringRef CPU, StringRef TuneCPU,
                 StringRef FS, StringRef ABIName, const TargetMachine &TM);

  // Parses features string setting specified subtarget options. The
  // definition of this function is auto-generated by tblgen.
  void ParseSubtargetFeatures(StringRef CPU, StringRef TuneCPU, StringRef FS);

  const RISCVFrameLowering *getFrameLowering() const override {
    return &FrameLowering;
  }
  const RISCVInstrInfo *getInstrInfo() const override { return &InstrInfo; }
  const RISCVRegisterInfo *getRegisterInfo() const override {
    return &RegInfo;
  }
  const RISCVTargetLowering *getTargetLowering() const override {
    return &TLInfo;
  }
  const SelectionDAGTargetInfo *getSelectionDAGInfo() const override {
    return &TSInfo;
  }
  bool enableMachineScheduler() const override { return true; }
  bool hasStdExtM() const { return HasStdExtM; }
  bool hasStdExtA() const { return HasStdExtA; }
  bool hasStdExtF() const { return HasStdExtF; }
  bool hasStdExtD() const { return HasStdExtD; }
  bool hasStdExtC() const { return HasStdExtC; }
  bool hasStdExtB() const { return HasStdExtB; }
  bool hasStdExtZba() const { return HasStdExtZba; }
  bool hasStdExtZbb() const { return HasStdExtZbb; }
  bool hasStdExtZbc() const { return HasStdExtZbc; }
  bool hasStdExtZbe() const { return HasStdExtZbe; }
  bool hasStdExtZbf() const { return HasStdExtZbf; }
  bool hasStdExtZbm() const { return HasStdExtZbm; }
  bool hasStdExtZbp() const { return HasStdExtZbp; }
  bool hasStdExtZbr() const { return HasStdExtZbr; }
  bool hasStdExtZbs() const { return HasStdExtZbs; }
  bool hasStdExtZbt() const { return HasStdExtZbt; }
  bool hasStdExtZbproposedc() const { return HasStdExtZbproposedc; }
  bool hasStdExtV() const { return HasStdExtV; }
  bool hasStdExtZvlsseg() const { return HasStdExtZvlsseg; }
  bool hasStdExtZvamo() const { return HasStdExtZvamo; }
  bool hasStdExtZfh() const { return HasStdExtZfh; }
  bool is64Bit() const { return HasRV64; }
  bool isRV32E() const { return IsRV32E; }
  bool enableLinkerRelax() const { return EnableLinkerRelax; }
  bool enableRVCHintInstrs() const { return EnableRVCHintInstrs; }
  bool enableSaveRestore() const { return EnableSaveRestore; }
  MVT getXLenVT() const { return XLenVT; }
  unsigned getXLen() const { return XLen; }
  RISCVABI::ABI getTargetABI() const { return TargetABI; }
  bool isRegisterReservedByUser(Register i) const {
    assert(i < RISCV::NUM_TARGET_REGS && "Register out of range");
    return UserReservedRegister[i];
  }

protected:
  // GlobalISel related APIs.
  std::unique_ptr<CallLowering> CallLoweringInfo;
  std::unique_ptr<InstructionSelector> InstSelector;
  std::unique_ptr<LegalizerInfo> Legalizer;
  std::unique_ptr<RegisterBankInfo> RegBankInfo;

public:
  const CallLowering *getCallLowering() const override;
  InstructionSelector *getInstructionSelector() const override;
  const LegalizerInfo *getLegalizerInfo() const override;
  const RegisterBankInfo *getRegBankInfo() const override;
};
} // End llvm namespace

#endif
