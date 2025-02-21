# Guia de Uso: Cleanup Docker Script

Este script realiza a limpeza automática de contêineres, imagens, volumes e redes não utilizados do Docker.

## Instalação

1. Clone o repositório:
   ```bash
   git clone https://github.com/lucasolopes/docker-cleanup.git
   cd docker-cleanup
   ```
2. Dê permissão de execução ao script:
   ```bash
   chmod +x cleanup_docker.sh
   ```

## Configuração

O script pode utilizar um arquivo `.env` para definir os períodos de retenção. Crie um arquivo `config.env` no diretório do script e defina as variáveis:
   ```bash
   RETENTION_DAYS_IMAGE=7
   RETENTION_DAYS_CONTAINER=7
   VOLUME_RETENTION_DAYS=7
   NETWORK_RETENTION_DAYS=7
   ```
Se o arquivo `config.env` não for encontrado, os valores padrão (7 dias) serão utilizados.

## Uso Manual

Para executar o script manualmente, utilize:
```bash
./cleanup_docker.sh
```

## Execução Automática no Shell (`.bashrc` ou `.zshrc`)

Para carregar o script automaticamente sempre que abrir um terminal, adicione a seguinte linha ao final do seu arquivo `~/.bashrc` ou `~/.zshrc`:
```bash
source {path}/cleanup_docker.sh
```
Substitua `{path}` pelo caminho absoluto onde o script está localizado.

Após adicionar, aplique as mudanças com:
```bash
source ~/.bashrc   # Para Bash
source ~/.zshrc    # Para Zsh
```

Agora, o script será carregado automaticamente! 🚀
