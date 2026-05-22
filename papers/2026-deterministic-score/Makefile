.PHONY: paper clean validate

paper:
	pdflatex main.tex
	bibtex main
	pdflatex main.tex
	pdflatex main.tex

validate:
	python3 validation/check_claims.py claims.yaml
	python3 validation/check_no_forbidden_claims.py main.tex

clean:
	rm -f main.aux main.bbl main.blg main.log main.out main.pdf main.vtc main.toc
