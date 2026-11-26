#!/usr/bin/env make -f

.PHONY: build package clean

build:
	make -C .

package:
	make -C . package

clean:
	make -C . clean
