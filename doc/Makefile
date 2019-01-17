vpath %.bib /home/ajs1/bibtex/bib

preview: manual.pdf force
	evince $< &

manual.pdf: manual.tex manual.bbl pictures/point-charge-models.pdf ${FRC}
	pdflatex manual

manual.bbl: manual.aux
	bibtex manual


manual.ps: manual.tex ${FRC}
	make -f ~/tex/Makefiles/Makefile.normal NAME=manual BIB=~/tex/bibtex/bib/all.bib ${FRC}

force:

