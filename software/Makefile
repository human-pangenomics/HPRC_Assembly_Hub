ROOT = .
include ${ROOT}/defs.mk

pyprogs = $(shell file -F $$'\t' bin/* | awk '/Python script/{print $$1}')


all:
	@echo "make lint - run flake8 on python code" >&2
	@echo "make test - run tests" >&2
	@echo "make clean - cleanup" >&2
	@exit 1

lint:
	${FLAKE8} --color=never ${pyprogs}

test:
	cd tests && ${MAKE} test

clean:
	cd tests && ${MAKE} clean
	rm -rf ${BINDIR}/__pycache__
