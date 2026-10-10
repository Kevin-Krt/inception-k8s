
## What I used

- **ConfigMap** and **Secret** for the configuration and the passwords
- **StatefulSet** for MariaDB, with a PersistentVolumeClaim
- **Deployment** for the web Pod, which holds two containers
- **Services** so each part can be reached by a stable name
- **Ingress** for the entry point and the TLS certificate

## Three things I had to decide

**NGINX and PHP-FPM are in the same Pod.** They both need the same WordPress
files. The storage on my cluster can only be mounted by one machine at a time,
so two separate Pods could not share it. Putting them together solved it, and
they now talk through `127.0.0.1`.

**TLS happens only once, at the Ingress.** At first I kept NGINX doing TLS, like
in my Compose version. Traefik then refused its certificate. I realised I was
encrypting twice for no reason, so NGINX now listens on plain HTTP inside the
cluster and the certificate sits in the Ingress.

**MariaDB is a StatefulSet, not a Deployment.** A Deployment makes
interchangeable Pods sharing one volume, which is wrong for a database. A
StatefulSet gives a stable name and its own volume. It does not replicate
anything though: that would be MariaDB's job.

## What replaced what

| Docker Compose | Kubernetes |
|---|---|
| Docker's internal DNS | CoreDNS, through Services |
| `depends_on` | a readiness probe |
| named volume | PersistentVolumeClaim |
| `.env` | ConfigMap and Secret |
| `docker compose up -d` | `kubectl apply -f k8s/` |

## What is missing

I know these are not right, I ran out of time.

- No CPU or memory requests and limits, so the Pods are `BestEffort`.
- The config files are still copied into the images, so changing one means
  rebuilding. ConfigMaps mounted as files would be better.
- The Secret is in the repository in plain text. Fine for a demo, not for
  anything else.
- I kept the wait loop from my Compose entrypoint instead of writing a real
  readiness probe.
- Images are loaded with `k3d image import`. Kubernetes does not build images:
  in a real setup the CI builds and pushes them to a registry.

## Running it

```bash
k3d cluster create inception -p "8443:443@loadbalancer"

echo "127.0.0.1 kkraft.42.fr" | sudo tee -a /etc/hosts

kubectl create secret tls kkraft-tls \
  --cert=./ssl/kkraft.crt --key=./ssl/kkraft.key

./rebuild.sh
```

Then open `https://kkraft.42.fr:8443`.

## Commands I used the most

```bash
kubectl get pods
kubectl describe pod <name>        # the Events at the bottom say what is wrong
kubectl logs <name> --previous     # when a container keeps restarting
kubectl logs -n kube-system deployment/traefik
```