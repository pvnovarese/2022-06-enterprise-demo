FROM xmrig/xmrig:latest AS xmrig

FROM registry.access.redhat.com/ubi8-minimal:latest

LABEL maintainer="pvn@novarese.net"
LABEL name="2022-06-enterprise-demo"
LABEL org.opencontainers.image.title="2022-06-enterprise-demo"
LABEL org.opencontainers.image.description="Simple image to test various policy rules with Anchore Enterprise."

HEALTHCHECK --timeout=10s CMD /bin/true || exit 1

##if you need to use the actual rpm rather than the hints file, use this COPY and comment out the other one
##COPY Dockerfile sudo-1.8.29-5.el8.x86_64.rpm ./ 
COPY anchore_hints.json log4j-core-2.14.1.jar /
COPY --from=xmrig /xmrig/xmrig /xmrig/xmrig


RUN set -ex && \
    echo "aws_access_key_id=01234567890123456789" > /aws_access && \
    echo "-----BEGIN OPENSSH PRIVATE KEY-----" > /ssh_key && \
    microdnf -y install ruby python3-devel python3 python3-pip nodejs shadow-utils tar gzip && \
    curl https://anchorectl-releases.s3-us-west-2.amazonaws.com/v0.2.0/anchorectl_0.2.0_linux_amd64.tar.gz | tar xzvf - -C /usr/local/bin/ && \
    adduser -d /xmrig mining && \
    pip3 install --index-url https://pypi.org/simple --no-cache-dir aiohttp==3.7.3 pytest urllib3 botocore six numpy && \
    gem install bundler lockbox:0.6.8 ftpd:0.2.1 && \
    npm install --cache /tmp/empty-cache debug chalk commander xmldom@0.4.0 && \
    npm cache clean --force && \
    microdnf -y clean all && \
    rm -rf /var/cache/yum /tmp 

## if using the actual rpm rather than the hints file, you need these: ##
##    yum -y install /sudo-1.8.29-5.el8.x86_64.rpm && \
##    rm -rf /sudo-1.8.29-5.el8.x86_64.rpm && \

## just to make sure we have a unique build each time
RUN date > /image_build_timestamp

USER mining
WORKDIR /xmrig
ENTRYPOINT /bin/false
