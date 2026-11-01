# Determinarea experimentală a unei curbe izofone

Protocol de lucru, explicații și răspunsuri la întrebările laboratorului

## Stadiul lucrării

În directorul PSS nu au fost găsite măsurători anterioare. Acest document pregătește experimentul; nu afirmă că audițiile au fost efectuate. Graficul experimental și raportul final vor fi generate din răspunsurile ascultătorului. Nu sunt folosite valori teoretice drept rezultate personale.

Cerința obligatorie a assignment-ului este punctul 1 din „Desfășurarea lucrării”: determinarea unei curbe de egală tărie prin metoda ajustării, la un nivel confortabil. Metoda scării și comparația între metode sunt suplimentare. Resursele originale sunt păstrate; audiometru.m a fost adaptat pentru memorarea repetărilor și export. Copia sa inițială se află în resurse_originale/.

## 1. Ce se determină

O curbă de egală tărie reunește nivelurile unor tonuri pure de frecvențe diferite care sunt percepute la fel de tare ca o referință fixă de 1 kHz. Se modifică nivelul testului, nu frecvența sau nivelul referinței. Se compară tăria percepută, nu înălțimea sunetului și nici faptul că un sunet este pur și simplu audibil.

Prin definiția din material, un nivel al tăriei de X foni corespunde egalității cu un ton de 1 kHz la X dB SPL. Această atribuire cere cunoașterea nivelului acustic al referinței. În scriptul furnizat, amplgen calculează A = 10^((L−70)/20). Astfel, L = 30 înseamnă amplitudine digitală de vârf 0,01, adică −40 dBFS de vârf, nu automat 30 dB SPL. Comentariul „Pa” din funcție nu calibrează difuzoarele sau căștile.

În condiții casnice, fără calibrare acustică în funcție de frecvență, se poate determina o curbă orientativă pentru ansamblul ascultător–echipament. Ordonata corectă este „Nivel pe scala programului [dB; necalibrat SPL]”. Se poate raporta și diferența față de referință, ΔL(f) = Ltest(f) − Lref. Eticheta „foni” din interfața veche este nominală; nu o vom prezenta ca măsurătoare absolută.

## 2. Pregătirea și acomodarea

Se folosește același dispozitiv de redare pe parcursul experimentului, într-o încăpere cât mai liniștită. Se notează căștile sau difuzoarele, dispozitivul audio, volumul sistemului și procesările active. Volumul și procesările se păstrează neschimbate după stabilirea referinței. Dacă se modifică, măsurătorile nu se amestecă în aceeași curbă.

Se pornește de la un volum mic și se alege o referință clar audibilă și confortabilă. Nu se mărește excesiv volumul pentru a forța compararea unui ton care nu este perceput; frecvența poate fi omisă și motivul consemnat. Amplitudinea digitală nu oferă singură o garanție asupra nivelului acustic la ureche.

În MATLAB, din directorul PSS, se rulează run_experiment. Se completează metadatele, apoi se fac câteva comparații de acomodare, de exemplu la 500 și 2000 Hz, fără memorarea rezultatelor. Se observă diferența dintre schimbarea frecvenței și schimbarea tăriei. Programul propune nivelul 30 pe scala sa, dar alegerea finală depinde de confortul efectiv al ascultătorului.

## 3. Metoda ajustării: procedura obligatorie

Referința rămâne un ton de 1000 Hz la nivel fix. Frecvențele de test, distribuite la intervale de o octavă, sunt 62,5; 125; 250; 500; 1000; 2000; 4000; 8000 și 16000 Hz. Includerea punctului de 1000 Hz este un control al consistenței judecății: media ar trebui să fie în vecinătatea referinței, fără a fi forțată numeric la aceasta.

Butonul T + R prezintă o pereche: TEST 500 ms, pauză 200 ms, REFERINȚĂ 500 ms. Ordinea rămâne aceeași. Semnalele sunt generate la 48000 eșantioane/s, cu rampe cosinus de 10 ms la început și sfârșit, pentru reducerea clicurilor. Sunt folosite funcțiile furnizate amplgen.m și singen.m; nu se normalizează separat fiecare ton, deoarece astfel s-ar pierde diferențele de nivel urmărite.

Pentru fiecare frecvență se ascultă perechea, se modifică sliderul nivelului testului și se ascultă din nou. Dacă testul pare mai tare, se reduce nivelul; dacă pare mai slab, se crește. Se pornește cu modificări mai mari și se rafinează în apropierea egalității. Când cele două tonuri par egale ca tărie, se apasă Memorare. Un nivel modificat nu poate fi memorat înainte de a fi audiat.

Se fac minimum trei ajustări la fiecare frecvență. După memorare, programul deplasează alternativ nivelul de pornire cu ±4 dB față de ultima potrivire, în limitele interfeței. Acest lucru încurajează o nouă căutare; nu înlocuiește participarea reală a subiectului. Se pot face pauze pentru evitarea oboselii. La frecvențele greu de comparat se notează incertitudinea sau motivul omiterii, fără completarea artificială a curbei.

După încheierea măsurătorilor se rulează finalizeaza_experiment, cu audiometrul încă deschis. Se descriu acomodarea făcută și dificultățile întâmpinate efectiv. Programul exportă graficul și documentul explicativ din datele memorate și din aceste observații. O sesiune cu frecvențe fără trei repetări este marcată ca parțială.

## 4. Cum se obține graficul

Pentru frecvența f și n ajustări L1,…,Ln, nivelul reprezentat este media aritmetică în dB: Lmediu(f) = (L1 + … + Ln)/n. Aceasta este media estimărilor punctului de egalitate pe scala nivelului; nu se face media amplitudinilor sau a energiilor semnalelor.

Dispersia este descrisă de deviația standard eșantională: s(f) = sqrt[Σ(Li − Lmediu)²/(n−1)]. Pentru n = 1, deviația standard rămâne nedefinită. Barele ±s nu sunt intervale de încredere și nu includ erorile sistematice de redare sau calibrare.

Graficul folosește frecvența în Hz pe abscisă logaritmică și nivelul pe scala programului pe ordonată. Punctele sunt unite doar pentru lizibilitate. O valoare lipsă produce o întrerupere a liniei; nu este înlocuită cu o valoare interpolată. Rezultatul trebuie interpretat ca o curbă orientativă pentru sesiunea și echipamentul descrise.

Datele brute și statistica sunt salvate în CSV. Pentru atașare sunt generate curba_izofona.png și raport_experiment.pdf; există și grafic vectorial PDF, raport HTML și sursa textuală editabilă. Fiecare sesiune are propriul subdirector în rezultate/, astfel încât nu suprascrie o sesiune anterioară.

## 5. Metoda scării: supliment opțional

După metoda ajustării, fără schimbarea volumului sau a referinței, se poate rula run_scara. Se păstrează perechile T–R de 500 ms, cu pauză de 200 ms. Subiectul răspunde „t” dacă testul este mai tare și „r” dacă referința este mai tare. „p” repetă audiția, „s” omite frecvența, iar „q” încheie sesiunea.

Nivelul următor este stabilit de algoritm: după răspunsul „testul este mai tare”, nivelul scade; după răspunsul opus, crește. Se începe cu pasul de 8 dB, care este redus la 4 și apoi la 2 dB la primele schimbări de direcție. La pasul de 2 dB se păstrează șase niveluri de întoarcere; media acestora estimează punctul de egalitate. Pornirea este cu 8 dB deasupra potrivirii anterioare, când aceasta există, dar percepția inițială mai puternică nu este garantată la fiecare frecvență.

În material există o formulare care indică baleierea nivelului referinței; pașii algoritmici și scopul experimentului cer, de fapt, modificarea testului și păstrarea referinței. Implementarea respectă acest principiu. Nivelurile sunt limitate pentru a evita creșterea necontrolată; o frecvență care nu converge în domeniul permis rămâne fără estimare completă.

Scriptul suplimentar original CurbeDeEgalaTarie.m este păstrat, dar declară o funcție numită guidetemplate0 și pornește în unele ramuri de la LRef+38 = +3 dB digital, ceea ce depășește amplitudinea unitară. Pentru protocolul pregătit aici se utilizează run_scara, care aplică aceeași scară digitală și aceeași referință ca audiometrul adaptat și salvează toate răspunsurile.

Se obține separat comparatie_metode.png și un raport al metodei scării. SD-ul punctelor de întoarcere descrie observații succesive corelate; nu este echivalent cu SD-ul ajustărilor independente. Diferențele dintre metode nu sunt cuantificate înainte de efectuarea ambelor experimente.

## 6. Răspunsuri la întrebările și aplicațiile din PDF

Factorii care influențează reușita: zgomotul de fond, răspunsul în frecvență și poziționarea căștilor, nivelul referinței, durata și pauza dintre tonuri, volumul/procesările sistemului, acomodarea, atenția, oboseala și memoria auditivă. Pentru ajustare contează în plus punctul de pornire, precizia controlului și tendința subiectului de a opri prematur căutarea egalității. Pentru scară contează pasul, numărul de întoarceri, criteriul de oprire, limitele de nivel și consecvența răspunsurilor.

Organizarea metodei limitelor: se fixează referința și o frecvență a testului. Într-o serie ascendentă se pornește de la un test mai slab și se crește nivelul în pași până la schimbarea judecății în „mai tare decât referința”. Într-o serie descendentă se pornește invers și se caută schimbarea în „mai slab”. Punctul de egalitate al unei treceri poate fi estimat prin mijlocul intervalului dintre cele două niveluri care încadrează schimbarea. Se alternează mai multe serii ascendente și descendente, apoi se mediază estimările. Se repetă pentru fiecare frecvență. În acest experiment se caută egalitatea de tărie, nu pragul de detectare a unui sunet în liniște.

Erorile specifice metodei limitelor sunt obișnuința — continuarea aceluiași răspuns după ce condiția s-a modificat — și anticiparea schimbării înainte ca aceasta să fie percepută. Alternarea sensurilor, pornirile variate și instruirea adecvată reduc aceste efecte, fără a le elimina complet.

Partea dificilă pentru subiect este compararea aceleiași proprietăți perceptuale la sunete cu timbre/înălțimi foarte diferite. Un ton grav și unul acut nu pot fi comparați după amplitudinea percepută în mod automat; trebuie apreciată tăria, separată de înălțime. Memoria auditivă este limitată, iar judecata în vecinătatea egalității poate varia. Perechile scurte cu pauză constantă și repetările ajută. Dificultățile personale întâmpinate efectiv se consemnează după audiții, nu se deduc din această explicație generală.

## 7. Ce se completează în raportul final

Participantul, data, echipamentul, condițiile încăperii și volumul sistemului; nivelul de referință ales; modul efectiv de acomodare; numărul de repetări și valorile obținute; frecvențele omise și motivul; dificultățile reale și strategiile folosite; limitele de calibrare. Generatorul de raport completează automat elementele numerice și păstrează observațiile introduse de participant. Nu declară o curba standard drept rezultat experimental.

## Verificarea implementării

Au fost pregătite verificări numerice fără redare audio pentru durata semnalelor, limita amplitudinii, rampele la capete, media/SD și schimbarea pasului scării. Fișierele noi și audiometrul adaptat au trecut analiza statică MATLAB fără mesaje. Calcule independente Python au verificat durata, amplitudinea și rampele semnalelor, media/SD și schimbarea pasului scării; acestea nu constituie măsurători ale participantului. În mediul de pregătire, MATLAB R2026a nu a pornit: eroare „Incompatible processor … neon”; execuția completă și audiția trebuie verificate în MATLAB funcțional. Aceasta nu împiedică efectuarea experimentului de către participant pe propriul sistem.

## Resursă

„Experimente psihoacustice privind trasarea curbelor izofone.pdf”, documentul furnizat: teoria curbelor, pp. 1–2; metoda ajustării, pp. 3–4; metoda scării și desfășurarea lucrării, pp. 4–5; întrebări și aplicații, pp. 5–6.
