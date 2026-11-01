#!/usr/bin/env python3
"""Calcule reale pe WAV-uri si grafice vectoriale cu ReportLab.
Nu necesita numpy/scipy. PNG-urile se obtin din PDF cu exporta_png.swift.
"""
from pathlib import Path
import csv,json,math,hashlib
from reportlab.pdfgen import canvas
from reportlab.graphics.shapes import Drawing
from reportlab.graphics.charts.lineplots import LinePlot
from reportlab.graphics import renderPDF
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.colors import HexColor
from analiza_semnal import analyze, correlations,energy,peak

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'rezultate'/'referinta_python';OUT.mkdir(parents=True,exist_ok=True)
FONT='/System/Library/Fonts/Supplemental/'
pdfmetrics.registerFont(TTFont('Arial',FONT+'Arial.ttf'))
pdfmetrics.registerFont(TTFont('ArialB',FONT+'Arial Bold.ttf'))
BLUE=HexColor('#1f5fa5');ORANGE=HexColor('#d95629');GRAY=HexColor('#afb6be')


def decimate(xs,ys,bins=1400):
    if len(xs)<=2*bins:return list(zip(xs,ys))
    out=[];step=math.ceil(len(xs)/bins)
    for start in range(0,len(xs),step):
        stop=min(len(xs),start+step)
        lo=min(range(start,stop),key=lambda k:ys[k]);hi=max(range(start,stop),key=lambda k:ys[k])
        for k in sorted({lo,hi}):out.append((xs[k],ys[k]))
    return out


def chart(c,x,y,w,h,data,title,xlabel,ylabel,colors=None,marks=None,xrange=None):
    drawing=Drawing(w,h);p=LinePlot();p.x=80;p.y=50;p.width=w-97;p.height=h-96
    finite=[[v for v in row if math.isfinite(v[1])] for row in data]
    if not any(finite):
        c.setFont('Arial',11);c.drawString(x+80,y+h-21,title)
        c.drawString(x+80,y+h/2,'Normalizare nedefinita: energia cadrului este nula.')
        return None
    p.data=[row if row else [(0,0),(1,0)] for row in finite]
    p.joinedLines=True
    p.xValueAxis.labels.fontName='Arial';p.yValueAxis.labels.fontName='Arial'
    p.xValueAxis.labels.fontSize=18;p.yValueAxis.labels.fontSize=16
    p.xValueAxis.visibleGrid=True;p.yValueAxis.visibleGrid=True
    p.xValueAxis.gridStrokeColor=HexColor('#e4e8ec');p.yValueAxis.gridStrokeColor=HexColor('#e4e8ec')
    if xrange:p.xValueAxis.valueMin=xrange[0];p.xValueAxis.valueMax=xrange[1]
    vals=[v[1] for row in finite for v in row]
    lo=min(vals,default=-1);hi=max(vals,default=1)
    if hi-lo<1e-14:lo-=.5;hi+=.5
    margin=.08*(hi-lo);p.yValueAxis.valueMin=lo-margin;p.yValueAxis.valueMax=hi+margin
    for i in range(len(p.data)):
        p.lines[i].strokeColor=(colors or [BLUE,ORANGE,GRAY])[i%3];p.lines[i].strokeWidth=.8
    drawing.add(p);renderPDF.draw(drawing,c,x,y)
    c.setFont('ArialB',18);c.setFillColor(HexColor('#1a3045'));c.drawString(x+80,y+h-21,title)
    c.setFont('Arial',16);c.drawCentredString(x+w/2,y+7,xlabel)
    c.saveState();c.translate(x+12,y+h/2);c.rotate(90);c.drawCentredString(0,0,ylabel);c.restoreState()
    if marks:
        xmin=xrange[0] if xrange else min(v[0] for row in finite for v in row)
        xmax=xrange[1] if xrange else max(v[0] for row in finite for v in row)
        for mx,my,color in marks:
            px=x+80+(mx-xmin)/(xmax-xmin)*(w-97)
            py=y+50+(my-(lo-margin))/(hi-lo+2*margin)*(h-96)
            c.setStrokeColor(color);c.setFillColor(color);c.circle(px,py,3,stroke=1,fill=1)
    return p


def write_csv(path,headers,rows):
    with path.open('w',newline='',encoding='utf-8') as f:
        w=csv.writer(f);w.writerow(headers);w.writerows(rows)


def main():
    cfg=json.loads((ROOT/'configuratie.json').read_text());summary=[];audios=[];hashes={}
    for k,entry in enumerate(cfg['fisiere'],1):
        path=ROOT/entry['cale'];d=analyze(path,cfg,entry['m_manual']);audios.append(d)
        name=path.stem;out=OUT/f'{k:02d}_{name}';out.mkdir(exist_ok=True)
        hashes[entry['cale']]=hashlib.sha256(path.read_bytes()).hexdigest()
        x=d['x'];fs=d['fs'];N=d['N'];E=d['energy'];t=[n/fs for n in range(len(x))]
        fields=['fisier','tip','m_0','index_final_MATLAB','index_initial_MATLAB','t_initial_s','t_final_s','N','Fs_Hz','lambda2','lambda3','F0_v2_Hz','F0_v3_Hz','energie','coerenta','acord_variante']
        rows=[]
        for j,s in enumerate(d['selected'],1):
            rows.append([path.name,s['tip'],s['m'],s['m']+1,s['start']+1,s['t_start'],s['t_end'],N,fs,s['lag2'],s['lag3'],s['f02'],s['f03'],s['energy'],s['coherence'],s['agree']])
            write_csv(out/f'autocorelatie_{j:02d}.csv',['lambda','r2','r3','r2_normalizata','r3_normalizata'],zip(range(N-1),s['r2'],s['r3'],s['c2'],s['c3']))
        summary.extend(rows);write_csv(out/'ferestre_f0.csv',fields,rows)
        write_csv(out/'energie.csv',['t_s','energie','putere'],((tt,e,e/N) for tt,e in zip(t,E)))
        c=canvas.Canvas(str(out/'semnal_energie.pdf'),pagesize=(1100,800));c.setTitle(name+' — semnal si energie')
        chart(c,0,530,1100,260,[decimate(t,x)],name+' — semnal original','Timp [s]','Amplitudine')
        chart(c,0,270,1100,260,[decimate(t,E)],f'Energie pe termen scurt: N={N}, {1000*N/fs:.3f} ms','Timp [s]','E [unitati numerice²]')
        emax=max(max(E),1e-300)
        db=[10*math.log10(max(e,1e-300)/emax) for e in E]
        chart(c,0,10,1100,260,[decimate(t,db)],'Energie raportata la maximul aceluiasi fisier','Timp [s]','10 log10(E/Emax) [dB]')
        c.save()
        height=260*len(d['selected'])+50
        c=canvas.Canvas(str(out/'ferestre.pdf'),pagesize=(1200,height));c.setTitle(name+' — ferestre si autocorelatii')
        c.setFont('ArialB',15);c.drawString(62,height-24,f'{name}: r2/r2(0) (albastru), r3/r3(0) (portocaliu); m de la zero')
        for j,s in enumerate(d['selected'],1):
            y=height-40-260*j
            idx=list(range(s['start'],s['m']+1));hist=list(range(max(0,s['start']-(N-2)),s['m']+1))
            tt=[(n-s['m'])/fs*1000 for n in hist];ti=[(n-s['m'])/fs*1000 for n in idx]
            chart(c,0,y,600,260,[list(zip(tt,[x[n] for n in hist])),list(zip(ti,[x[n] for n in idx]))],f'{j}. m={s["m"]}; t={s["t_end"]:.6f}s','Timp relativ la m [ms]','Amplitudine',[GRAY,BLUE])
            title=f'F0 v2={s["f02"]:.2f} Hz; v3={s["f03"]:.2f} Hz' if s['valid'] else 'F0 nedeterminata / estimare respinsa'
            marks=[(s['lag2'],s['c2'][s['lag2']],BLUE),(s['lag3'],s['c3'][s['lag3']],ORANGE)] if s['valid'] else None
            chart(c,600,y,600,260,[list(enumerate(s['c2'])),list(enumerate(s['c3']))],title,'lambda [esantioane]','Autocorelatie normalizata',marks=marks,xrange=(0,N-2))
        c.save()
        print(name,[(s['m'],round(s['f02'],2),round(s['f03'],2),s['tip']) for s in d['selected']],flush=True)
    write_csv(OUT/'rezumat_f0.csv',fields,summary)
    # Datele scalare necesare raportului; fara duplicarea tuturor esantioanelor.
    records=[]
    for entry,d in zip(cfg['fisiere'],audios):
        records.append({'cale':entry['cale'],'fs':d['fs'],'channels':d['channels'],'N':d['N'],'samples':len(d['x']),'duration':len(d['x'])/d['fs'], 'peak_amplitude':max(map(abs,d['x'])),'energy_max':max(d['energy']), 'selected':[{key:value for key,value in s.items() if key not in ['r2','r3','c2','c3']} for s in d['selected']]})
    def clean(value):
        if isinstance(value,dict):return {k:clean(v) for k,v in value.items()}
        if isinstance(value,list):return [clean(v) for v in value]
        if isinstance(value,float) and not math.isfinite(value):return None
        return value
    (OUT/'analiza.json').write_text(json.dumps(clean(records),indent=2,ensure_ascii=False,allow_nan=False)+'\n')
    (OUT/'configuratie_utilizata.json').write_text(json.dumps(cfg,indent=2,ensure_ascii=False)+'\n')
    (OUT/'surse_sha256.json').write_text(json.dumps(hashes,indent=2,ensure_ascii=False)+'\n')
    # Verificari independente ale identitatilor si indicilor.
    r2,r3,c2,c3=correlations(list(range(1,13)),8,4,2)
    assert r2[0]==57.5 and r2[2]==55.5 and r3[2]==42.5
    assert energy(list(range(1,13)),4)[8]==230
    sinus=[math.sin(2*math.pi*100*n/8000) for n in range(1600)]
    r2,r3,c2,c3=correlations(sinus,1000,220)
    assert abs(c3[80]-1)<1e-12 and peak(c2,8000,cfg)[0]==80 and abs(peak(c3,8000,cfg)[0]-80)<=1
    _,_,c2,c3=correlations(sinus,1000,800)
    assert peak(c2,8000,cfg)[0]==80 and peak(c3,8000,cfg)[0]==80
    for d in audios:
        for s in d['selected']:
            m=s['m'];direct=sum(v*v for v in d['x'][m-d['N']+1:m+1])
            assert abs(direct-d['energy'][m])<1e-9
            assert abs(s['r2'][0]-s['r3'][0])<1e-15
            assert s['m']-s['start']+1==d['N']
    (ROOT/'documentatie'/'verificare_independenta.json').write_text(json.dumps({'stare':'trecut','formule':'(2.50), (2.52), (2.76)','teste':['sume directe si indici','istoric exterior ferestrei pentru r3','sinus 100 Hz: lambda=80 exact la N=800; toleranta 1 esantion la N=220','E(m)=N*r2(0)=N*r3(0) pe toate ferestrele reale','lungimea fiecarei ferestre'], 'executie':'Python pe WAV-urile reale; nu executie MATLAB'},indent=2,ensure_ascii=False)+'\n')

if __name__=='__main__':main()
