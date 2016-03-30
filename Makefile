KONTO1 = 1
KONTO2 = 2

all: mov build graph 

mov:
	@mv ~/Downloads/PB_Umsatzauskunft_KtoNr${KONTO1}*.csv  db/ || true
	@mv ~/Downloads/PB_Umsatzauskunft_KtoNr${KONTO2}*.csv dbSCard/ || true
	
build:
	@ruby akkumulation_csv.rb
	@ruby akkumulation_csv.rb -i 'dbSCard/*csv' -o kontoumsatz_spar.csv

graph:
	R --no-save < graph.r 
	evince konto.pdf
