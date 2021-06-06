job "example" {
  datacenters = ["dc1"]
  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }

  migrate {
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "web" {
    count = 1

    network {
      port "http" {
        static = 80
      }
    }

    service {
      name = "test-web"
      port = "http"

      check {
        name     = "health"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:1.19.9"
        ports = ["http"]
        volumes = [
           "consul.html:/usr/share/nginx/html/consul.html"
        ]
      }

      resources {
        cpu    = 500
        memory = 256
      }

      template {
        data          = <<DATA
consul servers list:
{{ range service "consul" }}
{{ .Address }}:{{ .Port }}
{{ end }}
DATA
        destination   = "consul.html"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
