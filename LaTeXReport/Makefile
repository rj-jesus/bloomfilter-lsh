
all: report.pdf

report.pdf: report.tex report.bib
	pdflatex -shell-escape report.tex
	biber report
	pdflatex -shell-escape report.tex
	pdflatex -shell-escape report.tex

clean:
	rm -f *.aux *.blg *.bbl *.toc *.log *.lof *.lot *.log.xml *.bcf *.out *.run.xml
