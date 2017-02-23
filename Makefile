html:
	pykwiki cache -f

publish: html
	ghp-import -p -b gh-pages docroot
