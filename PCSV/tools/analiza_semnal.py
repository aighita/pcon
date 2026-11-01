"""Referinta numerica dupa formulele (2.50), (2.52), (2.76) din platforma.
Fara numpy/scipy; analizeaza fisiere WAV PCM16/PCM32 mono sau stereo.
"""
from pathlib import Path
import array
import math
import wave
import sys


def read_wav(path):
    with wave.open(str(path)) as w:
        fs=w.getframerate(); channels=w.getnchannels(); bits=w.getsampwidth(); frames=w.getnframes()
        if bits not in (2,4):raise ValueError('Referinta Python accepta WAV PCM16/PCM32. MATLAB audioread accepta si alte formate.')
        a=array.array('h' if bits==2 else 'i',w.readframes(frames))
        if sys.byteorder!='little':a.byteswap()
        scale=2**(8*bits-1)
        x=[sum(a[i:i+channels])/(channels*scale) for i in range(0,len(a),channels)]
    return x,fs,channels


def energy(x,N):
    # Suma mobila cauzala; zero in afara fisierului, ca in filtrarea FIR.
    out=[];v=0.
    for i,a in enumerate(x):
        v+=a*a
        if i>=N:v-=x[i-N]*x[i-N]
        out.append(max(0.,v))
    return out


def correlations(x,m,N,lmax=None):
    if lmax is None:lmax=N-2
    start=m-N+1
    if start<0 or m>=len(x):raise ValueError('Fereastra trebuie sa fie complet in fisier.')
    r2=[];r3=[]
    for lag in range(lmax+1):
        r2.append(sum(x[n]*x[n-lag] for n in range(start+lag,m+1))/(N-lag))
        r3.append(sum(x[n]*(x[n-lag] if n>=lag else 0.) for n in range(start,m+1))/N)
    p=r2[0]
    if p<=1e-20:return r2,r3,[math.nan]*len(r2),[math.nan]*len(r3)
    return r2,r3,[v/p for v in r2],[v/p for v in r3]


def peak(curve,fs,cfg):
    lo=max(1,math.ceil(fs/cfg['f0_max_Hz']));hi=min(len(curve)-2,math.floor(fs/cfg['f0_min_Hz']))
    candidates=[k for k in range(lo,hi+1) if curve[k]>curve[k-1] and curve[k]>=curve[k+1]]
    if not candidates:return None,math.nan
    high=max(curve[k] for k in candidates)
    if high<cfg['prag_periodicitate']:return None,high
    # Primul varf care depaseste 85% din maxim, in domeniul de cautare.
    candidates=[k for k in candidates if curve[k]>=.85*high and curve[k]>=cfg['prag_periodicitate']]
    return candidates[0],curve[candidates[0]]


def inspect(x,fs,N,m,cfg,Emax):
    r2,r3,c2,c3=correlations(x,m,N)
    l2,p2=peak(c2,fs,cfg);l3,p3=peak(c3,fs,cfg)
    start=m-N+1;power=r2[0]
    # Control separat de coerenta, numai pentru respingerea falselor periodicitati.
    coherence=0.
    if l3:
        num=sum(x[n]*x[n-l3] for n in range(start,m+1))
        past=sum(x[n-l3]**2 for n in range(start,m+1))
        den=math.sqrt(power*N*past)
        coherence=num/den if den>1e-20 else 0.
    active=power*N>=Emax*cfg['prag_energie_relativ']
    valid=active and l2 is not None and l3 is not None and coherence>=cfg['prag_periodicitate']
    close=valid and abs(l2-l3)<=max(2,.08*min(l2,l3))
    return dict(m=m,N=N,start=start,t_start=start/fs,t_end=m/fs,energy=power*N,
                lag2=l2 if valid else None,lag3=l3 if valid else None,
                f02=fs/l2 if valid else math.nan,f03=fs/l3 if valid else math.nan,
                peak2=p2,peak3=p3,coherence=coherence,valid=valid,agree=close,
                r2=r2,r3=r3,c2=c2,c3=c3)


def analyze(path,cfg,manual=None):
    x,fs,channels=read_wav(path);N=math.floor(cfg['N_referinta']*fs/cfg['Fs_referinta']+.5)
    if len(x)<2*N-1:raise ValueError('Semnal prea scurt pentru fereastra si istoricul variantei 3.')
    E=energy(x,N);emax=max(E);hop=max(1,math.floor(cfg['hop_secunde']*fs+.5))
    first=2*N-3
    if manual:
        selected=[inspect(x,fs,N,int(m),cfg,emax) for m in manual]
        for s in selected:s['tip']='manuala'
    else:
        candidates=[]
        for m in range(first,len(x),hop):
            if E[m]<.04*emax:continue
            s=inspect(x,fs,N,m,cfg,emax)
            zcr=sum(x[n]*x[n-1]<0 for n in range(m-N+2,m+1))/N
            if s['agree'] and zcr<=cfg['prag_zcr_selectie']:candidates.append(s)
        candidates.sort(key=lambda s:(-min(s['coherence'],1)*math.sqrt(s['energy']/emax),s['m']))
        selected=[];spacing=math.floor(cfg['separare_ferestre_secunde']*fs+.5)
        for s in candidates:
            if all(abs(s['m']-v['m'])>=spacing for v in selected):
                s['tip']='candidata sonora';selected.append(s)
            if len(selected)>=cfg['numar_ferestre_sonore']:break
        # Controale: un cadru activ fara periodicitate si un cadru de nivel mic.
        controls=[]
        for m in range(first,len(x),hop):
            if .02*emax<E[m]<.25*emax and all(abs(m-v['m'])>=spacing for v in selected):
                s=inspect(x,fs,N,m,cfg,emax)
                if not s['valid']:controls.append(s)
        if controls:
            s=max(controls,key=lambda s:s['energy']);s['tip']='control neperiodic';selected.append(s)
        m=min(range(first,len(x),hop),key=lambda m:E[m])
        s=inspect(x,fs,N,m,cfg,emax);s['tip']='control nivel mic';selected.append(s)
        selected.sort(key=lambda s:s['m'])
    return dict(path=str(path),x=x,fs=fs,channels=channels,N=N,energy=E,selected=selected)
