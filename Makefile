entrega1.pdf:  entrega1.tex
	pdflatex entrega1.tex

clean:
	rm -f entrega1.pdf
	rm -f *.nav *.snm *.toc *.out *.dvi *.blg *.bbl *.aux *.log

exe:
	evince entrega1.pdf &