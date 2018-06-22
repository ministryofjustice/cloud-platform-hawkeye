#!/usr/bin/env python3

import argparse, os, sys
from github import Github
from subprocess import check_call, CalledProcessError
import json

def main():
    parser = argparse.ArgumentParser(description='Find secrets hidden in the depths of git.')
    parser.add_argument("--token", dest="token", help="access token")
    parser.add_argument("--filter", dest="filter", help="only scan repos matching")
    parser.set_defaults(filter="cloud-platform")
    parser.set_defaults(token=None)
    args = parser.parse_args()

    g = Github(args.token)
    for repo in g.get_user().get_repos():
        if args.filter in repo.name and repo.organization is not None:
            try:
                check_call(['git','clone','--depth','1',repo.clone_url])
            except CalledProcessError:                
                pass
            try:
                check_call(['hawkeye','scan','-t','/target/'+repo.name,'-j',repo.name+'.json'])
            except CalledProcessError:
                pass

    

if __name__ == "__main__":
    main()
