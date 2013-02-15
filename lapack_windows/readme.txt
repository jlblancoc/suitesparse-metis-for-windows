
LAPACK for Windows: http://icl.cs.utk.edu/lapack-for-windows/


Build Instructions to create LAPACK 3.4.1 dll for Windows with MinGW

Requirements: MinGW, CMAKE 2.8.8, VS IDEs

Download the lapack.tgz from the netlib website and unzip.
http://netlib.org/lapack/lapack.tgz


Download CMAKE and install it on your machine.

Download MinGW 32 bits or MinGW-w64 and install it on your machine.
http://www.mingw.org/
--> Automatic installer, remember to enable C, C++, Fortran.

http://mingw-w64.sourceforge.net/
--> http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Automated%20Builds/mingw-w64-bin_i686-mingw_20111220.zip/download


Put the GNU runtime directory in your PATH, for me I added Add C:\MinGW\bin in my PATH (right click on your computer icon, go to properties, advanced system settings, Environment Variables, look for the PATH variable and put 'C:\MinGW\bin;' in front of its current value)

Open CMAKE

Point to your lapack-3.4.1 folder as the source code folder

Point to a new folder where you want the build to be (not the same is better)

Click configure, check the install path if you want to have the libraries and includes in a particular location.

Choose MinGW Makefiles.
Click "Specify native compilers" and indicate the path to the Mingw compilers. On my machine, it is "C:/MinGW/bin/gfortran.exe"
Set the 'BUILD_SHARED_LIBS' option to ON.

Click again configure until everything becomes white

Click generate, that will create the mingw build.

Close CMAKE

Open a cmd prompt (Click Run.. then enter cmd)

Go to your build folder using the cd command

Type C:/MinGW/bin/mingw32-make.exe
Type C:/MinGW/bin/mingw32-make.exe test if you want to run LAPACK testings to make sure everything is ok

Your libs are in the lib folder, the dlls are in the bin folder. The resulting build will provide both GNU-format and MS-format import libraries for the DLLs.

Now you should be able to create a C application built with MSVC and linked directly to the MinGW-built LAPACK DLLs

NOTE: Your C application built with Microsoft Visual Studio and linked to the MinGW-built lapack DLLs will run but requires the GNU runtime DLLs ( both libgfortran-3.dll and libgcc_s_dw2-1.dll are needed.) from MinGW to be available. As you have the GNU runtime directory in your PATH, you should be good to go.

For MinGW: (32 bits)


For MinGW64: 
D:\mingw-w64-bin_i686-mingw_20111220\x86_64-w64-mingw32\lib\libgfortran-3.dll
...


Thank you to the CMAKE guys for providing this build.

