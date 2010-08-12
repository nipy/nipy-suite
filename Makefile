REPOS := nipy/nibabel.git nipy/nipy.git nipy/nitime.git Garyfallidis/dipy.git miketrumpis/xipy.git nipy/nipype.git
PROJECTS := $(shell echo $(REPOS) | sed -e 's,\S*/\(\S*\).git,\1,g')

PYTHON ?= python
INDENT := | sed -e "s/^/\t/g"
INSTALLDIR=$(CURDIR)/install

RUN=$(CURDIR)/bin/runc
export DRY VERBOSE

PYTHONVERSION := $(shell $(PYTHON) --version 2>&1 | sed -e 's/\S* \([0-9]*\.[0-9]*\)[.ab].*/\1/g')
# TODO: installation path
PYTHONINSTALLPATH := $(INSTALLDIR)/lib/python$(PYTHONVERSION)/site-packages/
PYTHONPATH := $(PYTHONPATH):$(PYTHONINSTALLPATH)
export PYTHONPATH

ifndef VERBOSE
NOSEARGS=-q
else
NOSEARGS=
endif

all: install test

all-%:
	@echo I: $* all subprojects
	@$(MAKE) -k $(foreach prj, $(PROJECTS), $*-$(prj))

# Rules for specific actions
clean-%:
	@cd $*; $(RUN) "clean $*" $(PYTHON) setup.py clean

build-%:
	@cd $*; $(RUN) "build $*" $(PYTHON) setup.py build

install-%:
	@cd $*; $(RUN) "install $*" $(PYTHON) setup.py install --prefix=$(INSTALLDIR)

unittest-%: cleaninstall-%
# To make sure things up-to-date
	@[ -z $$VERBOSE ] ||  echo "PYTHONPATH=$$PYTHONPATH"
	@$(RUN) "Assuring uptodate install of $*" $(MAKE) install-$*
	@cd $(INSTALLDIR) && $(RUN) "Testing $*" nosetests $(NOSEARGS) $*

testinstall-%: install-%
# To check either all python code is installed
# TODO: make compatible with any Python... too late now -- just testing
	@cd $*/$*; find -iname \*.py | grep -v build/| sort >| /tmp/1.txt
	@cd $(PYTHONINSTALLPATH)/$*; find . -iname \*.py | sort >| /tmp/2.txt
	@echo " I: testinstall $*"
	@diff /tmp/1.txt /tmp/2.txt | grep -v '__config__.py' \
	| { grep '^[><]' && exit 2 || :; }

test-%: unittest-% testinstall-%
	:

# Dependencies:
install-nipy: install-nibabel
install-dipy: install-nibabel install-nipy
install-nitime: install-nibabel
install-xipy: install-nipy install-dipy

# Shortcuts
clean: all-clean
	# nipy(?) leaves things behind
	-rm failed.nii.gz
	# nitime and xipy still have build
	rm -rf $(foreach prj, $(PROJECTS), $(prj)/build)
	# DiPy doesn't remove generated .c files upon clean
	find dipy -iname *.c -delete

cleaninstall-%:
	rm -rf $(PYTHONINSTALLPATH)/$**

dist-clean: clean
	rm -rf install

build: all-build
install: all-install
test: all-test
unittest: all-unittest
testinstall: all-testinstall

# To oversee repositories
status:
	@echo I: Current repository
	@git describe $(INDENT)
	@git status $(INDENT)
	@echo I: Submodules
	@git submodule status $(INDENT)

describe:
	@echo I: Main module version:
	@git describe $(INDENT)
	@echo I: Dependent modules
	@git submodule foreach '{ git describe 2>/dev/null || git show-ref --abbrev HEAD; } $(INDENT)'

reset-to-suite:
	@echo "I: Resetting all submodules to suite's versions"
	@git submodule foreach 'git checkout master && git reset --hard $$sha1'

pull:
	@echo I: Fetching and pulling the master branches
	@git submodule foreach 'git checkout master && git pull'

each-%:
	@echo I: Running git $% foreach submodule
	git submodule foreach git $*

# Invoke ipython in current "environment"
ipython:
	ipython
shell:
	$(SHELL)

# Initial creation
init:
	git init
	for r in $(REPOS); do git submodule add git://github.com/$$r; done

reinit: wipe init

# Primarily for Yarik's initial playground
wipe:
	for r in $(REPOS); do rm -rf `echo $${r#*/} | sed -e 's,.git,,g'`; done
	rm -rf .git*

.PHONY: init reinit wipe install status build test clean dist-clean
