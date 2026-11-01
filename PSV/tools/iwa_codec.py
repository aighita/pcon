"""Codec minimal Protobuf/Snappy pentru actualizarea sablonului Pages furnizat."""

def vint(b,p=0):
 n=0;s=0
 while True:
  v=b[p];p+=1;n|=(v&127)<<s;s+=7
  if v<128:return n,p

def raw(b):
 n,p=vint(b);o=bytearray()
 while p<len(b):
  t=b[p];p+=1;k=t&3
  if k==0:
   l=t>>2
   if l<60:l+=1
   else:
    z=l-59;l=int.from_bytes(b[p:p+z],'little')+1;p+=z
   o.extend(b[p:p+l]);p+=l
  else:
   if k==1:l=4+((t>>2)&7);d=((t&224)<<3)|b[p];p+=1
   elif k==2:l=1+(t>>2);d=int.from_bytes(b[p:p+2],'little');p+=2
   else:l=1+(t>>2);d=int.from_bytes(b[p:p+4],'little');p+=4
   for _ in range(l):o.append(o[-d])
 assert len(o)==n
 return bytes(o)

def decompress(b):
 o=b'';p=0
 while p<len(b):
  k=b[p];n=int.from_bytes(b[p+1:p+4],'little');p+=4
  assert k==0
  o+=raw(b[p:p+n]);p+=n
 return o

def fields(b):
 p=0;a=[]
 while p<len(b):
  t,p=vint(b,p);k=t&7
  if k==0:v,p=vint(b,p)
  elif k==2:n,p=vint(b,p);v=b[p:p+n];p+=n
  elif k in (1,5):n={1:8,5:4}[k];v=b[p:p+n];p+=n
  else:raise ValueError(k)
  a.append((t>>3,k,v))
 return a
