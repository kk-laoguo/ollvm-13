; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu \
; RUN:   -mcpu=pwr10 -ppc-asm-full-reg-names \
; RUN:   -ppc-vsr-nums-as-vr < %s | FileCheck %s
; RUN: llc -verify-machineinstrs -mtriple=powerpc64-unknown-linux-gnu \
; RUN:   -mcpu=pwr10 -ppc-asm-full-reg-names \
; RUN:   -ppc-vsr-nums-as-vr < %s | FileCheck %s --check-prefix=CHECK-BE

declare <512 x i1> @llvm.ppc.mma.xvf16ger2pp(<512 x i1>, <16 x i8>, <16 x i8>)
declare <512 x i1> @llvm.ppc.mma.assemble.acc(<16 x i8>, <16 x i8>, <16 x i8>, <16 x i8>)
declare void @foo()
define void @intrinsics1(<16 x i8> %vc1, <16 x i8> %vc2, <16 x i8> %vc3, <16 x i8> %vc4, i8* %ptr) {
; CHECK-LABEL: intrinsics1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    .cfi_def_cfa_offset 176
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    .cfi_offset r30, -16
; CHECK-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -176(r1)
; CHECK-NEXT:    # kill: def $v5 killed $v5 killed $vsrp18 def $vsrp18
; CHECK-NEXT:    # kill: def $v4 killed $v4 killed $vsrp18 def $vsrp18
; CHECK-NEXT:    # kill: def $v3 killed $v3 killed $vsrp17 def $vsrp17
; CHECK-NEXT:    # kill: def $v2 killed $v2 killed $vsrp17 def $vsrp17
; CHECK-NEXT:    xxlor vs0, v2, v2
; CHECK-NEXT:    xxlor vs1, v3, v3
; CHECK-NEXT:    stxvp vsp34, 128(r1) # 32-byte Folded Spill
; CHECK-NEXT:    ld r30, 272(r1)
; CHECK-NEXT:    stxvp vsp36, 96(r1) # 32-byte Folded Spill
; CHECK-NEXT:    xxlor vs2, v4, v4
; CHECK-NEXT:    xxlor vs3, v5, v5
; CHECK-NEXT:    xxmtacc acc0
; CHECK-NEXT:    xvf16ger2pp acc0, v2, v4
; CHECK-NEXT:    xxmfacc acc0
; CHECK-NEXT:    stxvp vsp0, 64(r1)
; CHECK-NEXT:    stxvp vsp2, 32(r1)
; CHECK-NEXT:    bl foo@notoc
; CHECK-NEXT:    lxvp vsp0, 64(r1)
; CHECK-NEXT:    lxvp vsp2, 32(r1)
; CHECK-NEXT:    lxvp vsp34, 128(r1) # 32-byte Folded Reload
; CHECK-NEXT:    lxvp vsp36, 96(r1) # 32-byte Folded Reload
; CHECK-NEXT:    xxmtacc acc0
; CHECK-NEXT:    xvf16ger2pp acc0, v2, v4
; CHECK-NEXT:    xxmfacc acc0
; CHECK-NEXT:    stxv vs0, 48(r30)
; CHECK-NEXT:    stxv vs1, 32(r30)
; CHECK-NEXT:    stxv vs2, 16(r30)
; CHECK-NEXT:    stxv vs3, 0(r30)
; CHECK-NEXT:    addi r1, r1, 176
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-BE-LABEL: intrinsics1:
; CHECK-BE:       # %bb.0:
; CHECK-BE-NEXT:    mflr r0
; CHECK-BE-NEXT:    std r0, 16(r1)
; CHECK-BE-NEXT:    stdu r1, -256(r1)
; CHECK-BE-NEXT:    .cfi_def_cfa_offset 256
; CHECK-BE-NEXT:    .cfi_offset lr, 16
; CHECK-BE-NEXT:    .cfi_offset r30, -16
; CHECK-BE-NEXT:    std r30, 240(r1) # 8-byte Folded Spill
; CHECK-BE-NEXT:    # kill: def $v5 killed $v5 killed $vsrp18 def $vsrp18
; CHECK-BE-NEXT:    # kill: def $v4 killed $v4 killed $vsrp18 def $vsrp18
; CHECK-BE-NEXT:    # kill: def $v3 killed $v3 killed $vsrp17 def $vsrp17
; CHECK-BE-NEXT:    # kill: def $v2 killed $v2 killed $vsrp17 def $vsrp17
; CHECK-BE-NEXT:    xxlor vs0, v2, v2
; CHECK-BE-NEXT:    xxlor vs1, v3, v3
; CHECK-BE-NEXT:    stxvp vsp34, 208(r1) # 32-byte Folded Spill
; CHECK-BE-NEXT:    ld r30, 368(r1)
; CHECK-BE-NEXT:    xxlor vs2, v4, v4
; CHECK-BE-NEXT:    xxlor vs3, v5, v5
; CHECK-BE-NEXT:    stxvp vsp36, 176(r1) # 32-byte Folded Spill
; CHECK-BE-NEXT:    xxmtacc acc0
; CHECK-BE-NEXT:    xvf16ger2pp acc0, v2, v4
; CHECK-BE-NEXT:    xxmfacc acc0
; CHECK-BE-NEXT:    stxvp vsp0, 112(r1)
; CHECK-BE-NEXT:    stxvp vsp2, 144(r1)
; CHECK-BE-NEXT:    bl foo
; CHECK-BE-NEXT:    nop
; CHECK-BE-NEXT:    lxvp vsp0, 112(r1)
; CHECK-BE-NEXT:    lxvp vsp2, 144(r1)
; CHECK-BE-NEXT:    lxvp vsp34, 208(r1) # 32-byte Folded Reload
; CHECK-BE-NEXT:    lxvp vsp36, 176(r1) # 32-byte Folded Reload
; CHECK-BE-NEXT:    xxmtacc acc0
; CHECK-BE-NEXT:    xvf16ger2pp acc0, v2, v4
; CHECK-BE-NEXT:    xxmfacc acc0
; CHECK-BE-NEXT:    stxv vs1, 16(r30)
; CHECK-BE-NEXT:    stxv vs0, 0(r30)
; CHECK-BE-NEXT:    stxv vs3, 48(r30)
; CHECK-BE-NEXT:    stxv vs2, 32(r30)
; CHECK-BE-NEXT:    ld r30, 240(r1) # 8-byte Folded Reload
; CHECK-BE-NEXT:    addi r1, r1, 256
; CHECK-BE-NEXT:    ld r0, 16(r1)
; CHECK-BE-NEXT:    mtlr r0
; CHECK-BE-NEXT:    blr
  %1 = tail call <512 x i1> @llvm.ppc.mma.assemble.acc(<16 x i8> %vc1, <16 x i8> %vc2, <16 x i8> %vc3, <16 x i8> %vc4)
  %2 = tail call <512 x i1> @llvm.ppc.mma.xvf16ger2pp(<512 x i1> %1, <16 x i8> %vc1, <16 x i8> %vc3)
  tail call void @foo()
  %3 = tail call <512 x i1> @llvm.ppc.mma.xvf16ger2pp(<512 x i1> %2, <16 x i8> %vc1, <16 x i8> %vc3)
  %4 = bitcast i8* %ptr to <512 x i1>*
  store <512 x i1> %3, <512 x i1>* %4, align 64
  ret void
}
