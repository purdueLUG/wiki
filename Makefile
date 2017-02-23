html:
	pykwiki cache -f

push:
	git add docroot
	git commit -m "*"
	git subtree push --prefix docroot origin gh-pages
