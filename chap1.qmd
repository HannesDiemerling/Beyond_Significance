---
title: "2.1 Fehlinterpretationen und binäres Denken"
format: html
---

## Zeit: 15 min | Schwierigkeit: Einsteiger

### Theorie: Die Illusion der harten Grenze
Der p-Wert ist eine der am häufigsten missverstandene Metrik der Wissenschaft. Er liefert explizit keine Antworten auf die eigentlichen Kernfragen der Forschung. Er sagt dir weder, ob ein Effekt in der Realität vorhanden oder durch Zufall entstanden ist, noch wie wahrscheinlich es ist, dass dein Ergebnis bei einer Wiederholung der Studie identisch ausfällt.

Besonders gefährlich ist die etablierte Praxis, eine starre Signifikanzschwelle (meist 0.05) zu definieren. Die Natur zieht keine magische Grenze zwischen p = 0.049 und p = 0.051. Ein solcher Schwellenwert erzwingt unlogische, rein binäre Entscheidungen (Gigerenzer, 2004). Er überlagert den Blick auf die echten Daten und verführt dazu, messbare Nuancen in ein extremes "Erfolg" oder "Misserfolg" Schema zu pressen. In der Praxis geht es häufig noch weiter: Viele betrachten ausschließlich den p-Wert — ohne die Rohdaten oder den eigentlichen Effekt zu betrachten. Oder sie schauen sich den Effekt nur dann an, wenn p signifikant war.

### Beispiel SmartRail: Zwei Strecken, eine Entscheidung
Die Deutsche Bahn testet SmartRail auf zwei Fernverkehrsstrecken. Auf der Strecke München–Frankfurt und auf der Strecke Hamburg–Berlin werden je 30 ICE-Fahrten mit dem neuen System aufgezeichnet und mit dem alten Betrieb verglichen.

Auf der Strecke München–Frankfurt zeigt die Auswertung eine klare Verbesserung: SmartRail spart im Schnitt 2.1 Minuten Verspätung pro Fahrt. Der p-Wert liegt bei 0.047. Das Projektteam meldet einen signifikanten Erfolg.

Auf der Strecke Hamburg–Berlin sehen die Rohdaten nahezu identisch aus. SmartRail spart dort ebenfalls rund 2.1 Minuten. Doch wegen leicht größerer Streuung an diesem Tag liegt der p-Wert bei 0.053. Die Software meldet: nicht signifikant. Das dortige Team stuft SmartRail als wirkungslos ein.

Zwei faktisch gleich starke Effekte. Zwei konträre Entscheidungen. Der einzige Unterschied: zwei hundertstel im p-Wert.

### Deine Aufgabe
Die Applikation simuliert drei typische Vorgehensweisen im Umgang mit p-Werten — vom reinen p-Wert-Blick bis zur vollständigen Datenanalyse. Oben links wählst du den Ansichtsmodus, unten links die Streuung für Hamburg–Berlin.

1. **Nur p-Werte (Startmodus):** Die Applikation startet so, wie Ergebnisse in der Praxis leider oft bewertet werden: ausschließlich anhand des p-Werts. Beobachte das Infofeld — München gilt als Erfolg, Hamburg als Versagen. Niemand hat die Rohdaten angeschaut.
2. **Effekt nur bei Signifikanz:** Wechsle zum Modus "Effekt nur bei Signifikanz". Nur bei signifikantem p schaut man überhaupt auf die Daten. Erhöhe die Streuung von Hamburg–Berlin, bis auch dort Signifikanz erreicht wird — und beide Effekte sichtbar werden.
3. **Vollständige Ansicht:** Schalte auf "Vollständige Ansicht". Jetzt siehst du beide Strecken gleichzeitig — und erkennst das Absurde: Beide Effekte sind faktisch identisch. Allein die Streuung hat entschieden, was als Erfolg gilt und was nicht.

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
#| viewerHeight: 700

from shiny import App, ui, render
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import ttest_ind

np.random.seed(7)
N = 30
MEAN_OLD = 12.5
MEAN_NEW = 10.4

old_muc = np.random.normal(MEAN_OLD, 3.0, N)
new_muc = np.random.normal(MEAN_NEW, 3.0, N)

app_ui = ui.page_fluid(
    ui.card(
        ui.card_header("SmartRail: Gleicher Effekt, gegensätzliche Urteile"),
        ui.layout_columns(
            ui.div(
                ui.h5("Ansichtsmodus"),
                ui.input_radio_buttons(
                    "view_mode", None,
                    choices={
                        "ponly":    "Nur p-Werte",
                        "sig_only": "Effekt nur bei Signifikanz",
                        "full":     "Vollständige Ansicht",
                    },
                    selected="ponly"
                ),
                ui.hr(),
                ui.h5("Strecke Hamburg–Berlin"),
                ui.input_slider(
                    "sd_hb",
                    "Streuung der Verspätung (Minuten)",
                    min=1.5, max=6.0, value=3.0, step=0.1
                ),
                ui.hr(),
                ui.output_ui("verdict_panel"),
            ),
            ui.output_plot("dual_plot"),
            col_widths=(4, 8)
        )
    )
)

def server(input, output, session):

    def get_hamburg_data(sd):
        np.random.seed(21)
        old_hb = np.random.normal(MEAN_OLD, sd, N)
        new_hb = np.random.normal(MEAN_NEW, sd, N)
        return old_hb, new_hb

    @render.plot
    def dual_plot():
        mode  = input.view_mode()
        sd_hb = input.sd_hb()
        old_hb, new_hb = get_hamburg_data(sd_hb)

        _, p_muc = ttest_ind(old_muc, new_muc)
        _, p_hb  = ttest_ind(old_hb,  new_hb)
        eff_muc  = np.mean(old_muc) - np.mean(new_muc)
        eff_hb   = np.mean(old_hb)  - np.mean(new_hb)

        jitter_scale = 0.08

        def draw_route(ax, old_d, new_d, name, p_val, eff, seed):
            sig     = p_val < 0.05
            label   = "SIGNIFIKANT" if sig else "NICHT SIG."
            color_t = '#27ae60' if sig else '#c0392b'
            np.random.seed(seed)
            jx_old = np.random.uniform(-jitter_scale, jitter_scale, N)
            jx_new = np.random.uniform(-jitter_scale, jitter_scale, N)
            ax.scatter(1 + jx_old, old_d, color='#95a5a6', alpha=0.6, s=50, label='Alt')
            ax.scatter(2 + jx_new, new_d, color='#3498db', alpha=0.6, s=50, label='SmartRail')
            ax.plot([1, 2], [np.mean(old_d), np.mean(new_d)],
                    color='#2c3e50', linewidth=2, linestyle='--')
            ax.scatter([1, 2], [np.mean(old_d), np.mean(new_d)],
                       color='#2c3e50', s=100, zorder=6)
            ax.set_title(f"{name}\n({label})", color=color_t,
                         fontweight='bold', fontsize=12, pad=15)
            ax.set_xlabel(f"Effekt: {eff:.1f} Min | p = {p_val:.3f}", fontsize=10, labelpad=10)
            ax.set_xticks([1, 2])
            ax.set_xticklabels(['Altes System', 'SmartRail'], fontsize=9)
            ax.set_ylabel("Verspätung in Minuten")
            ax.set_ylim(0, 26)
            ax.spines['top'].set_visible(False)
            ax.spines['right'].set_visible(False)

        def blank_route(ax, name, p_val):
            sig     = p_val < 0.05
            label   = "SIGNIFIKANT" if sig else "NICHT SIG."
            color_t = '#27ae60' if sig else '#c0392b'
            ax.set_title(f"{name}\n({label})", color=color_t,
                         fontweight='bold', fontsize=12, pad=15)
            ax.text(0.5, 0.45, "Rohdaten nicht\nbetrachtet.",
                    ha='center', va='center', fontsize=13, color='#95a5a6',
                    style='italic', transform=ax.transAxes)
            ax.set_facecolor('#f8f9fa')
            ax.set_xticks([])
            ax.set_yticks([])
            for spine in ax.spines.values():
                spine.set_visible(False)

        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))

        if mode == "ponly":
            blank_route(ax1, "München – Frankfurt", p_muc)
            blank_route(ax2, "Hamburg – Berlin",    p_hb)
        elif mode == "sig_only":
            if p_muc < 0.05:
                draw_route(ax1, old_muc, new_muc, "München – Frankfurt", p_muc, eff_muc, 99)
            else:
                blank_route(ax1, "München – Frankfurt", p_muc)
            if p_hb < 0.05:
                draw_route(ax2, old_hb, new_hb, "Hamburg – Berlin", p_hb, eff_hb, 88)
            else:
                blank_route(ax2, "Hamburg – Berlin", p_hb)
        else:
            draw_route(ax1, old_muc, new_muc, "München – Frankfurt", p_muc, eff_muc, 99)
            draw_route(ax2, old_hb,  new_hb,  "Hamburg – Berlin",    p_hb,  eff_hb,  88)

        fig.subplots_adjust(wspace=0.4, bottom=0.2, top=0.85, left=0.1, right=0.95)
        return fig

    @render.ui
    def verdict_panel():
        mode  = input.view_mode()
        sd_hb = input.sd_hb()
        old_hb, new_hb = get_hamburg_data(sd_hb)

        _, p_muc = ttest_ind(old_muc, new_muc)
        _, p_hb  = ttest_ind(old_hb,  new_hb)
        eff_muc  = np.mean(old_muc) - np.mean(new_muc)
        eff_hb   = np.mean(old_hb)  - np.mean(new_hb)

        c_muc = "#27ae60" if p_muc < 0.05 else "#c0392b"
        c_hb  = "#27ae60" if p_hb  < 0.05 else "#c0392b"

        same = (p_muc < 0.05) == (p_hb < 0.05)
        if same:
            msg       = "Beide Strecken kommen zum selben Urteil."
            msg_color = "#27ae60"
        else:
            if mode == "full":
                msg = (
                    f"Gegensätzliche Urteile! Beide Effekte sind ~{abs(eff_muc):.1f} Min "
                    f"und damit faktisch gleich groß. Allein die Streuung entscheidet."
                )
            else:
                msg = "Gegensätzliche Urteile — trotz faktisch gleichem Effekt."
            msg_color = "#c0392b"

        muc_detail = (f"Effekt {eff_muc:.1f} Min | p = {p_muc:.3f}"
                      if mode == "full" else f"p = {p_muc:.3f}")
        hb_detail  = (f"Effekt {eff_hb:.1f} Min | p = {p_hb:.3f}"
                      if mode == "full" else f"p = {p_hb:.3f}")

        return ui.div(
            ui.tags.p(
                ui.tags.span("München–Frankfurt: ", style="font-weight:bold;"),
                ui.tags.span(muc_detail, style=f"color:{c_muc}; font-weight:bold;"),
            ),
            ui.tags.p(
                ui.tags.span("Hamburg–Berlin: ", style="font-weight:bold;"),
                ui.tags.span(hb_detail, style=f"color:{c_hb}; font-weight:bold;"),
            ),
            ui.tags.hr(style="margin:8px 0;"),
            ui.tags.p(
                msg,
                style=f"color:{msg_color}; font-weight:bold; font-size:13px;"
            ),
            style="background:#f8f9fa; padding:12px; border-radius:8px; margin-top:8px;"
        )

app = App(app_ui, server)
```
