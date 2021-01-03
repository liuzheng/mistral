#!/bin/bash
set -e

# If a Mistral config doesn't exist we should create it and fill in with
# parameters
if [ ! -f ${CONFIG_FILE} ]; then
    oslo-config-generator \
      --config-file "${MISTRAL_DIR}/tools/config/config-generator.mistral.conf" \
      --output-file "${CONFIG_FILE}"
    INI_SET="crudini --set ${CONFIG_FILE}"

    ${INI_SET} DEFAULT js_implementation "v8eval"
    ${INI_SET} DEFAULT auth_type  "${DEFAULT__auth_type}"
    ${INI_SET} DEFAULT transport_url "${DEFAULT__transport_url}"
    ${INI_SET} DEFAULT debug "${DEFAULT__debug}"

    ${INI_SET} pecan auth_enable "${pecan__auth_enable}"

    ${INI_SET} keycloak_oidc auth_url "${keycloak_oidc__auth_url}"
    ${INI_SET} keycloak_oidc insecure "${keycloak_oidc__insecure}"

    ${INI_SET} database connection "${database__connection}"
    ${INI_SET} oslo_policy policy_file "${oslo_policy__policy_file}"
#    ${INI_SET} notification publishers "st2 = mistral.notifiers.publishers.webhook:WebhookPublisher"
fi

if [ "${database__connection}" == "sqlite:////data/mistral.db" -a ! -f /data/mistral.db ]
then
    mkdir -p /data/
    python ./tools/sync_db.py --config-file "${CONFIG_FILE}"
    mistral-db-manage --config-file "${CONFIG_FILE}" populate
fi

if "${UPGRADE_DB}";
then
    /usr/local/bin/mistral-db-manage --config-file "${CONFIG_FILE}" upgrade head
    mistral-db-manage --config-file "${CONFIG_FILE}" populate
fi

mistral-server --config-file "${CONFIG_FILE}" --server ${MISTRAL_SERVER}
