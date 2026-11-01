# PSS — determinarea unei curbe de egală tărie

**Sunt necesare audițiile participantului.** Nu există încă măsurători personale în acest director și nu este furnizat un grafic fictiv drept rezultat experimental.

## Rulare în MATLAB

Deschideți directorul `PSS`, apoi:

```matlab
run_experiment
```

1. Completați echipamentul și condițiile de audiție. Alegeți o referință confortabilă și păstrați volumul sistemului și referința fixe.
2. Faceți câteva comparații de acomodare fără memorare.
3. Pentru fiecare frecvență, modificați nivelul testului până când testul și referința par **la fel de tari**, apoi apăsați Memorare. Butonul **T + R** redă **test 500 ms → pauză 200 ms → referință 500 ms**.
4. Faceți minimum **trei ajustări** la fiecare dintre cele nouă frecvențe. Nivelul de pornire este deplasat automat după fiecare memorare. Un nivel nou trebuie audiat înainte de memorare.
5. Fără să închideți audiometrul, rulați:

```matlab
finalizeaza_experiment
```

Descrieți acomodarea și dificultățile efective în dialogul final. Se generează în `rezultate/sesiune_.../referinta_.../`:

- **`curba_izofona.png`** — graficul de atașat;
- **`raport_experiment.pdf`** — documentul explicativ de atașat;
- grafic PDF vectorial, raport HTML/Markdown, date brute și medii/SD în CSV.

Salvarea datelor și a graficului se face după fiecare memorare. Raportul este generat la finalizare. Datele sunt separate pe nivel de referință, iar sesiunile au directoare distincte. Pentru pauză, păstrați fereastra deschisă. Dacă este închisă accidental, măsurătorile deja exportate rămân în CSV și MAT; comanda de pornire creează o sesiune nouă, fără reluare automată.

Nivelul selectat implicit este 30 **pe scala programului**, nu o măsurătoare de 30 foni. Fără calibrare acustică, graficul folosește niveluri relative/necalibrate SPL. Nu forțați prin creșterea volumului compararea unui ton greu perceptibil; omiteți-l și notați motivul.

## Supliment opțional: metoda scării

După ajustare, cu audiometrul deschis și **aceeași referință și același volum**:

```matlab
run_scara
```

Răspundeți în Command Window cu `t` (test mai tare), `r` (referință mai tare), `p` (reascultare), `s` (omiterea frecvenței), `q` (încheiere). Algoritmul folosește pași de 8, 4, 2 dB și media a șase întoarceri la pasul fin. Exportă separat încercările, estimările, un grafic comparativ și raportul suplimentar Markdown. Punctele care nu au convergent complet rămân lipsă.

## Organizare

- PDF-ul laboratorului și resursele `.m`/`.fig` rămân în rădăcina `PSS`.
- `audiometru.m` este adaptat; `amplgen.m`, `singen.m`, `tone.m` și fișierele `.fig` sunt păstrate.
- `resurse_originale/` păstrează copiile inițiale ale celor două interfețe MATLAB.
- `matlab/` conține generarea cu rampe, statistica, exportul, raportarea și verificările.
- `documentatie/` conține protocolul, rezolvările teoretice și o fișă necompletată de măsurare.
- `rezultate/` primește exclusiv datele și artefactele generate la rularea experimentului.

Pentru metoda opțională se recomandă `run_scara`, nu interfața veche `CurbeDeEgalaTarie`, care are o neconcordanță între numele funcției și fișier și poate genera niveluri digitale peste limita unitară. Protocolul explică aceste probleme.

## Verificări și limite

```matlab
addpath('matlab')
verifica_izofona    % fără redare audio, fără rezultate experimentale fictive
```

Este folosit numai MATLAB de bază; nu sunt necesare toolbox-uri suplimentare pentru statistică sau PDF. Codul se bazează pe `exportgraphics`, inclusiv export PDF cu Append. Funcția `gui_mainfcn` folosită de interfața furnizată există în instalarea locală R2026a.

Rularea MATLAB din mediul de pregătire a eșuat înainte de executarea verificărilor, cu eroarea de procesor `neon`. Verificarea statică este documentată separat; nu reprezintă o validare a redării audio sau a judecăților ascultătorului. Protocolul este disponibil ca PDF și Markdown în `documentatie/`.
