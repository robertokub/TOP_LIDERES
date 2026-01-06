Chave pública SSH adicionada neste repositório.

Arquivo:
- `deploy_keys/u804807903_br-asc-web723.pub`

Uso recomendado:
- Para autorizar a chave em um servidor, copie o conteúdo do arquivo e adicione a `authorized_keys` do usuário remoto:

  cat deploy_keys/u804807903_br-asc-web723.pub >> ~/.ssh/authorized_keys

- Alternativamente, adicione o arquivo como "deploy key" no provedor Git/CI que você usa.

Aviso:
- Não compartilhe chaves privadas neste repositório. Este arquivo contém somente a chave pública.
