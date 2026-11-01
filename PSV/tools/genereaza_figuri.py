#!/usr/bin/env python3
"""Figuri de referinta si verificari independente; necesita Pillow.
Nu substituie executia MATLAB. Rulare: python3 tools/genereaza_figuri.py
"""
from pathlib import Path
from math import sin, cos, exp, pi, log, log10, atan
import cmath
import json
import random
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'documentatie' / 'figuri'
OUT.mkdir(parents=True, exist_ok=True)
FONT = '/System/Library/Fonts/Supplemental/Arial.ttf'
font = ImageFont.truetype(FONT, 19)
small = ImageFont.truetype(FONT, 15)

def gray(w,h,values):
    im=Image.new('L',(w,h)); im.putdata([round(max(0,min(1,v))*255) for v in values]); return im

def montage(items,name,cols=2,tile=(560,380)):
    rows=(len(items)+cols-1)//cols; tw,th=tile
    out=Image.new('RGB',(cols*tw,rows*th),(250,250,250)); d=ImageDraw.Draw(out)
    for i,(title,im) in enumerate(items):
        x=(i%cols)*tw; y=(i//cols)*th
        d.text((x+12,y+8),title,font=font,fill=(25,35,50))
        im=im.convert('RGB'); scale=min((tw-24)/im.width,(th-48)/im.height)
        method=Image.Resampling.NEAREST if max(im.size)<=128 else Image.Resampling.LANCZOS
        im=im.resize((round(im.width*scale),round(im.height*scale)),method)
        out.paste(im,(x+(tw-im.width)//2,y+40+(th-48-im.height)//2))
    out.save(OUT/name)

def plot(points,title,xlabel='Unghi (grade)',ylabel='Raspuns relativ'):
    im=Image.new('RGB',(1000,550),'white'); d=ImageDraw.Draw(im)
    d.text((70,15),title,font=font,fill='black')
    x0,y0,x1,y1=90,65,950,470
    d.line((x0,y0,x0,y1,x1,y1),fill='black',width=2)
    for t in [0,.25,.5,.75,1]:
        y=y1-t*(y1-y0); d.line((x0,y,x1,y),fill=(220,225,230));d.text((15,y-9),f'{t:.2f}',font=small,fill='black')
    xmin=min(x for x,y in points); xmax=max(x for x,y in points)
    coords=[(x0+(x-xmin)/(xmax-xmin)*(x1-x0), y1-y*(y1-y0)) for x,y in points]
    d.line(coords,fill=(20,100,180),width=3)
    for x,y in coords:d.ellipse((x-3,y-3,x+3,y+3),fill=(20,100,180))
    for x in [xmin,(xmin+xmax)/2,xmax]:
        px=x0+(x-xmin)/(xmax-xmin)*(x1-x0);d.text((px-15,y1+10),f'{x:g}',font=small,fill='black')
    d.text((400,515),xlabel,font=font,fill='black');d.text((90,40),ylabel,font=small,fill='black')
    return im

for name in ['buildings_original','parrots']:
    g=Image.open(ROOT/'test_images'/f'{name}.bmp').convert('L')
    low=g.filter(ImageFilter.GaussianBlur(.8))
    # Laplacian discret semnat, normalizat numai pentru vizualizare.
    w,h=g.size; a=list(g.tobytes()); e=[]
    for y in range(h):
        for x in range(w):
            e.append(a[y*w+max(0,x-1)]+a[y*w+min(w-1,x+1)]+a[max(0,y-1)*w+x]+a[min(h-1,y+1)*w+x]-4*a[y*w+x])
    maxe=max(abs(v) for v in e) or 1
    edge=gray(w,h,[.5+.5*v/maxe for v in e])
    sharp=g.filter(ImageFilter.UnsharpMask(radius=1,percent=100,threshold=0))
    montage([('Original',g),('Gaussian, sigma = 0,8',low),('Laplacian semnat: scala proprie',edge),('Clarificare',sharp)],'ex01_'+('buildings' if name.startswith('build') else name)+'.png')

Nx,Ny=1600,900
freq=[.5*1000**(x/(Nx-1)) for x in range(Nx)]
phase=[2*pi*.5/log(1000)*(1000**(x/(Nx-1))-1) for x in range(Nx)]
C=[exp(log(.005)*(1-y/(Ny-1))) for y in range(Ny)]
assert abs(C[0]-.005)<1e-12 and C[-1]==1
assert all(a<b for a,b in zip(freq,freq[1:]))
cr=gray(Nx,Ny,[.5+.5*c*sin(p) for c in C for p in phase]);cr.save(OUT/'ex02_campbell_robson.png')

rng=random.Random(2026)
g=Image.open(ROOT/'test_images'/'lighthouse2.bmp').convert('L');w,h=g.size
a=[v/255 for v in g.tobytes()]; noise=[rng.gauss(0,.06) for _ in range(128*w)]
top=a.copy(); bot=a.copy()
for y in range(128):
    for x in range(w):
        top[y*w+x]+=noise[y*w+x];bot[(y+384)*w+x]+=noise[y*w+x]
montage([('Original',g),('Zgomot pe cer',gray(w,h,top)),('Acelasi zgomot pe roci',gray(w,h,bot))],'ex03_lighthouse.png',3,(440,340))
own=[.5 if y<256 else max(.15,min(.85,.5+.18*sin(2*pi*x/9)*cos(2*pi*y/11)+rng.gauss(0,.09))) for y in range(h) for x in range(w)]
uniform=own.copy(); textured=own.copy()
for y in range(128):
    for x in range(384):
        uniform[(y+64)*w+x+192]+=noise[y*w+x]
        textured[(y+320)*w+x+192]+=noise[y*w+x]
montage([('Imagine proprie sintetica',gray(w,h,own)),('Bloc pe zona uniforma',gray(w,h,uniform)),('Bloc pe zona texturata',gray(w,h,textured))],'ex03_proprie.png',3,(440,340))

s1=[sin(2*pi*7*x/128) for y in range(128) for x in range(128)]
s2=[sum(sin(2*pi*k*7*x/128) for k in (4,5,6)) for y in range(128) for x in range(128)]
montage([('f = 7 cicluri/imagine',gray(128,128,[.5+v/2 for v in s1])),('4f + 5f + 6f',gray(128,128,[.5+v/6 for v in s2]))],'ex04_periodicitate.png',1,(800,310))
theta=67.5*pi/180
s3=[sin(2*pi*7*(-sin(theta)*x-cos(theta)*y)/128) for y in range(128) for x in range(128)]
s4=[sin(2*pi*7*(sin(theta)*x-cos(theta)*y)/128) for y in range(128) for x in range(128)]
montage([('Benzi +67,5 grade',gray(128,128,[.5+v/2 for v in s3])),('Benzi -67,5 grade',gray(128,128,[.5+v/2 for v in s4])),('Suma',gray(128,128,[.5+(a+b)/4 for a,b in zip(s3,s4)]))],'ex04_orientare.png',3,(350,390))
I=gray(768,768,[.5+.4*exp(-((x-544)**2+(y-230)**2)/(2*35**2))-.4*exp(-((x-224)**2+(y-230)**2)/(2*35**2)) for y in range(1,769) for x in range(1,769)])
d=ImageDraw.Draw(I)
for y in [230,550]: d.ellipse((379,y-5,389,y+5),fill=0)
I.save(OUT/'ex05_adaptare.png')

N=101; sigma=10.1; f=5/N; rr=range(-50,51)
g1=[exp(-x*x/(2*sigma*sigma)) for x in rr]
e1=[g*cos(2*pi*f*x) for g,x in zip(g1,rr)]
o1=[g*sin(2*pi*f*x) for g,x in zip(g1,rr)]
even=[gy*ex for gy in g1 for ex in e1]; odd=[gy*ox for gy in g1 for ox in o1]; rot=[ey*gx for ey in e1 for gx in g1]
def dft(a):return [sum(v*cmath.exp(-2j*pi*k*n/N) for n,v in enumerate(a)) for k in range(-50,51)]
G=dft(g1);E=dft(e1)
V=[abs(gy*ex) for gy in G for ex in E];H=[abs(ey*gx) for ey in E for gx in G]
maxv=max(V)
montage([('Gabor par, benzi verticale',gray(N,N,[.5+v/2 for v in even])),('Gabor impar',gray(N,N,[.5+v/2 for v in odd])),('Gabor rotit',gray(N,N,[.5+v/2 for v in rot])),('MTF vertical: lobi pe fx',gray(N,N,[v/maxv for v in V])),('MTF rotit: lobi pe fy',gray(N,N,[v/maxv for v in H]))],'ex06_gabor.png',3,(390,390))
rv=sum(g*cos(2*pi*f*x) for g,(y,x) in zip(even,((y,x) for y in rr for x in rr)))
rh=sum(g*cos(2*pi*f*y) for g,(y,x) in zip(even,((y,x) for y in rr for x in rr)))
assert abs(rh/rv)<1e-3
assert max(abs(V[y*N+x]-H[x*N+y]) for y in range(N) for x in range(N))<1e-10
tuning=[]
for angle in range(0,181,5):
    t=angle*pi/180
    r=sum(g*cos(2*pi*f*(cos(t)*x+sin(t)*y)) for g,(y,x) in zip(even,((y,x) for y in rr for x in rr)))
    tuning.append((angle,abs(r/rv)))
plot(tuning,'Selectivitate Gabor: normala benzilor').save(OUT/'ex06_selectivitate.png')

frames=[]; fps=50
for n in range(2*fps):
    im=Image.new('RGB',(1000,430),(20,20,20));d=ImageDraw.Draw(im)
    x=500+6*(n-fps)/fps*65
    d.text((260,20),'Flash-lag: fixati crucea alba',font=font,fill='white')
    d.line((493,90,507,90),fill='white',width=2);d.line((500,83,500,97),fill='white',width=2)
    d.ellipse((x-10,170,x+10,190),fill=(77,255,77))
    if n==fps:
        assert x==500
        d.ellipse((490,270,510,290),fill=(255,128,51))
        im.save(OUT/'ex07_aliniere.png')
    d.text((180,375),'Previzualizare 50 cadre/s; flash aliniat fizic la debut.',font=font,fill='white')
    frames.append(im)
frames[0].save(OUT/'ex07_flash_lag.gif',save_all=True,append_images=frames[1:],duration=20,loop=0,disposal=2)
for direction in [-1,1]:
    for frame in range(720):
        k=frame%120;x=direction*6*(k-60)/60
        if k==60:assert x==0
checks={'origine':'Calcul independent Python; nu executie MATLAB', 'gabor_Rv':rv,'gabor_Rh':rh,'gabor_raport':abs(rh/rv),'gabor_dB':20*log10(abs(rh/rv)), 'unghi_40cm_60cm_grade':2*atan(40/120)*180/pi,'contrast_sus':C[0],'contrast_jos':C[-1],'flash_cadre_verificate':1440,'teste':'trecute'}
(ROOT/'documentatie'/'verificare_independenta.json').write_text(json.dumps(checks,indent=2,ensure_ascii=False)+'\n')
print(json.dumps(checks,indent=2,ensure_ascii=False))
