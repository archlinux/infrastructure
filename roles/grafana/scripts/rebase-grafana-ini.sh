#!/bin/bash

mon_grafana_ver=$(ssh root@monitoring.archlinux.org pacman -Q grafana | awk '{print $2}')
git_grafana_ver=$(git log --oneline | grep -Pom1 'rebase grafana.ini to grafana \K\S+')

if [[ -z $mon_grafana_ver ]]; then
  echo >&2 'failed to detect current version on monitoring'
  exit 1
fi

if [[ $(vercmp $git_grafana_ver $mon_grafana_ver) -ge 0 ]]; then
  echo >&2 "already rebased to $git_grafana_ver (>= $mon_grafana_ver on monitoring)"
  exit 1
fi

old_pkg=https://archive.archlinux.org/packages/g/grafana/grafana-$git_grafana_ver-x86_64.pkg.tar.zst
new_pkg=https://archive.archlinux.org/packages/g/grafana/grafana-$mon_grafana_ver-x86_64.pkg.tar.zst

diff -up \
  <(curl -s "$old_pkg" | bsdtar -xOq etc/grafana.ini) \
  <(curl -s "$new_pkg" | bsdtar -xOq etc/grafana.ini) \
  | patch "$(dirname $0)/../templates/grafana.ini.j2"

echo
echo ':: fix any conflicts above, "git add" the changes and commit with:'
echo ":: git commit -m 'grafana: rebase grafana.ini to grafana $mon_grafana_ver'"
