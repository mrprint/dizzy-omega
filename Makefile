BIN     = $(DESTDIR)/usr/bin
SHARE   = $(DESTDIR)/usr/share/unde

all: dizzy_omega
	$(MAKE) $(AM_MAKEFLAGS) -C sounds

dub.json: dub.json_pre
	grep -q 14.04 /etc/lsb-release && sed 's/2.0.0/1.9.6/' dub.json_pre > dub.json || cp dub.json_pre dub.json

dizzy_omega: dub.json
	OPTIONS="";\
	file /bin/bash | grep -q x86-64 || OPTIONS="--compiler=gdc";\
	grep -q 14.04 /etc/lsb-release && OPTIONS="$$OPTIONS -c Ubuntu_14_04";\
	dub build $$OPTIONS

clean:
	$(MAKE) $(AM_MAKEFLAGS) -C sounds clean
	rm -f dizzy_omega dub.selections.json dub.json
	rm -rf .dub
