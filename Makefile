REPOS := hanke/nibabel.git nipy/nipy.git fperez/nitime.git Garyfallidis/dipy.git miketrumpis/xipy.git
PROJECTS := $(shell echo $(REPOS) | sed -e 's,\S*/\(\S*\).git,\1,g')

PYTHON ?= python
INSTALLDIR=$(CURDIR)/install

RUN=$(CURDIR)/bin/runc
export DRY
PYTHONPATH := $(PYTHONPATH):$(INSTALLDIR)/usr/lib/
export PYTHONPATH

all:
	@echo $(PROJECTS);

all-%:
	: I: $* all subprojects
	@$(MAKE) $(foreach prj, $(PROJECTS), $*-$(prj))

# Rules for specific actions
clean-%:
	@cd $*; $(RUN) "clean $*" $(PYTHON) setup.py clean

build-%:
	@cd $*; $(RUN) "build $*" $(PYTHON) setup.py build

install-%:
	@cd $*; $(RUN) "install $*" $(PYTHON) setup.py install --prefix=$(INSTALLDIR)


# Shortcuts
clean: all-clean
	rm -rf install
dist-clean: all-clean
	# nitime and xipy still have build
	rm -rf $(foreach prj, $(PROJECTS), $(prj)/build)
	# DiPy doesn't remove generated .c files upon clean
	find dipy -iname *.c -delete

build: all-build
install: all-install

# Initial creation
init:
	git init
	for r in $(REPOS); do git submodule add git://github.com/$$r; done

reinit: wipe init

# Primarily for Yarik's initial playground
wipe:
	for r in $(REPOS); do rm -rf `echo $${r#*/} | sed -e 's,.git,,g'`; done
	rm -rf .git*

.PHONY: init reinit wipe
