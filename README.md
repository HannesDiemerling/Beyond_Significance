# Beyond Significance: praktische Relevanz von Effekten

Interactive, self-paced workshop on effect sizes and practical relevance, in German.
Workshop 01 of the [Beyond p-values](https://hannesdiemerling.github.io/Frequent-Reformation/) series.

**Start the workshop:** https://hannesdiemerling.github.io/Beyond_Significance/

Every chapter combines a short explanation with an app that runs in the
browser. No installation is needed.

| Chapter | Topic |
|---|---|
| 1 | Fehlinterpretationen und binäres Denken (misinterpretations and binary thinking) |
| 2 | p Wert und Stichprobengröße (p value and sample size) |
| 3 | Unstandardisierte Effekte (unstandardized effects) |
| 4 | Standardisierte Effektgrößen (standardized effect sizes) |
| 5 | Praktische Bedeutsamkeit (practical significance) |
| 6 | Publikationsbias (publication bias) |

## Build locally

The site is a [Quarto](https://quarto.org) website. The apps are written in
Python with Shiny and embedded with the Shinylive extension.

```bash
pip install -r requirements.txt
quarto add quarto-ext/shinylive
quarto preview
```

Every push to `main` publishes the site to GitHub Pages.

## License

MIT
