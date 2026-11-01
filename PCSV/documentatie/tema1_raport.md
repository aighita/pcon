# Tema 1 laborator PCSV

Autocorelațiile pe termen scurt, frecvența fundamentală și energia semnalului vocal

Rezolvarea folosește înregistrările selectate în configuratie.json: casa_male1.wav, casa_male2.wav, casa_female.wav. În configurația inițială sunt folosite cele trei sunete de test din platforma „L1 - marimi pe termen scurt”, conform cererii. Înregistrările proprii pot fi introduse ulterior prin același fișier de configurare. În directorul sursă au fost găsite platforma scanată și WAV-urile, fără rezolvări MATLAB preexistente.

## 1–2. Sunetele de test și reprezentarea în timp

| Fișier | Fs [Hz] | Eșantioane | Durată [s] | Canale | N |
| --- | --- | --- | --- | --- | --- |
| casa_male1.wav | 8000 | 106000 | 13.25 | 1 | 220 |
| casa_male2.wav | 8000 | 68000 | 8.50 | 1 | 220 |
| casa_female.wav | 8000 | 106000 | 13.25 | 1 | 220 |

Fișierele de test inițiale sunt WAV PCM pe 16 biți, mono, la 8000 Hz. Pentru configurația analizată, parametrii fiecărui fișier sunt cei din tabel. Stereo este convertit în mono prin media canalelor. Pentru fiecare fișier, axa timpului este t(n) = n/Fs, cu n pornind de la zero. Amplitudinea digitală este păstrată la scara citită; nu se aplică normalizări separate sau eliminarea mediei. Graficele semnalului complet și ale energiei sunt incluse în paginile dedicate fiecărui sunet.

Rezultatele numerice și figurile livrate au fost calculate direct din aceste WAV-uri prin implementarea independentă Python. Codul MATLAB implementează aceleași formule și exportă propriile rezultate la rulare. Analiza sa statică a trecut fără mesaje; executarea MATLAB în acest mediu a fost blocată înainte de teste de eroarea de procesor „neon”.

## 3. Alegerea ferestrei și convenția pentru m

N = round(220·Fs/8000). La 8 kHz rezultă N = 220 eșantioane, cu durata N/Fs = 27,5 ms. Conform platformei, m reprezintă ultimul eșantion al ferestrei, iar cadrul este x(n), n = m−N+1,…,m. Indicii matematici din raport pornesc de la zero; în MATLAB se extrage x(m−N+2:m+1).

Pozițiile m pentru cele șase ferestre ale fiecărui sunet sunt salvate explicit în configuratie.json: patru cadre cu periodicitate clară și două cadre de control. Istoricul anterior necesar variantei 3 este disponibil integral pentru toate întârzierile afișate. Durata N/Fs nu trebuie confundată cu distanța dintre momentele primului și ultimului eșantion, (N−1)/Fs = 27,375 ms.

## 4. Autocorelațiile: variantele 2 și 3

Pentru λ ≥ 0 și λ < N, conform ecuației (2.50), pagina tipărită 26 a platformei:

r2(λ,m) = [1/(N−λ)] · Σ x(n)·x(n−λ), pentru n = m−N+1+λ,…,m.

Varianta 2 folosește N−λ perechi, toate din fereastra aleasă, și compensează numărul de perechi prin împărțirea la N−λ. În vecinătatea lui λ = N, rămân foarte puține perechi, iar estimarea devine sensibilă la poziția ferestrei și la zgomot.

Conform ecuației (2.52), aceeași pagină:

r3(λ,m) = (1/N) · Σ x(n)·x(n−λ), pentru n = m−N+1,…,m.

Varianta 3 folosește N perechi pentru fiecare întârziere. Eșantioanele x(n−λ) pot fi dinaintea ferestrei. Prin urmare, nu este suficient să calculăm ambele variante numai din vectorul decupat cu xcorr. O schimbare de fonem sau de amplitudine în istoricul cadrului poate influența diferit varianta 3.

Pe același grafic se reprezintă r2(λ,m)/r2(0,m) și r3(λ,m)/r3(0,m), pentru λ = 0,…,218, exact ca domeniul cerut în platformă pentru N = 220. La alte Fs, domeniul este adaptat la 0,…,N−2. Pentru întârzieri negative se folosește |λ| în formule; tema este reprezentată pe semiaxa pozitivă.

În origine r2(0,m) = r3(0,m) = (1/N)·Σx(n)² = P(m). Pentru un cadru de energie nulă, normalizarea este nedefinită; codul întoarce NaN, fără împărțire la zero. Valorile normalizate ale acestor estimatori finiți pot depăși 1 și nu sunt limitate artificial. În cazul variantei 3, normalizarea prin energia cadrului curent nu este aceeași cu normalizarea prin rădăcina produsului energiilor celor două fragmente.

## 5–6. Determinarea frecvenței fundamentale

Maximul din λ = 0 nu este folosit pentru determinarea perioadei. Se identifică un maxim local clar la o întârziere pozitivă λ0, apoi T0 = λ0/Fs și F0 = Fs/λ0. Căutarea este restrânsă la 60–500 Hz, adică λ = 16,…,133 la Fs = 8000 Hz. Se alege primul maxim care depășește pragul 0,60 și 85% din cel mai mare maxim local din acest domeniu; pozițiile alese sunt marcate pe grafice.

Un control suplimentar de energie și coerență respinge cadrele fără periodicitate suficientă. Acest control nu modifică autocorelațiile desenate. Rezultatul rămâne o estimare: armonicile dominante, tranzițiile și cadrele foarte scurte pot produce erori de perioadă sau mici deplasări ale maximului. Se verifică vizual forma de undă și maximele; o componentă periodică nu dovedește singură identificarea unui anumit fonem.

Diferențele de un eșantion sunt posibile chiar la semnale ideale. În verificarea pe un sinus de 100 Hz cu N = 220, r3(80)/r3(0) = 1, dar maximul local poate fi la λ = 81 din cauza ferestrei finite. Pentru această realizare, la N = 800 ambele maxime sunt la λ = 80. Testul explică de ce nu trebuie forțate rezultate identice pentru cei doi estimatori.

## Rezultate — casa_male1.wav

Fs = 8000 Hz; N = 220; durata fișierului = 13.25 s. Energia maximă pe termen scurt este 0.505751 în unități numerice pătratice. Cele șase valori m sunt capetele ferestrelor, nu începuturile lor.

| m (de la 0) | t final [s] | λ2 | F0 v2 [Hz] | λ3 | F0 v3 [Hz] |
| --- | --- | --- | --- | --- | --- |
| 3397 | 0.424625 | 72 | 111.11 | 72 | 111.11 |
| 29397 | 3.674625 | 85 | 94.12 | 85 | 94.12 |
| 51957 | 6.494625 | — | — | — | — |
| 53397 | 6.674625 | 86 | 93.02 | 86 | 93.02 |
| 57477 | 7.184625 | 91 | 87.91 | 90 | 88.89 |
| 102437 | 12.804625 | — | — | — | — |

„—” înseamnă că nu se raportează o frecvență fundamentală pentru cadrul respectiv. Pentru cadrele periodice se folosesc maximele marcate în figura de pe pagina următoare.

![casa_male1: semnalul complet, energia cu fereastră alunecătoare și energia relativă în dB.](../rezultate/referinta_python/01_casa_male1/semnal_energie.png)

## casa_male1 — ferestre și autocorelații

![Stânga: cadrul analizat în albastru și istoricul în gri. Dreapta: r2/r2(0) în albastru și r3/r3(0) în portocaliu; punctele marchează întârzierile folosite la F0.](../rezultate/referinta_python/01_casa_male1/ferestre.png)

## Rezultate — casa_male2.wav

Fs = 8000 Hz; N = 220; durata fișierului = 8.50 s. Energia maximă pe termen scurt este 0.236377 în unități numerice pătratice. Cele șase valori m sunt capetele ferestrelor, nu începuturile lor.

| m (de la 0) | t final [s] | λ2 | F0 v2 [Hz] | λ3 | F0 v3 [Hz] |
| --- | --- | --- | --- | --- | --- |
| 9157 | 1.144625 | 60 | 133.33 | 60 | 133.33 |
| 20597 | 2.574625 | — | — | — | — |
| 23397 | 2.924625 | — | — | — | — |
| 31957 | 3.994625 | 72 | 111.11 | 72 | 111.11 |
| 37317 | 4.664625 | 68 | 117.65 | 68 | 117.65 |
| 57317 | 7.164625 | 81 | 98.77 | 81 | 98.77 |

„—” înseamnă că nu se raportează o frecvență fundamentală pentru cadrul respectiv. Pentru cadrele periodice se folosesc maximele marcate în figura de pe pagina următoare.

![casa_male2: semnalul complet, energia cu fereastră alunecătoare și energia relativă în dB.](../rezultate/referinta_python/02_casa_male2/semnal_energie.png)

## casa_male2 — ferestre și autocorelații

![Stânga: cadrul analizat în albastru și istoricul în gri. Dreapta: r2/r2(0) în albastru și r3/r3(0) în portocaliu; punctele marchează întârzierile folosite la F0.](../rezultate/referinta_python/02_casa_male2/ferestre.png)

## Rezultate — casa_female.wav

Fs = 8000 Hz; N = 220; durata fișierului = 13.25 s. Energia maximă pe termen scurt este 0.357303 în unități numerice pătratice. Cele șase valori m sunt capetele ferestrelor, nu începuturile lor.

| m (de la 0) | t final [s] | λ2 | F0 v2 [Hz] | λ3 | F0 v3 [Hz] |
| --- | --- | --- | --- | --- | --- |
| 13957 | 1.744625 | — | — | — | — |
| 17237 | 2.154625 | 35 | 228.57 | 35 | 228.57 |
| 18437 | 2.304625 | — | — | — | — |
| 47637 | 5.954625 | 45 | 177.78 | 45 | 177.78 |
| 69077 | 8.634625 | 36 | 222.22 | 36 | 222.22 |
| 96437 | 12.054625 | 43 | 186.05 | 43 | 186.05 |

„—” înseamnă că nu se raportează o frecvență fundamentală pentru cadrul respectiv. Pentru cadrele periodice se folosesc maximele marcate în figura de pe pagina următoare.

![casa_female: semnalul complet, energia cu fereastră alunecătoare și energia relativă în dB.](../rezultate/referinta_python/03_casa_female/semnal_energie.png)

## casa_female — ferestre și autocorelații

![Stânga: cadrul analizat în albastru și istoricul în gri. Dreapta: r2/r2(0) în albastru și r3/r3(0) în portocaliu; punctele marchează întârzierile folosite la F0.](../rezultate/referinta_python/03_casa_female/ferestre.png)

## 7. Energia pe termen scurt

Conform ecuațiilor (2.75) și (2.76), pagina tipărită 31 a platformei: E(m) = Σx(n)², pentru n = m−N+1,…,m, iar P(m) = E(m)/N. În MATLAB, curba completă se obține prin filter(ones(N,1),1,x.^2), cu pas de un eșantion. Este o sumă cauzală pe o fereastră dreptunghiulară; nu se folosește o fereastră Hann sau Hamming, care ar modifica definiția cerută.

La începutul fișierului, eșantioanele anterioare sunt considerate zero, astfel încât primele N−1 valori includ ferestre parțial umplute. Pentru cadrele analizate acest efect inițial nu intervine. Relația E(m) = N·r2(0,m) = N·r3(0,m) este verificată numeric pe toate ferestrele selectate.

Vârfurile energiei corespund regiunilor cu amplitudini mai mari; pauzele au energie mică. Energia singură nu dovedește sonoritatea sau periodicitatea unui fonem: o consoană neperiodică poate avea energie semnificativă. Din acest motiv analiza energiei este corelată cu forma de undă și autocorelația. Valorile sunt în unitățile pătratice ale amplitudinii digitale, nu în jouli și nu în dB SPL.

A treia reprezentare a fiecărui fișier folosește 10·log10[E(m)/Emax], cu Emax calculat separat pentru acel fișier. Este o reprezentare relativă pentru evidențierea pauzelor; nu reprezintă calibrarea acustică a înregistrărilor.

## Sinteza frecvențelor estimate

| Înregistrare | Cadre periodice | Interval F0 v2 [Hz] | Interval F0 v3 [Hz] |
| --- | --- | --- | --- |
| casa_male1 | 4 | 87.91–111.11 | 88.89–111.11 |
| casa_male2 | 4 | 98.77–133.33 | 98.77–133.33 |
| casa_female | 4 | 177.78–228.57 | 177.78–228.57 |

Intervalele descriu numai ferestrele selectate, nu toate valorile F0 din întreaga înregistrare. Ele nu sunt o estimare a vitezei de rostire a cuvântului. Durata cuvântului și frecvența vibrației cvasi-periodice a vocii sunt proprietăți diferite.

Exemplu de diferență între variante: casa_male1.wav, m = 57477. λ2 = 91 conduce la F0 = 87.91 Hz, iar λ3 = 90 conduce la F0 = 88.89 Hz. Diferența provine din poziția maximului pentru cele două definiții și din rezoluția de un eșantion; nu este corectată artificial.

## Reproducere și înlocuirea sunetelor

Se rulează run_tema1 din directorul PCSV. Fișierele și valorile m se schimbă numai în configuratie.json. Pentru înregistrări proprii se înlocuiește calea WAV și se golește lista m_manual, sau se introduc capete de ferestre potrivite noii înregistrări. N se adaptează automat proporțional cu Fs. Rezultatele MATLAB sunt salvate separat de referința Python, astfel încât sursa fiecărui rezultat rămâne clară.

Nu este necesară reeșantionarea la 8 kHz. O eventuală schimbare reală a frecvenței de eșantionare trebuie făcută prin reeșantionare cu filtrare, nu prin înlocuirea etichetei Fs, care ar modifica înălțimea sunetului și toate estimările F0.

## Verificare și surse

Verificări independente: sume directe pe o secvență numerică, diferența r2/r3 prin istoricul exterior cadrului, sinus de 100 Hz, energie prin sumă directă și consistența indicilor pe toate cele 18 ferestre reale. Analiza statică MATLAB și rezultatele verificărilor sunt în documentatie/. Valorile complete ale autocorelațiilor și energiei sunt disponibile în CSV, alături de graficele PNG și PDF vectorial.

Surse: „Tema 1 Laborator .pdf”, punctele 1–7; „1. Marimi pe termen scurt - Laborator.pdf”, secțiunea 2.3, ecuațiile (2.50) și (2.52), pagina tipărită 26 (pagina 7 a PDF-ului scanat), și secțiunea 2.9, ecuațiile (2.75)–(2.76), pagina tipărită 31 (pagina 9 a PDF-ului scanat). WAV-urile originale sunt cele din același director; hash-urile SHA-256 sunt păstrate împreună cu rezultatele.
