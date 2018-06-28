FROM centos:7
MAINTAINER Razvan Cosma <razvan.cosma@digital.justice.gov.uk>

ENV LANG=en_US.utf-8
ENV LC_ALL=en_US.utf-8

RUN yum -y -q update && yum -y -q install epel-release && yum -y -q update
RUN yum -y -q remove iputils && \
    yum -y -q install wget openssl openssl-devel tar unzip \
							libffi-devel python34-devel python34-pip redhat-rpm-config git-core \
							gcc gcc-c++ make zlib-devel pcre-devel ca-certificates \
              ruby rubygems java-1.8.0-openjdk.x86_64 which && \
    yum -y -q clean all

# Git-crypt
RUN cd /tmp && \
    wget -q https://www.agwa.name/projects/git-crypt/downloads/git-crypt-0.6.0.tar.gz && \
    tar xzf git-crypt* && \
    cd git-crypt* && \
    make && \
    make install && \
    rm -rf /tmp/git-crypt*

ENV NPM_VERSION=5.10.0

# Get nodejs repos
RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -

RUN yum -y install nodejs && \
    yum -y clean all

RUN rm -rf /usr/lib/node_modules/npm && \
    mkdir /usr/lib/node_modules/npm && \
    curl -sL https://github.com/npm/npm/archive/v$NPM_VERSION.tar.gz | tar xz -C /usr/lib/node_modules/npm --strip-components=1

RUN node --version && \
    npm --version

# If we ever change the hawkeye version, redo everything below
ARG HE_VERSION=

# If we have changed the hawkeye version, do an update
RUN yum -y -q update && \
    yum -y -q clean all

# Install python-pip
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN python3 get-pip.py

# Add bundler-audit
RUN gem install bundler-audit brakeman
RUN bundle-audit update

# Add safety, piprot, bandit
RUN pip3 install safety piprot bandit

# Add FindSecBugs
RUN mkdir /usr/local/bin/findsecbugs && \
    cd /usr/local/bin/findsecbugs && \
    wget -q -O findsecbugs-cli.zip https://github.com/find-sec-bugs/find-sec-bugs/releases/download/version-1.7.1/findsecbugs-cli-1.7.1.zip && \
    unzip -q findsecbugs-cli.zip && \
    chmod +x /usr/local/bin/findsecbugs/findsecbugs.sh && \
    rm findsecbugs-cli.zip && \
    mv findsecbugs.sh findsecbugs

ENV PATH=/usr/local/bin/findsecbugs:$PATH

#Add Owasp Dependency Check
ARG OWASP_DEP_FOLDER=/usr/local/bin/owaspdependency
RUN mkdir $OWASP_DEP_FOLDER && cd $OWASP_DEP_FOLDER && \
    wget -q -O dependency-check.zip http://dl.bintray.com/jeremy-long/owasp/dependency-check-3.2.1-release.zip && \
    unzip -q dependency-check.zip && \
    chmod +x $OWASP_DEP_FOLDER/dependency-check/bin/dependency-check.sh && \
    rm dependency-check.zip && \
    mv dependency-check/bin/dependency-check.sh dependency-check/bin/dependency-check

ENV PATH=$OWASP_DEP_FOLDER/dependency-check/bin:$PATH

RUN pip3 install pygithub
RUN rpm -U http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm && \
    yum install -y git
RUN wget -q https://github.com/github/hub/releases/download/v2.4.0/hub-linux-amd64-2.4.0.tgz && \
    tar xzf hub-linux*tgz && mv hub-linux*/bin/hub /usr/local/bin/ && rm -fr hub-linux*
RUN git config --global hub.protocol https

# Install hawkeye
RUN mkdir -p /hawkeye
COPY ./hawkeye/package.json /hawkeye/
RUN cd /hawkeye && \
    npm install --production --quiet
COPY ./hawkeye /hawkeye

ENV PATH=/hawkeye/bin:$PATH

# will add org logic here
RUN echo "machine github.com" > ~/.netrc
COPY get_all_repos.py /hawkeye/

WORKDIR /target
ENTRYPOINT ["/hawkeye/get_all_repos.py"]
