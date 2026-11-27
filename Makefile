ga:
	@chmod +x ga ga-load

.PHONY: clean check init ga

clean:
	rm -rf compiled/
	rm -rf test-out

check:
	racket tests/test-compiler.rkt
	racket tests/tests.rkt
