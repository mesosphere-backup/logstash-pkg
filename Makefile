# Note that the prefix affects the init scripts as well.
prefix := usr/
app := logstash
prefix := net.logstash # For OS X. 

.PHONY: deb
deb: version with-upstart
	cd toor && \
	fpm -t deb -s dir \
	    -n $(app) -v `cat ../version` -p ../$(app).deb .

.PHONY: rpm
rpm: version with-upstart
	cd toor && \
	fpm -t rpm -s dir \
	    -n $(app) -v `cat ../version` -p ../$(app).rpm .

.PHONY: osx
osx: version just-jar
	cd toor && \
	fpm -t osxpkg --osxpkg-identifier-prefix $(prefix) -s dir \
	    -n $(app) -v `cat ../version` -p ../$(app).pkg .

.PHONY: with-upstart
with-upstart: just-jar $(app).conf
	mkdir -p toor/etc/init
	cp $(app).conf toor/etc/init/

.PHONY: just-jar
just-jar: runnable.jar
	mkdir -p toor/$(prefix)/bin
	cp $< toor/$(prefix)/bin/$(app)
	chmod 755 toor/$(prefix)/bin/$(app)

runnable.jar:
	cd marathon && mvn package && bin/build-distribution
	cp marathon/target/$@ $@

