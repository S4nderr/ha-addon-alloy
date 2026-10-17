// Logarchief — aanvoer vanaf Home Assistant OS. systemd-journal → VictoriaLogs via het loket (Loki-push-API).
// Sjabloon; init-alloy vult __LOKI_URL__, __HOST__, __JOURNAL_PATH__, __MAX_AGE__ en __LOG_LEVEL__ in.
// Zelfde pijplijn als projects\logarchief\journal\config-pve.alloy (ADR 0005/0007), met één HAOS-eigenheid:
// add-ons, Core en Supervisor loggen via Docker naar de journal, dus hun unit is altijd docker.service.
// Daarom wordt CONTAINER_NAME de unit als die er is (homeassistant, hassio_supervisor, addon_…).

logging {
  level = "__LOG_LEVEL__"
}

loki.relabel "journal" {
  forward_to = []

  rule {
    source_labels = ["__journal__systemd_unit"]
    target_label  = "unit"
  }
  rule {
    source_labels = ["unit"]
    regex         = "session-\\d+\\.scope"
    target_label  = "unit"
    replacement   = "session.scope"
  }
  rule {
    source_labels = ["unit"]
    regex         = "user@\\d+\\.service"
    target_label  = "unit"
    replacement   = "user.service"
  }

  rule {
    source_labels = ["__journal_syslog_identifier"]
    target_label  = "ident"
  }

  // HAOS: containerregels krijgen de containernaam als unit (anders is alles docker.service).
  rule {
    source_labels = ["__journal_container_name"]
    regex         = "(.+)"
    target_label  = "unit"
    replacement   = "$1"
  }

  // Regels zonder unit (kernel, early boot): de identifier als unit.
  rule {
    source_labels = ["unit", "ident"]
    regex         = ";(.+)"
    target_label  = "unit"
    replacement   = "$1"
  }

  rule {
    source_labels = ["__journal__transport"]
    target_label  = "transport"
  }
  rule {
    source_labels = ["__journal__pid"]
    target_label  = "pid"
  }

  rule {
    source_labels = ["__journal_priority"]
    target_label  = "priority"
  }
  rule {
    source_labels = ["priority"]
    regex         = "0"
    target_label  = "level"
    replacement   = "emerg"
  }
  rule {
    source_labels = ["priority"]
    regex         = "1"
    target_label  = "level"
    replacement   = "alert"
  }
  rule {
    source_labels = ["priority"]
    regex         = "2"
    target_label  = "level"
    replacement   = "crit"
  }
  rule {
    source_labels = ["priority"]
    regex         = "3"
    target_label  = "level"
    replacement   = "err"
  }
  rule {
    source_labels = ["priority"]
    regex         = "4"
    target_label  = "level"
    replacement   = "warning"
  }
  rule {
    source_labels = ["priority"]
    regex         = "5"
    target_label  = "level"
    replacement   = "notice"
  }
  rule {
    source_labels = ["priority"]
    regex         = "6"
    target_label  = "level"
    replacement   = "info"
  }
  rule {
    source_labels = ["priority"]
    regex         = "7"
    target_label  = "level"
    replacement   = "debug"
  }

  rule {
    target_label = "host"
    replacement  = "__HOST__"
  }
}

loki.source.journal "haos" {
  path          = "__JOURNAL_PATH__"
  max_age       = "__MAX_AGE__"
  relabel_rules = loki.relabel.journal.rules
  forward_to    = [loki.process.journal.receiver]
  // Cursor: /data/alloy (storage.path), overleeft herstarts van de add-on.
}

loki.process "journal" {
  forward_to = [loki.write.logarchief.receiver]

  stage.drop {
    expression          = "^\\s*$"
    drop_counter_reason = "lege_regel"
  }
}

loki.write "logarchief" {
  endpoint {
    url = "__LOKI_URL__"
    headers = {
      "VL-Stream-Fields"     = "host,unit",
      "VL-Decolorize-Fields" = "_msg",
    }
  }
}
