#!/usr/bin/env python3
"""Raportul temei, construit din rezultatele WAV reale si configuratia folosita."""
from pathlib import Path
import json,math,statistics
from xml.sax.saxutils import escape
from reportlab.platypus import SimpleDocTemplate,Paragraph,Spacer,Image,Table,TableStyle,PageBreak,KeepTogether
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.colors import HexColor,white
from reportlab.lib.utils import ImageReader
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'rezultate/referinta_python'
records=json.loads((OUT/'analiza.json').read_text());cfg=json.loads((OUT/'configuratie_utilizata.json').read_text())
pdfmetrics.registerFont(TTFont('Arial','/System/Library/Fonts/Supplemental/Arial.ttf'))
pdfmetrics.registerFont(TTFont('ArialB','/System/Library/Fonts/Supplemental/Arial Bold.ttf'))
styles={
 'title':ParagraphStyle('title',fontName='ArialB',fontSize=23,leading=28,textColor=HexColor('#183b55'),spaceAfter=14),
 'h':ParagraphStyle('head',fontName='ArialB',fontSize=15,leading=20,spaceBefore=12,spaceAfter=10,textColor=HexColor('#183b55'),keepWithNext=True),
 'b':ParagraphStyle('body',fontName='Arial',fontSize=10.5,leading=15,spaceAfter=9),
 'small':ParagraphStyle('small',fontName='Arial',fontSize=8.5,leading=12,spaceAfter=9),
}
story=[];md=[]
def para(s,style='b'):
    story.append(Paragraph(escape(s),styles[style]));md.append(('# ' if style=='title' else '## ' if style=='h' else '')+s+'\n')
def image(path,caption,maxheight=640):
    w,h=ImageReader(str(path)).getSize();scale=min(491/w,maxheight/h)
    story.append(KeepTogether([Image(str(path),width=w*scale,height=h*scale),Spacer(1,6),Paragraph(escape(caption),styles['small'])]))
    md.append('!['+caption+'](../'+path.relative_to(ROOT).as_posix()+')\n')
def number(v):return '—' if v is None or (isinstance(v,float) and not math.isfinite(v)) else f'{v:.2f}'
def table(headers,rows,widths=None):
    story.append(Table([headers]+rows,colWidths=widths,repeatRows=1,style=TableStyle([
        ('FONTNAME',(0,0),(-1,0),'ArialB'),('FONTNAME',(0,1),(-1,-1),'Arial'),('FONTSIZE',(0,0),(-1,-1),8.5),
        ('BACKGROUND',(0,0),(-1,0),HexColor('#e9f0f5')),('TEXTCOLOR',(0,0),(-1,0),HexColor('#183b55')),
        ('GRID',(0,0),(-1,-1),.4,HexColor('#c9d4dd')),('VALIGN',(0,0),(-1,-1),'MIDDLE'),
        ('TOPPADDING',(0,0),(-1,-1),6),('BOTTOMPADDING',(0,0),(-1,-1),6)])))
    md.append('| '+' | '.join(headers)+' |\n| '+' | '.join('---' for _ in headers)+' |\n'+ '\n'.join('| '+' | '.join(map(str,r))+' |' for r in rows)+'\n')

para('Tema 1 laborator PCSV','title')
para('Autocorelațiile pe termen scurt, frecvența fundamentală și energia semnalului vocal')
para('Rezolvarea folosește înregistrările selectate în configuratie.json: '+', '.join(Path(d['cale']).name for d in records)+'. În configurația inițială sunt folosite cele trei sunete de test din platforma „L1 - marimi pe termen scurt”, conform cererii. Înregistrările proprii pot fi introduse ulterior prin același fișier de configurare. În directorul sursă au fost găsite platforma scanată și WAV-urile, fără rezolvări MATLAB preexistente.')
para('1–2. Sunetele de test și reprezentarea în timp','h')
rows=[]
for d in records:
    rows.append([Path(d['cale']).name,str(d['fs']),str(d['samples']),f'{d["duration"]:.2f}',str(d['channels']),str(d['N'])])
table(['Fișier','Fs [Hz]','Eșantioane','Durată [s]','Canale','N'],rows,[145,65,85,75,55,40])
para('Fișierele de test inițiale sunt WAV PCM pe 16 biți, mono, la 8000 Hz. Pentru configurația analizată, parametrii fiecărui fișier sunt cei din tabel. Stereo este convertit în mono prin media canalelor. Pentru fiecare fișier, axa timpului este t(n) = n/Fs, cu n pornind de la zero. Amplitudinea digitală este păstrată la scara citită; nu se aplică normalizări separate sau eliminarea mediei. Graficele semnalului complet și ale energiei sunt incluse în paginile dedicate fiecărui sunet.')
para('Rezultatele numerice și figurile livrate au fost calculate direct din aceste WAV-uri prin implementarea independentă Python. Codul MATLAB implementează aceleași formule și exportă propriile rezultate la rulare. Analiza sa statică a trecut fără mesaje; executarea MATLAB în acest mediu a fost blocată înainte de teste de eroarea de procesor „neon”.')
para('3. Alegerea ferestrei și convenția pentru m','h')
para('N = round(220·Fs/8000). La 8 kHz rezultă N = 220 eșantioane, cu durata N/Fs = 27,5 ms. Conform platformei, m reprezintă ultimul eșantion al ferestrei, iar cadrul este x(n), n = m−N+1,…,m. Indicii matematici din raport pornesc de la zero; în MATLAB se extrage x(m−N+2:m+1).')
para('Pozițiile m pentru cele șase ferestre ale fiecărui sunet sunt salvate explicit în configuratie.json: patru cadre cu periodicitate clară și două cadre de control. Istoricul anterior necesar variantei 3 este disponibil integral pentru toate întârzierile afișate. Durata N/Fs nu trebuie confundată cu distanța dintre momentele primului și ultimului eșantion, (N−1)/Fs = 27,375 ms.')

story.append(PageBreak())
para('4. Autocorelațiile: variantele 2 și 3','h')
para('Pentru λ ≥ 0 și λ < N, conform ecuației (2.50), pagina tipărită 26 a platformei:')
para('r2(λ,m) = [1/(N−λ)] · Σ x(n)·x(n−λ), pentru n = m−N+1+λ,…,m.')
para('Varianta 2 folosește N−λ perechi, toate din fereastra aleasă, și compensează numărul de perechi prin împărțirea la N−λ. În vecinătatea lui λ = N, rămân foarte puține perechi, iar estimarea devine sensibilă la poziția ferestrei și la zgomot.')
para('Conform ecuației (2.52), aceeași pagină:')
para('r3(λ,m) = (1/N) · Σ x(n)·x(n−λ), pentru n = m−N+1,…,m.')
para('Varianta 3 folosește N perechi pentru fiecare întârziere. Eșantioanele x(n−λ) pot fi dinaintea ferestrei. Prin urmare, nu este suficient să calculăm ambele variante numai din vectorul decupat cu xcorr. O schimbare de fonem sau de amplitudine în istoricul cadrului poate influența diferit varianta 3.')
para('Pe același grafic se reprezintă r2(λ,m)/r2(0,m) și r3(λ,m)/r3(0,m), pentru λ = 0,…,218, exact ca domeniul cerut în platformă pentru N = 220. La alte Fs, domeniul este adaptat la 0,…,N−2. Pentru întârzieri negative se folosește |λ| în formule; tema este reprezentată pe semiaxa pozitivă.')
para('În origine r2(0,m) = r3(0,m) = (1/N)·Σx(n)² = P(m). Pentru un cadru de energie nulă, normalizarea este nedefinită; codul întoarce NaN, fără împărțire la zero. Valorile normalizate ale acestor estimatori finiți pot depăși 1 și nu sunt limitate artificial. În cazul variantei 3, normalizarea prin energia cadrului curent nu este aceeași cu normalizarea prin rădăcina produsului energiilor celor două fragmente.')
para('5–6. Determinarea frecvenței fundamentale','h')
para('Maximul din λ = 0 nu este folosit pentru determinarea perioadei. Se identifică un maxim local clar la o întârziere pozitivă λ0, apoi T0 = λ0/Fs și F0 = Fs/λ0. Căutarea este restrânsă la 60–500 Hz, adică λ = 16,…,133 la Fs = 8000 Hz. Se alege primul maxim care depășește pragul 0,60 și 85% din cel mai mare maxim local din acest domeniu; pozițiile alese sunt marcate pe grafice.')
para('Un control suplimentar de energie și coerență respinge cadrele fără periodicitate suficientă. Acest control nu modifică autocorelațiile desenate. Rezultatul rămâne o estimare: armonicile dominante, tranzițiile și cadrele foarte scurte pot produce erori de perioadă sau mici deplasări ale maximului. Se verifică vizual forma de undă și maximele; o componentă periodică nu dovedește singură identificarea unui anumit fonem.')
para('Diferențele de un eșantion sunt posibile chiar la semnale ideale. În verificarea pe un sinus de 100 Hz cu N = 220, r3(80)/r3(0) = 1, dar maximul local poate fi la λ = 81 din cauza ferestrei finite. Pentru această realizare, la N = 800 ambele maxime sunt la λ = 80. Testul explică de ce nu trebuie forțate rezultate identice pentru cei doi estimatori.')

for k,d in enumerate(records,1):
    name=Path(d['cale']).stem;folder=OUT/f'{k:02d}_{name}'
    story.append(PageBreak());para(f'Rezultate — {name}.wav','h')
    valid=[s for s in d['selected'] if s['valid']]
    para(f'Fs = {d["fs"]} Hz; N = {d["N"]}; durata fișierului = {d["duration"]:.2f} s. Energia maximă pe termen scurt este {d["energy_max"]:.6g} în unități numerice pătratice. Cele șase valori m sunt capetele ferestrelor, nu începuturile lor.')
    rows=[]
    for s in d['selected']:
        rows.append([str(s['m']),f'{s["t_end"]:.6f}',str(s['lag2']) if s['lag2'] else '—',number(s['f02']),str(s['lag3']) if s['lag3'] else '—',number(s['f03'])])
    table(['m (de la 0)','t final [s]','λ2','F0 v2 [Hz]','λ3','F0 v3 [Hz]'],rows,[85,90,55,100,55,100])
    para('„—” înseamnă că nu se raportează o frecvență fundamentală pentru cadrul respectiv. Pentru cadrele periodice se folosesc maximele marcate în figura de pe pagina următoare.',style='small')
    image(folder/'semnal_energie.png',f'{name}: semnalul complet, energia cu fereastră alunecătoare și energia relativă în dB.',maxheight=380)
    story.append(PageBreak());para(f'{name} — ferestre și autocorelații','h')
    image(folder/'ferestre.png','Stânga: cadrul analizat în albastru și istoricul în gri. Dreapta: r2/r2(0) în albastru și r3/r3(0) în portocaliu; punctele marchează întârzierile folosite la F0.',maxheight=640)

story.append(PageBreak());para('7. Energia pe termen scurt','h')
para('Conform ecuațiilor (2.75) și (2.76), pagina tipărită 31 a platformei: E(m) = Σx(n)², pentru n = m−N+1,…,m, iar P(m) = E(m)/N. În MATLAB, curba completă se obține prin filter(ones(N,1),1,x.^2), cu pas de un eșantion. Este o sumă cauzală pe o fereastră dreptunghiulară; nu se folosește o fereastră Hann sau Hamming, care ar modifica definiția cerută.')
para('La începutul fișierului, eșantioanele anterioare sunt considerate zero, astfel încât primele N−1 valori includ ferestre parțial umplute. Pentru cadrele analizate acest efect inițial nu intervine. Relația E(m) = N·r2(0,m) = N·r3(0,m) este verificată numeric pe toate ferestrele selectate.')
para('Vârfurile energiei corespund regiunilor cu amplitudini mai mari; pauzele au energie mică. Energia singură nu dovedește sonoritatea sau periodicitatea unui fonem: o consoană neperiodică poate avea energie semnificativă. Din acest motiv analiza energiei este corelată cu forma de undă și autocorelația. Valorile sunt în unitățile pătratice ale amplitudinii digitale, nu în jouli și nu în dB SPL.')
para('A treia reprezentare a fiecărui fișier folosește 10·log10[E(m)/Emax], cu Emax calculat separat pentru acel fișier. Este o reprezentare relativă pentru evidențierea pauzelor; nu reprezintă calibrarea acustică a înregistrărilor.')
para('Sinteza frecvențelor estimate','h')
rows=[]
for d in records:
    valid=[s for s in d['selected'] if s['valid']]
    a=[s['f02'] for s in valid];b=[s['f03'] for s in valid]
    rows.append([Path(d['cale']).stem,str(len(valid)),f'{min(a):.2f}–{max(a):.2f}' if a else '—',f'{min(b):.2f}–{max(b):.2f}' if b else '—'])
table(['Înregistrare','Cadre periodice','Interval F0 v2 [Hz]','Interval F0 v3 [Hz]'],rows,[150,90,125,125])
para('Intervalele descriu numai ferestrele selectate, nu toate valorile F0 din întreaga înregistrare. Ele nu sunt o estimare a vitezei de rostire a cuvântului. Durata cuvântului și frecvența vibrației cvasi-periodice a vocii sunt proprietăți diferite.')
differences=[]
for d in records:
    for s in d['selected']:
        if s['valid'] and s['lag2']!=s['lag3']:differences.append((Path(d['cale']).name,s))
for name,s in differences:
    para(f'Exemplu de diferență între variante: {name}, m = {s["m"]}. λ2 = {s["lag2"]} conduce la F0 = {s["f02"]:.2f} Hz, iar λ3 = {s["lag3"]} conduce la F0 = {s["f03"]:.2f} Hz. Diferența provine din poziția maximului pentru cele două definiții și din rezoluția de un eșantion; nu este corectată artificial.')
para('Reproducere și înlocuirea sunetelor','h')
para('Se rulează run_tema1 din directorul PCSV. Fișierele și valorile m se schimbă numai în configuratie.json. Pentru înregistrări proprii se înlocuiește calea WAV și se golește lista m_manual, sau se introduc capete de ferestre potrivite noii înregistrări. N se adaptează automat proporțional cu Fs. Rezultatele MATLAB sunt salvate separat de referința Python, astfel încât sursa fiecărui rezultat rămâne clară.')
para('Nu este necesară reeșantionarea la 8 kHz. O eventuală schimbare reală a frecvenței de eșantionare trebuie făcută prin reeșantionare cu filtrare, nu prin înlocuirea etichetei Fs, care ar modifica înălțimea sunetului și toate estimările F0.')
para('Verificare și surse','h')
para('Verificări independente: sume directe pe o secvență numerică, diferența r2/r3 prin istoricul exterior cadrului, sinus de 100 Hz, energie prin sumă directă și consistența indicilor pe toate cele 18 ferestre reale. Analiza statică MATLAB și rezultatele verificărilor sunt în documentatie/. Valorile complete ale autocorelațiilor și energiei sunt disponibile în CSV, alături de graficele PNG și PDF vectorial.')
para('Surse: „Tema 1 Laborator .pdf”, punctele 1–7; „1. Marimi pe termen scurt - Laborator.pdf”, secțiunea 2.3, ecuațiile (2.50) și (2.52), pagina tipărită 26 (pagina 7 a PDF-ului scanat), și secțiunea 2.9, ecuațiile (2.75)–(2.76), pagina tipărită 31 (pagina 9 a PDF-ului scanat). WAV-urile originale sunt cele din același director; hash-urile SHA-256 sunt păstrate împreună cu rezultatele.')

(ROOT/'documentatie/tema1_raport.md').write_text('\n'.join(md),encoding='utf-8')
def footer(c,doc):
    c.setFont('Arial',9);c.setFillColor(HexColor('#4c6070'))
    c.drawString(52,26,'PCSV — Tema 1 — analiză pe sunetele de test furnizate')
    c.drawRightString(543,26,str(doc.page))
SimpleDocTemplate(str(ROOT/'tema1_raport.pdf'),pagesize=(595.28,841.89),leftMargin=52,rightMargin=52,topMargin=42,bottomMargin=45,title='Tema 1 PCSV — autocorelatie si energie').build(story,onFirstPage=footer,onLaterPages=footer)
print(ROOT/'tema1_raport.pdf')
