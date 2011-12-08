VERSION=0.1.0
BUILD=0

prefix=/usr/local
bindir=${prefix}/bin
libdir=${prefix}/lib
mandir=${prefix}/share/man

all:

clean:

install:
	install bin/scdlr.sh $(DESTDIR)$(bindir)/
	install lib/scdlr.sh $(DESTDIR)$(libdir)/

uninstall:
	rm -f $(DESTDIR)$(bindir)/scdlr.sh
	rm -f $(DESTDIR)$(libdir)/scdlr.sh

gh-pages:
	git checkout -q gh-pages
	shocco lib/scdlr.sh >scdlr.sh.html+
	mv scdlr.sh.html+ index.html
	git add index.html
	git commit -m "Rebuilt docs."
	git push origin gh-pages
	git checkout -q master

.PHONY: all clean install uninstall test gh-pages