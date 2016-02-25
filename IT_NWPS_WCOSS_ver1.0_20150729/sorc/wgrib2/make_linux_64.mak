all:
	cd g2clib-1.4.0; make -f linux.mak 64BIT=1
	cd iplib; make
	cd gctpc/source; make -f makefile.gctpc
	cd wgrib2; make -f linux.mak 64BIT=1

install:
	cd wgrib2; make -f linux.mak 64BIT=1 install

clean:
	cd g2clib-1.4.0; make -f linux.mak 64BIT=1 clean
	cd iplib; make clean
	cd gctpc/source; make -f makefile.gctpc clean
	cd wgrib2; make -f linux.mak 64BIT=1 clean
