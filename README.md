

# ollvm 13
[参考连接：移植llvm12.x](https://github.com/0x3f97/ollvm-12.x)

从 obfuscator-llvm 项目移植到 llvm 13.x

## 移植过程

获取 llvm 13 https://github.com/llvm/llvm-project

获取 ollvm 10 该项目是由PLCT实验室维护的ollvm分支 https://github.com/isrc-cas/flounder

![image-20211015092122270](https://gitee.com/Tangchi/ZainPhotoCloud/raw/master/blogimage/image-20211015092122270.png)

复制 ollvm 主要代码到 llvm 13 项目中.

```
copy /r C:\Dev\ollvm\reference\flounder\llvm\include\llvm\Transforms\Obfuscation C:\Dev\ollvm\llvm-project\llvm\include\llvm\Transforms
copy /r C:\Dev\ollvm\reference\flounder\llvm\lib\Transforms\Obfuscation C:\Dev\ollvm\llvm-project\llvm\lib\Transforms
```

### 修改 CmakeLists.txt

- 添加下面这行到 `llvm-project\llvm\lib\Transforms\CMakeLists.txt`的第12行.

```
add_subdirectory(Obfuscation)
```

- `llvm-project\llvm\lib\Transforms\IPO\CMakeLists.txt`

Add the following line at line 73

```
Obfuscation
```

### 修改LLVM源码

**InitializePasses.h**

`C:\Dev\ollvm\llvm-project\llvm\include\llvm\InitializePasses.h`

Add the following at 457

```
void initializeFlatteningPass(PassRegistry&);
```

**PassManagerBuilder.cpp**

`llvm-project\llvm\lib\Transforms\IPO\PassManagerBuilder.cpp`

Add the following at line 53

```c++
// Flags for obfuscation
#include "llvm/Transforms/Obfuscation/BogusControlFlow.h"
#include "llvm/Transforms/Obfuscation/Flattening.h"
#include "llvm/Transforms/Obfuscation/Split.h"
#include "llvm/Transforms/Obfuscation/Substitution.h"
#include "llvm/Transforms/Obfuscation/CryptoUtils.h"
#include "llvm/Transforms/Obfuscation/StringObfuscation.h"
```

Add the following at line 98

```
// Flags for obfuscation
static cl::opt<std::string> Seed("seed", cl::init(""),
                                    cl::desc("seed for the random"));
static cl::opt<std::string> AesSeed("aesSeed", cl::init(""),
                                    cl::desc("seed for the AES-CTR PRNG"));
static cl::opt<bool> StringObf("sobf", cl::init(false),
                                  cl::desc("Enable the string obfuscation"));   //tofix
static cl::opt<bool> Flattening("fla", cl::init(false),              //tofix
                                cl::desc("Enable the flattening pass"));
static cl::opt<bool> BogusControlFlow("bcf", cl::init(false),
                                      cl::desc("Enable bogus control flow"));
static cl::opt<bool> Substitution("sub", cl::init(false),
                                  cl::desc("Enable instruction substitutions"));
static cl::opt<bool> Split("split", cl::init(false),
                           cl::desc("Enable basic block splitting"));
// Flags for obfuscation
```

Add the following at line 706

```
  //obfuscation related pass
  MPM.add(createSplitBasicBlockPass(Split));
  MPM.add(createBogusPass(BogusControlFlow));
  MPM.add(createFlatteningPass(Flattening));
  MPM.add(createStringObfuscationPass(StringObf));
  MPM.add(createSubstitutionPass(Substitution));
```



### 修改`bfuscator`源码

这部分可以不用修改，直接把此项目里面的2个`Obfuscation`文件夹拷贝到LLVM里面对应的目录下

**StringObfuscation.cpp**

`llvm-project\llvm\lib\Transforms\Obfuscation\StringObfuscation.cpp`

Modify CallSite.h to AbstractCallSite.h. at line 10

```
#include "llvm/IR/AbstractCallSite.h"
```

Insert the follwing at line 15

```
#include "llvm/IR/Instructions.h"
```

Replace MayAlign to Align at line 15, 175, 183, 184, 191.

```
LoadInst *ptr_19 = new LoadInst(gvar->getType()->getArrayElementType(),
                                gvar, "", false, label_for_body);
ptr_19->setAlignment(Align(8));
...
LoadInst* int8_20 = new LoadInst(ptr_arrayidx->getType()->getArrayElementType(), ptr_arrayidx, "", false, label_for_body);
int8_20->setAlignment(Align(1));
...
void_21->setAlignment(Align(1));
```

**Substitution.cpp**

Modify Substitution::addDoubleNeg function at line 215. BinaryOperator → UnaryOperator

```
// Implementation of a = -(-b + (-c)) 
void Substitution::addDoubleNeg(BinaryOperator *bo) { 
  BinaryOperator *op, *op2 = NULL; 
  UnaryOperator *op3, *op4; 
  if (bo->getOpcode() == Instruction::Add) { 
    op = BinaryOperator::CreateNeg(bo->getOperand(0), "", bo); 
    op2 = BinaryOperator::CreateNeg(bo->getOperand(1), "", bo); 
    op = BinaryOperator::Create(Instruction::Add, op, op2, "", bo); 
    op = BinaryOperator::CreateNeg(op, "", bo); 
    bo->replaceAllUsesWith(op); 
    // Check signed wrap 
    //op->setHasNoSignedWrap(bo->hasNoSignedWrap()); 
    //op->setHasNoUnsignedWrap(bo->hasNoUnsignedWrap()); 
  } else { 
    op3 = UnaryOperator::CreateFNeg(bo->getOperand(0), "", bo); 
    op4 = UnaryOperator::CreateFNeg(bo->getOperand(1), "", bo); 
    op = BinaryOperator::Create(Instruction::FAdd, op3, op4, "", bo); 
    op3 = UnaryOperator::CreateFNeg(op, "", bo); 
    bo->replaceAllUsesWith(op3); 
  }   
}
```

Modify Substitution::subNeg function at line 299. BinaryOperator → UnaryOperator

```
// Implementation of a = b + (-c) 
void Substitution::subNeg(BinaryOperator *bo) { 
  BinaryOperator *op = NULL;   
  if (bo->getOpcode() == Instruction::Sub) { 
    op = BinaryOperator::CreateNeg(bo->getOperand(1), "", bo); 
    op = BinaryOperator::Create(Instruction::Add, bo->getOperand(0), op, "", bo); 
    // Check signed wrap 
    //op->setHasNoSignedWrap(bo->hasNoSignedWrap()); 
    //op->setHasNoUnsignedWrap(bo->hasNoUnsignedWrap()); 
  } else { 
    auto op1 = UnaryOperator::CreateFNeg(bo->getOperand(1), "", bo); 
    op = BinaryOperator::Create(Instruction::FAdd, bo->getOperand(0), op1, "", bo); 
  } 
  bo->replaceAllUsesWith(op); 
}
```

**BogusControlFlow.cpp**

C:\Dev\ollvm\llvm-project\llvm\lib\Transforms\Obfuscation\BogusControlFlow.cpp

Add the following at line 380

```
UnaryOperator *op2;
```

Modify at line 420

```
case 1: op2 = UnaryOperator::CreateFNeg(i->getOperand(0),*var,&*i);
```

Modify at line 569-570

```
opX = new LoadInst (x->getType()->getElementType(), (Value *)x, "", (*i));
opY = new LoadInst (x->getType()->getElementType(), (Value *)y, "", (*i));
```

The constructor LoadInst in LLVM 12 requires a llvm::Type object as the first argument.



**Flattening.cpp**

C:\Dev\ollvm\llvm-project\llvm\lib\Transforms\Obfuscation\Flattening.cpp

Add the following at line 17

```
#include "llvm/InitializePasses.h"
```

Modify line 123.

```
load = new LoadInst(switchVar->getType()->getElementType(), switchVar, "switchVar", loopEntry);
```

line 239.

```
INITIALIZE_PASS_DEPENDENCY(LowerSwitchLegacyPass)
```

cmake

```
cd llvm-project
mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_CREATE_XCODE_TOOLCHAIN=ON  -DLLVM_ENABLE_PROJECTS="clang" ../llvm

make -j8
// toolcchains
sudo make install-xcode-toolchain

mv /usr/local/Toolchains  ~/Library/Developer/Toolchains
// 之后重启xcode，就能看到新编译的llvm
```

![image-20211015092420001](https://gitee.com/Tangchi/ZainPhotoCloud/raw/master/blogimage/image-20211015092420001.png)



ollvm 基本使用

编译时使用参数

```
clang-cl -mllvm -bcf -mllvm -sub -mllvm -fla -mllvm -sobf -mllvm -split 
```

增加混淆强度

```
clang-cl -mllvm -bcf -mllvm -bcf_loop=4 -mllvm -bcf_prob=100 -mllvm -sub -mllvm -sub_loop=2 -mllvm -fla -mllvm -sobf -mllvm -split 
```

# The LLVM Compiler Infrastructure

This directory and its sub-directories contain source code for LLVM, a toolkit for the construction of highly optimized compilers, optimizers, and run-time environments.

The README briefly describes how to get started with building LLVM. For more information on how to contribute to the LLVM project, please take a look at the [Contributing to LLVM](https://llvm.org/docs/Contributing.html) guide.

## Getting Started with the LLVM System

Taken from https://llvm.org/docs/GettingStarted.html.

### Overview

Welcome to the LLVM project!

The LLVM project has multiple components. The core of the project is itself called "LLVM". This contains all of the tools, libraries, and header files needed to process intermediate representations and converts it into object files. Tools include an assembler, disassembler, bitcode analyzer, and bitcode optimizer. It also contains basic regression tests.

C-like languages use the [Clang](http://clang.llvm.org/) front end. This component compiles C, C++, Objective-C, and Objective-C++ code into LLVM bitcode -- and from there into object files, using LLVM.

Other components include: the [libc++ C++ standard library](https://libcxx.llvm.org/), the [LLD linker](https://lld.llvm.org/), and more.

### Getting the Source Code and Building LLVM

The LLVM Getting Started documentation may be out of date. The [Clang Getting Started](http://clang.llvm.org/get_started.html) page might have more accurate information.

This is an example work-flow and configuration to get and build the LLVM source:

1. Checkout LLVM (including related sub-projects like Clang):

   - `git clone https://github.com/llvm/llvm-project.git`
   - Or, on windows, `git clone --config core.autocrlf=false https://github.com/llvm/llvm-project.git`

2. Configure and build LLVM and Clang:

   - `cd llvm-project`

   - `mkdir build`

   - `cd build`

   - `cmake -G <generator> [options] ../llvm`

     Some common build system generators are:

     - `Ninja` --- for generating [Ninja](https://ninja-build.org/) build files. Most llvm developers use Ninja.
     - `Unix Makefiles` --- for generating make-compatible parallel makefiles.
     - `Visual Studio` --- for generating Visual Studio projects and solutions.
     - `Xcode` --- for generating Xcode projects.

     Some Common options:

     - `-DLLVM_ENABLE_PROJECTS='...'` --- semicolon-separated list of the LLVM sub-projects you'd like to additionally build. Can include any of: clang, clang-tools-extra, libcxx, libcxxabi, libunwind, lldb, compiler-rt, lld, polly, or debuginfo-tests.

       For example, to build LLVM, Clang, libcxx, and libcxxabi, use `-DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi"`.

     - `-DCMAKE_INSTALL_PREFIX=directory` --- Specify for *directory* the full path name of where you want the LLVM tools and libraries to be installed (default `/usr/local`).

     - `-DCMAKE_BUILD_TYPE=type` --- Valid options for *type* are Debug, Release, RelWithDebInfo, and MinSizeRel. Default is Debug.

     - `-DLLVM_ENABLE_ASSERTIONS=On` --- Compile with assertion checks enabled (default is Yes for Debug builds, No for all other build types).

   - `cmake --build . [-- [options] <target>]` or your build system specified above directly.

     - The default target (i.e. `ninja` or `make`) will build all of LLVM.
     - The `check-all` target (i.e. `ninja check-all`) will run the regression tests to ensure everything is in working order.
     - CMake will generate targets for each tool and library, and most LLVM sub-projects generate their own `check-<project>` target.
     - Running a serial build will be **slow**. To improve speed, try running a parallel build. That's done by default in Ninja; for `make`, use the option `-j NNN`, where `NNN` is the number of parallel jobs, e.g. the number of CPUs you have.

   - For more information see [CMake](https://llvm.org/docs/CMake.html)

Consult the [Getting Started with LLVM](https://llvm.org/docs/GettingStarted.html#getting-started-with-llvm) page for detailed information on configuring and compiling LLVM. You can visit [Directory Layout](https://llvm.org/docs/GettingStarted.html#directory-layout) to learn about the layout of the source code tree.
