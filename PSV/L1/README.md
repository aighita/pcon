# Laborator 1 PCSV / PSV

Rezolvările exercițiilor 1–7 și demonstrația **Flash-lag** de la exercițiul 7.

- `laborator.pages`: raport editabil în format Pages nativ, cu explicații și trimiteri la figuri.
- `laborator.pdf`: versiune pentru citire, cu figurile de referință încorporate.
- `run_laborator.m`: punctul de pornire pentru MATLAB.
- `matlab/`: funcții separate pe exerciții și funcții comune.
- `test_images/`: cele trei imagini originale din laborator.
- `rezultate/`: destinația exporturilor produse la execuția MATLAB.
- `documentatie/laborator.md`: sursa textuală a raportului.
- `documentatie/figuri/`: figuri de referință calculate independent în Python și previzualizare GIF.
- `documentatie/sablon_initial.pages`: copia documentului inițial, păstrată pentru regenerare.
- `tools/`: generarea documentelor, a figurilor și verificarea structurii Pages.

## MATLAB

Este necesar MATLAB modern (codul a fost analizat cu R2026a), cu **Image Processing Toolbox** și **Signal Processing Toolbox** pentru întregul laborator. Animația Flash-lag și verificările matematice folosesc numai MATLAB de bază.

Din directorul `PSV`:

```matlab
run_laborator(false)       % ex. 1–6; CSF ilustrativă, fără interacțiune
addpath('matlab')
verifica_laborator         % verificări matematice fără ferestre
ex07_flash_lag             % animație de 12 secunde nominal
```

Pentru măsurarea sensibilității la contrast, introduceți lățimea fizică a stimulului afișat și distanța de observare, în centimetri:

```matlab
ex02_contrast(true, 40, 60) % înlocuiți 40 și 60 cu geometria reală
ex05_adaptare(true)        % fixare 20 s, apoi mutarea privirii
ex07_flash_lag('FPS',60,'Cycles',6,'Speed',6,'Direction',-1)
```

`run_laborator(true)` parcurge întregul laborator cu interacțiune, folosind implicit geometria CSF 40 cm / 60 cm. La măsurare se preferă apelul separat cu geometria reală. La CSF: minimum șase puncte distincte ale anvelopei vizibile, apoi Enter.

În animație: **SPACE** pauză, **C** control static aliniat, **ESC** închidere. La debutul fiecărui flash, coordonatele orizontale sunt identice prin construcție. Flash-ul durează un cadru nominal. Jurnalul `ex07_cadre.csv` înregistrează timpi software; grafica MATLAB standard nu garantează prezentare sincronizată cu refresh-ul monitorului.

`ex1.m` rămâne un punct de intrare compatibil pentru primul exercițiu. Funcțiile își determină căile pornind de la propria locație.

## Verificări efectuate și limite

Analiza statică `mlint -id` pentru toate cele 15 fișiere `.m` a trecut fără mesaje. MATLAB R2026a nu a putut porni în mediul de lucru: `Incompatible processor. This Qt build requires ... neon`. Execuția completă MATLAB și testul `verifica_laborator` trebuie rulate pe un sistem funcțional; nu sunt raportate ca trecute aici.

Calculul independent Python a verificat limitele contrastului, monotonia frecvenței, transpunerea MTF la rotație, răspunsurile Gabor și alinierea Flash-lag în 1440 de cadre calculate. Rezultatele sunt în `documentatie/verificare_independenta.json`. Figurile Python nu sunt exporturi MATLAB; generatorul de zgomot și unele implementări de filtrare diferă.

Curba CSF automată este **ilustrativă**. Nu sunt declarate măsurători perceptuale ale unui observator. Pragurile reale se obțin interactiv, în condiții de vizualizare controlate.

Arhiva Pages nativă a fost actualizată pornind de la șablonul existent, păstrând stilurile acestuia. S-au verificat integritatea ZIP, mesajele IWA, textul integral și pozițiile stilurilor. Deschiderea și repaginarea în aplicația Pages nu au putut fi verificate în acest mediu. PDF-ul suplimentar a fost verificat prin extragerea textului și inspecție vizuală.

## Regenerarea documentelor

Python 3 și dependențele din `tools/requirements.txt` sunt necesare numai pentru figurile/PDF-ul suplimentar. Fișierul Pages poate fi regenerat cu biblioteca standard Python.

```sh
python3 -m pip install -r tools/requirements.txt
python3 tools/genereaza_figuri.py
python3 tools/genereaza_pdf.py
# Pe macOS, actualizează miniaturile raportului:
swift -disable-sandbox -module-cache-path /tmp/pcsv-swift-cache tools/previzualizare_pdf.swift
python3 tools/actualizeaza_pages.py
python3 tools/actualizeaza_pages.py --verify
```

Generatoarele de figuri/PDF folosesc fontul Arial din macOS. Pentru alt sistem, adaptați calea fontului. Actualizarea Pages citește `documentatie/sablon_initial.pages` și `documentatie/laborator.md`, apoi rescrie `laborator.pages`.
