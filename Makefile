# Note that the prefix affects the init scripts as well.
prefix := usr/
app    := logstash
domain := net.logstash # For OS X.
jar    := logstash-1.2.2-flatjar.jar

.PHONY: deb
deb: version with-upstart
	cd toor && \
	fpm -t deb -s dir \
	    -n $(app) -v `head -n1 ../version` -p ../$(app).deb .

.PHONY: rpm
rpm: version with-upstart
	cd toor && \
	fpm -t rpm -s dir \
	    -n $(app) -v `head -n1 ../version` -p ../$(app).rpm .

.PHONY: osx
osx: version just-jar
	cd toor && \
	fpm -t osxpkg --osxpkg-identifier-prefix $(domain) -s dir \
	    -n $(app) -v `head -n1 ../version` -p ../$(app).pkg .

.PHONY: with-upstart
with-upstart: just-jar $(app).conf
	mkdir -p toor/etc/init
	cp $(app).conf toor/etc/init/

.PHONY: just-jar
just-jar: runnable.jar
	mkdir -p toor/$(prefix)/bin
	cp $< toor/$(prefix)/bin/$(app)
	chmod 755 toor/$(prefix)/bin/$(app)

.PHONY: runnable.jar
runnable.jar: logstash logstash.jar
	cat $^ > $@

version: logstash.jar
	java -jar $< version | sed -n '/^logstash  */ { s/// ; p ;}' > $@

logstash.jar: release
	curl -fL `cat $<` --output $@

