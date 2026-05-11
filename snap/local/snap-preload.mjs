import path from "node:path";
import { pathToFileURL } from "node:url";

const snapRoot = process.env.SNAP?.trim();
if (snapRoot) {
  const bindOverride = normalizeBind(process.env.OPENCLAW_SNAP_BIND_OVERRIDE);
  const remoteHttpUiEnabled = shouldEnableRemoteHttpUi({
    bindOverride,
    raw: process.env.OPENCLAW_SNAP_REMOTE_HTTP_UI,
  });

  if (bindOverride || remoteHttpUiEnabled) {
    const configUrl = pathToFileURL(path.join(snapRoot, "dist", "config", "config.js")).href;
    const { setConfigOverride } = await import(configUrl);

    if (bindOverride) {
      setConfigOverride("gateway.bind", bindOverride);
    }

    if (remoteHttpUiEnabled) {
      // Break-glass snap path for direct http://<lan-ip>:<port>/ Control UI access on
      // headless appliances. This matches the explicit non-loopback snap bind choice.
      setConfigOverride("gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback", true);
      setConfigOverride("gateway.controlUi.dangerouslyDisableDeviceAuth", true);
    }
  }
}

function normalizeBind(raw) {
  const value = raw?.trim().toLowerCase();
  switch (value) {
    case "loopback":
    case "lan":
    case "tailnet":
    case "auto":
      return value;
    default:
      return undefined;
  }
}

function shouldEnableRemoteHttpUi(params) {
  const value = params.raw?.trim().toLowerCase();
  if (value === "0" || value === "false" || value === "off" || value === "disabled") {
    return false;
  }
  if (value === "1" || value === "true" || value === "on" || value === "enabled") {
    return true;
  }
  return (
    params.bindOverride === "lan" ||
    params.bindOverride === "tailnet" ||
    params.bindOverride === "auto"
  );
}

// OpenClaw Snap IPv6 Workaround
// The internal ssrf dispatcher performs round-robin across all resolved IPs.
// In environments without proper IPv6 routing, this causes connection timeouts.
// We force IPv4 resolution here to prevent those timeouts.
import dns from "node:dns";
import dnsPromises from "node:dns/promises";

const originalLookup = dns.lookup;
dns.lookup = function (hostname, options, callback) {
  if (typeof options === "function") {
    callback = options;
    options = {};
  } else if (!options) {
    options = {};
  }
  let newOptions = typeof options === "object" && options !== null ? { ...options } : {};
  newOptions.family = 4;
  return originalLookup(hostname, newOptions, callback);
};

const originalPromisesLookup = dnsPromises.lookup;
dnsPromises.lookup = async function (hostname, options) {
  let newOptions = typeof options === "object" && options !== null ? { ...options } : {};
  newOptions.family = 4;
  return originalPromisesLookup(hostname, newOptions);
};
