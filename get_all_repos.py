#!/usr/bin/python3 -u

import os, sys, argparse, re
from github import Github
from subprocess import check_call, CalledProcessError, DEVNULL

def main():
    parser = argparse.ArgumentParser(description='Find secrets hidden in the depths of git.')
    parser.add_argument("--token", dest="token", help="GH access token", required=True)
    parser.add_argument("--user", dest="user", help="GH username", required=True)
    parser.add_argument("--filter", dest="filter", help="only scan repos matching")
    parser.set_defaults(filter='.*')
    args = parser.parse_args()

    g = Github(args.token)
    with open(os.path.expanduser("~/.netrc"), "a") as netrc:
        netrc.write("login "+args.user+"\n"+"password "+args.token)
    p = re.compile(args.filter, re.I)
    for repo in g.get_user().get_repos(type='all'):
        if p.search(repo.name) and repo.organization is not None:
            print("Scanning "+repo.organization.name+"/"+repo.name)
            try:
                check_call(['hub','clone',repo.html_url], stdout=DEVNULL, stderr=DEVNULL)
            except CalledProcessError:
                try:
                    check_call(['hub','fetch'], cwd=repo.name, stderr=DEVNULL)
                except (CalledProcessError, FileNotFoundError):
                    print("Could not scan "+repo.name+", `hub fetch` failed")
            try:
                check_call(['hawkeye','scan','-t','/target/'+repo.name], stdout=DEVNULL)
            except CalledProcessError:
                print("Could not scan "+repo.name+", `hawkeye scan` failed")


if __name__ == "__main__":
    main()
