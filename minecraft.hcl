job "minecraft" {
  datacenters = ["dc1"]
  type        = "service"

  group "minecraft" {
    count = 1

    volume "mc" {
      type      = "host"
      source    = "mc"
      read_only = false
    }

    task "setup" {
      driver = "docker"

      config {
        image = "alpine:latest"
        command = "sh"
        args = [
          "-c",
          "mkdir -p /minecraft && echo 'eula=true' > /minecraft/eula.txt"
        ]
      }

      volume_mount {
        volume      = "mc"
        destination = "/minecraft"
      }

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "eclipse-temurin:17-jdk-jammy"
        command = "sh"
        args = [
          "-c",
          "cd /minecraft && java -Xms1024M -Xmx2048M -jar server.jar --nogui"
        ]
        volumes = [
          "mc:/minecraft"
        ]
      }

      volume_mount {
        volume      = "mc"
        destination = "/minecraft"
      }

      artifact {
        source      = "https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar"
        destination = "/minecraft/server.jar"
      }

      resources {
        cpu    = 1000
        memory = 2048
      }
    }

    network {
      port "minecraft" {
        static = 25565
      }
    }
  }
}
