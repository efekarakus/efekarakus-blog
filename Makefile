bundle := bundle

start: bundle
	${bundle} exec jekyll serve

build: bundle
	JEKYLL_ENV=production jekyll build

bundle:
	${bundle}