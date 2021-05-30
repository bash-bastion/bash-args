sync:
	../glue/glue.sh sync

build: sync
	../glue/glue.sh cmd build

docs: sync
	../glue/glue.sh cmd docs

lint: sync
	../glue/glue.sh cmd lint

release: sync
	../glue/glue.sh cmd release

releaseDry: sync build
	../glue/glue.sh cmd releaseDry

run: sync
	../glue/glue.sh cmd run

test: sync
	../glue/glue.sh cmd test
