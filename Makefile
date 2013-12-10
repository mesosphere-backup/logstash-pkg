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
with-upstart: just-jar $(app).conf kibana.conf
	mkdir -p toor/etc/init
	cp $(app).conf kibana.conf toor/etc/init/

.PHONY: just-jar
just-jar: runnable.jar
	mkdir -p toor/usr/bin
	mkdir -p toor/etc/logstash/agent.d toor/etc/logstash/web
	cp $< toor/usr/bin/$(app).jar
	chmod 755 toor/usr/bin/$(app).jar

.PHONY: runnable.jar
runnable.jar: logstash logstash.jar
	cat $^ > $@

version: logstash.jar
	java -jar $< version | sed -n '/^logstash  */ { s/// ; p ;}' > $@

logstash.jar: release
	curl -fL `cat $<` --output $@

