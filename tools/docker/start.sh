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
    ${INI_SET} DEFAULT auth_type  "$(perl -e 'print $ENV{"DEFAULT.auth_type"}')"
    ${INI_SET} DEFAULT transport_url "$(perl -e 'print $ENV{"DEFAULT.transport_url"}')"
    ${INI_SET} DEFAULT debug $(perl -e 'print $ENV{"DEFAULT.debug"}')

    ${INI_SET} pecan auth_enable $(perl -e 'print $ENV{"pecan.auth_enable"}')

    ${INI_SET} keycloak_oidc auth_url "$(perl -e 'print $ENV{"keycloak_oidc.auth_url"}')"
    ${INI_SET} keycloak_oidc insecure $(perl -e 'print $ENV{"keycloak_oidc.insecure"}')

    ${INI_SET} database connection "$(perl -e 'print $ENV{"database.connection"}')"
    ${INI_SET} oslo_policy policy_file "$(perl -e 'print $ENV{"oslo_policy.policy_file"}')"
fi

if [ "$(perl -e 'print $ENV{"database.connection"}')" == "sqlite:////data/mistral.db" -a ! -f /data/mistral.db ]
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
