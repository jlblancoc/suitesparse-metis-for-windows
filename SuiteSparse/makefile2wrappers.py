#!/usr/bin/python
# Generate "wrapper sources" for compiling the same file several times with CMake for UMFPACK
# (Jose Luis Blanco)

import os
import sys
import re
import string

#------   MAIN   -------
def main():
	f = open("makefile2wrappers.txt","r");
	lins = f.readlines();
	f.close();
	
	for l in lins:
		l = l.strip();
		if len(l)==0 or l.startswith('#'):
			continue;

		print('Line: '+l);
		# $(C) -DDINT -c ../Source/umf_analyze.c -o umf_i_analyze.o
		defs=re.match(".*\)(.*)-c",l).group(1).strip();
		# If there's no "-o" flag, just compile the file as is:
		if re.search('.*-o.*',l)!=None:
			src=re.match(".*-c(.*)-o",l).group(1).strip();
			out=re.match(".*-o(.*)",l).group(1).strip();
			f='SourceWrappers/'+out+".c";
			print(' => Creating '+f+'\n');
			o = open(f,"w");
			DEFs = defs.strip().split("-D");
			DEFs = [x for x in DEFs if x]; # Remove empty 
			# If we have "CS_COMPLEX", wrap the entire thing in a #ifndef NCOMPLEX ... #endif
			has_complex=False
			if 'CS_COMPLEX' in DEFs:
				has_complex=True
			# TODO: Other COMPLEX flags?
			
			if has_complex:
				o.write('#ifndef NCOMPLEX\n');
			# Pre-definitions:
			for d in DEFs:
				o.write('#define '+d+'\n');
			# The source code itself:
			o.write('#include <'+src+'>'+'\n');
			if has_complex:
				o.write('#endif // NCOMPLEX\n');
			o.close();	
		else:
			src=re.match(".*-c(.*)",l).group(1).strip();
			f = "SourceWrappers/"+os.path.basename(src);
			print(' => Creating '+f+'\n');
			o = open(f,"w");
			o.write('#include <'+src+'>'+'\n');
			o.close();
				
	return 0
#-----------


def replaceInFile(fileIn, fileOut, textToSearch, newText) :
    o = open(fileOut,"w")
    data = open(fileIn).read()
    for idx in range(len(textToSearch)):
        data = re.sub(textToSearch[idx], newText[idx], data)
    o.write(data)
    o.close()
#-----------
	
	
if __name__ == "__main__":
    sys.exit(main())

