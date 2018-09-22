from conans import ConanFile, CMake
from conans.tools import load
import re
def get_version():
    try:
        content = load("SuiteSparse/SuiteSparse_config/SuiteSparse_config.h")
        version_major = re.search(r"#define SUITESPARSE_MAIN_VERSION (.*)", content).group(1)
        version_minor = re.search(r"#define SUITESPARSE_SUB_VERSION (.*)", content).group(1)
        version_update = re.search(r"#define SUITESPARSE_SUBSUB_VERSION (.*)", content).group(1)
        return version_major.strip() + "." + version_minor.strip() + "." + version_update.strip()
    except Exception:
        return None

class SuiteSparseConan(ConanFile):
    name = "SuiteSparse"
    version = get_version()
    license = "LGPL and GPL"
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
        self.copy("*.h", dst="include", src="SuiteSparse/CHOLMOD/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/COLAMD/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/CSparse/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/CXSparse/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/KLU/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/LDL/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/SPQR/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/UMFPACK/Include")
        self.copy("*.h", dst="include", src="SuiteSparse/SuiteSparse_config")

        self.copy("*.hpp", dst="include", src="SuiteSparse/AMD/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/BTF/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/CAMD/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/CCOLAMD/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/CHOLMOD/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/CHOLAMD/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/COLAMD/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/CSparse/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/CXSparse/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/KLU/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/LDL/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/SPQR/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/UMFPACK/Include")
        self.copy("*.hpp", dst="include", src="SuiteSparse/SuiteSparse_config")

        self.copy("*.lib", dst="lib", keep_path=False)
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.dylib*", dst="lib", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)
        self.copy("FindSuiteSparse.cmake", ".", ".")

    def package_info(self):
        if self.settings.os == "Windows":
            self.cpp_info.libs = ['libamd', 'libbtf', 'libcamd', 'libccolamd', 'libcolamd', 'libcholmod', 'libcxsparse', 'libklu', 'libspqr', 'suitesparseconfig', 'libumfpack']
        else:
            self.cpp_info.libs = ['amd', 'btf', 'camd', 'ccolamd', 'colamd', 'cholmod', 'cxsparse', 'klu', 'spqr', 'suitesparseconfig', 'umfpack']