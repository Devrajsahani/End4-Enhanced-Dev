#!/usr/bin/env python3
"""Return a small, title-redacted screen-time summary from local Awatcher."""
import json
import socket
import urllib.error
import urllib.request
from datetime import datetime, timedelta

BASE = "http://127.0.0.1:5600/api/0"

def main():
    host = socket.gethostname()
    start = datetime.now().astimezone().replace(hour=0, minute=0, second=0, microsecond=0)
    end = datetime.now().astimezone()
    query = [
        f'events = query_bucket("aw-watcher-window_{host}");',
        f'afk_events = query_bucket("aw-watcher-afk_{host}");',
        'not_afk = filter_keyvals(afk_events, "status", ["not-afk"]);',
        'events = filter_period_intersect(events, not_afk);',
        'events = merge_events_by_keys(events, ["app"]);',
        'RETURN = sort_by_duration(events);',
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
    rows = result[0] if result else []
    apps = []
    for row in rows:
        data = row.get("data", {})
        app = data.get("app") or data.get("app_id") or "Unknown app"
        duration = max(0, float(row.get("duration", 0)))
        if duration:
            apps.append({"name": str(app), "seconds": round(duration)})
    apps.sort(key=lambda item: item["seconds"], reverse=True)
    print(json.dumps({
        "ok": True,
        "totalSeconds": sum(item["seconds"] for item in apps),
        "apps": apps[:5],
        "updated": end.strftime("%H:%M"),
    }))

try:
    main()
except (OSError, ValueError, KeyError, IndexError, TypeError, urllib.error.URLError) as error:
    print(json.dumps({"ok": False, "message": str(error)}))
