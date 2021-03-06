include Makefile.inc

DIRSCRIPTS = scripts

.PHONY: all help install generate clean

all: help

help:
	@echo 'USAGE: `make [option] <target>` where <target> is one of'
	@echo
	@echo '  help              show the help information'
	@echo '  generate          generate final files from `filename.in`'
	@echo '  clean             clean'
	@echo '  install           re-build and install the package'
	@echo
	@echo 'OPTIONS:'
	@echo
	@echo '  PBFD="/path_to/pl_bash_functions_dir/scripts"'
	@echo

install:
	rm -rf	 $(DESTDIR)$(LIBDIR)/$(PKG_DIR)
	install -D -m0755 LICENSE.md $(DESTDIR)$(LIBDIR)/$(PKG_DIR)/LICENSE.md
	install -D -m0755 RELEASE-NOTES.md $(DESTDIR)$(LIBDIR)/$(PKG_DIR)/RELEASE-NOTES.md
	install -D -m0755 README.md $(DESTDIR)$(LIBDIR)/$(PKG_DIR)/README.md
	$(MAKE) -C $(DIRSCRIPTS) install

generate:
	$(MAKE) -C $(DIRSCRIPTS) generate

clean:
	$(MAKE) -C $(DIRSCRIPTS) clean
