# README file for NWPS utils
# Last modified: 06/03/2016

The NWPS utils are built and installed using the build script:

> ./build_utils.sh

Following extensive testing the highest performance is an Intel build
without IOBUF. All the NWPS utils will be built with the Intel
wrappers without IOBUF, using buffered STDIO file functions.

For testing the binaries in each source code directory:

> ./build_utils.sh NOCLEAN NOINSTALL

In each source code directory there is a testdata directory with a job
card for COMPUTE node testing.

For manual testing there is a README.txt file in each source
directory.

The Intel build for the NWPS utils binaries are built for both
haswell and sandybridge architecture, reference:

http://wcossdocs.ncep.noaa.gov/userwiki/index.php/Using_modules_on_TO4

"make" ENV variables used by implicit make rules are set in the build
script, reference: 

https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html

All the makefile use the "make" ENV variables to define the compiler
and flags. If you need to test other compiler environments all you
need to do is change the make variables in your user ENV and run the
"make" command in the source code directory.





