# Makefile for Tokyo Cabinet



#================================================================
# Setting Variables
#================================================================


# Generic settings
SHELL = /bin/bash

# Package information
PACKAGE = tokyocabinet
VERSION = 1.4.48
PACKAGEDIR = $(PACKAGE)-$(VERSION)
PACKAGETGZ = $(PACKAGE)-$(VERSION).tar.gz
LIBVER = 9
LIBREV = 10
FORMATVER = 1.0

# Targets
HEADERFILES = tcutil.h tchdb.h tcbdb.h tcfdb.h tctdb.h tcadb.h
LIBRARYFILES = libtokyocabinet.a libtokyocabinet.so.9.10.0 libtokyocabinet.so.9 libtokyocabinet.so
LIBOBJFILES = glob.o mman.o regex.o mingw32_wrapper.o tcutil.o tchdb.o tcbdb.o tcfdb.o tctdb.o tcadb.o myconf.o md5.o
COMMANDFILES = tcutest tcumttest tcucodec tchtest tchmttest tchmgr tcbtest tcbmttest tcbmgr tcftest tcfmttest tcfmgr tcttest tctmttest tctmgr tcatest tcamttest tcamgr
CGIFILES = tcawmgr.cgi
MAN1FILES = tcutest.1 tcumttest.1 tcucodec.1 tchtest.1 tchmttest.1 tchmgr.1 tcbtest.1 tcbmttest.1 tcbmgr.1 tcftest.1 tcfmttest.1 tcfmgr.1 tcttest.1 tctmttest.1 tctmgr.1 tcatest.1 tcamttest.1 tcamgr.1
MAN3FILES = tokyocabinet.3 tcutil.3 tcxstr.3 tclist.3 tcmap.3 tctree.3 tcmdb.3 tcmpool.3 tchdb.3 tcbdb.3 tcfdb.3 tctdb.3 tcadb.3
DOCUMENTFILES = COPYING ChangeLog doc tokyocabinet.idl
PCFILES = tokyocabinet.pc

# Install destinations
prefix = /usr/local
exec_prefix = ${prefix}
datarootdir = ${prefix}/share
INCLUDEDIR = ${prefix}/include
LIBDIR = ${exec_prefix}/lib
BINDIR = ${exec_prefix}/bin
LIBEXECDIR = ${exec_prefix}/libexec
DATADIR = ${datarootdir}/$(PACKAGE)
MAN1DIR = ${datarootdir}/man/man1
MAN3DIR = ${datarootdir}/man/man3
PCDIR = ${exec_prefix}/lib/pkgconfig
DESTDIR =

# Building configuration
CC = x86_64-w64-mingw32-gcc
CPPFLAGS = -I. -I$(INCLUDEDIR) -I/home/jjlauer/include -I/usr/local/include -DNDEBUG -D_GNU_SOURCE=1 -D_REENTRANT -D__EXTENSIONS__ -D_MYNOZLIB -D_MYNOBZIP \
  -D_TC_PREFIX="\"$(prefix)\"" -D_TC_INCLUDEDIR="\"$(INCLUDEDIR)\"" \
  -D_TC_LIBDIR="\"$(LIBDIR)\"" -D_TC_BINDIR="\"$(BINDIR)\"" -D_TC_LIBEXECDIR="\"$(LIBEXECDIR)\"" \
  -D_TC_APPINC="\"-I$(INCLUDEDIR)\"" -D_TC_APPLIBS="\"-L$(LIBDIR) -ltokyocabinet -lpthread -lm \""
CFLAGS = -g -O2 -std=gnu99 -Wall  -fsigned-char -O2 -D_POSIX_C_SOURCE
LDFLAGS = -L. -L$(LIBDIR) -L/home/jjlauer/lib -L/usr/local/lib
CMDLDFLAGS = 
LIBS = -lpthread -lm -lpsapi
LDENV = LD_RUN_PATH=/lib:/usr/lib:$(LIBDIR):$(HOME)/lib:/usr/local/lib:$(LIBDIR):.
RUNENV = LD_LIBRARY_PATH=.:/lib:/usr/lib:$(LIBDIR):$(HOME)/lib:/usr/local/lib:$(LIBDIR)
POSTCMD = true



#================================================================
# Suffix rules
#================================================================


.SUFFIXES :
.SUFFIXES : .c .o

.c.o :
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $<



#================================================================
# Actions
#================================================================


all : $(LIBRARYFILES) $(COMMANDFILES) $(CGIFILES)
	@$(POSTCMD)
	@printf '\n'
	@printf '#================================================================\n'
	@printf '# Ready to install.\n'
	@printf '#================================================================\n'


clean :
	rm -rf $(LIBRARYFILES) $(LIBOBJFILES) $(COMMANDFILES) $(CGIFILES) \
	  *.o a.out tokyocabinet_all.c check.in check.out gmon.out *.vlog words.tsv \
	  casket casket-* casket.* *.tch *.tcb *.tcf *.tct *.idx.* *.wal *~ hoge moge tako ika


version :
	vernum=`expr $(LIBVER)00 + $(LIBREV)` ; \
	  sed -e 's/_TC_VERSION.*/_TC_VERSION    "$(VERSION)"/' \
	    -e "s/_TC_LIBVER.*/_TC_LIBVER     $$vernum/" \
	    -e 's/_TC_FORMATVER.*/_TC_FORMATVER  "$(FORMATVER)"/' tcutil.h > tcutil.h~
	[ -f tcutil.h~ ] && mv -f tcutil.h~ tcutil.h


untabify :
	ls *.c *.h *.idl | while read name ; \
	  do \
	    sed -e 's/\t/        /g' -e 's/ *$$//' $$name > $$name~; \
	    [ -f $$name~ ] && mv -f $$name~ $$name ; \
	  done


install :
	mkdir -p $(DESTDIR)$(INCLUDEDIR)
	cp -Rf $(HEADERFILES) $(DESTDIR)$(INCLUDEDIR)
	mkdir -p $(DESTDIR)$(LIBDIR)
	cp -Rf $(LIBRARYFILES) $(DESTDIR)$(LIBDIR)
	mkdir -p $(DESTDIR)$(BINDIR)
	cp -Rf $(COMMANDFILES) $(DESTDIR)$(BINDIR)
	mkdir -p $(DESTDIR)$(LIBEXECDIR)
	cp -Rf $(CGIFILES) $(DESTDIR)$(LIBEXECDIR)
	mkdir -p $(DESTDIR)$(DATADIR)
	cp -Rf $(DOCUMENTFILES) $(DESTDIR)$(DATADIR)
	mkdir -p $(DESTDIR)$(MAN1DIR)
	cd man && cp -Rf $(MAN1FILES) $(DESTDIR)$(MAN1DIR)
	mkdir -p $(DESTDIR)$(MAN3DIR)
	cd man && cp -Rf $(MAN3FILES) $(DESTDIR)$(MAN3DIR)
	mkdir -p $(DESTDIR)$(PCDIR)
	cp -Rf $(PCFILES) $(DESTDIR)$(PCDIR)
	-[ "$$UID" = 0 ] && PATH=/sbin:/usr/sbin:$(PATH) ldconfig 2>/dev/null || true
	@printf '\n'
	@printf '#================================================================\n'
	@printf '# Thanks for using Tokyo Cabinet.\n'
	@printf '#================================================================\n'


install-strip :
	make DESTDIR=$(DESTDIR) install
	cd $(DESTDIR)$(BINDIR) && strip $(COMMANDFILES)


uninstall :
	cd $(DESTDIR)$(INCLUDEDIR) && rm -f $(HEADERFILES)
	cd $(DESTDIR)$(LIBDIR) && rm -f $(LIBRARYFILES)
	cd $(DESTDIR)$(BINDIR) && rm -f $(COMMANDFILES)
	cd $(DESTDIR)$(LIBEXECDIR) && rm -f $(CGIFILES)
	cd $(DESTDIR)$(MAN1DIR) && rm -f $(MAN1FILES)
	cd $(DESTDIR)$(MAN3DIR) && rm -f $(MAN3FILES)
	rm -rf $(DESTDIR)$(DATADIR)
	cd $(DESTDIR)$(PCDIR) && rm -f $(PCFILES)
	[ "$$UID" = 0 ] && PATH=/sbin:/usr/sbin:$(PATH) ldconfig 2>/dev/null || true


dist :
	make version
	make untabify
	make distclean
	cd .. && tar cvf - $(PACKAGEDIR) | gzip -c > $(PACKAGETGZ)
	sync ; sync


distclean : clean
	cd example && make clean
	cd bros && make clean
	rm -rf Makefile tokyocabinet.pc config.cache config.log config.status autom4te.cache


check :
	make check-util
	make check-hdb
	make check-bdb
	make check-fdb
	make check-tdb
	make check-adb
	rm -rf casket*
	@printf '\n'
	@printf '#================================================================\n'
	@printf '# Checking completed.\n'
	@printf '#================================================================\n'


check-util :
	rm -rf casket*
	$(RUNENV) $(RUNCMD) ./tcamgr version
	$(RUNENV) $(RUNCMD) ./tcutest xstr 50000
	$(RUNENV) $(RUNCMD) ./tcutest list -rd 50000
	$(RUNENV) $(RUNCMD) ./tcutest map -rd -tr 50000
	$(RUNENV) $(RUNCMD) ./tcutest map -rd -tr -rnd -dc 50000
	$(RUNENV) $(RUNCMD) ./tcutest tree -rd -tr 50000
	$(RUNENV) $(RUNCMD) ./tcutest tree -rd -tr -rnd -dc 50000
	$(RUNENV) $(RUNCMD) ./tcutest mdb -rd -tr 50000
	$(RUNENV) $(RUNCMD) ./tcutest mdb -rd -tr -rnd -dc 50000
	$(RUNENV) $(RUNCMD) ./tcutest mdb -rd -tr -rnd -dpr 50000
	$(RUNENV) $(RUNCMD) ./tcutest ndb -rd -tr 50000
	$(RUNENV) $(RUNCMD) ./tcutest ndb -rd -tr -rnd -dc 50000
	$(RUNENV) $(RUNCMD) ./tcutest ndb -rd -tr -rnd -dpr 50000
	$(RUNENV) $(RUNCMD) ./tcutest misc 500
	$(RUNENV) $(RUNCMD) ./tcutest wicked 50000
	$(RUNENV) $(RUNCMD) ./tcumttest combo 5 50000 500
	$(RUNENV) $(RUNCMD) ./tcumttest combo -rnd 5 50000 500
	$(RUNENV) $(RUNCMD) ./tcumttest typical 5 50000 5000
	$(RUNENV) $(RUNCMD) ./tcumttest typical -rr 1000 5 50000 5000
	$(RUNENV) $(RUNCMD) ./tcumttest typical -nc 5 50000 5000
	$(RUNENV) $(RUNCMD) ./tcumttest combo -tr 5 50000 500
	$(RUNENV) $(RUNCMD) ./tcumttest combo -tr -rnd 5 50000 500
	$(RUNENV) $(RUNCMD) ./tcumttest typical -tr 5 50000 5000
	$(RUNENV) $(RUNCMD) ./tcumttest typical -tr -rr 1000 5 50000 5000
	$(RUNENV) $(RUNCMD) ./tcumttest typical -tr -nc 5 50000 5000
	$(RUNENV) $(RUNCMD) ./tcucodec url Makefile > check.in
	$(RUNENV) $(RUNCMD) ./tcucodec url -d check.in > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec base Makefile > check.in
	$(RUNENV) $(RUNCMD) ./tcucodec base -d check.in > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec quote Makefile > check.in
	$(RUNENV) $(RUNCMD) ./tcucodec quote -d check.in > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec mime Makefile > check.in
	$(RUNENV) $(RUNCMD) ./tcucodec mime -d check.in > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec pack -bwt Makefile > check.in
	$(RUNENV) $(RUNCMD) ./tcucodec pack -d -bwt check.in > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec tcbs Makefile > check.in
	$(RUNENV) $(RUNCMD) ./tcucodec tcbs -d check.in > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec zlib Makefile > check.in
	$(RUNENV) $(RUNCMD) ./tcucodec zlib -d check.in > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec xml Makefile > check.in
	$(RUNENV) $(RUNCMD) ./tcucodec xml -d check.in > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec cstr Makefile > check.in
	$(RUNENV) $(RUNCMD) ./tcucodec cstr -d check.in > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec ucs Makefile > check.in
	$(RUNENV) $(RUNCMD) ./tcucodec ucs -d check.in > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec date -ds '1978-02-11T18:05:30+09:00' -rf > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec cipher -key "mikio" Makefile > check.in
	$(RUNENV) $(RUNCMD) ./tcucodec cipher -key "mikio" check.in > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec tmpl -var name mikio -var nick micky \
	  '@name=[%name%][%IF nick%] nick=[%nick%][%END%][%IF hoge%][%ELSE%].[%END%]' > check.out
	$(RUNENV) $(RUNCMD) ./tcucodec conf > check.out
	rm -rf casket*


check-hdb :
	rm -rf casket*
	$(RUNENV) $(RUNCMD) ./tchtest write casket 50000 5000 5 5
	$(RUNENV) $(RUNCMD) ./tchtest read casket
	$(RUNENV) $(RUNCMD) ./tchtest remove casket
	$(RUNENV) $(RUNCMD) ./tchtest write -mt -tl -td -rc 50 -xm 500000 casket 50000 5000 5 5
	$(RUNENV) $(RUNCMD) ./tchtest read -mt -nb -rc 50 -xm 500000 casket
	$(RUNENV) $(RUNCMD) ./tchtest remove -mt -rc 50 -xm 500000 casket
	$(RUNENV) $(RUNCMD) ./tchtest write -as -tb -rc 50 -xm 500000 casket 50000 50000 5 5
	$(RUNENV) $(RUNCMD) ./tchtest read -nl -rc 50 -xm 500000 casket
	$(RUNENV) $(RUNCMD) ./tchtest remove -rc 50 -xm 500000 -df 5 casket
	$(RUNENV) $(RUNCMD) ./tchtest rcat -pn 500 -xm 50000 -df 5 casket 50000 5000 5 5
	$(RUNENV) $(RUNCMD) ./tchtest rcat -tl -td -pn 5000 casket 50000 500 5 15
	$(RUNENV) $(RUNCMD) ./tchtest rcat -nl -pn 500 -rl casket 5000 500 5 5
	$(RUNENV) $(RUNCMD) ./tchtest rcat -tb -pn 500 casket 5000 500 5 5
	$(RUNENV) $(RUNCMD) ./tchtest rcat -ru -pn 500 casket 5000 500 1 1
	$(RUNENV) $(RUNCMD) ./tchtest rcat -tl -td -ru -pn 500 casket 5000 500 1 1
	$(RUNENV) $(RUNCMD) ./tchmgr list -pv casket > check.out
	$(RUNENV) $(RUNCMD) ./tchmgr list -pv -fm 1 -px casket > check.out
	$(RUNENV) $(RUNCMD) ./tchtest misc casket 5000
	$(RUNENV) $(RUNCMD) ./tchtest misc -tl -td casket 5000
	$(RUNENV) $(RUNCMD) ./tchtest misc -mt -tb casket 500
	$(RUNENV) $(RUNCMD) ./tchtest wicked casket 50000
	$(RUNENV) $(RUNCMD) ./tchtest wicked -tl -td casket 50000
	$(RUNENV) $(RUNCMD) ./tchtest wicked -mt -tb casket 5000
	$(RUNENV) $(RUNCMD) ./tchtest wicked -tt casket 5000
	$(RUNENV) $(RUNCMD) ./tchtest wicked -tx casket 5000
	$(RUNENV) $(RUNCMD) ./tchmttest write -xm 500000 -df 5 -tl casket 5 5000 500 5
	$(RUNENV) $(RUNCMD) ./tchmttest read -xm 500000 -df 5 casket 5
	$(RUNENV) $(RUNCMD) ./tchmttest read -xm 500000 -rnd casket 5
	$(RUNENV) $(RUNCMD) ./tchmttest remove -xm 500000 casket 5
	$(RUNENV) $(RUNCMD) ./tchmttest wicked -nc casket 5 5000
	$(RUNENV) $(RUNCMD) ./tchmttest wicked -tl -td casket 5 5000
	$(RUNENV) $(RUNCMD) ./tchmttest wicked -tb casket 5 5000
	$(RUNENV) $(RUNCMD) ./tchmttest typical -df 5 casket 5 50000 5000
	$(RUNENV) $(RUNCMD) ./tchmttest typical -rr 1000 casket 5 50000 5000
	$(RUNENV) $(RUNCMD) ./tchmttest typical -tl -rc 50000 -nc casket 5 50000 5000
	$(RUNENV) $(RUNCMD) ./tchmttest race -df 5 casket 5 10000
	$(RUNENV) $(RUNCMD) ./tchmgr create casket 3 1 1
	$(RUNENV) $(RUNCMD) ./tchmgr inform casket
	$(RUNENV) $(RUNCMD) ./tchmgr put casket one first
	$(RUNENV) $(RUNCMD) ./tchmgr put casket two second
	$(RUNENV) $(RUNCMD) ./tchmgr put -dk casket three third
	$(RUNENV) $(RUNCMD) ./tchmgr put -dc casket three third
	$(RUNENV) $(RUNCMD) ./tchmgr put -dc casket three third
	$(RUNENV) $(RUNCMD) ./tchmgr put -dc casket three third
	$(RUNENV) $(RUNCMD) ./tchmgr put casket four fourth
	$(RUNENV) $(RUNCMD) ./tchmgr put -dk casket five fifth
	$(RUNENV) $(RUNCMD) ./tchmgr out casket one
	$(RUNENV) $(RUNCMD) ./tchmgr out casket two
	$(RUNENV) $(RUNCMD) ./tchmgr get casket three > check.out
	$(RUNENV) $(RUNCMD) ./tchmgr get casket four > check.out
	$(RUNENV) $(RUNCMD) ./tchmgr get casket five > check.out
	$(RUNENV) $(RUNCMD) ./tchmgr list -pv casket > check.out
	$(RUNENV) $(RUNCMD) ./tchmgr optimize casket
	$(RUNENV) $(RUNCMD) ./tchmgr put -dc casket three third
	$(RUNENV) $(RUNCMD) ./tchmgr get casket three > check.out
	$(RUNENV) $(RUNCMD) ./tchmgr get casket four > check.out
	$(RUNENV) $(RUNCMD) ./tchmgr get casket five > check.out
	$(RUNENV) $(RUNCMD) ./tchmgr list -pv casket > check.out
	rm -rf casket*


check-bdb :
	rm -rf casket*
	$(RUNENV) $(RUNCMD) ./tcbtest write casket 50000 5 5 5000 5 5
	$(RUNENV) $(RUNCMD) ./tcbtest read casket
	$(RUNENV) $(RUNCMD) ./tcbtest remove casket
	$(RUNENV) $(RUNCMD) ./tcbmgr list -rb 00001000 00002000 casket > check.out
	$(RUNENV) $(RUNCMD) ./tcbmgr list -fm 000001 casket > check.out
	$(RUNENV) $(RUNCMD) ./tcbtest write -mt -tl -td -ls 1024 casket 50000 5000 5000 5000 5 5
	$(RUNENV) $(RUNCMD) ./tcbtest read -mt -nb casket
	$(RUNENV) $(RUNCMD) ./tcbtest remove -mt casket
	$(RUNENV) $(RUNCMD) ./tcbtest write -tb -xm 50000 casket 50000 5 5 50000 5 5
	$(RUNENV) $(RUNCMD) ./tcbtest read -nl casket
	$(RUNENV) $(RUNCMD) ./tcbtest remove -df 5 casket
	$(RUNENV) $(RUNCMD) ./tcbtest rcat -lc 5 -nc 5 -df 5 -pn 500 casket 50000 5 5 5000 5 5
	$(RUNENV) $(RUNCMD) ./tcbtest rcat -tl -td -pn 5000 casket 50000 5 5 500 5 15
	$(RUNENV) $(RUNCMD) ./tcbtest rcat -nl -pn 5000 -rl casket 15000 5 5 500 5 5
	$(RUNENV) $(RUNCMD) ./tcbtest rcat -ca 1000 -tb -pn 5000 casket 15000 5 5 500 5 5
	$(RUNENV) $(RUNCMD) ./tcbtest rcat -ru -pn 500 casket 5000 5 5 500 1 1
	$(RUNENV) $(RUNCMD) ./tcbtest rcat -cd -tl -td -ru -pn 500 casket 5000 5 5 500 1 1
	$(RUNENV) $(RUNCMD) ./tcbmgr list -pv casket > check.out
	$(RUNENV) $(RUNCMD) ./tcbtest queue casket 15000 5 5
	$(RUNENV) $(RUNCMD) ./tcbtest misc casket 5000
	$(RUNENV) $(RUNCMD) ./tcbtest misc -tl -td casket 5000
	$(RUNENV) $(RUNCMD) ./tcbtest misc -mt -tb casket 500
	$(RUNENV) $(RUNCMD) ./tcbtest wicked casket 50000
	$(RUNENV) $(RUNCMD) ./tcbtest wicked -tl -td casket 50000
	$(RUNENV) $(RUNCMD) ./tcbtest wicked -mt -tb casket 5000
	$(RUNENV) $(RUNCMD) ./tcbtest wicked -tt casket 5000
	$(RUNENV) $(RUNCMD) ./tcbtest wicked -tx casket 5000
	$(RUNENV) $(RUNCMD) ./tcbtest write -cd -lc 5 -nc 5 casket 5000 5 5 5 5 5
	$(RUNENV) $(RUNCMD) ./tcbtest read -cd -lc 5 -nc 5 casket
	$(RUNENV) $(RUNCMD) ./tcbtest remove -cd -lc 5 -nc 5 casket
	$(RUNENV) $(RUNCMD) ./tcbmgr list -pv casket > check.out
	$(RUNENV) $(RUNCMD) ./tcbtest write -ci -td -lc 5 -nc 5 casket 5000 5 5 5 5 5
	$(RUNENV) $(RUNCMD) ./tcbtest read -ci -lc 5 -nc 5 casket
	$(RUNENV) $(RUNCMD) ./tcbtest remove -ci -lc 5 -nc 5 casket
	$(RUNENV) $(RUNCMD) ./tcbmgr list -pv casket > check.out
	$(RUNENV) $(RUNCMD) ./tcbtest write -cj -tb -lc 5 -nc 5 casket 5000 5 5 5 5 5
	$(RUNENV) $(RUNCMD) ./tcbtest read -cj -lc 5 -nc 5 casket
	$(RUNENV) $(RUNCMD) ./tcbtest remove -cj -lc 5 -nc 5 casket
	$(RUNENV) $(RUNCMD) ./tcbmgr list -pv casket > check.out
	$(RUNENV) $(RUNCMD) ./tcbmttest write -df 5 -tl casket 5 5000 5 5 500 5
	$(RUNENV) $(RUNCMD) ./tcbmttest read -df 5 casket 5
	$(RUNENV) $(RUNCMD) ./tcbmttest read -rnd casket 5
	$(RUNENV) $(RUNCMD) ./tcbmttest remove casket 5
	$(RUNENV) $(RUNCMD) ./tcbmttest wicked -nc casket 5 5000
	$(RUNENV) $(RUNCMD) ./tcbmttest wicked -tl -td casket 5 5000
	$(RUNENV) $(RUNCMD) ./tchmttest wicked -tb casket 5 5000
	$(RUNENV) $(RUNCMD) ./tcbmttest typical -df 5 casket 5 50000 5 5
	$(RUNENV) $(RUNCMD) ./tcbmttest typical -rr 1000 casket 5 50000 5 5
	$(RUNENV) $(RUNCMD) ./tcbmttest typical -tl -nc casket 5 50000 5 5
	$(RUNENV) $(RUNCMD) ./tcbmttest race -df 5 casket 5 10000
	$(RUNENV) $(RUNCMD) ./tcbmgr create casket 4 4 3 1 1
	$(RUNENV) $(RUNCMD) ./tcbmgr inform casket
	$(RUNENV) $(RUNCMD) ./tcbmgr put casket one first
	$(RUNENV) $(RUNCMD) ./tcbmgr put casket two second
	$(RUNENV) $(RUNCMD) ./tcbmgr put -dk casket three third
	$(RUNENV) $(RUNCMD) ./tcbmgr put -dc casket three third
	$(RUNENV) $(RUNCMD) ./tcbmgr put -dc casket three third
	$(RUNENV) $(RUNCMD) ./tcbmgr put -dd casket three third
	$(RUNENV) $(RUNCMD) ./tcbmgr put -dd casket three third
	$(RUNENV) $(RUNCMD) ./tcbmgr put casket four fourth
	$(RUNENV) $(RUNCMD) ./tcbmgr put -dk casket five fifth
	$(RUNENV) $(RUNCMD) ./tcbmgr out casket one
	$(RUNENV) $(RUNCMD) ./tcbmgr out casket two
	$(RUNENV) $(RUNCMD) ./tcbmgr get casket three > check.out
	$(RUNENV) $(RUNCMD) ./tcbmgr get casket four > check.out
	$(RUNENV) $(RUNCMD) ./tcbmgr get casket five > check.out
	$(RUNENV) $(RUNCMD) ./tcbmgr list -pv casket > check.out
	$(RUNENV) $(RUNCMD) ./tcbmgr list -j three -pv casket > check.out
	$(RUNENV) $(RUNCMD) ./tcbmgr optimize casket
	$(RUNENV) $(RUNCMD) ./tcbmgr put -dc casket three third
	$(RUNENV) $(RUNCMD) ./tcbmgr get casket three > check.out
	$(RUNENV) $(RUNCMD) ./tcbmgr get casket four > check.out
	$(RUNENV) $(RUNCMD) ./tcbmgr get casket five > check.out
	$(RUNENV) $(RUNCMD) ./tcbmgr list -pv casket > check.out


check-fdb :
	rm -rf casket*
	$(RUNENV) $(RUNCMD) ./tcftest write casket 50000 50
	$(RUNENV) $(RUNCMD) ./tcftest read casket
	$(RUNENV) $(RUNCMD) ./tcftest remove casket
	$(RUNENV) $(RUNCMD) ./tcftest write casket 50000 50
	$(RUNENV) $(RUNCMD) ./tcftest read -mt -nb casket
	$(RUNENV) $(RUNCMD) ./tcftest remove -mt casket
	$(RUNENV) $(RUNCMD) ./tcftest rcat -pn 500 casket 50000 50
	$(RUNENV) $(RUNCMD) ./tcftest rcat -nl -pn 500 -rl casket 5000 500
	$(RUNENV) $(RUNCMD) ./tcftest rcat -pn 500 -ru casket 5000 500
	$(RUNENV) $(RUNCMD) ./tcfmgr list -pv casket > check.out
	$(RUNENV) $(RUNCMD) ./tcfmgr list -pv -ri "[100,200)" -px casket > check.out
	$(RUNENV) $(RUNCMD) ./tcftest misc casket 5000
	$(RUNENV) $(RUNCMD) ./tcftest misc -mt -nl casket 500
	$(RUNENV) $(RUNCMD) ./tcftest wicked casket 50000
	$(RUNENV) $(RUNCMD) ./tcftest wicked -mt -nb casket 50000
	$(RUNENV) $(RUNCMD) ./tcfmttest write casket 5 5000 50
	$(RUNENV) $(RUNCMD) ./tcfmttest read casket 5
	$(RUNENV) $(RUNCMD) ./tcfmttest read -rnd casket 5
	$(RUNENV) $(RUNCMD) ./tcfmttest remove casket 5
	$(RUNENV) $(RUNCMD) ./tcfmttest wicked -nc casket 5 5000
	$(RUNENV) $(RUNCMD) ./tcfmttest wicked casket 5 5000
	$(RUNENV) $(RUNCMD) ./tcfmttest typical casket 5 50000 50
	$(RUNENV) $(RUNCMD) ./tcfmttest typical -rr 1000 casket 5 50000 50
	$(RUNENV) $(RUNCMD) ./tcfmttest typical -nc casket 5 50000 50
	$(RUNENV) $(RUNCMD) ./tcfmgr create casket 50
	$(RUNENV) $(RUNCMD) ./tcfmgr inform casket
	$(RUNENV) $(RUNCMD) ./tcfmgr put casket 1 first
	$(RUNENV) $(RUNCMD) ./tcfmgr put casket 2 second
	$(RUNENV) $(RUNCMD) ./tcfmgr put -dk casket 3 third
	$(RUNENV) $(RUNCMD) ./tcfmgr put -dc casket 3 third
	$(RUNENV) $(RUNCMD) ./tcfmgr put -dc casket 3 third
	$(RUNENV) $(RUNCMD) ./tcfmgr put -dc casket 3 third
	$(RUNENV) $(RUNCMD) ./tcfmgr put casket 4 fourth
	$(RUNENV) $(RUNCMD) ./tcfmgr put -dk casket 5 fifth
	$(RUNENV) $(RUNCMD) ./tcfmgr out casket 1
	$(RUNENV) $(RUNCMD) ./tcfmgr out casket 2
	$(RUNENV) $(RUNCMD) ./tcfmgr get casket 3 > check.out
	$(RUNENV) $(RUNCMD) ./tcfmgr get casket 4 > check.out
	$(RUNENV) $(RUNCMD) ./tcfmgr get casket 5 > check.out
	$(RUNENV) $(RUNCMD) ./tcfmgr list -pv casket > check.out
	$(RUNENV) $(RUNCMD) ./tcfmgr optimize casket 5
	$(RUNENV) $(RUNCMD) ./tcfmgr put -dc casket 3 third
	$(RUNENV) $(RUNCMD) ./tcfmgr get casket 3 > check.out
	$(RUNENV) $(RUNCMD) ./tcfmgr get casket 4 > check.out
	$(RUNENV) $(RUNCMD) ./tcfmgr get casket 5 > check.out
	$(RUNENV) $(RUNCMD) ./tcfmgr list -pv casket > check.out


check-tdb :
	rm -rf casket*
	$(RUNENV) $(RUNCMD) ./tcttest write casket 50000 5000 5 5
	$(RUNENV) $(RUNCMD) ./tcttest read casket
	$(RUNENV) $(RUNCMD) ./tcttest remove casket
	$(RUNENV) $(RUNCMD) ./tcttest write -mt -tl -td -rc 50 -lc 5 -nc 5 -xm 500000 \
	  -is -in -it -if -ix casket 5000 5000 5 5
	$(RUNENV) $(RUNCMD) ./tcttest read -mt -nb -rc 50 -lc 5 -nc 5 -xm 500000 casket
	$(RUNENV) $(RUNCMD) ./tcttest remove -mt -rc 50 -lc 5 -nc 5 -xm 500000 -df 5 casket
	$(RUNENV) $(RUNCMD) ./tcttest rcat -pn 500 -xm 50000 -df 5 -is casket 5000 5000 5 5
	$(RUNENV) $(RUNCMD) ./tcttest rcat -tl -td -pn 5000 -is -in casket 5000 500 5 15
	$(RUNENV) $(RUNCMD) ./tcttest rcat -nl -pn 500 -rl -is -in casket 5000 500 5 5
	$(RUNENV) $(RUNCMD) ./tcttest rcat -tb -pn 500 -is -in casket 5000 500 5 5
	$(RUNENV) $(RUNCMD) ./tcttest rcat -ru -pn 500 -is -in casket 5000 500 1 1
	$(RUNENV) $(RUNCMD) ./tcttest rcat -tl -td -ru -pn 500 -is -in casket 5000 500 1 1
	$(RUNENV) $(RUNCMD) ./tctmgr list -pv casket > check.out
	$(RUNENV) $(RUNCMD) ./tctmgr list -pv -px casket > check.out
	$(RUNENV) $(RUNCMD) ./tcttest misc casket 500
	$(RUNENV) $(RUNCMD) ./tcttest misc -tl -td casket 500
	$(RUNENV) $(RUNCMD) ./tcttest misc -mt -tb casket 500
	$(RUNENV) $(RUNCMD) ./tcttest wicked casket 5000
	$(RUNENV) $(RUNCMD) ./tcttest wicked -tl -td casket 5000
	$(RUNENV) $(RUNCMD) ./tcttest wicked -mt -tb casket 5000
	$(RUNENV) $(RUNCMD) ./tcttest wicked -tt casket 5000
	$(RUNENV) $(RUNCMD) ./tcttest wicked -tx casket 5000
	$(RUNENV) $(RUNCMD) ./tctmttest write -xm 500000 -df 5 -tl -is -in casket 5 5000 500 5
	$(RUNENV) $(RUNCMD) ./tctmttest read -xm 500000 -df 5 casket 5
	$(RUNENV) $(RUNCMD) ./tctmttest read -xm 500000 -rnd casket 5
	$(RUNENV) $(RUNCMD) ./tctmttest remove -xm 500000 casket 5
	$(RUNENV) $(RUNCMD) ./tctmttest wicked casket 5 5000
	$(RUNENV) $(RUNCMD) ./tctmttest wicked -tl -td casket 5 5000
	$(RUNENV) $(RUNCMD) ./tctmttest typical -df 5 casket 5 5000 500
	$(RUNENV) $(RUNCMD) ./tctmttest typical -rr 1000 casket 5 5000 500
	$(RUNENV) $(RUNCMD) ./tctmttest typical -tl -rc 50000 -lc 5 -nc 5 casket 5 5000 500
	$(RUNENV) $(RUNCMD) ./tctmgr create casket 3 1 1
	$(RUNENV) $(RUNCMD) ./tctmgr setindex casket name
	$(RUNENV) $(RUNCMD) ./tctmgr inform casket
	$(RUNENV) $(RUNCMD) ./tctmgr put casket "" name mikio birth 19780211 lang ja,en,c
	$(RUNENV) $(RUNCMD) ./tctmgr put casket "" name fal birth 19771007 lang ja
	$(RUNENV) $(RUNCMD) ./tctmgr put casket "" name banana price 100
	$(RUNENV) $(RUNCMD) ./tctmgr put -dc casket 3 color yellow
	$(RUNENV) $(RUNCMD) ./tctmgr put -dk casket "" name melon price 1200 color green
	$(RUNENV) $(RUNCMD) ./tctmgr put casket "" name void birth 20010101 lang en
	$(RUNENV) $(RUNCMD) ./tctmgr out casket 5
	$(RUNENV) $(RUNCMD) ./tctmgr get casket 1 > check.out
	$(RUNENV) $(RUNCMD) ./tctmgr get casket 2 > check.out
	$(RUNENV) $(RUNCMD) ./tctmgr get casket 3 > check.out
	$(RUNENV) $(RUNCMD) ./tctmgr search casket > check.out
	$(RUNENV) $(RUNCMD) ./tctmgr search -m 10 -sk 1 -pv -ph casket > check.out
	$(RUNENV) $(RUNCMD) ./tctmgr search -m 10 -ord name STRDESC -pv -ph casket > check.out
	$(RUNENV) $(RUNCMD) ./tctmgr search -m 10 -ord name STRDESC -pv -ph casket \
	  name STRBW mi birth NUMBT 19700101,19791231 lang STRAND ja,en > check.out
	$(RUNENV) $(RUNCMD) ./tctmgr search -ord birth NUMDESC -pv -ms UNION casket \
	  name STREQ mikio name STRINC fal name FTSEX "ba na na"
	$(RUNENV) $(RUNCMD) ./tctmgr setindex casket name
	$(RUNENV) $(RUNCMD) ./tctmgr setindex -it dec casket birth
	$(RUNENV) $(RUNCMD) ./tctmgr setindex casket lang
	$(RUNENV) $(RUNCMD) ./tctmgr list -pv casket > check.out
	$(RUNENV) $(RUNCMD) ./tctmgr optimize casket
	$(RUNENV) $(RUNCMD) ./tctmgr put casket "" name tokyo country japan lang ja
	$(RUNENV) $(RUNCMD) ./tctmgr search -m 10 -sk 1 -pv -ph casket > check.out
	$(RUNENV) $(RUNCMD) ./tctmgr search -m 10 -ord name STRDESC -pv -ph casket > check.out
	$(RUNENV) $(RUNCMD) ./tctmgr search -m 10 -ord name STRDESC -pv -ph casket \
	  name STRBW mi birth NUMBT 19700101,19791231 lang STRAND ja,en > check.out
	$(RUNENV) $(RUNCMD) ./tctmgr search -ord price NUMDESC -ph -rm casket name STRINC a
	$(RUNENV) $(RUNCMD) ./tctmgr list -pv casket > check.out


check-adb :
	rm -rf casket*
	$(RUNENV) $(RUNCMD) ./tcatest write 'casket.tch#mode=wct#bnum=5000' 50000
	$(RUNENV) $(RUNCMD) ./tcatest read 'casket.tch#mode=r'
	$(RUNENV) $(RUNCMD) ./tcatest remove 'casket.tch#mode=w'
	$(RUNENV) $(RUNCMD) ./tcatest misc 'casket.tch#mode=wct#bnum=500#opts=ld' 5000
	$(RUNENV) $(RUNCMD) ./tcatest wicked 'casket.tch#mode=wct' 5000
	$(RUNENV) $(RUNCMD) ./tcatest write '@casket.tcb#mode=wct#lmemb=5#nmemb=5' 50000
	$(RUNENV) $(RUNCMD) ./tcatest read '@casket.tcb#mode=r'
	$(RUNENV) $(RUNCMD) ./tcatest remove '@casket.tcb#mode=w'
	$(RUNENV) $(RUNCMD) ./tcatest misc '@casket.tcb#mode=wct#lmemb=5#nmemb=5#opts=ld' 5000
	$(RUNENV) $(RUNCMD) ./tcatest wicked '@casket.tcb#mode=wct' 5000
	$(RUNENV) $(RUNCMD) ./tcatest write 'casket.tcf#mode=wct#width=10' 50000
	$(RUNENV) $(RUNCMD) ./tcatest read 'casket.tcf#mode=r'
	$(RUNENV) $(RUNCMD) ./tcatest remove 'casket.tcf#mode=w'
	$(RUNENV) $(RUNCMD) ./tcatest write '*#bnum=5000#cap=100' 50000
	$(RUNENV) $(RUNCMD) ./tcatest misc '*' 5000
	$(RUNENV) $(RUNCMD) ./tcatest wicked '*' 5000
	$(RUNENV) $(RUNCMD) ./tcatest write '%casket-mul.tch#mode=wct#bnum=500' 50000
	$(RUNENV) $(RUNCMD) ./tcatest read '%casket-mul.tch#mode=r'
	$(RUNENV) $(RUNCMD) ./tcatest remove '%casket-mul.tch#mode=w'
	$(RUNENV) $(RUNCMD) ./tcatest misc '%casket-mul.tch#mode=wct#bnum=500#opts=ld' 5000
	$(RUNENV) $(RUNCMD) ./tcatest wicked '%casket-mul.tch#mode=wct' 5000
	$(RUNENV) $(RUNCMD) ./tcatest compare casket 50 500
	$(RUNENV) $(RUNCMD) ./tcatest compare casket 5 5000
	$(RUNENV) $(RUNCMD) ./tcamttest write 'casket.tch#mode=wct#bnum=5000' 5 5000
	$(RUNENV) $(RUNCMD) ./tcamttest read 'casket.tch#mode=r' 5
	$(RUNENV) $(RUNCMD) ./tcamttest remove 'casket.tch#mode=w' 5
	$(RUNENV) $(RUNCMD) ./tcamttest write '%casket-mul.tcb#mode=wct#bnum=5000' 5 5000
	$(RUNENV) $(RUNCMD) ./tcamttest read '%casket-mul.tcb#mode=r' 5
	$(RUNENV) $(RUNCMD) ./tcamttest remove '%casket-mul.tcb#mode=w' 5
	$(RUNENV) $(RUNCMD) ./tcamgr create 'casket.tch#mode=wct#bnum=3'
	$(RUNENV) $(RUNCMD) ./tcamgr inform 'casket.tch'
	$(RUNENV) $(RUNCMD) ./tcamgr put casket.tch one first
	$(RUNENV) $(RUNCMD) ./tcamgr put casket.tch two second
	$(RUNENV) $(RUNCMD) ./tcamgr put -dk casket.tch three third
	$(RUNENV) $(RUNCMD) ./tcamgr put -dc casket.tch three third
	$(RUNENV) $(RUNCMD) ./tcamgr put -dc casket.tch three third
	$(RUNENV) $(RUNCMD) ./tcamgr put -dc casket.tch three third
	$(RUNENV) $(RUNCMD) ./tcamgr put casket.tch four fourth
	$(RUNENV) $(RUNCMD) ./tcamgr put -dk casket.tch five fifth
	$(RUNENV) $(RUNCMD) ./tcamgr out casket.tch one
	$(RUNENV) $(RUNCMD) ./tcamgr out casket.tch two
	$(RUNENV) $(RUNCMD) ./tcamgr get casket.tch three > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr get casket.tch four > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr get casket.tch five > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr list -pv -fm f casket.tch > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr optimize casket.tch
	$(RUNENV) $(RUNCMD) ./tcamgr put -dc casket.tch three third
	$(RUNENV) $(RUNCMD) ./tcamgr get casket.tch three > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr get casket.tch four > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr get casket.tch five > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr misc casket.tch putlist six sixth seven seventh
	$(RUNENV) $(RUNCMD) ./tcamgr misc casket.tch outlist six
	$(RUNENV) $(RUNCMD) ./tcamgr misc casket.tch getlist three four five six > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr list -pv casket.tch > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr create 'casket.tct#mode=wct#idx=name:lex#idx=age:dec'
	$(RUNENV) $(RUNCMD) ./tcamgr put -sep '|' casket.tct 1 "name|mikio|age|30"
	$(RUNENV) $(RUNCMD) ./tcamgr put -sep '|' casket.tct 2 "name|fal|age|31"
	$(RUNENV) $(RUNCMD) ./tcamgr put -sep '|' casket.tct 3 "name|lupin|age|29"
	$(RUNENV) $(RUNCMD) ./tcamgr get -sep '\t' casket.tct 1 > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr list -sep '\t' -pv casket.tct > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr misc -sep '|' casket.tct search \
	  "addcond|name|STRINC|i" "setorder|age|NUMASC" "setmax|1" "get" > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr misc -sep '|' casket.tct search "get" "out" > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr create '%casket-mul.tcb#mode=wct'
	$(RUNENV) $(RUNCMD) ./tcamgr put '%casket-mul.tcb' one first
	$(RUNENV) $(RUNCMD) ./tcamgr put '%casket-mul.tcb' two second
	$(RUNENV) $(RUNCMD) ./tcamgr put -dk '%casket-mul.tcb' three third
	$(RUNENV) $(RUNCMD) ./tcamgr put -dc '%casket-mul.tcb' three third
	$(RUNENV) $(RUNCMD) ./tcamgr put -dc '%casket-mul.tcb' three third
	$(RUNENV) $(RUNCMD) ./tcamgr put -dc '%casket-mul.tcb' three third
	$(RUNENV) $(RUNCMD) ./tcamgr put '%casket-mul.tcb' four fourth
	$(RUNENV) $(RUNCMD) ./tcamgr put -dk '%casket-mul.tcb' five fifth
	$(RUNENV) $(RUNCMD) ./tcamgr out '%casket-mul.tcb' one
	$(RUNENV) $(RUNCMD) ./tcamgr out '%casket-mul.tcb' two
	$(RUNENV) $(RUNCMD) ./tcamgr get '%casket-mul.tcb' three > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr get '%casket-mul.tcb' four > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr get '%casket-mul.tcb' five > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr list -pv -fm f '%casket-mul.tcb' > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr optimize '%casket-mul.tcb'
	$(RUNENV) $(RUNCMD) ./tcamgr put -dc '%casket-mul.tcb' three third
	$(RUNENV) $(RUNCMD) ./tcamgr get '%casket-mul.tcb' three > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr get '%casket-mul.tcb' four > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr get '%casket-mul.tcb' five > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr misc '%casket-mul.tcb' '%putlist' six sixth seven seventh
	$(RUNENV) $(RUNCMD) ./tcamgr misc '%casket-mul.tcb' '@outlist' six
	$(RUNENV) $(RUNCMD) ./tcamgr misc '%casket-mul.tcb' '@getlist' \
	  three four five six > check.out
	$(RUNENV) $(RUNCMD) ./tcamgr list -pv '%casket-mul.tcb' > check.out


check-valgrind :
	make RUNCMD="valgrind --tool=memcheck --log-file=%p.vlog" check
	grep ERROR *.vlog | grep -v ' 0 errors' ; true
	grep 'at exit' *.vlog | grep -v ' 0 bytes' ; true


check-large :
	rm -rf casket*
	$(RUNENV) $(RUNCMD) ./tchmttest typical casket 3 1000000 5000000 13 8
	$(RUNENV) $(RUNCMD) ./tchmttest typical -nc casket 3 1000000 5000000 13 8
	$(RUNENV) $(RUNCMD) ./tcbmttest typical casket 3 500000 8 8 500000 16 8
	$(RUNENV) $(RUNCMD) ./tcbmttest typical -nc casket 3 500000 8 8 500000 16 8
	$(RUNENV) $(RUNCMD) ./tcfmttest typical casket 3 500000 2048 4g
	$(RUNENV) $(RUNCMD) ./tcfmttest typical -nc casket 3 500000 2048 4g
	rm -rf casket*


check-compare :
	$(RUNENV) $(RUNCMD) ./tcatest compare casket 5 10000
	$(RUNENV) $(RUNCMD) ./tcatest compare casket 10 5000
	$(RUNENV) $(RUNCMD) ./tcatest compare casket 50 1000
	$(RUNENV) $(RUNCMD) ./tcatest compare casket 100 500


check-thread :
	rm -rf casket*
	$(RUNENV) $(RUNCMD) ./tcumttest typical 5 500000 500000
	$(RUNENV) $(RUNCMD) ./tcumttest typical -nc -rr 1000 5 500000 500000
	$(RUNENV) $(RUNCMD) ./tchmttest typical casket 5 500000 500000
	$(RUNENV) $(RUNCMD) ./tchmttest typical -rc 500000 -nc -rr 1000 casket 5 500000 500000
	$(RUNENV) $(RUNCMD) ./tcbmttest typical casket 5 100000 5 5
	$(RUNENV) $(RUNCMD) ./tcbmttest typical -nc -rr 1000 casket 5 100000 5 5
	$(RUNENV) $(RUNCMD) ./tcfmttest typical casket 5 500000 10
	$(RUNENV) $(RUNCMD) ./tcfmttest typical -nc -rr 1000 casket 5 500000 10
	rm -rf casket*


check-race :
	$(RUNENV) $(RUNCMD) ./tchmttest race casket 5 10000
	$(RUNENV) $(RUNCMD) ./tcbmttest race casket 5 10000


check-forever :
	while true ; \
	  do \
	    make check || break ; \
	    make check || break ; \
	    make check-thread || break ; \
	    make check-race || break ; \
	    make check-race || break ; \
	    make check-compare || break ; \
	    make check-compare || break ; \
	  done


words :
	rm -f casket-* words.tsv
	cat /usr/share/dict/words | \
	  tr '\t\r' '  ' | grep -v '^ *$$' | cat -n | sort | \
	  LC_ALL=C sed -e 's/^ *//' -e 's/\(^[0-9]*\)\t\(.*\)/\2\t\1/' > words.tsv
	./tchmgr create casket-hash -1 0 ; ./tchmgr importtsv casket-hash words.tsv
	./tcbmgr create casket-btree 8192 ; ./tcbmgr importtsv casket-btree words.tsv
	./tcbmgr create -td casket-btree-td 8192 ; ./tcbmgr importtsv casket-btree-td words.tsv
	./tcbmgr create -tb casket-btree-tb 8192 ; ./tcbmgr importtsv casket-btree-tb words.tsv
	./tcbmgr create -tt casket-btree-tt 8192 ; ./tcbmgr importtsv casket-btree-tt words.tsv
	./tcbmgr create -tx casket-btree-tx 8192 ; ./tcbmgr importtsv casket-btree-tx words.tsv
	wc -c words.tsv casket-hash casket-btree \
	  casket-btree-td casket-btree-tb casket-btree-tt casket-btree-tx


wordtable :
	rm -rf casket* words.tsv
	cat /usr/share/dict/words | \
	  tr '\t\r' '  ' | grep -v '^ *$$' | cat -n | sort | \
	  LC_ALL=C sed -e 's/^ *//' -e 's/\(^[0-9]*\)\t\(.*\)/\1\tword\t\2\tnum\t\1/' \
	    -e 's/$$/\txxx\tabc\tyyy\t123/' > words.tsv
	./tctmgr create casket
	./tctmgr setindex casket word
	./tctmgr setindex -it dec casket num
	./tctmgr importtsv casket words.tsv


.PHONY : all clean install check



#================================================================
# Building binaries
#================================================================


libtokyocabinet.a : $(LIBOBJFILES)
	$(AR) $(ARFLAGS) $@ $(LIBOBJFILES)


libtokyocabinet.so.$(LIBVER).$(LIBREV).0 : $(LIBOBJFILES)
	if uname -a | egrep -i 'SunOS' > /dev/null ; \
	  then \
	    $(CC) $(CFLAGS) -shared -Wl,-G,-h,libtokyocabinet.so.$(LIBVER) -o $@ \
	      $(LIBOBJFILES) $(LDFLAGS) $(LIBS) ; \
	  else \
	    $(CC) $(CFLAGS) -shared -Wl,-soname,libtokyocabinet.so.$(LIBVER) -o $@ \
	      $(LIBOBJFILES) $(LDFLAGS) $(LIBS) ; \
	  fi


libtokyocabinet.so.$(LIBVER) : libtokyocabinet.so.$(LIBVER).$(LIBREV).0
	ln -f -s libtokyocabinet.so.$(LIBVER).$(LIBREV).0 $@


libtokyocabinet.so : libtokyocabinet.so.$(LIBVER).$(LIBREV).0
	ln -f -s libtokyocabinet.so.$(LIBVER).$(LIBREV).0 $@


libtokyocabinet.$(LIBVER).$(LIBREV).0.dylib : $(LIBOBJFILES)
	$(CC) $(CFLAGS) -dynamiclib -o $@ \
	  -install_name $(LIBDIR)/libtokyocabinet.$(LIBVER).dylib \
	  -current_version $(LIBVER).$(LIBREV).0 -compatibility_version $(LIBVER) \
	  $(LIBOBJFILES) $(LDFLAGS) $(LIBS)


libtokyocabinet.$(LIBVER).dylib : libtokyocabinet.$(LIBVER).$(LIBREV).0.dylib
	ln -f -s libtokyocabinet.$(LIBVER).$(LIBREV).0.dylib $@


libtokyocabinet.dylib : libtokyocabinet.$(LIBVER).$(LIBREV).0.dylib
	ln -f -s libtokyocabinet.$(LIBVER).$(LIBREV).0.dylib $@


tcutest : tcutest.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcumttest : tcumttest.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcucodec : tcucodec.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tchtest : tchtest.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tchmttest : tchmttest.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tchmgr : tchmgr.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcbtest : tcbtest.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcbmttest : tcbmttest.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcbmgr : tcbmgr.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcftest : tcftest.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcfmttest : tcfmttest.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcfmgr : tcfmgr.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcttest : tcttest.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tctmttest : tctmttest.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tctmgr : tctmgr.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcatest : tcatest.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcamttest : tcamttest.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcamgr : tcamgr.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


tcawmgr.cgi : tcawmgr.o $(LIBRARYFILES)
	$(LDENV) $(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(CMDLDFLAGS) -ltokyocabinet $(LIBS)


myconf.o : myconf.h

tcutil.o : myconf.h tcutil.h md5.h

tchdb.o : myconf.h tcutil.h tchdb.h

tcbdb.o : myconf.h tcutil.h tchdb.h tcbdb.h

tcfdb.o : myconf.h tcutil.h tcfdb.h

tctdb.o : myconf.h tcutil.h tchdb.h tctdb.h

tcadb.o : myconf.h tcutil.h tchdb.h tcbdb.h tcfdb.h tctdb.h tcadb.h

tcutest.o tcucodec.o : myconf.h tcutil.h

tchtest.o tchmttest.o tchmgr.o : myconf.h tcutil.h tchdb.h

tcbtest.o tcbmttest.o tcbmgr.o : myconf.h tcutil.h tchdb.h tcbdb.h

tcftest.o tcfmttest.o tcfmgr.o : myconf.h tcutil.h tcfdb.h

tcttest.o tctmttest.o tctmgr.o : myconf.h tcutil.h tchdb.h tcbdb.h tctdb.h

tcatest.o tcamttest.o tcamgr.o tcawmgr.o : \
  myconf.h tcutil.h tchdb.h tcbdb.h tcfdb.h tctdb.h tcadb.h


tokyocabinet_all.c : myconf.c tcutil.c md5.c tchdb.c tcbdb.c tcfdb.c tctdb.c tcadb.c
	cat myconf.c tcutil.c md5.c tchdb.c tcbdb.c tcfdb.c tctdb.c tcadb.c > $@

tokyocabinet_all.o : myconf.h tcutil.h tchdb.h tcbdb.h tcfdb.h tctdb.h tcadb.h



# END OF FILE
