GITLAB_PASS=$(sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode)
echo "machine gitlab.k3d.gitlab.com
login root
password ${GITLAB_PASS}" > ~/.netrc

HOST_ENTRY="127.0.0.1 gitlab.localhost"
HOSTS_FILE="/etc/hosts"

if grep -q "$HOST_ENTRY" "$HOSTS_FILE"; then
    echo "exist $HOSTS_FILE"
else
    echo "adding $HOSTS_FILE"
    echo "$HOST_ENTRY" | sudo tee -a "$HOSTS_FILE"
fi

git clone http://gitlab.k3d.gitlab.com/root/mbrettsc.git gitlab_repo
git clone https://github.com/mbrettsc/k3d-argocd-manifests.mbrettsc.git github_repo
mv github_repo/manifests gitlab_repo/
rm -rf github_repo/

cd gitlab_repo
git add *
git commit -m "update"
git push
cd ..

sudo kubectl apply -f confs/argocd/ -n argocd
