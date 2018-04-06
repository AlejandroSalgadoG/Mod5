entrega1.pdf:  entrega1.tex entrega1.bib
	pdflatex entrega1.tex
	bibtex entrega1
	pdflatex entrega1.tex
	pdflatex entrega1.tex
	pdflatex entrega1.tex

clean:
	rm -f entrega1.pdf
	rm -f *.bst *.nav *.snm *.toc *.out *.dvi *.blg *.bbl *.aux *.log

exe:
	evince entrega1.pdf &
