<!-- BACK TO TOP ANCHOR -->

<a id="readme-top"></a>

## Provisionamento de Cluster Kubernetes Local para Desenvolvimento

Estudo de caso que explora a implementação de um cluster Kubernetes em ambiente local, com foco em automação, flexibilidade e práticas de desenvolvimento de aplicações em contêineres.

<!-- TABLE OF CONTENTS -->
<details open>
  <summary>Índice</summary>
  <ol>
    <li><a href="#objetivo">Objetivo</a></li>
    <li><a href="#escopo">Escopo</a></li>
    <li><a href="#tecnologias">Tecnologias</a></li>
    <li>
      <a href="#arquitetura">Arquitetura</a>
      <ul>
        <li><a href="#repositório">Repositório</a></li>
        <li><a href="#registro-de-imagens">Registro de imagens</a></li>
        <li><a href="#cluster-kubernetes">Cluster Kubernetes</a></li>
        <li><a href="#ci/cd">CI/CD</a></li>
        <li><a href="#monitoramento-e-observabilidade">Monitoramento e observabilidade</a></li>
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
Este documento apresenta o processo de planejamento e implementação de um cluster Kubernetes em ambiente local. São detalhados os requisitos de hardware e software, as tecnologias selecionadas, os procedimentos de provisionamento e operação, além de orientações importantes sobre o uso do repositório.

## Escopo
O cluster será executado em sistemas GNU/Linux, com foco em práticas de desenvolvimento ágil. Devido à natureza das ferramentas adotadas, a infraestrutura pode ser provisionada de forma leve e rápida, garantindo flexibilidade para simulações de ambientes em produção.

## Tecnologias
As tecnologias selecionadas para este projeto foram escolhidas por sua modularidade e baixo acoplamento, permitindo substituições com impacto mínimo na arquitetura geral.

- Sistema Operacional
  - **Debian GNU/Linux**
  - Reconhecido por sua estabilidade e segurança, é ideal para servidores e ambientes críticos.

- Container Runtime
  - **Docker**
  - Principal ferramenta para criação e gerenciamento de contêineres, amplamente adotada no mercado.

- Kubernetes CLI
  - **kubectl**
  - Ferramenta essencial para interações com clusters Kubernetes, locais ou remotos.

- ⚠️ Distribuição Kubernetes
  - **kind (Kubernetes IN Docker)**
  - Elemento central do projeto. Utiliza contêineres em vez de máquinas virtuais para executar os nodes, permitindo:
    - Criação de múltiplos clusters em paralelo.
    - Provisionamento leve e rápido.
    - Integração com pipelines de CI/CD e testes locais.

- Gerenciador de Pacotes Kubernetes
  - **Helm**
  - Facilita a instalação, atualização e gerenciamento de pacotes no cluster, como ingress controllers, sistemas de monitoramento e bancos de dados.

- Monitoramento
  - **Grafana**
  - Oferece dashboards interativos para visualização de métricas do cluster..

- Observabilidade
  - **Prometheus**
  - Responsável pela coleta de métricas dos componentes do cluster, integrando-se com outras ferramentas de visualização e alerta.

- Alertas
  - **Alertmanager**
  - Permite a configuração de alertas e notificações personalizadas com base nas métricas coletadas.

- Infraestrutura como Código
  - **Terraform**
  - Provisiona a infraestrutura de forma declarativa, incluindo o registro de contêineres local, volumes e o próprio cluster Kubernetes.

- Node Version Manager
  - **nvm**
  - Facilita a instalação e gerenciamento de múltiplas versões do Node.js.

- Javascript Runtime
  - **NodeJS**
  - Necessário para execução de scripts e aplicações JavaScript.

- Node Package Manager
  - **pnpm**
  - Alternativa ao `npm`, escolhido por:
    - Instalações mais rápidas;
    - Cache global que evita duplicação de pacotes;
    - Compartilhamento de dependências via links simbólicos;
    - Controle rigoroso de versões;
    - Suporte nativo a monorepos com workspaces.

- Build tool
  - **Nx**
  - Organiza o monorepo e executa comandos. Ideal para grandes projetos, oferece:
    - Cache inteligente para acelerar builds e testes;
    - Visualização gráfica de dependências;
    - Suporte a múltiplas tecnologias (Node, Java);
    - Ferramentas para modularização e reutilização de código;
    - Forte integração com CI/CD.

- Padronização de Commits
  - **Husky & commitlint**
  - Garantem a conformidade com padrões semânticos nos commits, mesmo em ambientes locais.

- Java Development Kit
  - **JDK**
  - Essencial para desenvolvimento e execução de aplicações Java.

- Compilação para Binários Nativos (JDK)
  - **GraalVM**
  - Compila código Java para binários nativos, reduzindo tempo de inicialização e consumo de memória.

## Arquitetura

### Repositório

- Estruturado como monorepo utilizando pnpm workspaces, permitindo múltiplas aplicações em um único repositório.
- Nx gerencia builds e scripts que geram artefatos.
- Padronização de commits via Husky e commitlint.
- Provisionamento inicial da infraestrutura e aplicações realizado por scripts shell.

### Registro de imagens

- Registro local com volume persistente, permitindo acesso às imagens diretamente pelo host se necessário.
- Utiliza a imagem oficial Docker `registry:2`, adequada para registros locais.
- Conectado à rede Docker `kind`, permitindo que o cluster Kubernetes realize o pull das imagens.

### Cluster Kubernetes

- Cluster local com múltiplos nodes;
  - 1 control-plane;
  - 1 worker reserva para tarefas gerais;
  - 1 worker dedicado para aplicações;
  - 1 worker dedicado para o controle de ingress.
- 2 custom namespaces
  - des: destinado ao desenvolvimento e testes;
  - prd: destinado à execução de aplicações em produção.
- Instalação de pacotes via `Helm`;
- Utilização do `nginx-ingress` como ingress controller para roteamento HTTP local.
- Conectividade com o registro de imagens via rede Docker `kind`.

### CI/CD

- *Pipeline de integração e entrega contínua em desenvolvimento...*

### Monitoramento e Observabilidade

Implementado com o `kube-prometheus-stack` via Helm, incluindo:

- Grafana: Dashboards interativos para visualização de métricas e monitoramento em tempo real.
- Prometheus: Coleta e armazenamento de métricas para análise de desempenho.
- Alertmanager: Geração automatizada de alertas e notificações, permitindo resposta rápida a incidentes.

### Segurança

- *Módulo de segurança em desenvolvimento...*

## Requisitos

### Hardware

Requisitos mínimos e recomendados, considerando [o sistema operacional Debian GNU/Linux][debian-requirements-url]:

- CPU: ≥ 1 GHz
- Memória RAM: 1 a 2GB
- Armazenamento: 10 a 20GB

### Software

A instalação das ferramentas deve seguir as instruções oficiais de cada projeto. Abaixo estão os requisitos e observações específicas:

- **Debian GNU/Linux 12**
  - [Instalação][debian-install-url]
  - *Outras distribuições Linux são compatíveis, mas podem exigir métodos de instalação alternativos. Consulte a documentação oficial de cada ferramenta.*
- **Docker ≥ 28.3.3**
  - [Instalação][docker-install-url]
  - O daemon do Docker roda como `root`. Para evitar o uso constante de `sudo`, [adicione o usuário no grupo Docker][docker-install-root-url].
  - Em distribuições que utilizam `systemd`, o Docker pode não iniciar automaticamente. [Configure esse compartamento][docker-install-boot-url] se necessário.
  - Verificação: `docker run hello-world`
- **kubectl ≥ 1.33.3**
  - [Instalação][kubectl-install-url]
  - Verificação: `kubectl version`
- **kind ≥ 0.29.0**
  - [Instalação][kind-install-url]
  - Certifique-se de que o executável esteja no `PATH` do sistema.
  - Verificação: `kind version`
- **Helm ≥ 3.18.5**
  - [Instalação][helm-install-url]
  - Certifique-se de que o executável esteja no `PATH` do sistema.
  - Verificação: `helm version`
- **Terraform ≥ 1.13.0**
  - [Instalação][terraform-install-url]
  - Verificação: `terraform version`
- **(Opcional) nvm ≥ 0.40.3**
  - [Instalação][nvm-install-url]
  - Verificação: `nvm --version`
- **NodeJS ≥ 22.18.0**
  - Se estiver usando o nvm: `nvm install 22.18.0`
  - Alternativamente, [instale os binários manualmente][node-install-url] *(recomendado usar nvm)*.
  - Verificação: `node --version`
- **pnpm ≥ 10.15.0**
  - Instalação via npm: `npm install -g pnpm@10.15.0`
  - Alternativamente, [instale os binários manualmente][pnpm-install-url].
  - Verificação: `pnpm --version`
- **JDK ≥ 21.0.8**
  - [Instalação][java-install-url]
  - Verificação: `java --version`
- **GraalVM ≥ 21.0.8-graal**
  - [Instalação][graalvm-install-url]
  - Verificação: `java --version` *(o valor deve diferir da versão padrão do JDK)*

## Utilização

Antes de iniciar, certifique-se de que todos os requisitos estejam devidamente instalados e funcionais.

### Primeiro deploy
O primeiro deploy é realizado por meio de um `script shell`, o que permite flexibilidade na implementação, inclusive em ambientes remotos (como VMs), utilizando ferramentas como `Ansible`.

- Verifique as permissões do script:
```bash
ls -l scripts/infra-terraform.sh
```
- Se o script não estiver com permissões de execução, aplique:
```bash
chmod +x scripts/infra-terraform.sh
```
- Permissões esperadas: `-rwxr-xr-x`

<br/>

Você pode executar o script de duas formas:
- Diretamente: 
```bash
./scripts/infra-terraform.sh all
```
- Via Makefile: 
```bash
make all
```
- Para visualizar os comandos disponíveis, utilize:
```bash
make help
```

O Terraform iniciará o provisionamento dos recursos necessários. Em seguida, o `kubectl` realizará o deploy das aplicações configuradas. Os logs de progresso seguirão o padrão:
```bash
[HH:MM:SS][INFO] Message...
```

Após alguns segundos, uma mensagem de sucesso será exibida, juntamente com as URLs das aplicações relevantes. Acesse os links para verificar se os serviços estão operacionais:
- Registro de imagens: http://localhost:5000/v2/_catalog
- Grafana: http://localhost/monitoring/grafana
- Prometheus: http://localhost/monitoring/prometheus
- Alertmanager: http://localhost/monitoring/alertmanager
- Aplicação getting-started (des): http://localhost/des/getting-started/hello
- Aplicação getting-started (prd): http://localhost/prd/getting-started/hello

### Deploys automáticos

*Em desenvolvimento...*

### Destruindo infraestrutura

Caso seja necessário, é possível remover completamente a infraestrutura provisionada — composta exclusivamente por contêineres e volumes — deixando o ambiente limpo para um novo deploy.:

- Comando direto:
```bash
./scripts/infra-terraform.sh destroy
```

- Via Makefile:
```bash
make destroy
```

O Terraform iniciará o processo de destruição dos recursos. Em poucos segundos, uma mensagem de sucesso será exibida.

## Advertências
- Por padrão, o projeto exige commits assinados via SSH ou GPG. Caso esse comportamento não seja desejado, é possível desabilitar a verificação comentando o trecho correspondente no arquivo
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

Distribuído sob a Licença Pública Geral GNU v3.0.

Consulte a [LICENÇA][license-url] para mais informações.

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
