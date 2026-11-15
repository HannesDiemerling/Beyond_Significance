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

## Structure

- `index.md`: start page
- `chap1.qmd` to `chap6.qmd`: one chapter each; the app code sits in the
  `shinylive-python` block of the chapter
- `_quarto.yml`: site configuration and sidebar
- `styles.css`: navigation bar between chapters and workshops
- `.github/workflows/publish.yml`: build and deployment

## Build locally

The site is a [Quarto](https://quarto.org) website. The apps are written in
Python with Shiny and embedded with the Shinylive extension. The workflow
builds with Python 3.11.

```bash
pip install -r requirements.txt
quarto add quarto-ext/shinylive
quarto preview
```

`quarto render` writes the site to `_site/`. `quarto add` installs the
extension into `_extensions/`, which is not part of the repository.

Every push to `main` publishes the site to GitHub Pages.

## License

Code: MIT (see `LICENSE`). This repository states no separate license for the workshop texts.

## Author

Hannes Diemerling ([GitHub](https://github.com/HannesDiemerling), ORCID [0009-0002-6027-9181](https://orcid.org/0009-0002-6027-9181))
