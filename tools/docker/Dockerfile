FROM krallin/ubuntu-tini:16.04

MAINTAINER Andras Kovi <akovi@nokia.com>

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
      mc \
      python-dev \
      python-pip \
      python-setuptools \
      swig \
      cmake \
      crudini \
      libuv1 \
      libuv1-dev \
      libmysqlclient-dev libpq-dev

RUN pip install -U pip

#RUN pip install -v v8eval mysql-python && python -c 'import v8eval'
RUN pip install -v mysql-python tox python-mistralclient v8eval #-i https://mirrors.aliyun.com/pypi/simple/
###  note: js_implementation in mistral use py_mini_racer or pyv8 or v8eval
###        it can be find in https://docs.openstack.org/mistral/latest/user/wf_lang_v2.html

COPY . /opt/stack/mistral

#RUN curl -o /tmp/upper-constraints.txt http://git.openstack.org/cgit/openstack/requirements/plain/upper-constraints.txt && \
#    sed -i '/^mistral.*/d' /tmp/upper-constraints.txt &&\
#    pip install -e /opt/stack/mistral
RUN pip install -e /opt/stack/mistral

RUN mkdir -p /etc/mistral

RUN oslo-config-generator \
      --config-file /opt/stack/mistral/tools/config/config-generator.mistral.conf \
      --output-file /etc/mistral/mistral.conf

RUN INI_SET="crudini --set /etc/mistral/mistral.conf" && \
    $INI_SET DEFAULT js_implementation v8eval && \
    $INI_SET DEFAULT transport_url rabbit://guest:guest@rabbitmq:5672/ && \
    $INI_SET database connection sqlite:///data/mistral.db && \
    $INI_SET oslo_policy policy_file /opt/stack/mistral/etc/policy.json && \
    $INI_SET pecan auth_enable false

EXPOSE 8989

CMD mistral-server --server all
