# Notebook: nb_test_apim_connectivity
# Purpose:  Tests DNS resolution and HTTPS reachability of the APIM endpoint.
#           Designed to run as a Notebook activity in a Fabric pipeline.
#           The test result is returned via mssparkutils.notebook.exit() so
#           the pipeline can inspect it — check pipeline activity output →
#           result → exitValue for the JSON result.
#
# Parameters:
#   p_base_url  — APIM base URL to test (e.g. https://apim-anthill-dev-centralus-1.azure-api.net)

import json
import socket
import requests

# ── Parameter ──────────────────────────────────────────────────────────────────
p_base_url = ""

if not p_base_url.strip():
    raise ValueError("Parameter 'p_base_url' is required.")

_host = p_base_url.strip().rstrip("/").replace("https://", "").replace("http://", "").split("/")[0]

print("=" * 60)
print("  nb_test_apim_connectivity")
print("=" * 60)
print(f"  host : {_host}")
print("=" * 60)

_results = {"host": _host, "dns": {}, "https": {}, "overall": "FAIL"}

# ── Test 1: DNS resolution ─────────────────────────────────────────────────────
print("\n[1/2] DNS resolution ...")
try:
    ip = socket.gethostbyname(_host)
    _results["dns"] = {"status": "OK", "resolved_ip": ip}
    print(f"  OK — resolved to {ip}")
except Exception as e:
    _results["dns"] = {"status": "FAIL", "error": str(e)}
    print(f"  FAIL — {e}")

# ── Test 2: HTTPS reachability ─────────────────────────────────────────────────
print("\n[2/2] HTTPS reachability ...")
try:
    r = requests.get(f"https://{_host}", timeout=10, verify=True)
    _results["https"] = {"status": "OK", "http_status_code": r.status_code}
    print(f"  OK — HTTP status {r.status_code}")
except Exception as e:
    _results["https"] = {"status": "FAIL", "error": str(e)}
    print(f"  FAIL — {e}")

# ── Overall result ─────────────────────────────────────────────────────────────
if _results["dns"]["status"] == "OK" and _results["https"]["status"] == "OK":
    _results["overall"] = "PASS"

print("\n" + "=" * 60)
print(f"  Overall : {_results['overall']}")
print("=" * 60)

# Return result to pipeline — visible in pipeline activity output → result → exitValue
mssparkutils.notebook.exit(json.dumps(_results))  # noqa: F821  # type: ignore[name-defined]  — injected by Fabric runtime
