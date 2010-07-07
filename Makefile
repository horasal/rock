.PHONY: all clean mrproper prepare_bootstrap bootstrap install
PARSER_GEN=greg
NQ_PATH=source/rock/frontend/NagaQueen.c
DATE=$(shell date +%Y-%m-%d)
TIME=$(shell date +%H:%M)
OOC_OWN_FLAGS=-sourcepath=source -v +-w +-O0 -g -ignoredefine=ROCK_BUILD_

PREFIX?=/usr
MAN_INSTALL_PATH?=/usr/local/man/man1
BIN_INSTALL_PATH?=${PREFIX}/bin

ifdef WINDIR
	OOC_OWN_FLAGS+=+-DROCK_BUILD_DATE=\\\"${DATE}\\\" +-DROCK_BUILD_TIME=\\\"${TIME}\\\"
else
	OOC_OWN_FLAGS+=+-DROCK_BUILD_DATE=\"${DATE}\" +-DROCK_BUILD_TIME=\"${TIME}\"
endif

OOC?=rock
OOC_CMD=${OOC} ${OOC_OWN_FLAGS} ${OOC_FLAGS}

all: bootstrap

# Regenerate NagaQueen.c from the greg grammar
# you need ../nagaqueen and greg to be in your path
#
# http://github.com/nddrylliog/nagaqueen
# http://github.com/nddrylliog/greg
grammar:
	${PARSER_GEN} ../nagaqueen/grammar/nagaqueen.leg > source/rock/frontend/NagaQueen.c

# Prepares the build/ directory, used for bootstrapping
# The build/ directory contains all the C sources needed to build rock
# and a nice Makefile, too
prepare_bootstrap:
	@echo "Preparing boostrap (in build/ directory)"
	rm -rf build/
	${OOC} -driver=make -sourcepath=source -outpath=c-source rock/rock -o=../bin/c_rock c-source/${NQ_PATH} -v -g +-w
	sed s/-w.*/-w\ -DROCK_BUILD_DATE=\\\"\\\\\"bootstrapped\\\\\"\\\"\ -DROCK_BUILD_TIME=\\\"\\\\\"\\\\\"\\\"/ -i build/Makefile
	cp ${NQ_PATH} build/c-source/${NQ_PATH}
	@echo "Done!"

# For c-source based rock releases, 'make bootstrap' will compile a version
# of rock from the C sources in build/, then use that version to re-compile itself
bootstrap:
	@echo "Creating bin/ in case it does not exist."
	mkdir -p bin/
	@echo "Compiling from C source"
	cd build/ && ROCK_DIST=.. make
	@echo "Now re-compiling ourself"
	OOC=bin/c_rock ROCK_DIST=. make self
	@echo "Congrats! you have a boostrapped version of rock in bin/rock now. Have fun!"

# Copy the manpage and create a symlink to the binary
install:
	if [ -e ${BIN_INSTALL_PATH}/rock ]; then echo "${BIN_INSTALL_PATH}/rock already exists, overwriting."; rm ${BIN_INSTALL_PATH}/rock ${BIN_INSTALL_PATH}/rock.exe; fi
	ln -s $(shell pwd)/bin/rock* ${BIN_INSTALL_PATH}/
	install -d ${MAN_INSTALL_PATH}
	install docs/rock.1 ${MAN_INSTALL_PATH}/

# Regenerate the man page from docs/rock.1.txt You need ascidoc for that
man:
	cd docs/ && a2x -f manpage rock.1.txt

# Compile rock with itself
self:
	mkdir -p bin/
	${OOC_CMD} rock/rock -o=bin/rock ${NQ_PATH}

backup:
	cp bin/rock bin/safe_rock

safe:
	OOC=bin/safe_rock make self

clean:
	rm -rf *_tmp/ .libs/
