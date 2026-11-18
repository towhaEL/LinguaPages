import sys
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
OUT=sys.argv[1]; FONT=sys.argv[2]
INK,PAPER,ORANGE,ORANGE_L="#111315","#ECEAE4","#E0742E","#C9601C"
def ring(cx,cy,r,ex,ey,rx,ry):
    return (f"M{cx} {cy-r} A{r} {r} 0 1 1 {cx} {cy+r} A{r} {r} 0 1 1 {cx} {cy-r} Z "
            f"M{ex} {cy-ry} A{rx} {ry} 0 1 0 {ex} {cy+ry} A{rx} {ry} 0 1 0 {ex} {cy-ry} Z")
# master: stem 62–92, bowl r66 @ (128,96), counter 31×34 @ (129,96); ribbon split at y164, 45° notch
BODY="M62 32 H92 V164 H62 Z "+ring(128,96,66,129,96,31,34)
RIB="M62 164 H92 V224 L77 209 L62 224 Z"
# small-size cut: heavier stem (36), smaller counter, deeper notch
S_BODY="M62 32 H98 V164 H62 Z "+ring(128,96,66,131,96,27,29)
S_RIB="M62 164 H98 V224 L80 206 L62 224 Z"
def svg(w,h,inner,title="OpenPages logo"):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" role="img" aria-labelledby="t"><title id="t">{title}</title>\n{inner}\n</svg>\n'
def sym(body,rib,cb,cr,tf=""):
    t=f' transform="{tf}"' if tf else ""
    return f'<g id="symbol"{t}><path fill="{cb}" d="{body}"/><path fill="{cr}" d="{rib}"/></g>'
# wordmark outlines (Figtree Bold, tracking -10/1000)
f=TTFont(FONT); gs=f.getGlyphSet(); cmap=f.getBestCmap(); cap=f['OS/2'].sCapHeight
def word(x0,base,capH):
    s=capH/cap; pen=SVGPathPen(gs); x=0
    for ch in "OpenPages":
        g=cmap[ord(ch)]; gs[g].draw(TransformPen(pen,(s,0,0,-s,x0+x*s,base))); x+=gs[g].width-10
    return pen.getCommands(), (x+10)*s
def write(name,content): open(f"{OUT}/{name}","w").write(content)
schemes={"color-dark":(PAPER,ORANGE,PAPER),"color-light":(INK,ORANGE_L,INK),"black":("#000","#000","#000"),"white":("#FFF","#FFF","#FFF")}
for k,(cb,cr,cw) in schemes.items():
    write(f"masters/openpages-symbol-{k}.svg",svg(256,256,sym(BODY,RIB,cb,cr)))
    write(f"masters/openpages-symbol-small-{k}.svg",svg(256,256,sym(S_BODY,S_RIB,cb,cr)))
    # horizontal: symbol shifted to 24–156, gap 44, cap height 92
    wd,ww=word(200,128+46,92); W=round(200+ww+24)
    write(f"masters/openpages-horizontal-{k}.svg",svg(W,256,sym(BODY,RIB,cb,cr,"translate(-38 0)")+f'<path id="wordmark" fill="{cw}" d="{wd}"/>'))
    # stacked: symbol on top, wordmark below (cap height 64), centred
    wd2,ww2=word(0,0,64); SW=max(256,round(ww2+48))
    write(f"masters/openpages-stacked-{k}.svg",svg(SW,360,sym(BODY,RIB,cb,cr,f"translate({(SW-256)/2} 0)")+f'<path id="wordmark" fill="{cw}" d="{wd2}" transform="translate({(SW-ww2)/2:.1f} 316)"/>'))
    # wordmark only
    wd3,ww3=word(16,128+46,92); write(f"masters/openpages-wordmark-{k}.svg",svg(round(ww3+32),256,f'<path id="wordmark" fill="{cw}" d="{wd3}"/>'))
# app icon: ink tile, mark at ~60 %; Android adaptive foreground (108dp grid, mark inside 66dp safe zone)
inner=sym(S_BODY,S_RIB,PAPER,ORANGE,"translate(128 128) scale(0.6) translate(-128 -127)")
write("masters/openpages-app-icon.svg",svg(256,256,f'<rect width="256" height="256" rx="56" fill="{INK}"/>'+inner))
write("masters/openpages-app-icon-fullbleed.svg",svg(256,256,f'<rect width="256" height="256" fill="{INK}"/>'+inner))
write("masters/openpages-adaptive-foreground.svg",svg(432,432,sym(S_BODY,S_RIB,PAPER,ORANGE,"translate(216 216) scale(0.95) translate(-128 -127)")))
write("masters/openpages-adaptive-background.svg",svg(432,432,f'<rect width="432" height="432" fill="{INK}"/>'))
write("masters/openpages-monochrome-icon.svg",svg(432,432,sym(S_BODY,S_RIB,"#000","#000","translate(216 216) scale(0.95) translate(-128 -127)")))
