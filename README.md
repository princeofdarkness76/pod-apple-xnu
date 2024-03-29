# pod-apple-xnu
Table of contents:
A. How to build XNU
B. How to install a new header file from XNU

=============================================
A. How to build XNU:

1) Type: "make"

  This builds all the components for kernel, architecture, and machine
  configurations defined in TARGET_CONFIGS.  Additionally, we also support
  architectures defined in ARCH_CONFIGS and kernel configurations defined in 
  KERNEL_CONFIGS.  Note that TARGET_CONFIGS overrides any configurations defined
  in ARCH_CONFIGS and KERNEL_CONFIGS.

  By default, architecture defaults to the build machine 
  architecture, and the kernel configuration is set to build for DEVELOPMENT.
  
  This will also create a bootable image, mach_kernel,  and a kernel binary 
  with symbols, mach_kernel.sys.


	/* this is all you need to do to build with RELEASE kernel configuration  */
	make TARGET_CONFIGS="release x86_64 default" SDKROOT=/path/to/SDK
	
	or the following is equivalent (ommitted SDKROOT will use /)
	
	make ARCH_CONFIGS=X86_64

2) Building DEBUG

  Define kernel configuration to DEBUG in your environment or when running a 
  make command.  Then, apply procedures 4, 5

  $ make TARGET_CONFIGS="DEBUG X86_64 DEFAULT" all

  or

  $ make KERNEL_CONFIGS=DEBUG ARCH_CONFIGS=X86_64 all

  or

  $ export TARGET_CONFIGS="DEBUG X86_64 DEFAULT"
  $ export SDKROOT=/path/to/SDK
  $ make all

  Example:
    $(OBJROOT)/DEBUG_X86_64/osfmk/DEBUG/osfmk.filelist: list of objects in osfmk component
    $(OBJROOT)/DEBUG_X86_64/mach_kernel: bootable image

3) Building fat

  Define architectures in your environment or when running a make command.
  Apply procedures 3, 4, 5

  $ make TARGET_CONFIGS="RELEASE I386 DEFAULT RELEASE X86_64 DEFAULT" exporthdrs all

  or

  $ make ARCH_CONFIGS="I386 X86_64" exporthdrs all

  or

  $ export ARCH_CONFIGS="I386 X86_64"
  $ make exporthdrs all

4) Verbose make 
   To display complete tool invocations rather than an abbreviated version,
   $ make VERBOSE=YES

5) Debug information formats
   By default, a DWARF debug information repository is created during the install phase; this is a "bundle" named mach_kernel.dSYM
   To select the older STABS debug information format (where debug information is embedded in the mach_kernel.sys image), set the BUILD_STABS environment variable.
   $ export BUILD_STABS=1
   $ make

6) Build check before integration

  From the top directory, run:

    $ ~rc/bin/buildit . -arch i386 -arch x86_64 -arch armv7 -arch ppc -noinstallsrc -nosum

	
  xnu supports a number of XBS build aliases, which allow B&I to build
  the same source submission multiple times in different ways, to
  produce different results. Each build alias supports the standard
  "clean", "install", "installsrc", "installhdrs" targets, but
  conditionalize their behavior on the RC_ProjectName make variable
  which is passed as the -buildAlias argument to ~rc/bin/buildit, which
  can be one of:

  -buildAlias xnu            # the default, builds /mach_kernel, kernel-space
                             # headers, user-space headers, man pages,
                             # symbol-set kexts

  -buildAlias xnu_debug      # a DEBUG kernel in /AppleInternal with dSYM

  -buildAlias libkxld        # user-space version of kernel linker

  -buildAlias libkmod        # static library automatically linked into kexts

  -buildAlias Libsyscall     # automatically generate BSD syscall stubs

  -buildAlias xnu_quick_test # install xnu unit tests



7) Creating tags and cscope

  Set up your build environment as per instructions in 2a

  From the top directory, run:

    $ make tags		# this will build ctags and etags on a case-sensitive
			# volume, only ctags on case-insensitive

    $ make TAGS		# this will build etags

    $ make cscope	# this will build cscope database

8) Reindenting files

  Source files can be reindented using clang-format setup in .clang-format. XNU follow a variant of WebKit style for source code formatting. Please refer to format styles at http://www.webkit.org/coding/coding-style.html. Further options about style options is available at http://clang.llvm.org/docs/ClangFormatStyleOptions.html

  Note: clang-format binary may not be part of base installation. It can be compiled from llvm clang sources and is reachable in $PATH.

  From the top directory, run:

   $ make reindent      # reindent all source files using clang format.


9) Other makefile options

   $ make MAKEJOBS=-j8    # this will use 8 processes during the build. The default is 2x the number of active CPUS.
   $ make -j8             # the standard command-line option is also accepted

   $ make -w              # trace recursive make invocations. Useful in combination with VERBOSE=YES

   $ make BUILD_LTO=0	  # build without LLVM Link Time Optimization

   $ make REMOTEBUILD=user@remotehost # perform build on remote host

   $ make BUILD_JSON_COMPILATION_DATABASE=1 # Build Clang JSON Compilation Database

=============================================
B. How to install a new header file from XNU

[To install IOKit headers, see additional comments in iokit/IOKit/Makefile.]

1) XNU installs header files at the following locations -
	a. $(DSTROOT)/System/Library/Frameworks/Kernel.framework/Headers
	b. $(DSTROOT)/System/Library/Frameworks/Kernel.framework/PrivateHeaders
	c. $(DSTROOT)/usr/include/
	d. $(DSTROOT)/System/Library/Frameworks/System.framework/PrivateHeaders

	Kernel.framework is used by kernel extensions.  System.framework 
	and /usr/include are used by user level applications.  The header 
	files in framework's "PrivateHeaders" are only available for Apple 
	Internal development.

2) The directory containing the header file should have a Makefile that 
   creates the list of files that should be installed at different locations.
   If you are adding first header file in a directory, you will need to 
   create Makefile similar to xnu/bsd/sys/Makefile.

   Add your header file to the correct file list depending on where you want 
   to install it.   The default locations where the header files are installed 
   from each file list are -

   a. DATAFILES : To make header file available in user level -
	  $(DSTROOT)/usr/include

   b. PRIVATE_DATAFILES : To make header file available to Apple internal in 
      user level -
	  $(DSTROOT)/System/Library/Frameworks/System.framework/PrivateHeaders

   c. KERNELFILES : To make header file available in kernel level - 
	  $(DSTROOT)/System/Library/Frameworks/Kernel.framework/Headers
	  $(DSTROOT)/System/Library/Frameworks/Kernel.framework/PrivateHeaders

   d. PRIVATE_KERNELFILES : To make header file available to Apple internal 
      for kernel extensions - 
	  $(DSTROOT)/System/Library/Frameworks/Kernel.framework/PrivateHeaders

3) The Makefile combines the file lists mentioned above into different 
   install lists which are used by build system to install the header files.

   If the install list that you are interested does not exist, create it
   by adding the appropriate file lists.  The default install lists, its 
   member file lists and their default location are described below - 

   a. INSTALL_MI_LIST : Installs header file to a location that is available to
      everyone in user level. 
      Locations -
	  $(DSTROOT)/usr/include
      Definition -
	  INSTALL_MI_LIST = ${DATAFILES}

   b. INSTALL_MI_LCL_LIST : Installs header file to a location that is available
      for Apple internal in user level.
      Locations -
	  $(DSTROOT)/System/Library/Frameworks/System.framework/PrivateHeaders
      Definition -
	  INSTALL_MI_LCL_LIST = ${PRIVATE_DATAFILES}

   c. INSTALL_KF_MI_LIST : Installs header file to location that is available
      to everyone for kernel extensions.
      Locations -
	  $(DSTROOT)/System/Library/Frameworks/Kernel.framework/Headers
      Definition -
	  INSTALL_KF_MI_LIST = ${KERNELFILES}

   d. INSTALL_KF_MI_LCL_LIST : Installs header file to location that is 
      available for Apple internal for kernel extensions.
      Locations -
	  $(DSTROOT)/System/Library/Frameworks/Kernel.framework/PrivateHeaders
      Definition -
	  INSTALL_KF_MI_LCL_LIST = ${KERNELFILES} ${PRIVATE_KERNELFILES}

4) If you want to install the header file in a sub-directory of the paths 
   described in (1), specify the directory name using two variable 
   INSTALL_MI_DIR and EXPORT_MI_DIR as follows - 

   INSTALL_MI_DIR = dirname
   EXPORT_MI_DIR = dirname

5) A single header file can exist at different locations using the steps 
   mentioned above.  However it might not be desirable to make all the code
   in the header file available at all the locations.  For example, you 
   want to export a function only to kernel level but not user level.

   You can use C language's pre-processor directive (#ifdef, #endif, #ifndef)
   to control the text generated before a header file is installed.  The kernel 
   only includes the code if the conditional macro is TRUE and strips out 
   code for FALSE conditions from the header file.  

   Some pre-defined macros and their descriptions are -
   a. PRIVATE : If true, code is available to all of the xnu kernel and is 
      not available in kernel extensions and user level header files.  The 
      header files installed in all the paths described above in (1) will not 
      have code enclosed within this macro.

   b. KERNEL_PRIVATE : Same as PRIVATE

   c. BSD_KERNEL_PRIVATE : If true, code is available to the xnu/bsd part of 
      the kernel and is not available to rest of the kernel, kernel extensions 
      and user level header files.  The header files installed in all the 
      paths described above in (1) will not have code enclosed within this 
      macro.

   d. KERNEL :  If true, code is available only in kernel and kernel 
      extensions and is not available in user level header files.  Only the 
      header files installed in following paths will have the code - 
	  $(DSTROOT)/System/Library/Frameworks/Kernel.framework/Headers
	  $(DSTROOT)/System/Library/Frameworks/Kernel.framework/PrivateHeaders
