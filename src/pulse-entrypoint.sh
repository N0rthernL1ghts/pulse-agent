#!/usr/bin/env bash

main() {
    # Process docker secrets
    if ! bash /usr/local/bin/init-docker-secrets; then
        printf "Error occurred with init-docker-secrets\n"
        return 1
    fi

    # Load normalized secrets
    source /usr/local/lib/load-env /run/secrets_normalized

    # Start the agent
    printf "Pulse Agent %s\n\n" "${PULSE_VERSION}"
    exec /usr/local/bin/pulse-docker-agent -no-auto-update "$@"
}

main "$@"
