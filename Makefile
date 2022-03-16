
start:
	minikube start

install:
	kubectl create namespace argo
	kubectl apply -n argo -f install.yaml

configure:
	kubectl apply -n argo -f config.yaml

serve:
	kubectl -n argo port-forward deployment.apps/argo-server 2746:2746

install-minio:
	helm install argo-artifacts minio/minio --namespace argo --set fullnameOverride=argo-artifacts --set defaultBucket.enabled=true --set defaultBucket.name=my-bucket --set persistence.enabled=false --set resources.requests.memory=2Gi --set service.type=ClusterIP

serve-minio:
	kubectl port-forward service/argo-artifacts 9000:9000 -n argo

get-minio-token:
	kubectl get secret -n argo argo-artifacts -o jsonpath="{.data.accesskey}" | base64 --decode
	kubectl get secret -n argo argo-artifacts -o jsonpath="{.data.secretkey}" | base64 --decode

get-auth-token:
	POD_ID=$(kubectl get po -n argo --output="jsonpath={.items..metadata.name}" --selector=app=argo-server)
	kubectl -n argo exec argo-server-${POD_ID} -- argo auth token

test1:
	argo submit --watch -n argo .\workflow-test1.yaml

test2:
	argo submit --watch -n argo .\workflow-test2.yaml