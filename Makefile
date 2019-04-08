bundle := bundle

start: bundle
	${bundle} exec jekyll serve

build: bundle
	JEKYLL_ENV=production ${bundle} exec jekyll build

bundle:
	${bundle}
