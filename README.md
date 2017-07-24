# purduelug.org wiki

See [github.com/purduelug/purduelug.github.io](http://github.com/purduelug/purduelug.github.io) for the main site.

Do all work on the `source` branch.  The makefile will automatically push to `gh-pages`, where Github builds from.

## Dependencies
    pip install pelican pykwiki ghp-import

## Building and Publishing

Build wiki articles

    make html

Publish to github pages

    make publish
    
Use `git` as usual for managing wiki source content.
