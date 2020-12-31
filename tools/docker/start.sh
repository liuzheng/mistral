#!/bin/bash
set -e

# If a Mistral config doesn't exist we should create it and fill in with
# parameters
if [ ! -f ${CONFIG_FILE} ]; then
    oslo-config-generator \
      --config-file "${MISTRAL_DIR}/tools/config/config-generator.mistral.conf" \
      --output-file "${CONFIG_FILE}"
    INI_SET="crudini --set ${CONFIG_FILE}"

    ${INI_SET} DEFAULT js_implementation py_mini_racer
    ${INI_SET} DEFAULT auth_type ${DEFAULT.auth_type}
    ${INI_SET} DEFAULT transport_url "${DEFAULT.transport_url}"
    ${INI_SET} DEFAULT debug "${DEFAULT.debug}"

    ${INI_SET} pecan auth_enable ${pecan.auth_enable}

    ${INI_SET} keycloak_oidc auth_url ${keycloak_oidc.auth_url}
    ${INI_SET} keycloak_oidc insecure ${keycloak_oidc.insecure}

    ${INI_SET} database connection "${database.connection}"
    ${INI_SET} oslo_policy policy_file "${oslo_policy.policy_file}"
fi

if [ ${database.connection} == "sqlite:///data/mistral.db" -a ! -f /data/mistral.db ]
then
    python ./tools/sync_db.py --config-file "${CONFIG_FILE}"
    mistral-db-manage --config-file "${CONFIG_FILE}" populate
fi

if "${UPGRADE_DB}";
then
    /usr/local/bin/mistral-db-manage --config-file "${CONFIG_FILE}" upgrade head
    mistral-db-manage --config-file "${CONFIG_FILE}" populate
fi

mistral-server --config-file "${CONFIG_FILE}" --server ${MISTRAL_SERVER}
