from conans import ConanFile, CMake, tools

class SuiteSparseConan(ConanFile):
    name = "SuiteSparse"
    version = "0.1"
    license = "LGPL"
    url = "<Package recipe repository url here, for issues about the package>"
    description = "<Description of SuiteSparse here>"
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False]}
    default_options = "shared=False"
    generators = "cmake"
    exports_sources = "*"

    def build(self):
        cmake = CMake(self)
        cmake.definitions["BUILD_METIS"] = "OFF"
        cmake.configure(source_folder=".")
        cmake.build()

        # Explicit way:
        # self.run('cmake "%s/src" %s' % (self.source_folder, cmake.command_line))
        # self.run("cmake --build . %s" % cmake.build_config)

    def package(self):
        self.copy("*.h", dst="include", src="SuiteSparse/AMD/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/BTF/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/CAMD/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/CCOLAMD/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/CHOLAMD/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/COLAMD/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/CSparse/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/CXSparse/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/KLU/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/LDL/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/SPQR/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/UMFPACK/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/SuiteSparse_config")
        self.copy("*.lib", dst="lib", keep_path=False)
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.dylib*", dst="lib", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)
        self.copy("FindSuiteSparse.cmake", ".", ".")

    def package_info(self):
        self.cpp_info.libs = ['amd', 'btf', 'camd', 'ccolamd', 'colamd', 'cholmod', 'cxsparse', 'klu', 'spqr', 'suitesparseconfig', 'umfpack']