### 디렉토리 구조

k8s-infra<br>
├── modules<br>
│   ├── cluster<br>
│   │   ├── cluster.tf<br>
│   │   ├── data.tf<br>
│   │   ├── outputs.tf<br>
│   │   └── variables.tf<br>
│   ├── iam<br>
│   │   ├── iam.tf<br>
│   │   ├── outputs.tf<br>
│   │   └── variables.tf<br>
│   └── worker<br>
│       ├── data.tf<br>
│       ├── locals.tf<br>
│       ├── outputs.tf<br>
│       ├── templates<br>
│       │   └── userdata.sh.tpl<br>
│       ├── variables.tf<br>
│       └── worker.tf<br>
├── prod<br>
│   ├── alb-controller<br>
│   │   ├── alb-controller.tf<br>
│   │   ├── irsa.tf<br>
│   │   ├── remote.tf<br>
│   │   ├── terraform.tfstate<br>
│   │   ├── terraform.tfstate.backup<br>
│   │   └── variables.tf<br>
│   ├── aws-auth<br>
│   │   ├── auth.tf<br>
│   │   ├── data.tf<br>
│   │   ├── remote.tf<br>
│   │   ├── templates<br>
│   │   │   └── aws_auth.yaml.tpl<br>
│   │   ├── terraform.tfstate<br>
│   │   ├── terraform.tfstate.backup<br>
│   │   └── variables.tf<br>
│   ├── cluster<br>
│   │   ├── cluster.tf<br>
│   │   ├── outputs.tf<br>
│   │   ├── remote.tf<br>
│   │   ├── remote_backend.tf<br>
│   │   ├── terraform.tfstate<br>
│   │   ├── terraform.tfstate.backup<br>
│   │   └── variables.tf<br>
│   ├── external-dns<br>
│   │   ├── external-dns.tf<br>
│   │   ├── outputs.tf<br>
│   │   ├── remote.tf<br>
│   │   ├── terraform.tfstate<br>
│   │   ├── terraform.tfstate.backup<br>
│   │   ├── variables.tf<br>
│   │   └── yaml<br>
│   │       ├── client.yaml<br>
│   │       ├── external-dns.yaml<br>
│   │       └── service-ingress.yaml<br>
│   └── worker<br>
│       ├── outputs.tf<br>
│       ├── remote.tf<br>
│       ├── remote_backend.tf<br>
│       ├── terraform.tfstate<br>
│       ├── terraform.tfstate.backup<br>
│       ├── variables.tf<br>
│       └── worker.tf<br>
└── terraform.tfstate<br>

#### module 
* cluster : 기본적인 cluster 설정과 worker와의 SG 그룹설정, 그리고 cluster 자체 필요한 IAM ROLE설정 관련 모듈<br>
* worker : worker노드의 IAM ROLE설정, LaunchConfiguration , ASG 설정관련 모듈<br>
* iam : 외부 리소스인 alb controller가 aws 리소스사용을 해야하기 때문에 oidc 구성도 함께 되어야 하고<br>
      alb controller 설치시 함께 구성되는 sa가 assume할수 있도록 신뢰관계 등록해주고<br>
      실제 권한에 대한 Role를 설정, 롤에 대한 json내용 prod쪽에 설정함<br>

#### prod
* alb-controller : alb controller 헬름설치, SA - IRSA 설정<br>
* aws-auth : kubectl 은 인증에 대한것이라면 aws-auth설정은 인가 관련으로 반드시 필요. kubectl get node부터 해당 권한필요<br>
* cluster : module호출<br>
* worker : module호출<br>
* external-dns : route53도메인에 alb-controller에서 생성되어지는 alb dns주소를 자동 맵핑해줌.
