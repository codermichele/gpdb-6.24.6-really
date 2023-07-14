FROM ubuntu:18.04

COPY ./ /gpdb_src/

WORKDIR /
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/usr-local.conf \
&& ldconfig

RUN chmod +x gpdb_src/greenplum-oss/sysconf.bash \
&& gpdb_src/greenplum-oss/sysconf.bash \
&& cd gpdb_src/greenplum-oss/openssh-7.9p1 \
&& autoconf \
&& autoheader \
&& ./configure --sysconfdir=/etc/ssh \
&& make \
&& make install \
&& echo "sshd:x:1200:1200:/var/run/sshd:/usr/sbin/nologin" >> /etc/passwd \
&& cd / \
&& chmod +x gpdb_src/concourse/scripts/setup_gpadmin_user.bash \
&& gpdb_src/concourse/scripts/setup_gpadmin_user.bash

WORKDIR /gpdb_src/gp-xerces-3.1.2-p1
RUN mkdir build \
&& cd build \
&& ../configure --prefix=/usr/local \
&& make -j8 \
&& make -j8 install

WORKDIR /gpdb_src

# Configure build environment to install at /usr/local/gpdb
RUN ./configure --with-perl --with-python --with-libxml --with-gssapi --prefix=/usr/local/greenplum-db \
&& make -j8 \
&& make -j8 install
