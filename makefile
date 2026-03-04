# $Id: makefile 243 2024-04-06 10:34:40Z rishi $

file=sample
tmpdir=/tmp/$(shell basename "$(CURDIR)")/$(file)
required_sty=fontawesome5
sty_packages=$(if $(STY),$(STY),$(required_sty))

all: pdf out 
	make pdf
	make pdf

out:
	if  [ -f $(file).out ] ; then cp $(file).out tmp.out; fi ;
	sed 's/BOOKMARK/dtxmark/g;' tmp.out > x.out; mv x.out tmp.out ;

pdf: ensure-sty
	mkdir -p "$(tmpdir)/"
	pdflatex -output-directory="$(tmpdir)/" $(file).tex
	cp "$(tmpdir)/$(file).pdf" .

ensure-sty:
	@missing=""; \
	for sty in $(required_sty); do \
		if ! kpsewhich "$$sty.sty" >/dev/null 2>&1; then \
			missing="$$missing $$sty"; \
		fi; \
	done; \
	if [ -n "$$missing" ]; then \
		echo "Missing style package(s):$$missing"; \
		echo "Running: make install-sty STY=\"$$missing\""; \
		$(MAKE) install-sty STY="$$missing"; \
	fi

install-sty:
	@for pkg in $(sty_packages); do \
		if kpsewhich "$$pkg.sty" >/dev/null 2>&1; then \
			echo "$$pkg.sty already available."; \
		elif command -v tlmgr >/dev/null 2>&1; then \
			echo "Installing $$pkg via tlmgr (user mode)..."; \
			tlmgr --usermode install "$$pkg" >/dev/null 2>&1 || { \
				tlmgr init-usertree >/dev/null 2>&1 || true; \
				tlmgr --usermode install "$$pkg" || { \
					echo "tlmgr user mode failed for $$pkg."; \
					echo "On Debian/Ubuntu try: sudo apt install texlive-fonts-extra"; \
					exit 1; \
				}; \
			}; \
		elif command -v apt-get >/dev/null 2>&1; then \
			echo "tlmgr not available. Install required TeX packages with apt."; \
			echo "Try: sudo apt install texlive-fonts-extra"; \
			exit 1; \
		else \
			echo "No supported package manager found for $$pkg."; \
			echo "Install $$pkg manually via your TeX distribution."; \
			exit 1; \
		fi; \
	done

index:
	makeindex -s gind.ist -o $(file).ind $(file).idx 

changes:
	makeindex -s gglo.ist -o $(file).gls $(file).glo

xview:
#	xpdf -z 200 $(file).pdf &>/dev/null
	open -a 'Skim.app' $(file).pdf 

view:
	open -a 'Adobe Reader.app' $(file).pdf

ins:
	latex elsarticle.ins 

diff:
	diff $(file).sty ../$(file).sty |less

copy:
	cp $(file).sty ../
