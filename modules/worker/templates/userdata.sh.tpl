#!/bin/bash
set -ex
${pre_userdata}

B64_CLUSTER_CA=${cluster_auth_base64}
API_SERVER_URL=${endpoint}
/etc/eks/bootstrap.sh ${cluster_name} --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL ${runtime} 
# /etc/eks/bootstrap.sh ${cluster_name} --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL ${runtime} --kubelet-extra-args ${kubelet_extra_args} --cloud-provider=external

${additional_userdata}