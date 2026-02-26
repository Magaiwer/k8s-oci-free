# 🚀 Terraform Modulo Kubernetes OCI (Always Free)

> 🇺🇸 **English version**: This is the Portuguese `(pt-BR)` documentation. For the English version, please check the [README.md](./README.md) file.
 
Este repositório contém um template completo, modular e preparado para as melhores práticas para criar o seu Cluster Kubernetes (OKE) nativo dentro dos limites do nível gratuito do Oracle Cloud (Always Free).

---

## 🏗️ Arquitetura

O código provisiona a seguinte infraestrutura:
- **Rede (VCN e Subnets Públicas)**.
- **Segurança**: Regras de firewall baseadas no padrão Mínimo de privilégios (Security Lists configuradas apenas com o necessário TCP/SSH).
- **Control Plane do Kubernetes (API Master)**: Cluster do tipo BASIC, gratuito.
- **Compute (Worker Nodes)**: Configurado exatamente no limite ARM da Oracle: `2 instâncias` (A1.Flex) provendo `2 OCPUs` e `12GB de RAM` cada.

---

## 🛠️ Pré-requisitos

1.  **Conta no Oracle Cloud Infrastructure (OCI)** com recursos disponíveis no Always Free.
2.  **Terraform CLI** instalado em sua máquina (Versão mínima: 1.1.0).
3.  **Chaves de API da Oracle configuradas** (Obrigatório para gerar o *.pem* usado pelo Terraform acessar sua cloud).
4.  **OCI CLI** instalado na sua máquina para resgatar o `kubeconfig` após a criação (Opcional, mas muito recomendado).

---

## 🔑 Como preencher as suas Variáveis (terraform.tfvars)

Para rodar este laboratório, você deve criar e preencher o arquivo de variáveis na raiz deste projeto. Já dispomos de um arquivo `terraform.tfvars.example`. Renomeie-o ou copie-o para `terraform.tfvars`.

Aqui está onde você encontra cada variável dentro da console web da Oracle Cloud:

- `tenancy_ocid`
  - **Onde Achar:** No canto superior direito, clique em "Profile" (O bonequinho do seu usuário) > `Tenancy: <nome-da-sua-tenancy>` > Copie o OCID.
- `user_ocid`
  - **Onde Achar:** No canto superior direito, clique em "Profile" > `User Settings` > Copie o OCID do seu usuário (Ex: `ocid1.user.oc1...`).
- `private_key_path`
  - **Onde Achar/Criar:** No Console OCI, em "Profile" > `User Settings` > No menu vertical inferior esquerdo acesse `API Keys`. Adicione uma API Key. Baixe a Chave Privada (`.pem`) e aponte este caminho da sua máquina local no tfvars (Ex: `~/.oci/minha_chave.pem`).
- `fingerprint`
  - **Onde Achar:** Após criar a "API Key" descrita acima, a própria janela do OCI mostrará o Fingerprint (um hash algo como `12:34:56...`).
- `region`
  - **Onde Achar:** Na barra superior direita está sua Região Home (Ex: `sa-saopaulo-1` ou `us-ashburn-1`). Use apenas regiões que a Oracle liberou para você.
- `compartment_id`
  - **Onde Achar:** Acesse o menu Global no topo esquerdo ☰ > `Identity & Security` > `Compartments`. Crie um ou copie o OCID de um Sandbox existente (Recomendado não usar o root padrão para o cluster).
- `availability_domain`
  - **Onde Achar:** Se tiver dúvidas de como se chama os ADs em sua conta, você pode instalar e rodar com o OCI CLI: `oci iam availability-domain list`. O nome vai ser string como `tYvX:US-ASHBURN-AD-1` ou `rCvy:SA-SAOPAULO-1-AD-1`.

As demais variáveis, como IP Ranges (CIDR Blocks) ou versão do K8s (`v1.31.1`) podem ser mantidas no padrão sugerido, a não ser que você precise injetar roteamento corporativo exímio.

---

## 🏃 Como Implementar o Cluster

Abra seu terminal favorito e siga as etapas:

**1. Configurar sua base (Baixar plugins e módulos)**
```bash
terraform init
```

**2. Visualizar as Mudanças (Opcional, mas recomendável)**
```bash
terraform plan
```
> Revise se não vai surgir o custo de algum nat-gateway. Se aparecer recursos não condizentes com o Always Free, aborte a execução. O script nativo prioriza tudo o que é de graça.

**3. Criar os Recursos**
```bash
terraform apply
```
> Confirme com um "yes". Após o OK, a Oracle levará em torno de ~10 a ~25 minutos para provisionar o Cluster. Vá curtir um café. ☕

**4. Acessando seu Novo Cluster!**
Depois do sucesso do `apply`, o terminal vai exibir um output especial chamado `kubeconfig_command`.

Para acessar de fato o cluster, você precisará de duas ferramentas na sua máquina:
1. **OCI CLI**: Se não a tiver, você pode instalar o script oficial com o comando `bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"`
2. **Kubectl**: A ferramenta oficial do kubernetes. (Siga a [documentação do k8s](https://kubernetes.io/docs/tasks/tools/) para seu SO).

Com as ferramentas na máquina, copie aquele comando gerado no Output do terraform. Ele será parecido com isso:
```bash
oci ce cluster create-kubeconfig --cluster-id ocid1.cluster.oc1.xxxx --file $HOME/.kube/config --region sa-saopaulo-1 --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT
```
Execute-o no seu terminal para baixar seu arquivo seguro de credenciais. Feito isso, conecte roteando o comando mestre: `kubectl get nodes` e veja seus Worker nodes prontos para a diversão! 🎉

---

## 🗑️ Destruição / Limpeza

A Oracle pode suspender contas inativas (`Idle status`). Se precisar remover todos os recursos criados de forma simples, rode:
```bash
terraform destroy
```

Feito de forma limpa, seguindo os princípios de Componentização para não haver sugeiras virtuais. Divirta-se!

---

## 🧩 Add-ons Opcionais e Observabilidade

Este repositório foi expandido para suportar ferramentas Cloud-Native avançadas, mantendo-as **TOTALMENTE OPCIONAIS** via `Feature Flags`. A gerência do Cluster e da Rede (Cloud Provider) permanece estritamente isolada da instalação via Kubernetes/Helm.

No seu `terraform.tfvars`, você pode injetar as seguintes flags (se as omitir, o padrão é `false`):

```hcl
enable_headlamp   = true   # Instala Headlamp Management UI
enable_monitoring = true   # Instala Kube-Prometheus-Stack (Prometheus, Grafana, Alertmanager)
enable_telemetry  = false  # Instala Loki (Logs centralizados) e OpenTelemetry Collector
```

Assim que essas variáveis forem alteradas e você rodar um `terraform apply`, o script fará o provisionamento automático via contêineres e Helm Charts utilizando as credenciais recém geradas do seu Kubeconfig local.

### ⚠️ Estimativa de Recursos (Consumo ao ativar a Stack Completa)

Se você ativar **todas as 3 flags como `true`**, este será aproximadamente o consumo ocioso exigido pela stack inteira rodando sobre os seus 2 Worker Nodes (que totalizam conjuntamente **4 OCPUs e 24 GB de RAM** do Always Free):

1. **Headlamp**: É uma interface GUI construída em base muito leve.
   - *Consumo Médio de Base*: **~100 a 150 MB de RAM** e ~0.1 OCPU constantes.
2. **Kube-Prometheus-Stack (Grafana + Alertmanager + Prometheus)**: 
   - *Consumo Médio de Base*: **~1.5 a 2 GB de RAM** e ~0.4 OCPU (Ingerindo poucas métricas no início).
3. **Loki + OpenTelemetry (Promtail)**: 
   - *Consumo Médio de Base*: **~800 MB a 1.2 GB de RAM** e ~0.3 OCPUs (Atenção redobrada pois logs em disco consomem também Block Storage vertiginosamente).

#### **Custo Oculto Total do Sistema "Tudo Ativado"**
- **RAM Utilizada:** Lançar toda essa suíte de ponta consumirá de chofre **entre 4 GB a 6 GB da sua RAM total** disponível (que hoje é de 24 GB totais ou seja de ~15% a ~25% da memória gasta). Ficam livres ~18 GB de RAM confortáveis para rodar seus microsserviços do usuário.
- **CPU Utilizada:** Custará da base cerca de **1.2 OCPUs** de um limite total de 4. Se a ingestão de usuários ou métricas aumentar, os processos Go (Prometheus/Loki) escalarão esse uso.

> **💡 Dica:** Evite ativar ferramentas de Logging Pesado (Loki) se pretende gerir poucas aplicações (1 Cluster) livres de observabilidade massiva. O `Headlamp + Grafana` forma a melhor adoecao "Custo-Benefício" num ecossistema fechado OCI Free.
