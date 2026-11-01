# Laborator 1 — Percepția stimulilor vizuali

Rezolvări și implementări MATLAB • PCSV / PSV • 2026

## Obiectiv și organizare

Lucrarea studiază filtrarea spațială, sensibilitatea la contrast, mascarea, interacțiunile dintre stimuli, adaptarea și selectivitatea celulelor simple. La exercițiul 7 este ales efectul Flash-lag, implementat ca experiment vizual animat. Cerințele sunt cele din „Laborator 1 PCSV_2026.pdf”, paginile 1–10.

Codul se află în matlab/, imaginile originale în test_images/, iar rezultatele exportate de MATLAB în rezultate/. Punctul comun de pornire este run_laborator.m. Raportul editabil este laborator.pages; sursa sa textuală este documentatie/laborator.md. Documentul PDF suplimentar include figurile de referință din documentatie/figuri/. Aceste figuri sunt calculate separat în Python pentru ilustrarea rezolvărilor; nu sunt capturi ale unei execuții MATLAB.

Verificare în acest mediu: pornirea MATLAB R2026a a eșuat înainte de executarea codului, cu mesajul „Incompatible processor … neon”. Prin urmare, raportul nu pretinde o execuție MATLAB finalizată. Analiza statică a tuturor fișierelor .m cu analizorul MATLAB mlint a trecut fără mesaje. Valorile numerice Gabor și geometria Flash-lag sunt verificate independent în Python. Măsurarea CSF și observarea iluziilor necesită participarea efectivă a unui observator; nu sunt inventate rezultate perceptuale.

## 1. Unghiul de vizualizare și filtrarea spațială

Pentru un stimul de lățime W privit de la distanța D, unghiul total este α = 2·atan(W/(2D))·180/π. Dacă stimulul conține n perioade, frecvența medie este n/α cicluri/grad (cpd). Frecvența în cicluri/pixel se înmulțește cu numărul de pixeli pe grad pentru a obține cpd; dimensiunea în pixeli nu fixează singură unghiul vizual. La W = 40 cm și D = 60 cm rezultă α ≈ 36,87°; șapte perioade ocupând această lățime corespund aproximativ la 0,190 cpd.

Implementare: ex01_filtrare.m citește buildings_original.bmp și parrots.bmp, le convertește în tonuri de gri și aplică un filtru gaussian 13×13, σ = 0,8 pixeli, un Laplacian pentru contururi și imsharpen cu Radius = 1, Amount = 1. Filtrarea folosește extensie simetrică la margini pentru a evita conturul artificial produs de completarea cu zerouri. Conversia im2double previne aritmetica saturată a datelor uint8.

Filtrul gaussian este trece-jos: atenuează variațiile rapide, netezește textura și păstrează predominant formele mari. În buildings_original sunt afectate țiglele acoperișurilor, ochiurile ferestrelor, inscripțiile și ramurile fine din fundal. În parrots se estompează nervurile penelor și liniile subțiri din jurul ochilor, în timp ce siluetele celor doi papagali rămân ușor de recunoscut.

Laplacianul este trece-sus: regiunile uniforme dau răspuns apropiat de zero, iar tranzițiile de intensitate produc lobi de semne opuse. La clădiri evidențiază ramele ferestrelor și muchiile grinzilor; la papagali evidențiază conturul ciocurilor și delimitările penajului. Imaginea Laplacianului se afișează pe o scală proprie, deoarece răspunsul este semnat. Aceasta nu reprezintă luminanța fizică a scenei.

imsharpen combină imaginea cu o componentă de detaliu extrasă prin netezire, aproximativ Iclar = I + k·(I − Gσ*I). Ferestrele și penele devin mai pregnante. Operația amplifică și zgomotul și poate produce halouri sau saturație la muchii; nu recuperează informație eliminată complet anterior. Originalul, filtrarea gaussiană și imaginea clarificată sunt afișate pe aceeași scară [0,1].

Figuri de referință: documentatie/figuri/ex01_buildings.png și ex01_parrots.png. Exporturile MATLAB sunt ex01_buildings_original.png și ex01_parrots.png în rezultate/.

## 2. Sensibilitatea la lumină și la contrast

Funcția fSin2(fm,fn) returnează S(y,x) = sin[2π·(fm·y + fn·x)/128], cu x,y = 0,…,127. Pasul de eșantionare este un pixel; fm și fn reprezintă numărul de cicluri pe înălțimea, respectiv lățimea imaginii. Frecvențele pe axe trebuie să rămână strict sub 64 cicluri/imagine în modul pentru a evita aliasingul. Pentru afișare se folosește I = 0,5 + 0,5·S, fără a confunda semnalul bipolar cu o luminanță negativă.

Pentru Lmax = L0(1+C) și Lmin = L0(1−C), contrastul Michelson este CM = (Lmax−Lmin)/(Lmax+Lmin) = C. Sensibilitatea la contrast este SCSF = 1/Cprag. De exemplu, un prag de 1% înseamnă sensibilitate 100. Modificarea luminanței medii și modificarea contrastului sunt operații distincte.

Diagrama Campbell–Robson are 1600×900 pixeli. Pe coordonata orizontală normalizată x ∈ [0,1], frecvența instantanee este f(x) = 0,5·1000^x, în cicluri pe lățimea imaginii. Faza se obține prin integrare: φ(x) = 2π·0,5·(1000^x−1)/ln(1000). Alegerea sin[2π·f(x)·x] ar produce o altă frecvență instantanee și nu respectă cerința.

Cu y = 0 sus și y = 1 jos, contrastul este C(y) = exp[ln(0,005)·(1−y)], iar imaginea I(x,y) = 0,5 + 0,5·C(y)·sin φ(x). Astfel contrastul este 0,5% sus și 100% jos. Limitele anvelopei pe orice linie sunt 0,5·(1−C) și 0,5·(1+C), independente de x. Extremele eșantionate pot să nu atingă exact anvelopa, deoarece maximele sinusului nu cad obligatoriu pe pixeli. La extrema stângă, unde încape mai puțin de un ciclu local, nu se poate interpreta o porțiune foarte scurtă drept o estimare fiabilă a contrastului Michelson local.

Exemplul din PDF folosește C = Y³; această lege nu este exponențială și pornește de la zero. Implementarea o înlocuiește cu legea cerută textual. Frecvența maximă 500 este sub Nyquist-ul grilei, (1600−1)/2 = 799,5 cicluri pe lățimea normalizată.

Determinarea experimentală: se rulează ex02_contrast(true, W, D), se fixează geometria de observare și se marchează minimum șase puncte ale graniței dintre textura vizibilă și cea invizibilă. Enter încheie selecția. Pentru punctul (px,py), x = (px−1)/1599, y = (py−1)/899; frecvența este f(x)/α, pragul este C(y), iar sensibilitatea este inversul pragului. CSV-ul păstrează frecvența în cpd, pragul și sensibilitatea. W este lățimea fizică a imaginii efectiv afișate; nu trebuie introdusă automat lățimea întregului monitor.

În modul automat este folosită exclusiv o curbă ilustrativă: frecvențe [0,05; 0,2; 0,5; 1; 2; 4; 8; 13,56] cpd și sensibilități [3; 8; 20; 45; 80; 100; 55; 18]. Aceste valori sunt exemple didactice și nu măsurători personale. Forma band-pass ilustrează sensibilitatea mai bună pentru frecvențe medii și scăderea pentru variații foarte lente sau detalii foarte fine. Valorile pixelilor sunt folosite ca aproximație a luminanței; o determinare fotometrică necesită calibrarea și liniarizarea afișajului.

Filtrul Remez se construiește în ex02_contrast.m cu firpm, ordin 80, din curba măsurată sau ilustrativă, normalizată la maximul său. Frecvențele sunt raportate la Nyquist-ul aceleiași geometrii vizuale: fN = 799,5/α cpd. Sunt impuse șase benzi cu răspuns liniar pe fiecare bandă și intervale de tranziție libere. Nu se poate cere unui FIR finit să coincidă exact cu o curbă arbitrară: firpm furnizează o aproximație minimax pe benzile impuse. Ordinul și benzile se pot ajusta după examinarea răspunsului obținut.

ftrans2 transformă filtrul unidimensional într-un nucleu bidimensional prin transformarea McClellan. Aproximarea izotropă nu este perfectă în întregul plan al frecvențelor. Nucleul filtrează buildings_original.bmp în virgulă mobilă, cu margini simetrice. Compararea se face pe aceeași scară [0,1]; răspunsul neclampat este păstrat în fișierul MAT. O schimbare a nivelului mediu este posibilă deoarece câștigul la frecvența zero nu este impus la unitate.

Sunt favorizate structurile la scări medii, în timp ce variațiile foarte lente și cele foarte fine sunt atenuate. Într-o imagine încărcată, detaliile fine nu sunt toate perceptibile: sensibilitatea limitată la frecvențe înalte și mascarea de către vecinătăți reduc detectabilitatea unor modificări. Aceasta justifică ponderarea perceptuală folosită în prelucrare și compresie. Pragurile depind însă de contrast, luminanță, distanță, conținut și observator; CSF nu este o mască universală de eliminare a detaliilor.

Figură: documentatie/figuri/ex02_campbell_robson.png. Curba, filtrul Remez și imaginea filtrată se exportă de MATLAB în rezultate/ex02_csf_remez.png, iar coeficienții sunt salvați în ex02_contrast.mat.

## 3. Mascare și evidențiere

ex03_mascare.m citește lighthouse2.bmp, de 512×768 pixeli, și generează un zgomot alb gaussian 128×768, cu medie zero și deviație standard 0,06 pe scala [0,1]. Aceeași realizare este adăugată o dată pe liniile 1:128 și o dată pe liniile 385:512. Intensitățile sunt limitate explicit în [0,1] după adunare. Generatorul este inițializat reproductibil cu seed 2026, iar starea sa anterioară este restaurată la ieșire.

În partea superioară, cerul conține suprafețe relativ uniforme. Variațiile aleatoare adăugate devin evidente deoarece introduc energie spațială într-o zonă cu puține detalii concurente. În partea inferioară, textura rocilor și a valurilor are deja variații puternice; zgomotul devine mai greu de separat de structura locală. Acesta este un exemplu de mascare spațială dependentă de conținut. Amplitudinea zgomotului introdus este identică înainte de limitarea intensităților.

La cerința „imagine proprie” este creată explicit o imagine sintetică originală, cu jumătatea superioară uniformă și jumătatea inferioară texturată, ambele cu medie nominală 0,5. Se suprapune același bloc de zgomot 128×384 într-o regiune uniformă, apoi într-o regiune texturată. Imaginea proprie este salvată separat în rezultate/ex03_imagine_proprie.png. Alegerea sintetică permite controlul luminanței și al texturii; nu este prezentată ca fotografie realizată de un observator.

Vizibilitatea crescută a zgomotului pe cer poate fi numită informal evidențiere în comparația cerută de enunț. Facilitarea în sens psihofizic strict ar necesita însă demonstrarea scăderii pragului țintei în prezența unei măști slabe. Cele două imagini statice nu demonstrează singure acea scădere; ele ilustrează în primul rând efectul texturii asupra vizibilității zgomotului.

Codul-model din PDF aplică uint8 înainte de scalarea cu 255. Astfel valorile aleatoare sunt cuantizate prematur și nu mai reprezintă zgomot continuu de intensitate mică. Folosirea randn în double evită acest efect și evită confundarea zgomotului cu o creștere sistematică a luminanței.

Figuri: documentatie/figuri/ex03_lighthouse.png și ex03_proprie.png. Realizările Python din aceste figuri folosesc același principiu, dar nu sunt identice bit cu bit cu realizările generatorului MATLAB.

## 4. Non-independență în frecvență spațială și orientare

Primul experiment compară s1 = sin u cu s2 = sin 4u + sin 5u + sin 6u, unde u = 2π·7·x/128. Identitatea trigonometrică este s2 = sin 5u·(1 + 2 cos u). Semnalul de frecvență înaltă are o anvelopă care se repetă la frecvența fundamentală f = 7. De asemenea, cel mai mare divizor comun al numerelor de cicluri 28, 35 și 42 este 7. Textura conține șapte grupări pe lățime, de aceea cele două imagini pot sugera aceeași periodicitate globală.

Suma nu conține o componentă Fourier la f: spectrul său liniar conține numai 4f, 5f și 6f. Detectarea grupărilor prin rectificare, contrast local și integrare spațială explică percepția unei periodicitați comune. Nu trebuie susținut că adunarea liniară generează automat o nouă sinusoidă la frecvența f. Toate cele trei componente rămân sub Nyquist-ul de 64 cicluri/imagine.

Al doilea experiment creează benzi orientate exact la θ = +67,5° și θ = −67,5° față de axa orizontală carteziană. Pentru o normală la benzi n = (−sin θ, cos θ), stimulul este sin[2π·f·(−sin θ·x + cos θ·y)/128]. Deoarece imaginile au coordonata verticală crescătoare în jos, în implementare se schimbă semnul termenului vertical. Unghiul benzilor este perpendicular pe direcția vectorului de frecvență; cele două convenții trebuie diferențiate.

În sumă sunt prezente cele două orientări inițiale. Apar și grupări/aliniamente orizontale și verticale ale rețelei perceptuale. Cu a = 2π·f·sin θ·x/128 și b = 2π·f·cos θ·y/128, suma poate fi scrisă, până la semne și faze, ca 2·cos a·sin b. Acest produs explică organizarea în anvelope pe axe. Spectrul liniar păstrează cele patru vârfuri asociate celor două sinusoide reale; aliniamentele suplimentare nu sunt componente Fourier noi pe axe.

Exemplul fSin2(3,7) din PDF este o aproximare și poate conduce la confuzie între unghiul normalei și unghiul benzilor. ex04_nonindependenta.m folosește explicit sinusul și cosinusul unghiului dorit. Amplitudinea sumelor este normalizată analitic pentru afișare, fără saturație.

Figuri: documentatie/figuri/ex04_periodicitate.png și ex04_orientare.png.

## 5. Adaptarea

ex05_adaptare.m generează un fond gri cu luminanță numerică 0,5, o pată gaussiană întunecată la stânga, una luminoasă la dreapta și două puncte de fixare pe verticală. Petele sunt centrate la aceeași înălțime cu punctul superior. Se fixează acest punct aproximativ 20 s și apoi se mută imediat privirea la punctul inferior, păstrând imaginea afișată.

În timpul fixării, contrastele periferice staționare se pot estompa prin adaptare și dispariție perceptuală de tip Troxler. Efectul este mai probabil pentru petele cu margini estompate. Mișcările oculare mici și reîmprospătarea stimulului pe retină pot reduce estomparea; dispariția completă nu este garantată pentru fiecare observator.

După mutarea privirii în jos apare o postimagine negativă în zona gri de lângă punctul inferior: pata care a fost întunecată poate apărea luminoasă, iar pata care a fost luminoasă poate apărea întunecată. Răspunsurile locale adaptate sunt dezechilibrate temporar când aceleași regiuni retiniene privesc fondul uniform. Postimaginea este legată de coordonatele retiniene și se estompează pe măsură ce sensibilitatea se recuperează.

Adaptarea la rețele sinusoidale are și selectivitate de frecvență și orientare: expunerea prelungită reduce sensibilitatea canalelor acordate apropiat de stimulul adaptor. Mecanismele nu trebuie atribuite exclusiv retinei; selectivitatea pentru orientare implică și prelucrarea corticală. Adaptarea locală explică de ce un model bazat numai pe luminanța absolută ar fi insuficient.

Figura de fixare: documentatie/figuri/ex05_adaptare.png. Pentru cronometrare și schimbarea instrucțiunii se rulează ex05_adaptare(true).

## 6. Modelarea celulelor simple cu filtre Gabor

Se folosește o grilă 101×101, x,y ∈ {−50,…,50}, f0 = 5/101 ≈ 0,049505 cicluri/pixel și σ = 101/(2·5) = 10,1 pixeli. Anvelopa este G(x,y) = exp[−(x²+y²)/(2σ²)]. Filtrul par este ge = G·cos(2πf0x), iar cel impar este go = G·sin(2πf0x). Centrul gaussianei este ales exact în zero pentru a obține simetrie pară, respectiv impară; deplasarea cu 0,5 din exemplul PDF ar strica simetria exactă față de originea grilei.

Cele două funcții sunt în cuadratură de fază. Ele nu sunt una conjugata complexă a celeilalte, fiind ambele reale. Se poate construi un Gabor complex ge + i·go; conjugatul său este ge − i·go. Un model de celulă simplă liniară are răspunsul R = Σx,y g(x,y)·I(x,y), cu sensibilitate la faza stimulului. Un model de energie care combină pătratele răspunsurilor în cuadratură ar descrie altă proprietate și nu este răspunsul liniar cerut aici.

Funcția de transfer modulatorie numerică este MTF = fftshift(abs(fft2(g))). În cazul benzilor verticale, frecvența variază pe x, iar MTF are doi lobi în jurul (fx,fy) = (±5/101,0). Lățimea lobilor este invers proporțională cu întinderea gaussianei: localizarea spațială mai bună implică selectivitate mai slabă în frecvență. Nucleul finit introduce abateri mici față de expresia continuă.

Pentru câmpul receptor rotit, gr = G·cos(2πf0y), lobii MTF se mută în (0,±5/101). MTF rotită este transpunerea MTF inițiale, în limitele erorii numerice și ale convenției de afișare. O secțiune exclusiv pe axa fx prin fy = 0 nu mai intersectează vârfurile filtrului rotit. Rotația modifică selectivitatea în orientare, fără să modifice frecvența radială preferată.

Verificarea selectivității compară aceeași celulă cu benzi verticale și cu benzi orizontale, de aceeași frecvență, amplitudine și fază centrală. Pentru ge vertical se calculează Rv = Σ ge·cos(2πf0x) și Rh = Σ ge·cos(2πf0y). Calculul independent în dublă precizie furnizează aproximativ Rv = 320,473430 și Rh = 0,033155739, deci |Rh/Rv| ≈ 0,000103459, respectiv aproximativ −79,7 dB în amplitudine. Răspunsul orizontal este astfel cu aproape patru ordine de mărime mai mic decât cel vertical.

Acestea sunt răspunsuri brute ale nucleului definit, fără normalizare de energie; raportul este indicatorul util comparației. O sinusoidă verticală aflată în cuadratură față de filtrul par ar avea de asemenea un răspuns aproape nul, de aceea se păstrează faza compatibilă în comparația de orientare. ex06_gabor.m exportă suplimentar curba acordului pentru normale între 0° și 180° și valorile exacte ale execuției MATLAB în CSV.

Figuri: documentatie/figuri/ex06_gabor.png și ex06_selectivitate.png. Fișierele MATLAB păstrează nucleele, MTF-urile și răspunsurile în rezultate/ex06_gabor.mat.

## 7. Iluzia aleasă: efectul Flash-lag

Un obiect în mișcare și un flash staționar sunt prezentate la aceeași coordonată orizontală în momentul apariției flash-ului. Obiectele sunt separate vertical pentru a putea fi comparate. Observatorul poate percepe obiectul mobil ca fiind înaintea flash-ului în direcția deplasării. Decalajul este perceptual; demonstrația nu introduce intenționat o întârziere între obiecte.

Mecanisme propuse. Nijhawan (1994) a asociat fenomenul cu extrapolarea mișcării, prin care sistemul vizual ar compensa întârzierile de prelucrare. O altă familie de explicații invocă latențe diferite pentru stimuli mobili și flash-uri. Eagleman și Sejnowski (2000) au arătat rolul informației de mișcare de după flash și au propus integrarea temporală/postdicția. Rezultatele lor au inclus o fereastră de ordinul a 80 ms în condițiile experimentelor respective. Explicațiile nu trebuie reduse la o singură întârziere fixă valabilă în toate condițiile, iar demonstrația de laborator nu discriminează între toate modelele.

Implementare: ex07_flash_lag.m folosește numai grafica MATLAB. La 60 cadre/s solicitate, un ciclu are 120 cadre, iar flash-ul apare la cadrul k = 60, cu numerotare de la zero. Poziția obiectului mobil este xm(k) = d·v·(k−60)/60, unde d este ±1, iar v implicit este 6 unități grafice/s. Flash-ul are xf = 0 și este vizibil exact un cadru. La debutul său xm(60) = xf = 0 exact, pentru ambele sensuri de mișcare. Pozițiile verticale sunt +0,45 și −0,45. Discurile au aceeași mărime în puncte grafice.

Durata nominală a flash-ului este 1/60 s ≈ 16,7 ms. Demonstrația rulează implicit șase cicluri, adică 12 s nominal. Se fixează crucea albă și se compară pozițiile orizontale ale discurilor, evitând urmărirea voluntară a celui mobil. SPACE pune pauză, C comută controlul static cu discuri aliniate permanent, iar ESC închide. Parametrul Direction = −1 inversează mișcarea. Schimbarea sensului și controlul static ajută la separarea impresiei de avans de o eventuală eroare geometrică permanentă.

Instrucțiune de rulare: addpath('matlab'); ex07_flash_lag('FPS',60,'Cycles',6,'Direction',1). Pentru sens opus se folosește Direction = −1. Viteza este în unități grafice/s, nu în grade/s; o conversie angulară cere măsurarea dimensiunii afișate și a distanței observatorului.

La execuție sunt salvate ex07_cadre.csv și ex07_flash_lag.mat. Jurnalul conține indicele cadrului, ciclul, timpul nominal, momentul trimiterii comenzii grafice, momentul revenirii din drawnow, poziția și indicatorul flash. El permite verificarea alinierii și a intervalelor software dintre cadre. Nu măsoară momentul fizic al aprinderii pixelilor. drawnow și pause nu garantează sincronizarea cu refresh-ul monitorului; pe un sistem lent flash-ul poate dura mai mult sau intervalele pot fi neregulate. Pentru o măsurare psihofizică de precizie sunt necesare prezentare sincronizată și verificarea temporală a afișajului.

Interpretarea dimensională Δx ≈ v·Δt poate ilustra legătura dintre o latență și un decalaj. De exemplu, v = 6 unități/s și Δt = 0,08 s ar da 0,48 unități. Acesta este un calcul ilustrativ al unui model simplificat, nu o estimare a decalajului fiecărui observator. Programul nu desenează acest avans în imagine.

Consecințe în inginerie. În interfețe video și realitate augmentată, un marker tranzitoriu asociat unei ținte mobile poate părea decalibrat chiar dacă pozițiile au fost corecte la același moment. Erorile tehnice de timestamp, buffering sau sincronizare se pot adăuga efectului perceptual și trebuie evaluate separat. O verificare geometrică pe un cadru înghețat este utilă alături de evaluarea în mișcare.

Interpolarea temporală, conversia ratei de cadre și reducerea bitrate-ului pot modifica durata flash-ului, claritatea țintei, contrastul sau traiectoria de mișcare. Aceste modificări pot schimba condițiile în care apare iluzia; nu rezultă că orice codec produce în mod obligatoriu un anumit decalaj. Eliminarea unui singur cadru poate elimina complet un eveniment foarte scurt. Pentru suprapuneri critice se recomandă evaluarea atât a sincronizării tehnice, cât și a percepției în condițiile reale de vizualizare. Compensarea cu o deplasare fixă a markerului nu este justificată universal, deoarece efectul depinde de stimul și de condițiile de observare.

Previzualizare: documentatie/figuri/ex07_flash_lag.gif, cu 50 cadre/s pentru compatibilitatea duratelor GIF, și ex07_aliniere.png pentru cadrul flash-ului. Aceste artefacte ilustrează geometria; animația MATLAB rămâne implementarea principală. GIF-ul nu oferă temporizare experimentală controlată.

## Rulare și validare

În MATLAB, se deschide directorul PSV și se execută run_laborator(false) pentru calculele automate. Modul run_laborator(true) include marcarea manuală a anvelopei, instrucțiunea temporizată de adaptare și animația Flash-lag. Parametrii geometrici reali pentru CSF se introduc prin apelul separat ex02_contrast(true,W,D). Sunt necesare Image Processing Toolbox și Signal Processing Toolbox; Flash-lag folosește numai MATLAB de bază.

verifica_laborator.m verifică dimensiunea și convenția sinusoidelor, limitele și monotonia diagramei Campbell–Robson, alinierea fizică la fiecare flash și raportul mic al răspunsului Gabor la orientarea ortogonală. Se rulează după addpath('matlab'). Nu este un test al percepției observatorului. Verificarea independentă Python și figurile se pot reproduce cu tools/genereaza_figuri.py; verificarea formatului Pages se realizează cu tools/actualizeaza_pages.py --verify.

## Bibliografie

[1] „Laborator 1. Percepția stimulilor vizuali”, Laborator 1 PCSV_2026.pdf, materialul furnizat, pp. 1–10.

[2] Nijhawan, R. (1994). Motion extrapolation in catching. Nature, 370, 256–257. https://doi.org/10.1038/370256b0

[3] Eagleman, D. M. și Sejnowski, T. J. (2000). Motion integration and postdiction in visual awareness. Science, 287(5460), 2036–2038. https://doi.org/10.1126/science.287.5460.2036 ; https://pubmed.ncbi.nlm.nih.gov/10720334/
