FROM --platform=${TARGETPLATFORM} liferay/jdk11-jdk8:latest AS liferay-jdk11-jdk8

COPY resources/etc/created-date /etc/created-date

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install --no-install-recommends --yes cron gettext gosu && \
	apt-get clean

# create job_runner group and user
RUN groupadd -r job_runner && useradd --no-log-init -r -g job_runner job_runner

RUN mkdir -p /opt/liferay/job-queue
RUN chown -R job_runner:job_runner /opt/liferay/job-queue
RUN chmod -R 775 /opt/liferay/job-queue

RUN echo "root" > /etc/cron.allow && \
    echo "job_runner" >> /etc/cron.allow && \
    chmod 0644 /etc/cron.allow

FROM liferay-jdk11-jdk8

ARG LABEL_BUILD_DATE
ARG LABEL_NAME
ARG LABEL_VCS_REF
ARG LABEL_VCS_URL
ARG LABEL_VERSION
ARG TARGETPLATFORM

COPY resources/ /

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

ENV LANG="C.UTF-8"

LABEL org.label-schema.build-date="${LABEL_BUILD_DATE}"
LABEL org.label-schema.name="${LABEL_NAME}"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.vcs-ref="${LABEL_VCS_REF}"
LABEL org.label-schema.vcs-url="${LABEL_VCS_URL}"
LABEL org.label-schema.vendor="Liferay, Inc."
LABEL org.label-schema.version="${LABEL_VERSION}"

WORKDIR /opt/liferay