JAVA_SRCS=$(wildcard qrcode/*.java)
JAVA_CLASSES=$(JAVA_SRCS:%.java=%.class)

%.class:$(JAVA_SRCS)
	javac $?

zxing_qrcode.jar: $(JAVA_CLASSES)
	jar cf $@ $?

.PHONY: clean

clean:
	$(RM) qrcode/*.class zxing_qrcode.jar
