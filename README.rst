.. -*- mode: rst; fill-column: 78; indent-tabs-mode: nil -*-
.. ex: set sts=4 ts=4 sw=4 et tw=79:

===========
DESCRIPTION
===========

nipy-suite is an umbrella over all projects under NiPy umbrella.  At
the moment that includes:

 NiBabel
   I/O for common neuroimaging file formats
 NiPy
   analysis of structural and functional neuroimaging data
 NiPype
   data analysis pipelines
 NiTime
   time series analysis
 DiPy
   diffusion imaging analysis
 XiPy
   visualization?


=====
Setup
=====

Every Ni*Py subproject is a git submodule, so after cloning
nipy-suite repository, use `git submodule` to fetch actual projects'
repositories (at the moment only from the respective *master
repository*)

::

 git clone git://github.com/nipy/nipy-suite.git
 cd nipy-suite
 git submodule init
 git submodule update

That would assure that you have main repositories available and checked out
for your local nipy-suite collection.  If you want to track all of them and
have additional clones (from developers) be added, it is recommended to make
use of mr_.  If you have it available just run::

  mr -c .mrconfig -t -j update

To get additional remotes pointing to developer's clones added, and fresh
changes fetched.  `-j` runs all operations in parallel to speed up fetching.
`-c .mrconfig -t` is necessary until you incorporate your local nipy-suite
into your global mr_ configuration.  See `nipy-devel post`_ for more details.

.. _mr: http://kitenet.net/~joey/code/mr/
.. _nipy-devel post: http://mail.scipy.org/pipermail/nipy-devel/2010-July/004344.html

============
COMMAND LINE
============

Currently all interactions are coded via Makefile rules.  For
additional verbose output, please add ``VERBOSE=1`` to the cmdline
arguments to make. Following targets are of common use

all (Default)
  Runs `install` and `test` targets
install
  Installs all modules under `install/`
test
  Installs all modules and runs their unittests reporting success of
  failure
testinstall
  Installs all modules and checks either all .py files get installed
clean
  Cleans results of builds, `install/` is preserved
dist-clean
  Calls `clean` and removes `install/`


====
TODO
====

Plenty:

* spot a moment when all unittests pass among all the tools and
  call (tag) it nipy-suite 0.0.1.  I haven't decided yet on how much of
  evilness I should add, e.g. I could tag my clones of all projects with
  corresponding suite-0.0.1 tag... not sure

* probably make it use my own clone of nipy where I would make it
  use nibabel from the module (not from the copy)

* extend testing to

  - doctests
  - representative examples/demos which could be ran non-interactively

* possibly provide interfacing to github:

  - automatically populate git configs of subprojects with remotes
    for everyone in the network (with RW to the owner's clone if he has
    one)
  - visualize summary on how many clones in the network of each project
  - may be figure out either master of each project has plentiful
    of unmerged from the other branches in the network, and visualize
    those

