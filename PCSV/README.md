# Tema 1 laborator PCSV — mărimi pe termen scurt

Rezolvarea punctelor 1–7 din `Tema 1 Laborator .pdf`, folosind, conform cererii, aceleași înregistrări de test:

- `casa_male1.wav`, `casa_male2.wav`, `casa_female.wav` din `L1 - marimi pe termen scurt/`.

Platforma din acel director este un PDF scanat cu formulele de laborator; nu conține scripturi MATLAB preexistente. Implementarea urmează în special ecuațiile **(2.50), (2.52) și (2.76)**, paginile tipărite 26 și 31.

## Fișiere principale

- **`tema1_raport.pdf`**: rezolvarea cu formule, grafice și rezultate numerice pe WAV-urile de test.
- `documentatie/tema1_raport.md`: sursa textuală a raportului.
- **`run_tema1.m`**: calculează și exportă rezultatele în MATLAB.
- **`configuratie.json`**: fișierele audio, ferestrele și parametrii de analiză, într-un singur loc.
- `matlab/`: funcțiile pentru autocorelațiile 2 și 3, selecție, energie, export și verificări.
- `rezultate/referinta_python/`: rezultate deja calculate independent din WAV-urile reale, inclusiv PNG, PDF vectorial, CSV și indicii ferestrelor.
- `rezultate/matlab/`: apare la rularea codului MATLAB; nu conține exporturi pretinse înainte de rulare.

## Rulare MATLAB

Din directorul `PCSV`:

```matlab
run_tema1
```

Nu sunt necesare toolbox-uri suplimentare și nu se redă audio automat. Sunt produse:

- `semnal_energie.png/.pdf`: semnal, energie pe termen scurt și energie relativă în dB;
- `ferestre.png/.pdf`: ferestrele și comparațiile `r2/r2(0)` cu `r3/r3(0)`, cu maximele folosite la F0 marcate;
- `ferestre_f0.csv`: m, timp, întârzierile și frecvențele fundamentale;
- `autocorelatie_XX.csv`: valorile brute și normalizate pentru fiecare fereastră;
- `energie.csv`: energia și puterea la fiecare eșantion;
- `analiza.mat`: datele complete, ferestrele și rezultatele;
- `rezumat_f0.csv` și `rezumat.md`: sinteza tuturor fișierelor analizate.

Fiecare sunet are propriul subdirector, iar rularea repetată rescrie rezultatele aceleiași configurații.

## Înlocuirea cu sunetele proprii

1. Copiază înregistrările WAV în `PCSV/sunete_proprii/` sau într-un alt subdirector.
2. Editează numai `configuratie.json`: înlocuiește `cale` cu, de exemplu, `sunete_proprii/cuvant1.wav` și setează **`m_manual: []`** pentru fișierele noi. Poți adăuga sau șterge intrări în lista `fisiere`.
3. Rulează `run_tema1`. Lista goală declanșează selecția automată de cadre candidate sonore și cadre de control. Verifică vizual periodicitatea și pozițiile maximelor; selecția este euristică și poate alege armonici sau zgomot periodic.
4. Pentru alegere explicită, pune în `m_manual` indicii ultimului eșantion al fiecărei ferestre, **numărați de la zero**. Poți calcula `m = round(tFinal*Fs)`, cu `m < length(x)`. În MATLAB, fereastra este `x(m-N+2:m+1)`.

Pentru sunetele de test, `m_manual` este deja completat cu șase poziții pe fișier: patru ferestre periodice și două controale. Valorile fixe fac rezultatul reproductibil. Pentru alte înregistrări, acești indici trebuie înlocuiți sau goliți.

Codul păstrează frecvența originală și folosește `N = round(220*Fs/8000)`, adică aproximativ 27,5 ms. Nu schimbă artificial rata de eșantionare. Stereo este convertit în mono prin media canalelor; amplitudinile nu sunt normalizate individual și media semnalului nu este scăzută, pentru a păstra formulele platformei. Dacă ai nevoie de un alt domeniu F0, modifică `f0_min_Hz`/`f0_max_Hz`.

## Definiții și precauții de interpretare

`m` indică **sfârșitul** ferestrei, conform platformei. Pentru `lambda >= 0`:

```text
r2(lambda,m) = sum[x(n)*x(n-lambda), n=m-N+1+lambda:m] / (N-lambda)
r3(lambda,m) = sum[x(n)*x(n-lambda), n=m-N+1:m] / N
E(m)        = sum[x(n)^2, n=m-N+1:m]
P(m)        = E(m)/N
```

Varianta 3 citește și eșantioane anterioare ferestrei. Calcularea ambelor variante doar din cadrul decupat cu `xcorr` ar pierde această diferență. Eșantioanele anterioare începutului fișierului sunt considerate zero; ferestrele de test au întregul istoric disponibil pentru întârzierile afișate.

La 8 kHz se reprezintă `lambda = 0:218`; la alte Fs se adaptează până la `N-2`. F0 se estimează din primul maxim local suficient de clar din domeniul configurat, prin `Fs/lambda0`, excluzând maximul din origine. Nu se atribuie o F0 tăcerii sau unui cadru fără periodicitate suficientă. Normalizările finite pot depăși 1; nu sunt limitate artificial la intervalul [-1,1].

Energia este suma pătratelor amplitudinilor numerice, nu o măsurătoare în jouli. Primele N−1 valori ale curbei de energie implică extensia cu zerouri înainte de fișier. Durata unui cadru este N/Fs; distanța dintre momentele primului și ultimului eșantion este (N−1)/Fs.

## Verificare

```matlab
addpath('matlab')
verifica_tema1
```

Testele disting explicit r2 de r3 pe o secvență cu sume cunoscute, verifică energia, semnalul nul și un sinus de 100 Hz. La N=220, efectele de capăt pot deplasa cu un eșantion maximul variantei 3 chiar pe un sinus; la N=800 (zece perioade), ambele maxime sunt la lambda=80.

Analiza statică MATLAB a fișierelor implementate a trecut fără mesaje. Execuția MATLAB în mediul de pregătire este blocată de eroarea de procesor `neon`; rezultatele livrate sunt calculate separat în Python, direct pe aceleași WAV-uri. Nu sunt prezentate drept exporturi MATLAB. Verificările numerice independente și hash-urile surselor sunt păstrate în documentație și în directorul rezultatelor.

## Regenerarea rezultatelor de referință și a raportului

Python 3, ReportLab și fonturile Arial din macOS sunt suficiente. Nu sunt necesare NumPy sau SciPy. Implementarea Python acceptă WAV PCM16/PCM32; MATLAB `audioread` acceptă și alte variante WAV.

```sh
python3 -m pip install -r tools/requirements.txt
python3 tools/genereaza_rezultate.py
swift -disable-sandbox -module-cache-path /tmp/pcsv-swift-cache tools/exporta_png.swift
python3 tools/genereaza_raport.py
```

Pentru schimbările sunetelor proprii, `run_tema1` este punctul de intrare principal; raportul PDF livrat descrie configurația de test curentă. La regenerarea completă în Python, raportul folosește rezultatele și configurația nou generate.
