; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-globals
; RUN: opt -S -mtriple=amdgcn-amd-amdhsa -amdgpu-annotate-kernel-features %s | FileCheck -allow-unused-prefixes -check-prefixes=CHECK,AKF_CHECK %s
; RUN: opt -S -mtriple=amdgcn-amd-amdhsa -amdgpu-attributor %s | FileCheck -allow-unused-prefixes -check-prefixes=CHECK,ATTRIBUTOR_CHECK %s

@x = global i32 0
;.
; CHECK: @[[X:[a-zA-Z0-9_$"\\.-]+]] = global i32 0
;.
define void @func1() {
; CHECK-LABEL: define {{[^@]+}}@func1
; CHECK-SAME: () #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    store i32 0, i32* @x, align 4
; CHECK-NEXT:    ret void
;
  store i32 0, i32* @x
  ret void
}

define void @func4() {
; CHECK-LABEL: define {{[^@]+}}@func4
; CHECK-SAME: () #[[ATTR0]] {
; CHECK-NEXT:    store i32 0, i32* @x, align 4
; CHECK-NEXT:    ret void
;
  store i32 0, i32* @x
  ret void
}

define void @func2() #0 {
; AKF_CHECK-LABEL: define {{[^@]+}}@func2
; AKF_CHECK-SAME: () #[[ATTR0]] {
; AKF_CHECK-NEXT:    call void @func4()
; AKF_CHECK-NEXT:    call void @func1()
; AKF_CHECK-NEXT:    ret void
;
; ATTRIBUTOR_CHECK-LABEL: define {{[^@]+}}@func2
; ATTRIBUTOR_CHECK-SAME: () #[[ATTR0]] {
; ATTRIBUTOR_CHECK-NEXT:    call void @func4() #[[ATTR2:[0-9]+]]
; ATTRIBUTOR_CHECK-NEXT:    call void @func1() #[[ATTR2]]
; ATTRIBUTOR_CHECK-NEXT:    ret void
;
  call void @func4()
  call void @func1()
  ret void
}

define void @func3() {
; AKF_CHECK-LABEL: define {{[^@]+}}@func3
; AKF_CHECK-SAME: () #[[ATTR0]] {
; AKF_CHECK-NEXT:    call void @func1()
; AKF_CHECK-NEXT:    ret void
;
; ATTRIBUTOR_CHECK-LABEL: define {{[^@]+}}@func3
; ATTRIBUTOR_CHECK-SAME: () #[[ATTR0]] {
; ATTRIBUTOR_CHECK-NEXT:    call void @func1() #[[ATTR2]]
; ATTRIBUTOR_CHECK-NEXT:    ret void
;
  call void @func1()
  ret void
}

define amdgpu_kernel void @kernel3() #0 {
; AKF_CHECK-LABEL: define {{[^@]+}}@kernel3
; AKF_CHECK-SAME: () #[[ATTR1:[0-9]+]] {
; AKF_CHECK-NEXT:    call void @func2()
; AKF_CHECK-NEXT:    call void @func3()
; AKF_CHECK-NEXT:    ret void
;
; ATTRIBUTOR_CHECK-LABEL: define {{[^@]+}}@kernel3
; ATTRIBUTOR_CHECK-SAME: () #[[ATTR1:[0-9]+]] {
; ATTRIBUTOR_CHECK-NEXT:    call void @func2() #[[ATTR2]]
; ATTRIBUTOR_CHECK-NEXT:    call void @func3() #[[ATTR2]]
; ATTRIBUTOR_CHECK-NEXT:    ret void
;
  call void @func2()
  call void @func3()
  ret void
}

attributes #0 = { "uniform-work-group-size"="false" }
;.
; AKF_CHECK: attributes #[[ATTR0]] = { "uniform-work-group-size"="false" }
; AKF_CHECK: attributes #[[ATTR1]] = { "amdgpu-calls" "uniform-work-group-size"="false" }
;.
; ATTRIBUTOR_CHECK: attributes #[[ATTR0]] = { nounwind writeonly "uniform-work-group-size"="false" }
; ATTRIBUTOR_CHECK: attributes #[[ATTR1]] = { "amdgpu-calls" "uniform-work-group-size"="false" }
; ATTRIBUTOR_CHECK: attributes #[[ATTR2]] = { nounwind writeonly }
;.