.PHONY: all clean ttf web pack check

NAME=Amiri
LATIN=AmiriLatin
VERSION=0.112

TOOLS=tools
SRC=sources
DOC=documentation
TESTS=test-suite
FONTS=$(NAME)-Regular $(NAME)-Bold $(NAME)-Slanted $(NAME)-BoldSlanted $(NAME)Quran $(NAME)QuranColored
DIST=$(NAME)-$(VERSION)
CDIST=$(NAME)-$(VERSION)-CTAN

BUILD=$(TOOLS)/build.py
MAKECLR=$(TOOLS)/makeclr.py
PY ?= python
FF=$(PY) $(BUILD)

SFDS=$(FONTS:%=$(SRC)/%.sfdir)
DTTF=$(FONTS:%=%.ttf)
DOTF=$(FONTS:%=%.otf)
PDFS=$(DOC)/Documentation-Arabic.pdf
FEAT=$(wildcard $(SRC)/*.fea)
TEST=$(wildcard $(TESTS)/*.test)
TEST+=$(wildcard $(TESTS)/*.ptest)

export SOURCE_DATE_EPOCH ?= 0

all: ttf web

ttf: $(DTTF)
otf: $(DOTF)
doc: $(PDFS)

$(NAME)Quran.ttf $(NAME)Quran.otf: $(SRC)/$(NAME)-Regular.sfdir $(SRC)/latin/$(LATIN)-Regular.sfd $(SRC)/$(NAME).fea $(FEAT) $(BUILD)
	@echo "   FF	$@"
	@$(FF) --input $< --output $@ --features=$(SRC)/$(NAME).fea --version $(VERSION) --quran

$(NAME)QuranColored.ttf: $(NAME)Quran.ttf $(MAKECLR)
	@echo "   FF	$@"
	@$(PY) $(MAKECLR) $< $@

$(NAME)QuranColored.otf: $(NAME)Quran.otf $(MAKECLR)
	@echo "   FF	$@"
	@$(PY) $(MAKECLR) $< $@

$(NAME)-Regular.ttf $(NAME)-Regular.otf: $(SRC)/$(NAME)-Regular.sfdir $(SRC)/latin/$(LATIN)-Regular.sfd $(SRC)/$(NAME).fea $(FEAT) $(BUILD)
	@echo "   FF	$@"
	@$(FF) --input $< --output $@ --features=$(SRC)/$(NAME).fea --version $(VERSION)

$(NAME)-Slanted.ttf $(NAME)-Slanted.otf: $(SRC)/$(NAME)-Regular.sfdir $(SRC)/latin/$(LATIN)-Slanted.sfd $(SRC)/$(NAME).fea $(FEAT) $(BUILD)
	@echo "   FF	$@"
	@$(FF) --input $< --output $@ --features=$(SRC)/$(NAME).fea --version $(VERSION) --slant=10

$(NAME)-Bold.ttf $(NAME)-Bold.otf: $(SRC)/$(NAME)-Bold.sfdir $(SRC)/latin/$(LATIN)-Bold.sfd $(SRC)/$(NAME).fea $(FEAT) $(BUILD)
	@echo "   FF	$@"
	@$(FF) --input $< --output $@ --features=$(SRC)/$(NAME).fea --version $(VERSION)

$(NAME)-BoldSlanted.ttf $(NAME)-BoldSlanted.otf: $(SRC)/$(NAME)-Bold.sfdir $(SRC)/latin/$(LATIN)-BoldSlanted.sfd $(SRC)/$(NAME).fea $(FEAT) $(BUILD)
	@echo "   FF	$@"
	@$(FF) --input $< --output $@ --features=$(SRC)/$(NAME).fea --version $(VERSION) --slant=10

$(DOC)/Documentation-Arabic.pdf: $(DOC)/Documentation-Arabic.tex $(DTTF)
	@echo "   GEN	$@"
	@latexmk --norc --xelatex --quiet --output-directory=${DOC} $<

check: $(DTTF)
	@echo "running tests"
	@$(foreach font,$(DTTF),echo "   OTS	$(font)" && python -m ots --quiet $(font) &&) true

clean:
	rm -rfv $(DTTF) $(PDFS) $(SRC)/$(NAME)*.fea.pp
	rm -rfv $(DOC)/documentation-arabic.{aux,log,toc}

distclean: clean
	rm -rf {$(DIST),$(CDIST)}{,.zip}

dist: all check pack doc
	@rm -rf $(DIST) $(CDIST)
	@mkdir -p $(DIST) $(CDIST)
	@cp OFL.txt $(DIST)
	@cp OFL.txt $(CDIST)
	@cp $(DTTF) $(DIST)
	@cp $(DTTF) $(CDIST)
	@cp README.md $(DIST)/README
	@cp README.md $(CDIST)/README
	@cp README-Arabic.md $(DIST)/README-Arabic
	@cp README-Arabic.md $(CDIST)/README-Arabic
	@cp NEWS.md $(DIST)/NEWS
	@cp NEWS.md $(CDIST)/NEWS
	@cp NEWS-Arabic.md $(DIST)/NEWS-Arabic
	@cp NEWS-Arabic.md $(CDIST)/NEWS-Arabic
	@cp $(NAME).fontspec $(CDIST)
	@cp $(PDFS) $(DIST)
	@cp $(PDFS) $(CDIST)
	@echo "   ZIP  $(DIST)"
	@zip -rq $(DIST).zip $(DIST)
	@echo "   ZIP  $(CDIST)"
	@zip -rq $(CDIST).zip $(CDIST)
