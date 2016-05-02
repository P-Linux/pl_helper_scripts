DESTDIR =
USRBINDIR = /usr/bin
BINDIR = /bin
MANDIR = /usr/share/man
LIBDIR = /usr/lib
ETCDIR = /etc

# TODO: Update this with each release
VERSION = '0.9.0'
NAME = pl_helper_scripts

ifndef PBFD
	PL_BASH_FUNCTIONS_DIR = '/usr/lib/pl_bash_functions'
else
	PL_BASH_FUNCTIONS_DIR = $(PBFD)
endif

PKG_DIR = $(NAME)

# End of file
