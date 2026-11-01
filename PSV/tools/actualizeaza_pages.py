#!/usr/bin/env python3
"""Actualizeaza textul nativ IWA al sablonului furnizat; numai biblioteca standard.
Nu redenumeste un DOCX drept Pages. Pastreaza stilurile si structura sablonului.
--verify: verifica arhiva, lungimile mesajelor, textul si pozitiile stilurilor.
"""
from pathlib import Path
import sys
import zipfile
from iwa_codec import vint, fields, decompress

ROOT=Path(__file__).resolve().parents[1]

def varint(n):
    out=bytearray()
    while n>127: out.append((n&127)|128); n>>=7
    out.append(n); return bytes(out)

def pack(fs):
    out=bytearray()
    for f,k,v in fs:
        out.extend(varint((f<<3)|k))
        if k==0:out.extend(varint(v))
        elif k==2:out.extend(varint(len(v)));out.extend(v)
        else:out.extend(v)
    return bytes(out)

def records(data):
    p=0
    while p<len(data):
        n,p=vint(data,p); h=fields(data[p:p+n]);p+=n;messages=[]
        for f,k,v in h:
            if f==2:
                size=next(x[2] for x in fields(v) if x[0]==3)
                messages.append(data[p:p+size]);p+=size
        yield h,messages
    assert p==len(data)

def compress_literal(data):
    out=bytearray()
    for p in range(0,len(data),65536):
        chunk=data[p:p+65536]; n=len(chunk); ln=n-1
        if n<=60: tag=bytes([ln<<2])
        else:
            z=(ln.bit_length()+7)//8; tag=bytes([(59+z)<<2])+ln.to_bytes(z,'little')
        raw=varint(n)+tag+chunk
        out.extend(b'\0'+len(raw).to_bytes(3,'little')+raw)
    return bytes(out)

def source():
    blocks=[b.strip() for b in (ROOT/'documentatie/laborator.md').read_text().split('\n\n') if b.strip()]
    text=[]; runs=[]; offset=0
    for i,block in enumerate(blocks):
        if block.startswith('# '):line=block[2:];style=1731496
        elif block.startswith('## '):line=block[3:];style=1731509
        elif i==1:line=block;style=1731500
        else:line=block;style=1731515
        line=line.replace('\n',' ')+'\n'
        runs.append((1,2,pack([(1,0,offset),(2,2,pack([(1,0,style)]))])))
        text.append(line);offset+=len(line.encode('utf-16-le'))//2
    return ''.join(text),pack(runs)

def update():
    text,runs=source()
    template=ROOT/'documentatie/sablon_initial.pages'
    z=zipfile.ZipFile(template); out=bytearray()
    for h,msgs in records(decompress(z.read('Index/Document.iwa'))):
        ident=next(v for f,k,v in h if f==1)
        for i,msg in enumerate(msgs):
            fs=fields(msg)
            if ident==1732558:
                fs=[(f,k,text.encode() if f==3 else runs if f==5 else v) for f,k,v in fs if f!=11]
                msgs[i]=pack(fs)
            elif any(f==3 and k==2 and v==b'Footer' for f,k,v in fs):
                msgs[i]=pack([(f,k,'PCSV · Laborator 1'.encode() if f==3 else v) for f,k,v in fs if f!=11])
        nh=[];j=0
        for f,k,v in h:
            if f==2:
                v=pack([(ff,kk,len(msgs[j]) if ff==3 else vv) for ff,kk,vv in fields(v)]);j+=1
            nh.append((f,k,v))
        hb=pack(nh);out.extend(varint(len(hb))+hb+b''.join(msgs))
    encoded=compress_literal(bytes(out));assert decompress(encoded)==out
    with zipfile.ZipFile(ROOT/'laborator.pages','w',zipfile.ZIP_DEFLATED) as dest:
        for name in z.namelist():
            if name=='Index/Document.iwa':dest.writestr(name,encoded)
            elif name.startswith('preview'):
                preview=ROOT/'documentatie'/'figuri'/name
                if preview.exists():dest.writestr(name,preview.read_bytes())
            else:dest.writestr(name,z.read(name))
    verify()

def verify():
    z=zipfile.ZipFile(ROOT/'laborator.pages');assert z.testzip() is None
    expected,_=source(); found=False
    for h,msgs in records(decompress(z.read('Index/Document.iwa'))):
        if next(v for f,k,v in h if f==1)!=1732558:continue
        fs=fields(msgs[0]);text=next(v.decode() for f,k,v in fs if f==3)
        assert text==expected
        runs=next(v for f,k,v in fs if f==5)
        starts=[next(v for f,k,v in fields(run) if f==1) for _,_,run in fields(runs)]
        assert starts==sorted(set(starts)) and starts[-1]<len(text.encode('utf-16-le'))//2
        assert all(text[p-1]=='\n' for p in starts[1:]) # BMP text: UTF16 offsets = codepoints
        found=True
    assert found
    print(f'Pages: arhiva nativa verificata; {len(expected)} caractere, {len(starts)} paragrafe.')

if __name__=='__main__':
    if '--verify' in sys.argv:verify()
    else:update()
