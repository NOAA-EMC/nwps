all:
	cd g2clib-1.4.0; make -f linux.mak
	cd iplib; make
	cd gctpc/source; make -f makefile.gctpc
	cd wgrib2; make -f linux.mak

install:
	cd wgrib2; make -f linux.mak install

clean:
	cd g2clib-1.4.0; make -f linux.mak clean
	cd iplib; make clean
	cd gctpc/source; make -f makefile.gctpc	clean
	cd wgrib2; make -f linux.mak clean
