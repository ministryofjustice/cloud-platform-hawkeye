# cloud-platform-hawkeye
Repo scanner for misplaced secrets

This borrows ideas and code from [gitleaks](https://github.com/zricethezav/gitleaks) and [hawkeye](https://github.com/Stono/hawkeye); the resulting Docker image is pushed to https://hub.docker.com/r/razvanmoj/cloud-platform-hawkeye/
To run, a read-only API key with access to the needed org repos is needed, then
```
$ docker pull razvanmoj/cloud-platform-hawkeye
$ docker run --rm -v $PWD:/target razvanmoj/cloud-platform-hawkeye
```
All the readable org repos will be shallow cloned (only master HEAD) in `$PWD` and the scan resulst saved as report.txt
