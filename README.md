# cloud-platform-hawkeye
Repo scanner for misplaced secrets

This borrows ideas and code from [gitleaks](https://github.com/zricethezav/gitleaks) and [hawkeye](https://github.com/Stono/hawkeye); the resulting Docker image is pushed to https://hub.docker.com/r/razvanmoj/cloud-platform-hawkeye/
To run, a read-only API key with access to the needed org repos is needed, then
```
$ docker pull razvanmoj/cloud-platform-hawkeye
$ docker run --rm -v $PWD/target:/target razvanmoj/cloud-platform-hawkeye --token 'aaabbb' --user 'ghusername' --filter 'regexp' 2>&1 | tee target/report.txt
```
All the readable org repos will be cloned in `$PWD/target` ; do note that for now the scanner **only checks the HEAD of the master branch**. A [sample report](sample-report.txt) is attached.
