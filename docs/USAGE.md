<!-- BACK TO TOP ANCHOR -->

<a id="readme-top"></a>

## Automação de Cluster Kubernetes Local com CI/CD e Registro de Imagens

Estudo de caso sobre a criação automatizada de um cluster Kubernetes em ambiente local, integrando pipelines de CI/CD e um registro de imagens privado. O projeto foca em práticas modernas de desenvolvimento com contêineres, promovendo flexibilidade e reprodutibilidade.

<!-- TABLE OF CONTENTS -->
<details open>
  <summary>Índice</summary>
  <ol>
    <li><a href="#objetivo">Objetivo</a></li>
    <li><a href="#escopo">Escopo</a></li>
    <li>
      <a href="#arquitetura">Arquitetura</a>
      <ul>
        <li><a href="#repositório-de-código">Repositório de Código</a></li>
        <li><a href="#registro-de-imagens">Registro de imagens</a></li>
        <li><a href="#cluster-kubernetes">Cluster Kubernetes</a></li>
        <li><a href="#pipeline-de-integração-contínua-(ci)">Pipeline de Integração Contínua (CI)</a></li>
        <li><a href="#cluster-kubernetes">Cluster Kubernetes</a></li>
      </ul>
    </li>
    <li>
      <a href="#tecnologias-utilizadas-e-justificativas">Tecnologias Utilizadas e Justificativas</a>
        <ul>
          <li><a href="#🖥️-sistema-operacional">🖥️ Sistema Operacional</a></li>
          <li><a href="#📦-contêineres-e-orquestração">📦 Contêineres e Orquestração</a></li>
          <li><a href="#🔄-entrega-contínua-e-gitops">🔄 Entrega Contínua e GitOps</a></li>
          <li><a href="#⚙️-infraestrutura-como-código">⚙️ Infraestrutura como Código</a></li>
          <li><a href="#📈-monitoramento-e-observabilidade">📈 Monitoramento e Observabilidade</a></li>
          <li><a href="#🧪-qualidade-de-código-e-ci">🧪 Qualidade de Código e CI</a></li>
          <li><a href="#🧰-ambiente-de-desenvolvimento">🧰 Ambiente de Desenvolvimento</a></li>
          <li><a href="#☕-tecnologias-java">☕ Tecnologias Java</a></li>
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
Este documento apresenta o processo de planejamento e implementação de um cluster Kubernetes em ambiente local. São detalhados as tecnologias selecionadas, requisitos de hardware e software, os procedimentos de provisionamento e operação, além de orientações importantes sobre o uso do repositório.

## Escopo
O cluster será executado em sistemas GNU/Linux, com foco em práticas de desenvolvimento ágil. Devido à natureza das ferramentas adotadas, a infraestrutura pode ser provisionada de forma leve e rápida, garantindo flexibilidade para simulações de ambientes em produção.

## Arquitetura

![Diagrama](diagram.png "Diagrama")

A arquitetura do projeto é composta por quatro pilares principais: o repositório de código, o registro de imagens, a pipeline de integração contínua (CI) e o cluster Kubernetes com entrega contínua automatizada. Abaixo, detalhamos cada um deles:

### Repositório de Código

- Utiliza o pnpm workspace para estruturar um monorepositório, permitindo que múltiplas aplicações compartilhem dependências e código de forma eficiente.
- O Nx é empregado para padronizar e orquestrar os scripts de build, testes e deploy entre diferentes aplicações e frameworks, garantindo consistência e automação.
- Ferramentas como Husky e Commitlint são integradas para padronizar mensagens de commit, evitando variações semânticas entre desenvolvedores.
- Um script de inicialização (infrastructure.sh) automatiza o provisionamento da infraestrutura local, facilitando a configuração do ambiente em novas máquinas.

### Registro de imagens

- Um container dedicado, provisionado via Terraform, atua como registro local de imagens Docker.
- Todas as imagens geradas pelas pipelines de CI são armazenadas nesse registro, que possui volume persistente para garantir a integridade das imagens mesmo após reinicializações ou destruição da infraestrutura.

### Pipeline de Integração Contínua (CI)

- Dois containers adicionais, também provisionados via Terraform, hospedam os runners do Jenkins e do SonarQube.
- Essas ferramentas executam as etapas de build, testes e análise de qualidade do código. Em caso de sucesso, uma nova imagem é gerada e enviada ao registro local.
- A pipeline também realiza versionamento automático da aplicação, criando commits na branch correspondente conforme o tipo de alteração detectada.

### Cluster Kubernetes

- O cluster é criado localmente com Minikube, utilizando o driver Docker via Terraform. Isso significa que o cluster roda dentro de um container, e não em uma máquina virtual.
- Três ferramentas monitoram o ambiente:
  - Prometheus: coleta métricas do cluster.
  - Grafana: gera dashboards visuais com base nas métricas.
  - Alertmanager: permite configurar alertas com base nos dados do Prometheus.
- Cada ferramenta possui um subdomínio próprio, como `http://grafana.<ip>.np.io`, enquanto as aplicações são acessadas por subcaminhos, como `http://<ip>/des/app/hello`.
- Como solução de entrega contínua, o serviço ArgoCD é integrado ao cluster. Ele monitora o repositório de código e, ao detectar alterações nas branches definidas, realiza o deploy automático das aplicações. O ArgoCD busca as imagens no registro local e atualiza os pods no cluster, garantindo que cada build bem-sucedida seja refletida diretamente no ambiente de execução.

## Tecnologias Utilizadas e Justificativas
As tecnologias escolhidas para este projeto foram selecionadas com base em critérios como modularidade, baixo acoplamento, ampla adoção no mercado e facilidade de integração. A seguir, apresentamos os principais componentes organizados por categoria, com os pontos positivos que motivaram sua adoção:

### 🖥️ Sistema Operacional

**Debian GNU/Linux**  
Estável, seguro e amplamente utilizado em servidores. Ideal para ambientes críticos e de desenvolvimento local.

### 📦 Contêineres e Orquestração
**Docker**  
Ferramenta padrão para criação e gerenciamento de contêineres. Simples, robusta e com grande comunidade.

**Minikube**  
Distribuição leve do Kubernetes, ideal para ambientes locais. Destaques:
1. Suporte a múltiplos modos de provisionamento (usado aqui via container).
2. Criação rápida de clusters paralelos.
3. Integração fácil com ferramentas de CI/CD.

**kubectl**  
Ferramenta essencial para interações com clusters Kubernetes, locais ou remotos.

**Helm**  
Funciona como um "gerenciador de aplicativos" para o Kubernetes. Ele permite instalar e configurar aplicações com apenas alguns comandos. Benefícios:
1. Automatiza instalações e evita a criação manual de dezenas de arquivos YAML.
2. Facilita atualizações, permitindo atualizar versões de aplicações sem perder configurações.
3. Usa "charts", que são pacotes reutilizáveis com definições de deploy.

### 🔄 Entrega Contínua e GitOps
**ArgoCD**
Ferramenta de GitOps que automatiza o deploy no Kubernetes. Vantagens:
1. Monitora branches definidas no repositório.
2. Atualiza os pods automaticamente após builds bem-sucedidos.
3. Garante sincronização entre código e ambiente.

### ⚙️ Infraestrutura como Código
**Terraform**  
O Terraform permite que toda a infraestrutura (como servidores, volumes, containers) seja descrita em arquivos de texto. Isso torna o ambiente reproduzível e versionável. Pontos fortes:
1. Reprodutibilidade.
2. Controle de versões.
3. Integração com múltiplos provedores e recursos locais.

### 📈 Monitoramento e Observabilidade
**Prometheus**  
Prometheus é como um "sensor" que monitora tudo que acontece no cluster: uso de CPU, memória, número de pods, falhas, etc.

**Grafana**  
Grafana transforma os dados coletados pelo Prometheus em gráficos interativos e dashboards.

**Alertmanager**  
Configuração de alertas personalizados com base nos dados do Prometheus.

### 🧪 Qualidade de Código e CI

**SonarQube**  
SonarQube verifica o código-fonte em busca de problemas como bugs, vulnerabilidades e má prática de programação.

**Jenkins**  
Jenkins é um runner que executa os processos de build, teste e deploy. Ele é altamente configurável e acoplável com outras ferramentas.

### 🧰 Ambiente de Desenvolvimento

**nvm + NodeJS**  
Execução de aplicações JavaScript com controle de versões via nvm.

**pnpm**  
Gerenciador de pacotes alternativo ao npm. Diferenciais:
1. Instalações rápidas.
2. Cache global.
3. Suporte nativo a monorepos.

**Nx**  
Ferramenta para organização de monorepositórios. Benefícios:
1. Cache inteligente.
2. Visualização de dependências.
3. Suporte a múltiplas linguagens.

**Husky & commitlint**  
Padronização de mensagens de commit, garantindo consistência semântica.

### ☕ Tecnologias Java

**JDK + Gradle**  
Ambiente completo para desenvolvimento e automação de builds Java.

**GraalVM**  
Compilação de código Java para binários nativos. Vantagens:
1. Redução no tempo de inicialização.
2. Menor consumo de memória.

## Requisitos

### Hardware

Requisitos mínimos e recomendados, considerando [o sistema operacional Debian GNU/Linux][debian-requirements-url]:

- CPU: ≥ 1 GHz
- Memória RAM: 1 a 2GB
- Armazenamento: 10 a 20GB

### Software

A instalação das ferramentas deve seguir as instruções oficiais de cada projeto. Abaixo estão os requisitos e observações específicas:

[**Debian GNU/Linux 12**][debian-install-url]  
*Outras distribuições Linux são compatíveis, mas podem exigir métodos de instalação alternativos. Consulte a documentação oficial de cada ferramenta.*

[**Docker ≥ 28.3.3**][docker-install-url]
- O daemon do Docker roda como `root`. Para evitar o uso constante de `sudo`, [adicione o usuário no grupo Docker][docker-install-root-url].
- Em distribuições que utilizam `systemd`, o Docker pode não iniciar automaticamente. [Configure esse compartamento][docker-install-boot-url] se necessário.
- Verificação: `docker run hello-world`

[**kubectl ≥ 1.33.3**][kubectl-install-url]  
- Verificação: `kubectl version`

[**kind ≥ 0.29.0**][kind-install-url]  
- Certifique-se de que o executável esteja no `PATH` do sistema.
- Verificação: `kind version`

[**Helm ≥ 3.18.5**][helm-install-url]
- Certifique-se de que o executável esteja no `PATH` do sistema.
- Verificação: `helm version`

[**Terraform ≥ 1.13.0**][terraform-install-url]
- Verificação: `terraform version`

[**(Opcional) nvm ≥ 0.40.3**][nvm-install-url]
- Verificação: `nvm --version`

**NodeJS ≥ 22.18.0**
- Se estiver usando o nvm: `nvm install 22.18.0`
- Alternativamente, [instale os binários manualmente][node-install-url] *(recomendado usar nvm)*.
- Verificação: `node --version`

**pnpm ≥ 10.15.0**
- Instalação via npm: `npm install -g pnpm@10.15.0`
- Alternativamente, [instale os binários manualmente][pnpm-install-url].
- Verificação: `pnpm --version`

[**JDK ≥ 21.0.8**][java-install-url]
- Verificação: `java --version`

[**GraalVM ≥ 21.0.8-graal**][graalvm-install-url]
- Verificação: `java --version` *(o valor deve diferir da versão padrão do JDK)*

## Utilização

Antes de iniciar, certifique-se de que todos os requisitos estejam devidamente instalados e funcionais.

### Primeiro deploy
O primeiro deploy é realizado por meio de um `script shell`, o que permite flexibilidade na implementação, inclusive em ambientes remotos (como VMs), utilizando ferramentas como `Ansible`.

- Verifique as permissões do script:
```bash
ls -l scripts/infrastructure.sh
```
- Se o script não estiver com permissões de execução, aplique:
```bash
chmod +x scripts/infrastructure.sh
```
- Permissões esperadas: `-rwxr-xr-x`

<br/>

Você pode executar o script de duas formas:
- Diretamente: 
```bash
./scripts/infrastructure.sh all
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
- Jenkins: http://localhost:5001/
- SonarQube: http://localhost:5002/
- Kubernets Dashboard: https://&lt;ip&gt;.np.io/
- Grafana: https://grafana.&lt;ip&gt;.np.io/
- Prometheus: https://prometheus.&lt;ip&gt;.np.io/
- Alertmanager: https://alertmanager.&lt;ip&gt;.np.io/
- Aplicação getting-started (des): https://&lt;ip&gt;.np.io/des/getting-started/hello
- Aplicação getting-started (prd): https://&lt;ip&gt;.np.io/prd/getting-started/hello

### Deploys automáticos
Após realizar um commit no repositório, siga os passos abaixo para executar uma build manual no Jenkins:
1. Acesse o Dashboard do Jenkins
Abra o navegador e vá até o endereço do Jenkins:
Exemplo: http://localhost:5001/

2. Faça login
Use suas credenciais de acesso. Se for a primeira vez, você tera que pegar a senha dentro do container.
```bash
docker ps # Procure o container do jenkins e anote o ID

docker exec -ti <ID> bash # Abrirá o bash no container passado

# Dentro do container, printe a senha inicial
$ cat /var/lib/jenkins/secrets/initialAdminPassword
```

3. Localize o Job da aplicação
Na tela inicial, procure pelo nome do Job correspondente à aplicação que você deseja buildar.
Dica: Os nomes dos jobs geralmente seguem o padrão do nome da aplicação ou da branch.

4. Execute a Build
Clique no nome do Job.
Na página do Job, clique em "Build Now" no menu lateral esquerdo.

5. Acompanhe o progresso
Um novo item aparecerá na seção Build History.
Clique no número da build para ver os detalhes.
Em seguida, clique em "Console Output" para acompanhar os logs em tempo real.

6. Verifique o resultado
Se a build for bem-sucedida, uma nova imagem será gerada e enviada ao registro local.
Dependendo da branch utilizada, O ArgoCD será acionado automaticamente (via GitOps) e atualizará os pods no cluster com a nova versão da aplicação.

### Destruindo infraestrutura

Caso seja necessário, é possível remover completamente a infraestrutura provisionada — composta exclusivamente por contêineres e volumes — deixando o ambiente limpo para um novo deploy.:

- Comando direto:
```bash
./scripts/infrastructure.sh destroy
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
- O provedor terraform do `minikube` as vezes entra em conflito com elementos kubernetes, caso a conexão com o contexto kubernetes de erro durante o apply, tente excluir as arquivos gerados `.terraform` `.terraform.lock.hcl` `terraform.tfstate` e tente novamente.

## Licença

Distribuído sob a Licença Pública Geral GNU v3.0.

Consulte a [LICENÇA][license-url] para mais informações.

## Referências
- [Documentação Docker][docker-docs-url]
- [Documentação Kubernetes][k8s-docs-url]
- [Documentação kind][kind-docs-url]
- [Documentação Helm][helm-docs-url]
- [Documentação Terraform][terraform-docs-url]
- [Documentação ArgoCD][argocd-docs-url]
- [Documentação Jenkins][jenkins-docs-url]

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
[argocd-docs-url]: https://argo-cd.readthedocs.io/en/stable
[jenkins-docs-url]: https://www.jenkins.io/doc/

[choose-a-license-url]: https://choosealicense.com
[semver-url]: https://semver.org
[convcommits-url]: https://www.conventionalcommits.org
