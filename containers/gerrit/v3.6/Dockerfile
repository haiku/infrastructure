FROM docker.io/alpine:3.17

MAINTAINER Haiku, Inc <haiku-inc@gmail.com>

# Overridable defaults
ENV GERRIT_HOME /var/gerrit
ENV GERRIT_PLUGIN_BUNDLE ${GERRIT_HOME}/bundled_plugins
ENV GERRIT_SITE ${GERRIT_HOME}/review_site
ENV GERRIT_WAR ${GERRIT_HOME}/gerrit.war
ENV GERRIT_BRANCH 3.6
ENV GERRIT_VERSION 3.6.3
ENV GERRIT_USER gerrit2
ENV GERRIT_INIT_ARGS "--install-plugin=download-commands"
ENV INTERNAL_PLUGINS="plugin-manager hooks"
ENV EXTERNAL_PLUGINS="account avatars-gravatar events-log oauth admin-console healthcheck"

# Add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN adduser -D -h "${GERRIT_HOME}" -g "Gerrit User" -s /sbin/nologin "${GERRIT_USER}"

RUN set -x \
    && apk add --update --no-cache git openssh openssl bash \
	    perl perl-cgi perl-libwww perl-lwp-protocol-https git-gitweb curl su-exec \
		openjdk17 openjdk17-jdk openjdk17-jre openjdk17-jre-headless 

RUN mkdir /docker-entrypoint-init.d && mkdir -p ${GERRIT_PLUGIN_BUNDLE}

#Download gerrit.war
RUN curl -fSsL https://gerrit-releases.storage.googleapis.com/gerrit-${GERRIT_VERSION}.war -o $GERRIT_WAR

# Extract any internal plugins (Thanks Nix OS for the idea!)
RUN for i in ${INTERNAL_PLUGINS}; do \
	echo "Install $i..."; \
	java -jar $GERRIT_WAR cat plugins/$i.jar > ${GERRIT_PLUGIN_BUNDLE}/$i.jar; \
	done;

# Download plugins bazel-master-stable-*
ENV GERRITFORGE_URL=https://gerrit-ci.gerritforge.com
ENV GERRITFORGE_ARTIFACT_DIR=lastSuccessfulBuild/artifact/bazel-bin/plugins
ENV PLUGIN_VERSION=bazel-master-stable-${GERRIT_BRANCH}
RUN for i in ${EXTERNAL_PLUGINS}; do \
	echo "Install $i..." \
	wget ${GERRITFORGE_URL}/job/plugin-$i-${PLUGIN_VERSION}/${GERRITFORGE_ARTIFACT_DIR}/$i/$i.jar \
		-O ${GERRIT_PLUGIN_BUNDLE}/$i.jar; \
	done;

# Ensure the entrypoint scripts are in a fixed location
COPY gerrit-entrypoint.sh /
COPY gerrit-start.sh /
RUN chmod +x /gerrit*.sh

#A directory has to be created before a volume is mounted to it.
#So gerrit user can own this directory.
RUN su-exec ${GERRIT_USER} mkdir -p $GERRIT_SITE

# Check for healthy backend web service
HEALTHCHECK --start-period=10m CMD curl --fail http://`hostname`:8080/ || exit 1

#Gerrit site directory is a volume, so configuration and repositories
#can be persisted and survive image upgrades.
VOLUME $GERRIT_SITE

ENTRYPOINT ["/gerrit-entrypoint.sh"]

EXPOSE 8080 29418

CMD ["/gerrit-start.sh"]
