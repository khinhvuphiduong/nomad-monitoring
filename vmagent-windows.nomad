job "vmagent-windows" {
  datacenters = ["dc2"]
  namespace = "development-r2"
  type        = "system"
  constraint {
      attribute = "${attr.kernel.name}"
      value     = "windows"
  }

  group "vmagent-windows" {
    count = 1

    network {
      // mode = "bridge"
      port "vmagent-http" {
        to = 8429
      }
    }

    task "vmagent-windows" {
      driver = "raw_exec"

      config {
        command = "${NOMAD_TASK_DIR}/vmagent-windows-amd64-prod.exe"
        args = ["-promscrape.config=${NOMAD_TASK_DIR}/prometheus.yml", "-remoteWrite.url=${VICTORIAMETRICS_ADDR}"]
      }

      artifact {
        source = "https://nomadpackage:ANJVss4UPWpSa@package.citigo.com.vn/endpoints/wintools/content/vmagent-windows-amd64-prod.zip"
        options {
          archive = "zip"
        }
      }

      template {
        data        = file(abspath("./configs/prometheus.tpl.yml"))
        destination = "local/prometheus.yml"
        change_mode = "restart"
      }

      template {
        data = <<EOF
  {{- range service "vicky-web" }}
  VICTORIAMETRICS_ADDR=http://{{ .Address }}:{{ .Port }}/api/v1/write
{{ end -}}
EOF

        destination = "local/env"
        env         = true
      }


      resources {
        cpu    = 256
        memory = 300
      }
    }
  }

}