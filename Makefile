REPOS := hanke/nibabel.git nipy/nipy.git fperez/nitime.git Garyfallidis/dipy.git miketrumpis/xipy.git
PROJECTS := $(shell echo $(REPOS) | sed -e 's,\S*/\(\S*\).git,\1,g')

PYTHON ?= python
INSTALLDIR=$(CURDIR)/install

RUN=$(CURDIR)/bin/runc
export DRY VERBOSE
# TODO: python version and installation path
PYTHONPATH := $(PYTHONPATH):$(INSTALLDIR)/lib/python2.6/site-packages/
export PYTHONPATH

all:
	@echo $(PROJECTS);

all-%:
	@echo I: $* all subprojects
	@$(MAKE) $(foreach prj, $(PROJECTS), $*-$(prj))

# Rules for specific actions
clean-%:
	@cd $*; $(RUN) "clean $*" $(PYTHON) setup.py clean

build-%:
	@cd $*; $(RUN) "build $*" $(PYTHON) setup.py build

install-%:
	@cd $*; $(RUN) "install $*" $(PYTHON) setup.py install --prefix=$(INSTALLDIR)

test-%:
# To make sure things up-to-date
	@$(RUN) "Assuring uptodate install of $*" $(MAKE) install-$*
	@$(RUN) "Testing $*" nosetests -q $*

# Shortcuts
dist-clean: all-clean
	# nitime and xipy still have build
	rm -rf $(foreach prj, $(PROJECTS), $(prj)/build)
	# DiPy doesn't remove generated .c files upon clean
	find dipy -iname *.c -delete

clean: dist-clean
	rm -rf install

build: all-build
install: all-install
test: all-test

# To oversee repositories
status:
	: I: Current repository
	git status
	: I: Submodules
	git submodule status

# Invoke ipython in current "environment"
ipython:
	ipython

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
