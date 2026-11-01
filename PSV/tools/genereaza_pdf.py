#!/usr/bin/env python3
"""Versiune PDF a raportului, cu figuri de referinta. Necesita reportlab."""
from pathlib import Path
from xml.sax.saxutils import escape
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, PageBreak, KeepTogether
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.colors import HexColor
from reportlab.lib.utils import ImageReader
ROOT=Path(__file__).resolve().parents[1]
pdfmetrics.registerFont(TTFont('Arial','/System/Library/Fonts/Supplemental/Arial.ttf'))
pdfmetrics.registerFont(TTFont('ArialB','/System/Library/Fonts/Supplemental/Arial Bold.ttf'))
styles={
 'title':ParagraphStyle('title',fontName='ArialB',fontSize=23,leading=29,textColor=HexColor('#18364c'),spaceAfter=18),
 'heading':ParagraphStyle('heading',fontName='ArialB',fontSize=16,leading=21,textColor=HexColor('#18364c'),spaceAfter=14),
 'body':ParagraphStyle('body',fontName='Arial',fontSize=10.5,leading=15,spaceAfter=10),
 'caption':ParagraphStyle('caption',fontName='Arial',fontSize=9,leading=12,textColor=HexColor('#465363'),spaceAfter=14),
}
figs={
 '1.':['ex01_buildings.png','ex01_parrots.png'],
 '2.':['ex02_campbell_robson.png'],
 '3.':['ex03_lighthouse.png','ex03_proprie.png'],
 '4.':['ex04_periodicitate.png','ex04_orientare.png'],
 '5.':['ex05_adaptare.png'],
 '6.':['ex06_gabor.png','ex06_selectivitate.png'],
 '7.':['ex07_aliniere.png'],
}
story=[];section=None

def append_figures():
    for name in figs.get(section,[]):
        path=ROOT/'documentatie'/'figuri'/name
        w,h=ImageReader(str(path)).getSize();scale=min(475/w,440/h)
        story.append(KeepTogether([Spacer(1,9),Image(str(path),width=w*scale,height=h*scale),Paragraph(escape('Figură de referință calculată independent: '+name),styles['caption'])]))

for block in (ROOT/'documentatie'/'laborator.md').read_text().split('\n\n'):
    block=block.strip()
    if not block:continue
    if block.startswith('## '):
        append_figures()
        title=block[3:];section=title.split(' ')[0]
        if section[0].isdigit() or title in ['Rulare și validare','Bibliografie']:story.append(PageBreak())
        story.append(Paragraph(escape(title),styles['heading']))
    elif block.startswith('# '):story.append(Paragraph(escape(block[2:]),styles['title']))
    else:story.append(Paragraph(escape(block).replace('\n',' '),styles['body']))
append_figures()

def page(canvas,doc):
    canvas.setFont('Arial',9);canvas.setFillColor(HexColor('#536474'))
    canvas.drawString(52,30,'PCSV / PSV · Laborator 1 · 2026')
    canvas.drawRightString(543,30,str(doc.page))
SimpleDocTemplate(str(ROOT/'laborator.pdf'),pagesize=(595.28,841.89),rightMargin=52,leftMargin=52,topMargin=48,bottomMargin=50,title='Laborator 1 — Percepția stimulilor vizuali',author='').build(story,onFirstPage=page,onLaterPages=page)
print(ROOT/'laborator.pdf')
