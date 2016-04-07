PACKAGES=
# I don't understand warning 18
OCAML_WARNING=+a-4-9-18-41-30-42-44-40
OCAML_WARN_ERROR=+5+10+8+12+20+11
OPTIONS=-no-sanitize -no-links -tag debug -use-ocamlfind	\
-cflags -w,$(OCAML_WARNING) -cflags				\
-warn-error,$(OCAML_WARN_ERROR) -cflag -bin-annot -j 8 -tag thread		\
 -tag principal
#OPTIONS += -cflags -warn-error,+a
DIRECTORIES=src
OCAMLBUILD=ocamlbuild \
		 $(addprefix -package ,$(PACKAGES)) \
		 $(OPTIONS)	\
		 $(addprefix -I ,$(DIRECTORIES)) \

.PHONY: tests

BINARY=sort

TOCOMPILE= $(addprefix src/, $(addsuffix .native,$(BINARY)))

all: compile

include .config

compile: .merlin
	@rm -rf bin/ lib/ bin-test/
	$(OCAMLBUILD) $(TOCOMPILE)
	@mkdir -p bin/
	@cp $(addprefix _build/,$(addprefix src/, $(addsuffix .native, $(BINARY)))) \
	    bin

install:
	@mkdir -p $(BINDIR)
	install bin/sort.native $(BINDIR)/oci-sort

uninstall:
	rm -f $(BINDIR)/oci-sort

clean:
	$(OCAMLBUILD) -clean

.merlin: Makefile
	@echo "Generating Merlin file"
	@rm -f .merlin.tmp
	@for PKG in $(PACKAGES); do echo PKG $$PKG >> .merlin.tmp; done
	@for SRC in $(DIRECTORIES); do echo S $$SRC >> .merlin.tmp; done
	@for SRC in $(DIRECTORIES); do echo B _build/$$SRC >> .merlin.tmp; done
	@echo FLG -w $(OCAML_WARNING) >> .merlin.tmp
	@echo FLG -w $(OCAML_WARN_ERROR) >> .merlin.tmp
	@mv .merlin.tmp .merlin

tests: compile
	DEBUG_OCI_SORT=yes bin/sort.native tests/simple_example.sort

.PHONY: headers

define make-header
git ls-files | xargs git check-attr $1 | sed -n -e "s/^\([^:]*\): $1: set/\1/p" \
| xargs headache -c licences/headache_config.txt -h licences/$2
endef
headers:
	$(call make-header,header-cea,CEA_LGPL)
	$(call make-header,header-why3,WHY3_LGPL)

.config: config.status
	./config.status --file .config

config.status: configure
	./config.status --recheck

GIT_TARNAME = oci-$(VERSION)
archive:
	git archive --format=tar --prefix=$(GIT_TARNAME)/ -o $(GIT_TARNAME).tar HEAD^{tree}
	@rm -rf $(GIT_TARNAME)
	@mkdir -p $(GIT_TARNAME)
	cp configure $(GIT_TARNAME)/
	tar rf $(GIT_TARNAME).tar $(GIT_TARNAME)/configure
	@rm -r $(GIT_TARNAME)
	gzip -f -9 $(GIT_TARNAME).tar
