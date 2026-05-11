---
title: "2.3 Unstandardisierte Effekte"
format: html
---

## Zeit: 15 min | Schwierigkeit: Einsteiger

### Theorie: Die Rückkehr in die reale Welt
Wissenschaftliche Forschungsfragen zielen im Kern immer auf Effekte ab. Ein Effekt ist die tatsächliche messbare Veränderung in der realen Welt. Er ist die einzig relevante Größe für die Theorieentwicklung und für praktische Interventionen.

Unstandardisierte Effekte messen diese Veränderung strikt in der Einheit des verwendeten Messinstruments. Sie beantworten die Frage nach der Existenz und der exakten Größe eines Effektes direkt und intuitiv. Sie bilden die Basis für praktische Entscheidungen in der echten Welt (Baguley, 2009). Ein p Wert verrät nicht, ob eine Maßnahme ihr Geld wert ist, nur ob ein Schwellenwert überschritten wurde.

### Beispiel SmartRail: Was bringt das System wirklich?
Die Bahn hat SmartRail ausgerollt und meldet statistisch signifikante Verbesserungen. Jetzt stellt sich die entscheidende Frage: Wie viele Minuten Verspätung spart das System tatsächlich ein?

Dieser rohe Zeitwert in Minuten ist der unstandardisierte Effekt. Er ist sofort greifbar. Spart SmartRail durchschnittlich 0.5 Minuten, ist das für den Pendler kaum spürbar. Spart es 12 Minuten, verändert das den Arbeitsweg täglich messbar. Der unstandardisierte Effekt in Minuten liefert die entscheidende Information, um die praktische Relevanz des Projekts zu beurteilen. Er ist die Brücke von der Statistik in die Realität.

### Deine Aufgabe
Die Applikation zeigt zwei überlappende Verteilungen: die Verspätungen ohne SmartRail (grau) und mit SmartRail (blau). Der Alltagsrechner unten übersetzt den gemessenen Effekt direkt in deinen Pendelralltag.

1. **Beobachten:** Bei den Startwerten überschneiden sich die Verteilungen stark. Der unstandardisierte Effekt beträgt 5 Minuten. Der Alltagsrechner zeigt, was das für einen Jahrespendler bedeutet.
2. **Effekt vergrößern:** Verschiebe den Durchschnitt von SmartRail auf 2 Minuten. Die blaue Verteilung wandert nach links. Der unstandardisierte Effekt wächst auf 13 Minuten. Beobachte, wie sich der Alltagsrechner verändert.
3. **Streuung begreifen:** Erhöhe die Schwankung der Verspätung. Die Verteilung wird breit und flach. Der Durchschnittseffekt bleibt gleich, aber das System wird für den einzelnen Fahrgast unzuverlässig. Der Mittelwert allein erzählt nicht die ganze Geschichte.

<div id="shiny-loading" style="background:#f0f4ff; border-left:4px solid #4a6fa5; border-radius:4px; padding:10px 14px; margin-bottom:10px; font-size:14px; color:#2c3e50;">
  ⏳ Die Anwendung wird geladen — bitte bis zu 30 Sekunden warten.
</div>
<script>
(function(){
  var d = document.getElementById('shiny-loading');
  if(!d) return;
  function hide(){ d.style.transition='opacity 0.5s'; d.style.opacity='0'; setTimeout(function(){d.style.display='none';},500); }
  window.addEventListener('message', function h(e){ hide(); window.removeEventListener('message',h); });
  setTimeout(hide, 45000);
})();
</script>

```{shinylive-python}
#| standalone: true
#| viewerHeight: 750

from shiny import App, render, ui
import numpy as np
import matplotlib.pyplot as plt

MEAN_OLD = 15.0
SD_OLD   = 5.0

app_ui = ui.page_fluid(
    ui.card(
        ui.card_header("SmartRail: Unstandardisierter Effekt in Minuten"),
        ui.layout_columns(
            ui.div(
                ui.h5("SmartRail einstellen"),
                ui.input_slider("new_mean", "Durchschnittliche Verspätung mit SmartRail (Min)", 0, 30, 10),
                ui.input_slider("new_sd",   "Schwankung der Verspätung mit SmartRail (Min)", 1, 15, 4),
                ui.hr(),
                ui.output_ui("alltagsrechner"),
            ),
            ui.output_plot("hist_plot"),
            col_widths=(4, 8)
        )
    )
)

def server(input, output, session):

    @render.plot
    def hist_plot():
        mean_new = input.new_mean()
        sd_new   = input.new_sd()
        effect   = MEAN_OLD - mean_new

        np.random.seed(42)
        data_old = np.random.normal(MEAN_OLD, SD_OLD,   2000)
        data_new = np.random.normal(mean_new, sd_new, 2000)

        fig, ax = plt.subplots(figsize=(10, 6))
        bins = np.linspace(-10, 40, 60)

        ax.hist(data_old, bins=bins, alpha=0.5, color='#95a5a6',
                label=f'Ohne SmartRail  (Ø {MEAN_OLD:.0f} Min)', density=True)
        ax.hist(data_new, bins=bins, alpha=0.6, color='#3498db',
                label=f'Mit SmartRail  (Ø {mean_new:.0f} Min)', density=True)

        ax.axvline(MEAN_OLD, color='#7f8c8d', linestyle='dotted', linewidth=2)
        ax.axvline(mean_new, color='#2980b9',  linestyle='dotted', linewidth=2)

        # Doppelpfeil für den Effekt
        y_arrow = ax.get_ylim()[1] * 0.85
        if abs(effect) > 0.5:
            ax.annotate(
                "", xy=(mean_new, y_arrow), xytext=(MEAN_OLD, y_arrow),
                arrowprops=dict(arrowstyle="<->", color='#2c3e50', lw=2)
            )
            ax.text((MEAN_OLD + mean_new) / 2, y_arrow * 1.02,
                    f'{abs(effect):.1f} Min', ha='center', va='bottom',
                    fontweight='bold', fontsize=12, color='#2c3e50')

        title_color = '#27ae60' if effect > 0 else '#c0392b'
        label = "Verbesserung" if effect > 0 else "Verschlechterung"
        ax.set_title(f"Unstandardisierter Effekt: {abs(effect):.1f} Minuten {label}",
                     color=title_color, fontweight='bold', fontsize=13)
        ax.set_xlabel("Verspätung in Minuten (Rohwerte)")
        ax.set_ylabel("Relative Häufigkeit")
        ax.set_xlim(-10, 40)
        ax.legend(loc='upper right')
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)

        return fig

    @render.ui
    def alltagsrechner():
        mean_new  = input.new_mean()
        effect    = MEAN_OLD - mean_new          # Minuten gespart pro Fahrt
        fahrten   = 230                          # Arbeitstage pro Jahr
        jahreswert = effect * fahrten            # Minuten pro Jahr

        if effect > 0:
            stunden = abs(jahreswert) / 60
            farbe   = "#27ae60"
            pfeil   = "▼"
            label   = "gespart"
        else:
            stunden = abs(jahreswert) / 60
            farbe   = "#c0392b"
            pfeil   = "▲"
            label   = "verloren"

        return ui.div(
            ui.tags.p("Alltagsrechner (230 Arbeitstage/Jahr)",
                      style="font-weight:bold; font-size:13px; margin-bottom:6px;"),
            ui.tags.p(
                ui.tags.span(f"{pfeil} {abs(effect):.1f} Min ",
                             style=f"color:{farbe}; font-weight:bold; font-size:16px;"),
                "pro Fahrt",
            ),
            ui.tags.p(
                ui.tags.span(f"{pfeil} {abs(jahreswert):.0f} Min ",
                             style=f"color:{farbe}; font-weight:bold; font-size:16px;"),
                f"{label} pro Jahr",
            ),
            ui.tags.p(
                ui.tags.span(f"= {stunden:.1f} Stunden",
                             style=f"color:{farbe}; font-weight:bold; font-size:16px;"),
                " pro Jahr",
            ),
            style="background:#f8f9fa; padding:12px; border-radius:8px; margin-top:8px;"
        )

app = App(app_ui, server)
```