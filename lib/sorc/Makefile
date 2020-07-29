all:
	@echo "Attempting to compile libemapf."
	(cd ./emapf-c && make clean all)
	@echo "-----------------------------"
	@echo "Attempting to compile libgd."
	(cd ./gd && make clean)
	(cd ./gd && make)
	cp ./gd/libgd.a ../
	@echo "-----------------------------"

clean:
	@echo "Attempting to clean libemapf."
	(cd ./emapf-c && make clean)
	@echo "-----------------------------"
	@echo "Attempting to clean libgd."
	(cd ./gd && make clean)
	@echo "-----------------------------"

install: all
	@echo "Attempting to install libemapf."
	(cd ./emapf-c && make install)
	@echo "-----------------------------"
	@echo "Attempting to install libgd."
	cp ./gd/libgd.a ../
	@echo "-----------------------------"
