bundle := bundle

start: bundle
	${bundle} exec jekyll serve ${ARGS}

build: bundle
	JEKYLL_ENV=production ${bundle} exec jekyll build

bundle:
	${bundle}

docker-build:
	docker run --rm -t --volume="${PWD}:/srv/jekyll" --volume="${PWD}/vendor/bundle:/usr/local/bundle" --env JEKYLL_ENV=production jekyll/jekyll:3.8 jekyll build --trace

docker-run:
	docker run --rm --volume="${PWD}:/srv/jekyll" --volume="${PWD}/vendor/bundle:/usr/local/bundle" --env JEKYLL_ENV=development -p 4000:4000 jekyll/jekyll:3.8 jekyll serve