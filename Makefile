.ONESHELL:
.DEFAULT_GOAL := all

all: writeup.pdf

TEX_SOURCES := $(wildcard *.tex) data.tex .diagrams_crop

%.pdf:%.tex $(TEX_SOURCES)
	latexmk -shell-escape -lualatex $<

IPYNB_SOURCES := $(wildcard data/*.ipynb)
PYTHON_SOURCES := $(wildcard data/*.py)

data.tex: $(PYTHON_SOURCES) $(IPYNB_SOURCES)
	cd data
	$(foreach py,$(PYTHON_SOURCES),$(call python $(py)))
	$(foreach nb,$(IPYNB_SOURCES),$(call jupyter nbconvert --to notebook --execute $(nb)))
	cd ..
	ls data/*.tex | parallel echo '\\input{{}}' > $@

DIAGRAM_SOURCES := $(wildcard diagrams/*.pdf)

.diagrams_crop: $(DIAGRAM_SOURCES)
# $(foreach dia,$(basename $(DIAGRAM_SOURCES)),$(call pdfcrop $(dia).pdf cropped/$(dia).pdf))
	echo "$(DIAGRAM_SOURCES)" | tr ' ' '\n' | parallel -n 1 "pdfcrop {} diagrams/cropped/{/}"
# $(foreach dia,$(basename $(DIAGRAM_SOURCES)),$(call echo $(dia);))
	touch $@
