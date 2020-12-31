FROM krallin/ubuntu-tini:16.04

MAINTAINER liuzheng <liuzheng712@gmail.com>

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get -qq update && \
    apt-get install -y  \
      curl \
      git \
      libffi-dev \
      libssl-dev \
      libxml2-dev \
      libxslt1-dev \
      libyaml-dev \
      python \
      python-dev \
      python-pip \
      python-setuptools \
      swig \
      cmake \
      crudini \
      gcc \
      libuv1 \
      libuv1-dev \
      libmysqlclient-dev libpq-dev && \
      pip install -U pip

RUN pip install -v mysql-python tox python-mistralclient py_mini_racer -i https://mirrors.aliyun.com/pypi/simple/
###  note: js_implementation in mistral use py_mini_racer or pyv8 or v8eval
###        it can be find in https://docs.openstack.org/mistral/latest/user/wf_lang_v2.html

COPY requirements.txt "${MISTRAL_DIR}/"
#RUN curl -o "${TMP_CONSTRAINTS}" \
#    http://opendev.org/openstack/requirements/raw/branch/master/upper-constraints.txt && \
#    sed -i "/^mistral.*/d" "${TMP_CONSTRAINTS}" && \
#    pip install -r "${MISTRAL_DIR}/requirements.txt" -i https://mirrors.aliyun.com/pypi/simple/
RUN pip install -r "${MISTRAL_DIR}/requirements.txt" -i https://mirrors.aliyun.com/pypi/simple/

COPY . /opt/stack/mistral

RUN mkdir -p /etc/mistral && \
    pip install -e /opt/stack/mistral -i https://mirrors.aliyun.com/pypi/simple/ && \
    find ${MISTRAL_DIR} -name "*.sh" -exec chmod +x {} \;

ENV MISTRAL_DIR="/opt/stack/mistral" \
    TMP_CONSTRAINTS="/tmp/upper-constraints.txt" \
    CONFIG_FILE="/etc/mistral/mistral.conf" \
    UPGRADE_DB="false" \
    DEBIAN_FRONTEND="noninteractive" \
    MISTRAL_SERVER="all" \
    DEFAULT.transport_url="rabbit://guest:guest@rabbitmq:5672/" \
    DEFAULT.debug="false" \
    DEFAULT.auth_type="keycloak-oidc" \
    database.connection="sqlite:///data/mistral.db" \
    keycloak_oidc.auth_url="http://keycloak:8080/auth" \
    keycloak_oidc.insecure=true \
    pecan.auth_enable="false" \
    oslo_policy.policy_file=/opt/stack/mistral/etc/policy.json

WORKDIR "${MISTRAL_DIR}"
EXPOSE 8989
CMD "${MISTRAL_DIR}/tools/docker/start.sh"
