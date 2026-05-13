# test-github-actions
test github actions

# test docker build
```bash
docker build -t amveremes/test-github-actions .
```

# create release with goreleaser

Example :
```bash
git tag v0.1.22
git push origin v0.1.22
```

Start container :
```bash
docker run -d -p 5000:5000 ghcr.io/amveremes/test-github-actions:latest
```
