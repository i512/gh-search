# README

A simple rails app for searching github repos.

```bash
git clone git@github.com:i512/gh-search.git
cd gh-search
bundle
# optional: set an access token for increased rate limits
export GITHUB_ACCESS_TOKEN="..."
rails server

open http://localhost:3000
```

TODO:
* Add Dockerfile and docker-compose.yml