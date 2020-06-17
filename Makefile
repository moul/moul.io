.PHONY: build
build:
	rm -rf public
	cp -rf docs public
	./gen.sh
	@echo "Done. in ./public/"

.PHONY: dev
dev: build
	netlify dev
