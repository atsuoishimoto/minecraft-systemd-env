# ScreenなしでMinecraft Javaサーバを運用する

LinuxでMinecraftのModサーバを運用する場合、サーバプロセスの標準入出力を読み書きするためにscreenコマンドなどを利用して起動することが多いようです。Rconポートを開けるのはいやですがいちいちscreenにアタッチするのも面倒な気がしたので、systemdから直接Minecraftを起動して、標準入力にはsocketを利用して書き込めるようにしてみました。

以下の解説では、Ubuntuを利用し、`/opt/minecraft/` ディレクトリに環境を作成する手順を解説しています。また、Minecraftは `/opt/minecraft/neoforge` にインストールしています。

## Systemd設定

このリポジトリを `/opt/minecraft` にcloneします。

```sh
git clone https://github.com/atsuoishimoto/minecraft-systemd-env.git /opt/minecraft
```

以下のコマンドを実行します

```sh
sudo ln -s /opt/minecraft/minecraft-java.service /etc/systemd/system/minecraft-java.service
sudo ln -s /opt/minecraft/minecraft-java.socket /etc/systemd/system/minecraft-java.socket

sudo systemctl daemon-reload

sudo systemctl enable minecraft-java.socket
sudo systemctl enable minecraft-java.service
```

## Minecraft(NeoForge) のインストール

ここでは、NeoForge 21.1.137 をインストールしています。適宜利用するModサーバに読み替えてください。

また、インストール先ディレクトリは `/opt/minecraft/neoforge` としています。

以下のコマンドでJavaをインストールしておきます。

```sh
apt install openjdk-21-jre
```

利用するModサーバのJarファイルをダウンロードし、次のコマンドで `/opt/minecraft/neoforge` にインストールします。

```sh
java -jar neoforge-21.1.137-installer.jar --installServer /opt/minecraft/neoforge
```

「私はMinecraftのエンドユーザライセンスに同意いたします」と誓ってから、次のコマンドを実行します。

```
echo "eula=true" > /opt/minecraft/neoforge/eula.txt
```

## サーバの起動

以下のコマンドでサーバを起動します。

```sh
sudo systemctl start minecraft-java.service
```

journalctlで起動を確認します。

```sh
sudo journalctl -f -u minecraft-java.service
```

この時点で、Minecraftクライアントから接続可能となります。


## サーバの停止

次のコマンドでサーバに `stop` コマンドを送信し、プロセスを終了します。

```sh
sudo systemctl stop minecraft-java.service
```


## サーバコマンドの実行

Minecraftサーバの標準入力は、`/run/minecraft-java.stdin` に接続しています。コマンドを実行する場合は、

```sh
echo list > /run/minecraft-java.stdin
```

のようにコマンドを入力してください。コマンドの実行結果は `journalctl` で確認できます。

```sh
$ sudo journalctl -u minecraft-java.service
[Server thread/INFO] [minecraft/MinecraftServer]: There are 0 of a max of 20 players online:
```
