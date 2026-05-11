---
title: "2.4 Standardisierte Effektgrößen"
format: html
---

## Zeit: 15 min | Schwierigkeit: Einsteiger

### Theorie: Äpfel mit Birnen vergleichen
Unstandardisierte Effekte in originalen Maßeinheiten stoßen an ihre Grenzen, wenn du Studien vergleichen willst, die unterschiedliche Messinstrumente verwenden.

Wie vergleichst du eine Maßnahme, die in Minuten gemessen wird, mit einer Maßnahme, die in Kilowattstunden gemessen wird? Hierfür benötigen wir standardisierte Effektgrößen. Sie transformieren den Effekt in eine dimensionslose Zahl: die Anzahl der Standardabweichungen, um die sich die Gruppen unterscheiden.

Die bekannteste standardisierte Effektgröße ist **Cohens d**. Die Formel lautet:

$$d = \frac{|\bar{M}_1 - \bar{M}_2|}{SD_{pooled}}$$

Du teilst den absoluten Unterschied der Mittelwerte durch die **gepoolte Standardabweichung** beider Gruppen. Die gepoolte Standardabweichung ist das gewichtete Mittel der Streuungen in beiden Gruppen und beschreibt, wie stark die Messwerte natürlicherweise variieren.

Das Ergebnis ist eine dimensionslose Zahl ohne Maßeinheit. Ein Wert von d = 0.5 bedeutet: Die Gruppen unterscheiden sich um eine halbe Standardabweichung. Weil beide Metriken nun in Standardabweichungen ausgedrückt werden, sind sie direkt vergleichbar, egal ob wir Minuten oder Kilowattstunden gemessen haben.

**Wichtiger Vorbehalt:** Cohen selbst betonte ausdrücklich, dass seine Richtwerte (0.2 = klein, 0.5 = mittel, 0.8 = groß) nur grobe Orientierungen für Situationen sind, in denen keine domänenspezifischen Referenzwerte vorliegen (Cohen, 1988). Sie sind keine Diagnosekriterien und sollten nicht als starre Schwellenwerte verwendet werden, sonst replizieren wir das binäre Denken aus Kapitel 2.1. Ein d = 0.3 kann in einem Kontext bedeutsam und in einem anderen trivial sein.

**Ein weiterer Vorbehalt:** Die Standardisierung entfernt die Maßeinheit, nicht den inhaltlichen Kontext. Ein d = 0.5 für Verspätung ist nicht automatisch "genauso wichtig" wie ein d = 0.5 für Energieverbrauch. Der Vergleich via Cohens d beantwortet die Frage, welcher Effekt *relativ zu seiner natürlichen Streuung* größer ist — nicht unbedingt, welcher praktisch bedeutsamer ist.

### Beispiel SmartRail: Zwei Kennzahlen, eine Skala
Der Vorstand bewertet SmartRail anhand zweier Kennzahlen. Projekt A misst die Verbesserung der Pünktlichkeit in Minuten. Projekt B misst die Reduzierung des Energieverbrauchs in kWh pro 100 km.

Beide Projekte berichten Verbesserungen. Projekt A senkt die Verspätung um 3 Minuten. Projekt B senkt den Energieverbrauch um 2 kWh. Welche Verbesserung ist relativ zur natürlichen Schwankung der jeweiligen Messung größer?

3 Minuten und 2 kWh lassen sich nicht direkt vergleichen. Erst wenn wir beide Effekte durch ihre jeweilige gepoolte Standardabweichung teilen, werden sie vergleichbar. Die Verteilungsplots zeigen dir visuell, was verschiedene d-Werte bedeuten: Je weiter die Gipfel der beiden Kurven auseinanderliegen, desto größer ist d.

### Deine Aufgabe
Die Applikation zeigt oben die überlappenden Verteilungen beider Projekte in ihren jeweiligen Originaleinheiten. Unten siehst du die standardisierten Cohens d Werte im direkten Vergleich.

1. **Verteilungen lesen:** Beobachte die Überlappung beider Kurvenpaare. Wo die Gipfel weiter auseinanderliegen und die Überlappung kleiner ist, ist d größer.
2. **Streuung variieren:** Erhöhe die Streuung von Projekt A stark. Der gemessene Effekt (3 Minuten) bleibt gleich, aber d sinkt. Die Verbesserung ist relativ zur natürlichen Schwankung kleiner geworden.
3. **Benchmarks hinterfragen:** Versuche, beide Projekte auf ein d nahe 0.5 zu bringen. Überlege dann: Ist ein "mittlerer Effekt" bei Verspätungsminuten dasselbe wie bei Kilowattstunden? Cohen's d beantwortet die relative Frage — die praktische Bedeutung musst du selbst beurteilen.

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
#| viewerHeight: 820

from shiny import App, render, ui
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from scipy.stats import norm

MEAN_OLD_A = 15.0    # Verspätung ohne SmartRail (Min)
MEAN_OLD_B = 85.0    # Energie ohne SmartRail (kWh/100km)

app_ui = ui.page_fluid(
    ui.card(
        ui.card_header("SmartRail: Zwei Kennzahlen auf einer Skala"),
        ui.layout_columns(
            ui.div(
                ui.h6("Projekt A: Verspätung"),
                ui.input_slider("eff_a", "Verbesserung (Minuten)", 0.5, 15.0, 3.0, step=0.5),
                ui.input_slider("sd_a",  "Streuung (Minuten)",     1.0, 12.0, 5.0, step=0.5),
                ui.hr(),
                ui.h6("Projekt B: Energieverbrauch"),
                ui.input_slider("eff_b", "Verbesserung (kWh/100km)", 0.5, 10.0, 2.0, step=0.5),
                ui.input_slider("sd_b",  "Streuung (kWh)",           1.0, 15.0, 8.0, step=0.5),
                ui.hr(),
                ui.output_ui("cohen_panel"),
            ),
            ui.output_plot("overview_plot"),
            col_widths=(4, 8)
        )
    )
)

def server(input, output, session):

    def get_d(eff, sd):
        return eff / sd if sd > 0 else 0

    @render.plot
    def overview_plot():
        eff_a = input.eff_a()
        sd_a  = input.sd_a()
        eff_b = input.eff_b()
        sd_b  = input.sd_b()

        d_a = get_d(eff_a, sd_a)
        d_b = get_d(eff_b, sd_b)

        fig = plt.figure(figsize=(11, 9))
        gs  = GridSpec(2, 2, figure=fig, hspace=0.5, wspace=0.35)
        ax1 = fig.add_subplot(gs[0, 0])   # Verteilung Projekt A
        ax2 = fig.add_subplot(gs[0, 1])   # Verteilung Projekt B
        ax3 = fig.add_subplot(gs[1, :])   # Cohen's d Vergleich

        # --- Projekt A: Verspätung ---
        span_a  = max(4 * sd_a, eff_a + 2 * sd_a)
        x_a     = np.linspace(MEAN_OLD_A - span_a, MEAN_OLD_A + span_a, 400)
        y_old_a = norm.pdf(x_a, MEAN_OLD_A,          sd_a)
        y_new_a = norm.pdf(x_a, MEAN_OLD_A - eff_a,  sd_a)

        ax1.fill_between(x_a, y_old_a, alpha=0.45, color='#95a5a6', label='Ohne SmartRail')
        ax1.fill_between(x_a, y_new_a, alpha=0.55, color='#3498db', label='Mit SmartRail')
        ax1.axvline(MEAN_OLD_A,          color='#7f8c8d', linestyle='dotted', lw=1.5)
        ax1.axvline(MEAN_OLD_A - eff_a,  color='#2980b9', linestyle='dotted', lw=1.5)
        ax1.set_xlabel("Verspätung (Minuten)")
        ax1.set_ylabel("Dichte")
        ax1.set_title(f"Projekt A — d = {d_a:.2f}", fontweight='bold', fontsize=11)
        ax1.legend(fontsize=8, loc='upper right')
        ax1.spines['top'].set_visible(False)
        ax1.spines['right'].set_visible(False)

        # --- Projekt B: Energie ---
        span_b  = max(4 * sd_b, eff_b + 2 * sd_b)
        x_b     = np.linspace(MEAN_OLD_B - span_b, MEAN_OLD_B + span_b, 400)
        y_old_b = norm.pdf(x_b, MEAN_OLD_B,          sd_b)
        y_new_b = norm.pdf(x_b, MEAN_OLD_B - eff_b,  sd_b)

        ax2.fill_between(x_b, y_old_b, alpha=0.45, color='#95a5a6', label='Ohne SmartRail')
        ax2.fill_between(x_b, y_new_b, alpha=0.55, color='#27ae60', label='Mit SmartRail')
        ax2.axvline(MEAN_OLD_B,          color='#7f8c8d', linestyle='dotted', lw=1.5)
        ax2.axvline(MEAN_OLD_B - eff_b,  color='#229954', linestyle='dotted', lw=1.5)
        ax2.set_xlabel("Energieverbrauch (kWh/100km)")
        ax2.set_ylabel("Dichte")
        ax2.set_title(f"Projekt B — d = {d_b:.2f}", fontweight='bold', fontsize=11)
        ax2.legend(fontsize=8, loc='upper right')
        ax2.spines['top'].set_visible(False)
        ax2.spines['right'].set_visible(False)

        # --- Cohen's d Vergleich ---
        d_max    = max(d_a, d_b, 1.0)
        y_limit  = max(d_max * 1.35, 1.1)
        bar_cols = ['#3498db', '#27ae60']

        bars = ax3.bar(['Projekt A\n(Verspätung in Min)', 'Projekt B\n(Energie in kWh/100km)'],
                       [d_a, d_b], color=bar_cols, width=0.4, alpha=0.85)

        for thresh, label in [(0.2, 'Kleiner Effekt (0.2)'),
                               (0.5, 'Mittlerer Effekt (0.5)'),
                               (0.8, 'Großer Effekt (0.8)')]:
            ax3.axhline(thresh, color='#bdc3c7', linestyle='dotted', linewidth=1.5)
            ax3.text(1.5, thresh + 0.02, label, color='#95a5a6', fontsize=9, ha='right')

        for bar in bars:
            h = bar.get_height()
            ax3.text(bar.get_x() + bar.get_width() / 2, h + 0.03,
                     f'd = {h:.2f}', ha='center', va='bottom',
                     fontweight='bold', fontsize=12)

        ax3.set_ylim(0, y_limit)
        ax3.set_ylabel("Cohens d (Standardabweichungen)")
        ax3.set_title("Vergleich auf einheitlicher Skala — Richtwerte nach Cohen (1988)",
                      fontsize=11)
        ax3.spines['top'].set_visible(False)
        ax3.spines['right'].set_visible(False)

        return fig

    @render.ui
    def cohen_panel():
        d_a = get_d(input.eff_a(), input.sd_a())
        d_b = get_d(input.eff_b(), input.sd_b())

        def label(d):
            if d < 0.2:   return "sehr klein"
            elif d < 0.5: return "klein"
            elif d < 0.8: return "mittel"
            else:          return "groß"

        winner = "A (Verspätung)" if d_a >= d_b else "B (Energie)"
        col    = "#3498db"         if d_a >= d_b else "#27ae60"

        return ui.div(
            ui.tags.p(
                ui.tags.span("d (Verspätung) = ", style="font-weight:bold;"),
                ui.tags.span(f"{d_a:.2f} ", style="color:#3498db; font-weight:bold; font-size:15px;"),
                ui.tags.span(f"({label(d_a)})", style="color:#7f8c8d; font-size:12px;"),
            ),
            ui.tags.p(
                ui.tags.span("d (Energie) = ", style="font-weight:bold;"),
                ui.tags.span(f"{d_b:.2f} ", style="color:#27ae60; font-weight:bold; font-size:15px;"),
                ui.tags.span(f"({label(d_b)})", style="color:#7f8c8d; font-size:12px;"),
            ),
            ui.tags.hr(style="margin:8px 0;"),
            ui.tags.p(
                "Relativ zur Streuung größer: ",
                ui.tags.span(f"Projekt {winner}", style=f"color:{col}; font-weight:bold;"),
            ),
            style="background:#f8f9fa; padding:12px; border-radius:8px; margin-top:8px; font-size:13px;"
        )

app = App(app_ui, server)
```