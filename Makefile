html:
	pykwiki cache -f

publish:
	git add -f docroot
	git subtree push --prefix docroot origin gh-pages
