ode Exporter Full	1860	System metrics (CPU, memory, disk, network) for all servers
Dovecot OpenMetrics	14881	Dovecot-specific metrics (auth, IMAP, deliveries)
Prometheus 2.0 Overview	3662	General Prometheus health


# Linux

12486
23146

# Postfix
---
{
  "__inputs": [
    {
      "name": "DS_PROMETHEUS",
      "label": "Prometheus",
      "description": "",
      "type": "datasource",
      "pluginId": "prometheus",
      "pluginName": "Prometheus"
    }
  ],
  "__requires": [
    { "type": "grafana", "id": "grafana", "name": "Grafana", "version": "9.0.0" },
    { "type": "datasource", "id": "prometheus", "name": "Prometheus", "version": "1.0.0" },
    { "type": "panel", "id": "timeseries", "name": "Time series", "version": "" },
    { "type": "panel", "id": "stat", "name": "Stat", "version": "" },
    { "type": "panel", "id": "bargauge", "name": "Bar gauge", "version": "" },
    { "type": "panel", "id": "table", "name": "Table", "version": "" }
  ],
  "annotations": { "list": [] },
  "description": "Postfix mail server monitoring using fluxxu/postfix-exporter metrics",
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 1,
  "id": null,
  "links": [],
  "panels": [

    { "collapsed": false, "gridPos": { "h": 1, "w": 24, "x": 0, "y": 0 }, "id": 100, "title": "Overview", "type": "row" },

    {
      "id": 1, "type": "stat", "title": "Message delivery rate",
      "description": "Successful deliveries per second",
      "gridPos": { "h": 4, "w": 4, "x": 0, "y": 1 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": { "mode": "absolute", "steps": [
            { "color": "green", "value": null }, { "color": "yellow", "value": 10 }, { "color": "red", "value": 50 }
          ]},
          "unit": "reqps", "decimals": 2
        }
      },
      "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "orientation": "auto", "textMode": "auto", "colorMode": "background", "graphMode": "area" },
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum(rate(postfix_statuses_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "deliveries/s" }]
    },

    {
      "id": 2, "type": "stat", "title": "Deferred messages",
      "description": "Messages currently in deferred state",
      "gridPos": { "h": 4, "w": 4, "x": 4, "y": 1 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": { "mode": "absolute", "steps": [
            { "color": "green", "value": null }, { "color": "yellow", "value": 1 }, { "color": "red", "value": 10 }
          ]},
          "unit": "short"
        }
      },
      "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "background", "graphMode": "none" },
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum(increase(postfix_statuses_total{job=~\"$job\", status=\"deferred\"}[$__rate_interval]))", "legendFormat": "deferred" }]
    },

    {
      "id": 3, "type": "stat", "title": "Bounced messages",
      "gridPos": { "h": 4, "w": 4, "x": 8, "y": 1 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": { "mode": "absolute", "steps": [
            { "color": "green", "value": null }, { "color": "red", "value": 1 }
          ]},
          "unit": "short"
        }
      },
      "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "background", "graphMode": "none" },
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum(increase(postfix_statuses_total{job=~\"$job\", status=\"bounced\"}[$__rate_interval]))", "legendFormat": "bounced" }]
    },

    {
      "id": 4, "type": "stat", "title": "Login failures",
      "gridPos": { "h": 4, "w": 4, "x": 12, "y": 1 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": { "mode": "absolute", "steps": [
            { "color": "green", "value": null }, { "color": "yellow", "value": 5 }, { "color": "red", "value": 20 }
          ]},
          "unit": "short"
        }
      },
      "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "background", "graphMode": "area" },
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum(rate(postfix_login_failures_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "failures/s" }]
    },

    {
      "id": 5, "type": "stat", "title": "Parse errors",
      "gridPos": { "h": 4, "w": 4, "x": 16, "y": 1 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": { "mode": "absolute", "steps": [
            { "color": "green", "value": null }, { "color": "yellow", "value": 10 }, { "color": "red", "value": 100 }
          ]},
          "unit": "short"
        }
      },
      "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "value", "graphMode": "area" },
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum(increase(postfix_errors_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "errors" }]
    },

    {
      "id": 6, "type": "stat", "title": "Active connections",
      "gridPos": { "h": 4, "w": 4, "x": 20, "y": 1 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": { "mode": "absolute", "steps": [
            { "color": "blue", "value": null }, { "color": "yellow", "value": 100 }, { "color": "red", "value": 500 }
          ]},
          "unit": "reqps"
        }
      },
      "options": { "reduceOptions": { "calcs": ["lastNotNull"] }, "colorMode": "background", "graphMode": "area" },
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum(rate(postfix_connects_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "connects/s" }]
    },

    { "collapsed": false, "gridPos": { "h": 1, "w": 24, "x": 0, "y": 5 }, "id": 101, "title": "Message delivery", "type": "row" },

    {
      "id": 10, "type": "timeseries", "title": "Message statuses rate",
      "description": "Rate of message status changes by subprogram and status",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 6 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1, "fillOpacity": 10 } }
      },
      "options": { "tooltip": { "mode": "multi", "sort": "desc" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull", "mean"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (subprogram, status) (rate(postfix_statuses_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "{{subprogram}} / {{status}}" }
      ]
    },

    {
      "id": 11, "type": "timeseries", "title": "Delivery delay (p50 / p95 / p99)",
      "description": "Message processing delay percentiles by subprogram and status",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 6 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "s", "custom": { "lineWidth": 1, "fillOpacity": 5 } }
      },
      "options": { "tooltip": { "mode": "multi", "sort": "desc" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull", "mean"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "histogram_quantile(0.50, sum by (le, subprogram, status) (rate(postfix_delay_seconds_bucket{job=~\"$job\"}[$__rate_interval])))", "legendFormat": "p50 {{subprogram}}/{{status}}" },
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "histogram_quantile(0.95, sum by (le, subprogram, status) (rate(postfix_delay_seconds_bucket{job=~\"$job\"}[$__rate_interval])))", "legendFormat": "p95 {{subprogram}}/{{status}}" },
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "histogram_quantile(0.99, sum by (le, subprogram, status) (rate(postfix_delay_seconds_bucket{job=~\"$job\"}[$__rate_interval])))", "legendFormat": "p99 {{subprogram}}/{{status}}" }
      ]
    },

    {
      "id": 12, "type": "timeseries", "title": "Queue manager statuses",
      "description": "Postfix qmgr message status events",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 14 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1, "fillOpacity": 10 } }
      },
      "options": { "tooltip": { "mode": "multi" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (status) (rate(postfix_qmgr_statuses_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "qmgr / {{status}}" }
      ]
    },

    {
      "id": 13, "type": "timeseries", "title": "Status reply codes",
      "description": "Server message status reply codes (requires config)",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 14 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1 } }
      },
      "options": { "tooltip": { "mode": "multi" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (subprogram, status, code, enhanced_code) (rate(postfix_status_replies_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "{{subprogram}} {{status}} {{code}} {{enhanced_code}}" }
      ]
    },

    { "collapsed": false, "gridPos": { "h": 1, "w": 24, "x": 0, "y": 22 }, "id": 102, "title": "Connections", "type": "row" },

    {
      "id": 20, "type": "timeseries", "title": "Connect / disconnect rate",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 23 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1, "fillOpacity": 10 } }
      },
      "options": { "tooltip": { "mode": "multi" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull", "mean"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (subprogram) (rate(postfix_connects_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "connect {{subprogram}}" },
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (subprogram) (rate(postfix_disconnects_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "disconnect {{subprogram}}" }
      ]
    },

    {
      "id": 21, "type": "timeseries", "title": "Lost connections",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 23 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1, "fillOpacity": 10 },
          "color": { "fixedColor": "orange", "mode": "fixed" }
        }
      },
      "options": { "tooltip": { "mode": "multi" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (subprogram) (rate(postfix_lost_connections_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "lost {{subprogram}}" }
      ]
    },

    {
      "id": 22, "type": "timeseries", "title": "Not resolved hostnames",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 31 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1 } }
      },
      "options": { "tooltip": { "mode": "multi" }, "legend": { "displayMode": "list", "placement": "bottom" } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (subprogram) (rate(postfix_not_resolved_hostnames_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "{{subprogram}}" }
      ]
    },

    {
      "id": 23, "type": "timeseries", "title": "Postscreen actions",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 31 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1, "fillOpacity": 10 } }
      },
      "options": { "tooltip": { "mode": "multi" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (action) (rate(postfix_postscreen_actions_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "{{action}}" }
      ]
    },

    { "collapsed": false, "gridPos": { "h": 1, "w": 24, "x": 0, "y": 39 }, "id": 103, "title": "SMTP & rejections", "type": "row" },

    {
      "id": 30, "type": "timeseries", "title": "SMTP reply codes",
      "description": "SMTP server reply codes (requires config)",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 40 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1, "fillOpacity": 10 } }
      },
      "options": { "tooltip": { "mode": "multi" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (code, enhanced_code) (rate(postfix_smtp_replies_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "{{code}} {{enhanced_code}}" }
      ]
    },

    {
      "id": 31, "type": "timeseries", "title": "NOQUEUE reject replies",
      "description": "NOQUEUE: reject events by code (requires config)",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 40 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1, "fillOpacity": 10 },
          "color": { "fixedColor": "red", "mode": "fixed" }
        }
      },
      "options": { "tooltip": { "mode": "multi" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (subprogram, command, code, enhanced_code) (rate(postfix_noqueue_reject_replies_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "{{subprogram}} {{command}} {{code}} {{enhanced_code}}" }
      ]
    },

    {
      "id": 32, "type": "timeseries", "title": "Login failures by method",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 48 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1, "fillOpacity": 10 },
          "color": { "fixedColor": "dark-orange", "mode": "fixed" }
        }
      },
      "options": { "tooltip": { "mode": "multi" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (subprogram, method) (rate(postfix_login_failures_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "{{subprogram}} / {{method}}" }
      ]
    },

    {
      "id": 33, "type": "timeseries", "title": "Milter actions",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 48 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1 } }
      },
      "options": { "tooltip": { "mode": "multi" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (subprogram, action) (rate(postfix_milter_actions_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "{{subprogram}} / {{action}}" }
      ]
    },

    { "collapsed": false, "gridPos": { "h": 1, "w": 24, "x": 0, "y": 56 }, "id": 104, "title": "Log processing", "type": "row" },

    {
      "id": 40, "type": "timeseries", "title": "Log records processed",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 57 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1, "fillOpacity": 10 } }
      },
      "options": { "tooltip": { "mode": "multi" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull", "mean"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "sum by (subprogram, severity) (rate(postfix_logs_total{job=~\"$job\"}[$__rate_interval]))", "legendFormat": "{{subprogram}} / {{severity}}" }
      ]
    },

    {
      "id": 41, "type": "timeseries", "title": "Errors / unsupported / foreign log records",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 57 },
      "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
      "fieldConfig": {
        "defaults": { "unit": "reqps", "custom": { "lineWidth": 1, "fillOpacity": 10 } }
      },
      "options": { "tooltip": { "mode": "multi" }, "legend": { "displayMode": "table", "placement": "bottom", "calcs": ["lastNotNull"] } },
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "rate(postfix_errors_total{job=~\"$job\"}[$__rate_interval])", "legendFormat": "parse errors" },
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "rate(postfix_unsupported_total{job=~\"$job\"}[$__rate_interval])", "legendFormat": "unsupported" },
        { "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" }, "expr": "rate(postfix_foreign_total{job=~\"$job\"}[$__rate_interval])", "legendFormat": "foreign" }
      ]
    }

  ],
  "refresh": "30s",
  "schemaVersion": 36,
  "style": "dark",
  "tags": ["postfix", "email", "prometheus"],
  "templating": {
    "list": [
      {
        "current": {},
        "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
        "definition": "label_values(postfix_logs_total, job)",
        "hide": 0,
        "includeAll": true,
        "multi": false,
        "name": "job",
        "options": [],
        "query": { "query": "label_values(postfix_logs_total, job)", "refId": "StandardVariableQuery" },
        "refresh": 2,
        "regex": "",
        "sort": 1,
        "type": "query",
        "label": "Job"
      },
      {
        "current": {},
        "datasource": { "type": "prometheus", "uid": "${DS_PROMETHEUS}" },
        "definition": "label_values(postfix_logs_total{job=~\"$job\"}, instance)",
        "hide": 0,
        "includeAll": true,
        "multi": true,
        "name": "instance",
        "options": [],
        "query": { "query": "label_values(postfix_logs_total{job=~\"$job\"}, instance)", "refId": "StandardVariableQuery" },
        "refresh": 2,
        "regex": "",
        "sort": 1,
        "type": "query",
        "label": "Instance"
      }
    ]
  },
  "time": { "from": "now-3h", "to": "now" },
  "timepicker": {},
  "timezone": "browser",
  "title": "Postfix (fluxxu exporter)",
  "uid": "postfix-fluxxu-v1",
  "version": 1
}
---

# Unbound

21006 - works 




# VAlkey
11835


 
# Dovecot

---
{
  "annotations": [
    {
      "kind": "AnnotationQuery",
      "spec": {
        "builtIn": true,
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "query": {
          "datasource": {
            "name": "-- Grafana --"
          },
          "group": "grafana",
          "kind": "DataQuery",
          "spec": {},
          "version": "v0"
        }
      }
    }
  ],
  "cursorSync": "Crosshair",
  "description": "Dovecot 2.4 native Prometheus metrics dashboard. Covers auth, IMAP commands, mail delivery, and user sessions.",
  "editable": true,
  "elements": {
    "panel-1": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "dovecot_auth_successes_total{instance=~\"$instance\"}",
                      "legendFormat": "Successes"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 1,
        "links": [],
        "title": "Auth Successes (total)",
        "vizConfig": {
          "group": "stat",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "thresholds"
                },
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    }
                  ]
                },
                "unit": "short"
              },
              "overrides": []
            },
            "options": {
              "colorMode": "background",
              "graphMode": "none",
              "justifyMode": "center",
              "orientation": "auto",
              "percentChangeColorMode": "standard",
              "reduceOptions": {
                "calcs": [
                  "lastNotNull"
                ],
                "fields": "",
                "values": false
              },
              "showPercentChange": false,
              "textMode": "auto",
              "wideLayout": true
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-10": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_auth_successes_total{instance=~\"$instance\"}[5m])",
                      "legendFormat": "Auth Successes/s"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              },
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_auth_failures_total{instance=~\"$instance\"}[5m])",
                      "legendFormat": "Auth Failures/s"
                    },
                    "version": "v0"
                  },
                  "refId": "B"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 10,
        "links": [],
        "title": "Authentication Rate",
        "vizConfig": {
          "group": "timeseries",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisBorderShow": false,
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "",
                  "axisPlacement": "auto",
                  "barAlignment": 0,
                  "barWidthFactor": 0.6,
                  "drawStyle": "line",
                  "fillOpacity": 15,
                  "gradientMode": "none",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "insertNulls": false,
                  "lineInterpolation": "smooth",
                  "lineWidth": 2,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "never",
                  "showValues": false,
                  "spanNulls": false,
                  "stacking": {
                    "group": "A",
                    "mode": "none"
                  },
                  "thresholdsStyle": {
                    "mode": "off"
                  }
                },
                "min": 0,
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                },
                "unit": "ops"
              },
              "overrides": [
                {
                  "matcher": {
                    "id": "byName",
                    "options": "Auth Failures/s"
                  },
                  "properties": [
                    {
                      "id": "color",
                      "value": {
                        "fixedColor": "red",
                        "mode": "fixed"
                      }
                    }
                  ]
                },
                {
                  "matcher": {
                    "id": "byName",
                    "options": "Auth Successes/s"
                  },
                  "properties": [
                    {
                      "id": "color",
                      "value": {
                        "fixedColor": "green",
                        "mode": "fixed"
                      }
                    }
                  ]
                }
              ]
            },
            "options": {
              "annotations": {
                "clustering": -1,
                "multiLane": false
              },
              "legend": {
                "calcs": [
                  "mean",
                  "max"
                ],
                "displayMode": "table",
                "placement": "bottom",
                "showLegend": true
              },
              "tooltip": {
                "hideZeros": false,
                "mode": "multi",
                "sort": "desc"
              }
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-11": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_auth_successes_duration_seconds_total{instance=~\"$instance\"}[5m]) / rate(dovecot_auth_successes_total{instance=~\"$instance\"}[5m])",
                      "legendFormat": "Avg Success Duration"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              },
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_auth_failures_duration_seconds_total{instance=~\"$instance\"}[5m]) / rate(dovecot_auth_failures_total{instance=~\"$instance\"}[5m])",
                      "legendFormat": "Avg Failure Duration"
                    },
                    "version": "v0"
                  },
                  "refId": "B"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 11,
        "links": [],
        "title": "Average Auth Duration",
        "vizConfig": {
          "group": "timeseries",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisBorderShow": false,
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "",
                  "axisPlacement": "auto",
                  "barAlignment": 0,
                  "barWidthFactor": 0.6,
                  "drawStyle": "line",
                  "fillOpacity": 15,
                  "gradientMode": "none",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "insertNulls": false,
                  "lineInterpolation": "smooth",
                  "lineWidth": 2,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "never",
                  "showValues": false,
                  "spanNulls": false,
                  "stacking": {
                    "group": "A",
                    "mode": "none"
                  },
                  "thresholdsStyle": {
                    "mode": "off"
                  }
                },
                "min": 0,
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                },
                "unit": "s"
              },
              "overrides": []
            },
            "options": {
              "annotations": {
                "clustering": -1,
                "multiLane": false
              },
              "legend": {
                "calcs": [
                  "mean",
                  "max"
                ],
                "displayMode": "table",
                "placement": "bottom",
                "showLegend": true
              },
              "tooltip": {
                "hideZeros": false,
                "mode": "multi",
                "sort": "desc"
              }
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-2": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "dovecot_auth_failures_total{instance=~\"$instance\"}",
                      "legendFormat": "Failures"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 2,
        "links": [],
        "title": "Auth Failures (total)",
        "vizConfig": {
          "group": "stat",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "thresholds"
                },
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "yellow",
                      "value": 1
                    },
                    {
                      "color": "red",
                      "value": 10
                    }
                  ]
                },
                "unit": "short"
              },
              "overrides": []
            },
            "options": {
              "colorMode": "background",
              "graphMode": "none",
              "justifyMode": "center",
              "orientation": "auto",
              "percentChangeColorMode": "standard",
              "reduceOptions": {
                "calcs": [
                  "lastNotNull"
                ],
                "fields": "",
                "values": false
              },
              "showPercentChange": false,
              "textMode": "auto",
              "wideLayout": true
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-20": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_imap_commands_total{instance=~\"$instance\", cmd_name!=\"\", tagged_reply_state=\"OK\"}[5m])",
                      "legendFormat": "{{cmd_name}}"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 20,
        "links": [],
        "title": "IMAP Command Rate by Command",
        "vizConfig": {
          "group": "timeseries",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisBorderShow": false,
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "",
                  "axisPlacement": "auto",
                  "barAlignment": 0,
                  "barWidthFactor": 0.6,
                  "drawStyle": "line",
                  "fillOpacity": 10,
                  "gradientMode": "none",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "insertNulls": false,
                  "lineInterpolation": "smooth",
                  "lineWidth": 2,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "never",
                  "showValues": false,
                  "spanNulls": false,
                  "stacking": {
                    "group": "A",
                    "mode": "none"
                  },
                  "thresholdsStyle": {
                    "mode": "off"
                  }
                },
                "min": 0,
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                },
                "unit": "ops"
              },
              "overrides": []
            },
            "options": {
              "annotations": {
                "clustering": -1,
                "multiLane": false
              },
              "legend": {
                "calcs": [
                  "mean",
                  "max"
                ],
                "displayMode": "table",
                "placement": "right",
                "showLegend": true
              },
              "tooltip": {
                "hideZeros": false,
                "mode": "multi",
                "sort": "desc"
              }
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-21": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "dovecot_imap_commands_total{instance=~\"$instance\", cmd_name!=\"\", tagged_reply_state=\"OK\"}",
                      "instant": true,
                      "legendFormat": "{{cmd_name}}"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 21,
        "links": [],
        "title": "IMAP Command Distribution (total)",
        "vizConfig": {
          "group": "piechart",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  }
                },
                "unit": "short"
              },
              "overrides": []
            },
            "options": {
              "legend": {
                "displayMode": "table",
                "placement": "bottom",
                "showLegend": true,
                "values": [
                  "value",
                  "percent"
                ]
              },
              "pieType": "donut",
              "reduceOptions": {
                "calcs": [
                  "lastNotNull"
                ],
                "fields": "",
                "values": false
              },
              "sort": "desc",
              "tooltip": {
                "hideZeros": false,
                "mode": "single",
                "sort": "none"
              }
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-22": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_imap_commands_duration_seconds_total{instance=~\"$instance\", cmd_name!=\"\", tagged_reply_state=\"OK\"}[5m]) / rate(dovecot_imap_commands_total{instance=~\"$instance\", cmd_name!=\"\", tagged_reply_state=\"OK\"}[5m])",
                      "legendFormat": "{{cmd_name}}"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 22,
        "links": [],
        "title": "Average IMAP Command Duration by Command",
        "vizConfig": {
          "group": "timeseries",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisBorderShow": false,
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "",
                  "axisPlacement": "auto",
                  "barAlignment": 0,
                  "barWidthFactor": 0.6,
                  "drawStyle": "line",
                  "fillOpacity": 10,
                  "gradientMode": "none",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "insertNulls": false,
                  "lineInterpolation": "smooth",
                  "lineWidth": 2,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "never",
                  "showValues": false,
                  "spanNulls": false,
                  "stacking": {
                    "group": "A",
                    "mode": "none"
                  },
                  "thresholdsStyle": {
                    "mode": "off"
                  }
                },
                "min": 0,
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                },
                "unit": "s"
              },
              "overrides": []
            },
            "options": {
              "annotations": {
                "clustering": -1,
                "multiLane": false
              },
              "legend": {
                "calcs": [
                  "mean",
                  "max"
                ],
                "displayMode": "table",
                "placement": "right",
                "showLegend": true
              },
              "tooltip": {
                "hideZeros": false,
                "mode": "multi",
                "sort": "desc"
              }
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-23": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "dovecot_imap_commands_total{instance=~\"$instance\", cmd_name!=\"\", tagged_reply_state=\"OK\"}",
                      "format": "table",
                      "instant": true,
                      "legendFormat": "{{cmd_name}}"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              },
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "dovecot_imap_commands_duration_seconds_total{instance=~\"$instance\", cmd_name!=\"\", tagged_reply_state=\"OK\"} / dovecot_imap_commands_total{instance=~\"$instance\", cmd_name!=\"\", tagged_reply_state=\"OK\"} * 1000",
                      "format": "table",
                      "instant": true,
                      "legendFormat": "{{cmd_name}}"
                    },
                    "version": "v0"
                  },
                  "refId": "B"
                }
              }
            ],
            "queryOptions": {},
            "transformations": [
              {
                "group": "merge",
                "kind": "Transformation",
                "spec": {
                  "options": {}
                }
              },
              {
                "group": "organize",
                "kind": "Transformation",
                "spec": {
                  "options": {
                    "excludeByName": {
                      "Time": true,
                      "__name__": true,
                      "instance": true,
                      "job": true,
                      "tagged_reply_state": true
                    },
                    "renameByName": {
                      "Value #A": "Total Count",
                      "Value #B": "Avg Duration (ms)",
                      "cmd_name": "Command"
                    }
                  }
                }
              }
            ]
          }
        },
        "description": "",
        "id": 23,
        "links": [],
        "title": "IMAP Command Summary Table",
        "vizConfig": {
          "group": "table",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "thresholds"
                },
                "custom": {
                  "align": "auto",
                  "cellOptions": {
                    "type": "color-background"
                  },
                  "footer": {
                    "reducers": []
                  },
                  "inspect": false
                },
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "super-light-green",
                      "value": 0
                    }
                  ]
                },
                "unit": "short"
              },
              "overrides": [
                {
                  "matcher": {
                    "id": "byName",
                    "options": "Avg Duration (ms)"
                  },
                  "properties": [
                    {
                      "id": "unit",
                      "value": "ms"
                    },
                    {
                      "id": "thresholds",
                      "value": {
                        "mode": "absolute",
                        "steps": [
                          {
                            "color": "green",
                            "value": 0
                          }
                        ]
                      }
                    }
                  ]
                }
              ]
            },
            "options": {
              "cellHeight": "sm",
              "showHeader": true,
              "sortBy": [
                {
                  "desc": true,
                  "displayName": "Total Count"
                }
              ]
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-3": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "dovecot_imap_commands_count{instance=~\"$instance\"}",
                      "legendFormat": "Commands"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 3,
        "links": [],
        "title": "IMAP Commands (total)",
        "vizConfig": {
          "group": "stat",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "thresholds"
                },
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "blue",
                      "value": 0
                    }
                  ]
                },
                "unit": "short"
              },
              "overrides": []
            },
            "options": {
              "colorMode": "background",
              "graphMode": "none",
              "justifyMode": "center",
              "orientation": "auto",
              "percentChangeColorMode": "standard",
              "reduceOptions": {
                "calcs": [
                  "lastNotNull"
                ],
                "fields": "",
                "values": false
              },
              "showPercentChange": false,
              "textMode": "auto",
              "wideLayout": true
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-30": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_mail_deliveries_total{instance=~\"$instance\"}[5m])",
                      "legendFormat": "Deliveries/s"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              },
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_mail_submissions_total{instance=~\"$instance\"}[5m])",
                      "legendFormat": "Submissions/s"
                    },
                    "version": "v0"
                  },
                  "refId": "B"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 30,
        "links": [],
        "title": "Mail Delivery & Submission Rate",
        "vizConfig": {
          "group": "timeseries",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisBorderShow": false,
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "",
                  "axisPlacement": "auto",
                  "barAlignment": 0,
                  "barWidthFactor": 0.6,
                  "drawStyle": "bars",
                  "fillOpacity": 80,
                  "gradientMode": "none",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "insertNulls": false,
                  "lineInterpolation": "linear",
                  "lineWidth": 1,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "never",
                  "showValues": false,
                  "spanNulls": false,
                  "stacking": {
                    "group": "A",
                    "mode": "none"
                  },
                  "thresholdsStyle": {
                    "mode": "off"
                  }
                },
                "min": 0,
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                },
                "unit": "ops"
              },
              "overrides": []
            },
            "options": {
              "annotations": {
                "clustering": -1,
                "multiLane": false
              },
              "legend": {
                "calcs": [
                  "mean",
                  "max",
                  "sum"
                ],
                "displayMode": "table",
                "placement": "bottom",
                "showLegend": true
              },
              "tooltip": {
                "hideZeros": false,
                "mode": "multi",
                "sort": "desc"
              }
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-31": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_mail_deliveries_duration_seconds_total{instance=~\"$instance\"}[5m]) / rate(dovecot_mail_deliveries_total{instance=~\"$instance\"}[5m])",
                      "legendFormat": "Avg Delivery Duration"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 31,
        "links": [],
        "title": "Average Mail Delivery Duration",
        "vizConfig": {
          "group": "timeseries",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisBorderShow": false,
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "",
                  "axisPlacement": "auto",
                  "barAlignment": 0,
                  "barWidthFactor": 0.6,
                  "drawStyle": "line",
                  "fillOpacity": 15,
                  "gradientMode": "none",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "insertNulls": false,
                  "lineInterpolation": "smooth",
                  "lineWidth": 2,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "never",
                  "showValues": false,
                  "spanNulls": false,
                  "stacking": {
                    "group": "A",
                    "mode": "none"
                  },
                  "thresholdsStyle": {
                    "mode": "off"
                  }
                },
                "min": 0,
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                },
                "unit": "s"
              },
              "overrides": []
            },
            "options": {
              "annotations": {
                "clustering": -1,
                "multiLane": false
              },
              "legend": {
                "calcs": [
                  "mean",
                  "max"
                ],
                "displayMode": "table",
                "placement": "bottom",
                "showLegend": true
              },
              "tooltip": {
                "hideZeros": false,
                "mode": "multi",
                "sort": "desc"
              }
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-4": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "dovecot_mail_user_sessions_total{instance=~\"$instance\"}",
                      "legendFormat": "Sessions"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 4,
        "links": [],
        "title": "User Sessions (total)",
        "vizConfig": {
          "group": "stat",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "thresholds"
                },
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "purple",
                      "value": 0
                    }
                  ]
                },
                "unit": "short"
              },
              "overrides": []
            },
            "options": {
              "colorMode": "background",
              "graphMode": "none",
              "justifyMode": "center",
              "orientation": "auto",
              "percentChangeColorMode": "standard",
              "reduceOptions": {
                "calcs": [
                  "lastNotNull"
                ],
                "fields": "",
                "values": false
              },
              "showPercentChange": false,
              "textMode": "auto",
              "wideLayout": true
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-40": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_mail_user_sessions_total{instance=~\"$instance\"}[5m])",
                      "legendFormat": "Sessions/s"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 40,
        "links": [],
        "title": "User Session Rate",
        "vizConfig": {
          "group": "timeseries",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisBorderShow": false,
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "",
                  "axisPlacement": "auto",
                  "barAlignment": 0,
                  "barWidthFactor": 0.6,
                  "drawStyle": "line",
                  "fillOpacity": 20,
                  "gradientMode": "opacity",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "insertNulls": false,
                  "lineInterpolation": "smooth",
                  "lineWidth": 2,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "never",
                  "showValues": false,
                  "spanNulls": false,
                  "stacking": {
                    "group": "A",
                    "mode": "none"
                  },
                  "thresholdsStyle": {
                    "mode": "off"
                  }
                },
                "min": 0,
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                },
                "unit": "ops"
              },
              "overrides": []
            },
            "options": {
              "annotations": {
                "clustering": -1,
                "multiLane": false
              },
              "legend": {
                "calcs": [
                  "mean",
                  "max"
                ],
                "displayMode": "table",
                "placement": "bottom",
                "showLegend": true
              },
              "tooltip": {
                "hideZeros": false,
                "mode": "multi",
                "sort": "desc"
              }
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-41": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_mail_user_sessions_duration_seconds_total{instance=~\"$instance\"}[5m]) / rate(dovecot_mail_user_sessions_total{instance=~\"$instance\"}[5m])",
                      "legendFormat": "Avg Session Duration"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 41,
        "links": [],
        "title": "Average Session Duration",
        "vizConfig": {
          "group": "timeseries",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisBorderShow": false,
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "",
                  "axisPlacement": "auto",
                  "barAlignment": 0,
                  "barWidthFactor": 0.6,
                  "drawStyle": "line",
                  "fillOpacity": 15,
                  "gradientMode": "none",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "insertNulls": false,
                  "lineInterpolation": "smooth",
                  "lineWidth": 2,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "never",
                  "showValues": false,
                  "spanNulls": false,
                  "stacking": {
                    "group": "A",
                    "mode": "none"
                  },
                  "thresholdsStyle": {
                    "mode": "off"
                  }
                },
                "min": 0,
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                },
                "unit": "s"
              },
              "overrides": []
            },
            "options": {
              "annotations": {
                "clustering": -1,
                "multiLane": false
              },
              "legend": {
                "calcs": [
                  "mean",
                  "max"
                ],
                "displayMode": "table",
                "placement": "bottom",
                "showLegend": true
              },
              "tooltip": {
                "hideZeros": false,
                "mode": "multi",
                "sort": "desc"
              }
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-42": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_mail_user_sessions_rss_total{instance=~\"$instance\"}[5m])",
                      "legendFormat": "RSS bytes/s"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 42,
        "links": [],
        "title": "Session Memory Usage (RSS rate)",
        "vizConfig": {
          "group": "timeseries",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisBorderShow": false,
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "",
                  "axisPlacement": "auto",
                  "barAlignment": 0,
                  "barWidthFactor": 0.6,
                  "drawStyle": "line",
                  "fillOpacity": 15,
                  "gradientMode": "none",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "insertNulls": false,
                  "lineInterpolation": "smooth",
                  "lineWidth": 2,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "never",
                  "showValues": false,
                  "spanNulls": false,
                  "stacking": {
                    "group": "A",
                    "mode": "none"
                  },
                  "thresholdsStyle": {
                    "mode": "off"
                  }
                },
                "min": 0,
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                },
                "unit": "bytes"
              },
              "overrides": []
            },
            "options": {
              "annotations": {
                "clustering": -1,
                "multiLane": false
              },
              "legend": {
                "calcs": [
                  "mean",
                  "max"
                ],
                "displayMode": "table",
                "placement": "bottom",
                "showLegend": true
              },
              "tooltip": {
                "hideZeros": false,
                "mode": "multi",
                "sort": "desc"
              }
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-43": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_mail_user_sessions_utime_total{instance=~\"$instance\"}[5m])",
                      "legendFormat": "User CPU time/s"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              },
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "rate(dovecot_mail_user_sessions_stime_total{instance=~\"$instance\"}[5m])",
                      "legendFormat": "System CPU time/s"
                    },
                    "version": "v0"
                  },
                  "refId": "B"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 43,
        "links": [],
        "title": "Session CPU Time (utime + stime rate)",
        "vizConfig": {
          "group": "timeseries",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "palette-classic"
                },
                "custom": {
                  "axisBorderShow": false,
                  "axisCenteredZero": false,
                  "axisColorMode": "text",
                  "axisLabel": "",
                  "axisPlacement": "auto",
                  "barAlignment": 0,
                  "barWidthFactor": 0.6,
                  "drawStyle": "line",
                  "fillOpacity": 10,
                  "gradientMode": "none",
                  "hideFrom": {
                    "legend": false,
                    "tooltip": false,
                    "viz": false
                  },
                  "insertNulls": false,
                  "lineInterpolation": "smooth",
                  "lineWidth": 2,
                  "pointSize": 5,
                  "scaleDistribution": {
                    "type": "linear"
                  },
                  "showPoints": "never",
                  "showValues": false,
                  "spanNulls": false,
                  "stacking": {
                    "group": "A",
                    "mode": "normal"
                  },
                  "thresholdsStyle": {
                    "mode": "off"
                  }
                },
                "min": 0,
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "green",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 80
                    }
                  ]
                },
                "unit": "short"
              },
              "overrides": []
            },
            "options": {
              "annotations": {
                "clustering": -1,
                "multiLane": false
              },
              "legend": {
                "calcs": [
                  "mean",
                  "max"
                ],
                "displayMode": "table",
                "placement": "bottom",
                "showLegend": true
              },
              "tooltip": {
                "hideZeros": false,
                "mode": "multi",
                "sort": "desc"
              }
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-5": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "dovecot_mail_deliveries_total{instance=~\"$instance\"}",
                      "legendFormat": "Deliveries"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 5,
        "links": [],
        "title": "Mail Deliveries (total)",
        "vizConfig": {
          "group": "stat",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "thresholds"
                },
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "teal",
                      "value": 0
                    }
                  ]
                },
                "unit": "short"
              },
              "overrides": []
            },
            "options": {
              "colorMode": "background",
              "graphMode": "none",
              "justifyMode": "center",
              "orientation": "auto",
              "percentChangeColorMode": "standard",
              "reduceOptions": {
                "calcs": [
                  "lastNotNull"
                ],
                "fields": "",
                "values": false
              },
              "showPercentChange": false,
              "textMode": "auto",
              "wideLayout": true
            }
          },
          "version": "13.0.1"
        }
      }
    },
    "panel-6": {
      "kind": "Panel",
      "spec": {
        "data": {
          "kind": "QueryGroup",
          "spec": {
            "queries": [
              {
                "kind": "PanelQuery",
                "spec": {
                  "hidden": false,
                  "query": {
                    "datasource": {
                      "name": "${datasource}"
                    },
                    "group": "prometheus",
                    "kind": "DataQuery",
                    "spec": {
                      "expr": "dovecot_auth_failures_total{instance=~\"$instance\"} / (dovecot_auth_successes_total{instance=~\"$instance\"} + dovecot_auth_failures_total{instance=~\"$instance\"})",
                      "legendFormat": "Failure Rate"
                    },
                    "version": "v0"
                  },
                  "refId": "A"
                }
              }
            ],
            "queryOptions": {},
            "transformations": []
          }
        },
        "description": "",
        "id": 6,
        "links": [],
        "title": "Auth Failure Rate",
        "vizConfig": {
          "group": "stat",
          "kind": "VizConfig",
          "spec": {
            "fieldConfig": {
              "defaults": {
                "color": {
                  "mode": "thresholds"
                },
                "max": 1,
                "min": 0,
                "thresholds": {
                  "mode": "absolute",
                  "steps": [
                    {
                      "color": "dark-red",
                      "value": 0
                    },
                    {
                      "color": "red",
                      "value": 0.05
                    }
                  ]
                },
                "unit": "percentunit"
              },
              "overrides": []
            },
            "options": {
              "colorMode": "background",
              "graphMode": "none",
              "justifyMode": "center",
              "orientation": "auto",
              "percentChangeColorMode": "standard",
              "reduceOptions": {
                "calcs": [
                  "lastNotNull"
                ],
                "fields": "",
                "values": false
              },
              "showPercentChange": false,
              "textMode": "auto",
              "wideLayout": true
            }
          },
          "version": "13.0.1"
        }
      }
    }
  },
  "layout": {
    "kind": "RowsLayout",
    "spec": {
      "rows": [
        {
          "kind": "RowsLayoutRow",
          "spec": {
            "collapse": false,
            "layout": {
              "kind": "GridLayout",
              "spec": {
                "items": [
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-1"
                      },
                      "height": 4,
                      "width": 4,
                      "x": 0,
                      "y": 0
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-2"
                      },
                      "height": 4,
                      "width": 4,
                      "x": 4,
                      "y": 0
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-3"
                      },
                      "height": 4,
                      "width": 4,
                      "x": 8,
                      "y": 0
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-4"
                      },
                      "height": 4,
                      "width": 4,
                      "x": 12,
                      "y": 0
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-5"
                      },
                      "height": 4,
                      "width": 4,
                      "x": 16,
                      "y": 0
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-6"
                      },
                      "height": 4,
                      "width": 4,
                      "x": 20,
                      "y": 0
                    }
                  }
                ]
              }
            },
            "title": "Overview"
          }
        },
        {
          "kind": "RowsLayoutRow",
          "spec": {
            "collapse": false,
            "layout": {
              "kind": "GridLayout",
              "spec": {
                "items": [
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-30"
                      },
                      "height": 8,
                      "width": 12,
                      "x": 0,
                      "y": 0
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-31"
                      },
                      "height": 8,
                      "width": 12,
                      "x": 12,
                      "y": 0
                    }
                  }
                ]
              }
            },
            "title": "Mail Delivery & Submissions"
          }
        },
        {
          "kind": "RowsLayoutRow",
          "spec": {
            "collapse": false,
            "layout": {
              "kind": "GridLayout",
              "spec": {
                "items": [
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-10"
                      },
                      "height": 8,
                      "width": 12,
                      "x": 0,
                      "y": 0
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-11"
                      },
                      "height": 8,
                      "width": 12,
                      "x": 12,
                      "y": 0
                    }
                  }
                ]
              }
            },
            "title": "Authentication"
          }
        },
        {
          "kind": "RowsLayoutRow",
          "spec": {
            "collapse": false,
            "layout": {
              "kind": "GridLayout",
              "spec": {
                "items": [
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-40"
                      },
                      "height": 8,
                      "width": 8,
                      "x": 0,
                      "y": 0
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-41"
                      },
                      "height": 8,
                      "width": 8,
                      "x": 8,
                      "y": 0
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-42"
                      },
                      "height": 8,
                      "width": 8,
                      "x": 16,
                      "y": 0
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-43"
                      },
                      "height": 8,
                      "width": 24,
                      "x": 0,
                      "y": 8
                    }
                  }
                ]
              }
            },
            "title": "User Sessions"
          }
        },
        {
          "kind": "RowsLayoutRow",
          "spec": {
            "collapse": false,
            "layout": {
              "kind": "GridLayout",
              "spec": {
                "items": [
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-20"
                      },
                      "height": 9,
                      "width": 16,
                      "x": 0,
                      "y": 0
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-21"
                      },
                      "height": 9,
                      "width": 8,
                      "x": 16,
                      "y": 0
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-22"
                      },
                      "height": 8,
                      "width": 24,
                      "x": 0,
                      "y": 9
                    }
                  },
                  {
                    "kind": "GridLayoutItem",
                    "spec": {
                      "element": {
                        "kind": "ElementReference",
                        "name": "panel-23"
                      },
                      "height": 8,
                      "width": 24,
                      "x": 0,
                      "y": 17
                    }
                  }
                ]
              }
            },
            "title": "IMAP Commands"
          }
        }
      ]
    }
  },
  "links": [],
  "liveNow": false,
  "preload": false,
  "tags": [
    "dovecot",
    "mail",
    "imap",
    "prometheus"
  ],
  "timeSettings": {
    "autoRefresh": "30s",
    "autoRefreshIntervals": [
      "5s",
      "10s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ],
    "fiscalYearStartMonth": 0,
    "from": "now-3h",
    "hideTimepicker": false,
    "timezone": "browser",
    "to": "now"
  },
  "title": "Dovecot 2.4 — Native Prometheus Metrics",
  "variables": [
    {
      "kind": "DatasourceVariable",
      "spec": {
        "allowCustomValue": true,
        "current": {
          "text": "Prometheus",
          "value": "PBFA97CFB590B2093"
        },
        "hide": "dontHide",
        "includeAll": false,
        "label": "Datasource",
        "multi": false,
        "name": "datasource",
        "options": [],
        "pluginId": "prometheus",
        "refresh": "onDashboardLoad",
        "regex": "",
        "skipUrlSync": false
      }
    },
    {
      "kind": "QueryVariable",
      "spec": {
        "allowCustomValue": true,
        "current": {
          "text": "All",
          "value": "$__all"
        },
        "definition": "label_values(dovecot_auth_successes_total, instance)",
        "hide": "dontHide",
        "includeAll": true,
        "label": "Instance",
        "multi": false,
        "name": "instance",
        "options": [],
        "query": {
          "datasource": {
            "name": "${datasource}"
          },
          "group": "prometheus",
          "kind": "DataQuery",
          "spec": {
            "query": "label_values(dovecot_auth_successes_total, instance)",
            "refId": "PrometheusVariableQueryEditor-VariableQuery"
          },
          "version": "v0"
        },
        "refresh": "onTimeRangeChanged",
        "regex": "",
        "regexApplyTo": "value",
        "skipUrlSync": false,
        "sort": "alphabeticalAsc"
      }
    }
  ]
}

---









# RSPAMD
---
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": { "type": "grafana", "uid": "-- Grafana --" },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "description": "Rspamd 4.x native Prometheus metrics. Covers scanning, classification, actions, memory, and Bayes/fuzzy stats.",
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 1,
  "id": null,
  "links": [],
  "panels": [

    {
      "collapsed": false,
      "gridPos": { "h": 1, "w": 24, "x": 0, "y": 0 },
      "id": 100,
      "title": "Overview",
      "type": "row"
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": { "mode": "absolute", "steps": [{ "color": "blue", "value": null }] },
          "unit": "short", "mappings": []
        },
        "overrides": []
      },
      "gridPos": { "h": 4, "w": 4, "x": 0, "y": 1 },
      "id": 1,
      "options": { "colorMode": "background", "graphMode": "none", "justifyMode": "center", "orientation": "auto", "reduceOptions": { "calcs": ["lastNotNull"], "fields": "", "values": false }, "textMode": "auto" },
      "title": "Total Scanned",
      "type": "stat",
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_scanned_total{instance=~\"$instance\"}", "legendFormat": "Scanned", "refId": "A" }]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": { "mode": "absolute", "steps": [{ "color": "red", "value": null }] },
          "unit": "short", "mappings": []
        },
        "overrides": []
      },
      "gridPos": { "h": 4, "w": 4, "x": 4, "y": 1 },
      "id": 2,
      "options": { "colorMode": "background", "graphMode": "none", "justifyMode": "center", "orientation": "auto", "reduceOptions": { "calcs": ["lastNotNull"], "fields": "", "values": false }, "textMode": "auto" },
      "title": "Total Spam",
      "type": "stat",
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_spam_total{instance=~\"$instance\"}", "legendFormat": "Spam", "refId": "A" }]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": { "mode": "absolute", "steps": [{ "color": "green", "value": null }] },
          "unit": "short", "mappings": []
        },
        "overrides": []
      },
      "gridPos": { "h": 4, "w": 4, "x": 8, "y": 1 },
      "id": 3,
      "options": { "colorMode": "background", "graphMode": "none", "justifyMode": "center", "orientation": "auto", "reduceOptions": { "calcs": ["lastNotNull"], "fields": "", "values": false }, "textMode": "auto" },
      "title": "Total Ham",
      "type": "stat",
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_ham_total{instance=~\"$instance\"}", "legendFormat": "Ham", "refId": "A" }]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": {
            "mode": "absolute",
            "steps": [
              { "color": "green", "value": null },
              { "color": "yellow", "value": 0.3 },
              { "color": "red", "value": 0.6 }
            ]
          },
          "unit": "percentunit", "mappings": []
        },
        "overrides": []
      },
      "gridPos": { "h": 4, "w": 4, "x": 12, "y": 1 },
      "id": 4,
      "options": { "colorMode": "background", "graphMode": "none", "justifyMode": "center", "orientation": "auto", "reduceOptions": { "calcs": ["lastNotNull"], "fields": "", "values": false }, "textMode": "auto" },
      "title": "Spam Rate",
      "type": "stat",
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_spam_total{instance=~\"$instance\"} / rspamd_scanned_total{instance=~\"$instance\"}", "legendFormat": "Spam Rate", "refId": "A" }]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": { "mode": "absolute", "steps": [{ "color": "orange", "value": null }] },
          "unit": "s", "mappings": []
        },
        "overrides": []
      },
      "gridPos": { "h": 4, "w": 4, "x": 16, "y": 1 },
      "id": 5,
      "options": { "colorMode": "background", "graphMode": "none", "justifyMode": "center", "orientation": "auto", "reduceOptions": { "calcs": ["lastNotNull"], "fields": "", "values": false }, "textMode": "auto" },
      "title": "Avg Scan Time",
      "type": "stat",
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_scan_time_average{instance=~\"$instance\"}", "legendFormat": "Avg Scan Time", "refId": "A" }]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": { "mode": "absolute", "steps": [{ "color": "purple", "value": null }] },
          "unit": "short", "mappings": []
        },
        "overrides": []
      },
      "gridPos": { "h": 4, "w": 4, "x": 20, "y": 1 },
      "id": 6,
      "options": { "colorMode": "background", "graphMode": "none", "justifyMode": "center", "orientation": "auto", "reduceOptions": { "calcs": ["lastNotNull"], "fields": "", "values": false }, "textMode": "auto" },
      "title": "Active Connections",
      "type": "stat",
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_connections{instance=~\"$instance\"}", "legendFormat": "Connections", "refId": "A" }]
    },

    {
      "collapsed": false,
      "gridPos": { "h": 1, "w": 24, "x": 0, "y": 5 },
      "id": 101,
      "title": "Scanning & Classification",
      "type": "row"
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": {
            "axisCenteredZero": false, "axisColorMode": "text", "axisPlacement": "auto",
            "barAlignment": 0, "drawStyle": "line", "fillOpacity": 15, "gradientMode": "none",
            "lineInterpolation": "smooth", "lineWidth": 2, "pointSize": 5,
            "showPoints": "never", "spanNulls": false,
            "stacking": { "group": "A", "mode": "none" },
            "thresholdsStyle": { "mode": "off" }
          },
          "unit": "ops", "min": 0
        },
        "overrides": [
          { "matcher": { "id": "byName", "options": "Spam/s" }, "properties": [{ "id": "color", "value": { "fixedColor": "red", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "Ham/s" }, "properties": [{ "id": "color", "value": { "fixedColor": "green", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "Scanned/s" }, "properties": [{ "id": "color", "value": { "fixedColor": "blue", "mode": "fixed" } }] }
        ]
      },
      "gridPos": { "h": 8, "w": 16, "x": 0, "y": 6 },
      "id": 10,
      "options": {
        "legend": { "calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom", "showLegend": true },
        "tooltip": { "mode": "multi", "sort": "desc" }
      },
      "title": "Scan Rate — Scanned / Spam / Ham",
      "type": "timeseries",
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rate(rspamd_scanned_total{instance=~\"$instance\"}[5m])", "legendFormat": "Scanned/s", "refId": "A" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rate(rspamd_spam_total{instance=~\"$instance\"}[5m])", "legendFormat": "Spam/s", "refId": "B" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rate(rspamd_ham_total{instance=~\"$instance\"}[5m])", "legendFormat": "Ham/s", "refId": "C" }
      ]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": { "hideFrom": { "legend": false, "tooltip": false, "viz": false } },
          "unit": "short", "mappings": []
        },
        "overrides": [
          { "matcher": { "id": "byName", "options": "spam" }, "properties": [{ "id": "color", "value": { "fixedColor": "red", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "ham" }, "properties": [{ "id": "color", "value": { "fixedColor": "green", "mode": "fixed" } }] }
        ]
      },
      "gridPos": { "h": 8, "w": 8, "x": 16, "y": 6 },
      "id": 11,
      "options": {
        "legend": { "displayMode": "table", "placement": "bottom", "showLegend": true, "values": ["value", "percent"] },
        "pieType": "donut",
        "tooltip": { "mode": "single", "sort": "none" }
      },
      "title": "Spam vs Ham Distribution",
      "type": "piechart",
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_spam_total{instance=~\"$instance\"}", "legendFormat": "spam", "refId": "A", "instant": true },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_ham_total{instance=~\"$instance\"}", "legendFormat": "ham", "refId": "B", "instant": true }
      ]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": {
            "axisCenteredZero": false, "axisColorMode": "text", "axisPlacement": "auto",
            "barAlignment": 0, "drawStyle": "line", "fillOpacity": 10, "gradientMode": "none",
            "lineInterpolation": "smooth", "lineWidth": 2, "pointSize": 5,
            "showPoints": "never", "spanNulls": false,
            "stacking": { "group": "A", "mode": "none" },
            "thresholdsStyle": { "mode": "off" }
          },
          "unit": "s", "min": 0
        },
        "overrides": []
      },
      "gridPos": { "h": 7, "w": 12, "x": 0, "y": 14 },
      "id": 12,
      "options": {
        "legend": { "calcs": ["mean", "max", "last"], "displayMode": "table", "placement": "bottom", "showLegend": true },
        "tooltip": { "mode": "multi", "sort": "desc" }
      },
      "title": "Average Scan Time",
      "type": "timeseries",
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_scan_time_average{instance=~\"$instance\"}", "legendFormat": "Avg Scan Time (s)", "refId": "A" }
      ]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": {
            "axisCenteredZero": false, "axisColorMode": "text", "axisPlacement": "auto",
            "barAlignment": 0, "drawStyle": "line", "fillOpacity": 10, "gradientMode": "none",
            "lineInterpolation": "smooth", "lineWidth": 2, "pointSize": 5,
            "showPoints": "never", "spanNulls": false,
            "stacking": { "group": "A", "mode": "none" },
            "thresholdsStyle": { "mode": "off" }
          },
          "unit": "short", "min": 0
        },
        "overrides": []
      },
      "gridPos": { "h": 7, "w": 12, "x": 12, "y": 14 },
      "id": 13,
      "options": {
        "legend": { "calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom", "showLegend": true },
        "tooltip": { "mode": "multi", "sort": "desc" }
      },
      "title": "Connections",
      "type": "timeseries",
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_connections{instance=~\"$instance\"}", "legendFormat": "Active Connections", "refId": "A" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rate(rspamd_control_connections_total{instance=~\"$instance\"}[5m])", "legendFormat": "Control Connections/s", "refId": "B" }
      ]
    },

    {
      "collapsed": false,
      "gridPos": { "h": 1, "w": 24, "x": 0, "y": 21 },
      "id": 102,
      "title": "Actions",
      "type": "row"
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": {
            "axisCenteredZero": false, "axisColorMode": "text", "axisPlacement": "auto",
            "barAlignment": 0, "drawStyle": "line", "fillOpacity": 15, "gradientMode": "none",
            "lineInterpolation": "smooth", "lineWidth": 2, "pointSize": 5,
            "showPoints": "never", "spanNulls": false,
            "stacking": { "group": "A", "mode": "normal" },
            "thresholdsStyle": { "mode": "off" }
          },
          "unit": "ops", "min": 0
        },
        "overrides": [
          { "matcher": { "id": "byName", "options": "reject" }, "properties": [{ "id": "color", "value": { "fixedColor": "dark-red", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "add header" }, "properties": [{ "id": "color", "value": { "fixedColor": "orange", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "no action" }, "properties": [{ "id": "color", "value": { "fixedColor": "green", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "soft reject" }, "properties": [{ "id": "color", "value": { "fixedColor": "yellow", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "greylist" }, "properties": [{ "id": "color", "value": { "fixedColor": "light-blue", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "rewrite subject" }, "properties": [{ "id": "color", "value": { "fixedColor": "purple", "mode": "fixed" } }] }
        ]
      },
      "gridPos": { "h": 9, "w": 16, "x": 0, "y": 22 },
      "id": 20,
      "options": {
        "legend": { "calcs": ["mean", "max"], "displayMode": "table", "placement": "bottom", "showLegend": true },
        "tooltip": { "mode": "multi", "sort": "desc" }
      },
      "title": "Action Rate by Type (stacked)",
      "type": "timeseries",
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rate(rspamd_actions_total{instance=~\"$instance\", type=\"no action\"}[5m])", "legendFormat": "no action", "refId": "A" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rate(rspamd_actions_total{instance=~\"$instance\", type=\"add header\"}[5m])", "legendFormat": "add header", "refId": "B" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rate(rspamd_actions_total{instance=~\"$instance\", type=\"reject\"}[5m])", "legendFormat": "reject", "refId": "C" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rate(rspamd_actions_total{instance=~\"$instance\", type=\"soft reject\"}[5m])", "legendFormat": "soft reject", "refId": "D" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rate(rspamd_actions_total{instance=~\"$instance\", type=\"greylist\"}[5m])", "legendFormat": "greylist", "refId": "E" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rate(rspamd_actions_total{instance=~\"$instance\", type=\"rewrite subject\"}[5m])", "legendFormat": "rewrite subject", "refId": "F" }
      ]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": { "hideFrom": { "legend": false, "tooltip": false, "viz": false } },
          "unit": "short", "mappings": []
        },
        "overrides": [
          { "matcher": { "id": "byName", "options": "no action" }, "properties": [{ "id": "color", "value": { "fixedColor": "green", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "add header" }, "properties": [{ "id": "color", "value": { "fixedColor": "orange", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "reject" }, "properties": [{ "id": "color", "value": { "fixedColor": "red", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "soft reject" }, "properties": [{ "id": "color", "value": { "fixedColor": "yellow", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "greylist" }, "properties": [{ "id": "color", "value": { "fixedColor": "light-blue", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "rewrite subject" }, "properties": [{ "id": "color", "value": { "fixedColor": "purple", "mode": "fixed" } }] }
        ]
      },
      "gridPos": { "h": 9, "w": 8, "x": 16, "y": 22 },
      "id": 21,
      "options": {
        "legend": { "displayMode": "table", "placement": "bottom", "showLegend": true, "values": ["value", "percent"] },
        "pieType": "donut",
        "tooltip": { "mode": "single", "sort": "none" }
      },
      "title": "Action Distribution (total)",
      "type": "piechart",
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_actions_total{instance=~\"$instance\", type=\"no action\"}", "legendFormat": "no action", "refId": "A", "instant": true },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_actions_total{instance=~\"$instance\", type=\"add header\"}", "legendFormat": "add header", "refId": "B", "instant": true },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_actions_total{instance=~\"$instance\", type=\"reject\"}", "legendFormat": "reject", "refId": "C", "instant": true },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_actions_total{instance=~\"$instance\", type=\"soft reject\"}", "legendFormat": "soft reject", "refId": "D", "instant": true },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_actions_total{instance=~\"$instance\", type=\"greylist\"}", "legendFormat": "greylist", "refId": "E", "instant": true },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_actions_total{instance=~\"$instance\", type=\"rewrite subject\"}", "legendFormat": "rewrite subject", "refId": "F", "instant": true }
      ]
    },

    {
      "collapsed": false,
      "gridPos": { "h": 1, "w": 24, "x": 0, "y": 31 },
      "id": 103,
      "title": "Memory & Pools",
      "type": "row"
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": {
            "axisCenteredZero": false, "axisColorMode": "text", "axisPlacement": "auto",
            "barAlignment": 0, "drawStyle": "line", "fillOpacity": 20, "gradientMode": "opacity",
            "lineInterpolation": "smooth", "lineWidth": 2, "pointSize": 5,
            "showPoints": "never", "spanNulls": false,
            "stacking": { "group": "A", "mode": "none" },
            "thresholdsStyle": { "mode": "off" }
          },
          "unit": "bytes", "min": 0
        },
        "overrides": []
      },
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 32 },
      "id": 30,
      "options": {
        "legend": { "calcs": ["mean", "last"], "displayMode": "table", "placement": "bottom", "showLegend": true },
        "tooltip": { "mode": "multi", "sort": "desc" }
      },
      "title": "Memory Allocated",
      "type": "timeseries",
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_allocated_bytes{instance=~\"$instance\"}", "legendFormat": "Allocated Bytes", "refId": "A" }
      ]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": {
            "axisCenteredZero": false, "axisColorMode": "text", "axisPlacement": "auto",
            "barAlignment": 0, "drawStyle": "line", "fillOpacity": 10, "gradientMode": "none",
            "lineInterpolation": "smooth", "lineWidth": 2, "pointSize": 5,
            "showPoints": "never", "spanNulls": false,
            "stacking": { "group": "A", "mode": "none" },
            "thresholdsStyle": { "mode": "off" }
          },
          "unit": "short", "min": 0
        },
        "overrides": [
          { "matcher": { "id": "byName", "options": "Pools Freed" }, "properties": [{ "id": "color", "value": { "fixedColor": "green", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "Pools Allocated" }, "properties": [{ "id": "color", "value": { "fixedColor": "blue", "mode": "fixed" } }] }
        ]
      },
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 32 },
      "id": 31,
      "options": {
        "legend": { "calcs": ["mean", "last"], "displayMode": "table", "placement": "bottom", "showLegend": true },
        "tooltip": { "mode": "multi", "sort": "desc" }
      },
      "title": "Memory Pool Lifecycle",
      "type": "timeseries",
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_pools_allocated{instance=~\"$instance\"}", "legendFormat": "Pools Allocated", "refId": "A" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_pools_freed{instance=~\"$instance\"}", "legendFormat": "Pools Freed", "refId": "B" }
      ]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": {
            "axisCenteredZero": false, "axisColorMode": "text", "axisPlacement": "auto",
            "barAlignment": 0, "drawStyle": "line", "fillOpacity": 10, "gradientMode": "none",
            "lineInterpolation": "smooth", "lineWidth": 2, "pointSize": 5,
            "showPoints": "never", "spanNulls": false,
            "stacking": { "group": "A", "mode": "none" },
            "thresholdsStyle": { "mode": "off" }
          },
          "unit": "short", "min": 0
        },
        "overrides": [
          { "matcher": { "id": "byName", "options": "Oversized Chunks" }, "properties": [{ "id": "color", "value": { "fixedColor": "red", "mode": "fixed" } }] },
          { "matcher": { "id": "byName", "options": "Fragmented" }, "properties": [{ "id": "color", "value": { "fixedColor": "orange", "mode": "fixed" } }] }
        ]
      },
      "gridPos": { "h": 7, "w": 24, "x": 0, "y": 40 },
      "id": 32,
      "options": {
        "legend": { "calcs": ["mean", "last"], "displayMode": "table", "placement": "right", "showLegend": true },
        "tooltip": { "mode": "multi", "sort": "desc" }
      },
      "title": "Memory Pool Chunks Detail",
      "type": "timeseries",
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_chunks_allocated{instance=~\"$instance\"}", "legendFormat": "Chunks Allocated", "refId": "A" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_shared_chunks_allocated{instance=~\"$instance\"}", "legendFormat": "Shared Chunks Allocated", "refId": "B" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_chunks_freed{instance=~\"$instance\"}", "legendFormat": "Chunks Freed", "refId": "C" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_chunks_oversized{instance=~\"$instance\"}", "legendFormat": "Oversized Chunks", "refId": "D" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_fragmented{instance=~\"$instance\"}", "legendFormat": "Fragmented", "refId": "E" }
      ]
    },

    {
      "collapsed": false,
      "gridPos": { "h": 1, "w": 24, "x": 0, "y": 47 },
      "id": 104,
      "title": "Bayes & Fuzzy Statistics",
      "type": "row"
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": {
            "mode": "absolute",
            "steps": [
              { "color": "yellow", "value": null },
              { "color": "green", "value": 1000 }
            ]
          },
          "unit": "short", "mappings": []
        },
        "overrides": []
      },
      "gridPos": { "h": 4, "w": 4, "x": 0, "y": 48 },
      "id": 40,
      "options": { "colorMode": "background", "graphMode": "none", "justifyMode": "center", "orientation": "auto", "reduceOptions": { "calcs": ["lastNotNull"], "fields": "", "values": false }, "textMode": "auto" },
      "title": "Bayes Spam Tokens",
      "type": "stat",
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_statfiles_totals{instance=~\"$instance\", symbol=\"BAYES_SPAM\"}", "legendFormat": "BAYES_SPAM tokens", "refId": "A" }]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": {
            "mode": "absolute",
            "steps": [
              { "color": "yellow", "value": null },
              { "color": "green", "value": 1000 }
            ]
          },
          "unit": "short", "mappings": []
        },
        "overrides": []
      },
      "gridPos": { "h": 4, "w": 4, "x": 4, "y": 48 },
      "id": 41,
      "options": { "colorMode": "background", "graphMode": "none", "justifyMode": "center", "orientation": "auto", "reduceOptions": { "calcs": ["lastNotNull"], "fields": "", "values": false }, "textMode": "auto" },
      "title": "Bayes Ham Tokens",
      "type": "stat",
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_statfiles_totals{instance=~\"$instance\", symbol=\"BAYES_HAM\"}", "legendFormat": "BAYES_HAM tokens", "refId": "A" }]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": {
            "mode": "absolute",
            "steps": [
              { "color": "blue", "value": null }
            ]
          },
          "unit": "short", "mappings": [],
          "decimals": 0
        },
        "overrides": []
      },
      "gridPos": { "h": 4, "w": 8, "x": 8, "y": 48 },
      "id": 42,
      "options": { "colorMode": "background", "graphMode": "none", "justifyMode": "center", "orientation": "auto", "reduceOptions": { "calcs": ["lastNotNull"], "fields": "", "values": false }, "textMode": "auto" },
      "title": "Fuzzy Hashes (rspamd.com)",
      "type": "stat",
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_fuzzy_stat{instance=~\"$instance\", storage=\"rspamd.com\"}", "legendFormat": "Fuzzy hashes", "refId": "A" }]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": {
            "mode": "absolute",
            "steps": [
              { "color": "green", "value": null }
            ]
          },
          "unit": "short", "mappings": []
        },
        "overrides": []
      },
      "gridPos": { "h": 4, "w": 4, "x": 16, "y": 48 },
      "id": 43,
      "options": { "colorMode": "background", "graphMode": "none", "justifyMode": "center", "orientation": "auto", "reduceOptions": { "calcs": ["lastNotNull"], "fields": "", "values": false }, "textMode": "auto" },
      "title": "Total Learned",
      "type": "stat",
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_learned_total{instance=~\"$instance\"}", "legendFormat": "Learned", "refId": "A" }]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "thresholds" },
          "thresholds": {
            "mode": "absolute",
            "steps": [
              { "color": "yellow", "value": null },
              { "color": "green", "value": 1 }
            ]
          },
          "unit": "bool", "mappings": [
            { "options": { "0": { "color": "red", "index": 0, "text": "Read-Write" }, "1": { "color": "green", "index": 1, "text": "Read-Only" } }, "type": "value" }
          ]
        },
        "overrides": []
      },
      "gridPos": { "h": 4, "w": 4, "x": 20, "y": 48 },
      "id": 44,
      "options": { "colorMode": "background", "graphMode": "none", "justifyMode": "center", "orientation": "auto", "reduceOptions": { "calcs": ["lastNotNull"], "fields": "", "values": false }, "textMode": "auto" },
      "title": "Read-Only Mode",
      "type": "stat",
      "targets": [{ "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_read_only{instance=~\"$instance\"}", "legendFormat": "Read Only", "refId": "A" }]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": {
            "axisCenteredZero": false, "axisColorMode": "text", "axisPlacement": "auto",
            "barAlignment": 0, "drawStyle": "line", "fillOpacity": 10, "gradientMode": "none",
            "lineInterpolation": "smooth", "lineWidth": 2, "pointSize": 5,
            "showPoints": "never", "spanNulls": false,
            "stacking": { "group": "A", "mode": "none" },
            "thresholdsStyle": { "mode": "off" }
          },
          "unit": "short", "min": 0
        },
        "overrides": []
      },
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 52 },
      "id": 45,
      "options": {
        "legend": { "calcs": ["mean", "last"], "displayMode": "table", "placement": "bottom", "showLegend": true },
        "tooltip": { "mode": "multi", "sort": "desc" }
      },
      "title": "Bayes Stat Files — Used / Total / Revision",
      "type": "timeseries",
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_statfiles_used{instance=~\"$instance\"}", "legendFormat": "Used — {{symbol}}", "refId": "A" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_statfiles_totals{instance=~\"$instance\"}", "legendFormat": "Total — {{symbol}}", "refId": "B" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_statfiles_revision{instance=~\"$instance\"}", "legendFormat": "Revision — {{symbol}}", "refId": "C" }
      ]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": {
            "axisCenteredZero": false, "axisColorMode": "text", "axisPlacement": "auto",
            "barAlignment": 0, "drawStyle": "line", "fillOpacity": 10, "gradientMode": "none",
            "lineInterpolation": "smooth", "lineWidth": 2, "pointSize": 5,
            "showPoints": "never", "spanNulls": false,
            "stacking": { "group": "A", "mode": "none" },
            "thresholdsStyle": { "mode": "off" }
          },
          "unit": "short", "min": 0
        },
        "overrides": []
      },
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 52 },
      "id": 46,
      "options": {
        "legend": { "calcs": ["mean", "last"], "displayMode": "table", "placement": "bottom", "showLegend": true },
        "tooltip": { "mode": "multi", "sort": "desc" }
      },
      "title": "Bayes Stat Files — Size / Languages / Users",
      "type": "timeseries",
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_statfiles_size{instance=~\"$instance\"}", "legendFormat": "Size — {{symbol}}", "refId": "A" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_statfiles_languages{instance=~\"$instance\"}", "legendFormat": "Languages — {{symbol}}", "refId": "B" },
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_statfiles_users{instance=~\"$instance\"}", "legendFormat": "Users — {{symbol}}", "refId": "C" }
      ]
    },

    {
      "datasource": { "type": "prometheus", "uid": "${datasource}" },
      "fieldConfig": {
        "defaults": {
          "color": { "mode": "palette-classic" },
          "custom": {
            "axisCenteredZero": false, "axisColorMode": "text", "axisPlacement": "auto",
            "barAlignment": 0, "drawStyle": "line", "fillOpacity": 20, "gradientMode": "opacity",
            "lineInterpolation": "smooth", "lineWidth": 2, "pointSize": 5,
            "showPoints": "never", "spanNulls": false,
            "stacking": { "group": "A", "mode": "none" },
            "thresholdsStyle": { "mode": "off" }
          },
          "unit": "short", "min": 0
        },
        "overrides": []
      },
      "gridPos": { "h": 7, "w": 24, "x": 0, "y": 60 },
      "id": 47,
      "options": {
        "legend": { "calcs": ["mean", "last"], "displayMode": "table", "placement": "bottom", "showLegend": true },
        "tooltip": { "mode": "multi", "sort": "desc" }
      },
      "title": "Fuzzy Storage Hash Count",
      "type": "timeseries",
      "targets": [
        { "datasource": { "type": "prometheus", "uid": "${datasource}" }, "expr": "rspamd_fuzzy_stat{instance=~\"$instance\"}", "legendFormat": "{{storage}}", "refId": "A" }
      ]
    }

  ],
  "refresh": "30s",
  "schemaVersion": 38,
  "tags": ["rspamd", "mail", "spam", "prometheus"],
  "templating": {
    "list": [
      {
        "current": {},
        "hide": 0,
        "includeAll": false,
        "label": "Datasource",
        "multi": false,
        "name": "datasource",
        "options": [],
        "query": "prometheus",
        "refresh": 1,
        "type": "datasource"
      },
      {
        "current": { "selected": false, "text": "All", "value": "$__all" },
        "datasource": { "type": "prometheus", "uid": "${datasource}" },
        "definition": "label_values(rspamd_scanned_total, instance)",
        "hide": 0,
        "includeAll": true,
        "label": "Instance",
        "multi": false,
        "name": "instance",
        "options": [],
        "query": {
          "query": "label_values(rspamd_scanned_total, instance)",
          "refId": "PrometheusVariableQueryEditor-VariableQuery"
        },
        "refresh": 2,
        "regex": "",
        "sort": 1,
        "type": "query"
      }
    ]
  },
  "time": { "from": "now-6h", "to": "now" },
  "timepicker": {},
  "timezone": "browser",
  "title": "Rspamd 4.x — Native Prometheus Metrics",
  "uid": "rspamd-native-v1",
  "version": 1
}

---


 





ansible-mailstack/
├── files/
│   └── dashboards/
│       ├── linux-server.json
│       ├── mail-stack-overview.json
│       ├── postfix-performance.json
│       ├── dovecot-imap.json
│       ├── mysql-replication.json
│       ├── rspamd-spam.json
│       ├── clamav-antivirus.json
│       ├── valkey-cache.json
│       ├── unbound-dns.json
│       ├── nfs-storage.json
│       └── roundcube-webmail.json


# Export all dashboards via API
curl -s -u admin:CHANGE_ME_GRAFANA_PASSWORD http://192.168.1.238:3000/api/search | \
  jq -r '.[].uid' | \
  while read uid; do
    curl -s -u admin:CHANGE_ME_GRAFANA_PASSWORD "http://192.168.1.238:3000/api/dashboards/uid/$uid" | \
      jq '.dashboard' > "dashboard-${uid}.json"
  done
