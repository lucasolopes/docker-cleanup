#!/bin/bash

# Carregar configurações do usuário
CONFIG_FILE="./config.env"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    RETENTION_DAYS_IMAGE=7
    RETENTION_DAYS_CONTAINER=7
    VOLUME_RETENTION_DAYS=7
    NETWORK_RETENTION_DAYS=7
fi

# Converter dias para segundos
RETENTION_SECONDS=$((RETENTION_DAYS * 86400))
CURRENT_TIME=$(date +%s)

echo "Executando limpeza Docker em $(date)" >> ./log_limpeza_docker.txt

# Remover contêineres parados há mais de X dias
docker container prune -f --filter "until=$((RETENTION_DAYS_CONTAINER * 24))h" > /dev/null 2>&1

# Remover imagens não utilizadas há mais de X dias
docker image prune -a -f --filter "until=$((RETENTION_DAYS_IMAGE * 24))h" > /dev/null 2>&1

# Remover volumes **não utilizados** há mais de X dias
for volume in $(docker volume ls -q --filter "dangling=true"); do
    CREATED_AT=$(docker volume inspect --format '{{.CreatedAt}}' "$volume" 2>/dev/null)

    if [ -z "$CREATED_AT" ]; then
        echo "Ignorando volume sem data de criação: $volume" >> ./log_limpeza_docker.txt
        continue
    fi

    CREATED_TIMESTAMP=$(date -d "$CREATED_AT" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "$CREATED_AT" +%s)

    if [ -n "$CREATED_TIMESTAMP" ] && [ $((CURRENT_TIME - CREATED_TIMESTAMP)) -gt $((VOLUME_RETENTION_DAYS * 86400)) ]; then
        echo "Removendo volume antigo: $volume" >> ./log_limpeza_docker.txt
        docker volume rm "$volume" > /dev/null 2>&1
    fi
done

# Remover redes **não utilizadas** há mais de X dias
for network in $(docker network ls -q --filter "dangling=true"); do
    CREATED_AT=$(docker network inspect --format '{{.CreatedAt}}' "$network" 2>/dev/null)

    if [ -z "$CREATED_AT" ]; then
        echo "Ignorando rede sem data de criação: $network" >> ./log_limpeza_docker.txt
        continue
    fi

    CREATED_TIMESTAMP=$(date -d "$CREATED_AT" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "$CREATED_AT" +%s)

    if [ -n "$CREATED_TIMESTAMP" ] && [ $((CURRENT_TIME - CREATED_TIMESTAMP)) -gt $((NETWORK_RETENTION_DAYS * 86400)) ]; then
        echo "Removendo rede antiga: $network" >> ./log_limpeza_docker.txt
        docker network rm "$network" > /dev/null 2>&1
    fi
done
