# 基础镜像
FROM centos:centos8

# 参数
ARG JDK_PKG
ARG WEBLOGIC_JAR

# 基础环境设置
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo \
    && sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo \
    && yum makecache \
    && yum -y install libnsl \
    && groupadd -g 1000 oinstall && useradd -u 1100 -g oinstall oracle \
    && mkdir -p /install && mkdir -p /scripts

# 复制脚本
COPY ./scripts /scripts/
COPY jdks/$JDK_PKG .
COPY weblogics/$WEBLOGIC_JAR .

# 判断jdk是包（bin/tar.gz）weblogic包（11g/12c）载入对应脚本
RUN if [ $JDK_PKG == *.bin ] ; then echo ****载入JDK bin安装脚本**** && cp /scripts/jdk_bin_install.sh /scripts/jdk_install.sh ; else echo ****载入JDK tar.gz安装脚本**** ; fi \
    && if [ $WEBLOGIC_JAR == *1036* ] ; then echo ****载入11g安装脚本**** && cp /scripts/weblogic_install11g.sh /scripts/weblogic_install.sh && cp /scripts/create_domain11g.sh /scripts/create_domain.sh ; else echo ****载入12c安装脚本**** && cp /scripts/weblogic_install12c.sh /scripts/weblogic_install.sh && cp /scripts/create_domain12c.sh /scripts/create_domain.sh  ; fi \
    && chmod +x /scripts/*.sh

# 安装
RUN /scripts/jdk_install.sh \
    && /scripts/weblogic_install.sh \
    && /scripts/create_domain.sh \
    && /scripts/open_debug_mode.sh


EXPOSE 7001

# 启动 Weblogic Server
# CMD ["tail","-f","/dev/null"]
CMD ["/u01/app/oracle/Domains/ExampleSilentWTDomain/bin/startWebLogic.sh"]
