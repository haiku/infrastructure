# cgit for Haiku

This cgit container runs nginx and allows users
to navigate git repositories attached via a volume at /var/git.

## Requirements

The volume attached at /var/git needs:

  * A bunch of git repos.
  * A file named 'repos' with cgit configuration directives for each repo.
```
repo.url=haiku
repo.path=/var/git/haiku.git
repo.desc=All glory to Haiku
```
