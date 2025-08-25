<!-- BACK TO TOP ANCHOR -->

<a id="readme-top"></a>

## Provisionando um cluster de Kubernetes local

Um estudo de caso sobre a implementação de um cluster Kubernetes local para desenvolvimento local.

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Índice</summary>
  <ol>
    <li><a href="#objetivo">Objetivo</a></li>
    <li><a href="#escopo">Escopo</a></li>
    <li><a href="#tecnologias">Tecnologias</a></li>
    <li>
      <a href="#arquitetura">Arquitetura</a>
      <ul>
        <li><a href="#repositório">Repositório</a></li>
        <li><a href="#registro-de-imagens">Registro de Imagens</a></li>
        <li><a href="#cluster-kubernetes">Cluster Kubernetes</a></li>
        <li><a href="#ci/cd">CI/CD</a></li>
        <li><a href="#monitoramento-e-observabilidade">Monitoramento e Observabilidade</a></li>
        <li><a href="#segurança">Segurança</a></li>
      </ul>
    </li>
    <li>
      <a href="#requisitos">Requisitos</a>
        <ul>
          <li><a href="#hardware">Hardware</a></li>
          <li><a href="#software">Software</a></li>
        </ul>
    </li>
    <li>
      <a href="#utilização">Utilização</a>
        <ul>
          <li><a href="#primeiro-deploy">Primeiro deploy</a></li>
          <li><a href="#deploys-automáticos">Deploys automáticos</a></li>
          <li><a href="#destruindo-infraestrutura">Destruindo infraestrutura</a></li>
        </ul>
    </li>
    <li><a href="#advertências">Advertências</a></li>
    <li><a href="#licença">Licença</a></li>
    <li><a href="#referências">Referências</a></li>
    <li><a href="#reconhecimentos">Reconhecimentos</a></li>
  </ol>
</details>

## Objetivo
Este documento descreve todo o processo de planejamento e implementação de um cluster Kubernetes local para testes e desenvolvimento, detalhando os requisitos de hardware e software, escolhas de tecnologias, deploy de recursos, procedimentos de operação e advertências refrente ao uso do repositório.

## Escopo
O cluster será utilizado em ambiente local GNU/Linux, com foco em desenvolvimento ágil de aplicações. Devido a natureza das tecnologias escolhidas, o provisionamento da infraestrutura é leve e rápido.

## Tecnologias
Estas tecnologias foram selecionados pela modularidade e por serem "fracamente acopladas", ou seja, podem ser substituidas sem gerar muitos problemas.

- *Sistema operacional* **Debian GNU/Linux**: É reconhecido por sua estabilidade e segurança, ideal para servidores e sistemas críticos.
- *Container runtime* **Docker**: A escolha princiapl para trabalhos que envolvem containers, uma das maioridas ferramentas do mercado.
- *Kubernetes CLI*: **kubectl**: Essencial para interações diretas com o cluster kubernetes, local ou não.
- ⚠️ *Kubernetes distribution* **kind**: A escolha mais importante do projeto, kind (kubenernetes in docker):
  - Utiliza containers para rodar os nodes ao invés de VMs dedicadas.
  - Permite múltiplos clusters em paralelo sem depender de VMs.
  - Muito usado em pipelines de CI/CD e testes locais.
- *Kubernetes package manager* **Helm**: Facilita a instalação e manutenção de packages no cluster, como ingress, monitoramento e bancos de dados.
- *Infrastructure as code* **Terraform**: De modo declarativo, provisiona toda a infraestrutura necessária, desde o registro de container local, o cluster kubernetes, volumes, etc.
- *Node Version Manager* **nvm**: Facilita a instalação e gerenciamentos de mútiplas versões do NodeJS.
- *Javascript Runtime* **NodeJS**: Necessário para executar arquivos JavaScript.
- *Node Package Manager*: **pnpm**: Utilizado para gerenciar pacotes node, utilizado n lugar do `npm` pois:
  - Tem instalações mais rápidas que o `npm`;
  - Cache global evita duplicação de pacotes;
  - Dependências compartilhadas via links simbólicos, sem múltiplas cópias;
  - Controle mais rígido de versões, reduzindo conflitos;
  - Suporte a monorepos nativo com os `workspaces`, ideal para grandes projetos com múltiplos pacotes.
- *Build tool* **Nx**: Responsável por organizar o monorepo e executar comandos, ideal para monorepos pois dispoẽm de:
  - Cache inteligente que acelera builds e testes
  - Análises gráficas de dependências entre projetos
  - Suporte integrado a várias tecnologias (React, Angular, Node, Java, etc.)
  - Ferramentas para modularidade e reuso de código
  - Forte integração com CI/CD
  - Comunidade ativa e manutenção constante
- *Commit linting* **Husky & commitlint**: Mantém um padrão semântico nos commits, mesmo nos locais.
- *Java Development Kit* **JDK**: Necessário para o desenvolvimento e utilização de aplicações Java.
- *Java Native Image compilation* **GraalVM**: Compila código para binários nativos, reduzindo tempo de inicialização e consumo de memória.

## Arquitetura

### Repositório

- Utiliza pnpm workspace como solução de monorepo, múltiplas aplicações em um único repositório;
- Builds e scripts que geram artefatos são gerenciados pelo Nx;
- Linting de commits via Husky e commitlint;
- Instalação inicial de infraestrutura via shell script.
- Deploy inicial de aplicações via shell script.

### Registro de imagens

- Local, com volume criado para disponibilizar imagens no host caso necessário;
- Utiliza imagem dedicada do Docker `registry:2`, pŕopria para registros locais;
- Conecta-se a rede Docker `kind` para que o cluster kubernetes possa fazer o `pull` das imagens;

### Cluster Kubernetes

- Local, múltiplos nodes;
  - 1 control-plane;
  - 1 worker reserva para tarefas gerais;
  - 1 worker dedicado para aplicações;
  - 1 worker dedicado para ingress.
- 2 custom namespaces
  - des: para desenvolvimento e teste das aplicações;
  - prd: para aplicações em produção;
- Instalação de pacotes via `Helm`;
- `nginx-ingress` como ingress controller para roteamento HTTP local;
- Conexão com registro de imagens via rede Docker `kind`.

### CI/CD

*Em construção...*

### Monitoramento e Observabilidade

*Em construção...*

### Segurança

*Em construção...*

## Requisitos

### Hardware
Mínimo e recomendado ([de acordo com sistema o operacional escolhido][debian-requirements-url])
- CPU: 1 GHz
- RAM: 1 ~ 2GB
- Armazenamento: 10 ~ 20GB

### Software
Os métodos de instalação estão disponíveis nas documentações de cada ferramenta, apenas detalhes pontuais serão inseridos aqui.
- Sistema operacional: **Debian GNU/Linux 12**
  - [Instalação][debian-install-url]
  - *Outras distribuições de linux podem instalar as ferramentas necessárias de formas alternativas, verifique a documentaçào de cada ferramenta.*
- Container runtime: **Docker ≥ 28.3.3**
  - [Instalação][docker-install-url]
  - O daemon  do Docker sempre roda no user `root`, para evitar o uso de `sudo`, [adicione o usuário no grupo Docker][docker-install-root-url].
  - Algumas distribuições de linux utilizam `systemd` para gerenciar serviços e talvez o Docker não inicie automaticamente no boot. Você pode [configurar esse compartamento][docker-install-boot-url].
  - Utilize o comando `docker run hello-world` para verificar se a instalação foi bem sucedida.
- Kubernetes CLI: **kubectl ≥ 1.33.3**
  - [Instalação][kubectl-install-url]
  - Utilize o comando `kubectl version` para verificar se a instalação foi bem sucedida.
- Kubernetes distribution: **kind ≥ 0.29.0**
  - [Instalação][kind-install-url]
  - Importante lembrar de ter o executável no `PATH` do sistema, para poder invocar comandos com `kind`.
  - Utilize o comando `kind version` para verificar se a instalação foi bem sucedida.
- Kubernetes package manager: **Helm ≥ 3.18.5**
  - [Instalação][helm-install-url]
  - Importante lembrar de ter o executável no `PATH` do sistema, para poder invocar comandos com `helm`.
  - Utilize o comando `helm version` para verificar se a instalação foi bem sucedida.
- Infrastructure as code: **Terraform ≥ 1.13.0**
  - [Instalação][terraform-install-url]
  - Utilize o comando `terraform version` para verificar se a instalação foi bem sucedida.
- **(Opcional)** Node Version Manager: **nvm ≥ 0.40.3**
  - [Instalação][nvm-install-url]
  - Utilize o comando `nvm --version` para verificar se a instalação foi bem sucedida.
- Javascript Runtime: **NodeJS ≥ 22.18.0**
  - Caso tenha instalado o `nvm`, você pode usar o comando `nvm install 22.18.0`
  - Ou faça a [Instalação][node-install-url] dos binários manualmente *(é fortemente recomendado utilizar o `nvm`)*
  - Utilize o comando `node --version` para verificar se a instalação foi bem sucedida.
- Node Package Manager: **pnpm ≥ 10.15.0**
  - [Instalação][pnpm-install-url]
  - Caso não deseje instalar os binários diretamente, você pode utilizar o `npm` *(instalado juntamente do node)* com `npm install -g pnpm@10.15.0`
  - Utilize o comando `pnpm --version` para verificar se a instalação foi bem sucedida.
- Java Development Kit: **JDK ≥ 21.0.8**
  - [Instalação][java-install-url]
  - Utilize o comando `java --version` para verificar se a instalação foi bem sucedida.
- Java Native Image compilation: **GraalVM ≥ 21.0.8-graal**
  - [Instalação][graalvm-install-url]
  - Utilize o comando `java --version` para verificar se a instalação foi bem sucedida *(o valor deve estar diferente do recebido na instalação inicial do `JDK`)*.

## Utilização

Certifique-se que todos os requisitos estejam instalados e funcionais.

### Primeiro deploy
O primeiro deploy é feito através de um shell script, o que flexibiliza a implementação em um ambiente remoto, como uma VM, através de ferramentas como `Ansible`.

Cheque se o script `scripts/infra-terraform.sh` tem permissões de execução:
```bash
ls -l scripts/infra-terraform.sh
```
Caso não esteja como executável, de as permissões necessárias:
```bash
chmod +x scripts/infra-terraform.sh
```
*Permissões esperadas: `-rwxr-xr-x`*

<br/>

Agora, execute o script! Temos duas maneiras de fazer isso, manualmente ou através de Makefile:
```bash
./scripts/infra-terraform.sh all

make all
```
*Ao surgir dúvidas dos comandos diponíves, use o argumento `help`: `make help`*

O Terraform deve começar a provisionar todos os recursos necessários, em seguida, o kubectl ira fazer o deploy de todas as aplicações configuradas. Logs do progresso devem aparecer nessa syntax: `[HH:MM:SS][INFO] Message...`

Em poucos segundos uma mensagem de sucesso deve aparecer, junto às URLs de todas as aplicações relevantes, sinalizando que os deploys foram feitos com sucesso, acesse os links gerados para checar se esta tudo ok:
- Registro de imagens: http://localhost:5000/v2/_catalog
- Aplicação getting-started, ambiente des: http://localhost/des/getting-started/hello
- Aplicação getting-started, ambiente prd: http://localhost/prd/getting-started/hello

### Deploys automaticos

*Em construção...*

### Destruindo infraestrutura

Caso necessário, é possível destruir completamente a infraesturura (consistente apenas em containers e volumes), deixando o ambiente limpo para um novo deploy:

```bash
./scripts/infra-terraform.sh destroy

make destroy
```

O Terraform deve começar a deletar os recursos, e em poucos segundos uma mensagem de sucesso deve aparecer.

## Advertências
- Commits assinados por SSH ou GPG são requeridos por padrão. Caso esse comportamento não seja desejável, comente a verificação em `.husky/commit-msg`:
```sh
#!/usr/bin/env sh

# 1. Check if the commit is signed (GPG or SSH)
# if ! git log -1 --pretty=%G? | grep -qE 'G|U'; then
#   echo "❌ Commit is not signed! Please sign your commit using GPG or SSH."
#   exit 1
# fi

# 2. Run Commitlint
npx --no -- commitlint --edit "$1"
```

## Licença

Distribuído sob a Licença Pública Geral GNU v3.0. Consulte a [LICENÇA][license-url] para mais informações.

## Referências
- [Documentação Docker][docker-docs-url]
- [Documentação Kubernetes][k8s-docs-url]
- [Documentação kind][kind-docs-url]
- [Documentação Helm][helm-docs-url]
- [Documentação Terraform][terraform-docs-url]

## Reconhecimentos
- [Choose an Open Source License][choose-a-license-url]
- [Semantic Versioning][semver-url]
- [Conventional Commits][convcommits-url]

<!-- MARKDOWN LINKS -->

[debian-requirements-url]: https://www.debian.org/releases/stable/amd64/ch03s04.en.html

[debian-install-url]: https://www.debian.org/releases/stable/installmanual
[docker-install-url]: https://docs.docker.com/engine/install/debian
[docker-install-root-url]: https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
[docker-install-boot-url]: https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot-with-systemd
[docker-install-url]: https://docs.docker.com/engine/install/debian
[kubectl-install-url]: https://kubernetes.io/docs/tasks/tools/#kubectl
[kind-install-url]: https://kind.sigs.k8s.io/docs/user/quick-start#installation
[helm-install-url]: https://helm.sh/docs/intro/install
[terraform-install-url]: https://developer.hashicorp.com/terraform/install
[nvm-install-url]: https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
[node-install-url]: https://nodejs.org/en/download
[pnpm-install-url]: https://pnpm.io/installation
[java-install-url]: https://www.oracle.com/java/technologies/downloads/#java21
[graalvm-install-url]: https://www.graalvm.org/latest/getting-started/linux/

[license-url]: https://github.com/velvetcode206/on-premise-k8s-cluster/blob/main/LICENSE

[docker-docs-url]: https://docs.docker.com
[k8s-docs-url]: https://kubernetes.io/docs/home
[kind-docs-url]: https://kind.sigs.k8s.io
[helm-docs-url]: https://v3.helm.sh/docs
[terraform-docs-url]: https://developer.hashicorp.com/terraform/docs

[choose-a-license-url]: https://choosealicense.com
[semver-url]: https://semver.org
[convcommits-url]: https://www.conventionalcommits.org