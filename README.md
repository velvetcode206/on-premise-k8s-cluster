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

<p align="right"><a href="#readme-top">⬆ back to top</a></p>

### Built With

- [![git][git-shield]][git-url]

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
    - [ ] docker (container runtime, required by kind)
    - [ ] kind (running local k8s clusters using docker container as nodes)
    - [ ] kubectl (k8s CLI)
    - [ ] helm (k8s "package manager")
    - [ ] terraform (infra as code)
    - [ ] jenkins (CI/CD solution, dockerized)
    - [ ] nodejs & pnpm (monorepo workspace)

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

[git-shield]: https://img.shields.io/badge/git-versioning%20tool-000000?style=for-the-badge&logo=git&logoColor=ffffff&labelColor=F05032
[git-url]: https://git-scm.com/
