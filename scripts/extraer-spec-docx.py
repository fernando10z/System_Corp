import zipfile, re, html
from xml.etree import ElementTree as ET

W='{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
z = zipfile.ZipFile('/home/fernando/Descargas/MIP_Especificacion_Funcional_Maestra_Nivel_3_Ampliada.docx')
root = ET.fromstring(z.read('word/document.xml'))
body = root.find(W+'body')

def ptext(p):
    return ''.join(t.text or '' for t in p.iter(W+'t'))

def pstyle(p):
    pr = p.find(W+'pPr')
    if pr is None: return ''
    s = pr.find(W+'pStyle')
    return s.get(W+'val') if s is not None else ''

out=[]
def walk(el):
    for child in el:
        if child.tag == W+'p':
            t = ptext(child).strip()
            if not t: continue
            s = pstyle(child)
            m = re.match(r'(?:Heading|Ttulo|Titulo)(\d)', s)
            if m:
                out.append('\n'+'#'*min(6,int(m.group(1)))+' '+t)
            elif 'ListParagraph' in s or 'Prrafodelista' in s:
                out.append('- '+t)
            else:
                out.append(t)
        elif child.tag == W+'tbl':
            out.append('')
            for tr in child.findall(W+'tr'):
                cells=[]
                for tc in tr.findall(W+'tc'):
                    ct = ' '.join(ptext(p).strip() for p in tc.findall(W+'p'))
                    cells.append(ct.strip())
                out.append('| ' + ' | '.join(cells) + ' |')
            out.append('')
walk(body)
print('\n'.join(out))
