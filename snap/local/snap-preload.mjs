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
      if (
        process.env.OPENCLAW_SNAP_INSECURE_REMOTE === "1" ||
        process.env.OPENCLAW_SNAP_INSECURE_REMOTE === "true"
      ) {
        setConfigOverride("gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback", true);
        setConfigOverride("gateway.controlUi.dangerouslyDisableDeviceAuth", true);
      }
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
    case "0.0.0.0":
      return "auto";
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
