# 0. 시작하기 전에

- 본 과제는 CPU 4코어, Memory 4GB를 최소 리소스로 테스트 되었습니다.
  - 안정된 환경을 위해 Memory는 8GB를 권장합니다.
- 환경은 가상 머신을 통해 Ubuntu 20.04/Focal에서 확인하였습니다.
  - WSL **버전2** 와 VMWare, Windows에서 테스트 해보았습니다.
  - 권장하는 환경은 Windows에서 동작하는것입니다만, 그 외에도 동작됩니다.
- 본 과제의 환경은 vagrant - virtual box를 통해 수행됩니다.
  - Linux 환경에서는 init_env.sh을 통해 자동 설치됩니다.
  - Window 환경에서는 vagrant와 virtual box를 미리 설치 부탁드립니다.
    - vagrant install link: https://releases.hashicorp.com/vagrant/2.3.4/vagrant_2.3.4_windows_amd64.msi
    - virtual box install link: https://download.virtualbox.org/virtualbox/7.0.4/VirtualBox-7.0.4-154605-Win.exe
- **진행되지 않는 상황들에 대해 3. trouble shooting을 확인 해주세요**
- 전체 세팅 시간은 약 50분이 소요됩니다. 중간중간 loading..., Wait 등의 메시지와 함께 진행되지 않는 듯 보일 수 있습니다.

# 1. 실행 방법

- Linux에서 실행할 경우는 init_env.sh을, 윈도우에서 실행할 경우는 init_env.bat을 실행해주세요.

  - 필요한 환경 설치와 어플리케이션 배포 등이 자동화되어 수행됩니다.
  - WSL 환경은 가상 머신이 지원되지 않아 init_env가 동작하지 않습니다.
    - 기타 init_env가 동작하지 않는 경우 trouble shooting의 8번 항목으로 확인 부탁드립니다.

- 확인을 모두 마쳤다면, Vagrantfile이 있는곳에서 vagrant destory -f를 입력해주세요

# 2. 확인 방법

- 모든 설치가 마무리 되면 FINISHED 라는 문구가 나타납니다.
- 또한, 프론트 페이지의 주소가 나타납니다. curl [주소] 혹은 브라우저로 확인할 수 있습니다.

  - 프론트 페이지는 [주소]/, [주소]/sverdle, [주소]/rank로 구성되어 있습니다.
  - 유저 백엔드 서버는 [주소]/user 로 구성되어 있습니다.
  - 점수 백엔드 서버는 [주소]/score 로 구성되어 있습니다.
  - 랭킹 백엔드 서버는 [주소]/ranking으로 구성되어 있습니다.

- kubectl get po,deploy를 수행하면 다음과 같이 나타납니다.
  - 명령이 잘 동작하지 않는다면, trouble shooting의 7번 항목을 참고해주세요
  - pod에 READY가 2임을 확인하여 istio가 동작중인지 파악할 수 있습니다.
  - STATUS가 pending이거나 READY가 2/2로 올라오지 않을 경우, kubectl describe [pod NAME]으로 확인해주세요.

```
NAME                                      READY   STATUS    RESTARTS   AGE
pod/ranking-backend-v1-5b7dfc579-r8cps    2/2     Running   0          8s
pod/score-backend-v1-588f9c7df-qh2r9      2/2     Running   0          8s
pod/user-backend-v1-557b67dcf-pq9mn       2/2     Running   0          8s
pod/wordle-frontend-v1-5485fbbb96-2df7k   2/2     Running   0          8s

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ranking-backend-v1   1/1     1            1           9s
deployment.apps/score-backend-v1     1/1     1            1           9s
deployment.apps/user-backend-v1      1/1     1            1           9s
deployment.apps/wordle-frontend-v1   1/1     1            1           9s
```

- istioctl analyze를 동작하였을 때 istio에서 제공하는 툴에 의해 이슈가 있는지 판단할 수 있습니다.
  - 문제가 없는 경우 아래와 같이 나타납니다.

```
✔ No validation issues found when analyzing namespace: default.
```

# 3. trouble shooting

1. init_env 수행 초반에 진행되지 않을 경우, 경로에 한글이 있는지 확인해주세요. 한글 경로가 있을 경우 동작하지 않습니다.
2. init_env 수행시 커널 패닉이 발생하며 진행되지 않을 경우, vagrant와 virtual box의 버전이 너무 낮을 수 있습니다. 재설치 해주세요.
3. 아래와 유사한 문구가 나오면서 init_env가 진행되지 않는다면 현재 사용중인 네트워크 인터페이스의 번호를 입력해주세요
   3.1 대부분의 경우 1을 입력하면 됩니다.

```
==> default: Available bridged network interfaces:
1) Intel(R) Wi-Fi 6 AX200 160MHz
2) Hyper-V Virtual Ethernet Adapter
3) Hyper-V Virtual Ethernet Adapter #2
==> default: When choosing an interface, it is usually the one that is
==> default: being used to connect to the internet.
==> default:
    default: Which interface should the network bridge to?
```

4. init_env 수행 중 아래의 상태에서 오래걸릴 때는 가상머신의 SSH 연결이 지연되는 상황입니다.
   4.1 네트워크의 상태나 virtual box의 설정을 변경해야 합니다. 어려운 경우, 1. 실행방법의 *init_env가 잘 되지 않는 경우*를 참고해서 진행해주세요.

```shell
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
```

5. docker가 이미 설치된 경우 아래와 같은 메시지가 나오면서 대기할 때가 있습니다. N을 입력해주시면 됩니다.

```shell
File '/etc/apt/keyrings/docker.gpg' exists. Overwrite? (y/N)
```

6. 아래의 문구가 나온 경우, Docker의 동작이 원할하지 않은 경우입니다. Docker 실행을 점검해주세요.

```shell
Command Output: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

7. 아래와 같이 나오는 경우 `kind export kubeconfig`을 입력한 후 kubectl 명령을 입력해주세요.
   6.1 위의 명령을 입력해도 상황이 같다면, kind의 cluster 상태를 확인해야 합니다.

```shell
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

8. 만약, init_env가 잘 동작하지 않을 경우, 아래의 과정을 직접 수행해주세요.
   8.1 src 디렉토리를 리눅스 환경으로 옮긴 후(scp, ftp 등) install.sh 파일을 실행해주세요
   8.2 아래는 예시입니다.

```shell
scp ./src.tgz my-id@192.168.198.128:~/
ssh my-id@192.168.198.128
tar xvzf ./src.tgz
cd src
sudo ./install.sh
```

9. IP가 pending이거나 나타나지 않는다면 metallb 설치에 문제가 있을 수 있습니다.
10. 동작시킨 리눅스가 가상머신이거나 wsl인 경우, 가상 머신이나 wsl 외부에서 접근하기 위해 포워딩이 필요할 수 있습니다.
