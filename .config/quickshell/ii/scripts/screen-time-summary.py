#!/usr/bin/env python3
"""Return a screen-time summary from local Awatcher with hourly breakdown and system uptime."""
import json
import socket
import urllib.error
import urllib.request
from datetime import datetime

BASE = "http://127.0.0.1:5600/api/0"

def get_uptime_str():
    try:
        with open("/proc/uptime", "r") as f:
            uptime_sec = float(f.read().split()[0])
        hrs = int(uptime_sec // 3600)
        mins = int((uptime_sec % 3600) // 60)
        return f"{hrs}h {mins:02d}m"
    except Exception:
        return "—"

def clean_app_name(raw_name):
    if not raw_name:
        return "Unknown"
    name = str(raw_name).strip()
    mapping = {
        "brave-browser": "Brave",
        "com.anthropic.Claude": "Claude",
        "antigravity-ide": "Antigravity",
        "kitty": "Kitty",
        "foot": "Foot",
        "code": "VS Code",
        "code-oss": "VS Code",
        "spotify": "Spotify",
        "discord": "Discord",
        "org.gnome.Nautilus": "Files",
    }
    if name in mapping:
        return mapping[name]
    if name.startswith("brave-") and "Default" in name:
        return "Web App"
    if "." in name and len(name.split(".")) > 2:
        return name.split(".")[-1].capitalize()
    return name.capitalize()

def main():
    host = socket.gethostname()
    start = datetime.now().astimezone().replace(hour=0, minute=0, second=0, microsecond=0)
    end = datetime.now().astimezone()
    query = [
        f'events = query_bucket("aw-watcher-window_{host}");',
        f'afk_events = query_bucket("aw-watcher-afk_{host}");',
        'not_afk = filter_keyvals(afk_events, "status", ["not-afk"]);',
        'events = filter_period_intersect(events, not_afk);',
        'merged = merge_events_by_keys(events, ["app"]);',
        'RETURN = {"apps": sort_by_duration(merged), "timeline": events};',
    ]
    payload = json.dumps({
        "timeperiods": [f"{start.isoformat()}/{end.isoformat()}"],
        "query": query,
    }).encode()
    request = urllib.request.Request(
        f"{BASE}/query/", data=payload,
        headers={"Content-Type": "application/json"}, method="POST"
    )
    with urllib.request.urlopen(request, timeout=3) as response:
        result = json.load(response)
    
    data_dict = result[0] if (result and isinstance(result[0], dict)) else {}
    rows = data_dict.get("apps", [])
    timeline = data_dict.get("timeline", [])
    
    apps = []
    for row in rows:
        data = row.get("data", {})
        app = data.get("app") or data.get("app_id") or "Unknown app"
        duration = max(0, float(row.get("duration", 0)))
        if duration > 10: # Filter negligible durations
            apps.append({
                "name": clean_app_name(app),
                "rawName": str(app),
                "seconds": round(duration)
            })
    apps.sort(key=lambda item: item["seconds"], reverse=True)
    
    # Calculate hourly active distribution
    hourly = [0] * 24
    for ev in timeline:
        try:
            ts_str = ev.get("timestamp")
            if ts_str:
                ts = datetime.fromisoformat(ts_str)
                dur = float(ev.get("duration", 0))
                if ts.date() == end.date() and 0 <= ts.hour < 24:
                    hourly[ts.hour] += round(dur)
        except Exception:
            pass

    print(json.dumps({
        "ok": True,
        "totalSeconds": sum(item["seconds"] for item in apps),
        "apps": apps[:6],
        "hourly": hourly,
        "uptime": get_uptime_str(),
        "currentHour": end.hour,
        "updated": end.strftime("%H:%M"),
    }))

try:
    main()
except (OSError, ValueError, KeyError, IndexError, TypeError, urllib.error.URLError) as error:
    print(json.dumps({
        "ok": False,
        "message": str(error),
        "uptime": get_uptime_str()
    }))

