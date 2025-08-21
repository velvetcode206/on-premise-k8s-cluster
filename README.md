<!-- BACK TO TOP ANCHOR -->

<a id="readme-top"></a>

<!-- PROJECT HEADER -->
<div align="center">
  <h3 align="center">On premise k8s cluster</h3>
  <p align="center">
A study case on implementing an on premise kubernetes cluster for local development.
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

This is a study case on how to provision, configure and utilize an on-premise kubernetes cluster for local development.

It’s designed with agnostic automation tools in mind so it is easy to migrate the cluster to a hybrid mode or full cloud.

### Built With

- [![git][git-shield]][git-url]
- [![docker][docker-shield]][docker-url]
- [![kubectl][kubectl-shield]][kubectl-url]
- [![kind][kind-shield]][kind-url]
- [![helm][helm-shield]][helm-url]
- [![terraform][terraform-shield]][terraform-url]
- [![node][node-shield]][node-url]
- [![pnpm][pnpm-shield]][pnpm-url]

<p align="right"><a href="#readme-top">⬆ back to top</a></p>

<!-- GETTING STARTED -->

## Getting Started

Follow these instructions to set the project locally.

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/velvetcode206/on-premise-k8s-cluster
   ```

<p align="right"><a href="#readme-top">⬆ back to top</a></p>

<!-- ROADMAP -->

## Roadmap

<details>
<summary><strong>📌 Full Roadmap</strong></summary>

### Phase 1: Environment & Tooling
- [ ] Install prerequisites:
    - [x] git (versioning tool)
    - [x] docker (container runtime, required by kind)
    - [x] kubectl (k8s CLI)
    - [x] kind (local k8s clusters)
    - [x] helm (k8s "package manager")
    - [x] terraform (infra as code)
    - [ ] jenkins (CI/CD solution, via helm)
    - [x] nodejs (javascript runtime)
    - [x] pnpm (node package manager)

### Phase 2: Infrastructure & Setup
- [ ] Set up code quality tools
    - [ ] Nx (script runner)
    - [ ] Eslint & Commitlint (linters, formatters)
    - [ ] Husky (pre-commit hooks)
- [ ] Create local registry (for services docker images)
- [ ] Provision the local k8s Kind cluster
- [ ] Add necessary namespaces to k8s DES & PRD
- [ ] Install Jenkins plugins
    - [ ] Git
    - [ ] Docker
    - [ ] k8s CLI
    - [ ] Helm
    - [ ] Terraform

### Phase 3: Mocked Service Setup
- [ ] Scaffold a simple Quarkus service with a `/health` endpoint
- [ ] Create a basic helm chart (quarkus-service) with Deployment + Service
- [ ] Create Dockerfile for the Quarkus service

### Phase 4: Promotion Flow
- [ ] Extend Jenkins pipeline with manual approval step for promotion to PRD

### Phase 5: Ingress, Obersvability and Scaling
- [ ] Install NGINX ingress controller
- [ ] Add ConfigMap/Secret management for environment differences
- [ ] (Optional) Add Prometheus + Grafana via Helm for monitoring

</details>
<br />

See the [open issues][issues-url] for a full list of proposed features (and known issues).

<p align="right"><a href="#readme-top">⬆ back to top</a></p>

<!-- LICENSE -->

## License

Distributed under the GNU General Public License v3.0. See [LICENSE][license-url] for more information.

<p align="right"><a href="#readme-top">⬆ back to top</a></p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- [Choose an Open Source License][choose-a-license-url]
- [Readme Shields][shields-url]
- [Semantic Versioning][semver-url]
- [Conventional Commits][convcommits-url]
<p align="right"><a href="#readme-top">⬆ back to top</a></p>

<!-- MARKDOWN LINKS & IMAGES -->

[license-shield]: https://img.shields.io/github/license/velvetcode206/on-premise-k8s-cluster.svg?style=for-the-badge
[license-url]: https://github.com/velvetcode206/on-premise-k8s-cluster/blob/main/LICENSE
[choose-a-license-url]: https://choosealicense.com
[shields-url]: https://shields.io
[semver-url]: https://semver.org
[convcommits-url]: https://www.conventionalcommits.org

<!-- BUILD WITH SHIELDS -->

[git-shield]: https://img.shields.io/badge/git-2.39.5%20versioning%20tool-000000?style=for-the-badge&logo=git&logoColor=ffffff&labelColor=F05032
[git-url]: https://git-scm.com/
[docker-shield]: https://img.shields.io/badge/docker-28.3.3%20containerization%20platform-000000?style=for-the-badge&logo=docker&logoColor=ffffff&labelColor=2496ED
[docker-url]: https://www.docker.com/
[kubectl-shield]: https://img.shields.io/badge/kubectl-1.33.3%20kubernetes%20CLI-000000?style=for-the-badge&logo=kubernetes&logoColor=ffffff&labelColor=326CE5
[kubectl-url]: https://kubernetes.io/
[kind-shield]: https://img.shields.io/badge/kind-0.29.0%20local%20kubernetes%20(container%20orchestration)-000000?style=for-the-badge&logo=kubernetes&logoColor=ffffff&labelColor=326CE5
[kind-url]: https://kind.sigs.k8s.io/
[helm-shield]: https://img.shields.io/badge/helm-3.18.5%20kubernetes%20package%20manager-000000?style=for-the-badge&logo=kubernetes&logoColor=ffffff&labelColor=0F1689
[helm-url]: https://www.helm.sh/
[terraform-shield]: https://img.shields.io/badge/terraform-1.12.2%20infrastructure%20as%20code-000000?style=for-the-badge&logo=terraform&logoColor=ffffff&labelColor=844FBA
[terraform-url]: https://developer.hashicorp.com/terraform
[node-shield]: https://img.shields.io/badge/node-22.17.0%20javascript%20runtime%20environment-000000?style=for-the-badge&logo=nodedotjs&logoColor=ffffff&labelColor=5FA04E
[node-url]: https://pnpm.io/installation/
[pnpm-shield]: https://img.shields.io/badge/pnpm-10.15.0%20node%20package%20manager-000000?style=for-the-badge&logo=pnpm&logoColor=ffffff&labelColor=f69220
[pnpm-url]: https://pnpm.io/installation/