#!/usr/bin/env python3
"""Genereaza protocolul PDF si sablonul DOCX. Nu creeaza masuratori sau curbe.
Necesita reportlab pentru PDF; DOCX este construit cu biblioteca standard.
"""
from pathlib import Path
from xml.sax.saxutils import escape
import zipfile
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.colors import HexColor
ROOT=Path(__file__).resolve().parents[1]
D=ROOT/'documentatie'
pdfmetrics.registerFont(TTFont('Arial','/System/Library/Fonts/Supplemental/Arial.ttf'))
pdfmetrics.registerFont(TTFont('ArialB','/System/Library/Fonts/Supplemental/Arial Bold.ttf'))
styles={
 'title':ParagraphStyle('title',fontName='ArialB',fontSize=20,leading=25,spaceAfter=18,textColor=HexColor('#173750')),
 'head':ParagraphStyle('head',fontName='ArialB',fontSize=13,leading=18,spaceBefore=12,spaceAfter=9,textColor=HexColor('#173750'),keepWithNext=True),
 'body':ParagraphStyle('body',fontName='Arial',fontSize=10.5,leading=15,spaceAfter=10),
}
story=[]
for block in (D/'protocol_si_rezolvari.md').read_text().split('\n\n'):
    block=block.strip()
    if not block:continue
    if block.startswith('# '):kind='title';block=block[2:]
    elif block.startswith('## '):kind='head';block=block[3:]
    else:kind='body'
    story.append(Paragraph(escape(block),styles[kind]))

def footer(canvas,doc):
    canvas.setFont('Arial',9);canvas.setFillColor(HexColor('#526476'))
    canvas.drawString(48,27,'PSS — Protocol; rezultatele personale necesita audiții')
    canvas.drawRightString(547,27,str(doc.page))
SimpleDocTemplate(str(D/'protocol_si_rezolvari.pdf'),pagesize=(595.28,841.89),leftMargin=48,rightMargin=48,topMargin=45,bottomMargin=48,title='PSS — protocol si rezolvari').build(story,onFirstPage=footer,onLaterPages=footer)

paras=[]
for block in (D/'raport_de_completat.md').read_text().split('\n\n'):
    block=block.strip()
    if not block:continue
    if block.startswith('# '):style='Title';block=block[2:]
    elif block.startswith('## '):style='Heading1';block=block[3:]
    else:style='Normal'
    paras.append(f'<w:p><w:pPr><w:pStyle w:val="{style}"/></w:pPr><w:r><w:t xml:space="preserve">{escape(block)}</w:t></w:r></w:p>')
ns='http://schemas.openxmlformats.org/wordprocessingml/2006/main'
doc=f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="{ns}"><w:body>'+''.join(paras)+'<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134"/></w:sectPr></w:body></w:document>'
stylesxml=f'''<?xml version="1.0" encoding="UTF-8"?><w:styles xmlns:w="{ns}">
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:sz w:val="22"/></w:rPr></w:rPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:pPr><w:spacing w:after="160" w:line="280"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:color w:val="173750"/><w:sz w:val="38"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="220" w:after="120"/></w:pPr><w:rPr><w:b/><w:color w:val="173750"/><w:sz w:val="27"/></w:rPr></w:style></w:styles>'''
relsns='http://schemas.openxmlformats.org/package/2006/relationships'
with zipfile.ZipFile(D/'raport_de_completat.docx','w',zipfile.ZIP_DEFLATED) as z:
    z.writestr('[Content_Types].xml','''<?xml version="1.0"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/></Types>''')
    z.writestr('_rels/.rels',f'<Relationships xmlns="{relsns}"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>')
    z.writestr('word/document.xml',doc);z.writestr('word/styles.xml',stylesxml)
    z.writestr('word/_rels/document.xml.rels',f'<Relationships xmlns="{relsns}"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>')
print('Protocol PDF si sablon DOCX generate. Nu exista un grafic experimental fara date.')
