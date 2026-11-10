window.__ModuleLoader__.load({
  id: '@local/local-hnysqukwki-11kyqfw',
  factory(require) {
    const module = { exports: {} };
    const exports = module.exports;
var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/entry.jsx
var entry_exports = {};
__export(entry_exports, {
  PanelIcon: () => PanelIcon,
  default: () => entry_default
});
module.exports = __toCommonJS(entry_exports);
var import_react3 = __toESM(require("react"));

// src/app.jsx
var import_react2 = __toESM(require("react"));

// src/style.css
var style_default = ".pr-app {\n  --pr-blue: #4d6bfe;\n  --pr-blue-soft: rgba(77, 107, 254, 0.16);\n  --pr-line: rgba(255, 255, 255, 0.1);\n  --pr-line-strong: rgba(255, 255, 255, 0.18);\n  --pr-ink: #f4f1ea;\n  --pr-muted: #a3adbd;\n  --pr-ok: #68c39e;\n  --pr-warn: #e4b85b;\n  --pr-danger: #ee9b98;\n  --pr-surface: #131c2e;\n  --pr-raised: #1a2740;\n  position: relative;\n  isolation: isolate;\n  overflow-x: hidden;\n  padding-top: max(16px, env(safe-area-inset-top));\n  padding-left: max(16px, env(safe-area-inset-left));\n  padding-right: max(16px, env(safe-area-inset-right));\n  color: var(--pr-ink);\n  background:\n    radial-gradient(120% 60% at 8% -8%, rgba(77, 107, 254, 0.16), transparent 62%),\n    radial-gradient(90% 52% at 108% 4%, rgba(104, 195, 158, 0.1), transparent 60%),\n    #0c1424;\n}\n\n.pr-app::before {\n  content: '';\n  position: absolute;\n  inset: 0;\n  pointer-events: none;\n  background:\n    radial-gradient(70% 40% at 50% 0%, rgba(77, 107, 254, 0.08), transparent 70%),\n    linear-gradient(180deg, rgba(255, 255, 255, 0.02), transparent 30%);\n  z-index: 0;\n}\n\n.pr-app .wish-page {\n  position: relative;\n  z-index: 1;\n  min-height: 0;\n}\n\n.pr-content {\n  display: flex;\n  flex-direction: column;\n  gap: 16px;\n  padding-top: 2px;\n  padding-bottom: calc(20px + env(safe-area-inset-bottom));\n}\n\n.pr-stack {\n  display: flex;\n  flex-direction: column;\n  gap: 16px;\n  min-width: 0;\n}\n\n.pr-glass {\n  position: relative;\n  background:\n    linear-gradient(158deg, rgba(33, 49, 82, 0.62) 0%, rgba(19, 28, 46, 0.86) 62%, rgba(19, 28, 46, 0.92) 100%);\n  border: 1px solid var(--pr-line);\n  border-radius: 22px;\n  box-shadow:\n    inset 0 1px 0 rgba(255, 255, 255, 0.07),\n    0 22px 48px -30px rgba(0, 0, 0, 0.9);\n  -webkit-backdrop-filter: blur(18px) saturate(1.15);\n  backdrop-filter: blur(18px) saturate(1.15);\n  min-width: 0;\n}\n\n/* Header */\n.pr-head {\n  align-items: flex-start;\n  gap: 10px;\n  margin-bottom: 14px;\n}\n\n.pr-head-copy {\n  min-width: 0;\n  flex: 1;\n}\n\n.pr-kicker {\n  display: flex;\n  align-items: center;\n  gap: 10px;\n  font-size: 10.5px;\n  font-weight: 600;\n  letter-spacing: 0.18em;\n  color: #9fb1ff;\n  margin-bottom: 4px;\n}\n\n.pr-head h1 {\n  margin: 0;\n  font-size: 25px;\n  line-height: 1.2;\n  letter-spacing: -0.5px;\n  font-weight: 650;\n}\n\n.pr-sub {\n  margin: 3px 0 0;\n  font-size: 12.5px;\n  line-height: 1.45;\n  color: var(--pr-muted);\n}\n\n.pr-live {\n  display: inline-flex;\n  align-items: center;\n  gap: 5px;\n  padding: 2px 8px;\n  border-radius: 999px;\n  background: rgba(104, 195, 158, 0.1);\n  border: 1px solid rgba(104, 195, 158, 0.25);\n  color: #a8e2cb;\n  font-size: 10.5px;\n  letter-spacing: 0.04em;\n  font-weight: 500;\n}\n\n.pr-live i {\n  width: 5px;\n  height: 5px;\n  border-radius: 50%;\n  background: var(--pr-ok);\n  box-shadow: 0 0 0 3px rgba(104, 195, 158, 0.15);\n  animation: pr-breathe 2.6s ease-in-out infinite;\n}\n\n.pr-back {\n  width: 44px;\n  height: 44px;\n  flex: none;\n  display: grid;\n  place-items: center;\n  margin: 4px 0 0 -6px;\n  padding: 0;\n  border-radius: 14px;\n  border: 1px solid var(--pr-line);\n  background: rgba(26, 39, 64, 0.72);\n  color: var(--pr-ink);\n  cursor: pointer;\n  touch-action: manipulation;\n}\n\n.pr-back:active {\n  transform: scale(0.94);\n}\n\n/* Hero */\n.pr-hero {\n  position: relative;\n  overflow: hidden;\n  border-radius: 28px;\n  padding: 24px 20px 20px;\n  border: 1px solid rgba(255, 255, 255, 0.13);\n  background:\n    radial-gradient(120% 120% at 92% -6%, rgba(77, 107, 254, 0.36) 0%, transparent 55%),\n    radial-gradient(90% 90% at 0% 110%, rgba(104, 195, 158, 0.14) 0%, transparent 60%),\n    linear-gradient(150deg, rgba(30, 47, 82, 0.94) 0%, rgba(17, 26, 44, 0.96) 68%);\n  box-shadow:\n    inset 0 1px 0 rgba(255, 255, 255, 0.12),\n    0 30px 60px -34px rgba(0, 0, 0, 0.95);\n}\n\n.pr-hero-glow {\n  position: absolute;\n  width: 230px;\n  height: 230px;\n  right: -84px;\n  top: -90px;\n  border-radius: 50%;\n  background: radial-gradient(circle, rgba(77, 107, 254, 0.55), transparent 68%);\n  filter: blur(2px);\n  pointer-events: none;\n  animation: pr-breathe 7s ease-in-out infinite;\n}\n\n.pr-hero-radar {\n  position: absolute;\n  right: -8px;\n  top: 10px;\n  opacity: 0.9;\n  pointer-events: none;\n}\n\n.pr-eyebrow {\n  position: relative;\n  display: block;\n  font-size: 11px;\n  letter-spacing: 0.12em;\n  text-transform: uppercase;\n  color: #b7c6ff;\n  font-weight: 600;\n  margin-bottom: 10px;\n}\n\n.pr-hero h2 {\n  position: relative;\n  margin: 0 0 8px;\n  font-size: 27px;\n  line-height: 1.28;\n  letter-spacing: -0.8px;\n  font-weight: 600;\n  max-width: 12em;\n}\n\n.pr-hero p {\n  position: relative;\n  margin: 0 0 18px;\n  max-width: 24em;\n  color: #b9c4d8;\n  font-size: 13px;\n  line-height: 1.6;\n}\n\n.pr-cta {\n  position: relative;\n  display: flex;\n  align-items: center;\n  justify-content: space-between;\n  gap: 12px;\n  width: 100%;\n  min-height: 52px;\n  padding: 0 18px;\n  border: 0;\n  border-radius: 16px;\n  background: linear-gradient(120deg, #4d6bfe 0%, #6f86ff 55%, #4d6bfe 100%);\n  color: #fff;\n  font: inherit;\n  font-size: 16px;\n  font-weight: 650;\n  letter-spacing: 0.02em;\n  cursor: pointer;\n  touch-action: manipulation;\n  box-shadow:\n    0 12px 30px -14px rgba(77, 107, 254, 0.9),\n    inset 0 1px 0 rgba(255, 255, 255, 0.35);\n  overflow: hidden;\n}\n\n.pr-cta::after {\n  content: '';\n  position: absolute;\n  inset: 0;\n  background: linear-gradient(100deg, transparent 20%, rgba(255, 255, 255, 0.28) 48%, transparent 70%);\n  transform: translateX(-120%);\n  animation: pr-sheen 4.8s ease-in-out infinite;\n  pointer-events: none;\n}\n\n.pr-cta:active {\n  transform: scale(0.985);\n}\n\n.pr-hero-actions {\n  display: flex;\n  gap: 10px;\n  margin-top: 10px;\n}\n\n.pr-ghost {\n  flex: 1;\n  min-height: 46px;\n  display: inline-flex;\n  align-items: center;\n  justify-content: center;\n  gap: 8px;\n  border-radius: 14px;\n  border: 1px solid var(--pr-line-strong);\n  background: rgba(255, 255, 255, 0.045);\n  color: #dbe3f3;\n  font: inherit;\n  font-size: 13.5px;\n  font-weight: 500;\n  cursor: pointer;\n  touch-action: manipulation;\n  -webkit-backdrop-filter: blur(10px);\n  backdrop-filter: blur(10px);\n}\n\n.pr-ghost:active {\n  transform: scale(0.98);\n  background: rgba(255, 255, 255, 0.08);\n}\n\n/* Radar */\n.pr-radar {\n  position: relative;\n  width: 108px;\n  height: 108px;\n  flex: none;\n  display: inline-block;\n}\n\n.pr-radar i {\n  position: absolute;\n  inset: 0;\n  border-radius: 50%;\n  border: 1px solid rgba(77, 107, 254, 0.38);\n}\n\n.pr-radar i:nth-child(2) {\n  inset: 16px;\n  border-style: dashed;\n  border-color: rgba(104, 195, 158, 0.4);\n  animation: pr-spin 9s linear infinite reverse;\n}\n\n.pr-radar i:nth-child(3) {\n  inset: 32px;\n  border-color: rgba(228, 184, 91, 0.34);\n  animation: pr-spin 5.4s linear infinite;\n}\n\n.pr-radar b {\n  position: absolute;\n  inset: 48px;\n  border-radius: 50%;\n  background: var(--pr-blue);\n  box-shadow: 0 0 24px rgba(77, 107, 254, 0.9);\n  animation: pr-pulse 2s ease-in-out infinite;\n}\n\n.pr-radar::after {\n  content: '';\n  position: absolute;\n  inset: 0;\n  border-radius: 50%;\n  background: conic-gradient(from 0deg, rgba(77, 107, 254, 0.5), transparent 26%, transparent 100%);\n  -webkit-mask: radial-gradient(circle, transparent 46%, #000 47%);\n  mask: radial-gradient(circle, transparent 46%, #000 47%);\n  animation: pr-spin 3.6s linear infinite;\n  opacity: 0.75;\n}\n\n.pr-radar-sm {\n  width: 44px;\n  height: 44px;\n}\n\n.pr-radar-sm b {\n  inset: 19px;\n}\n\n.pr-radar-sm i:nth-child(2) {\n  inset: 6px;\n}\n\n.pr-radar-sm i:nth-child(3) {\n  inset: 12px;\n}\n\n/* Stats */\n.pr-stats {\n  display: grid;\n  grid-template-columns: repeat(3, minmax(0, 1fr));\n  gap: 10px;\n}\n\n.pr-stat {\n  display: flex;\n  flex-direction: column;\n  gap: 2px;\n  padding: 13px 14px;\n  border-radius: 18px;\n}\n\n.pr-stat strong {\n  font-size: 21px;\n  line-height: 1.15;\n  letter-spacing: -0.4px;\n  font-variant-numeric: tabular-nums;\n}\n\n.pr-stat span {\n  font-size: 11px;\n  line-height: 1.35;\n  color: var(--pr-muted);\n}\n\n/* Float entry */\n.pr-float {\n  display: flex;\n  align-items: center;\n  gap: 12px;\n  width: 100%;\n  min-height: 68px;\n  padding: 13px 15px;\n  text-align: left;\n  color: var(--pr-ink);\n  font: inherit;\n  cursor: pointer;\n  touch-action: manipulation;\n}\n\n.pr-float:active {\n  transform: scale(0.994);\n}\n\n.pr-float-icon {\n  width: 42px;\n  height: 42px;\n  flex: none;\n  display: grid;\n  place-items: center;\n  border-radius: 14px;\n  background: rgba(77, 107, 254, 0.16);\n  border: 1px solid rgba(77, 107, 254, 0.32);\n  color: #b3c2ff;\n}\n\n.pr-float-copy {\n  flex: 1;\n  min-width: 0;\n  display: flex;\n  flex-direction: column;\n  gap: 2px;\n}\n\n.pr-float-copy strong {\n  font-size: 14.5px;\n  font-weight: 600;\n}\n\n.pr-float-copy small {\n  font-size: 12px;\n  line-height: 1.45;\n  color: var(--pr-muted);\n}\n\n.pr-toggle {\n  width: 46px;\n  height: 27px;\n  flex: none;\n  border-radius: 999px;\n  border: 1px solid var(--pr-line);\n  background: var(--pr-raised);\n  position: relative;\n  display: inline-block;\n}\n\n.pr-toggle i {\n  position: absolute;\n  top: 3px;\n  left: 3px;\n  width: 19px;\n  height: 19px;\n  border-radius: 50%;\n  background: #8b99b2;\n}\n\n.pr-toggle[data-on='true'] {\n  background: var(--pr-blue);\n  border-color: var(--pr-blue);\n}\n\n.pr-toggle[data-on='true'] i {\n  left: 22px;\n  background: #fff;\n}\n\n/* Section */\n.pr-section {\n  display: flex;\n  flex-direction: column;\n  gap: 10px;\n  min-width: 0;\n}\n\n.pr-section-head {\n  display: flex;\n  align-items: center;\n  justify-content: space-between;\n  gap: 12px;\n  padding: 4px 2px 0;\n}\n\n.pr-section-head h2 {\n  margin: 0;\n  font-size: 17px;\n  line-height: 1.35;\n  font-weight: 600;\n  letter-spacing: -0.2px;\n}\n\n.pr-count {\n  min-width: 26px;\n  height: 24px;\n  display: inline-flex;\n  align-items: center;\n  justify-content: center;\n  padding: 0 8px;\n  border-radius: 999px;\n  background: rgba(255, 255, 255, 0.06);\n  color: var(--pr-muted);\n  font-size: 12px;\n  font-variant-numeric: tabular-nums;\n}\n\n.pr-caption {\n  font-size: 12px;\n  color: var(--pr-muted);\n}\n\n.pr-link {\n  display: inline-flex;\n  align-items: center;\n  gap: 6px;\n  min-height: 44px;\n  padding: 6px 2px;\n  border: 0;\n  background: none;\n  color: #aab8ff;\n  font: inherit;\n  font-size: 12.5px;\n  cursor: pointer;\n  touch-action: manipulation;\n}\n\n.pr-link.danger {\n  color: var(--pr-danger);\n}\n\n.pr-link.muted {\n  color: var(--pr-muted);\n}\n\n.pr-link:disabled {\n  opacity: 0.5;\n}\n\n.pr-list {\n  display: flex;\n  flex-direction: column;\n  gap: 10px;\n}\n\n/* Candidate */\n.pr-cand {\n  padding: 6px 6px 4px;\n  border-radius: 20px;\n  overflow: hidden;\n}\n\n.pr-cand-main {\n  width: 100%;\n  display: flex;\n  flex-direction: column;\n  gap: 7px;\n  padding: 12px 12px 8px;\n  border: 0;\n  background: none;\n  color: var(--pr-ink);\n  font: inherit;\n  text-align: left;\n  cursor: pointer;\n  touch-action: manipulation;\n}\n\n.pr-cand-title {\n  font-size: 15px;\n  line-height: 1.42;\n  font-weight: 600;\n  overflow-wrap: anywhere;\n}\n\n.pr-cand-meta {\n  display: flex;\n  flex-wrap: wrap;\n  align-items: center;\n  gap: 6px 8px;\n  font-size: 12px;\n  color: var(--pr-muted);\n  line-height: 1.4;\n}\n\n.pr-tag {\n  padding: 1px 8px;\n  border-radius: 999px;\n  background: rgba(255, 255, 255, 0.06);\n  font-size: 11px;\n}\n\n.pr-price-sm {\n  color: #c6d1e8;\n  font-variant-numeric: tabular-nums;\n}\n\n.pr-cand-actions {\n  display: flex;\n  align-items: center;\n  justify-content: flex-end;\n  gap: 18px;\n  padding: 0 12px 4px;\n}\n\n/* Records */\n.pr-record {\n  width: 100%;\n  display: flex;\n  flex-direction: column;\n  gap: 7px;\n  padding: 15px 16px;\n  text-align: left;\n  color: var(--pr-ink);\n  font: inherit;\n  cursor: pointer;\n  touch-action: manipulation;\n}\n\n.pr-record:active {\n  transform: scale(0.994);\n}\n\n.pr-record-top {\n  display: flex;\n  align-items: center;\n  justify-content: space-between;\n  gap: 10px;\n}\n\n.pr-record-top time {\n  font-size: 11.5px;\n  color: var(--pr-muted);\n  white-space: nowrap;\n}\n\n.pr-record-title {\n  font-size: 15.5px;\n  line-height: 1.4;\n  font-weight: 600;\n  overflow-wrap: anywhere;\n}\n\n.pr-record-meta {\n  display: flex;\n  flex-wrap: wrap;\n  align-items: center;\n  gap: 5px 10px;\n  font-size: 12px;\n  color: var(--pr-muted);\n}\n\n.pr-best-mini {\n  margin-left: auto;\n  color: var(--pr-ok);\n  font-size: 13px;\n  font-weight: 600;\n  font-variant-numeric: tabular-nums;\n}\n\n.pr-status {\n  display: inline-flex;\n  align-items: center;\n  gap: 6px;\n  padding: 3px 9px;\n  border-radius: 999px;\n  background: rgba(255, 255, 255, 0.06);\n  color: var(--pr-muted);\n  font-size: 11.5px;\n  white-space: nowrap;\n}\n\n.pr-status::before {\n  content: '';\n  width: 6px;\n  height: 6px;\n  border-radius: 50%;\n  background: currentColor;\n  flex: none;\n}\n\n.pr-status[data-tone='ok'] {\n  background: rgba(104, 195, 158, 0.12);\n  color: var(--pr-ok);\n}\n\n.pr-status[data-tone='warn'] {\n  background: rgba(228, 184, 91, 0.12);\n  color: var(--pr-warn);\n}\n\n.pr-status[data-tone='danger'] {\n  background: rgba(238, 155, 152, 0.12);\n  color: var(--pr-danger);\n}\n\n.pr-status[data-tone='live'] {\n  background: rgba(77, 107, 254, 0.16);\n  color: #b3c2ff;\n}\n\n.pr-status[data-tone='live']::before {\n  animation: pr-pulse 1.4s ease-in-out infinite;\n}\n\n/* Task */\n.pr-task {\n  padding: 16px;\n  border-color: rgba(77, 107, 254, 0.3);\n  background:\n    radial-gradient(120% 100% at 100% 0%, rgba(77, 107, 254, 0.18), transparent 60%),\n    linear-gradient(160deg, rgba(29, 44, 78, 0.78), rgba(19, 28, 46, 0.9));\n}\n\n.pr-task-top {\n  display: flex;\n  align-items: center;\n  gap: 12px;\n}\n\n.pr-task-done {\n  width: 44px;\n  height: 44px;\n  flex: none;\n  display: grid;\n  place-items: center;\n  border-radius: 50%;\n  background: rgba(104, 195, 158, 0.12);\n  color: var(--pr-ok);\n  border: 1px solid rgba(104, 195, 158, 0.3);\n}\n\n.pr-task-copy {\n  flex: 1;\n  min-width: 0;\n}\n\n.pr-task-copy strong {\n  display: block;\n  font-size: 15px;\n  line-height: 1.35;\n}\n\n.pr-task-copy span {\n  display: block;\n  margin-top: 2px;\n  font-size: 12px;\n  color: #b7c4f5;\n}\n\n.pr-events {\n  list-style: none;\n  margin: 13px 0 0;\n  padding: 0;\n  display: flex;\n  flex-direction: column;\n  gap: 7px;\n}\n\n.pr-events li {\n  display: flex;\n  gap: 8px;\n  align-items: flex-start;\n  font-size: 12.5px;\n  line-height: 1.5;\n  color: #c8d2e6;\n  min-width: 0;\n  overflow-wrap: anywhere;\n}\n\n.pr-event-dot {\n  width: 5px;\n  height: 5px;\n  flex: none;\n  margin-top: 7px;\n  border-radius: 50%;\n  background: #7d90b8;\n}\n\n.pr-events li[data-kind='tool'] .pr-event-dot {\n  background: var(--pr-blue);\n  box-shadow: 0 0 8px rgba(77, 107, 254, 0.8);\n}\n\n.pr-task-control {\n  margin-top: 12px;\n  min-height: 0;\n}\n\n.pr-btn-row {\n  display: flex;\n  flex-wrap: wrap;\n  align-items: center;\n  gap: 10px;\n}\n\n.pr-btn-row > .wish-button {\n  flex: 1 1 130px;\n}\n\n.pr-task .pr-btn-row {\n  margin-top: 10px;\n  justify-content: flex-end;\n}\n\n/* Detail */\n.pr-detail-head {\n  padding: 18px;\n}\n\n.pr-detail-top {\n  display: flex;\n  align-items: center;\n  justify-content: space-between;\n  gap: 10px;\n}\n\n.pr-detail-top time {\n  font-size: 11.5px;\n  color: var(--pr-muted);\n}\n\n.pr-detail-head h2 {\n  margin: 12px 0 6px;\n  font-size: 19px;\n  line-height: 1.4;\n  letter-spacing: -0.3px;\n  font-weight: 600;\n}\n\n.pr-spec {\n  margin: 0 0 6px;\n  font-size: 13px;\n  color: #c3cddf;\n}\n\n.pr-note {\n  margin: 0;\n  font-size: 12.5px;\n  line-height: 1.55;\n  color: var(--pr-muted);\n}\n\n.pr-warnline {\n  margin: 8px 0 0;\n  font-size: 12.5px;\n  line-height: 1.55;\n  color: #ecd8ab;\n  padding: 9px 12px;\n  border-radius: 12px;\n  background: rgba(228, 184, 91, 0.09);\n  border: 1px solid rgba(228, 184, 91, 0.28);\n}\n\n.pr-bestbox {\n  display: flex;\n  flex-direction: column;\n  gap: 2px;\n  margin-top: 14px;\n  padding: 13px 15px;\n  border-radius: 16px;\n  border: 1px solid rgba(104, 195, 158, 0.24);\n  background:\n    radial-gradient(100% 120% at 100% 0%, rgba(104, 195, 158, 0.16), transparent 65%),\n    rgba(104, 195, 158, 0.07);\n}\n\n.pr-bestbox > span {\n  font-size: 11.5px;\n  color: #a6dfc9;\n  letter-spacing: 0.02em;\n}\n\n.pr-bestbox > strong {\n  font-size: 30px;\n  line-height: 1.2;\n  letter-spacing: -0.8px;\n  font-variant-numeric: tabular-nums;\n  color: #d6f4e7;\n}\n\n.pr-bestbox > small {\n  font-size: 11.5px;\n  color: #8fbfae;\n  line-height: 1.45;\n}\n\n.pr-bestbox.empty {\n  border-color: var(--pr-line);\n  background: rgba(255, 255, 255, 0.03);\n}\n\n.pr-bestbox.empty > span,\n.pr-bestbox.empty > small {\n  color: var(--pr-muted);\n}\n\n.pr-bestbox.empty > strong {\n  color: #7f8da6;\n  font-size: 24px;\n}\n\n/* Table */\n.pr-table-wrap {\n  border-radius: 18px;\n  border-color: var(--pr-line);\n  background: rgba(19, 28, 46, 0.6);\n  -webkit-overflow-scrolling: touch;\n}\n\n.pr-table {\n  min-width: 330px;\n}\n\n.pr-table th {\n  font-size: 11.5px;\n  letter-spacing: 0.04em;\n}\n\n.pr-table td {\n  border-bottom-color: rgba(255, 255, 255, 0.07);\n  padding: 11px 10px;\n}\n\n.pr-cell-platform {\n  display: flex;\n  align-items: center;\n  gap: 8px;\n  min-width: 0;\n}\n\n.pr-cell-platform > span:last-child {\n  display: flex;\n  flex-direction: column;\n  gap: 1px;\n  min-width: 0;\n}\n\n.pr-cell-platform strong {\n  font-size: 12.5px;\n  line-height: 1.35;\n  font-weight: 500;\n  overflow-wrap: anywhere;\n}\n\n.pr-cell-platform small,\n.pr-table td > small {\n  display: block;\n  margin-top: 2px;\n  font-size: 10.5px;\n  line-height: 1.4;\n  color: var(--pr-muted);\n}\n\n.pr-cell-price {\n  display: block;\n  font-size: 15px;\n  line-height: 1.2;\n  font-variant-numeric: tabular-nums;\n  white-space: nowrap;\n}\n\n.pr-cell-price.muted {\n  color: var(--pr-muted);\n}\n\n.pr-cell-condition {\n  display: block;\n  font-size: 11.5px;\n  line-height: 1.45;\n  color: #b9c4d8;\n  overflow-wrap: anywhere;\n}\n\n.pr-missing-row td {\n  background: rgba(228, 184, 91, 0.045);\n}\n\n.pr-pdot {\n  width: 28px;\n  height: 28px;\n  flex: none;\n  display: inline-grid;\n  place-items: center;\n  border-radius: 9px;\n  border: 1px solid transparent;\n  font-size: 12px;\n  font-weight: 600;\n}\n\n/* Sources */\n.pr-source {\n  display: flex;\n  gap: 11px;\n  align-items: flex-start;\n  padding: 13px 14px;\n  border-radius: 16px;\n}\n\n.pr-source-body {\n  flex: 1;\n  min-width: 0;\n  display: flex;\n  flex-direction: column;\n  gap: 3px;\n}\n\n.pr-source a {\n  color: #a5baff;\n  font-size: 12.5px;\n  line-height: 1.45;\n  overflow-wrap: anywhere;\n  text-underline-offset: 2px;\n}\n\n.pr-source time {\n  font-size: 11px;\n  color: var(--pr-muted);\n}\n\n.pr-source p {\n  margin: 2px 0 0;\n  font-size: 11.5px;\n  line-height: 1.45;\n  color: #b9c4d8;\n}\n\n.pr-assumptions {\n  margin: 0;\n  padding: 14px 16px 14px 32px;\n  border-radius: 16px;\n  background: rgba(255, 255, 255, 0.035);\n  border: 1px solid var(--pr-line);\n  font-size: 12.5px;\n  line-height: 1.6;\n  color: #c3cddf;\n}\n\n.pr-assumptions li + li {\n  margin-top: 6px;\n}\n\n/* Action card */\n.pr-action-card {\n  padding: 15px 16px;\n}\n\n.pr-action-head {\n  display: flex;\n  align-items: flex-start;\n  gap: 11px;\n}\n\n.pr-action-icon {\n  width: 38px;\n  height: 38px;\n  flex: none;\n  display: grid;\n  place-items: center;\n  border-radius: 12px;\n  background: rgba(228, 184, 91, 0.12);\n  border: 1px solid rgba(228, 184, 91, 0.26);\n  color: #eccb85;\n}\n\n.pr-action-head strong {\n  display: block;\n  font-size: 14px;\n  line-height: 1.4;\n}\n\n.pr-action-head small {\n  display: block;\n  margin-top: 2px;\n  font-size: 11.5px;\n  line-height: 1.45;\n  color: var(--pr-muted);\n}\n\n.pr-reminder-set {\n  display: flex;\n  align-items: center;\n  justify-content: space-between;\n  gap: 10px;\n  margin-top: 12px;\n  padding: 10px 12px;\n  border-radius: 12px;\n  background: rgba(104, 195, 158, 0.09);\n  border: 1px solid rgba(104, 195, 158, 0.22);\n  font-size: 12px;\n  color: #b8e3d2;\n}\n\n.pr-chips {\n  display: flex;\n  flex-wrap: wrap;\n  gap: 8px;\n  margin-top: 12px;\n}\n\n.pr-chip {\n  display: inline-flex;\n  align-items: center;\n  gap: 7px;\n  min-height: 44px;\n  padding: 8px 14px;\n  border-radius: 999px;\n  border: 1px solid var(--pr-line);\n  background: rgba(26, 39, 64, 0.76);\n  color: #c6cfdf;\n  font: inherit;\n  font-size: 13px;\n  cursor: pointer;\n  touch-action: manipulation;\n}\n\n.pr-chip[data-on='true'] {\n  background: rgba(77, 107, 254, 0.9);\n  border-color: rgba(122, 144, 255, 0.9);\n  color: #fff;\n  font-weight: 600;\n}\n\n.pr-chip:disabled {\n  opacity: 0.55;\n}\n\n.pr-chip-dot {\n  width: 7px;\n  height: 7px;\n  border-radius: 50%;\n  flex: none;\n}\n\n/* Memory */\n.pr-page-intro {\n  padding: 2px 2px 0;\n}\n\n.pr-page-intro h2 {\n  margin: 0 0 5px;\n  font-size: 19px;\n  line-height: 1.35;\n  letter-spacing: -0.3px;\n}\n\n.pr-page-intro p {\n  margin: 0;\n  font-size: 12.5px;\n  line-height: 1.6;\n  color: var(--pr-muted);\n}\n\n.pr-mem {\n  padding: 16px;\n}\n\n.pr-mem-head {\n  display: flex;\n  align-items: flex-start;\n  justify-content: space-between;\n  gap: 10px;\n  margin-bottom: 10px;\n}\n\n.pr-mem-title {\n  display: flex;\n  flex-wrap: wrap;\n  align-items: center;\n  gap: 7px;\n  font-size: 16px;\n  font-weight: 600;\n  line-height: 1.35;\n}\n\n.pr-mem-title small {\n  flex-basis: 100%;\n  padding-left: 15px;\n  font-size: 11px;\n  font-weight: 400;\n  color: var(--pr-muted);\n  line-height: 1.45;\n}\n\n.pr-mem-time {\n  flex: none;\n  font-size: 11px;\n  color: var(--pr-muted);\n  padding-top: 2px;\n}\n\n.pr-dot {\n  width: 8px;\n  height: 8px;\n  border-radius: 50%;\n  flex: none;\n  background: var(--pr-blue);\n  box-shadow: 0 0 0 3px rgba(77, 107, 254, 0.14);\n}\n\n.pr-dot[data-ok='true'] {\n  background: var(--pr-ok);\n  box-shadow: 0 0 0 3px rgba(104, 195, 158, 0.16);\n}\n\n.pr-dot[data-ok='false'] {\n  background: var(--pr-warn);\n  box-shadow: 0 0 0 3px rgba(228, 184, 91, 0.16);\n}\n\n.pr-coupon {\n  display: flex;\n  gap: 8px;\n  align-items: flex-start;\n  margin: 0 0 10px;\n  padding: 10px 12px;\n  border-radius: 13px;\n  background: rgba(77, 107, 254, 0.1);\n  border: 1px solid rgba(77, 107, 254, 0.24);\n  font-size: 12px;\n  line-height: 1.5;\n  color: #c8d3f4;\n}\n\n.pr-coupon svg {\n  flex: none;\n  margin-top: 1px;\n  color: #a8b8ff;\n}\n\n.pr-steps {\n  margin: 0;\n  padding: 0 0 0 20px;\n  display: flex;\n  flex-direction: column;\n  gap: 6px;\n  font-size: 12.5px;\n  line-height: 1.55;\n  color: #c3cddf;\n}\n\n.pr-steps li::marker {\n  color: #7f90b8;\n  font-size: 11px;\n}\n\n.pr-mem-actions {\n  display: flex;\n  align-items: center;\n  gap: 18px;\n  margin-top: 10px;\n  padding-top: 6px;\n  border-top: 1px solid rgba(255, 255, 255, 0.07);\n}\n\n.pr-mem-editor {\n  display: flex;\n  flex-direction: column;\n  gap: 13px;\n}\n\n.pr-textarea {\n  min-height: 70px;\n  resize: vertical;\n  line-height: 1.55;\n}\n\n.pr-ai-loading {\n  display: flex;\n  align-items: center;\n  gap: 10px;\n  padding: 11px 13px;\n  border-radius: 13px;\n  background: rgba(77, 107, 254, 0.1);\n  border: 1px solid rgba(77, 107, 254, 0.25);\n  font-size: 12.5px;\n  color: #c8d3f4;\n}\n\n.pr-preview {\n  padding: 14px;\n  border-radius: 16px;\n  border-color: rgba(104, 195, 158, 0.26);\n  background: rgba(104, 195, 158, 0.06);\n}\n\n.pr-preview > strong {\n  display: block;\n  font-size: 13px;\n  color: #b9e6d3;\n  margin-bottom: 7px;\n}\n\n.pr-preview ol {\n  margin: 0;\n  padding-left: 19px;\n  display: flex;\n  flex-direction: column;\n  gap: 5px;\n  font-size: 12.5px;\n  line-height: 1.55;\n  color: #cfe5da;\n}\n\n.pr-rule {\n  padding: 16px;\n}\n\n.pr-rule-head {\n  display: flex;\n  align-items: center;\n  gap: 9px;\n  color: #b9c8e8;\n}\n\n.pr-rule-head strong {\n  font-size: 14.5px;\n}\n\n.pr-rule ul {\n  margin: 10px 0 0;\n  padding-left: 18px;\n  display: flex;\n  flex-direction: column;\n  gap: 4px;\n  font-size: 12px;\n  line-height: 1.55;\n  color: #b9c4d8;\n}\n\n.pr-note-sm {\n  margin: 8px 0 0;\n  font-size: 11.5px;\n  line-height: 1.55;\n  color: var(--pr-muted);\n}\n\n/* Settings */\n.pr-settings {\n  gap: 18px;\n  padding-bottom: 8px;\n}\n\n.pr-settings fieldset {\n  border-radius: 20px;\n  background:\n    linear-gradient(158deg, rgba(32, 47, 79, 0.5), rgba(19, 28, 46, 0.82));\n  -webkit-backdrop-filter: blur(16px);\n  backdrop-filter: blur(16px);\n}\n\n.pr-setting-stack {\n  flex-wrap: wrap;\n}\n\n.pr-setting-stack .pr-chips {\n  margin-top: 10px;\n  flex-basis: 100%;\n}\n\n.pr-settings .wish-setting-label small {\n  line-height: 1.45;\n  margin-top: 2px;\n}\n\n/* Forms */\n.pr-form-card {\n  padding: 18px;\n  display: flex;\n  flex-direction: column;\n  gap: 15px;\n}\n\n.pr-field {\n  display: flex;\n  flex-direction: column;\n  gap: 7px;\n}\n\n.pr-field-label {\n  display: flex;\n  align-items: baseline;\n  justify-content: space-between;\n  gap: 10px;\n  font-size: 13px;\n  color: #c9d2e4;\n}\n\n.pr-field-label small {\n  font-size: 11px;\n  color: var(--pr-muted);\n}\n\n.pr-form-card .wish-input {\n  font-size: 15px;\n}\n\n.pr-toggle-row {\n  display: flex;\n  align-items: center;\n  gap: 12px;\n  min-height: 60px;\n  padding: 11px 0 3px;\n  border-top: 1px solid rgba(255, 255, 255, 0.08);\n}\n\n.pr-toggle-row > span {\n  flex: 1;\n  min-width: 0;\n}\n\n.pr-toggle-row strong {\n  display: block;\n  font-size: 13.5px;\n  font-weight: 500;\n}\n\n.pr-toggle-row small {\n  display: block;\n  margin-top: 2px;\n  font-size: 11px;\n  line-height: 1.45;\n  color: var(--pr-muted);\n}\n\n.pr-toggle-row input[type='checkbox'] {\n  appearance: none;\n  width: 48px;\n  height: 28px;\n  flex: none;\n  border-radius: 999px;\n  background: var(--pr-raised);\n  border: 1px solid var(--pr-line);\n  position: relative;\n}\n\n.pr-toggle-row input[type='checkbox']::after {\n  content: '';\n  display: block;\n  width: 20px;\n  height: 20px;\n  border-radius: 50%;\n  background: #8b99b2;\n  position: absolute;\n  top: 3px;\n  left: 3px;\n}\n\n.pr-toggle-row input[type='checkbox']:checked {\n  background: var(--pr-blue);\n}\n\n.pr-toggle-row input[type='checkbox']:checked::after {\n  background: #fff;\n  left: 23px;\n}\n\n.pr-submit {\n  width: 100%;\n  min-height: 50px;\n  font-size: 15.5px;\n}\n\n.pr-whitelist {\n  margin: 8px 0 0;\n  padding: 0;\n  list-style: none;\n  display: flex;\n  flex-direction: column;\n  gap: 6px;\n  font-size: 11.5px;\n  line-height: 1.5;\n  color: #b9c4d8;\n}\n\n.pr-whitelist strong {\n  display: inline-block;\n  min-width: 64px;\n  color: #dbe3f3;\n  font-weight: 500;\n}\n\n.pr-details {\n  border-top: 1px solid rgba(255, 255, 255, 0.08);\n  padding-top: 10px;\n  margin-top: 4px;\n}\n\n.pr-details summary {\n  min-height: 44px;\n  display: flex;\n  align-items: center;\n  font-size: 12.5px;\n  color: #aab8ff;\n  cursor: pointer;\n  touch-action: manipulation;\n}\n\n.pr-details ul {\n  margin: 4px 0 4px;\n  padding-left: 18px;\n  font-size: 12px;\n  line-height: 1.55;\n  color: var(--pr-muted);\n}\n\n.pr-raw {\n  margin: 6px 0 0;\n  padding: 11px 12px;\n  border-radius: 12px;\n  background: rgba(8, 14, 26, 0.7);\n  border: 1px solid var(--pr-line);\n  font-size: 11.5px;\n  line-height: 1.5;\n  color: #bdc7da;\n  white-space: pre-wrap;\n  overflow-wrap: anywhere;\n  max-height: 220px;\n  overflow: auto;\n}\n\n.pr-success-line {\n  margin: 2px 0 0;\n  font-size: 12px;\n  line-height: 1.5;\n  color: var(--pr-ok);\n}\n\n/* Start */\n.pr-start-head {\n  padding: 16px;\n}\n\n.pr-start-top {\n  display: flex;\n  align-items: flex-start;\n  gap: 11px;\n}\n\n.pr-start-top .pr-action-icon {\n  background: rgba(77, 107, 254, 0.14);\n  border-color: rgba(77, 107, 254, 0.3);\n  color: #b3c2ff;\n}\n\n.pr-start-top strong {\n  display: block;\n  font-size: 14.5px;\n  line-height: 1.4;\n}\n\n.pr-start-top small {\n  display: block;\n  margin-top: 2px;\n  font-size: 11.5px;\n  line-height: 1.45;\n  color: var(--pr-muted);\n}\n\n.pr-badge {\n  flex: none;\n  padding: 3px 9px;\n  border-radius: 999px;\n  background: rgba(104, 195, 158, 0.12);\n  border: 1px solid rgba(104, 195, 158, 0.24);\n  color: #a8e2cb;\n  font-size: 10.5px;\n}\n\n.pr-start-channels {\n  display: flex;\n  flex-wrap: wrap;\n  gap: 8px;\n  margin-top: 13px;\n}\n\n/* Camera */\n.pr-camera {\n  padding: 16px;\n}\n\n.pr-camera-head {\n  display: flex;\n  align-items: flex-start;\n  gap: 11px;\n}\n\n.pr-camera-head > div {\n  flex: 1;\n  min-width: 0;\n}\n\n.pr-camera-head strong {\n  display: block;\n  font-size: 14px;\n  line-height: 1.4;\n}\n\n.pr-camera-head small {\n  display: block;\n  margin-top: 2px;\n  font-size: 11.5px;\n  line-height: 1.45;\n  color: var(--pr-muted);\n}\n\n.pr-camera .pr-btn-row {\n  margin-top: 12px;\n}\n\n.pr-photo-wrap {\n  position: relative;\n  margin-top: 12px;\n  border-radius: 16px;\n  overflow: hidden;\n  border: 1px solid var(--pr-line);\n  background: #0a1220;\n}\n\n.pr-photo-wrap img {\n  display: block;\n  width: 100%;\n  max-height: 230px;\n  object-fit: cover;\n}\n\n.pr-photo-busy {\n  position: absolute;\n  inset: 0;\n  display: flex;\n  flex-direction: column;\n  align-items: center;\n  justify-content: center;\n  gap: 10px;\n  background: rgba(8, 14, 26, 0.72);\n  -webkit-backdrop-filter: blur(6px);\n  backdrop-filter: blur(6px);\n  font-size: 12.5px;\n  color: #dbe3f3;\n}\n\n.pr-progress {\n  height: 3px;\n  border-radius: 2px;\n  background: rgba(255, 255, 255, 0.08);\n  overflow: hidden;\n  margin-top: 12px;\n}\n\n.pr-progress > span {\n  display: block;\n  height: 100%;\n  width: 40%;\n  border-radius: 2px;\n  background: linear-gradient(90deg, #4d6bfe, #9fb1ff);\n  animation: pr-slide 1.5s ease-in-out infinite;\n}\n\n/* Empty / skeleton / boot */\n.pr-empty {\n  display: flex;\n  flex-direction: column;\n  align-items: center;\n  text-align: center;\n  gap: 9px;\n  padding: 30px 22px;\n  border: 1px dashed rgba(255, 255, 255, 0.16);\n  border-radius: 20px;\n  background: rgba(255, 255, 255, 0.02);\n  color: var(--pr-muted);\n}\n\n.pr-empty-icon {\n  width: 50px;\n  height: 50px;\n  display: grid;\n  place-items: center;\n  border-radius: 16px;\n  background: rgba(77, 107, 254, 0.12);\n  border: 1px solid rgba(77, 107, 254, 0.26);\n  color: #aebcff;\n  margin-bottom: 2px;\n}\n\n.pr-empty strong {\n  font-size: 15px;\n  color: #dbe2f1;\n  font-weight: 550;\n}\n\n.pr-empty p {\n  margin: 0;\n  max-width: 26em;\n  font-size: 12.5px;\n  line-height: 1.6;\n}\n\n.pr-empty .wish-button {\n  margin-top: 4px;\n}\n\n.pr-boot {\n  display: flex;\n  flex-direction: column;\n  align-items: center;\n  gap: 12px;\n  padding: 34px 16px 20px;\n  text-align: center;\n}\n\n.pr-boot strong {\n  font-size: 15.5px;\n  font-weight: 550;\n}\n\n.pr-boot p {\n  margin: -4px 0 8px;\n  font-size: 12.5px;\n  color: var(--pr-muted);\n}\n\n.pr-skel-card {\n  width: 100%;\n  display: flex;\n  flex-direction: column;\n  gap: 9px;\n  padding: 16px;\n  border-radius: 18px;\n}\n\n.pr-skel {\n  display: block;\n  border-radius: 7px;\n  background: linear-gradient(100deg, rgba(24, 36, 58, 0.9) 20%, rgba(39, 56, 88, 0.95) 42%, rgba(24, 36, 58, 0.9) 64%);\n  background-size: 220% 100%;\n  animation: pr-shimmer 1.8s linear infinite;\n}\n\n.pr-unsupported {\n  display: flex;\n  flex-direction: column;\n  align-items: center;\n  gap: 10px;\n  padding: 34px 22px;\n  margin-top: 12px;\n  text-align: center;\n}\n\n.pr-unsupported strong {\n  font-size: 16px;\n}\n\n.pr-unsupported p {\n  margin: 0;\n  font-size: 12.5px;\n  line-height: 1.6;\n  color: var(--pr-muted);\n}\n\n/* Caps */\n.pr-caps-strip {\n  display: flex;\n  align-items: center;\n  gap: 9px;\n  padding: 11px 14px;\n  border-radius: 15px;\n  font-size: 11.5px;\n  color: var(--pr-muted);\n  line-height: 1.45;\n}\n\n.pr-caps-text {\n  flex: 1;\n  min-width: 0;\n  overflow-wrap: anywhere;\n}\n\n.pr-caps-text i {\n  font-style: normal;\n  padding: 0 3px;\n  opacity: 0.6;\n}\n\n.pr-caps-strip .pr-link {\n  min-height: 44px;\n  font-size: 11.5px;\n}\n\n.pr-cap-list {\n  display: flex;\n  flex-direction: column;\n}\n\n.pr-cap-row {\n  display: flex;\n  align-items: flex-start;\n  gap: 11px;\n  padding: 11px 0;\n  border-bottom: 1px solid rgba(255, 255, 255, 0.07);\n}\n\n.pr-cap-row:last-child {\n  border-bottom: 0;\n}\n\n.pr-cap-icon {\n  width: 30px;\n  height: 30px;\n  flex: none;\n  display: grid;\n  place-items: center;\n  border-radius: 9px;\n  background: rgba(255, 255, 255, 0.05);\n  color: var(--pr-muted);\n  border: 1px solid var(--pr-line);\n}\n\n.pr-cap-icon[data-ok='true'] {\n  background: rgba(104, 195, 158, 0.1);\n  border-color: rgba(104, 195, 158, 0.22);\n  color: var(--pr-ok);\n}\n\n.pr-cap-icon[data-ok='false'] {\n  background: rgba(228, 184, 91, 0.09);\n  border-color: rgba(228, 184, 91, 0.22);\n  color: var(--pr-warn);\n}\n\n.pr-cap-copy {\n  flex: 1;\n  min-width: 0;\n}\n\n.pr-cap-copy strong {\n  display: block;\n  font-size: 13px;\n  font-weight: 500;\n  line-height: 1.4;\n}\n\n.pr-cap-copy small {\n  display: block;\n  margin-top: 2px;\n  font-size: 11px;\n  line-height: 1.45;\n  color: var(--pr-muted);\n}\n\n.pr-cap-row .wish-badge {\n  flex: none;\n  font-size: 10.5px;\n}\n\n/* Sheet */\n.pr-sheet-backdrop {\n  position: fixed;\n  inset: 0;\n  z-index: 60;\n  display: flex;\n  align-items: flex-end;\n  justify-content: center;\n  background: rgba(2, 6, 15, 0.72);\n  -webkit-backdrop-filter: blur(3px);\n  backdrop-filter: blur(3px);\n  animation: pr-fade 0.18s ease both;\n}\n\n.pr-sheet {\n  width: 100%;\n  max-width: 640px;\n  max-height: 82vh;\n  overflow: auto;\n  overscroll-behavior: contain;\n  padding: 10px 18px calc(20px + env(safe-area-inset-bottom));\n  border-radius: 26px 26px 0 0;\n  border: 1px solid var(--pr-line-strong);\n  background:\n    radial-gradient(120% 80% at 100% 0%, rgba(77, 107, 254, 0.16), transparent 60%),\n    #131c2e;\n  box-shadow: 0 -24px 70px rgba(0, 0, 0, 0.6);\n  animation: pr-sheet-up 0.24s cubic-bezier(0.2, 0.9, 0.25, 1) both;\n}\n\n.pr-sheet-grab {\n  width: 38px;\n  height: 4px;\n  border-radius: 2px;\n  background: rgba(255, 255, 255, 0.22);\n  margin: 0 auto 14px;\n}\n\n.pr-sheet-head {\n  display: flex;\n  align-items: flex-start;\n  gap: 12px;\n  margin-bottom: 14px;\n}\n\n.pr-sheet-head h2 {\n  margin: 0;\n  font-size: 18px;\n  line-height: 1.35;\n}\n\n.pr-sheet-head p {\n  margin: 4px 0 0;\n  font-size: 12.5px;\n  line-height: 1.5;\n  color: var(--pr-muted);\n}\n\n.pr-sheet-close {\n  width: 44px;\n  height: 44px;\n  flex: none;\n  display: grid;\n  place-items: center;\n  margin: -8px -6px 0 auto;\n  padding: 0;\n  border-radius: 14px;\n  border: 1px solid var(--pr-line);\n  background: var(--pr-raised);\n  color: #cfd7e6;\n  cursor: pointer;\n}\n\n.pr-sheet-body {\n  display: flex;\n  flex-direction: column;\n  gap: 13px;\n}\n\n.pr-sheet-body .pr-btn-row {\n  margin-top: 2px;\n}\n\n/* Toast */\n.pr-toast {\n  position: fixed;\n  left: 50%;\n  bottom: calc(86px + env(safe-area-inset-bottom));\n  transform: translateX(-50%);\n  z-index: 70;\n  max-width: calc(100% - 40px);\n  padding: 10px 16px;\n  border-radius: 999px;\n  background: rgba(28, 42, 69, 0.94);\n  border: 1px solid var(--pr-line-strong);\n  color: #f4f1ea;\n  font-size: 12.5px;\n  line-height: 1.4;\n  text-align: center;\n  box-shadow: 0 16px 44px rgba(0, 0, 0, 0.55);\n  -webkit-backdrop-filter: blur(14px);\n  backdrop-filter: blur(14px);\n  animation: pr-fade 0.16s ease both;\n}\n\n/* Tabs */\n.pr-tabs {\n  gap: 6px;\n  padding-top: 8px;\n  background: linear-gradient(180deg, rgba(12, 20, 36, 0.2), rgba(12, 20, 36, 0.92));\n}\n\n.pr-tab {\n  display: flex;\n  flex-direction: column;\n  align-items: center;\n  justify-content: center;\n  gap: 3px;\n  min-height: 54px;\n  padding: 6px 4px;\n  border: 1px solid transparent;\n  border-radius: 15px;\n  background: none;\n  color: var(--pr-muted);\n  font: inherit;\n  font-size: 11px;\n  cursor: pointer;\n  touch-action: manipulation;\n}\n\n.pr-tab[aria-current='page'] {\n  color: #eef1f8;\n  background: rgba(77, 107, 254, 0.16);\n  border-color: rgba(77, 107, 254, 0.24);\n}\n\n.pr-tab[aria-current='page'] svg {\n  color: #b3c2ff;\n}\n\n.pr-tab svg {\n  width: 21px;\n  height: 21px;\n}\n\n/* Spinner */\n.pr-spin {\n  --pr-spin-size: 24px;\n  width: var(--pr-spin-size);\n  height: var(--pr-spin-size);\n  flex: none;\n  border-radius: 50%;\n  background: conic-gradient(from 0deg, #4d6bfe 0deg, #4d6bfe 100deg, rgba(77, 107, 254, 0) 250deg);\n  position: relative;\n  animation: pr-spin 0.95s linear infinite;\n  display: inline-block;\n}\n\n.pr-spin::after {\n  content: '';\n  position: absolute;\n  inset: 3px;\n  border-radius: 50%;\n  background: #19243c;\n}\n\n.pr-spin-sm {\n  --pr-spin-size: 18px;\n}\n\n.pr-spin-sm::after {\n  inset: 2px;\n  background: rgba(19, 28, 46, 0.9);\n}\n\n/* Animations */\n@keyframes pr-spin {\n  to {\n    transform: rotate(360deg);\n  }\n}\n\n@keyframes pr-pulse {\n  0%,\n  100% {\n    opacity: 1;\n    transform: scale(1);\n  }\n  50% {\n    opacity: 0.5;\n    transform: scale(0.9);\n  }\n}\n\n@keyframes pr-breathe {\n  0%,\n  100% {\n    opacity: 0.72;\n    transform: scale(1);\n  }\n  50% {\n    opacity: 1;\n    transform: scale(1.12);\n  }\n}\n\n@keyframes pr-shimmer {\n  to {\n    background-position: -220% 0;\n  }\n}\n\n@keyframes pr-slide {\n  0% {\n    transform: translateX(-120%);\n  }\n  55% {\n    transform: translateX(150%);\n  }\n  100% {\n    transform: translateX(280%);\n  }\n}\n\n@keyframes pr-sheen {\n  0%,\n  55% {\n    transform: translateX(-120%);\n  }\n  80%,\n  100% {\n    transform: translateX(130%);\n  }\n}\n\n@keyframes pr-fade {\n  from {\n    opacity: 0;\n  }\n  to {\n    opacity: 1;\n  }\n}\n\n@keyframes pr-sheet-up {\n  from {\n    transform: translateY(28px);\n    opacity: 0.6;\n  }\n  to {\n    transform: translateY(0);\n    opacity: 1;\n  }\n}\n\n@keyframes pr-enter {\n  from {\n    opacity: 0;\n    transform: translateY(7px);\n  }\n  to {\n    opacity: 1;\n    transform: none;\n  }\n}\n\n@media (prefers-reduced-motion: no-preference) {\n  .pr-app[data-active='true'] .pr-hero,\n  .pr-app[data-active='true'] .pr-stat,\n  .pr-app[data-active='true'] .pr-record,\n  .pr-app[data-active='true'] .pr-cand,\n  .pr-app[data-active='true'] .pr-mem {\n    animation: pr-enter 0.26s ease-out both;\n  }\n  .pr-app[data-active='true'] .pr-stat:nth-child(2) {\n    animation-delay: 0.04s;\n  }\n  .pr-app[data-active='true'] .pr-stat:nth-child(3) {\n    animation-delay: 0.08s;\n  }\n  .pr-cta:active,\n  .pr-ghost:active {\n    transition: transform 0.12s ease;\n  }\n  .pr-toggle i {\n    transition: left 0.16s ease, background 0.16s ease;\n  }\n}\n\n.pr-app[data-active='false'] .pr-radar::after,\n.pr-app[data-active='false'] .pr-radar i,\n.pr-app[data-active='false'] .pr-cta::after,\n.pr-app[data-active='false'] .pr-hero-glow,\n.pr-app[data-active='false'] .pr-live i {\n  animation-play-state: paused;\n}\n\n@media (prefers-reduced-motion: reduce) {\n  .pr-app *,\n  .pr-app *::before,\n  .pr-app *::after {\n    animation-duration: 0.001ms !important;\n    animation-iteration-count: 1 !important;\n    transition-duration: 0.001ms !important;\n  }\n}\n\n@media (max-width: 360px) {\n  .pr-hero {\n    padding: 21px 16px 17px;\n  }\n  .pr-hero h2 {\n    font-size: 24px;\n  }\n  .pr-hero-radar {\n    right: -34px;\n    top: 0;\n    transform: scale(0.86);\n  }\n  .pr-stat {\n    padding: 11px 12px;\n  }\n  .pr-stat strong {\n    font-size: 19px;\n  }\n  .pr-mem {\n    padding: 14px;\n  }\n  .pr-form-card {\n    padding: 16px;\n  }\n}\n\n@media (max-height: 420px) {\n  .pr-hero-radar {\n    display: none;\n  }\n  .pr-boot {\n    padding-top: 18px;\n  }\n}\n\n.pr-unverified-row td {\n  background: rgba(238, 155, 152, 0.035);\n}\n\n.pr-unverified-row .pr-cell-platform small {\n  color: #e0b3b0;\n}\n\n/* Source page and link-optional flow */\n.pr-source-banner {\n  padding: 15px 16px 6px;\n  border-color: rgba(104, 195, 158, 0.24);\n  background:\n    radial-gradient(120% 120% at 100% 0%, rgba(104, 195, 158, 0.14), transparent 62%),\n    linear-gradient(158deg, rgba(31, 50, 76, 0.62), rgba(19, 28, 46, 0.88));\n}\n\n.pr-source-banner-top {\n  display: flex;\n  align-items: center;\n  gap: 11px;\n  padding-bottom: 8px;\n}\n\n.pr-source-banner-top > div {\n  flex: 1;\n  min-width: 0;\n}\n\n.pr-source-banner-top strong {\n  display: block;\n  font-size: 14px;\n  line-height: 1.4;\n}\n\n.pr-source-banner-top small {\n  display: block;\n  margin-top: 2px;\n  font-size: 11.5px;\n  line-height: 1.45;\n  color: var(--pr-muted);\n}\n\n.pr-note-card {\n  display: flex;\n  align-items: flex-start;\n  gap: 9px;\n  padding: 12px 14px;\n  border-radius: 15px;\n  border: 1px solid rgba(77, 107, 254, 0.22);\n  background: rgba(77, 107, 254, 0.08);\n  color: #c8d3f4;\n  font-size: 12px;\n  line-height: 1.55;\n}\n\n.pr-note-card svg {\n  flex: none;\n  margin-top: 1px;\n  color: #a8b8ff;\n}\n\n.pr-source-line {\n  margin: 2px 0 6px;\n}\n\n.pr-source-nolink {\n  color: #9fb1c9;\n  font-size: 12.5px;\n  line-height: 1.45;\n}\n\n.pr-chip-source {\n  font-size: 10px;\n  line-height: 1;\n  padding: 3px 5px;\n  border-radius: 6px;\n  background: rgba(255, 255, 255, 0.18);\n}\n\n.pr-chip[data-source='true'] {\n  cursor: default;\n}\n\n.pr-chip[data-source='true'] {\n  background: rgba(104, 195, 158, 0.16);\n  border-color: rgba(104, 195, 158, 0.34);\n  color: #b9e6d3;\n}\n\n.pr-details-fields {\n  display: flex;\n  flex-direction: column;\n  gap: 15px;\n  padding-top: 4px;\n}\n\n.pr-live-prices {\n  display: flex;\n  flex-wrap: wrap;\n  align-items: center;\n  gap: 6px 8px;\n  margin-top: 10px;\n  padding: 9px 11px;\n  border-radius: 12px;\n  background: rgba(104, 195, 158, 0.08);\n  border: 1px solid rgba(104, 195, 158, 0.22);\n  color: #b8e3d2;\n  font-size: 11.5px;\n  line-height: 1.45;\n}\n\n.pr-live-dot {\n  width: 6px;\n  height: 6px;\n  flex: none;\n  border-radius: 50%;\n  background: var(--pr-ok);\n  animation: pr-pulse 1.6s ease-in-out infinite;\n}\n\n.pr-live-list {\n  color: #8fbfae;\n  font-size: 11px;\n  overflow-wrap: anywhere;\n}\n\n.pr-stall {\n  margin: 10px 0 0;\n  padding: 10px 12px;\n  border-radius: 12px;\n  background: rgba(228, 184, 91, 0.1);\n  border: 1px solid rgba(228, 184, 91, 0.28);\n  color: #ecd8ab;\n  font-size: 12px;\n  line-height: 1.5;\n}\n\n/* Per-platform price chips and consistency */\n.pr-platform-prices {\n  display: flex;\n  flex-wrap: wrap;\n  gap: 6px;\n  margin-top: 8px;\n}\n\n.pr-price-chip {\n  display: inline-flex;\n  align-items: center;\n  gap: 5px;\n  padding: 4px 8px;\n  border-radius: 8px;\n  background: rgba(255, 255, 255, 0.045);\n  border: 1px solid rgba(255, 255, 255, 0.08);\n  color: var(--pr-muted);\n  font-size: 10.5px;\n  line-height: 1.4;\n  white-space: nowrap;\n}\n\n.pr-price-chip i {\n  width: 5px;\n  height: 5px;\n  flex: none;\n  border-radius: 50%;\n}\n\n.pr-price-chip strong {\n  color: #dbe3f3;\n  font-size: 11px;\n  font-weight: 600;\n  font-variant-numeric: tabular-nums;\n}\n\n.pr-price-chip em {\n  font-style: normal;\n  padding: 0 4px;\n  border-radius: 5px;\n  background: rgba(228, 184, 91, 0.16);\n  color: #e4c27a;\n  font-size: 9.5px;\n}\n\n.pr-price-chip[data-missing='true'] {\n  opacity: 0.72;\n}\n\n.pr-price-chip[data-missing='true'] strong {\n  color: var(--pr-muted);\n  font-weight: 400;\n}\n\n.pr-match {\n  display: inline-flex;\n  align-items: center;\n  margin-bottom: 3px;\n  padding: 1px 6px;\n  border-radius: 5px;\n  background: rgba(255, 255, 255, 0.055);\n  color: var(--pr-muted);\n  font-size: 10px;\n  line-height: 1.6;\n  white-space: nowrap;\n}\n\n.pr-match[data-tone='ok'] {\n  background: rgba(104, 195, 158, 0.12);\n  color: var(--pr-ok);\n}\n\n.pr-match[data-tone='warn'] {\n  background: rgba(228, 184, 91, 0.1);\n  color: var(--pr-warn);\n}\n\n.pr-source-match {\n  display: flex;\n  flex-wrap: wrap;\n  align-items: center;\n  gap: 6px;\n  font-size: 11px;\n  color: var(--pr-muted);\n}\n\n.pr-reference-prices {\n  display: flex;\n  flex-wrap: wrap;\n  align-items: center;\n  gap: 6px;\n  margin-top: 6px;\n  padding-top: 6px;\n  border-top: 1px dashed rgba(255, 255, 255, 0.09);\n}\n\n.pr-reference-label {\n  font-size: 10px;\n  color: #8f9ab0;\n  letter-spacing: 0.04em;\n}\n\n.pr-price-chip[data-reference='true'] {\n  background: rgba(228, 184, 91, 0.055);\n  border-color: rgba(228, 184, 91, 0.16);\n}\n\n.pr-price-chip[data-reference='true'] strong {\n  color: #cbb98e;\n}\n\n.pr-kind-tabs {\n  display: grid;\n  grid-template-columns: repeat(3, minmax(0, 1fr));\n  gap: 6px;\n  padding: 5px;\n  border-radius: 16px;\n  background: rgba(19, 28, 46, 0.72);\n  border: 1px solid var(--pr-line);\n}\n\n.pr-kind-tab {\n  min-height: 44px;\n  display: inline-flex;\n  align-items: center;\n  justify-content: center;\n  gap: 6px;\n  border: 1px solid transparent;\n  border-radius: 12px;\n  background: none;\n  color: var(--pr-muted);\n  font: inherit;\n  font-size: 12.5px;\n  font-weight: 500;\n  cursor: pointer;\n  touch-action: manipulation;\n}\n\n.pr-kind-tab[data-on='true'] {\n  color: #eef1f8;\n  background: rgba(77, 107, 254, 0.22);\n  border-color: rgba(77, 107, 254, 0.32);\n}\n\n.pr-form-grid {\n  display: grid;\n  grid-template-columns: repeat(2, minmax(0, 1fr));\n  gap: 12px;\n}\n\n@media (max-width: 340px) {\n  .pr-form-grid {\n    grid-template-columns: 1fr;\n  }\n}\n\n.pr-kind-badge {\n  display: inline-flex;\n  align-items: center;\n  padding: 2px 7px;\n  border-radius: 6px;\n  background: rgba(77, 107, 254, 0.12);\n  border: 1px solid rgba(77, 107, 254, 0.22);\n  color: #aebcff;\n  font-size: 10px;\n  line-height: 1.6;\n  white-space: nowrap;\n}\n\n.pr-record-top .pr-kind-badge,\n.pr-detail-top .pr-kind-badge {\n  margin-left: 0;\n}\n\n.pr-item-facts {\n  display: flex;\n  flex-direction: column;\n  gap: 6px;\n  margin: 10px 0 2px;\n  padding: 10px 12px;\n  border-radius: 12px;\n  background: rgba(255, 255, 255, 0.035);\n  border: 1px solid rgba(255, 255, 255, 0.08);\n}\n\n.pr-item-facts div {\n  display: flex;\n  gap: 12px;\n  align-items: flex-start;\n  font-size: 12px;\n  line-height: 1.5;\n}\n\n.pr-item-facts dt {\n  color: var(--pr-muted);\n  flex: none;\n  min-width: 42px;\n}\n\n.pr-item-facts dd {\n  margin: 0;\n  color: #d4dcea;\n  overflow-wrap: anywhere;\n}\n\n.pr-a11y-banner {\n  display: flex;\n  align-items: center;\n  justify-content: space-between;\n  gap: 10px;\n  margin: 0;\n  font-size: 12px;\n}\n\n.pr-a11y-banner .pr-link {\n  flex: none;\n  min-height: 36px;\n  color: #f0d79a;\n}\n\n.pr-waiting {\n  display: flex;\n  align-items: center;\n  gap: 13px;\n  padding: 14px 16px;\n  border-color: rgba(77, 107, 254, 0.24);\n  background:\n    radial-gradient(120% 100% at 100% 0%, rgba(77, 107, 254, 0.14), transparent 66%),\n    rgba(19, 28, 46, 0.82);\n}\n\n.pr-waiting > div {\n  flex: 1;\n  min-width: 0;\n}\n\n.pr-waiting strong {\n  display: block;\n  font-size: 14px;\n  line-height: 1.4;\n}\n\n.pr-waiting p {\n  margin: 3px 0 0;\n  font-size: 11.5px;\n  line-height: 1.5;\n  color: var(--pr-muted);\n}\n\n.pr-detail-actions {\n  display: flex;\n  align-items: center;\n  flex-wrap: wrap;\n  gap: 10px;\n  margin: 2px 0 10px;\n}\n\n.pr-detail-actions .pr-link {\n  min-height: 40px;\n  padding: 0 10px;\n  border: 1px solid rgba(255, 255, 255, 0.12);\n  border-radius: 10px;\n  background: rgba(255, 255, 255, 0.04);\n}\n\n.pr-version {\n  margin: 2px 0 4px;\n  text-align: center;\n  font-size: 10.5px;\n  letter-spacing: 0.04em;\n  color: var(--pr-muted);\n  opacity: 0.7;\n}\n\n.pr-head-actions {\n  display: inline-flex;\n  align-items: center;\n  gap: 12px;\n}\n\n.pr-records-top {\n  display: flex;\n  align-items: center;\n  justify-content: space-between;\n  gap: 12px;\n  padding: 0 2px;\n}\n\n.pr-records-top .pr-link {\n  min-height: 40px;\n  padding: 0 8px;\n}\n\n.pr-channel-list {\n  display: flex;\n  flex-direction: column;\n  gap: 10px;\n  min-width: 0;\n}\n\n.pr-channel-card {\n  padding: 14px;\n  border-radius: 16px;\n  min-width: 0;\n}\n\n.pr-channel-card[data-lowest='true'] {\n  border-color: rgba(104, 195, 158, 0.4);\n  box-shadow:\n    inset 0 1px 0 rgba(255, 255, 255, 0.07),\n    0 12px 28px -22px rgba(104, 195, 158, 0.8);\n}\n\n.pr-channel-head {\n  display: flex;\n  align-items: flex-start;\n  justify-content: space-between;\n  gap: 12px;\n  min-width: 0;\n}\n\n.pr-channel-store {\n  display: flex;\n  align-items: flex-start;\n  gap: 9px;\n  min-width: 0;\n  flex: 1;\n}\n\n.pr-channel-store > span {\n  min-width: 0;\n}\n\n.pr-channel-store strong {\n  display: block;\n  font-size: 13px;\n  line-height: 1.45;\n  font-weight: 600;\n  overflow-wrap: anywhere;\n}\n\n.pr-channel-store small {\n  display: block;\n  margin-top: 2px;\n  font-size: 10.5px;\n  line-height: 1.45;\n  color: var(--pr-muted);\n}\n\n.pr-channel-price {\n  flex: none;\n  text-align: right;\n  max-width: 45%;\n}\n\n.pr-channel-price strong {\n  display: block;\n  font-size: 18px;\n  line-height: 1.25;\n  color: #8fe0c2;\n  font-variant-numeric: tabular-nums;\n  overflow-wrap: anywhere;\n}\n\n.pr-channel-price strong.muted {\n  color: var(--pr-muted);\n}\n\n.pr-channel-price small {\n  display: block;\n  margin-top: 2px;\n  font-size: 10px;\n  line-height: 1.4;\n  color: var(--pr-muted);\n}\n\n.pr-channel-tags {\n  display: flex;\n  align-items: center;\n  flex-wrap: wrap;\n  gap: 6px;\n  margin-top: 8px;\n}\n\n.pr-best-tag {\n  display: inline-flex;\n  align-items: center;\n  padding: 2px 7px;\n  border-radius: 6px;\n  border: 1px solid rgba(104, 195, 158, 0.28);\n  background: rgba(104, 195, 158, 0.12);\n  color: #a8e2cb;\n  font-size: 10px;\n  line-height: 1.6;\n}\n\n.pr-channel-condition {\n  margin: 7px 0 0;\n  font-size: 12px;\n  line-height: 1.55;\n  color: #d0d9e8;\n  overflow-wrap: anywhere;\n}\n\n.pr-channel-detail {\n  display: flex;\n  flex-direction: column;\n  gap: 3px;\n  margin-top: 6px;\n}\n\n.pr-channel-detail small {\n  font-size: 11px;\n  line-height: 1.5;\n  color: var(--pr-muted);\n  overflow-wrap: anywhere;\n}\n\n.pr-quick {\n  padding: 16px;\n  border-radius: 20px;\n}\n\n.pr-quick-meta {\n  display: flex;\n  align-items: center;\n  flex-wrap: wrap;\n  gap: 8px;\n  margin: 10px 0 12px;\n}\n\n.pr-quick-meta .pr-tag {\n  display: inline-flex;\n  align-items: center;\n  gap: 4px;\n}\n\n.pr-quick .pr-btn-row {\n  margin-top: 4px;\n}\n";

// src/components.jsx
var import_react = __toESM(require("react"));

// src/util.js
function str(value) {
  if (typeof value === "string") return value.trim();
  if (typeof value === "number" && Number.isFinite(value)) return String(value);
  return "";
}
function msg(error) {
  if (!error) return "\u672A\u77E5\u9519\u8BEF";
  const text = str(error.message) || str(error.error) || str(error.code) || String(error);
  return text || "\u672A\u77E5\u9519\u8BEF";
}
function isObj(value) {
  return !!value && typeof value === "object" && !Array.isArray(value);
}
function clampText(value, max) {
  const text = typeof value === "string" ? value : value == null ? "" : JSON.stringify(value);
  if (!text) return "";
  return text.length > max ? text.slice(0, max) + "\u2026" : text;
}
function parseJsonLoose(text) {
  if (typeof text !== "string") return null;
  let body = text.trim();
  if (!body) return null;
  body = body.replace(/^```(?:json)?\s*/i, "").replace(/```\s*$/i, "").trim();
  const first = body.indexOf("{");
  const last = body.lastIndexOf("}");
  if (first < 0 || last <= first) return null;
  body = body.slice(first, last + 1);
  try {
    return JSON.parse(body);
  } catch (error) {
    try {
      return JSON.parse(body.replace(/,\s*([}\]])/g, "$1"));
    } catch (error2) {
      return null;
    }
  }
}
var idSeed = 0;
function uid(prefix) {
  idSeed += 1;
  return (prefix || "x") + Date.now().toString(36) + idSeed.toString(36) + Math.random().toString(36).slice(2, 5);
}
function numberOrNull(value) {
  if (typeof value === "number" && Number.isFinite(value)) return Math.round(value * 100) / 100;
  if (typeof value === "string" && value.trim()) {
    const match = value.replace(/,/g, "").match(/-?\d+(?:\.\d+)?/);
    const num = match ? Number(match[0]) : NaN;
    if (Number.isFinite(num)) return Math.round(num * 100) / 100;
  }
  return null;
}
function httpUrl(value) {
  const url = str(value);
  return /^https?:\/\//i.test(url) ? url : "";
}
function formatPrice(value) {
  if (value == null || !Number.isFinite(value)) return null;
  return "\xA5" + value.toFixed(2);
}
function formatShipping(value) {
  if (value === 0) return "\u5305\u90AE";
  if (value == null) return "\u8FD0\u8D39\u5F85\u6838\u9A8C";
  return "\u8FD0\u8D39 \xA5" + value.toFixed(2);
}
function pad2(value) {
  return value < 10 ? "0" + value : String(value);
}
function formatTime(ms) {
  if (!ms) return "";
  const d = new Date(ms);
  if (Number.isNaN(d.getTime())) return "";
  return pad2(d.getMonth() + 1) + "-" + pad2(d.getDate()) + " " + pad2(d.getHours()) + ":" + pad2(d.getMinutes());
}
function formatDateTime(ms) {
  if (!ms) return "";
  const d = new Date(ms);
  if (Number.isNaN(d.getTime())) return "";
  return d.getFullYear() + "-" + pad2(d.getMonth() + 1) + "-" + pad2(d.getDate()) + " " + pad2(d.getHours()) + ":" + pad2(d.getMinutes());
}
function parseTime(value) {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  const text = str(value);
  if (!text) return 0;
  const ms = Date.parse(text);
  return Number.isFinite(ms) ? ms : 0;
}
function agoLabel(ms, now) {
  if (!ms) return "";
  const diff = Math.max(0, (now || Date.now()) - ms);
  const minutes = Math.floor(diff / 6e4);
  if (minutes < 1) return "\u521A\u521A";
  if (minutes < 60) return minutes + " \u5206\u949F\u524D";
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return hours + " \u5C0F\u65F6\u524D";
  const days = Math.floor(hours / 24);
  if (days < 7) return days + " \u5929\u524D";
  return formatTime(ms);
}
function elapsedLabel(ms) {
  const total = Math.max(0, Math.floor(ms / 1e3));
  const minutes = Math.floor(total / 60);
  const seconds = total % 60;
  return minutes ? minutes + " \u5206 " + pad2(seconds) + " \u79D2" : seconds + " \u79D2";
}
function lowestChannel(channels) {
  let best = null;
  (channels || []).forEach(function(channel) {
    if (!channel || channel.price == null) return;
    if (!best || channel.price < best.price) best = channel;
  });
  return best;
}
function toBase64(text) {
  try {
    const bytes = new TextEncoder().encode(text);
    let binary = "";
    for (let i = 0; i < bytes.length; i += 1) binary += String.fromCharCode(bytes[i]);
    return btoa(binary);
  } catch (error) {
    return "";
  }
}
function todayLabel() {
  const d = /* @__PURE__ */ new Date();
  return d.getFullYear() + "-" + pad2(d.getMonth() + 1) + "-" + pad2(d.getDate());
}

// src/data.js
var TITLE = "\u6BD4\u4EF7\u96F7\u8FBE";
var PANEL_ID = "local-hnysqukwki-11kyqfw";
var VERSION = "1.25.0";
var PLATFORMS = [
  {
    id: "taobao",
    name: "\u6DD8\u5B9D",
    short: "\u6DD8",
    color: "#ff7a45",
    app: "com.taobao.taobao",
    channels: ["\u5B98\u65B9\u65D7\u8230\u5E97", "\u5929\u732B\u56FD\u9645", "\u767E\u4EBF\u8865\u8D34", "\u54C1\u724C\u8D85\u503C\u8D2D"],
    coupon: "\u5546\u54C1\u9875\u770B\u4E0D\u5230\u5238\u72B6\u6001\u65F6\uFF0C\u624D\u53BB\u300C\u6211\u7684\u6DD8\u5B9D\u300D\u2192 \u4F18\u60E0\u5238 / \u9886\u5238\u4E2D\u5FC3\u786E\u8BA4\u4E00\u6B21",
    pkg: "\u6DD8\u5B9D / \u5929\u732B"
  },
  {
    id: "pdd",
    name: "\u62FC\u591A\u591A",
    short: "\u62FC",
    color: "#ef4f4f",
    app: "com.xunmeng.pinduoduo",
    channels: ["\u767E\u4EBF\u8865\u8D34", "\u5B98\u65B9\u65D7\u8230\u5E97", "\u54C1\u724C\u9ED1\u6807"],
    coupon: "\u9700\u8981\u65F6\u4ECE\u767E\u4EBF\u8865\u8D34\u9891\u9053\u5DE6\u4E0A\u89D2\u4F1A\u5458\u5165\u53E3\u9886\u4E00\u6B21\u767E\u8865\u5238\uFF0C\u9886\u5B8C\u56DE\u5546\u54C1\u9875",
    pkg: "\u62FC\u591A\u591A"
  },
  {
    id: "douyin",
    name: "\u6296\u97F3\u5546\u57CE",
    short: "\u6296",
    color: "#5f7cff",
    app: "com.ss.android.ugc.aweme",
    channels: ["\u54C1\u724C\u9ED1\u6807", "\u5B98\u65B9\u65D7\u8230\u5E97", "\u8D85\u503C\u8D2D"],
    coupon: "\u5546\u54C1\u9875\u6CA1\u5238\u4FE1\u606F\u65F6\uFF0C\u624D\u53BB\u5546\u57CE\u9996\u9875\u9886\u5238\u9875\u9886\u4E00\u6B21",
    pkg: "\u6296\u97F3"
  },
  {
    id: "jd",
    name: "\u4EAC\u4E1C",
    short: "\u4EAC",
    color: "#e4393c",
    app: "com.jingdong.app.mall",
    channels: ["\u4EAC\u4E1C\u81EA\u8425", "\u5B98\u65B9\u65D7\u8230\u5E97", "\u767E\u4EBF\u8865\u8D34", "\u4EAC\u4E1C\u56FD\u9645"],
    coupon: "\u53EA\u5728\u5546\u54C1\u9875\u9886\u5238\u533A\u9886\u4E00\u6B21\u5238\uFF0C\u4E0D\u8DF3\u8F6C\u5176\u4ED6\u4F1A\u573A",
    pkg: "\u4EAC\u4E1C"
  }
];
var TRAVEL_PLATFORMS = [
  {
    id: "ctrip",
    name: "\u643A\u7A0B",
    short: "\u643A",
    color: "#2f7dff",
    app: "ctrip.android.view",
    channels: ["\u9152\u5E97\u5B98\u65B9", "\u643A\u7A0B\u81EA\u8425", "\u822A\u53F8\u5B98\u65B9", "\u5B98\u65B9\u65D7\u8230"],
    coupon: "\u9996\u5C4F\u4F1A\u5458\u4EF7/\u5238\u4F18\u5148\uFF1B\u770B\u4E0D\u5230\u5C31\u6309\u9875\u9762\u4EF7\u8BB0\u5F55\uFF0C\u4E0D\u6DF1\u6316",
    pkg: "\u643A\u7A0B\u65C5\u884C",
    travel: true
  },
  {
    id: "meituan",
    name: "\u7F8E\u56E2",
    short: "\u7F8E",
    color: "#ffc233",
    app: "com.sankuai.meituan",
    channels: ["\u9152\u5E97\u5B98\u65B9", "\u7F8E\u56E2\u81EA\u8425", "\u54C1\u724C\u65D7\u8230"],
    coupon: "\u9996\u5C4F\u4F1A\u5458\u4EF7/\u5238\u4F18\u5148\uFF1B\u770B\u4E0D\u5230\u5C31\u6309\u9875\u9762\u4EF7\u8BB0\u5F55\uFF0C\u4E0D\u6DF1\u6316",
    pkg: "\u7F8E\u56E2",
    travel: true
  },
  {
    id: "qunar",
    name: "\u53BB\u54EA\u513F",
    short: "\u53BB",
    color: "#00b8d9",
    app: "com.Qunar",
    channels: ["\u822A\u53F8\u5B98\u65B9", "\u53BB\u54EA\u513F\u81EA\u8425", "\u9152\u5E97\u5B98\u65B9"],
    coupon: "\u9996\u5C4F\u4F1A\u5458\u4EF7/\u5238\u4F18\u5148\uFF1B\u770B\u4E0D\u5230\u5C31\u6309\u9875\u9762\u4EF7\u8BB0\u5F55\uFF0C\u4E0D\u6DF1\u6316",
    pkg: "\u53BB\u54EA\u513F\u65C5\u884C",
    travel: true
  }
];
var ALL_PLATFORMS = PLATFORMS.concat(TRAVEL_PLATFORMS);
var TRAVEL_PLATFORM_IDS = TRAVEL_PLATFORMS.map(function(p) {
  return p.id;
});
var PLATFORM_MAP = {};
ALL_PLATFORMS.forEach(function(item) {
  PLATFORM_MAP[item.id] = item;
});
var PLATFORM_ALIASES = {
  "\u6DD8\u5B9D": "taobao",
  "\u5929\u732B": "taobao",
  "\u6DD8\u5B9D/\u5929\u732B": "taobao",
  "\u62FC\u591A\u591A": "pdd",
  "\u6296\u97F3": "douyin",
  "\u6296\u97F3\u5546\u57CE": "douyin",
  "\u4EAC\u4E1C": "jd",
  "\u643A\u7A0B": "ctrip",
  "\u643A\u7A0B\u65C5\u884C": "ctrip",
  "\u7F8E\u56E2": "meituan",
  "\u53BB\u54EA\u513F": "qunar",
  "\u53BB\u54EA\u513F\u65C5\u884C": "qunar"
};
function platformId(value) {
  const raw = str(value);
  if (PLATFORM_MAP[raw]) return raw;
  if (PLATFORM_ALIASES[raw]) return PLATFORM_ALIASES[raw];
  if (raw.indexOf("\u6DD8\u5B9D") >= 0 || raw.indexOf("\u5929\u732B") >= 0) return "taobao";
  if (raw.indexOf("\u62FC\u591A\u591A") >= 0) return "pdd";
  if (raw.indexOf("\u6296\u97F3") >= 0) return "douyin";
  if (raw.indexOf("\u4EAC\u4E1C") >= 0) return "jd";
  if (raw.indexOf("\u643A\u7A0B") >= 0) return "ctrip";
  if (raw.indexOf("\u7F8E\u56E2") >= 0) return "meituan";
  if (raw.indexOf("\u53BB\u54EA\u513F") >= 0) return "qunar";
  return "";
}
var DEFAULT_STEPS = {
  taobao: [
    "\u5982\u679C\u5DF2\u7ECF\u5728\u6DD8\u5B9D\u5546\u54C1\u9875\u53D1\u8D77\u6BD4\u4EF7\uFF0C\u5C31\u7528\u5F53\u524D\u8FD9\u4E00\u9875\uFF0C\u4E0D\u91CD\u65B0\u641C\u7D22\u6DD8\u5B9D\u3002",
    "\u9700\u8981\u641C\u7D22\u65F6\u518D\u641C\u540C\u6B3E\uFF0C\u8BA4\u51C6\u5B98\u65B9\u65D7\u8230\u5E97 / \u5929\u732B\u56FD\u9645 / \u767E\u4EBF\u8865\u8D34 / \u54C1\u724C\u8D85\u503C\u8D2D\uFF0C\u8FDB\u5546\u54C1\u9875\u6838\u5BF9\u89C4\u683C\u3002",
    "\u5148\u8BB0\u5F55\u9875\u9762\u663E\u793A\u7684\u5230\u624B\u4EF7\u548C\u5238\u4FE1\u606F\uFF1B\u5546\u54C1\u9875\u770B\u4E0D\u5230\u5238\u72B6\u6001\u65F6\uFF0C\u624D\u53BB\u300C\u6211\u7684\u6DD8\u5B9D\u300D\u2192 \u4F18\u60E0\u5238 / \u9886\u5238\u4E2D\u5FC3\u786E\u8BA4\u4E00\u6B21\u3002",
    "\u786E\u8BA4\u5B8C\u76F4\u63A5\u79BB\u5F00\u6DD8\u5B9D\uFF0C\u4E0D\u56DE\u5230\u641C\u7D22\u9875\uFF0C\u4E0D\u53CD\u590D\u8FDB\u51FA\uFF1B\u6EE1\u51CF\u6309\u521A\u597D\u51D1\u5230\u95E8\u69DB\u4F30\u7B97\u5E76\u5199\u8FDB\u5047\u8BBE\u3002",
    "\u4E0D\u70B9\u5206\u4EAB\u3001\u4E0D\u590D\u5236\u94FE\u63A5\u3001\u4E0D\u52A0\u8D2D\u7269\u8F66\u3001\u4E0D\u4E0B\u5355\uFF1B\u94FE\u63A5\u53EA\u5728\u9875\u9762\u76F4\u63A5\u53EF\u89C1\u65F6\u987A\u4FBF\u8BB0\u5F55\u3002"
  ],
  pdd: [
    "\u5982\u679C\u5DF2\u7ECF\u5728\u62FC\u591A\u591A\u5546\u54C1\u9875\u53D1\u8D77\u6BD4\u4EF7\uFF0C\u5C31\u7528\u5F53\u524D\u8FD9\u4E00\u9875\uFF0C\u4E0D\u91CD\u65B0\u641C\u7D22\u62FC\u591A\u591A\u3002",
    "\u9700\u8981\u9886\u767E\u8865\u5238\u65F6\uFF0C\u4ECE\u767E\u4EBF\u8865\u8D34\u9891\u9053\u5DE6\u4E0A\u89D2\u4F1A\u5458\u5165\u53E3\u8FDB\u4E00\u6B21\uFF0C\u9886\u5B8C\u56DE\u5230\u5F53\u524D\u5546\u54C1\u9875\u770B\u5238\u540E\u4EF7\u3002",
    "\u8BA4\u51C6\u767E\u4EBF\u8865\u8D34 / \u5B98\u65B9\u65D7\u8230\u5E97 / \u54C1\u724C\u9ED1\u6807\uFF0C\u5546\u54C1\u9875\u9009\u540C\u89C4\u683C\uFF0C\u8BB0\u5F55\u5238\u540E\u5230\u624B\u4EF7\u3001\u95E8\u69DB\u548C\u8FD0\u8D39\u3002",
    "\u51D1\u6EE1\u51CF\u6309\u521A\u597D\u8FBE\u6807\u4F30\u7B97\uFF0C\u5176\u4ED6\u51D1\u5355\u54C1\u4E4B\u540E\u53EF\u53D6\u6D88\uFF1B\u4E0D\u771F\u7684\u4E0B\u5355\u3002",
    "\u4E0D\u70B9\u5206\u4EAB\u3001\u4E0D\u590D\u5236\u94FE\u63A5\u3001\u4E0D\u52A0\u8D2D\uFF1B\u94FE\u63A5\u53EA\u5728\u9875\u9762\u76F4\u63A5\u53EF\u89C1\u65F6\u8BB0\u5F55\u3002"
  ],
  douyin: [
    "\u5982\u679C\u5DF2\u7ECF\u5728\u6296\u97F3\u5546\u54C1\u9875\u53D1\u8D77\u6BD4\u4EF7\uFF0C\u5C31\u7528\u5F53\u524D\u8FD9\u4E00\u9875\uFF0C\u4E0D\u91CD\u65B0\u641C\u7D22\u6296\u97F3\u3002",
    "\u5546\u54C1\u9875\u6CA1\u6709\u5238\u4FE1\u606F\u65F6\uFF0C\u624D\u53BB\u5546\u57CE\u9996\u9875\u9886\u5238\u9875\u9886\u4E00\u6B21\uFF0C\u518D\u56DE\u5F53\u524D\u5546\u54C1\u9875\u770B\u5238\u540E\u4EF7\uFF1B\u6574\u4E2A\u6296\u97F3\u53EA\u8BBF\u95EE\u4E00\u6B21\u3002",
    "\u8BA4\u51C6\u54C1\u724C\u9ED1\u6807 / \u5B98\u65B9\u65D7\u8230\u5E97 / \u8D85\u503C\u8D2D\uFF0C\u9009\u540C\u89C4\u683C\uFF0C\u8BB0\u5F55\u5238\u540E\u4EF7\u3001\u6EE1\u51CF\u95E8\u69DB\u548C\u8FD0\u8D39\u3002",
    "\u4E0D\u70B9\u5206\u4EAB\u3001\u4E0D\u590D\u5236\u94FE\u63A5\u3001\u4E0D\u52A0\u8D2D\uFF1B\u94FE\u63A5\u53EA\u5728\u9875\u9762\u76F4\u63A5\u53EF\u89C1\u65F6\u8BB0\u5F55\u3002"
  ],
  jd: [
    "\u5982\u679C\u5DF2\u7ECF\u5728\u4EAC\u4E1C\u5546\u54C1\u9875\u53D1\u8D77\u6BD4\u4EF7\uFF0C\u5C31\u7528\u5F53\u524D\u8FD9\u4E00\u9875\uFF0C\u4E0D\u91CD\u65B0\u641C\u7D22\u4EAC\u4E1C\u3002",
    "\u9700\u8981\u641C\u7D22\u65F6\u8BA4\u51C6\u4EAC\u4E1C\u81EA\u8425 / \u5B98\u65B9\u65D7\u8230\u5E97 / \u767E\u4EBF\u8865\u8D34 / \u4EAC\u4E1C\u56FD\u9645\uFF0C\u6838\u5BF9\u662F\u5426\u81EA\u8425\u53D1\u8D27\u548C\u89C4\u683C\u3002",
    "\u53EA\u5728\u5546\u54C1\u9875\u9886\u5238\u533A\u9886\u4E00\u6B21\u5238\uFF0C\u4E0D\u8DF3\u8F6C\u5176\u4ED6\u4F1A\u573A\uFF1B\u8BB0\u5F55\u5230\u624B\u4EF7\u3001\u5238\u6761\u4EF6\u3001Plus \u4EF7\uFF08\u82E5\u663E\u793A\uFF09\u548C\u8FD0\u8D39\u3002",
    "\u4E0D\u70B9\u5206\u4EAB\u3001\u4E0D\u590D\u5236\u94FE\u63A5\u3001\u4E0D\u63D0\u4EA4\u8BA2\u5355\uFF1B\u94FE\u63A5\u53EA\u5728\u9875\u9762\u76F4\u63A5\u53EF\u89C1\u65F6\u8BB0\u5F55\u3002"
  ],
  ctrip: [
    "\u5982\u679C\u5DF2\u7ECF\u5728\u643A\u7A0B\u9152\u5E97/\u673A\u7968\u9875\u53D1\u8D77\uFF0C\u5C31\u7528\u5F53\u524D\u9875\uFF0C\u4E0D\u91CD\u65B0\u641C\u7D22\u643A\u7A0B\u3002",
    "\u5148\u770B\u9876\u90E8\u65E5\u671F\u680F\uFF1A\u5DF2\u662F\u540C\u5165\u4F4F/\u79BB\u5E97\uFF08\u5C24\u5176\u4ECA\u5929\u2192\u660E\u5929\uFF09\u65F6\uFF0C\u7EDD\u4E0D\u6253\u65E5\u671F\u9009\u62E9\u5668\uFF1B\u65E5\u671F\u4E0D\u5BF9\u624D\u6539\uFF0C\u53EA\u8BD5 1 \u6B21\uFF0C\u6253\u5F00\u5230\u9519\u8BEF\u6708\u4EFD\u5C31\u5173\u95ED\uFF0C\u4E0D\u6EDA\u6708\u4EFD\u3002",
    "\u641C\u7D22\u6846\u76F4\u63A5\u8F93\u5B8C\u6574\u9152\u5E97\u540D\uFF1B\u641C\u4E0D\u5230\u624D\u6539\u57CE\u5E02\u3002\u9152\u5E97\u8BE6\u60C5\u70B9\u300C\u67E5\u770B\u623F\u578B\u300D\uFF0C\u8BB0\u623F\u578B\u5217\u8868\u7B2C\u4E00\u884C\u7684\u6700\u4F4E\u4EF7/\u65E9\u9910/\u53D6\u6D88\uFF1B\u5217\u8868\u5361\u7247\u201C\xA5\u8D77\u201D\u53EA\u4F5C\u7EBF\u7D22\uFF0C\u6700\u7EC8\u4EE5\u623F\u578B\u9996\u884C\u786E\u8BA4\u3002",
    "\u9152\u5E97\u9ED8\u8BA4\u6BD4\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\uFF0C\u7528\u6237\u660E\u786E\u6253\u5F00\u67D0\u4E2A\u623F\u578B\u65F6\u624D\u6309\u6307\u5B9A\u623F\u578B\uFF1B\u65E9\u9910/\u53D6\u6D88/\u623F\u578B\u5DEE\u5F02\u5199 close/different + matchNote\u3002",
    "\u53EA\u8BFB\u9996\u5C4F\uFF0C\u4E0D\u8FDB\u5177\u4F53\u623F\u578B\u8BE6\u60C5\u3001\u7B5B\u9009\u3001\u8BC4\u4EF7\u3001\u5238\u4E2D\u5FC3\uFF1B\u6BCF\u5E73\u53F0\u8F6F\u9884\u7B97 6 \u6B21\u64CD\u4F5C\uFF0C\u8D85\u8FC7\u8BB0 missing \u8F6C\u4E0B\u4E00\u4E2A\u3002\u4E0D\u63D0\u4EA4\u8BA2\u5355\u3001\u4E0D\u652F\u4ED8\u3002"
  ],
  meituan: [
    "\u5982\u679C\u5DF2\u7ECF\u5728\u7F8E\u56E2\u9152\u5E97/\u673A\u7968\u9875\u53D1\u8D77\uFF0C\u5C31\u7528\u5F53\u524D\u9875\uFF0C\u4E0D\u91CD\u65B0\u641C\u7D22\u7F8E\u56E2\u3002",
    "\u4ECE\u9996\u9875\u300C\u9152\u5E97/\u6C11\u5BBF\u300D\u8FDB\u5165\uFF1B\u5148\u770B\u65E5\u671F\u680F\uFF0C\u5DF2\u662F\u540C\u65E5\u671F\u7EDD\u4E0D\u6253\u5F00\u65E5\u671F\u9009\u62E9\u5668\uFF1B\u65E5\u671F\u4E0D\u5BF9\u624D\u6539\uFF0C\u53EA\u8BD5 1 \u6B21\u3002",
    "\u641C\u7D22\u6846\u76F4\u63A5\u8F93\u5B8C\u6574\u9152\u5E97\u540D\uFF1B\u9152\u5E97\u9875\u9996\u5C4F\u6216 1 \u6B21\u6EDA\u52A8\u627E\u6700\u4F4E\u65E5\u5386\u623F\u4EF7\uFF1B\u9996\u5C4F\u6CA1\u4EF7\u624D\u8FDB\u623F\u578B\u5217\u8868\u7B2C\u4E00\u884C\u3002",
    "\u9152\u5E97\u9ED8\u8BA4\u6BD4\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\uFF0C\u7528\u6237\u660E\u786E\u6253\u5F00\u67D0\u4E2A\u623F\u578B\u65F6\u624D\u6309\u6307\u5B9A\u623F\u578B\uFF1B\u65E9\u9910/\u53D6\u6D88/\u623F\u578B\u5DEE\u5F02\u5199 close/different + matchNote\u3002",
    "\u53EA\u8BFB\u9996\u5C4F\uFF0C\u4E0D\u8FDB\u5177\u4F53\u623F\u578B\u8BE6\u60C5\u3001\u7B5B\u9009\u3001\u8BC4\u4EF7\u3001\u5238\u4E2D\u5FC3\uFF1B\u6BCF\u5E73\u53F0\u8F6F\u9884\u7B97 6 \u6B21\u64CD\u4F5C\uFF0C\u8D85\u8FC7\u8BB0 missing\u3002\u4E0D\u63D0\u4EA4\u8BA2\u5355\u3001\u4E0D\u652F\u4ED8\u3002"
  ],
  qunar: [
    "\u5982\u679C\u5DF2\u7ECF\u5728\u53BB\u54EA\u513F\u9152\u5E97/\u673A\u7968\u9875\u53D1\u8D77\uFF0C\u5C31\u7528\u5F53\u524D\u9875\uFF0C\u4E0D\u91CD\u65B0\u641C\u7D22\u53BB\u54EA\u513F\u3002",
    "\u9996\u9875\u300C\u9152\u5E97\u300D\uFF1B\u5148\u770B\u57CE\u5E02/\u65E5\u671F\u680F\uFF0C\u5DF2\u5BF9\u7EDD\u4E0D\u6539\uFF1B\u57CE\u5E02\u4E0D\u5BF9\u624D\u6539\u4E00\u6B21\uFF0C\u65E5\u671F\u4E0D\u5BF9\u53EA\u8BD5 1 \u6B21\uFF0C\u9519\u6708\u4EFD\u5173\u95ED\u4E0D\u6EDA\u3002",
    "\u641C\u7D22\u6846\u76F4\u63A5\u8F93\u5B8C\u6574\u9152\u5E97\u540D\uFF1B\u9152\u5E97\u8BE6\u60C5\u9996\u5C4F\u623F\u578B\u5217\u8868\u7B2C\u4E00\u884C\u5C31\u662F\u6700\u4F4E\u4EF7\uFF0C\u8BB0\u65E9\u9910/\u53D6\u6D88\uFF1B\u5217\u8868\u201C\xA5\u8D77\u201D\u53EA\u4F5C\u7EBF\u7D22\uFF0C\u6700\u7EC8\u4EE5\u8BE6\u60C5\u9996\u884C\u4E3A\u51C6\u3002",
    "\u9152\u5E97\u9ED8\u8BA4\u6BD4\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\uFF0C\u7528\u6237\u660E\u786E\u6253\u5F00\u67D0\u4E2A\u623F\u578B\u65F6\u624D\u6309\u6307\u5B9A\u623F\u578B\uFF1B\u65E9\u9910/\u53D6\u6D88/\u623F\u578B\u5DEE\u5F02\u5199 close/different + matchNote\u3002",
    "\u53EA\u8BFB\u9996\u5C4F\uFF0C\u4E0D\u8FDB\u5177\u4F53\u623F\u578B\u8BE6\u60C5\u3001\u7B5B\u9009\u3001\u8BC4\u4EF7\u3001\u5238\u4E2D\u5FC3\uFF1B\u6BCF\u5E73\u53F0\u8F6F\u9884\u7B97 6 \u6B21\u64CD\u4F5C\uFF0C\u8D85\u8FC7\u8BB0 missing\u3002\u4E0D\u63D0\u4EA4\u8BA2\u5355\u3001\u4E0D\u652F\u4ED8\u3002"
  ]
};
var KINDS = ["product", "hotel", "flight"];
var DEFAULT_MEMORY = {
  version: 5,
  updatedAt: 0,
  platforms: {
    taobao: { steps: DEFAULT_STEPS.taobao.slice(), coupon: PLATFORMS[0].coupon, notes: "" },
    pdd: { steps: DEFAULT_STEPS.pdd.slice(), coupon: PLATFORMS[1].coupon, notes: "" },
    douyin: { steps: DEFAULT_STEPS.douyin.slice(), coupon: PLATFORMS[2].coupon, notes: "" },
    jd: { steps: DEFAULT_STEPS.jd.slice(), coupon: PLATFORMS[3].coupon, notes: "" },
    ctrip: { steps: DEFAULT_STEPS.ctrip.slice(), coupon: TRAVEL_PLATFORMS[0].coupon, notes: "" },
    meituan: { steps: DEFAULT_STEPS.meituan.slice(), coupon: TRAVEL_PLATFORMS[1].coupon, notes: "" },
    qunar: { steps: DEFAULT_STEPS.qunar.slice(), coupon: TRAVEL_PLATFORMS[2].coupon, notes: "" }
  }
};
var DEFAULT_SETTINGS = {
  version: 4,
  floating: true,
  autoCoupon: true,
  skipSource: true,
  platforms: ["taobao", "pdd", "douyin", "jd"],
  travelPlatforms: TRAVEL_PLATFORM_IDS.slice(),
  reminderLead: 30
};
function defaultMemory() {
  return clone(DEFAULT_MEMORY);
}
function defaultSettings() {
  return clone(DEFAULT_SETTINGS);
}
function clone(value) {
  return JSON.parse(JSON.stringify(value));
}
function platformLabel(id) {
  return PLATFORM_MAP[id] ? PLATFORM_MAP[id].name : "\u5176\u4ED6\u6E20\u9053";
}
function platformColor(id) {
  return PLATFORM_MAP[id] ? PLATFORM_MAP[id].color : "#8fa0bf";
}
function normalizeSettings(raw) {
  const base = defaultSettings();
  if (!isObj(raw)) return base;
  const platforms = Array.isArray(raw.platforms) ? raw.platforms.filter(function(id) {
    return PLATFORMS.some(function(platform) {
      return platform.id === id;
    });
  }) : base.platforms;
  const travelSource = Array.isArray(raw.travelPlatforms) ? raw.travelPlatforms : base.travelPlatforms;
  const travelPlatforms = travelSource.filter(function(id) {
    return TRAVEL_PLATFORM_IDS.indexOf(id) >= 0;
  });
  return {
    version: 4,
    floating: raw.floating !== false,
    autoCoupon: raw.autoCoupon !== false,
    skipSource: raw.skipSource !== false,
    platforms: platforms.length ? uniq(platforms) : base.platforms,
    travelPlatforms: travelPlatforms.length ? uniq(travelPlatforms) : base.travelPlatforms,
    reminderLead: Number.isFinite(Number(raw.reminderLead)) ? Math.max(5, Math.min(1440, Number(raw.reminderLead))) : 30
  };
}
function normalizeMemory(raw) {
  const base = defaultMemory();
  if (!isObj(raw)) return base;
  const source = isObj(raw.platforms) ? raw.platforms : {};
  const version = Number(raw.version);
  const legacy = !Number.isFinite(version) || version < 3;
  const next = { version: 5, updatedAt: Number(raw.updatedAt) || 0, platforms: {} };
  ALL_PLATFORMS.forEach(function(platform) {
    const entry = isObj(source[platform.id]) ? source[platform.id] : {};
    const customSteps = Array.isArray(entry.steps) ? entry.steps.map(function(step) {
      return str(step).slice(0, 200);
    }).filter(Boolean).slice(0, 12) : [];
    let steps = legacy || !customSteps.length ? base.platforms[platform.id].steps.slice() : customSteps;
    const oldTravelDefault = TRAVEL_PLATFORM_IDS.indexOf(platform.id) >= 0 && !str(entry.notes) && !steps.some(function(step) {
      return step.indexOf("\u6700\u4F4E\u4EF7\u65E5\u5386\u623F") >= 0 || step.indexOf("\u65E5\u671F\u680F") >= 0 || step.indexOf("\u9152\u5E97/\u6C11\u5BBF") >= 0;
    });
    if (oldTravelDefault) steps = base.platforms[platform.id].steps.slice();
    next.platforms[platform.id] = {
      steps,
      coupon: legacy || !str(entry.coupon) ? base.platforms[platform.id].coupon : str(entry.coupon).slice(0, 200),
      notes: str(entry.notes).slice(0, 500)
    };
  });
  return next;
}
function normalizeChannel(raw) {
  if (!isObj(raw)) return null;
  const platform = platformId(raw.platform) || "other";
  const url = httpUrl(raw.url);
  const verifiedMs = parseTime(raw.verifiedAt);
  const label = str(raw.label).slice(0, 60);
  const store = str(raw.store).slice(0, 40) || "";
  const price = numberOrNull(raw.price);
  const condition = str(raw.condition).slice(0, 300);
  const note = str(raw.note).slice(0, 300);
  if (!store && !label && !url && price == null && !condition && !note) return null;
  const matchRaw = str(raw.match);
  const match = ["same", "close", "different", "unknown"].indexOf(matchRaw) >= 0 ? matchRaw : "";
  const specSeen = str(raw.specSeen || raw.variant).slice(0, 160);
  const matchNote = str(raw.matchNote || raw.difference).slice(0, 300);
  const details = {};
  const detailKeys = ["roomType", "bedType", "breakfast", "cancelPolicy", "guests", "flightNo", "airline", "date", "depTime", "arrTime", "from", "to", "cabin", "baggage", "taxes", "fees", "direct"];
  if (isObj(raw.details)) {
    Object.keys(raw.details).slice(0, 16).forEach(function(key) {
      const value = str(raw.details[key]);
      if (value) details[str(key).slice(0, 30)] = value.slice(0, 200);
    });
  }
  detailKeys.forEach(function(key) {
    const value = str(raw[key]);
    if (value) details[key] = value.slice(0, 200);
  });
  let priceUnit = str(raw.priceUnit);
  if (["night", "total", "ticket", "item"].indexOf(priceUnit) < 0) priceUnit = "";
  let linkKind = str(raw.linkKind);
  if (["product", "search", "current", "none"].indexOf(linkKind) < 0) {
    linkKind = url ? /search|s\.taobao|list\.|sou\./i.test(url) ? "search" : "product" : "none";
  }
  if (!url && (linkKind === "product" || linkKind === "search")) linkKind = "none";
  if (url && linkKind === "current") linkKind = "product";
  return {
    platform,
    store,
    label,
    price,
    shipping: numberOrNull(raw.shipping),
    coupons: Array.isArray(raw.coupons) ? raw.coupons.map(function(item) {
      return str(item).slice(0, 100);
    }).filter(Boolean).slice(0, 6) : str(raw.coupons) ? [str(raw.coupons).slice(0, 100)] : [],
    condition,
    url,
    linkKind,
    match,
    specSeen,
    matchNote,
    details,
    priceUnit,
    verifiedAt: verifiedMs ? new Date(verifiedMs).toISOString() : "",
    note
  };
}
function normalizeMissing2(raw) {
  if (!isObj(raw)) return null;
  const platform = platformId(raw.platform) || "other";
  const reason = str(raw.reason || raw.note).slice(0, 200);
  if (!reason) return null;
  return { platform, reason };
}
function normalizeChannels(raw) {
  const seen = {};
  const list = [];
  (Array.isArray(raw) ? raw : []).forEach(function(item) {
    const channel = normalizeChannel(item);
    if (!channel) return;
    const key = channel.platform + "|" + channel.store + "|" + channel.label;
    if (seen[key]) return;
    seen[key] = true;
    list.push(channel);
  });
  return list.slice(0, 16);
}
function normalizeItem(kind, raw) {
  const type = KINDS.indexOf(kind) >= 0 ? kind : "product";
  const data = isObj(raw) ? raw : {};
  if (type === "hotel") {
    const checkIn = str(data.checkIn).slice(0, 20);
    const checkOut = str(data.checkOut).slice(0, 20);
    let nights = Number(data.nights);
    if (!Number.isFinite(nights) && checkIn && checkOut) {
      const a = Date.parse(checkIn);
      const b = Date.parse(checkOut);
      if (Number.isFinite(a) && Number.isFinite(b) && b > a) nights = Math.round((b - a) / 864e5);
    }
    return {
      hotelName: str(data.hotelName || data.name || data.title).slice(0, 200),
      city: str(data.city).slice(0, 60),
      checkIn,
      checkOut,
      nights: Number.isFinite(nights) && nights > 0 ? Math.min(60, Math.round(nights)) : 0,
      rateMode: data.rateMode === "specific" ? "specific" : "lowest",
      roomType: str(data.roomType || data.spec).slice(0, 160),
      bedType: str(data.bedType).slice(0, 60),
      breakfast: str(data.breakfast).slice(0, 60),
      cancelPolicy: str(data.cancelPolicy).slice(0, 120),
      guests: str(data.guests).slice(0, 40),
      notes: str(data.notes || data.note).slice(0, 300)
    };
  }
  if (type === "flight") {
    return {
      airline: str(data.airline).slice(0, 60),
      flightNo: str(data.flightNo || data.flightNumber).slice(0, 30),
      date: str(data.date).slice(0, 20),
      from: str(data.from).slice(0, 60),
      to: str(data.to).slice(0, 60),
      depTime: str(data.depTime).slice(0, 20),
      arrTime: str(data.arrTime).slice(0, 20),
      cabin: str(data.cabin).slice(0, 40),
      direct: data.direct === true ? "true" : data.direct === false ? "false" : str(data.direct).slice(0, 10),
      baggage: str(data.baggage).slice(0, 120),
      passengers: str(data.passengers).slice(0, 40),
      notes: str(data.notes || data.note).slice(0, 300)
    };
  }
  return {
    title: str(data.title || data.name).slice(0, 200),
    spec: str(data.spec).slice(0, 160)
  };
}
function kindLabel(kind) {
  if (kind === "hotel") return "\u9152\u5E97";
  if (kind === "flight") return "\u673A\u7968";
  return "\u5546\u54C1";
}
function itemTitle(kind, item) {
  const data = isObj(item) ? item : {};
  if (kind === "hotel") return str(data.hotelName) || "\u672A\u547D\u540D\u9152\u5E97";
  if (kind === "flight") return [str(data.airline), str(data.flightNo)].filter(Boolean).join(" ") || "\u672A\u547D\u540D\u822A\u73ED";
  return str(data.title) || "\u672A\u547D\u540D\u5546\u54C1";
}
function itemSummary(kind, item) {
  const data = isObj(item) ? item : {};
  if (kind === "hotel") {
    return [
      str(data.city),
      data.checkIn && data.checkOut ? data.checkIn + " \u2192 " + data.checkOut : "",
      data.nights ? data.nights + " \u665A" : "",
      data.rateMode === "specific" ? "\u6307\u5B9A\u623F\u578B" : "\u6700\u4F4E\u4EF7\u65E5\u5386\u623F",
      str(data.roomType),
      str(data.bedType),
      str(data.breakfast),
      str(data.guests) ? str(data.guests) + " \u4EBA" : ""
    ].filter(Boolean).join(" \xB7 ");
  }
  if (kind === "flight") {
    return [
      str(data.flightNo),
      data.from && data.to ? data.from + " \u2192 " + data.to : "",
      str(data.date),
      str(data.depTime),
      str(data.cabin),
      str(data.baggage)
    ].filter(Boolean).join(" \xB7 ");
  }
  return str(data.spec);
}
function normalizeRecord(raw) {
  if (!isObj(raw)) return null;
  const kind = KINDS.indexOf(raw.kind) >= 0 ? raw.kind : "product";
  const item = normalizeItem(kind, isObj(raw.item) ? raw.item : raw);
  const channels = normalizeChannels(raw.channels);
  const missing = (Array.isArray(raw.missing) ? raw.missing : []).map(normalizeMissing2).filter(Boolean).slice(0, 8);
  const createdAt = Number(raw.createdAt) || Date.now();
  const updatedAt = Number(raw.updatedAt) || createdAt;
  const status = ["draft", "comparing", "done", "failed", "stopped", "interrupted"].indexOf(raw.status) >= 0 ? raw.status : "done";
  const record = {
    id: str(raw.id).replace(/[^a-zA-Z0-9_-]/g, "").slice(0, 64) || uid("p"),
    createdAt,
    updatedAt,
    kind,
    item,
    title: str(raw.title).slice(0, 200) || itemTitle(kind, item),
    spec: str(raw.spec).slice(0, 160) || itemSummary(kind, item),
    url: httpUrl(raw.url),
    note: str(raw.note).slice(0, 500),
    status,
    phase: str(raw.phase).slice(0, 40),
    sessionId: str(raw.sessionId),
    sourcePlatform: platformId(raw.sourcePlatform),
    sourceStore: str(raw.sourceStore).slice(0, 40),
    sourcePrice: numberOrNull(raw.sourcePrice),
    sourceNote: str(raw.sourceNote).slice(0, 300),
    sourceAt: Number(raw.sourceAt) || 0,
    capturedFrom: str(raw.capturedFrom).slice(0, 30),
    channels,
    missing,
    assumptions: Array.isArray(raw.assumptions) ? raw.assumptions.map(function(item2) {
      return str(item2).slice(0, 200);
    }).filter(Boolean).slice(0, 8) : [],
    eventsTail: Array.isArray(raw.eventsTail) ? raw.eventsTail.map(function(item2) {
      return str(item2).slice(0, 240);
    }).filter(Boolean).slice(-8) : [],
    lastRunAt: Number(raw.lastRunAt) || 0,
    reminderAt: Number(raw.reminderAt) || 0,
    reminderTiming: raw.reminderTiming === "inexact" ? "inexact" : raw.reminderAt ? "exact" : ""
  };
  return record;
}
function normalizeRecords(raw) {
  const list = Array.isArray(raw) ? raw : isObj(raw) && Array.isArray(raw.items) ? raw.items : [];
  return list.map(normalizeRecord).filter(Boolean).sort(function(a, b) {
    return b.updatedAt - a.updatedAt;
  }).slice(0, 80);
}
function normalizeCandidate(raw) {
  if (!isObj(raw)) return null;
  const kind = KINDS.indexOf(raw.kind) >= 0 ? raw.kind : "product";
  const item = normalizeItem(kind, isObj(raw.item) ? raw.item : raw);
  const title = str(raw.title).slice(0, 200) || itemTitle(kind, item);
  if (!title) return null;
  const sourcePlatform = platformId(raw.sourcePlatform) || platformId(raw.platformHint);
  const sourcePrice = numberOrNull(raw.sourcePrice != null ? raw.sourcePrice : raw.priceHint);
  const createdAt = Number(raw.createdAt) || Date.now();
  return {
    id: str(raw.id).replace(/[^a-zA-Z0-9_-]/g, "").slice(0, 64) || uid("c"),
    createdAt,
    capturedAt: Number(raw.capturedAt) || createdAt,
    capturedFrom: str(raw.capturedFrom).slice(0, 30),
    kind,
    item,
    title,
    spec: str(raw.spec).slice(0, 160),
    url: httpUrl(raw.url),
    sourceUrl: httpUrl(raw.sourceUrl || raw.url),
    sourcePlatform,
    sourceStore: str(raw.sourceStore).slice(0, 40),
    sourcePrice,
    sourceNote: str(raw.sourceNote || raw.note).slice(0, 300),
    note: str(raw.note).slice(0, 300),
    platformHint: sourcePlatform,
    priceHint: sourcePrice
  };
}
function normalizeCandidates(raw) {
  const list = Array.isArray(raw) ? raw : isObj(raw) && Array.isArray(raw.items) ? raw.items : [];
  return list.map(normalizeCandidate).filter(Boolean).slice(0, 60);
}
function normalizeCompareResult(result) {
  if (!isObj(result)) return null;
  const verticalRaw = str(result.vertical) || (str(result.kind) === "hotel-compare" ? "hotel" : str(result.kind) === "flight-compare" ? "flight" : "product");
  const kind = KINDS.indexOf(verticalRaw) >= 0 ? verticalRaw : "product";
  const item = normalizeItem(kind, isObj(result.item) ? result.item : result);
  const channels = normalizeChannels(result.channels);
  const missing = (Array.isArray(result.missing) ? result.missing : []).map(normalizeMissing2).filter(Boolean).slice(0, 8);
  if (!channels.length && !missing.length) return null;
  return {
    kind,
    vertical: kind,
    item,
    title: str(result.title).slice(0, 200) || itemTitle(kind, item),
    spec: str(result.spec).slice(0, 160) || itemSummary(kind, item),
    currency: str(result.currency) || "CNY",
    runId: str(result.runId).slice(0, 80),
    writtenAt: parseTime(result.writtenAt) ? new Date(parseTime(result.writtenAt)).toISOString() : "",
    partial: result.partial === true,
    sourcePlatform: platformId(result.sourcePlatform) || (isObj(result.source) ? platformId(result.source.platform) : ""),
    capturedFrom: str(result.capturedFrom).slice(0, 30),
    channels,
    missing,
    assumptions: Array.isArray(result.assumptions) ? result.assumptions.map(function(item2) {
      return str(item2).slice(0, 200);
    }).filter(Boolean).slice(0, 8) : [],
    needsUser: result.needsUser === true,
    note: str(result.note).slice(0, 500)
  };
}
function normalizeCandidateResult(result) {
  if (!isObj(result)) return null;
  const kind = KINDS.indexOf(str(result.vertical)) >= 0 ? str(result.vertical) : str(result.kind) === "hotel-candidate" ? "hotel" : str(result.kind) === "flight-candidate" ? "flight" : "product";
  const item = normalizeItem(kind, isObj(result.item) ? result.item : result);
  const title = str(result.title || result.name).slice(0, 200) || itemTitle(kind, item);
  if (!title) return null;
  return normalizeCandidate({
    kind,
    item,
    title,
    spec: str(result.spec).slice(0, 160),
    url: result.url || result.sourceUrl,
    sourceUrl: result.sourceUrl || result.url,
    sourcePlatform: result.sourcePlatform || result.platform,
    sourceStore: result.store || result.sourceStore,
    sourcePrice: result.sourcePrice != null ? result.sourcePrice : result.price,
    sourceNote: result.sourceNote || result.note,
    note: result.note,
    capturedFrom: result.capturedFrom || "floating",
    capturedAt: result.capturedAt
  });
}
function inferResultKind(result) {
  if (!isObj(result)) return "";
  if (str(result.kind) === "price-candidate") return "candidate";
  if (str(result.kind) === "price-compare") return "compare";
  if (Array.isArray(result.channels) || Array.isArray(result.missing)) return "compare";
  if (str(result.title)) return "candidate";
  return "";
}
function recordStatus(record) {
  switch (record.status) {
    case "comparing":
      return { label: "\u6BD4\u4EF7\u4E2D", tone: "live" };
    case "done":
      return { label: "\u5DF2\u6838\u9A8C", tone: "ok" };
    case "failed":
      return { label: "\u672A\u5B8C\u6210", tone: "danger" };
    case "stopped":
      return { label: "\u5DF2\u505C\u6B62", tone: "warn" };
    case "interrupted":
      return { label: "\u5F85\u4F60\u786E\u8BA4", tone: "warn" };
    default:
      return { label: "\u5F85\u5F00\u59CB", tone: "" };
  }
}
var AUTHENTIC_HINTS = ["\u65D7\u8230", "\u5929\u732B\u56FD\u9645", "\u767E\u4EBF\u8865\u8D34", "\u767E\u4EBF", "\u81EA\u8425", "\u8D85\u503C\u8D2D", "\u9ED1\u6807", "\u5B98\u65B9", "\u76F4\u8425", "\u822A\u53F8", "\u54C1\u724C"];
function isAuthenticChannel(channel) {
  if (!channel) return false;
  const text = str(channel.store) + " " + str(channel.label);
  return AUTHENTIC_HINTS.some(function(hint) {
    return text.indexOf(hint) >= 0;
  });
}
function claimableChannels(channels) {
  return (channels || []).filter(function(channel) {
    if (!channel || channel.price == null || !channel.verifiedAt || !isAuthenticChannel(channel)) return false;
    return channel.match === "same";
  });
}
function uniq(list) {
  const seen = {};
  const out = [];
  (list || []).forEach(function(item) {
    if (seen[item]) return;
    seen[item] = true;
    out.push(item);
  });
  return out;
}
function selectedPlatformNames(ids) {
  return (ids || []).map(platformLabel).join("\u3001");
}
function memoryForPrompt(memory, platformIds) {
  const chunks = [];
  (platformIds || []).forEach(function(id) {
    const platform = PLATFORM_MAP[id];
    const entry = memory && memory.platforms ? memory.platforms[id] : null;
    if (!platform || !entry) return;
    chunks.push("\u3010" + platform.name + "\u3011");
    chunks.push("\u6B63\u54C1\u6E20\u9053\uFF1A" + platform.channels.join(" / "));
    if (entry.coupon) chunks.push("\u9886\u5238\uFF1A" + entry.coupon);
    (entry.steps || []).forEach(function(step, index) {
      chunks.push(index + 1 + ". " + step);
    });
    if (entry.notes) chunks.push("\u8865\u5145\uFF1A" + entry.notes);
    chunks.push("");
  });
  return chunks.join("\n").trim();
}

// src/components.jsx
function Icon(props) {
  const name = props.name;
  const size = props.size || 20;
  const style = props.style || {};
  const common = {
    width: size,
    height: size,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round",
    strokeLinejoin: "round",
    "aria-hidden": true,
    style: { display: "block", flex: "none", ...style }
  };
  switch (name) {
    case "plus":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M12 5v14M5 12h14" }));
    case "camera":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M4 8.5A2.5 2.5 0 0 1 6.5 6h1.2l1.1-1.7h6.4L16.3 6h1.2A2.5 2.5 0 0 1 20 8.5v8A2.5 2.5 0 0 1 17.5 19h-11A2.5 2.5 0 0 1 4 16.5z" }), /* @__PURE__ */ import_react.default.createElement("circle", { cx: "12", cy: "12.4", r: "3.2" }));
    case "arrow":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M5 12h13M13 6l6 6-6 6" }));
    case "back":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M19 12H6M11 6l-6 6 6 6" }));
    case "chevron":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M9 5l7 7-7 7" }));
    case "close":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M6 6l12 12M18 6L6 18" }));
    case "trash":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M4 7h16M9 7V5h6v2M6.5 7l.8 12.2h9.4L17.5 7M10 11v5M14 11v5" }));
    case "clock":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("circle", { cx: "12", cy: "12", r: "8.2" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M12 7.5V12l3 1.8" }));
    case "link":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M10.5 13.5a3.5 3.5 0 0 0 5 0l2.4-2.4a3.5 3.5 0 0 0-5-5l-1.2 1.2" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M13.5 10.5a3.5 3.5 0 0 0-5 0l-2.4 2.4a3.5 3.5 0 0 0 5 5l1.2-1.2" }));
    case "bell":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M6.5 10a5.5 5.5 0 0 1 11 0c0 4 1.5 5.5 1.5 5.5H5S6.5 14 6.5 10z" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M10 19a2 2 0 0 0 4 0" }));
    case "spark":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M12 3l1.6 5.4L19 10l-5.4 1.6L12 17l-1.6-5.4L5 10l5.4-1.6z" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M18 16l.7 2.3L21 19l-2.3.7L18 22l-.7-2.3L15 19l2.3-.7z" }));
    case "record":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("rect", { x: "5", y: "3.5", width: "14", height: "17", rx: "2.4" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M8.5 8h7M8.5 12h7M8.5 16h4" }));
    case "memory":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M9 4.5a3 3 0 0 0-3 3 3 3 0 0 0-1.5 5.6A3 3 0 0 0 6 18.4a3 3 0 0 0 3 1.1V4.5z" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M15 4.5a3 3 0 0 1 3 3 3 3 0 0 1 1.5 5.6 3 3 0 0 1-1.5 5.3 3 3 0 0 1-3 1.1V4.5z" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M9 9h2M9 13h2M13 9h2M13 13h2" }));
    case "settings":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("circle", { cx: "12", cy: "12", r: "3" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M19.4 13.5a7.7 7.7 0 0 0 0-3l1.7-1.3-2-3.4-2 .9a7.5 7.5 0 0 0-2.6-1.5L14.2 3h-4l-.3 2.2A7.5 7.5 0 0 0 7.3 6.7l-2-.9-2 3.4 1.7 1.3a7.7 7.7 0 0 0 0 3L3.3 14.8l2 3.4 2-.9a7.5 7.5 0 0 0 2.6 1.5l.3 2.2h4l.3-2.2a7.5 7.5 0 0 0 2.6-1.5l2 .9 2-3.4z" }));
    case "alert":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M12 4.5l8.5 15h-17z" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M12 9.5v4.5M12 17h.01" }));
    case "shield":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M12 3l7 2.6v5.2c0 4.6-3 8-7 9.7-4-1.7-7-5.1-7-9.7V5.6z" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M8.8 11.8l2.2 2.2 4.2-4.3" }));
    case "refresh":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M4.5 10a7.5 7.5 0 0 1 12.8-4L20 8.7M20 4.5v4.2h-4.2" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M19.5 14a7.5 7.5 0 0 1-12.8 4L4 15.3M4 19.5v-4.2h4.2" }));
    case "check":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M5 12.5l4.3 4.3L19 7" }));
    case "float":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("circle", { cx: "12", cy: "12", r: "8.2" }), /* @__PURE__ */ import_react.default.createElement("circle", { cx: "12", cy: "12", r: "3.2" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M12 3.8v3M12 17.2v3M3.8 12h3M17.2 12h3" }));
    case "scan":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M4 8V5.5A1.5 1.5 0 0 1 5.5 4H8M16 4h2.5A1.5 1.5 0 0 1 20 5.5V8M20 16v2.5a1.5 1.5 0 0 1-1.5 1.5H16M8 20H5.5A1.5 1.5 0 0 1 4 18.5V16M4 12h16" }));
    case "tag":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M11.2 4H19a1 1 0 0 1 1 1v7.8L12 20.8 3.2 12z" }), /* @__PURE__ */ import_react.default.createElement("circle", { cx: "15.6", cy: "8.4", r: "1.2" }));
    case "phone":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("rect", { x: "6.5", y: "2.8", width: "11", height: "18.4", rx: "2.6" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M10.5 18.4h3" }));
    case "edit":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M14.5 5.5l4 4L9 19H5v-4z" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M12.5 7.5l4 4" }));
    case "compare":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M4 8h12M12 4l4 4-4 4" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M20 16H8M12 12l-4 4 4 4" }));
    case "bed":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M3 18v-7h18v7M3 18h18M5 11V7h5v4M10 11V9h4v2M14 11V7h5v4" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M3 21v-3M21 21v-3" }));
    case "plane":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M10.4 13.7 3 11.2V9.1l7.4 1.6V4.8a1.6 1.6 0 0 1 3.2 0v5.9l7.4-1.6v2.1l-7.4 2.5v4.5l2.3 1.4V21l-3.9-1-3.9 1v-1.4l2.3-1.4z" }));
    case "download":
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("path", { d: "M12 4v10M8 10.5l4 4 4-4" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M5 19h14" }));
    default:
      return /* @__PURE__ */ import_react.default.createElement("svg", { ...common }, /* @__PURE__ */ import_react.default.createElement("circle", { cx: "12", cy: "12", r: "8" }), /* @__PURE__ */ import_react.default.createElement("path", { d: "M12 8v4l3 2" }));
  }
}
function PlatformDot(props) {
  const id = props.platform;
  return /* @__PURE__ */ import_react.default.createElement("span", { className: "pr-pdot", style: { background: platformColor(id) + "26", color: platformColor(id), borderColor: platformColor(id) + "4d" } }, platformLabel(id).slice(0, 1));
}
function StatusPill(props) {
  const meta = props.meta || { label: "", tone: "" };
  return /* @__PURE__ */ import_react.default.createElement("span", { className: "pr-status", "data-tone": meta.tone || void 0 }, meta.label);
}
function SectionHead(props) {
  return /* @__PURE__ */ import_react.default.createElement("div", { className: "pr-section-head" }, /* @__PURE__ */ import_react.default.createElement("h2", null, props.title), props.action || null);
}
function Spinner(props) {
  const small = props.small;
  return /* @__PURE__ */ import_react.default.createElement("span", { className: small ? "pr-spin pr-spin-sm" : "pr-spin", "aria-hidden": "true" });
}
function Radar(props) {
  return /* @__PURE__ */ import_react.default.createElement("span", { className: props.small ? "pr-radar pr-radar-sm" : "pr-radar", "aria-hidden": "true" }, /* @__PURE__ */ import_react.default.createElement("i", null), /* @__PURE__ */ import_react.default.createElement("i", null), /* @__PURE__ */ import_react.default.createElement("i", null), /* @__PURE__ */ import_react.default.createElement("b", null));
}
function Field(props) {
  return /* @__PURE__ */ import_react.default.createElement("label", { className: "pr-field", htmlFor: props.id }, /* @__PURE__ */ import_react.default.createElement("span", { className: "pr-field-label" }, /* @__PURE__ */ import_react.default.createElement("span", null, props.label), props.hint ? /* @__PURE__ */ import_react.default.createElement("small", null, props.hint) : null), props.children);
}
function Empty(props) {
  return /* @__PURE__ */ import_react.default.createElement("div", { className: "pr-empty" }, /* @__PURE__ */ import_react.default.createElement("span", { className: "pr-empty-icon" }, /* @__PURE__ */ import_react.default.createElement(Icon, { name: props.icon || "compare", size: 26 })), /* @__PURE__ */ import_react.default.createElement("strong", null, props.title), props.body ? /* @__PURE__ */ import_react.default.createElement("p", null, props.body) : null, props.action || null);
}
function Sheet(props) {
  return /* @__PURE__ */ import_react.default.createElement("div", { className: "pr-sheet-backdrop", onClick: props.onClose || void 0 }, /* @__PURE__ */ import_react.default.createElement("section", { className: "pr-sheet", role: "dialog", "aria-modal": "true", "aria-label": props.label || "\u5F39\u5C42", onClick: (event) => event.stopPropagation() }, /* @__PURE__ */ import_react.default.createElement("div", { className: "pr-sheet-grab" }), /* @__PURE__ */ import_react.default.createElement("div", { className: "pr-sheet-head" }, /* @__PURE__ */ import_react.default.createElement("div", { style: { flex: 1, minWidth: 0 } }, /* @__PURE__ */ import_react.default.createElement("h2", null, props.title), props.subtitle ? /* @__PURE__ */ import_react.default.createElement("p", null, props.subtitle) : null), /* @__PURE__ */ import_react.default.createElement("button", { type: "button", className: "pr-sheet-close", "aria-label": "\u5173\u95ED", onClick: props.onClose }, /* @__PURE__ */ import_react.default.createElement(Icon, { name: "close", size: 19 }))), /* @__PURE__ */ import_react.default.createElement("div", { className: "pr-sheet-body" }, props.children)));
}

// src/prompts.js
var RESULT_PATH = "/root/.dsh/wish/workspaces/" + PANEL_ID + "/agent-results.json";
function finalizePrompt(text) {
  return String(text || "").split("__RESULT_PATH__").join(RESULT_PATH);
}
var PRODUCT_SCHEMA = [
  "{",
  '  "kind": "price-compare",',
  '  "vertical": "product",',
  '  "title": "\u5546\u54C1\u540D",',
  '  "spec": "\u6838\u9A8C\u5230\u7684\u7EDF\u4E00\u89C4\u683C\uFF1B\u65E0\u6CD5\u786E\u8BA4\u5C31\u5199\u4F60\u770B\u5230\u7684\u5019\u9009\u89C4\u683C",',
  '  "sourcePlatform": "taobao | pdd | douyin | jd | \u7A7A\u5B57\u7B26\u4E32",',
  '  "capturedFrom": "current-page | candidate | search",',
  '  "partial": true,',
  '  "runId": "\u672C\u6B21\u4EFB\u52A1\u6807\u8BC6",',
  '  "writtenAt": "2026-11-08T10:00:00+08:00",',
  '  "channels": [',
  "    {",
  '      "platform": "taobao | pdd | douyin | jd",',
  '      "store": "\u5B98\u65B9\u65D7\u8230\u5E97 / \u767E\u4EBF\u8865\u8D34 / \u4EAC\u4E1C\u81EA\u8425 / \u5929\u732B\u56FD\u9645 / \u54C1\u724C\u8D85\u503C\u8D2D / \u54C1\u724C\u9ED1\u6807",',
  '      "price": 199.0,',
  '      "shipping": 0,',
  '      "coupons": ["\u5E97\u94FA\u5238 10 \u5143"],',
  '      "condition": "\u5238\u540E\u4EF7\uFF1B\u8DE8\u5E97\u6EE1 300 \u51CF 40\uFF0C\u6309\u521A\u597D\u51D1\u5355\u4F30\u7B97",',
  '      "url": "\u9875\u9762\u80FD\u76F4\u63A5\u770B\u5230\u7684\u94FE\u63A5\uFF1B\u6CA1\u6709\u5C31\u7559\u7A7A",',
  '      "linkKind": "product | search | current | none",',
  '      "specSeen": "\u9875\u9762\u663E\u793A\u7684\u989C\u8272/\u6B3E\u5F0F/\u5C3A\u7801/\u6570\u91CF",',
  '      "match": "same | different | unknown",',
  '      "matchNote": "\u548C\u76EE\u6807\u7684\u5DEE\u5F02\uFF1B\u6CA1\u6709\u5C31\u7559\u7A7A",',
  '      "verifiedAt": "2026-11-08T10:00:00+08:00",',
  '      "note": ""',
  "    }",
  "  ],",
  '  "missing": [{ "platform": "pdd", "reason": "\u627E\u4E0D\u5230\u540C\u89C4\u683C / \u505C\u5728\u767B\u5F55\u9875" }],',
  '  "assumptions": ["\u6EE1\u51CF\u6309\u521A\u597D\u51D1\u5230 300 \u5143\u4F30\u7B97\uFF0C\u51D1\u5355\u54C1\u4E4B\u540E\u53EF\u53D6\u6D88"],',
  '  "needsUser": false,',
  '  "note": "\u53EA\u80FD\u58F0\u79F0\u5DF2\u6838\u9A8C\u6765\u6E90\u4E2D\u7684\u6700\u4F4E\u4EF7"',
  "}"
].join("\n");
var HOTEL_SCHEMA = [
  "{",
  '  "kind": "price-compare",',
  '  "vertical": "hotel",',
  '  "title": "\u9152\u5E97\u540D",',
  '  "item": {',
  '    "hotelName": "\u9152\u5E97\u540D", "city": "\u57CE\u5E02",',
  '    "checkIn": "YYYY-MM-DD", "checkOut": "YYYY-MM-DD", "nights": 2, "rateMode": "lowest",',
  '    "roomType": "\u623F\u578B\uFF08\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\u53EF\u4E3A\u7A7A\uFF09", "bedType": "\u5927\u5E8A/\u53CC\u5E8A", "breakfast": "\u542B\u65E9/\u65E0\u65E9",',
  '    "cancelPolicy": "\u514D\u8D39\u53D6\u6D88/\u4E0D\u53EF\u53D6\u6D88", "guests": "2 \u4EBA"',
  "  },",
  '  "sourcePlatform": "ctrip | meituan | qunar | \u7A7A\u5B57\u7B26\u4E32",',
  '  "partial": true, "runId": "\u672C\u6B21\u4EFB\u52A1\u6807\u8BC6", "writtenAt": "2026-11-08T10:00:00+08:00",',
  '  "channels": [',
  "    {",
  '      "platform": "ctrip | meituan | qunar",',
  '      "store": "\u9152\u5E97\u5B98\u65B9 / \u643A\u7A0B\u81EA\u8425 / \u7F8E\u56E2\u81EA\u8425 / \u53BB\u54EA\u513F\u81EA\u8425",',
  '      "label": "\u623F\u578B\u540D", "price": 699, "priceUnit": "night",',
  '      "condition": "\u542B\u53CC\u65E9/\u514D\u8D39\u53D6\u6D88/\u542B\u7A0E\u8D39", "coupons": [],',
  '      "specSeen": "\u540C\u9152\u5E97\u540C\u65E5\u671F\u540C\u623F\u578B", "match": "same | close | different | unknown",',
  '      "matchNote": "\u623F\u578B/\u5E8A\u578B/\u65E9\u9910/\u53D6\u6D88\u653F\u7B56\u5DEE\u5F02", "verifiedAt": "2026-11-08T10:00:00+08:00",',
  '      "details": { "roomType": "\u623F\u578B", "bedType": "\u5927\u5E8A", "breakfast": "\u542B\u53CC\u65E9", "cancelPolicy": "\u514D\u8D39\u53D6\u6D88", "taxes": "\u542B\u7A0E\u8D39" },',
  '      "url": "", "linkKind": "current | none", "note": ""',
  "    }",
  "  ],",
  '  "missing": [{ "platform": "meituan", "reason": "\u672A\u627E\u5230\u540C\u65E5\u671F\u540C\u623F\u578B" }],',
  '  "assumptions": [], "needsUser": false, "note": "\u53EA\u80FD\u58F0\u79F0\u5DF2\u6838\u9A8C\u6765\u6E90\u4E2D\u7684\u6700\u4F4E\u4EF7"',
  "}"
].join("\n");
var FLIGHT_SCHEMA = [
  "{",
  '  "kind": "price-compare",',
  '  "vertical": "flight",',
  '  "title": "\u822A\u53F8 + \u822A\u73ED\u53F7",',
  '  "item": {',
  '    "airline": "\u822A\u53F8", "flightNo": "MU1234", "date": "YYYY-MM-DD",',
  '    "from": "\u51FA\u53D1\u673A\u573A", "to": "\u5230\u8FBE\u673A\u573A", "depTime": "08:00", "arrTime": "10:30",',
  '    "cabin": "\u7ECF\u6D4E\u8231", "passengers": "1 \u4EBA"',
  "  },",
  '  "sourcePlatform": "ctrip | meituan | qunar | \u7A7A\u5B57\u7B26\u4E32",',
  '  "partial": true, "runId": "\u672C\u6B21\u4EFB\u52A1\u6807\u8BC6", "writtenAt": "2026-11-08T10:00:00+08:00",',
  '  "channels": [',
  "    {",
  '      "platform": "ctrip | meituan | qunar",',
  '      "store": "\u822A\u53F8\u5B98\u65B9 / \u643A\u7A0B\u81EA\u8425 / \u7F8E\u56E2\u81EA\u8425 / \u53BB\u54EA\u513F\u81EA\u8425",',
  '      "label": "\u8231\u4F4D+\u884C\u674E", "price": 699, "priceUnit": "ticket",',
  '      "condition": "\u542B\u673A\u5EFA\u71C3\u6CB9/20kg \u6258\u8FD0/\u9000\u6539\u89C4\u5219", "coupons": [],',
  '      "specSeen": "\u540C\u822A\u73ED\u540C\u65E5\u671F\u540C\u8231\u4F4D", "match": "same | different | unknown",',
  '      "matchNote": "\u822A\u73ED/\u65E5\u671F/\u8231\u4F4D/\u884C\u674E\u5DEE\u5F02", "verifiedAt": "2026-11-08T10:00:00+08:00",',
  '      "details": { "flightNo": "MU1234", "date": "YYYY-MM-DD", "cabin": "\u7ECF\u6D4E\u8231", "baggage": "20kg", "taxes": "\u542B\u7A0E\u8D39" },',
  '      "url": "", "linkKind": "current | none", "note": ""',
  "    }",
  "  ],",
  '  "missing": [{ "platform": "qunar", "reason": "\u672A\u627E\u5230\u540C\u822A\u73ED\u540C\u8231\u4F4D" }],',
  '  "assumptions": [], "needsUser": false, "note": "\u53EA\u80FD\u58F0\u79F0\u5DF2\u6838\u9A8C\u6765\u6E90\u4E2D\u7684\u6700\u4F4E\u4EF7"',
  "}"
].join("\n");
function firstWriteBlock() {
  return [
    "\u3010\u7B2C\u4E00\u6761\u786C\u89C4\u5219\uFF1A\u5148\u5199\u6765\u6E90\uFF0C\u518D\u770B\u522B\u7684\u3011",
    "1. \u7B2C\u4E00\u4E2A\u5DE5\u5177\u8C03\u7528\u7528 screen \u8BFB\u5F53\u524D\u5C4F\u3002\u7ED3\u679C\u6587\u4EF6\u56FA\u5B9A\u5199 __RESULT_PATH__\uFF08\u8FD9\u662F\u5BBF\u4E3B\u8BFB\u53D6\u7684\u8DEF\u5F84\uFF0C\u4E0D\u662F\u5F53\u524D pwd\uFF09\uFF1B\u4E0D\u8981\u7528 bash/ls \u627E\u8DEF\u5F84\u3002",
    "2. \u7B2C\u4E8C\u4E2A\u5DE5\u5177\u8C03\u7528\u5148 read \u4E00\u6B21 __RESULT_PATH__\uFF08\u5B58\u5728\u5C31\u8BFB\u53D6\uFF0C\u4E0D\u5B58\u5728\u4F1A\u62A5\u9519\uFF0C\u76F4\u63A5\u7EE7\u7EED\uFF09\uFF1B\u968F\u540E\u7ACB\u523B write \u6765\u6E90\u3002\u5DF2\u6709\u7ED3\u679C\u6587\u4EF6\u4E0D\u5148 read\uFF0Cwrite \u4F1A\u88AB\u62D2\u3002\u9996\u5C4F\u6709\u4EF7\u683C\u5C31\u5FC5\u987B write\uFF0C\u4E0D\u51C6\u4E3A\u4E86\u6807\u9898\u3001\u5E97\u94FA\u3001\u5238\u6216\u89C4\u683C\u6EDA\u52A8\u3002\u53EA\u6709\u9996\u5C4F\u6CA1\u6709\u4EF7\u683C\u65F6\uFF0C\u624D\u5141\u8BB8\u5148 scroll 1 \u6B21\uFF0Cscroll \u540E\u5FC5\u987B write\u3002\u6CA1\u6709\u5199\u6210\u529F\u4E4B\u524D\uFF0C\u4E0D\u8981\u6253\u5F00\u5176\u4ED6 App\u3001\u4E0D\u8981\u8FDB\u5E97\u94FA\u9875/\u8BC4\u4EF7\u9875/\u8BE6\u60C5\u9875/\u5238\u4E2D\u5FC3\u3002",
    "3. \u6807\u9898\u548C\u4EF7\u683C\u4ECE\u5F53\u524D\u9996\u5C4F\u6284\uFF1B\u6807\u9898\u770B\u4E0D\u6E05\u5C31\u7528\u641C\u7D22\u680F\u6216\u9875\u9762\u53EF\u89C1\u7684\u5546\u54C1\u540D\u7247\u6BB5\uFF0Cnote \u5199\u201C\u6807\u9898\u5F85\u786E\u8BA4\u201D\u3002\u989C\u8272/\u6B3E\u5F0F/\u5C3A\u7801\u9996\u5C4F\u770B\u5230\u5C31\u5199 specSeen\uFF1B\u5E97\u94FA\u7C7B\u578B\u3001\u5238\u770B\u4E0D\u5230\u5C31\u7559\u7A7A\uFF0C\u4E0D\u8981\u4E3A\u4E86\u786E\u8BA4\u5B83\u4EEC\u6EDA\u52A8\u6216\u8FDB\u522B\u7684\u9875\u9762\u3002",
    "4. \u5199\u5165\u6A21\u677F\uFF08platform/sourcePlatform \u6362\u6210\u5F53\u524D App\uFF0Cprice \u7528\u6570\u5B57\uFF0C\u770B\u4E0D\u5230\u5199 null\uFF09\uFF1A",
    '{"kind":"price-compare","vertical":"product","title":"\u5F53\u524D\u5546\u54C1\u6807\u9898","spec":"","sourcePlatform":"\u5F53\u524D\u5E73\u53F0","partial":true,"runId":"\u4F60\u751F\u6210\u7684\u6807\u8BC6","writtenAt":"\u5F53\u524DISO\u65F6\u95F4","channels":[{"platform":"\u5F53\u524D\u5E73\u53F0","store":"","price":1150,"match":"same","verifiedAt":"\u5F53\u524DISO\u65F6\u95F4"}],"missing":[],"needsUser":false,"note":"\u6765\u6E90\u5DF2\u8BB0\u5F55"}',
    "\u53EA\u5199\u8FD9\u4E9B\u5FC5\u8981\u5B57\u6BB5\uFF1B\u7A7A\u5B57\u6BB5\u7701\u7565\uFF0C\u4E0D\u8981\u5199 previousResults/assumptions/\u8BE6\u60C5\uFF1B\u5199\u5165\u6210\u529F\u7ACB\u523B open \u4E0B\u4E00\u4E2A\u5E73\u53F0\u3002",
    "5. \u5982\u679C\u5DF2\u7ECF\u8C03\u7528\u4E86 3 \u6B21 phone \u5DE5\u5177\u8FD8\u6CA1 write\uFF0C\u7ACB\u523B\u505C\u4E0B\u5F53\u524D\u52A8\u4F5C\uFF0C\u5148\u5199\u6765\u6E90\uFF1B\u4E0D\u8981\u518D\u6EDA\u7B2C 2 \u6B21\u3002",
    "\u3010\u53EF\u9009\u6D41\u6C34\u7EBF\u3011\u6765\u6E90\u9996\u5C4F\u4FE1\u606F\u5DF2\u7ECF\u5728\u4E0A\u4E0B\u6587\u3001\u4E14\u4E0B\u4E00\u4E2A App \u542F\u52A8\u6162\u65F6\uFF1A\u53EF\u4EE5\u5148 open \u4E0B\u4E00\u4E2A App\uFF08\u53EA\u5F00\u4E00\u4E2A\uFF09\u8BA9\u5B83\u52A0\u8F7D\uFF0C\u7D27\u63A5\u7740\u4E0B\u4E00\u6B65\u7ACB\u523B write \u6765\u6E90\uFF0C\u518D screen \u76EE\u6807 App\uFF1Bopen \u540E\u4E0D\u8981\u5148\u70B9\u76EE\u6807\u9875\uFF0C\u5148\u5199\u3002write \u5931\u8D25\u5C31\u505C\u4E0B\u3002",
    "6. \u5199\u5B8C\u540E\u624D\u7EE7\u7EED\uFF1A\u6765\u6E90\u9875\u5DF2\u663E\u793A\u5238\u540E\u4EF7\u5C31\u76F4\u63A5\u7528\uFF1B\u6CA1\u6709\u5C31\u6309\u9875\u9762\u4EF7\u8BB0\u5F55\uFF0Cnote \u5199\u201C\u5238\u672A\u6838\u9A8C\u201D\uFF0C\u4E0D\u8981\u4E3A\u4E86\u6765\u6E90\u5E73\u53F0\u7684\u5238\u8FDB\u300C\u6211\u7684\u300D\u6216\u5238\u4E2D\u5FC3\uFF1B\u5176\u4ED6\u76EE\u6807\u5E73\u53F0\u7684\u5238\u6309\u4E0B\u9762\u7684\u89C4\u5219\u5404\u67E5\u4E00\u6B21\u3002"
  ].join("\n");
}
function firstWriteBlockGeneric() {
  return [
    "\u3010\u7B2C\u4E00\u6761\u786C\u89C4\u5219\uFF1A\u5148\u5199\u6765\u6E90\uFF0C\u518D\u770B\u522B\u7684\u3011",
    "1. \u7B2C\u4E00\u4E2A\u5DE5\u5177\u8C03\u7528\u7528 screen \u8BFB\u5F53\u524D\u5C4F\u3002\u7ED3\u679C\u6587\u4EF6\u56FA\u5B9A\u5199 __RESULT_PATH__\uFF08\u8FD9\u662F\u5BBF\u4E3B\u8BFB\u53D6\u7684\u8DEF\u5F84\uFF0C\u4E0D\u662F\u5F53\u524D pwd\uFF09\uFF1B\u4E0D\u8981\u7528 bash/ls \u627E\u8DEF\u5F84\u3002",
    "2. \u7B2C\u4E8C\u4E2A\u5DE5\u5177\u8C03\u7528\u5148 read \u4E00\u6B21 __RESULT_PATH__\uFF08\u5B58\u5728\u5C31\u8BFB\u53D6\uFF0C\u4E0D\u5B58\u5728\u4F1A\u62A5\u9519\uFF0C\u76F4\u63A5\u7EE7\u7EED\uFF09\uFF1B\u968F\u540E\u7ACB\u523B write \u6765\u6E90\u3002\u5DF2\u6709\u7ED3\u679C\u6587\u4EF6\u4E0D\u5148 read\uFF0Cwrite \u4F1A\u88AB\u62D2\u3002\u9996\u5C4F\u6709\u4EF7\u683C\u5C31\u5FC5\u987B write\uFF0C\u4E0D\u51C6\u4E3A\u4E86\u6807\u9898\u3001\u5E97\u94FA\u3001\u5238\u3001\u89C4\u683C\u3001\u623F\u578B\u6216\u8231\u4F4D\u6EDA\u52A8\u3002\u53EA\u6709\u9996\u5C4F\u6CA1\u6709\u4EF7\u683C\u65F6\uFF0C\u624D\u5141\u8BB8\u5148 scroll 1 \u6B21\uFF0Cscroll \u540E\u5FC5\u987B write\u3002\u6CA1\u6709\u5199\u6210\u529F\u4E4B\u524D\uFF0C\u4E0D\u8981\u6253\u5F00\u5176\u4ED6 App\u3001\u4E0D\u8981\u8FDB\u8BE6\u60C5\u9875/\u8BC4\u4EF7\u9875/\u5238\u4E2D\u5FC3\u3002",
    "3. \u6309\u4F60\u5224\u65AD\u7684\u7C7B\u578B\u4F7F\u7528\u4E0A\u9762\u7684\u6A21\u677F\uFF1A\u5546\u54C1\u6284\u6807\u9898/\u89C4\u683C/\u9996\u5C4F\u4EF7\uFF1B\u9152\u5E97\u6284\u9152\u5E97\u540D/\u57CE\u5E02/\u5165\u4F4F\u79BB\u5E97/\u623F\u578B/\u9996\u5C4F\u6BCF\u665A\u4EF7\uFF1B\u673A\u7968\u6284\u822A\u73ED\u53F7/\u65E5\u671F/\u822A\u7EBF/\u8231\u4F4D/\u9996\u5C4F\u7968\u4EF7\u3002\u770B\u4E0D\u5230\u7684\u5B57\u6BB5\u7559\u7A7A\uFF0C\u4E0D\u8981\u4E3A\u4E86\u5B83\u4EEC\u6EDA\u52A8\u6216\u8FDB\u522B\u7684\u9875\u9762\u3002",
    "4. \u5982\u679C\u5DF2\u7ECF\u8C03\u7528\u4E86 3 \u6B21 phone \u5DE5\u5177\u8FD8\u6CA1 write\uFF0C\u7ACB\u523B\u505C\u4E0B\u5F53\u524D\u52A8\u4F5C\uFF0C\u5148\u5199\u6765\u6E90\uFF1B\u4E0D\u8981\u518D\u6EDA\u7B2C 2 \u6B21\u3002",
    "5. \u5199\u5B8C\u540E\u624D\u7EE7\u7EED\uFF1A\u6765\u6E90\u9875\u5DF2\u663E\u793A\u4EF7\u683C/\u4F1A\u5458\u4EF7\u5C31\u76F4\u63A5\u7528\uFF1B\u6CA1\u6709\u5C31\u6309\u9875\u9762\u4EF7\u8BB0\u5F55\uFF0Cnote \u5199\u201C\u672A\u6838\u9A8C\u201D\uFF0C\u4E0D\u8981\u4E3A\u4E86\u5B83\u8FDB\u5238\u4E2D\u5FC3\uFF1B\u5176\u4ED6\u76EE\u6807\u5E73\u53F0\u6309\u4E0B\u9762\u7684\u901A\u7528\u53E3\u5F84\u67E5\u3002"
  ].join("\n");
}
function travelFirstWriteBlock(kind) {
  const hotel = kind === "hotel";
  return [
    "\u3010\u7B2C\u4E00\u6761\u786C\u89C4\u5219\uFF1A\u5148\u5199\u6765\u6E90\uFF0C\u518D\u770B\u522B\u7684\u3011",
    "1. \u7B2C\u4E00\u4E2A\u5DE5\u5177\u8C03\u7528\u7528 screen \u8BFB\u5F53\u524D\u5C4F\u3002\u7ED3\u679C\u6587\u4EF6\u56FA\u5B9A\u5199 __RESULT_PATH__\uFF08\u8FD9\u662F\u5BBF\u4E3B\u8BFB\u53D6\u7684\u8DEF\u5F84\uFF0C\u4E0D\u662F\u5F53\u524D pwd\uFF09\uFF1B\u4E0D\u8981\u7528 bash/ls \u627E\u8DEF\u5F84\u3002",
    "2. \u7B2C\u4E8C\u4E2A\u5DE5\u5177\u8C03\u7528\u5148 read \u4E00\u6B21 __RESULT_PATH__\uFF08\u5B58\u5728\u5C31\u8BFB\u53D6\uFF0C\u4E0D\u5B58\u5728\u4F1A\u62A5\u9519\uFF0C\u76F4\u63A5\u7EE7\u7EED\uFF09\uFF1B\u968F\u540E\u7ACB\u523B write \u6765\u6E90\u3002\u5DF2\u6709\u7ED3\u679C\u6587\u4EF6\u4E0D\u5148 read\uFF0Cwrite \u4F1A\u88AB\u62D2\u3002\u9996\u5C4F\u6709\u4EF7\u683C\u5C31\u5FC5\u987B write\uFF0C\u4E0D\u51C6\u4E3A\u4E86\u6807\u9898\u3001\u5E97\u94FA\u3001\u5238\u6216\u89C4\u683C\u6EDA\u52A8\u3002\u53EA\u6709\u9996\u5C4F\u6CA1\u6709\u4EF7\u683C\u65F6\uFF0C\u624D\u5141\u8BB8\u5148 scroll 1 \u6B21\uFF0Cscroll \u540E\u5FC5\u987B write\u3002\u6CA1\u6709\u5199\u6210\u529F\u4E4B\u524D\uFF0C\u4E0D\u8981\u6253\u5F00\u5176\u4ED6 App\u3001\u4E0D\u8981\u8FDB\u8BE6\u60C5\u9875/\u8BC4\u4EF7\u9875/\u5238\u4E2D\u5FC3\u3002",
    "3. " + (hotel ? "\u4ECE\u9996\u5C4F\u6284\u9152\u5E97\u540D\u3001\u57CE\u5E02\u3001\u5165\u4F4F/\u79BB\u5E97\u65E5\u671F\u3001\u623F\u578B\u3001\u4EF7\u683C\uFF1B\u5E8A\u578B\u3001\u65E9\u9910\u3001\u53D6\u6D88\u653F\u7B56\u770B\u4E0D\u5230\u5C31\u7559\u7A7A\u3002" : "\u4ECE\u9996\u5C4F\u6284\u822A\u73ED\u53F7\u3001\u822A\u53F8\u3001\u65E5\u671F\u3001\u51FA\u53D1/\u5230\u8FBE\u673A\u573A\u3001\u8231\u4F4D\u3001\u4EF7\u683C\uFF1B\u884C\u674E/\u9000\u6539\u770B\u4E0D\u5230\u5C31\u7559\u7A7A\u3002"),
    "4. \u5199\u5165\u6A21\u677F\uFF08\u7EB5\u5411 vertical=" + kind + "\uFF0Cplatform/sourcePlatform \u6362\u6210\u5F53\u524D App\uFF09\uFF1A",
    hotel ? '{"kind":"price-compare","vertical":"hotel","title":"\u9152\u5E97\u540D","item":{"hotelName":"\u9152\u5E97\u540D","city":"\u57CE\u5E02","checkIn":"YYYY-MM-DD","checkOut":"YYYY-MM-DD","nights":1,"rateMode":"lowest","roomType":"","guests":"2 \u4EBA"},"sourcePlatform":"ctrip","partial":true,"runId":"\u4F60\u751F\u6210\u7684\u6807\u8BC6","writtenAt":"\u5F53\u524DISO\u65F6\u95F4","channels":[{"platform":"ctrip","store":"","price":699,"priceUnit":"night","match":"same","verifiedAt":"\u5F53\u524DISO\u65F6\u95F4"}],"missing":[],"needsUser":false,"note":"\u6765\u6E90\u5DF2\u8BB0\u5F55"}' : '{"kind":"price-compare","vertical":"flight","title":"\u822A\u53F8+\u822A\u73ED\u53F7","item":{"airline":"\u822A\u53F8","flightNo":"\u822A\u73ED\u53F7","date":"YYYY-MM-DD","from":"\u51FA\u53D1\u673A\u573A","to":"\u5230\u8FBE\u673A\u573A","cabin":"\u7ECF\u6D4E\u8231","passengers":"1 \u4EBA"},"sourcePlatform":"ctrip","partial":true,"runId":"\u4F60\u751F\u6210\u7684\u6807\u8BC6","writtenAt":"\u5F53\u524DISO\u65F6\u95F4","channels":[{"platform":"ctrip","store":"","price":699,"priceUnit":"ticket","match":"same","verifiedAt":"\u5F53\u524DISO\u65F6\u95F4"}],"missing":[],"needsUser":false,"note":"\u6765\u6E90\u5DF2\u8BB0\u5F55"}',
    "\u53EA\u5199\u5FC5\u8981\u5B57\u6BB5\uFF1B\u7A7A\u5B57\u6BB5\u7701\u7565\uFF0C\u4E0D\u8981\u5199 previousResults/assumptions/\u8BE6\u60C5\uFF1B\u5199\u5165\u6210\u529F\u7ACB\u523B open \u4E0B\u4E00\u4E2A\u5E73\u53F0\u3002",
    "\u3010\u53EF\u9009\u6D41\u6C34\u7EBF\u3011\u6765\u6E90\u9996\u5C4F\u4FE1\u606F\u5DF2\u7ECF\u5728\u4E0A\u4E0B\u6587\u3001\u4E14\u4E0B\u4E00\u4E2A App \u542F\u52A8\u6162\u65F6\uFF1A\u53EF\u4EE5\u5148 open \u4E0B\u4E00\u4E2A App\uFF08\u53EA\u5F00\u4E00\u4E2A\uFF09\u8BA9\u5B83\u52A0\u8F7D\uFF0C\u7D27\u63A5\u7740\u4E0B\u4E00\u6B65\u7ACB\u523B write \u6765\u6E90\uFF0C\u518D screen \u76EE\u6807 App\uFF1Bopen \u540E\u4E0D\u8981\u5148\u70B9\u76EE\u6807\u9875\uFF0C\u5148\u5199\u3002write \u5931\u8D25\u5C31\u505C\u4E0B\u3002",
    "5. \u5982\u679C\u5DF2\u7ECF\u8C03\u7528\u4E86 3 \u6B21 phone \u5DE5\u5177\u8FD8\u6CA1 write\uFF0C\u7ACB\u523B\u505C\u4E0B\u5F53\u524D\u52A8\u4F5C\uFF0C\u5148\u5199\u6765\u6E90\uFF1B\u4E0D\u8981\u518D\u6EDA\u7B2C 2 \u6B21\u3002"
  ].join("\n");
}
function discipline() {
  return [
    "\u3010\u7701\u6B65\u9AA4\u7EAA\u5F8B\uFF08\u5FC5\u987B\u9075\u5B88\uFF09\u3011",
    "- \u7528\u6237\u5DF2\u7ECF\u5728\u67D0\u4E2A\u5E73\u53F0\u5546\u54C1\u9875\u53D1\u8D77\u65F6\uFF0C\u8FD9\u4E00\u9875\u5C31\u662F\u8BE5\u5E73\u53F0\u7684\u5DF2\u6838\u9A8C\u6765\u6E90\uFF1A\u76F4\u63A5\u8BB0\u5F55\u5F53\u524D\u6807\u9898\u3001\u89C4\u683C\u3001\u5230\u624B\u4EF7\u3001\u5E97\u94FA\u7C7B\u578B\u548C\u65F6\u95F4\u3002\u4E0D\u8981\u518D\u641C\u7D22\u540C\u4E00\u5E73\u53F0\uFF0C\u4E0D\u8981\u91CD\u65B0\u6253\u5F00\u5B83\u3002",
    "- \u6574\u573A\u6BD4\u4EF7\u53EA\u5728\u4E00\u4E2A\u4EFB\u52A1\u91CC\u5B8C\u6210\uFF1B\u6BCF\u4E2A\u76EE\u6807\u5E73\u53F0\u53EA\u8FDB\u5165\u4E00\u6B21\uFF0C\u6309\u987A\u5E8F\u505A\u5B8C\u518D\u5207\u6362\uFF0C\u4E0D\u8981\u6765\u56DE\u8DF3\uFF0C\u4E0D\u8981\u91CD\u590D\u6253\u5F00\u5DF2\u7ECF\u770B\u8FC7\u7684 App\u3002",
    "- \u62FF\u5230\u6765\u6E90\u9996\u5C4F\u7684\u4EF7\u683C/\u6807\u9898/\u65E5\u671F\u540E\u7ACB\u523B\u5199\u7ED3\u679C\u5E76\u5207\u4E0B\u4E00\u4E2A\u5E73\u53F0\uFF1B\u4E0D\u8981\u5728\u6765\u6E90\u9875\u7B49\u52A0\u8F7D\u3001\u770B\u8BC4\u4EF7\u3001\u9886\u5238\u6216\u53CD\u590D\u786E\u8BA4\u3002",
    "- \u6253\u5F00\u76EE\u6807 App \u540E\u5148 screen\uFF1A\u5982\u679C\u5F53\u524D\u9875\u662F\u4E0A\u6B21\u7559\u4E0B\u7684\u522B\u7684\u5546\u54C1/\u578B\u53F7\uFF0C\u4E0D\u8981\u6838\u4EF7\u3001\u4E0D\u8981\u5728\u5F53\u524D\u9875\u6EDA\u52A8\uFF0C\u76F4\u63A5\u7528\u641C\u7D22\u6846\u641C\u76EE\u6807\u6B3E\uFF1B\u641C 1 \u6B21\u4ECD\u65E0\u540C\u6B3E\u5C31\u8BB0 missing \u8F6C\u4E0B\u4E00\u4E2A\u3002\u62FC\u591A\u591A\u5C24\u5176\u5E38\u89C1\uFF0C\u4F8B\u5982\u76EE\u6807\u662F DU2 \u5374\u505C\u5728\u4E0A\u6B21\u7684 EX3\uFF0C\u76F4\u63A5\u641C DU2\uFF0C\u4E0D\u8981\u8FD4\u56DE\u9996\u9875\u95F2\u901B\u3002",
    "- \u4E0D\u8981\u70B9\u5206\u4EAB\u3001\u590D\u5236\u94FE\u63A5\u3001\u4FDD\u5B58\u56FE\u7247\u3001\u52A0\u5165\u8D2D\u7269\u8F66\u3001\u7ACB\u5373\u8D2D\u4E70\u3001\u63D0\u4EA4\u8BA2\u5355\u6216\u652F\u4ED8\uFF1B\u4E0D\u8981\u8FDB\u76F4\u64AD\u95F4\u3001\u5BA2\u670D\u3001\u5E97\u94FA\u9875\u3001\u8BC4\u4EF7\u9875\u3001\u8BE6\u60C5\u9875\u6216\u5E97\u94FA\u9996\u9875\u95F2\u901B\u3002",
    "- \u5E97\u94FA\u7C7B\u578B\u3001\u89C4\u683C\u3001\u5238\u5728\u5F53\u524D\u5546\u54C1\u4E3B\u5C4F\u770B\u4E0D\u5230\u5C31\u7559\u7A7A\uFF1B\u4E0D\u8981\u4E3A\u4E86\u786E\u8BA4\u5B83\u4EEC\u6EDA\u52A8\u7B2C 2 \u6B21\u6216\u8FDB\u5E97\u94FA\u9875\u3002\u5B81\u53EF\u8FD9\u6761\u6765\u6E90\u4E0D\u53C2\u4E0E\u6700\u4F4E\u4EF7\uFF0C\u4E5F\u4E0D\u8981\u5361\u4F4F\u3002",
    "- \u94FE\u63A5\u53EA\u5728\u5F53\u524D\u9875\u9762\u76F4\u63A5\u53EF\u89C1\u65F6\u987A\u4FBF\u8BB0\u5F55\uFF1B\u770B\u4E0D\u5230\u5C31\u7559\u7A7A\u5E76\u628A linkKind \u5199 none\uFF0C\u5F53\u524D\u9875\u6765\u6E90\u5199 current\u3002\u7EDD\u5BF9\u4E0D\u8981\u4E3A\u4E86\u62FF\u94FE\u63A5\u53BB\u6253\u5F00\u5206\u4EAB\u9762\u677F\u6216\u526A\u8D34\u677F\u3002",
    "- \u4EF7\u683C\u53EA\u770B\u5546\u54C1\u9996\u5C4F\uFF0C\u9ED8\u8BA4\u4E0D\u4E0B\u6ED1\uFF1B\u9996\u5C4F\u6CA1\u6709\u4EF7\u683C\u624D\u5141\u8BB8 1 \u6B21 scroll\uFF0C\u62FF\u5230\u7ACB\u523B\u505C\u6B62\u3002\u4E0D\u8981\u4E3A\u4E86\u5238\u3001\u89C4\u683C\u3001\u5E97\u94FA\u7C7B\u578B\u3001\u8BC4\u4EF7\u6216\u201C\u5B8C\u6574\u6807\u9898\u201D\u7EE7\u7EED\u4E0B\u6ED1\u3002",
    "- \u5FC5\u987B\u6838\u5BF9\u989C\u8272/\u6B3E\u5F0F/\u5C3A\u7801/\u6570\u91CF\uFF1A\u4E00\u81F4\u5199 match=same\uFF1B\u4E0D\u540C\u5199 match=different \u5E76\u5728 matchNote \u5199\u5DEE\u5F02\uFF1B\u9996\u5C4F\u770B\u4E0D\u6E05\u5199 match=unknown\u3002different/unknown \u4E0D\u53C2\u4E0E\u6700\u4F4E\u4EF7\uFF0C\u4F46\u4ECD\u8981\u8BB0\u5F55\u4EF7\u683C\u5E76\u5907\u6CE8\u3002",
    "- \u9886\u5238\u53EA\u5728\u9700\u8981\u65F6\u505A\u4E00\u6B21\uFF0C\u505A\u5B8C\u5C31\u79BB\u5F00\uFF0C\u4E0D\u53CD\u590D\u56DE\u5546\u54C1\u9875\u3002",
    "- \u89C4\u683C\u4E0D\u660E\u786E\u53EA\u95EE\u7528\u6237\u4E00\u6B21\uFF1B\u786E\u8BA4\u540E\u6240\u6709\u5E73\u53F0\u6309\u540C\u4E00\u89C4\u683C\u3002\u627E\u4E0D\u5230\u540C\u89C4\u683C\u5C31\u8BB0 missing\uFF0C\u4E0D\u8DE8\u89C4\u683C\u6BD4\u4EF7\u3002",
    "- \u624B\u673A\u64CD\u63A7\u7531\u6574\u573A\u4EFB\u52A1\u5171\u7528\uFF1B\u4E0D\u8981\u4E3A\u6BCF\u4E2A App \u5355\u72EC\u7533\u8BF7\u6388\u6743\uFF0C\u4E5F\u4E0D\u8981\u56E0\u4E3A\u5207\u6362 App \u91CD\u65B0\u5F00\u59CB\u4EFB\u52A1\u3002\u7CFB\u7EDF\u82E5\u5F39\u51FA\u654F\u611F\u9875\u9762\u786E\u8BA4\uFF0C\u96C6\u4E2D\u5904\u7406\u4E00\u6B21\u3002",
    "- \u666E\u901A\u641C\u7D22\u3001\u5207\u6362 App\u3001\u8FD4\u56DE\u3001\u70B9\u5238\u3001\u6EDA\u52A8\u90FD\u4E0D\u9700\u8981\u8BE2\u95EE\u7528\u6237\uFF0C\u76F4\u63A5\u505A\uFF1B\u53EA\u6709\u767B\u5F55\u3001\u9A8C\u8BC1\u7801\u3001\u652F\u4ED8\u3001\u98CE\u63A7\u6216\u89C4\u683C\u786E\u5B9E\u4E0D\u660E\u786E\u65F6\u624D\u505C\u4E0B\u3002\u4E0D\u8981\u6BCF\u4E00\u6B65\u90FD\u8BF7\u7528\u6237\u786E\u8BA4\uFF0C\u4E5F\u4E0D\u8981\u4E3A\u4E86\u786E\u8BA4\u666E\u901A\u64CD\u4F5C\u8C03\u7528 handoff\u3002",
    "",
    "\u3010\u8FB9\u6BD4\u8FB9\u4FDD\u5B58\uFF08\u5F88\u91CD\u8981\uFF09\u3011",
    "- \u8BFB\u5B8C\u5F53\u524D\u9875\uFF0C\u5148 read \u4E00\u6B21\u7ED3\u679C\u6587\u4EF6\uFF08\u5B58\u5728\u624D\u8BFB\uFF1B\u4E0D\u5B58\u5728\u4F1A\u62A5\u9519\uFF09\uFF0C\u518D write \u4E00\u6B21 agent-results.json\uFF1A\u81F3\u5C11\u5305\u542B sourcePlatform \u548C\u5F53\u524D\u6765\u6E90\u6E20\u9053\uFF0Cpartial \u8BBE\u4E3A true\uFF0C\u7136\u540E\u518D\u79BB\u5F00\u5F53\u524D App\u3002",
    "- \u4E4B\u540E\u6BCF\u6838\u9A8C\u5B8C\u4E00\u4E2A\u5E73\u53F0\uFF0C\u7ACB\u523B\u7528 write \u8986\u76D6\u66F4\u65B0\u540C\u4E00\u4E2A\u6587\u4EF6\uFF1A\u4FDD\u7559\u672C\u6B21\u5DF2\u7ECF\u6838\u9A8C\u7684 channels\uFF0C\u8865\u4E0A\u65B0\u5E73\u53F0\uFF1B\u4E0D\u8981\u590D\u5236 previousResults/\u65E7\u7ED3\u679C\uFF0C\u4E0D\u8981\u7B49\u5168\u90E8\u7ED3\u675F\u624D\u5199\u3002",
    "- \u6700\u540E\u5199\u4E00\u6B21\u5B8C\u6574\u7ED3\u679C\uFF0Cpartial \u8BBE\u4E3A false\u3002\u7ED3\u679C\u6587\u4EF6\u56FA\u5B9A\u662F __RESULT_PATH__\uFF08\u5BBF\u4E3B\u8BFB\u53D6\u8FD9\u4E2A\u8DEF\u5F84\uFF09\uFF1B\u76F4\u63A5\u7528 write \u5199\u5B83\uFF1B\u4E0D\u8981\u7528 bash/ls \u627E\u8DEF\u5F84\uFF0C\u4E0D\u8981\u5199\u5230\u5F53\u524D agent-workspace \u6216\u5176\u4ED6\u76EE\u5F55\uFF0C\u4E5F\u4E0D\u8981\u8BFB\u65E7\u7ED3\u679C\u3002",
    "",
    "\u3010\u9632\u5361\u4F4F\u3011",
    "- \u6BCF\u4E2A\u5E73\u53F0\u6700\u591A\u7EA6 8 \u6B21\u5DE5\u5177\u64CD\u4F5C\uFF1B\u8D85\u8FC7\u8FD8\u6CA1\u62FF\u5230\u9996\u5C4F\u4EF7\u683C\uFF0C\u5C31\u8BB0 missing \u5E76\u7EE7\u7EED\u4E0B\u4E00\u4E2A\u5E73\u53F0\u3002\u4EF7\u683C\u9ED8\u8BA4\u53EA\u770B\u9996\u5C4F\uFF0C\u4E0D\u4E0B\u6ED1\u3002",
    "- \u5C4F\u5E55\u6CA1\u6709\u53EF\u8BFB\u5185\u5BB9\uFF08\u4F8B\u5982\u53EA\u6709 sku3_content_view\uFF09\u65F6\uFF0C\u7ACB\u5373\u6309\u8FD4\u56DE\uFF0C\u4E0D\u8981\u8FDE\u7EED\u76F2\u70B9\uFF0C\u4E5F\u4E0D\u8981\u7528 tap_xy \u731C\u3002",
    "- \u4E0D\u8981\u7528 open \u6253\u5F00\u5546\u54C1/\u9152\u5E97/\u673A\u7968\u94FE\u63A5\uFF08\u4F1A\u8DF3\u6D4F\u89C8\u5668\u6216\u5B89\u5168\u9875\uFF09\uFF1Bopen \u53EA\u7528\u6765\u6253\u5F00 App\u3002",
    "- \u5238\u9875\u6700\u591A\u8FDB\u4E00\u6B21\uFF1B\u627E\u4E0D\u5230\u76EE\u6807\u5238\u5C31\u6309\u9875\u9762\u4EF7\u8BB0\u5F55\uFF0C\u5E76\u5728 note \u5199\u201C\u5238\u672A\u6838\u9A8C\u201D\uFF0C\u4E0D\u8981\u7EE7\u7EED\u7FFB\u5238\u5217\u8868\u3002",
    "- \u89C4\u683C/\u623F\u578B/\u8231\u4F4D\u6D6E\u5C42\u8BFB\u4E0D\u5230\u5C31\u8FD4\u56DE\uFF0C\u4F7F\u7528\u9875\u9762\u5DF2\u9009\u89C4\u683C\uFF1B\u786E\u5B9E\u65E0\u6CD5\u786E\u8BA4\u5C31 needsUser\uFF0C\u4E0D\u8981\u5728\u6D6E\u5C42\u91CC\u53CD\u590D\u70B9\u3002"
  ].join("\n");
}
function couponRules() {
  return [
    "\u3010\u5238\u4E0E\u6EE1\u51CF\uFF0C\u53EA\u505A\u4E00\u6B21\u3011",
    "\u4EE5\u4E0B\u89C4\u5219\u53EA\u7528\u4E8E\u76EE\u6807\u5E73\u53F0\uFF1B\u6765\u6E90\u5E73\u53F0\u6309\u7B2C\u4E00\u6761\u786C\u89C4\u5219\uFF0C\u4E0D\u4E3A\u4E86\u5238\u8FDB\u5238\u4E2D\u5FC3\u3002",
    "- \u6DD8\u5B9D\uFF1A\u4F5C\u4E3A\u76EE\u6807\u5E73\u53F0\u65F6\uFF0C\u5546\u54C1\u9875\u5DF2\u7ECF\u663E\u793A\u5238\u540E\u4EF7\u6216\u5238\u72B6\u6001\u5C31\u76F4\u63A5\u8BB0\u5F55\uFF1B\u770B\u4E0D\u5230\u624D\u53BB\u300C\u6211\u7684\u6DD8\u5B9D\u300D\u2192 \u4F18\u60E0\u5238 / \u9886\u5238\u4E2D\u5FC3\u786E\u8BA4\u4E00\u6B21\uFF0C\u7136\u540E\u79BB\u5F00\u6DD8\u5B9D\uFF0C\u4E0D\u56DE\u641C\u7D22\u9875\u3002",
    "- \u62FC\u591A\u591A\uFF1A\u53EA\u6709\u767E\u8865\u5546\u54C1\u4E14\u9875\u9762\u6CA1\u663E\u793A\u5238\u65F6\uFF0C\u624D\u4ECE\u767E\u4EBF\u8865\u8D34\u9891\u9053\u5DE6\u4E0A\u89D2\u4F1A\u5458\u5165\u53E3\u9886\u4E00\u6B21\uFF0C\u9886\u5B8C\u56DE\u5F53\u524D\u5546\u54C1\u9875\u3002",
    "- \u6296\u97F3\uFF1A\u5546\u54C1\u9875\u6CA1\u6709\u5238\u4FE1\u606F\u65F6\uFF0C\u624D\u53BB\u5546\u57CE\u9996\u9875\u9886\u5238\u9875\u9886\u4E00\u6B21\uFF0C\u518D\u56DE\u5F53\u524D\u5546\u54C1\u9875\uFF1B\u6574\u4E2A\u6296\u97F3\u53EA\u8BBF\u95EE\u4E00\u6B21\u3002",
    "- \u4EAC\u4E1C\uFF1A\u53EA\u5728\u5546\u54C1\u9875\u9886\u5238\u533A\u9886\u4E00\u6B21\uFF0C\u4E0D\u8DF3\u8F6C\u5176\u4ED6\u4F1A\u573A\u3002",
    "- \u6EE1\u51CF\u6309\u201C\u521A\u597D\u51D1\u5230\u95E8\u69DB\u3001\u5176\u4ED6\u51D1\u5355\u54C1\u4E4B\u540E\u53D6\u6D88\u201D\u7684\u65B9\u5F0F\u4F30\u7B97\u8BE5\u5546\u54C1\u5B9E\u4ED8\uFF0C\u5199\u8FDB assumptions\uFF1B\u4E0D\u8981\u771F\u7684\u4E0B\u5355\u3002",
    "- \u6709\u4F1A\u5458\u4EF7\u3001Plus \u4EF7\u3001\u9996\u5355\u793C\u91D1\u65F6\uFF0C\u53EA\u8BB0\u5F55\u754C\u9762\u660E\u786E\u663E\u793A\u4E14\u8BE5\u8D26\u53F7\u53EF\u7528\u7684\u4EF7\u683C\uFF0C\u5199\u8FDB condition\u3002"
  ].join("\n");
}
function productProtocol(options) {
  const platforms = options.platforms && options.platforms.length ? options.platforms : PLATFORMS.map(function(p) {
    return p.id;
  });
  const memoryPlatforms = platforms.concat(options.source ? [options.source.platform] : []);
  const memoryBlock = memoryForPrompt(options.memory, memoryPlatforms);
  const lines = [
    discipline(),
    "",
    "\u3010\u5FC5\u987B\u9075\u5B88\u7684\u6B63\u54C1\u6E20\u9053\u3011",
    "- \u6DD8\u5B9D / \u5929\u732B\uFF1A\u5B98\u65B9\u65D7\u8230\u5E97\u3001\u5929\u732B\u56FD\u9645\u3001\u767E\u4EBF\u8865\u8D34\u3001\u54C1\u724C\u8D85\u503C\u8D2D",
    "- \u62FC\u591A\u591A\uFF1A\u767E\u4EBF\u8865\u8D34\u3001\u5B98\u65B9\u65D7\u8230\u5E97\u3001\u54C1\u724C\u9ED1\u6807",
    "- \u6296\u97F3\u5546\u57CE\uFF1A\u54C1\u724C\u9ED1\u6807\u3001\u5B98\u65B9\u65D7\u8230\u5E97\u3001\u8D85\u503C\u8D2D",
    "- \u4EAC\u4E1C\uFF1A\u4EAC\u4E1C\u81EA\u8425\u3001\u5B98\u65B9\u65D7\u8230\u5E97\u3001\u767E\u4EBF\u8865\u8D34\u3001\u4EAC\u4E1C\u56FD\u9645",
    "C \u5E97\u3001\u4E2A\u4EBA\u5E97\u3001\u65E0\u6B63\u54C1\u6807\u8BC6\u7684\u7B2C\u4E09\u65B9\u5E97\u3001\u62CD\u5356/\u4E8C\u624B\u4E00\u5F8B\u4E0D\u8FDB\u6BD4\u4EF7\u8868\u3002",
    "",
    couponRules()
  ];
  if (options.autoCoupon === false) {
    lines.push("- \u7528\u6237\u672C\u6B21\u5173\u95ED\u4E86\u81EA\u52A8\u9886\u5238\uFF1A\u53EA\u8BFB\u53D6\u5DF2\u9886\u5230\u7684\u5238\u548C\u9875\u9762\u663E\u793A\u4EF7\u683C\uFF0C\u4E0D\u4E3B\u52A8\u9886\u65B0\u5238\uFF1B\u6BD4\u4EF7\u65B9\u6CD5\u91CC\u7684\u9886\u5238\u6B65\u9AA4\u8DF3\u8FC7\u9886\u5238\u52A8\u4F5C\u3002");
  }
  lines.push("");
  lines.push("\u3010\u6BD4\u4EF7\u53E3\u5F84\u3011");
  lines.push("- \u540C\u6B3E\u4F18\u5148\u4E8E\u4F4E\u4EF7\uFF1A\u641C\u7D22\u7ED3\u679C\u6807\u9898\u91CC\u7684\u578B\u53F7\u3001BOA/\u7248\u672C\u3001\u989C\u8272\u3001\u5C3A\u7801\u3001\u6570\u91CF\u5FC5\u987B\u548C\u6765\u6E90\u4E00\u81F4\uFF1B\u4E0D\u4E00\u81F4\u5C31\u7EE7\u7EED\u627E\u540C\u6B3E\uFF0C\u4E0D\u8981\u7528\u66F4\u4FBF\u5B9C\u7684\u4E0D\u540C\u6B3E\u5192\u5145\u6EE1\u610F\u6E20\u9053\u3002");
  lines.push("- \u53EA\u6BD4\u8F83\u540C\u4E00\u5546\u54C1\u3001\u540C\u4E00\u89C4\u683C\uFF1B\u89C4\u683C\u65E0\u6CD5\u786E\u8BA4\u65F6\u4E0D\u8981\u8DE8\u89C4\u683C\u6BD4\u4EF7\uFF0C\u628A needsUser \u8BBE\u4E3A true \u5E76\u5199\u6E05\u770B\u5230\u7684\u5019\u9009\u89C4\u683C\u3002\u4E0D\u540C\u6B3E\u6700\u591A\u8BB0\u4E3A match=different \u7684\u201C\u975E\u540C\u6B3E\u53C2\u8003\u201D\uFF0C\u5199\u6E05\u5DEE\u5F02\uFF0C\u4E0D\u53C2\u4E0E\u5E73\u53F0\u6700\u4F4E\u4EF7\u3002\u627E\u4E0D\u5230\u540C\u6B3E\u5C31\u5199 missing\uFF08\u539F\u56E0\uFF1A\u672A\u627E\u5230\u540C\u6B3E\uFF09\u3002");
  lines.push("- \u6BCF\u4E2A\u6E20\u9053\u8BB0\u5F55\uFF1A\u5E73\u53F0\u3001\u5E97\u94FA\u7C7B\u578B\u3001\u9996\u5C4F\u5230\u624B\u4EF7\uFF08\u4E0D\u542B\u8FD0\u8D39\uFF09\u3001\u8FD0\u8D39\u3001\u5238/\u6EE1\u51CF\u6761\u4EF6\u3001\u6838\u9A8C\u65F6\u95F4\u3001\u989C\u8272/\u6B3E\u5F0F/\u5C3A\u7801\uFF08specSeen\uFF09\u548C\u4E00\u81F4\u6027\uFF08match/matchNote\uFF09\uFF1B\u94FE\u63A5\u80FD\u987A\u4FBF\u770B\u5230\u5C31\u8BB0\uFF0C\u770B\u4E0D\u5230\u7559\u7A7A\u3002");
  lines.push("- \u4EF7\u683C\u4EE5\u5546\u54C1\u9996\u5C4F\u4E3A\u51C6\uFF0C\u9ED8\u8BA4\u4E0D\u4E0B\u6ED1\uFF1B\u9996\u5C4F\u6CA1\u6709\u4EF7\u683C\u624D\u5141\u8BB8 1 \u6B21 scroll\u3002\u6BCF\u4E2A\u5E73\u53F0\u6700\u591A\u7EA6 8 \u6B21 phone \u64CD\u4F5C\uFF0C\u8D85\u8FC7\u5C31\u8BB0 missing \u7EE7\u7EED\u3002");
  lines.push("- price \u62FF\u4E0D\u5230\u5C31\u5199 null\uFF0C\u7EDD\u4E0D\u80FD\u4F30\u7B97\u6216\u6CBF\u7528\u65E7\u4EF7\uFF1B\u62FF\u4E0D\u5230\u7684\u6E20\u9053\u653E\u8FDB missing \u5E76\u5199\u539F\u56E0\u3002");
  lines.push("- \u4E0D\u80FD\u58F0\u79F0\u300C\u5168\u7F51\u6700\u4F4E\u300D\uFF0C\u53EA\u80FD\u58F0\u79F0\u300C\u5DF2\u6838\u9A8C\u6765\u6E90\u4E2D\u7684\u6700\u4F4E\u4EF7\u300D\u3002");
  lines.push("");
  lines.push("\u3010\u5B89\u5168\u8FB9\u754C\u3011");
  lines.push("- \u53EA\u8BFB\u4EF7\u683C\u3001\u89C4\u683C\u3001\u5238\u548C\u94FE\u63A5\uFF1B\u4E0D\u8FDB\u652F\u4ED8\u3001\u4E0D\u63D0\u4EA4\u8BA2\u5355\u3001\u4E0D\u4F7F\u7528\u82B1\u5457/\u767D\u6761/\u5206\u671F\u3001\u4E0D\u5220\u9664\u8D2D\u7269\u8F66\u3002");
  lines.push("- \u9047\u5230\u767B\u5F55\u3001\u9A8C\u8BC1\u7801\u3001\u652F\u4ED8\u3001\u5B9E\u540D\u3001\u98CE\u63A7\u6216\u5B89\u5168\u9A8C\u8BC1\uFF0C\u7ACB\u523B\u505C\u4E0B\uFF0C\u628A needsUser \u8BBE\u4E3A true\uFF0C\u5199\u6E05\u5361\u5728\u54EA\u4E00\u6B65\uFF0C\u4EA4\u7ED9\u7528\u6237\u5904\u7406\uFF0C\u4E0D\u8981\u7ED5\u8FC7\u3002");
  lines.push("");
  lines.push("\u3010\u6BD4\u4EF7\u65B9\u6CD5\uFF08\u4F18\u5148\u7167\u505A\uFF0C\u754C\u9762\u53D8\u5316\u65F6\u4EE5\u5B9E\u9645\u5C4F\u5E55\u4E3A\u51C6\uFF09\u3011");
  lines.push(memoryBlock || "\uFF08\u6682\u65E0\u81EA\u5B9A\u4E49\u6BD4\u4EF7\u65B9\u6CD5\uFF0C\u6309\u4E0A\u9762\u7684\u6B63\u54C1\u6E20\u9053\u548C\u9886\u5238\u89C4\u5219\u6267\u884C\u3002\uFF09");
  lines.push("");
  lines.push("\u3010\u7ED3\u679C\u5199\u76D8\u3011");
  lines.push("\u5B8C\u6210\u540E\uFF0C\u7528 write \u5DE5\u5177\u628A\u7ED3\u679C\u5199\u5165\u5F53\u524D\u5DE5\u4F5C\u533A\u7684 agent-results.json\uFF0C\u5185\u5BB9\u662F\u4E00\u4E2A JSON \u5BF9\u8C61\uFF1A");
  lines.push(PRODUCT_SCHEMA);
  lines.push("linkKind \u8BF4\u660E\uFF1Aproduct=\u5546\u54C1\u9875\u94FE\u63A5\uFF1Bsearch=\u641C\u7D22\u9875\u94FE\u63A5\uFF1Bcurrent=\u5F53\u524D\u9875\u6838\u9A8C\u4F46\u6CA1\u6709\u94FE\u63A5\uFF1Bnone=\u6CA1\u6709\u94FE\u63A5\u3002\u4E0D\u8981\u628A\u641C\u7D22\u7ED3\u679C\u9875\u4F2A\u88C5\u6210\u5546\u54C1\u94FE\u63A5\u3002");
  lines.push("\u5982\u679C\u7ED9\u4E86\u6765\u6E90\u5E73\u53F0\uFF0Cchannels \u7684\u7B2C\u4E00\u6761\u5FC5\u987B\u662F\u6765\u6E90\u5E73\u53F0\u8FD9\u4E00\u9875\uFF1B\u5176\u4ED6\u76EE\u6807\u5E73\u53F0\u6CA1\u6709\u67E5\u5230\u7684\uFF0C\u8981\u5199\u8FDB missing\u3002");
  lines.push("\u6700\u540E\u7528\u4E2D\u6587\u7B80\u77ED\u6C47\u62A5\uFF1A\u6838\u9A8C\u5230\u54EA\u4E9B\u5E73\u53F0\u3001\u5DF2\u6838\u9A8C\u6765\u6E90\u4E2D\u6700\u4F4E\u7684\u662F\u54EA\u4E2A\u3001\u54EA\u4E9B\u5E73\u53F0\u6CA1\u6838\u9A8C\u5230\u4EE5\u53CA\u539F\u56E0\u3002");
  return lines.join("\n");
}
function travelProtocol(kind, options) {
  const hotel = kind === "hotel";
  const defaultIds = TRAVEL_PLATFORM_IDS;
  const platforms = options.platforms && options.platforms.length ? options.platforms : defaultIds;
  const memoryPlatforms = platforms.concat(options.source ? [options.source.platform] : []);
  const memoryBlock = memoryForPrompt(options.memory, memoryPlatforms);
  const lines = [
    discipline().replace("\u5546\u54C1\u9875", hotel ? "\u9152\u5E97\u9875" : "\u673A\u7968\u9875").replace("\u5546\u54C1\u9996\u5C4F", hotel ? "\u9152\u5E97\u9996\u5C4F" : "\u673A\u7968\u9996\u5C4F").replace("\u5546\u54C1\u4E3B\u5C4F", hotel ? "\u9152\u5E97\u4E3B\u5C4F" : "\u673A\u7968\u4E3B\u5C4F"),
    "",
    "\u3010\u5FC5\u987B\u6838\u5BF9\u7684\u6B63\u89C4\u6E20\u9053\u3011",
    hotel ? "- \u9152\u5E97\u5B98\u65B9 / \u8FDE\u9501\u5B98\u65B9\u3001\u643A\u7A0B\u81EA\u8425\u3001\u7F8E\u56E2\u81EA\u8425\u3001\u53BB\u54EA\u513F\u81EA\u8425\uFF1B\u7B2C\u4E09\u65B9\u4EE3\u7406\u3001\u65E0\u8D44\u8D28\u5C0F\u5E97\u4E0D\u8BB0\u5F55\u3002" : "- \u822A\u53F8\u5B98\u65B9 / \u822A\u53F8\u76F4\u8425\u3001\u643A\u7A0B\u81EA\u8425\u3001\u7F8E\u56E2\u81EA\u8425\u3001\u53BB\u54EA\u513F\u81EA\u8425\uFF1B\u7B2C\u4E09\u65B9\u4EE3\u7406\u3001\u65E0\u8D44\u8D28\u7968\u4EE3\u4E0D\u8BB0\u5F55\u3002",
    "",
    "\u3010" + (hotel ? "\u9152\u5E97" : "\u673A\u7968") + "\u6BD4\u4EF7\u53E3\u5F84\u3011",
    hotel ? "- \u5FC5\u987B\u662F\u540C\u4E00\u5BB6\u9152\u5E97\u3001\u540C\u4E00\u57CE\u5E02\u3001\u540C\u4E00\u5165\u4F4F/\u79BB\u5E97\u65E5\u671F\u3001\u540C\u4E00\u623F\u578B/\u5E8A\u578B/\u65E9\u9910/\u53D6\u6D88\u653F\u7B56\uFF1B\u623F\u578B\u6216\u65E5\u671F\u4E0D\u540C\u5C31\u5199 match=different + matchNote\uFF0C\u4E0D\u53C2\u4E0E\u6700\u4F4E\u4EF7\u3002" : "- \u5FC5\u987B\u662F\u540C\u4E00\u822A\u73ED\u53F7\u3001\u540C\u4E00\u65E5\u671F\u3001\u540C\u4E00\u51FA\u53D1/\u5230\u8FBE\u673A\u573A\u3001\u540C\u4E00\u8231\u4F4D\u3001\u540C\u6837\u884C\u674E\uFF1B\u822A\u73ED/\u65E5\u671F/\u8231\u4F4D/\u884C\u674E\u4E0D\u540C\u5C31\u5199 match=different + matchNote\uFF0C\u4E0D\u53C2\u4E0E\u6700\u4F4E\u4EF7\u3002",
    "- \u4EF7\u683C\u53EA\u770B\u9996\u5C4F\uFF0C\u9ED8\u8BA4\u4E0D\u4E0B\u6ED1\uFF1B\u9996\u5C4F\u6CA1\u6709\u4EF7\u683C\u624D\u5141\u8BB8 1 \u6B21 scroll\u3002\u6BCF\u4E2A\u5E73\u53F0\u6700\u591A\u7EA6 8 \u6B21 phone \u64CD\u4F5C\uFF0C\u8D85\u8FC7\u8BB0 missing \u7EE7\u7EED\u3002",
    "- App \u542F\u52A8/\u5E7F\u544A\uFF1A\u770B\u5230\u5173\u95ED/\u8DF3\u8FC7\u7ACB\u5373\u70B9\u4E00\u6B21\uFF1B2 \u79D2\u5185\u65E0\u53EF\u8BFB\u5185\u5BB9\u518D screen \u4E00\u6B21\uFF0C\u4E0D\u8981\u8FDE\u7EED screen \u7B49\u542F\u52A8\u3002\u77ED\u94FE/H5 \u5F15\u5BFC\u9875\u53EA\u70B9\u4E00\u6B21\u201C\u6253\u5F00 App\u201D\uFF1B2 \u79D2\u6CA1\u8DF3\u8F6C\u5C31\u76F4\u63A5 open \u5BF9\u5E94 App \u641C\u7D22\uFF0C\u4E0D\u8981\u505C\u5728 H5 \u7B49\u52A0\u8F7D\u3001\u6EDA\u9875\u9762\u6216\u70B9\u5E7F\u544A\u3002",
    "- \u6765\u6E90\u9996\u5C4F\u4FE1\u606F\u62FF\u5230\u5C31\u5199\u5E76\u7ACB\u523B\u5207\u4E0B\u4E00\u4E2A\u5E73\u53F0\uFF1B\u4E0D\u8981\u5728\u6765\u6E90\u9875\u7B49\u52A0\u8F7D/\u770B\u8BC4\u4EF7/\u9886\u5238\uFF0C\u72B9\u8C6B\u4F1A\u62D6\u6162\u6574\u573A\u3002",
    hotel ? "- \u8BB0\u5F55\u6BCF\u665A\u4EF7\u683C\u548C\u603B\u4EF7/\u7A0E\u8D39/\u670D\u52A1\u8D39/\u65E9\u9910/\u53D6\u6D88\u653F\u7B56\uFF1B\u4F1A\u5458\u4EF7\u53EA\u8BB0\u5F55\u9875\u9762\u660E\u786E\u663E\u793A\u4E14\u8BE5\u8D26\u53F7\u53EF\u7528\u7684\u3002" : "- \u8BB0\u5F55\u6BCF\u4EBA\u7968\u4EF7\u548C\u542B\u673A\u5EFA\u71C3\u6CB9\u7684\u603B\u4EF7\u3001\u8231\u4F4D\u3001\u884C\u674E\u3001\u9000\u6539\u89C4\u5219\uFF1B\u4F1A\u5458\u4EF7/\u9752\u5E74\u7968\u53EA\u8BB0\u5F55\u9875\u9762\u660E\u786E\u663E\u793A\u4E14\u53EF\u7528\u7684\u3002",
    "- price \u62FF\u4E0D\u5230\u5199 null\uFF0C\u4E0D\u4F30\u7B97\u3001\u4E0D\u6CBF\u7528\u65E7\u4EF7\uFF1B\u627E\u4E0D\u5230\u540C\u6B3E/\u540C\u623F\u578B/\u540C\u822A\u73ED\u5C31\u5199 missing \u539F\u56E0\u3002",
    "- \u4E0D\u80FD\u58F0\u79F0\u300C\u5168\u7F51\u6700\u4F4E\u300D\uFF0C\u53EA\u80FD\u58F0\u79F0\u300C\u5DF2\u6838\u9A8C\u6765\u6E90\u4E2D\u7684\u6700\u4F4E\u4EF7\u300D\u3002",
    "",
    "\u3010\u5B89\u5168\u8FB9\u754C\u3011",
    "- \u53EA\u8BFB\u4EF7\u683C\u3001\u623F\u578B/\u8231\u4F4D\u3001\u65E5\u671F\u3001\u7A0E\u8D39\u548C\u9000\u6539\u89C4\u5219\uFF1B\u4E0D\u63D0\u4EA4\u8BA2\u5355\u3001\u4E0D\u652F\u4ED8\u3001\u4E0D\u62C5\u4FDD\u3001\u4E0D\u52FE\u9009\u534F\u8BAE\u3002",
    "- \u9047\u5230\u767B\u5F55\u3001\u9A8C\u8BC1\u7801\u3001\u652F\u4ED8\u3001\u5B9E\u540D\u3001\u98CE\u63A7\u7ACB\u5373\u505C\u4E0B\uFF0CneedsUser=true \u5E76\u8BF4\u660E\u5361\u5728\u54EA\u4E00\u6B65\u3002",
    "",
    "\u3010\u6BD4\u4EF7\u65B9\u6CD5\uFF08\u4F18\u5148\u7167\u505A\uFF0C\u754C\u9762\u53D8\u5316\u65F6\u4EE5\u5B9E\u9645\u5C4F\u5E55\u4E3A\u51C6\uFF09\u3011",
    memoryBlock || "\uFF08\u6682\u65E0\u81EA\u5B9A\u4E49\u6BD4\u4EF7\u65B9\u6CD5\uFF0C\u6309\u4E0A\u9762\u7684\u6B63\u89C4\u6E20\u9053\u548C\u540C\u6761\u4EF6\u89C4\u5219\u6267\u884C\u3002\uFF09",
    "",
    "\u3010\u7ED3\u679C\u5199\u76D8\u3011",
    "\u5B8C\u6210\u540E\u7528 write \u628A\u7ED3\u679C\u5199\u5165 __RESULT_PATH__\uFF1A",
    hotel ? HOTEL_SCHEMA : FLIGHT_SCHEMA,
    "\u5982\u679C\u7ED9\u4E86\u6765\u6E90\u5E73\u53F0\uFF0Cchannels \u7684\u7B2C\u4E00\u6761\u5FC5\u987B\u662F\u6765\u6E90\u5E73\u53F0\u5F53\u524D\u9875\uFF1B\u5176\u4ED6\u5E73\u53F0\u6CA1\u67E5\u5230\u5199\u8FDB missing\u3002",
    "\u6700\u540E\u7528\u4E2D\u6587\u7B80\u77ED\u6C47\u62A5\uFF1A\u6838\u9A8C\u5230\u54EA\u4E9B\u5E73\u53F0\u3001\u540C\u6761\u4EF6\u6700\u4F4E\u662F\u54EA\u4E2A\u3001\u54EA\u4E9B\u6CA1\u6838\u9A8C\u5230\u53CA\u539F\u56E0\u3002"
  ];
  return lines.join("\n");
}
function buildComparePrompt(options) {
  let text;
  if (options.kind === "hotel") text = buildHotelPrompt(options);
  else if (options.kind === "flight") text = buildFlightPrompt(options);
  else text = buildProductPrompt(options);
  return finalizePrompt(text);
}
function buildProductPrompt(options) {
  const source = options.source && PLATFORM_MAP[options.source.platform] ? options.source : null;
  const platforms = (options.platforms && options.platforms.length ? options.platforms : PLATFORMS.map(function(p) {
    return p.id;
  })).filter(
    function(id) {
      return !source || id !== source.platform;
    }
  );
  const item = options.item || {};
  const lines = [
    "\u4F60\u5728 Android \u624B\u673A\u4E0A\u771F\u5B9E\u64CD\u4F5C\u7535\u5546 App\uFF0C\u4E3A\u540C\u4E00\u4EF6\u5546\u54C1\u505A\u8DE8\u5E73\u53F0\u6BD4\u4EF7\u3002\u53EA\u8BB0\u5F55\u4F60\u4EB2\u773C\u6838\u9A8C\u5230\u7684\u4FE1\u606F\uFF0C\u4E0D\u7F16\u9020\u4EF7\u683C\u3002",
    "",
    "\u5546\u54C1\uFF1A" + (str(options.title || item.title) || "\uFF08\u4EE5\u5F53\u524D\u5C4F\u5E55\u770B\u5230\u7684\u5546\u54C1\u4E3A\u51C6\uFF09"),
    "\u89C4\u683C\uFF1A" + (str(options.spec || item.spec) || "\u5F85\u786E\u8BA4\uFF0C\u5148\u8BFB\u5546\u54C1\u9875\u89C4\u683C")
  ];
  if (str(options.url)) lines.push("\u5DF2\u6709\u94FE\u63A5\uFF08\u53EA\u8BFB\uFF0C\u4E0D\u8981\u6253\u5F00\u5206\u4EAB\uFF09\uFF1A" + str(options.url));
  if (str(options.note)) lines.push("\u7528\u6237\u8865\u5145\u8981\u6C42\uFF1A" + str(options.note));
  if (source) {
    lines.push(
      "\u6765\u6E90\u9875\u9762\uFF1A\u5DF2\u5728" + PLATFORM_MAP[source.platform].name + "\u5546\u54C1\u9875\u6838\u9A8C" + (source.price != null ? "\uFF0C\u9875\u9762\u4EF7 \xA5" + source.price : "") + (source.store ? "\uFF0C\u5E97\u94FA " + source.store : "") + "\u3002\u672C\u6B21\u4E0D\u8981\u641C\u7D22\u6216\u91CD\u65B0\u6253\u5F00" + PLATFORM_MAP[source.platform].name + "\uFF0C\u76F4\u63A5\u628A\u8FD9\u4E00\u9875\u8BB0\u5F55\u4E3A\u6765\u6E90\u6E20\u9053\uFF08linkKind=current \u6216 product\uFF09\u3002"
    );
  }
  lines.push("\u672C\u6B21\u8981\u67E5\u7684\u5E73\u53F0\uFF1A" + (selectedPlatformNames(platforms) || "\u65E0\uFF08\u53EA\u8BB0\u5F55\u6765\u6E90\uFF09"));
  if (str(options.runId)) lines.push("\u672C\u6B21 runId\uFF1A" + str(options.runId) + "\uFF1B\u6BCF\u6B21\u5199\u7ED3\u679C\u90FD\u5FC5\u987B\u5E26\u4E0A\u540C\u4E00\u4E2A runId \u548C\u5F53\u524D writtenAt\u3002");
  lines.push("");
  lines.push("\u3010\u901F\u5EA6\u786C\u89C4\u5219\uFF08\u4F18\u5148\u7EA7\u9AD8\u4E8E\u9010\u6761\u5BFC\u822A\uFF09\u3011");
  lines.push("1. \u6765\u6E90\u5E73\u53F0\u5F53\u524D\u9875\u9996\u9009\uFF1A\u6807\u9898\u548C\u9996\u5C4F\u4EF7\u770B\u5230\u5C31\u5199\u6700\u5C0F\u6765\u6E90\uFF0C\u7ACB\u523B\u5207\u4E0B\u4E00\u4E2A\u5E73\u53F0\uFF1B\u4E0D\u8981\u4E3A\u4E86\u5E97\u94FA/\u5238/\u89C4\u683C/\u5B8C\u6574\u6807\u9898\u7B49\uFF0C\u4E0D\u8981\u8FDB\u8BE6\u60C5/\u8BC4\u4EF7/\u5238\u4E2D\u5FC3\u3002");
  lines.push("2. \u76EE\u6807\u5E73\u53F0\u6253\u5F00\u540E\u5148 screen\uFF1A\u5982\u679C\u505C\u5728\u522B\u7684\u578B\u53F7/\u4E0A\u6B21\u9875\u9762\uFF0C\u4E0D\u8981\u6838\u4EF7\uFF0C\u76F4\u63A5\u641C\u7D22\u76EE\u6807\u6B3E\uFF1B\u641C 1 \u6B21\u4ECD\u65E0\u540C\u6B3E\u5C31\u8BB0 missing \u8F6C\u4E0B\u4E00\u4E2A\u3002");
  lines.push("3. \u641C\u7D22\u7ED3\u679C\u53EA\u7528\u6765\u786E\u8BA4\u578B\u53F7/\u989C\u8272/\u5C3A\u7801\uFF1B\u4EF7\u683C\u5FC5\u987B\u8FDB\u540C\u6B3E\u5546\u54C1\u9875\u770B\u9996\u5C4F\u3002\u4E0D\u540C\u6B3E\u4E0D\u70B9\u8FDB\u53BB\u5F53\u4E3B\u6E20\u9053\u3002");
  lines.push("4. App \u542F\u52A8/\u5E7F\u544A\uFF1A\u770B\u5230\u5173\u95ED/\u8DF3\u8FC7\u7ACB\u5373\u70B9\u4E00\u6B21\uFF1B2 \u79D2\u5185\u65E0\u53EF\u8BFB\u5185\u5BB9\u518D screen \u4E00\u6B21\uFF0C\u4E0D\u8981\u8FDE\u7EED\u7B49\u542F\u52A8\u3002");
  lines.push("5. screen \u6587\u672C\u4F18\u5148\uFF1B\u6587\u672C\u8BFB\u4E0D\u5230\u4EF7\u683C\u624D image\uFF0C\u6700\u591A 2 \u6B21\uFF1B\u4E0D\u8981\u7528 tap_xy \u731C\u3002");
  lines.push("6. \u6BCF\u4E2A\u5E73\u53F0\u8F6F\u9884\u7B97 6 \u6B21\u3001\u786C\u4E0A\u9650 8 \u6B21 phone \u64CD\u4F5C\uFF1B\u5230 8 \u6B21\u65E0\u8BBA\u6709\u6CA1\u6709\u4EF7\u90FD\u5199 missing \u8F6C\u4E0B\u4E00\u4E2A\u3002");
  lines.push("7. \u7B2C\u4E00\u6B21 write \u524D\u5148 read \u4E00\u6B21\u7ED3\u679C\u6587\u4EF6\uFF1B\u4E4B\u540E\u6BCF\u5E73\u53F0\u53EA\u66F4\u65B0\u4E00\u6B21\uFF1B\u4E0D\u8981\u7528 bash \u9A8C\u8BC1\u3002");
  lines.push("");
  lines.push("\u6B65\u9AA4\uFF1A");
  lines.push("1. \u5148\u8BFB\u5F53\u524D\u5C4F\u5E55\uFF1B\u5982\u679C\u5DF2\u7ECF\u5728\u6765\u6E90\u5E73\u53F0\u5546\u54C1\u9875\uFF0C\u6700\u591A\u6EDA\u52A8 1 \u6B21\u627E\u6807\u9898/\u4EF7\u683C\uFF0C\u7136\u540E\u7ACB\u523B\u5199\u4E00\u6B21 agent-results.json\uFF08\u6765\u6E90\u6E20\u9053 + partial:true\uFF09\u3002\u5E97\u94FA\u7C7B\u578B/\u89C4\u683C/\u5238\u770B\u4E0D\u5230\u5C31\u7559\u7A7A\uFF0C\u4E0D\u8981\u8FDB\u5E97\u94FA\u9875/\u8BC4\u4EF7/\u8BE6\u60C5/\u5238\u4E2D\u5FC3\u786E\u8BA4\u3002");
  lines.push("2. \u6309\u987A\u5E8F\u5904\u7406\u76EE\u6807\u5E73\u53F0\uFF1B\u6BCF\u4E2A App \u53EA\u8FDB\u5165\u4E00\u6B21\u3002\u641C\u7D22\u540C\u6B3E \u2192 \u5148\u5728\u7ED3\u679C\u9875\u6838\u5BF9\u578B\u53F7/BOA/\u989C\u8272/\u5C3A\u7801\uFF0C\u4E0D\u540C\u6B3E\u4E0D\u70B9\u8FDB\u53BB\u5F53\u4E3B\u6E20\u9053 \u2192 \u8BA4\u51C6\u6B63\u54C1\u6E20\u9053 \u2192 \u8FDB\u540C\u6B3E\u5546\u54C1\u9875\u770B\u9996\u5C4F\u4EF7\u4E0E\u989C\u8272/\u6B3E\u5F0F \u2192 \u8BB0\u5F55\u6570\u636E\u548C\u5F53\u524D\u65F6\u95F4 \u2192 \u7ACB\u523B\u66F4\u65B0 __RESULT_PATH__ \u2192 \u79BB\u5F00\uFF0C\u4E0D\u56DE\u5934\u3002\u9996\u5C4F\u4EF7\u9ED8\u8BA4\u4E0D\u4E0B\u6ED1\uFF1B\u9996\u5C4F\u6CA1\u4EF7\u624D 1 \u6B21 scroll\u3002\u6BCF\u4E2A\u5E73\u53F0\u6700\u591A\u7EA6 8 \u6B21\u64CD\u4F5C\u3002");
  lines.push(firstWriteBlock());
  lines.push("3. \u4E0D\u70B9\u5206\u4EAB\u3001\u4E0D\u590D\u5236\u94FE\u63A5\u3001\u4E0D\u52A0\u8D2D\u7269\u8F66\u3001\u4E0D\u4E0B\u5355\u3002\u94FE\u63A5\u53EA\u5728\u9875\u9762\u76F4\u63A5\u53EF\u89C1\u65F6\u987A\u4FBF\u8BB0\u5F55\uFF0C\u770B\u4E0D\u5230\u5C31\u7559\u7A7A\u3002");
  lines.push("4. \u6240\u6709\u76EE\u6807\u5E73\u53F0\u5904\u7406\u5B8C\u540E\u5199\u6700\u540E\u4E00\u6B21\u5B8C\u6574\u7ED3\u679C\uFF08partial:false\uFF09\uFF0C\u7ED3\u675F\u4EFB\u52A1\u3002");
  lines.push("");
  lines.push(productProtocol({ memory: options.memory, platforms, autoCoupon: options.autoCoupon, source }));
  return lines.join("\n");
}
function buildHotelPrompt(options) {
  const source = options.source && PLATFORM_MAP[options.source.platform] ? options.source : null;
  const platforms = (options.platforms && options.platforms.length ? options.platforms : TRAVEL_PLATFORM_IDS).filter(function(id) {
    return !source || id !== source.platform;
  });
  const item = options.item || {};
  const lines = [
    "\u4F60\u5728 Android \u624B\u673A\u4E0A\u771F\u5B9E\u64CD\u4F5C\u9152\u5E97\u9884\u8BA2 App\uFF0C\u4E3A\u540C\u4E00\u5BB6\u9152\u5E97\u3001\u540C\u4E00\u5165\u4F4F\u65E5\u671F\u3001\u540C\u4E00\u623F\u578B\u505A\u6BD4\u4EF7\u3002\u53EA\u8BB0\u5F55\u4F60\u4EB2\u773C\u6838\u9A8C\u5230\u7684\u4FE1\u606F\uFF0C\u4E0D\u7F16\u9020\u4EF7\u683C\u3002",
    "",
    "\u9152\u5E97\uFF1A" + (str(item.hotelName || options.title) || "\uFF08\u4EE5\u5F53\u524D\u5C4F\u5E55\u4E3A\u51C6\uFF09"),
    "\u57CE\u5E02\uFF1A" + (str(item.city) || "\u5F85\u786E\u8BA4"),
    "\u5165\u4F4F / \u79BB\u5E97\uFF1A" + (str(item.checkIn) || "\u5F85\u786E\u8BA4") + " \u2192 " + (str(item.checkOut) || "\u5F85\u786E\u8BA4") + (item.nights ? "\uFF08" + item.nights + " \u665A\uFF09" : ""),
    "\u623F\u578B\u53E3\u5F84\uFF1A" + (item.rateMode === "specific" ? "\u6307\u5B9A\u623F\u578B" : "\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\uFF08\u672A\u660E\u786E\u6253\u5F00\u67D0\u623F\u578B\u65F6\uFF09"),
    "\u623F\u578B\uFF1A" + (str(item.roomType) || (item.rateMode === "specific" ? "\u5F85\u786E\u8BA4" : "\u4EE5\u5404\u5E73\u53F0\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\u4E3A\u51C6")) + "\uFF1B\u5E8A\u578B\uFF1A" + (str(item.bedType) || "\u5F85\u786E\u8BA4") + "\uFF1B\u65E9\u9910\uFF1A" + (str(item.breakfast) || "\u5F85\u786E\u8BA4") + "\uFF1B\u53D6\u6D88\uFF1A" + (str(item.cancelPolicy) || "\u5F85\u786E\u8BA4"),
    "\u4EBA\u6570\uFF1A" + (str(item.guests) || "2 \u4EBA")
  ];
  if (str(options.note)) lines.push("\u7528\u6237\u8865\u5145\u8981\u6C42\uFF1A" + str(options.note));
  if (source) {
    lines.push(
      "\u6765\u6E90\u9875\u9762\uFF1A\u5DF2\u5728" + PLATFORM_MAP[source.platform].name + "\u9152\u5E97\u9875\u6838\u9A8C" + (source.price != null ? "\uFF0C\u9875\u9762\u4EF7 \xA5" + source.price : "") + "\u3002\u672C\u6B21\u4E0D\u8981\u641C\u7D22\u6216\u91CD\u65B0\u6253\u5F00" + PLATFORM_MAP[source.platform].name + "\uFF0C\u76F4\u63A5\u628A\u8FD9\u4E00\u9875\u8BB0\u5F55\u4E3A\u6765\u6E90\u6E20\u9053\u3002"
    );
  }
  lines.push("\u672C\u6B21\u8981\u67E5\u7684\u5E73\u53F0\uFF1A" + (selectedPlatformNames(platforms) || "\u65E0\uFF08\u53EA\u8BB0\u5F55\u6765\u6E90\uFF09"));
  if (str(options.runId)) lines.push("\u672C\u6B21 runId\uFF1A" + str(options.runId) + "\uFF1B\u6BCF\u6B21\u5199\u7ED3\u679C\u90FD\u5FC5\u987B\u5E26\u4E0A\u540C\u4E00\u4E2A runId \u548C\u5F53\u524D writtenAt\u3002");
  lines.push("");
  lines.push("\u3010\u901F\u5EA6\u786C\u89C4\u5219\uFF08\u4F18\u5148\u7EA7\u9AD8\u4E8E\u9010\u6761\u5BFC\u822A\uFF09\u3011");
  lines.push("1. \u5148\u770B\u9875\u9762\u9876\u90E8\u65E5\u671F\u680F\u3002\u5165\u4F4F/\u79BB\u5E97\u4E0E\u76EE\u6807\u4E00\u81F4\uFF08\u5C24\u5176\u4ECA\u5929\u2192\u660E\u5929\uFF09\u65F6\uFF0C\u7EDD\u4E0D\u6253\u65E5\u671F\u9009\u62E9\u5668\uFF1B\u76F4\u63A5\u641C\u9152\u5E97\u3002\u65E5\u671F\u680F\u4E0D\u5BF9\u624D\u6539\uFF0C\u65E5\u671F\u9009\u62E9\u5668\u53EA\u8BD5 1 \u6B21\uFF1B\u6253\u5F00\u5230\u9519\u8BEF\u6708\u4EFD\u5C31\u5173\u95ED\uFF0C\u4E0D\u6EDA\u6708\u4EFD\u3001\u4E0D\u7528\u622A\u56FE\u627E\u5750\u6807\u3002");
  lines.push("2. \u641C\u7D22\u6846\u76F4\u63A5\u8F93\u5165\u5B8C\u6574\u9152\u5E97\u540D\uFF1B\u6709\u7ED3\u679C\u5C31\u4E0D\u6539\u57CE\u5E02\u3002\u53EA\u6709\u641C\u4E0D\u5230\u624D\u6539\u57CE\u5E02\u4E00\u6B21\u3002");
  lines.push("3. \u4EF7\u683C\u6309\u8FD9\u4E2A\u987A\u5E8F\u62FF\uFF1A\u9152\u5E97\u5217\u8868\u5361\u7247\u201C\xA5xxx\u8D77\u201D\u53EA\u4F5C\u7EBF\u7D22\uFF08\u9664\u975E\u660E\u786E\u540C\u9152\u5E97/\u540C\u65E5\u671F/\u540C\u623F\u578B/\u542B\u7A0E\uFF09\uFF0C\u8FDB\u9152\u5E97\u8BE6\u60C5\u7528\u9996\u5C4F\u6216\u623F\u578B\u5217\u8868\u7B2C\u4E00\u884C\u786E\u8BA4 \u2192 \u624D\u9700\u8981\u201C\u67E5\u770B\u623F\u578B\u201D\u3002\u4E0D\u6253\u5F00\u5177\u4F53\u623F\u578B\u8BE6\u60C5\u3001\u4E0D\u7B5B\u9009\u3001\u4E0D\u770B\u8BC4\u4EF7\u3001\u4E0D\u8FDB\u5238\u4E2D\u5FC3\u3002");
  lines.push("4. \u643A\u7A0B\uFF1A\u9152\u5E97\u2192\u641C\u7D22\u9152\u5E97\u540D\u2192\u9152\u5E97\u8BE6\u60C5\u2192\u67E5\u770B\u623F\u578B\u2192\u7B2C\u4E00\u884C\uFF1B\u7F8E\u56E2\uFF1A\u9152\u5E97/\u6C11\u5BBF\u2192\u641C\u7D22\u9152\u5E97\u540D\u2192\u8BE6\u60C5\u9996\u5C4F\uFF08\u6CA1\u4EF7\u624D 1 \u6EDA\uFF09\uFF1B\u53BB\u54EA\u513F\uFF1A\u9152\u5E97\u2192\u641C\u7D22\u9152\u5E97\u540D\u2192\u8BE6\u60C5\u9996\u5C4F\u623F\u578B\u7B2C\u4E00\u884C\u3002");
  lines.push("5. screen \u6587\u672C\u4F18\u5148\uFF1B\u6587\u672C\u8BFB\u4E0D\u5230\u4EF7\u683C\u624D image\uFF0C\u6700\u591A 2 \u6B21\uFF1B\u65E5\u671F\u9009\u62E9\u5668\u4E0D\u8981\u622A\u56FE\u627E\u5750\u6807\u3002");
  lines.push("6. \u6BCF\u4E2A\u5E73\u53F0\u8F6F\u9884\u7B97 6 \u6B21\u3001\u786C\u4E0A\u9650 8 \u6B21 phone \u64CD\u4F5C\uFF1B\u5230 8 \u6B21\u65E0\u8BBA\u6709\u6CA1\u6709\u4EF7\u90FD\u5199 missing \u8F6C\u4E0B\u4E00\u4E2A\uFF0C\u4E0D\u604B\u6218\u3002");
  lines.push("7. \u7B2C\u4E00\u6B21 write \u524D\u5148 read \u4E00\u6B21\u7ED3\u679C\u6587\u4EF6\uFF1B\u4E4B\u540E\u6BCF\u5E73\u53F0\u53EA\u66F4\u65B0\u4E00\u6B21\uFF1B\u4E0D\u8981\u7528 bash \u9A8C\u8BC1\u3002\u542F\u52A8\u6743\u9650\u5F39\u7A97\u70B9\u201C\u59CB\u7EC8\u5141\u8BB8\u201D\uFF0C\u5C4F\u5E55\u8FC7\u671F\u5C31\u91CD\u65B0 screen \u518D\u70B9\u3002");
  lines.push("8. \u6253\u5F00\u76EE\u6807 App \u540E\u5148 screen\uFF1B\u5982\u679C\u5DF2\u7ECF\u5728\u8BE5\u9152\u5E97/\u623F\u578B\u9875\uFF0C\u76F4\u63A5\u7528\u5F53\u524D\u9875\uFF0C\u4E0D\u5F3A\u5236\u56DE\u9996\u9875\u91CD\u641C\u3002\u542F\u52A8\u5E7F\u544A/\u66F4\u65B0\u5F39\u7A97\u7ACB\u5373\u5173\u95ED\uFF0C\u4E0D\u505C\u7559\u3002");
  lines.push("");
  lines.push("\u6B65\u9AA4\uFF1A");
  lines.push("1. \u5148\u8BFB\u5F53\u524D\u5C4F\uFF1B\u5982\u679C\u5DF2\u7ECF\u5728\u6765\u6E90\u5E73\u53F0\u9152\u5E97\u9875\uFF0C\u6700\u591A\u6EDA\u52A8 1 \u6B21\u627E\u9152\u5E97\u540D/\u65E5\u671F/\u623F\u578B/\u9996\u5C4F\u4EF7\uFF0C\u7136\u540E\u7ACB\u523B\u5199\u4E00\u6B21 agent-results.json\uFF08\u6765\u6E90\u6E20\u9053 + partial:true\uFF09\u3002\u770B\u4E0D\u5230\u7684\u5E8A\u578B/\u65E9\u9910/\u53D6\u6D88\u653F\u7B56\u7559\u7A7A\uFF0C\u4E0D\u8FDB\u8BE6\u60C5\u9875/\u8BC4\u4EF7\u9875/\u5238\u4E2D\u5FC3\u786E\u8BA4\u3002");
  lines.push("2. \u6309\u987A\u5E8F\u5904\u7406\u76EE\u6807\u5E73\u53F0\uFF1B\u6BCF\u4E2A App \u53EA\u8FDB\u4E00\u6B21\u3002\u643A\u7A0B\uFF1A\u9152\u5E97 \u2192 \u76EE\u7684\u5730/\u65E5\u671F \u2192 \u641C\u9152\u5E97 \u2192 \u9152\u5E97\u9875\u623F\u578B/\u65E5\u5386\uFF1B\u7F8E\u56E2\uFF1A\u9152\u5E97/\u6C11\u5BBF \u2192 \u76EE\u7684\u5730/\u65E5\u671F \u2192 \u641C\u9152\u5E97 \u2192 \u9152\u5E97\u9875\u623F\u578B/\u65E5\u5386\uFF1B\u53BB\u54EA\u513F\uFF1A\u9152\u5E97 \u2192 \u76EE\u7684\u5730/\u65E5\u671F \u2192 \u641C\u9152\u5E97 \u2192 \u9152\u5E97\u9875\u623F\u578B/\u65E5\u5386\u3002");
  lines.push("3. \u9ED8\u8BA4\u627E\u201C\u6700\u4F4E\u4EF7\u65E5\u5386\u623F/\u5F53\u65E5\u6700\u4F4E\u53EF\u8BA2\u623F\u201D\uFF0C\u4E0D\u662F\u9875\u9762\u9ED8\u8BA4\u5C55\u793A\u7684\u7B2C\u4E00\u5F20\u9AD8\u4EF7\u623F\uFF1B\u5982\u679C\u7528\u6237\u660E\u786E\u6253\u5F00\u4E86\u67D0\u4E2A\u623F\u578B/\u4EF7\u683C\u8BA1\u5212\uFF0C\u624D\u6309\u6307\u5B9A\u623F\u578B\u3002\u6BCF\u4E2A\u5E73\u53F0\u8BB0\u5F55\u6700\u4F4E\u65E5\u5386\u623F\u7684\u623F\u578B/\u5E8A\u578B/\u65E9\u9910/\u53D6\u6D88\u653F\u7B56/\u7A0E\u8D39/\u6BCF\u665A\u4EF7\uFF1B\u5982\u679C\u6700\u4F4E\u623F\u578B\u4E0E\u6765\u6E90\u4E0D\u540C\uFF0C\u518D\u5C1D\u8BD5\u627E\u540C\u623F\u578B\u6700\u4F4E\u4EF7\u4F5C\u4E3A\u540C\u6761\u4EF6\u53C2\u8003\u3002");
  lines.push("4. \u65E9\u9910\u3001\u53D6\u6D88\u653F\u7B56\u3001\u623F\u578B\u5C3D\u91CF\u4E0E\u6765\u6E90\u4E00\u81F4\uFF1B\u4E0D\u4E00\u81F4\u5199 match=close\uFF08\u540C\u623F\u578B\u4F46\u65E9\u9910/\u53D6\u6D88\u4E0D\u540C\uFF09\u6216 match=different\uFF08\u623F\u578B\u4E0D\u540C\uFF09+ matchNote\uFF0C\u4EF7\u683C\u7167\u8BB0\uFF0C\u4F46\u6700\u4F4E\u4EF7\u7ED3\u8BBA\u8981\u6807\u660E\u6761\u4EF6\u5DEE\u5F02\u3002");
  lines.push("5. \u9996\u5C4F\u4EF7\u9ED8\u8BA4\u4E0D\u4E0B\u6ED1\uFF1B\u9996\u5C4F\u6CA1\u4EF7\u624D 1 \u6B21 scroll\uFF1B\u6BCF\u4E2A\u5E73\u53F0\u6700\u591A\u7EA6 8 \u6B21\u64CD\u4F5C\u3002");
  lines.push(travelFirstWriteBlock("hotel"));
  lines.push("6. \u4E0D\u70B9\u5206\u4EAB\u3001\u4E0D\u590D\u5236\u94FE\u63A5\u3001\u4E0D\u63D0\u4EA4\u8BA2\u5355\u3001\u4E0D\u652F\u4ED8\u3001\u4E0D\u52FE\u9009\u62C5\u4FDD/\u534F\u8BAE\u3002");
  lines.push("7. \u6240\u6709\u5E73\u53F0\u5904\u7406\u5B8C\u540E\u5199\u6700\u540E\u4E00\u6B21\u5B8C\u6574\u7ED3\u679C\uFF08partial:false\uFF09\u3002");
  lines.push("");
  lines.push(travelProtocol("hotel", { memory: options.memory, platforms, source }));
  return lines.join("\n");
}
function buildFlightPrompt(options) {
  const source = options.source && PLATFORM_MAP[options.source.platform] ? options.source : null;
  const platforms = (options.platforms && options.platforms.length ? options.platforms : TRAVEL_PLATFORM_IDS).filter(function(id) {
    return !source || id !== source.platform;
  });
  const item = options.item || {};
  const lines = [
    "\u4F60\u5728 Android \u624B\u673A\u4E0A\u771F\u5B9E\u64CD\u4F5C\u673A\u7968\u9884\u8BA2 App\uFF0C\u4E3A\u540C\u4E00\u822A\u73ED\u3001\u540C\u4E00\u65E5\u671F\u3001\u540C\u4E00\u8231\u4F4D\u505A\u6BD4\u4EF7\u3002\u53EA\u8BB0\u5F55\u4F60\u4EB2\u773C\u6838\u9A8C\u5230\u7684\u4FE1\u606F\uFF0C\u4E0D\u7F16\u9020\u4EF7\u683C\u3002",
    "",
    "\u822A\u73ED\uFF1A" + ([str(item.airline), str(item.flightNo)].filter(Boolean).join(" ") || "\uFF08\u4EE5\u5F53\u524D\u5C4F\u5E55\u4E3A\u51C6\uFF09"),
    "\u65E5\u671F\uFF1A" + (str(item.date) || "\u5F85\u786E\u8BA4"),
    "\u822A\u7EBF\uFF1A" + (str(item.from) || "\u5F85\u786E\u8BA4") + " \u2192 " + (str(item.to) || "\u5F85\u786E\u8BA4"),
    "\u65F6\u95F4\uFF1A" + (str(item.depTime) || "\u2014") + " \u2192 " + (str(item.arrTime) || "\u2014"),
    "\u8231\u4F4D\uFF1A" + (str(item.cabin) || "\u7ECF\u6D4E\u8231") + "\uFF1B\u4EBA\u6570\uFF1A" + (str(item.passengers) || "1 \u4EBA")
  ];
  if (str(options.note)) lines.push("\u7528\u6237\u8865\u5145\u8981\u6C42\uFF1A" + str(options.note));
  if (source) {
    lines.push(
      "\u6765\u6E90\u9875\u9762\uFF1A\u5DF2\u5728" + PLATFORM_MAP[source.platform].name + "\u673A\u7968\u9875\u6838\u9A8C" + (source.price != null ? "\uFF0C\u9875\u9762\u4EF7 \xA5" + source.price : "") + "\u3002\u672C\u6B21\u4E0D\u8981\u641C\u7D22\u6216\u91CD\u65B0\u6253\u5F00" + PLATFORM_MAP[source.platform].name + "\uFF0C\u76F4\u63A5\u628A\u8FD9\u4E00\u9875\u8BB0\u5F55\u4E3A\u6765\u6E90\u6E20\u9053\u3002"
    );
  }
  lines.push("\u672C\u6B21\u8981\u67E5\u7684\u5E73\u53F0\uFF1A" + (selectedPlatformNames(platforms) || "\u65E0\uFF08\u53EA\u8BB0\u5F55\u6765\u6E90\uFF09"));
  if (str(options.runId)) lines.push("\u672C\u6B21 runId\uFF1A" + str(options.runId) + "\uFF1B\u6BCF\u6B21\u5199\u7ED3\u679C\u90FD\u5FC5\u987B\u5E26\u4E0A\u540C\u4E00\u4E2A runId \u548C\u5F53\u524D writtenAt\u3002");
  lines.push("");
  lines.push("\u3010\u901F\u5EA6\u786C\u89C4\u5219\uFF08\u4F18\u5148\u7EA7\u9AD8\u4E8E\u9010\u6761\u5BFC\u822A\uFF09\u3011");
  lines.push("1. \u5148\u770B\u9875\u9762\u9876\u90E8\u65E5\u671F\u680F\u3002\u5165\u4F4F/\u79BB\u5E97\u4E0E\u76EE\u6807\u4E00\u81F4\uFF08\u5C24\u5176\u4ECA\u5929\u2192\u660E\u5929\uFF09\u65F6\uFF0C\u7EDD\u4E0D\u6253\u65E5\u671F\u9009\u62E9\u5668\uFF1B\u76F4\u63A5\u641C\u9152\u5E97\u3002\u65E5\u671F\u680F\u4E0D\u5BF9\u624D\u6539\uFF0C\u65E5\u671F\u9009\u62E9\u5668\u53EA\u8BD5 1 \u6B21\uFF1B\u6253\u5F00\u5230\u9519\u8BEF\u6708\u4EFD\u5C31\u5173\u95ED\uFF0C\u4E0D\u6EDA\u6708\u4EFD\u3001\u4E0D\u7528\u622A\u56FE\u627E\u5750\u6807\u3002");
  lines.push("2. \u641C\u7D22\u6846\u76F4\u63A5\u8F93\u5165\u5B8C\u6574\u9152\u5E97\u540D\uFF1B\u6709\u7ED3\u679C\u5C31\u4E0D\u6539\u57CE\u5E02\u3002\u53EA\u6709\u641C\u4E0D\u5230\u624D\u6539\u57CE\u5E02\u4E00\u6B21\u3002");
  lines.push("3. \u4EF7\u683C\u6309\u8FD9\u4E2A\u987A\u5E8F\u62FF\uFF1A\u9152\u5E97\u5217\u8868\u5361\u7247\u201C\xA5xxx\u8D77\u201D\u53EA\u4F5C\u7EBF\u7D22\uFF08\u9664\u975E\u660E\u786E\u540C\u9152\u5E97/\u540C\u65E5\u671F/\u540C\u623F\u578B/\u542B\u7A0E\uFF09\uFF0C\u8FDB\u9152\u5E97\u8BE6\u60C5\u7528\u9996\u5C4F\u6216\u623F\u578B\u5217\u8868\u7B2C\u4E00\u884C\u786E\u8BA4 \u2192 \u624D\u9700\u8981\u201C\u67E5\u770B\u623F\u578B\u201D\u3002\u4E0D\u6253\u5F00\u5177\u4F53\u623F\u578B\u8BE6\u60C5\u3001\u4E0D\u7B5B\u9009\u3001\u4E0D\u770B\u8BC4\u4EF7\u3001\u4E0D\u8FDB\u5238\u4E2D\u5FC3\u3002");
  lines.push("4. \u643A\u7A0B\uFF1A\u9152\u5E97\u2192\u641C\u7D22\u9152\u5E97\u540D\u2192\u9152\u5E97\u8BE6\u60C5\u2192\u67E5\u770B\u623F\u578B\u2192\u7B2C\u4E00\u884C\uFF1B\u7F8E\u56E2\uFF1A\u9152\u5E97/\u6C11\u5BBF\u2192\u641C\u7D22\u9152\u5E97\u540D\u2192\u8BE6\u60C5\u9996\u5C4F\uFF08\u6CA1\u4EF7\u624D 1 \u6EDA\uFF09\uFF1B\u53BB\u54EA\u513F\uFF1A\u9152\u5E97\u2192\u641C\u7D22\u9152\u5E97\u540D\u2192\u8BE6\u60C5\u9996\u5C4F\u623F\u578B\u7B2C\u4E00\u884C\u3002");
  lines.push("5. screen \u6587\u672C\u4F18\u5148\uFF1B\u6587\u672C\u8BFB\u4E0D\u5230\u4EF7\u683C\u624D image\uFF0C\u6700\u591A 2 \u6B21\uFF1B\u65E5\u671F\u9009\u62E9\u5668\u4E0D\u8981\u622A\u56FE\u627E\u5750\u6807\u3002");
  lines.push("6. \u6BCF\u4E2A\u5E73\u53F0\u8F6F\u9884\u7B97 6 \u6B21\u3001\u786C\u4E0A\u9650 8 \u6B21 phone \u64CD\u4F5C\uFF1B\u5230 8 \u6B21\u65E0\u8BBA\u6709\u6CA1\u6709\u4EF7\u90FD\u5199 missing \u8F6C\u4E0B\u4E00\u4E2A\uFF0C\u4E0D\u604B\u6218\u3002");
  lines.push("7. \u7B2C\u4E00\u6B21 write \u524D\u5148 read \u4E00\u6B21\u7ED3\u679C\u6587\u4EF6\uFF1B\u4E4B\u540E\u6BCF\u5E73\u53F0\u53EA\u66F4\u65B0\u4E00\u6B21\uFF1B\u4E0D\u8981\u7528 bash \u9A8C\u8BC1\u3002\u542F\u52A8\u6743\u9650\u5F39\u7A97\u70B9\u201C\u59CB\u7EC8\u5141\u8BB8\u201D\uFF0C\u5C4F\u5E55\u8FC7\u671F\u5C31\u91CD\u65B0 screen \u518D\u70B9\u3002");
  lines.push("8. \u6253\u5F00\u76EE\u6807 App \u540E\u5148 screen\uFF1B\u5982\u679C\u5DF2\u7ECF\u5728\u8BE5\u9152\u5E97/\u623F\u578B\u9875\uFF0C\u76F4\u63A5\u7528\u5F53\u524D\u9875\uFF0C\u4E0D\u5F3A\u5236\u56DE\u9996\u9875\u91CD\u641C\u3002\u542F\u52A8\u5E7F\u544A/\u66F4\u65B0\u5F39\u7A97\u7ACB\u5373\u5173\u95ED\uFF0C\u4E0D\u505C\u7559\u3002");
  lines.push("");
  lines.push("\u6B65\u9AA4\uFF1A");
  lines.push("1. \u5148\u8BFB\u5F53\u524D\u5C4F\uFF1B\u5982\u679C\u5DF2\u7ECF\u5728\u6765\u6E90\u5E73\u53F0\u673A\u7968\u9875\uFF0C\u6700\u591A\u6EDA\u52A8 1 \u6B21\u627E\u822A\u73ED\u53F7/\u65E5\u671F/\u822A\u7EBF/\u8231\u4F4D/\u9996\u5C4F\u4EF7\uFF0C\u7136\u540E\u7ACB\u523B\u5199\u4E00\u6B21 agent-results.json\uFF08\u6765\u6E90\u6E20\u9053 + partial:true\uFF09\u3002\u884C\u674E/\u9000\u6539\u770B\u4E0D\u5230\u5C31\u7559\u7A7A\uFF0C\u4E0D\u8FDB\u8BE6\u60C5\u9875/\u5238\u4E2D\u5FC3\u786E\u8BA4\u3002");
  lines.push("2. \u6309\u987A\u5E8F\u5904\u7406\u76EE\u6807\u5E73\u53F0\uFF1B\u6BCF\u4E2A App \u53EA\u8FDB\u4E00\u6B21\u3002\u641C\u7D22\u540C\u822A\u73ED\u53F7 + \u540C\u65E5\u671F \u2192 \u6838\u5BF9\u822A\u53F8/\u822A\u7EBF/\u8231\u4F4D/\u884C\u674E \u2192 \u770B\u9996\u5C4F\u7968\u4EF7\u548C\u7A0E\u8D39 \u2192 \u8BB0\u5F55\u5E76\u7ACB\u523B\u66F4\u65B0 __RESULT_PATH__ \u2192 \u79BB\u5F00\u3002\u9996\u5C4F\u4EF7\u9ED8\u8BA4\u4E0D\u4E0B\u6ED1\uFF1B\u9996\u5C4F\u6CA1\u4EF7\u624D 1 \u6B21 scroll\u3002\u6BCF\u4E2A\u5E73\u53F0\u6700\u591A\u7EA6 8 \u6B21\u64CD\u4F5C\u3002");
  lines.push(travelFirstWriteBlock("flight"));
  lines.push("3. \u4E0D\u70B9\u5206\u4EAB\u3001\u4E0D\u590D\u5236\u94FE\u63A5\u3001\u4E0D\u63D0\u4EA4\u8BA2\u5355\u3001\u4E0D\u652F\u4ED8\u3001\u4E0D\u52FE\u9009\u534F\u8BAE\u3002");
  lines.push("4. \u6240\u6709\u5E73\u53F0\u5904\u7406\u5B8C\u540E\u5199\u6700\u540E\u4E00\u6B21\u5B8C\u6574\u7ED3\u679C\uFF08partial:false\uFF09\u3002");
  lines.push("");
  lines.push(travelProtocol("flight", { memory: options.memory, platforms, source }));
  return lines.join("\n");
}
function buildCompareNowActionPrompt(memory, settings) {
  const productIds = settings && Array.isArray(settings.platforms) && settings.platforms.length ? settings.platforms : PLATFORMS.map(function(p) {
    return p.id;
  });
  const travelIds = settings && Array.isArray(settings.travelPlatforms) && settings.travelPlatforms.length ? settings.travelPlatforms : TRAVEL_PLATFORM_IDS;
  const productTargets = selectedPlatformNames(productIds);
  const travelTargets = selectedPlatformNames(travelIds);
  const text = [
    "\u4F60\u5728 Android \u624B\u673A\u4E0A\u3002\u7528\u6237\u6B63\u5728\u67D0\u4E2A App \u7684\u8BE6\u60C5\u9875\uFF0C\u70B9\u4E86\u60AC\u6D6E\u6BD4\u4EF7\u5165\u53E3\u3002",
    "\u7B2C\u4E00\u6B65\uFF1A\u5148\u7528 mcp__phone__* \u8BFB\u5F53\u524D\u5C4F\u5E55\uFF0C\u5224\u65AD\u5F53\u524D\u662F\u5546\u54C1\u3001\u9152\u5E97\u8FD8\u662F\u673A\u7968\uFF0C\u4EE5\u53CA\u5F53\u524D App\u3001\u6807\u9898/\u9152\u5E97\u540D/\u822A\u73ED\u53F7\u3001\u65E5\u671F\u3001\u4EF7\u683C\u3002\u89C4\u683C\u3001\u5E97\u94FA\u3001\u5238\u53EA\u5728\u5F53\u524D\u5C4F\u76F4\u63A5\u53EF\u89C1\u65F6\u987A\u624B\u8BB0\uFF1B\u770B\u4E0D\u5230\u5C31\u7559\u7A7A\uFF0C\u4E0D\u8981\u4E3A\u4E86\u786E\u8BA4\u5B83\u4EEC\u6EDA\u52A8\u6216\u8FDB\u522B\u7684\u9875\u9762\u3002\u4E0D\u8981\u70B9\u5206\u4EAB\uFF0C\u4E0D\u8981\u590D\u5236\u94FE\u63A5\u3002",
    "\u5F53\u524D App \u7684\u5E73\u53F0\u5C31\u662F\u6765\u6E90\u5E73\u53F0\uFF1A\u628A\u8FD9\u4E00\u9875\u8BB0\u5F55\u4E3A\u6765\u6E90\u6E20\u9053\uFF0C\u7EDD\u5BF9\u4E0D\u8981\u518D\u641C\u7D22\u6216\u91CD\u65B0\u6253\u5F00\u8FD9\u4E2A\u5E73\u53F0\u3002",
    '\u5982\u679C\u5F53\u524D\u4E0D\u5728\u5546\u54C1/\u9152\u5E97/\u673A\u7968\u8BE6\u60C5\u9875\uFF0C\u4E0D\u8981\u4E71\u70B9\uFF1A\u7528 write \u628A {"kind":"price-compare","vertical":"product","sourcePlatform":"","needsUser":true,"channels":[],"missing":[],"note":"\u5F53\u524D\u4E0D\u5728\u8BE6\u60C5\u9875\uFF0C\u8BF7\u6253\u5F00\u5546\u54C1/\u9152\u5E97/\u673A\u7968\u540E\u91CD\u8BD5"} \u5199\u5165 __RESULT_PATH__\uFF0C\u7136\u540E\u7ED3\u675F\u3002',
    "",
    "\u3010\u5148\u5224\u65AD\u7C7B\u578B\uFF0C\u518D\u6309\u5BF9\u5E94\u6A21\u677F\u5199\u6765\u6E90\u3011",
    "A \u9152\u5E97\uFF1A\u9875\u9762\u6709\u9152\u5E97\u540D\u3001\u5165\u4F4F/\u79BB\u5E97\u3001\u623F\u578B\u3001\u623F\u4EF7 \u2192 vertical=hotel\uFF1B\u53EA\u67E5\u9152\u5E97/\u673A\u7968\u5E73\u53F0\uFF1A" + travelTargets + '\u3002\u9ED8\u8BA4\u6BD4\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\uFF08rateMode=lowest\uFF09\uFF1B\u53EA\u6709\u7528\u6237\u660E\u786E\u6253\u5F00\u4E86\u67D0\u4E2A\u623F\u578B/\u4EF7\u683C\u8BA1\u5212\u624D\u7528 rateMode=specific\u3002\u6A21\u677F\uFF1A{"kind":"price-compare","vertical":"hotel","title":"\u9152\u5E97\u540D","item":{"hotelName":"","city":"","checkIn":"","checkOut":"","nights":1,"rateMode":"lowest","roomType":"","guests":"2 \u4EBA"},"sourcePlatform":"\u5F53\u524D\u5E73\u53F0","partial":true,"runId":"\u4F60\u751F\u6210\u7684\u6807\u8BC6","writtenAt":"\u5F53\u524DISO\u65F6\u95F4","channels":[{"platform":"\u5F53\u524D\u5E73\u53F0","store":"","price":699,"priceUnit":"night","match":"same","verifiedAt":"\u5F53\u524DISO\u65F6\u95F4"}],"missing":[],"needsUser":false,"note":"\u6765\u6E90\u5DF2\u8BB0\u5F55"}',
    "B \u673A\u7968\uFF1A\u9875\u9762\u6709\u822A\u73ED\u53F7\u3001\u65E5\u671F\u3001\u822A\u7EBF\u3001\u8231\u4F4D\u3001\u7968\u4EF7 \u2192 vertical=flight\uFF1B\u53EA\u67E5\u9152\u5E97/\u673A\u7968\u5E73\u53F0\uFF1A" + travelTargets + '\u3002\u6A21\u677F\uFF1A{"kind":"price-compare","vertical":"flight","title":"\u822A\u53F8+\u822A\u73ED\u53F7","item":{"airline":"","flightNo":"","date":"","from":"","to":"","cabin":"\u7ECF\u6D4E\u8231","passengers":"1 \u4EBA"},"sourcePlatform":"\u5F53\u524D\u5E73\u53F0","partial":true,"runId":"\u4F60\u751F\u6210\u7684\u6807\u8BC6","writtenAt":"\u5F53\u524DISO\u65F6\u95F4","channels":[{"platform":"\u5F53\u524D\u5E73\u53F0","store":"","price":699,"priceUnit":"ticket","match":"same","verifiedAt":"\u5F53\u524DISO\u65F6\u95F4"}],"missing":[],"needsUser":false,"note":"\u6765\u6E90\u5DF2\u8BB0\u5F55"}',
    "C \u5546\u54C1\uFF1A\u9875\u9762\u6709\u5546\u54C1\u6807\u9898\u3001\u89C4\u683C\u3001\u5230\u624B\u4EF7 \u2192 vertical=product\uFF1B\u53EA\u67E5\u5546\u54C1\u5E73\u53F0\uFF1A" + productTargets + '\u3002\u6A21\u677F\uFF1A{"kind":"price-compare","vertical":"product","title":"\u5546\u54C1\u540D","spec":"","sourcePlatform":"\u5F53\u524D\u5E73\u53F0","partial":true,"runId":"\u4F60\u751F\u6210\u7684\u6807\u8BC6","writtenAt":"\u5F53\u524DISO\u65F6\u95F4","channels":[{"platform":"\u5F53\u524D\u5E73\u53F0","store":"","price":199,"match":"same","verifiedAt":"\u5F53\u524DISO\u65F6\u95F4"}],"missing":[],"needsUser":false,"note":"\u6765\u6E90\u5DF2\u8BB0\u5F55"}',
    "\u53EA\u5199\u5FC5\u8981\u5B57\u6BB5\uFF1B\u4E0D\u8981\u590D\u5236 previousResults/\u65E7 channels/\u7A7A\u6570\u7EC4\uFF1B\u5199\u6210\u529F\u7ACB\u523B open \u4E0B\u4E00\u4E2A\u5E73\u53F0\u3002",
    "",
    firstWriteBlockGeneric(),
    "",
    "\u5199\u5B8C\u6765\u6E90\u540E\uFF0C\u6309\u7C7B\u578B\u53EA\u67E5\u5BF9\u5E94\u5E73\u53F0\uFF0C\u5F53\u524D App \u7684\u5E73\u53F0\u8DF3\u8FC7\uFF0C\u4E0D\u91CD\u590D\u641C\u7D22\uFF1B\u6BCF\u4E2A App \u53EA\u8FDB\u4E00\u6B21\uFF0C\u6BCF\u67E5\u5B8C\u4E00\u4E2A\u5C31\u66F4\u65B0\u4E00\u6B21 __RESULT_PATH__\u3002",
    "\u3010\u53EF\u9009\u6D41\u6C34\u7EBF\u3011\u6765\u6E90\u9996\u5C4F\u4FE1\u606F\u5DF2\u5728\u4E0A\u4E0B\u6587\u3001\u76EE\u6807 App \u542F\u52A8\u6162\u65F6\uFF0C\u53EF\u4EE5\u5148 open \u76EE\u6807 App\uFF08\u53EA\u5F00\u4E00\u4E2A\uFF09\u8BA9\u5B83\u52A0\u8F7D\uFF0C\u4E0B\u4E00\u6B65\u7ACB\u523B write \u6765\u6E90\uFF0C\u518D screen \u76EE\u6807\uFF1Bopen \u540E\u5148\u5199\u518D\u70B9\u3002",
    "\u3010\u9152\u5E97\u5FEB\u901F\u8DEF\u5F84\u3011\u5148\u770B\u65E5\u671F\u680F\uFF0C\u5DF2\u540C\u65E5\u671F\u7EDD\u4E0D\u6253\u5F00\u65E5\u671F\u9009\u62E9\u5668\uFF1B\u641C\u7D22\u6846\u8F93\u5B8C\u6574\u9152\u5E97\u540D\uFF1B\u5217\u8868\u201C\xA5\u8D77\u201D\u53EA\u4F5C\u7EBF\u7D22\uFF0C\u9152\u5E97\u8BE6\u60C5\u9996\u5C4F/\u623F\u578B\u7B2C\u4E00\u884C\u786E\u8BA4\uFF08\u643A\u7A0B\u70B9\u201C\u67E5\u770B\u623F\u578B\u201D\uFF0C\u7F8E\u56E2\u9996\u5C4F/1 \u6EDA\uFF0C\u53BB\u54EA\u513F\u9996\u5C4F\u623F\u578B\uFF09\u3002\u65E5\u671F\u9009\u62E9\u5668\u53EA\u8BD5 1 \u6B21\uFF0C\u9519\u6708\u4EFD\u5C31\u5173\uFF1B\u6253\u5F00 App \u5148 screen\uFF0C\u5DF2\u5728\u9152\u5E97\u9875\u76F4\u63A5\u7528\uFF0C\u4E0D\u56DE\u9996\u9875\u91CD\u641C\uFF1B\u6BCF\u5E73\u53F0\u22646 \u6B21\u64CD\u4F5C\uFF0C\u5931\u8D25\u8BB0 missing\u3002",
    "\u3010\u901A\u7528\u6BD4\u4EF7\u53E3\u5F84\u3011",
    "- \u540C\u6B3E\u4F18\u5148\u4E8E\u4F4E\u4EF7\uFF1A\u5546\u54C1\u578B\u53F7/\u989C\u8272/\u5C3A\u7801\uFF0C\u9152\u5E97\u623F\u578B/\u5E8A\u578B/\u65E9\u9910/\u53D6\u6D88\u653F\u7B56\uFF0C\u822A\u73ED\u53F7/\u65E5\u671F/\u8231\u4F4D/\u884C\u674E\u5FC5\u987B\u4E00\u81F4\uFF1B\u4E0D\u4E00\u81F4\u7EE7\u7EED\u627E\u540C\u6B3E\uFF0C\u4E0D\u80FD\u7528\u66F4\u4FBF\u5B9C\u7684\u4E0D\u540C\u6B3E\u5192\u5145\u6EE1\u610F\u6E20\u9053\u3002",
    "- \u4EF7\u683C\u53EA\u770B\u9996\u5C4F\uFF0C\u9ED8\u8BA4\u4E0D\u4E0B\u6ED1\uFF1B\u9996\u5C4F\u6CA1\u6709\u4EF7\u683C\u624D\u5141\u8BB8 1 \u6B21 scroll\u3002\u6BCF\u4E2A\u5E73\u53F0\u6700\u591A\u7EA6 8 \u6B21 phone \u64CD\u4F5C\uFF0C\u8D85\u8FC7\u8BB0 missing \u7EE7\u7EED\u3002",
    "- App \u542F\u52A8/\u5E7F\u544A\uFF1A\u770B\u5230\u5173\u95ED/\u8DF3\u8FC7\u7ACB\u5373\u70B9\u4E00\u6B21\uFF1B2 \u79D2\u5185\u65E0\u53EF\u8BFB\u5185\u5BB9\u518D screen \u4E00\u6B21\uFF0C\u4E0D\u8981\u8FDE\u7EED screen \u7B49\u542F\u52A8\u3002\u77ED\u94FE/H5 \u5F15\u5BFC\u9875\u53EA\u70B9\u4E00\u6B21\u201C\u6253\u5F00 App\u201D\uFF1B2 \u79D2\u6CA1\u8DF3\u8F6C\u5C31\u76F4\u63A5 open \u5BF9\u5E94 App \u641C\u7D22\uFF0C\u4E0D\u8981\u505C\u5728 H5 \u7B49\u52A0\u8F7D\u3001\u6EDA\u9875\u9762\u6216\u70B9\u5E7F\u544A\u3002",
    "- \u6765\u6E90\u9996\u5C4F\u4FE1\u606F\u62FF\u5230\u5C31\u5199\u5E76\u7ACB\u523B\u5207\u4E0B\u4E00\u4E2A\u5E73\u53F0\uFF1B\u4E0D\u8981\u5728\u6765\u6E90\u9875\u7B49\u52A0\u8F7D/\u770B\u8BC4\u4EF7/\u9886\u5238\uFF0C\u72B9\u8C6B\u4F1A\u62D6\u6162\u6574\u573A\u3002",
    "- \u4E0D\u540C\u6B3E/\u4E0D\u540C\u623F\u578B/\u4E0D\u540C\u822A\u73ED/\u4E0D\u540C\u8231\u4F4D\u5199 match=different + matchNote\uFF1B\u770B\u4E0D\u6E05\u5199 unknown\uFF0C\u90FD\u4E0D\u53C2\u4E0E\u6700\u4F4E\u4EF7\uFF0C\u4F46\u4EF7\u683C\u8981\u8BB0\u5F55\u3002",
    "- \u53EA\u8BFB\u4EF7\u683C/\u6761\u4EF6/\u7A0E\u8D39\uFF1B\u4E0D\u63D0\u4EA4\u8BA2\u5355\u3001\u4E0D\u652F\u4ED8\u3001\u4E0D\u62C5\u4FDD\uFF1B\u9047\u5230\u767B\u5F55/\u9A8C\u8BC1\u7801/\u652F\u4ED8/\u98CE\u63A7\u505C\u4E0B\u4EA4\u7ED9\u7528\u6237\u3002",
    "- \u6BCF\u67E5\u5B8C\u4E00\u4E2A\u5E73\u53F0\u7ACB\u523B\u7528 write \u66F4\u65B0 __RESULT_PATH__\uFF0C\u4FDD\u7559\u6240\u6709\u5DF2\u6838\u9A8C channels\uFF0C\u6700\u540E\u5199 partial:false\uFF1B\u4E0D\u8981\u7528 bash\u3002",
    "- \u4E0D\u80FD\u58F0\u79F0\u300C\u5168\u7F51\u6700\u4F4E\u300D\uFF0C\u53EA\u80FD\u58F0\u79F0\u300C\u5DF2\u6838\u9A8C\u6765\u6E90\u4E2D\u7684\u6700\u4F4E\u4EF7\u300D\u3002",
    "",
    "\u3010\u6BD4\u4EF7\u65B9\u6CD5\uFF08\u4F18\u5148\u7167\u505A\uFF09\u3011",
    memoryForPrompt(memory, productIds.concat(travelIds)) || "\uFF08\u6682\u65E0\u81EA\u5B9A\u4E49\u6BD4\u4EF7\u65B9\u6CD5\uFF09"
  ].join("\n");
  return finalizePrompt(text);
}
function buildLinkComparePrompt(options) {
  const url = str(options.url);
  const source = options.sourcePlatform && PLATFORM_MAP[options.sourcePlatform] ? PLATFORM_MAP[options.sourcePlatform] : null;
  const kind = options.kind === "hotel" || options.kind === "flight" ? options.kind : "product";
  const platforms = (options.platforms && options.platforms.length ? options.platforms : kind === "product" ? PLATFORMS.map(function(p) {
    return p.id;
  }) : TRAVEL_PLATFORM_IDS).filter(function(id) {
    return !source || id !== source.id;
  });
  const names = selectedPlatformNames(platforms) || "\u65E0";
  const lines = [
    "\u7528\u6237\u5728\u4F5C\u54C1\u91CC\u53EA\u7C98\u8D34\u4E86\u4E00\u4E2A\u94FE\u63A5\uFF0C\u8981\u6C42\u76F4\u63A5\u6BD4\u4EF7\u3002\u4E0D\u8981\u518D\u8BA9\u7528\u6237\u586B\u6807\u9898\u3001\u89C4\u683C\u6216\u65E5\u671F\uFF0C\u81EA\u5DF1\u4ECE\u94FE\u63A5/\u9875\u9762\u91CC\u8BFB\u3002",
    "",
    "\u94FE\u63A5\uFF1A" + url,
    source ? "\u94FE\u63A5\u770B\u8D77\u6765\u662F\uFF1A" + source.name + "\uFF08" + (kind === "product" ? "\u5546\u54C1" : kind === "hotel" ? "\u9152\u5E97" : "\u673A\u7968") + "\uFF0C\u4EC5\u7528\u4E8E\u9009\u5E73\u53F0\uFF09" : "\u94FE\u63A5\u5E73\u53F0\uFF1A\u5F85\u8BC6\u522B",
    "\u94FE\u63A5\u7684\u731C\u6D4B\u7C7B\u578B\u53EA\u7528\u4E8E\u9009\u5E73\u53F0\uFF1B\u6253\u5F00\u540E\u4EE5\u9875\u9762\u771F\u5B9E\u7C7B\u578B\u4E3A\u51C6\uFF08\u5546\u54C1/\u9152\u5E97/\u673A\u7968\uFF09\uFF0C\u4E0D\u8981\u786C\u5957\u3002",
    "\u76EE\u6807\u5E73\u53F0\uFF1A" + names,
    "\u672C\u6B21 runId\uFF1A" + (str(options.runId) || "link") + "\uFF1B\u6BCF\u6B21\u5199\u7ED3\u679C\u90FD\u5E26\u540C\u4E00\u4E2A runId \u548C\u5F53\u524D writtenAt\u3002",
    "",
    "\u3010\u7B2C\u4E00\u6B65\uFF1A\u6253\u5F00\u94FE\u63A5\u3011",
    "1. \u7B2C\u4E00\u4E2A\u52A8\u4F5C\u5148\u7528 mcp__phone__open \u6253\u5F00\u8FD9\u4E2A\u94FE\u63A5\u4E00\u6B21\u3002\u7528\u6237\u4E3B\u52A8\u8D34\u7684\u94FE\u63A5\u5141\u8BB8\u6253\u5F00\uFF1B\u4E0D\u8981\u590D\u5236\u3001\u4E0D\u8981\u5206\u4EAB\u3001\u4E0D\u8981\u70B9\u5E7F\u544A\u3002",
    "2. \u5982\u679C\u843D\u5230\u6D4F\u89C8\u5668\u3001\u5B89\u5168\u9875\u3001\u767B\u5F55\u9875\u6216\u6253\u4E0D\u5F00\uFF1A\u4E0D\u8981\u505C\u5728\u6D4F\u89C8\u5668\u91CC\u7814\u7A76\u3002\u7ACB\u523B\u8FD4\u56DE\u5BF9\u5E94 App\uFF0C\u7528\u94FE\u63A5\u91CC\u7684\u5546\u54C1\u540D/\u9152\u5E97\u540D/\u822A\u73ED\u53F7\u641C\u7D22\uFF1B\u6D4F\u89C8\u5668\u53EA\u7528\u6765\u8BC6\u522B\u4FE1\u606F\uFF0C\u4EF7\u683C\u4EE5 App \u8BE6\u60C5\u9875\u4E3A\u51C6\u3002",
    "3. \u5982\u679C\u94FE\u63A5\u76F4\u63A5\u8FDB\u5165\u5546\u54C1/\u9152\u5E97/\u673A\u7968\u8BE6\u60C5\uFF0C\u5148 screen\uFF0C\u5224\u65AD\u7C7B\u578B\uFF0C\u8BB0\u5F55\u6765\u6E90\u5E73\u53F0\u548C\u9996\u5C4F\u4EF7\u683C\u3002",
    "4. \u4E0D\u8981\u7528 bash/curl/web_fetch \u89E3\u6790\u77ED\u94FE\uFF1B\u53EA\u7528 mcp__phone__* \u5728\u624B\u673A\u4E0A\u6253\u5F00\uFF0C\u6700\u591A 2 \u5C4F H5\uFF0C\u62FF\u4E0D\u5230\u5C31 open App \u641C\u7D22\u3002",
    "",
    "\u3010\u77ED\u94FE/H5 \u5FEB\u901F\u8DF3\u8F6C\u3011",
    "App \u542F\u52A8/\u5E7F\u544A\uFF1A\u770B\u5230\u5173\u95ED/\u8DF3\u8FC7\u7ACB\u5373\u70B9\u4E00\u6B21\uFF1B2 \u79D2\u5185\u65E0\u53EF\u8BFB\u5185\u5BB9\u518D screen \u4E00\u6B21\uFF0C\u4E0D\u8981\u8FDE\u7EED screen \u7B49\u542F\u52A8\u3002",
    "\u5982\u679C\u94FE\u63A5\u843D\u5728 H5/\u5F15\u5BFC\u9875\uFF0C\u51FA\u73B0\u201C\u5728\u7F8E\u56E2/\u6DD8\u5B9D/\u5927\u4F17\u70B9\u8BC4 App \u5185\u6253\u5F00\u201D\u7B49\u6309\u94AE\uFF1A\u53EA\u70B9\u4E00\u6B21\u201C\u6253\u5F00 App\u201D\uFF1B\u6700\u591A\u7B49 2 \u79D2\uFF0C\u6CA1\u8DF3\u8F6C\u5C31\u505C\u6B62\u7B49\u5F85\uFF0C\u76F4\u63A5 open \u5BF9\u5E94 App\uFF0C\u7528 H5 \u4E0A\u770B\u5230\u7684\u9152\u5E97\u540D/\u5546\u54C1\u540D/POI \u641C\u7D22\u3002\u4E0D\u8981\u53CD\u590D screen\u3001\u6EDA\u52A8 H5\u3001\u70B9\u5E7F\u544A/\u4E0B\u8F7D\u3002",
    "\u62FF\u5230\u6765\u6E90\u9996\u5C4F\u4EF7\u683C/\u6807\u9898/\u65E5\u671F\u540E\u7ACB\u523B write\uFF0C\u5E76\u9A6C\u4E0A open \u4E0B\u4E00\u4E2A\u5E73\u53F0\uFF1B\u4E0D\u8981\u5728\u6765\u6E90\u9875\u7B49\u52A0\u8F7D\u3001\u770B\u8BC4\u4EF7/\u5E93\u5B58/\u9886\u5238\u3002",
    "",
    "\u3010\u7B2C\u4E8C\u6761\uFF1A\u5148\u5199\u6765\u6E90\u3011",
    "\u6253\u5F00\u540E\u5148 screen\uFF1B\u7B2C\u4E8C\u4E2A\u52A8\u4F5C read \u4E00\u6B21 __RESULT_PATH__\uFF08\u5B58\u5728\u624D\u8BFB\uFF0C\u4E0D\u5B58\u5728\u4F1A\u62A5\u9519\uFF0C\u76F4\u63A5\u7EE7\u7EED\uFF09\uFF1B\u7B2C\u4E09\u4E2A\u52A8\u4F5C write \u6765\u6E90\u3002\u9996\u5C4F\u6709\u4EF7\u683C\u5FC5\u987B\u5199\uFF1B\u9996\u5C4F\u6CA1\u4EF7\u624D 1 \u6B21 scroll\uFF0C\u6EDA\u540E\u5FC5\u987B\u5199\u3002",
    "\u6700\u5C0F\u6A21\u677F\uFF08\u6309\u9875\u9762\u7C7B\u578B\u9009\u4E00\u79CD\uFF0C\u53EA\u5199\u5FC5\u8981\u5B57\u6BB5\uFF09\uFF1A",
    '\u5546\u54C1\uFF1A{"kind":"price-compare","vertical":"product","title":"\u6807\u9898","spec":"","sourcePlatform":"\u5F53\u524D\u5E73\u53F0","partial":true,"runId":"...","writtenAt":"ISO","channels":[{"platform":"\u5F53\u524D\u5E73\u53F0","store":"","price":199,"match":"same","verifiedAt":"ISO"}],"missing":[],"needsUser":false,"note":"\u6765\u6E90\u5DF2\u8BB0\u5F55"}',
    '\u9152\u5E97\uFF1A{"kind":"price-compare","vertical":"hotel","title":"\u9152\u5E97\u540D","item":{"hotelName":"","city":"","checkIn":"","checkOut":"","nights":1,"rateMode":"lowest","roomType":"","guests":"2 \u4EBA"},"sourcePlatform":"\u5F53\u524D\u5E73\u53F0","partial":true,"runId":"...","writtenAt":"ISO","channels":[{"platform":"\u5F53\u524D\u5E73\u53F0","store":"","price":699,"priceUnit":"night","match":"same","verifiedAt":"ISO"}],"missing":[],"needsUser":false,"note":"\u6765\u6E90\u5DF2\u8BB0\u5F55"}',
    '\u673A\u7968\uFF1A{"kind":"price-compare","vertical":"flight","title":"\u822A\u53F8+\u822A\u73ED\u53F7","item":{"airline":"","flightNo":"","date":"","from":"","to":"","cabin":"\u7ECF\u6D4E\u8231","passengers":"1 \u4EBA"},"sourcePlatform":"\u5F53\u524D\u5E73\u53F0","partial":true,"runId":"...","writtenAt":"ISO","channels":[{"platform":"\u5F53\u524D\u5E73\u53F0","store":"","price":699,"priceUnit":"ticket","match":"same","verifiedAt":"ISO"}],"missing":[],"needsUser":false,"note":"\u6765\u6E90\u5DF2\u8BB0\u5F55"}',
    "\u4E0D\u8981\u5199 previousResults/\u65E7 channels/\u7A7A\u6570\u7EC4\uFF1B\u5199\u6210\u529F\u7ACB\u523B open \u4E0B\u4E00\u4E2A\u5E73\u53F0\u3002",
    "\u3010\u53EF\u9009\u6D41\u6C34\u7EBF\u3011\u6765\u6E90\u9996\u5C4F\u4FE1\u606F\u5DF2\u5728\u4E0A\u4E0B\u6587\u3001\u4E0B\u4E00\u4E2A App \u542F\u52A8\u6162\u65F6\uFF0C\u53EF\u4EE5\u5148 open \u4E0B\u4E00\u4E2A App\uFF08\u53EA\u5F00\u4E00\u4E2A\uFF09\u8BA9\u5B83\u52A0\u8F7D\uFF0C\u4E0B\u4E00\u6B65\u7ACB\u523B write \u6765\u6E90\uFF0C\u518D screen \u76EE\u6807\uFF1Bopen \u540E\u5148\u5199\u518D\u70B9\u3002",
    "\u5982\u679C\u94FE\u63A5\u6253\u5F00\u7684\u662F\u6D4F\u89C8\u5668/\u767B\u5F55\u9875\uFF0C\u6765\u6E90\u5E73\u53F0\u5148\u8BB0 missing\uFF0C\u5199\u6E05\u539F\u56E0\uFF1B\u4E0D\u8981\u5728\u6D4F\u89C8\u5668\u91CC\u6BD4\u4EF7\u3002",
    "",
    "\u3010\u7B2C\u4E09\u6761\uFF1A\u6309\u7C7B\u578B\u6BD4\u4EF7\u3011",
    kind === "product" ? "\u5546\u54C1\uFF1A\u540C\u6B3E\u540C\u89C4\u683C\u4F18\u5148\uFF1B\u989C\u8272/\u6B3E\u5F0F/\u5C3A\u7801\u4E0D\u540C\u5199 match=different\uFF1B\u9996\u5C4F\u4EF7\uFF1B\u6BCF\u5E73\u53F0\u22646\u6B21\u64CD\u4F5C\uFF1B\u627E\u4E0D\u5230\u540C\u6B3E\u8BB0 missing\u3002" : kind === "hotel" ? "\u9152\u5E97\uFF1A\u9ED8\u8BA4\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\uFF1B\u65E5\u671F\u680F\u5DF2\u4E00\u81F4\u7EDD\u4E0D\u6253\u5F00\u65E5\u671F\u9009\u62E9\u5668\uFF1B\u641C\u7D22\u5B8C\u6574\u9152\u5E97\u540D\uFF1B\u9152\u5E97\u8BE6\u60C5\u9996\u5C4F/\u623F\u578B\u7B2C\u4E00\u884C\uFF1B\u623F\u578B/\u65E9\u9910/\u53D6\u6D88\u5DEE\u5F02\u5199 close/different\u3002" : "\u673A\u7968\uFF1A\u540C\u822A\u73ED\u53F7/\u65E5\u671F/\u822A\u7EBF/\u8231\u4F4D\uFF1B\u65E5\u671F\u680F\u5DF2\u4E00\u81F4\u4E0D\u6253\u65E5\u671F\u9009\u62E9\u5668\uFF1B\u641C\u7D22\u822A\u73ED\u53F7\uFF1B\u9996\u5C4F\u7968\u4EF7/\u884C\u674E/\u9000\u6539\uFF1B\u4E0D\u540C\u822A\u73ED\u5199 different\u3002",
    "\u6BCF\u67E5\u5B8C\u4E00\u4E2A\u5E73\u53F0\u7ACB\u523B\u7528 write \u66F4\u65B0 __RESULT_PATH__\uFF0C\u4FDD\u7559\u5DF2\u6838\u9A8C channels\uFF0C\u6700\u540E\u5199 partial:false\uFF1B\u4E0D\u8981\u7528 bash\u3002",
    "\u53EA\u8BFB\u4EF7\u683C/\u6761\u4EF6/\u7A0E\u8D39\uFF1B\u4E0D\u63D0\u4EA4\u8BA2\u5355\u3001\u4E0D\u652F\u4ED8\uFF1B\u9047\u5230\u767B\u5F55/\u9A8C\u8BC1\u7801/\u652F\u4ED8\u5C31\u8BB0 missing \u6216 needsUser\uFF0C\u4E0D\u7ED5\u8FC7\u3002",
    "\u4E0D\u80FD\u58F0\u79F0\u300C\u5168\u7F51\u6700\u4F4E\u300D\uFF0C\u53EA\u80FD\u58F0\u79F0\u300C\u5DF2\u6838\u9A8C\u6765\u6E90\u4E2D\u7684\u6700\u4F4E\u4EF7\u300D\u3002",
    "",
    "\u3010\u6BD4\u4EF7\u65B9\u6CD5\u3011",
    memoryForPrompt(options.memory, kind === "product" ? PLATFORMS.map(function(p) {
      return p.id;
    }) : TRAVEL_PLATFORM_IDS) || "\uFF08\u6682\u65E0\u81EA\u5B9A\u4E49\u6BD4\u4EF7\u65B9\u6CD5\uFF09"
  ];
  return finalizePrompt(lines.join("\n"));
}
function buildCameraPrompt(ocrText) {
  const lines = [
    "\u8FD9\u662F\u4E00\u5F20\u7535\u5546\u5546\u54C1\u9875\u622A\u56FE\u3002\u8BF7\u63D0\u53D6\u5546\u54C1\u4FE1\u606F\uFF0C\u53EA\u8F93\u51FA\u4E00\u4E2A JSON \u5BF9\u8C61\uFF0C\u4E0D\u8981\u89E3\u91CA\uFF1A",
    '{"title":"\u5546\u54C1\u5168\u540D\uFF0C\u53BB\u6389\u4FC3\u9500\u8BCD","spec":"\u89C4\u683C/\u578B\u53F7/\u5BB9\u91CF/\u989C\u8272/\u6570\u91CF\uFF0C\u770B\u4E0D\u6E05\u5C31\u586B\u7A7A\u5B57\u7B26\u4E32","price":\u6570\u5B57\u6216null,"platform":"taobao|pdd|douyin|jd|other","store":"\u9875\u9762\u4E0A\u7684\u5E97\u94FA\u7C7B\u578B\uFF0C\u4F8B\u5982\u5B98\u65B9\u65D7\u8230\u5E97/\u767E\u4EBF\u8865\u8D34/\u81EA\u8425/\u54C1\u724C\u9ED1\u6807","note":"\u8865\u5145\u4FE1\u606F"}',
    "\u770B\u4E0D\u6E05\u7684\u5B57\u6BB5\u4E0D\u8981\u7F16\u9020\uFF1Aspec \u7559\u7A7A\u3001price \u7528 null\u3001store \u7559\u7A7A\u3002",
    "\u4E0D\u9700\u8981\u8BC6\u522B\u94FE\u63A5\uFF0C\u4E5F\u4E0D\u8981\u8981\u6C42\u7528\u6237\u590D\u5236\u94FE\u63A5\u3002"
  ];
  if (str(ocrText)) lines.push("\u672C\u5730 OCR \u8BFB\u5230\u7684\u5C4F\u5E55\u6587\u5B57\uFF08\u53EF\u80FD\u6709\u9519\uFF0C\u4EC5\u4F5C\u53C2\u8003\uFF09\uFF1A\n" + str(ocrText).slice(0, 1500));
  return lines.join("\n");
}
function buildMemoryRefinePrompt(platformId2, entry, eventsTail) {
  const platform = PLATFORM_MAP[platformId2];
  const travel = platform && platform.travel;
  const lines = [
    "\u4F60\u5728\u5E2E\u6211\u7EF4\u62A4\u4E00\u4EFD\u300C" + (travel ? "\u9152\u5E97/\u673A\u7968" : "\u7535\u5546") + "\u6BD4\u4EF7\u65B9\u6CD5\u300D\uFF0C\u53EA\u4F18\u5316\u6B65\u9AA4\uFF0C\u4E0D\u6267\u884C\u624B\u673A\u64CD\u4F5C\u3002",
    "\u5E73\u53F0\uFF1A" + (platform ? platform.name : platformId2),
    "\u8BE5\u5E73\u53F0\u5141\u8BB8\u7684\u6B63\u89C4\u6E20\u9053\uFF1A" + (platform ? platform.channels.join(" / ") : ""),
    "",
    "\u5F53\u524D\u9996\u5C4F/\u5238\u8981\u70B9\uFF1A" + (entry && entry.coupon ? entry.coupon : "\uFF08\u7A7A\uFF09"),
    "\u5F53\u524D\u6B65\u9AA4\uFF1A"
  ];
  (entry && entry.steps || []).forEach(function(step, index) {
    lines.push(index + 1 + ". " + step);
  });
  if (entry && entry.notes) lines.push("\u8865\u5145\u8BF4\u660E\uFF1A" + entry.notes);
  if (eventsTail && eventsTail.length) {
    lines.push("");
    lines.push("\u6700\u8FD1\u4E00\u6B21\u771F\u5B9E\u4EFB\u52A1\u7684\u6B65\u9AA4\u8BB0\u5F55\uFF08\u53EA\u4F5C\u53C2\u8003\uFF0C\u754C\u9762\u53EF\u80FD\u5DF2\u53D8\u5316\uFF09\uFF1A");
    eventsTail.forEach(function(item) {
      lines.push("- " + item);
    });
  }
  lines.push("");
  lines.push("\u4F18\u5316\u539F\u5219\uFF1A\u5982\u679C\u7528\u6237\u5DF2\u7ECF\u5728\u8BE6\u60C5\u9875\uFF0C\u5C31\u4E0D\u8981\u5199\u201C\u91CD\u65B0\u641C\u7D22\u540C\u4E00\u5E73\u53F0\u201D\uFF1B\u4E0D\u8981\u52A0\u5165\u590D\u5236\u94FE\u63A5\u3001\u5206\u4EAB\u9762\u677F\u3001\u52A0\u8D2D\u7269\u8F66\u3001\u63D0\u4EA4\u8BA2\u5355\u8FD9\u7C7B\u6B65\u9AA4\uFF1B\u4EF7\u683C\u53EA\u770B\u9996\u5C4F\uFF0C\u9ED8\u8BA4\u4E0D\u4E0B\u6ED1\uFF1B\u94FE\u63A5\u4E0D\u662F\u5FC5\u987B\u3002\u4FDD\u7559\u6B63\u89C4\u6E20\u9053\u7B5B\u9009\u3001\u540C\u9152\u5E97\u540C\u65E5\u671F\u540C\u623F\u578B/\u540C\u822A\u73ED\u540C\u65E5\u671F\u540C\u8231\u4F4D\u6838\u5BF9\u548C\u53EA\u8BFB\u8FB9\u754C\u3002");
  lines.push('\u6BCF\u6761\u4E0D\u8D85\u8FC7 80 \u5B57\uFF0C\u5171 4\u20138 \u6761\u3002\u8F93\u51FA\u4E25\u683C JSON\uFF0C\u4E0D\u8981\u989D\u5916\u6587\u5B57\uFF1A{"steps":["..."],"coupon":"...","notes":"..."}');
  return lines.join("\n");
}
function buildActions(memory, settings) {
  const productIds = settings && Array.isArray(settings.platforms) && settings.platforms.length ? settings.platforms : PLATFORMS.map(function(p) {
    return p.id;
  });
  const travelIds = settings && Array.isArray(settings.travelPlatforms) && settings.travelPlatforms.length ? settings.travelPlatforms : TRAVEL_PLATFORM_IDS;
  const apps = [];
  productIds.forEach(function(id) {
    if (PLATFORM_MAP[id] && apps.indexOf(PLATFORM_MAP[id].app) < 0) apps.push(PLATFORM_MAP[id].app);
  });
  travelIds.forEach(function(id) {
    if (PLATFORM_MAP[id] && apps.indexOf(PLATFORM_MAP[id].app) < 0) apps.push(PLATFORM_MAP[id].app);
  });
  return [
    {
      id: "price-compare-now",
      label: "\u7ACB\u5373\u6BD4\u4EF7",
      kind: "agent",
      apps,
      prompt: buildCompareNowActionPrompt(memory, settings || { platforms: productIds, travelPlatforms: travelIds })
    }
  ];
}

// src/app.jsx
var TERMINAL = { succeeded: 1, failed: 1, stopped: 1, interrupted: 1 };
function fingerprintOf(value) {
  let text = "";
  try {
    text = JSON.stringify(value) || "";
  } catch (error) {
    text = String(value);
  }
  let hash = 2166136261;
  for (let i = 0; i < text.length; i += 1) {
    hash ^= text.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }
  return (hash >>> 0).toString(36) + "-" + text.length;
}
var KIND_TABS = [
  { id: "product", label: "\u5546\u54C1", icon: "tag" },
  { id: "hotel", label: "\u9152\u5E97", icon: "bed" },
  { id: "flight", label: "\u673A\u7968", icon: "plane" }
];
function priceWithUnit(channel) {
  if (!channel || channel.price == null) return "\u2014";
  const price = formatPrice(channel.price);
  if (channel.priceUnit === "night") return price + "/\u665A";
  if (channel.priceUnit === "ticket") return price + "/\u4EBA";
  return price;
}
function localDateStamp(offsetDays) {
  const date = /* @__PURE__ */ new Date();
  date.setDate(date.getDate() + Number(offsetDays || 0));
  const pad = function(value) {
    return String(value).padStart(2, "0");
  };
  return date.getFullYear() + "-" + pad(date.getMonth() + 1) + "-" + pad(date.getDate());
}
function firstLinkUrl(text) {
  const match = String(text || "").match(/https?:\/\/[^\s，。；、]+/i);
  return match ? match[0].replace(/[),.;]+$/, "") : "";
}
function platformFromLink(url) {
  const raw = String(url || "").toLowerCase();
  if (!raw) return "";
  if (/taobao\.com|tmall\.com|tb\.cn/.test(raw)) return "taobao";
  if (/pinduoduo\.com|yangkeduo\.com/.test(raw)) return "pdd";
  if (/douyin\.com|jinritemai\.com/.test(raw)) return "douyin";
  if (/jd\.com|jd\.hk|3\.cn/.test(raw)) return "jd";
  if (/ctrip\.com/.test(raw)) return "ctrip";
  if (/meituan\.com|meituan\.net|dianping\.com|dpurl\.cn/.test(raw)) return "meituan";
  if (/qunar\.com/.test(raw)) return "qunar";
  return "";
}
function kindFromLink(url, platform) {
  const raw = String(url || "").toLowerCase();
  const travel = TRAVEL_PLATFORM_IDS.indexOf(platform) >= 0;
  if (!travel) return "product";
  if (/flight|jipiao|hangban|机票/.test(raw)) return "flight";
  return "hotel";
}
function itemFromStart(start) {
  if (start.kind === "hotel") {
    return {
      hotelName: start.hotelName,
      city: start.city,
      checkIn: start.checkIn,
      checkOut: start.checkOut,
      roomType: start.roomType,
      bedType: start.bedType,
      breakfast: start.breakfast,
      cancelPolicy: start.cancelPolicy,
      guests: start.guests
    };
  }
  if (start.kind === "flight") {
    return {
      flightNo: start.flightNo,
      airline: start.airline,
      date: start.date,
      from: start.from,
      to: start.to,
      cabin: start.cabin
    };
  }
  return { title: start.title, spec: start.spec };
}
function itemFromForm(form) {
  if (form.kind === "hotel") {
    return {
      hotelName: form.hotelName,
      city: form.city,
      checkIn: form.checkIn,
      checkOut: form.checkOut,
      roomType: form.roomType,
      bedType: form.bedType,
      breakfast: form.breakfast,
      cancelPolicy: form.cancelPolicy,
      guests: form.guests
    };
  }
  if (form.kind === "flight") {
    return {
      flightNo: form.flightNo,
      airline: form.airline,
      date: form.date,
      from: form.from,
      to: form.to,
      cabin: form.cabin
    };
  }
  return { title: form.title, spec: form.spec };
}
function startPlatforms(start, settings) {
  if (start.kind === "hotel" || start.kind === "flight") {
    return (start.travelPlatforms && start.travelPlatforms.length ? start.travelPlatforms : TRAVEL_PLATFORM_IDS).slice();
  }
  return (start.platforms || settings.platforms || []).slice();
}
function blankForm() {
  return {
    kind: "product",
    title: "",
    spec: "",
    url: "",
    note: "",
    price: "",
    sourcePlatform: "",
    sourceStore: "",
    hotelName: "",
    city: "",
    checkIn: "",
    checkOut: "",
    rateMode: "lowest",
    roomType: "",
    bedType: "",
    breakfast: "",
    cancelPolicy: "",
    guests: "2 \u4EBA",
    flightNo: "",
    airline: "",
    date: "",
    from: "",
    to: "",
    cabin: "\u7ECF\u6D4E\u8231"
  };
}
function blankStart(settings) {
  return {
    kind: "product",
    title: "",
    spec: "",
    url: "",
    note: "",
    platforms: (settings.platforms || []).slice(),
    travelPlatforms: (settings.travelPlatforms || TRAVEL_PLATFORM_IDS).slice(),
    autoCoupon: settings.autoCoupon !== false,
    source: null,
    skipSource: settings.skipSource !== false,
    hotelName: "",
    city: "",
    checkIn: "",
    checkOut: "",
    rateMode: "lowest",
    roomType: "",
    bedType: "",
    breakfast: "",
    cancelPolicy: "",
    guests: "2 \u4EBA",
    flightNo: "",
    airline: "",
    date: "",
    from: "",
    to: "",
    cabin: "\u7ECF\u6D4E\u8231"
  };
}
function startFromCandidate(candidate, settings) {
  const base = blankStart(settings);
  if (!candidate) return base;
  const isRecord = Array.isArray(candidate.channels);
  const kind = KINDS.indexOf(candidate.kind) >= 0 ? candidate.kind : "product";
  const item = normalizeItem(kind, candidate.item || candidate);
  base.kind = kind;
  base.url = candidate.url || "";
  if (kind === "hotel") {
    base.hotelName = item.hotelName || "";
    base.city = item.city || "";
    base.checkIn = item.checkIn || "";
    base.checkOut = item.checkOut || "";
    base.rateMode = item.rateMode || "lowest";
    base.roomType = item.roomType || "";
    base.bedType = item.bedType || "";
    base.breakfast = item.breakfast || "";
    base.cancelPolicy = item.cancelPolicy || "";
    base.guests = item.guests || "2 \u4EBA";
    base.title = itemTitle(kind, item);
    base.spec = itemSummary(kind, item);
  } else if (kind === "flight") {
    base.flightNo = item.flightNo || "";
    base.airline = item.airline || "";
    base.date = item.date || "";
    base.from = item.from || "";
    base.to = item.to || "";
    base.cabin = item.cabin || "\u7ECF\u6D4E\u8231";
    base.title = itemTitle(kind, item);
    base.spec = itemSummary(kind, item);
  } else {
    base.title = item.title || candidate.title || "";
    base.spec = item.spec || candidate.spec || "";
  }
  const sourcePrice = candidate.sourcePrice != null ? candidate.sourcePrice : candidate.priceHint;
  const sourcePlatform = !isRecord && PLATFORM_MAP[candidate.sourcePlatform] ? candidate.sourcePlatform : "";
  if (sourcePlatform && sourcePrice != null) {
    const capturedAt = candidate.capturedAt || candidate.createdAt || Date.now();
    base.source = {
      platform: sourcePlatform,
      price: sourcePrice,
      store: candidate.sourceStore || "",
      url: candidate.sourceUrl || candidate.url || "",
      note: candidate.sourceNote || candidate.note || "",
      at: capturedAt,
      from: candidate.capturedFrom || "candidate"
    };
    base.skipSource = Date.now() - capturedAt < 30 * 6e4 && settings.skipSource !== false;
  }
  base.note = [
    candidate.note,
    sourcePrice != null ? (sourcePlatform ? "\u6765\u6E90\u9875\u4EF7\u683C " : "\u5019\u9009\u9875\u4EF7\u683C ") + formatPrice(sourcePrice) + "\uFF08\u4EC5\u4F9B\u53C2\u8003\uFF09" : "",
    sourcePlatform ? "\u6765\u6E90 " + platformLabel(sourcePlatform) : candidate.platformHint ? "\u6765\u6E90 " + platformLabel(candidate.platformHint) : ""
  ].filter(Boolean).join(" \xB7 ");
  return base;
}
function channelFromSource(source, kind) {
  if (!source || !PLATFORM_MAP[source.platform] || source.price == null) return null;
  const type = kind || "product";
  return normalizeChannel({
    platform: source.platform,
    store: source.store || "",
    label: source.store ? "" : type === "hotel" ? "\u6765\u6E90\u623F\u578B" : type === "flight" ? "\u6765\u6E90\u8231\u4F4D" : "\u6765\u6E90\u5546\u54C1\u9875",
    price: source.price,
    priceUnit: type === "hotel" ? "night" : type === "flight" ? "ticket" : "",
    shipping: null,
    coupons: [],
    condition: type === "hotel" ? "\u5DF2\u5728\u9152\u5E97\u9875\u6838\u9A8C\u7684\u9996\u5C4F\u6BCF\u665A\u4EF7\uFF1B\u7A0E\u8D39/\u65E9\u9910\u4EE5\u9875\u9762\u4E3A\u51C6" : type === "flight" ? "\u5DF2\u5728\u673A\u7968\u9875\u6838\u9A8C\u7684\u9996\u5C4F\u7968\u4EF7\uFF1B\u7A0E\u8D39/\u884C\u674E\u4EE5\u9875\u9762\u4E3A\u51C6" : "\u5DF2\u5728\u5546\u54C1\u9875\u6838\u9A8C\u7684\u9875\u9762\u4EF7\uFF1B\u8FD0\u8D39\u548C\u5238\u4EE5\u9875\u9762\u4E3A\u51C6",
    url: source.url || "",
    linkKind: source.url ? "product" : "current",
    match: "same",
    specSeen: source.spec || "",
    matchNote: "",
    verifiedAt: new Date(source.at || Date.now()).toISOString(),
    note: "\u6765\u6E90\u9875\u9762\u76F4\u63A5\u8BB0\u5F55\uFF0C\u672A\u91CD\u65B0\u641C\u7D22"
  });
}
function bestChannel(record) {
  if (!record || !record.spec) return null;
  const eligible = (record.channels || []).filter(function(channel) {
    if (!channel || channel.price == null || !channel.verifiedAt || !isAuthenticChannel(channel)) return false;
    if (record.kind === "hotel") return true;
    return channel.match === "same";
  });
  return lowestChannel(eligible);
}
function matchMeta(channel, kind) {
  const travel = kind === "hotel" || kind === "flight";
  switch (channel && channel.match) {
    case "same":
      return { label: travel ? "\u6761\u4EF6\u4E00\u81F4" : "\u6B3E\u5F0F\u4E00\u81F4", tone: "ok" };
    case "close":
      return { label: "\u6761\u4EF6\u63A5\u8FD1", tone: "warn" };
    case "different":
      return { label: "\u6709\u5DEE\u5F02", tone: "warn" };
    case "unknown":
      return { label: travel ? "\u5F85\u786E\u8BA4" : "\u6B3E\u5F0F\u5F85\u786E\u8BA4", tone: "warn" };
    default:
      return { label: "\u672A\u6807\u6CE8", tone: "" };
  }
}
function mergeChannels(existing, incoming) {
  const list = (existing || []).slice();
  (incoming || []).forEach(function(channel) {
    const index = list.findIndex(function(item) {
      return item.platform === channel.platform && (item.store === channel.store || !item.store || !channel.store || item.label === channel.label);
    });
    if (index < 0) {
      list.push(channel);
      return;
    }
    const previous = list[index];
    list[index] = normalizeChannel({
      ...previous,
      ...channel,
      store: channel.store || previous.store,
      label: channel.label || previous.label,
      price: channel.price != null ? channel.price : previous.price,
      shipping: channel.shipping != null ? channel.shipping : previous.shipping,
      coupons: channel.coupons.length ? channel.coupons : previous.coupons,
      condition: channel.condition || previous.condition,
      url: channel.url || previous.url,
      linkKind: channel.url ? channel.linkKind : previous.linkKind,
      match: channel.match || previous.match,
      specSeen: channel.specSeen || previous.specSeen,
      matchNote: [previous.matchNote, channel.matchNote].filter(Boolean).join(" \xB7 ").slice(0, 300),
      details: Object.keys(channel.details || {}).length ? channel.details : previous.details,
      priceUnit: channel.priceUnit || previous.priceUnit,
      verifiedAt: channel.verifiedAt || previous.verifiedAt,
      note: [previous.note, channel.note].filter(Boolean).join(" \xB7 ").slice(0, 300)
    });
  });
  return normalizeChannels(list);
}
function compactEvents(events) {
  const out = [];
  (Array.isArray(events) ? events : []).forEach(function(item) {
    if (!item || typeof item !== "object") return;
    if (item.type === "tool") {
      out.push({ kind: "tool", text: str(item.name) || "\u5DE5\u5177" });
    } else if (item.type === "text") {
      const text = str(item.text);
      if (text) out.push({ kind: "text", text: clampText(text, 220) });
    }
  });
  return out.slice(-5);
}
function lastText(events) {
  let text = "";
  (Array.isArray(events) ? events : []).forEach(function(item) {
    if (item && item.type === "text" && str(item.text)) text = str(item.text);
  });
  return text;
}
function historyTail(events) {
  return compactEvents(events).map(function(item) {
    return item.kind === "tool" ? "\u6267\u884C\uFF1A" + item.text : item.text;
  });
}
function phaseLabel(phase) {
  switch (phase) {
    case "starting":
      return "\u6B63\u5728\u542F\u52A8\u52A9\u624B";
    case "running":
      return "\u6B63\u5728\u6BD4\u4EF7";
    case "awaiting-confirmation":
      return "\u7B49\u4F60\u786E\u8BA4";
    case "paused":
      return "\u5DF2\u6682\u505C";
    case "succeeded":
      return "\u4EFB\u52A1\u5B8C\u6210";
    case "failed":
      return "\u4EFB\u52A1\u5931\u8D25";
    case "stopped":
      return "\u5DF2\u505C\u6B62";
    case "interrupted":
      return "\u4EFB\u52A1\u4E2D\u65AD";
    default:
      return "\u5904\u7406\u4E2D";
  }
}
function runStatusMeta(run) {
  if (!run) return { label: "", tone: "" };
  if (run.running) return { label: "\u8FDB\u884C\u4E2D", tone: "live" };
  switch (run.phase) {
    case "succeeded":
      return { label: "\u5DF2\u5B8C\u6210", tone: "ok" };
    case "failed":
      return { label: "\u5931\u8D25", tone: "danger" };
    case "interrupted":
      return { label: "\u5F85\u786E\u8BA4", tone: "warn" };
    default:
      return { label: "\u5DF2\u505C\u6B62", tone: "warn" };
  }
}
function capOn(caps, key) {
  if (!caps) return false;
  const value = caps[key];
  return value === true || isObj(value) && value.granted === true;
}
function a11yState(caps) {
  if (!caps) return null;
  const phone = caps.phoneStatus;
  if (isObj(phone)) {
    if (isObj(phone.a11y) && typeof phone.a11y.serviceConnected === "boolean") return phone.a11y.serviceConnected;
    if (typeof phone.serviceConnected === "boolean") return phone.serviceConnected;
  }
  if (typeof caps.accessibilityConnected === "boolean") return caps.accessibilityConnected;
  return null;
}
function overlayState(caps) {
  if (!caps) return null;
  if (typeof caps.overlay === "boolean") return caps.overlay;
  if (typeof caps.overlayPermission === "boolean") return caps.overlayPermission;
  if (typeof caps.overlayGranted === "boolean") return caps.overlayGranted;
  if (typeof caps.canDrawOverlays === "boolean") return caps.canDrawOverlays;
  if (typeof caps.overlay === "string") {
    if (/grant|allow|yes|on/i.test(caps.overlay)) return true;
    if (/deny|denied|off|no|false/i.test(caps.overlay)) return false;
  }
  if (isObj(caps.overlay) && typeof caps.overlay.granted === "boolean") return caps.overlay.granted;
  if (isObj(caps.overlay) && typeof caps.overlay.enabled === "boolean") return caps.overlay.enabled;
  if (isObj(caps.phoneStatus)) {
    if (typeof caps.phoneStatus.overlay === "boolean") return caps.phoneStatus.overlay;
    if (typeof caps.phoneStatus.overlayPermission === "boolean") return caps.phoneStatus.overlayPermission;
    if (isObj(caps.phoneStatus.overlay) && typeof caps.phoneStatus.overlay.granted === "boolean") return caps.phoneStatus.overlay.granted;
    if (isObj(caps.phoneStatus.overlay) && typeof caps.phoneStatus.overlay.enabled === "boolean") return caps.phoneStatus.overlay.enabled;
  }
  if (isObj(caps.system) && typeof caps.system.overlay === "boolean") return caps.system.overlay;
  if (isObj(caps.system) && isObj(caps.system.overlay) && typeof caps.system.overlay.granted === "boolean") return caps.system.overlay.granted;
  if (isObj(caps.permissions)) {
    if (typeof caps.permissions.overlay === "boolean") return caps.permissions.overlay;
    if (isObj(caps.permissions.overlay) && typeof caps.permissions.overlay.granted === "boolean") return caps.permissions.overlay.granted;
  }
  return null;
}
function phoneBridgeState(caps) {
  if (!caps || !isObj(caps.phoneStatus)) return null;
  const phone = caps.phoneStatus;
  if (typeof phone.bridgeListening === "boolean") return phone.bridgeListening;
  if (typeof phone.enabled === "boolean") return phone.enabled;
  return null;
}
async function safeRead(bridge, name) {
  try {
    return { ok: true, value: await bridge.data.read(name) };
  } catch (error) {
    return { ok: false, error: msg(error) };
  }
}
function CapRow(props) {
  return /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-cap-row" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-cap-icon", "data-ok": props.ok === true ? "true" : props.ok === false ? "false" : "unknown" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: props.ok === true ? "check" : props.ok === false ? "alert" : "clock", size: 17 })), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-cap-copy" }, /* @__PURE__ */ import_react2.default.createElement("strong", null, props.label), /* @__PURE__ */ import_react2.default.createElement("small", null, props.text)), /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-badge", "data-state": props.ok === true ? "ready" : props.ok === false ? "error" : void 0 }, props.ok === true ? "\u5DF2\u5F00\u542F" : props.ok === false ? "\u672A\u5F00\u542F" : "\u672A\u77E5"));
}
function SkeletonLine(props) {
  return /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-skel", style: { width: props.width || "100%", height: props.height || 12 } });
}
function App() {
  const [bridge, setBridge] = (0, import_react2.useState)(null);
  const [boot, setBoot] = (0, import_react2.useState)("waiting");
  const [page, setPage] = (0, import_react2.useState)("home");
  const [recordId, setRecordId] = (0, import_react2.useState)("");
  const [sheet, setSheet] = (0, import_react2.useState)(null);
  const [records, setRecords] = (0, import_react2.useState)([]);
  const [candidates, setCandidates] = (0, import_react2.useState)([]);
  const [memory, setMemory] = (0, import_react2.useState)(defaultMemory());
  const [settings, setSettings] = (0, import_react2.useState)(defaultSettings());
  const [caps, setCaps] = (0, import_react2.useState)(null);
  const [capsError, setCapsError] = (0, import_react2.useState)("");
  const [run, setRun] = (0, import_react2.useState)(null);
  const [toast, setToast] = (0, import_react2.useState)(null);
  const [globalError, setGlobalError] = (0, import_react2.useState)("");
  const [saveHint, setSaveHint] = (0, import_react2.useState)({ text: "", state: "" });
  const [active, setActive] = (0, import_react2.useState)(true);
  const [photo, setPhoto] = (0, import_react2.useState)(null);
  const [form, setForm] = (0, import_react2.useState)(blankForm());
  const [start, setStart] = (0, import_react2.useState)(blankStart(defaultSettings()));
  const [formError, setFormError] = (0, import_react2.useState)("");
  const [startError, setStartError] = (0, import_react2.useState)("");
  const [confirmBusy, setConfirmBusy] = (0, import_react2.useState)(false);
  const [confirmError, setConfirmError] = (0, import_react2.useState)("");
  const [remindBusy, setRemindBusy] = (0, import_react2.useState)("");
  const [memoryEdit, setMemoryEdit] = (0, import_react2.useState)(null);
  const [tick, setTick] = (0, import_react2.useState)(Date.now());
  const [refreshing, setRefreshing] = (0, import_react2.useState)("");
  const [refreshingLatest, setRefreshingLatest] = (0, import_react2.useState)(false);
  const [quickUrl, setQuickUrl] = (0, import_react2.useState)("");
  const [quickError, setQuickError] = (0, import_react2.useState)("");
  const [actionsVisible, setActionsVisible] = (0, import_react2.useState)(null);
  const phoneGranted = capOn(caps, "phone");
  const remindersGranted = capOn(caps, "reminders");
  const a11y = a11yState(caps);
  const overlay = overlayState(caps);
  const floatingHidden = overlay === null && actionsVisible === false;
  const a11yBlocked = a11y === false;
  const overlayBlocked = overlay === false || floatingHidden;
  const floatingBlocked = overlayBlocked || a11yBlocked;
  const systemNotifications = capOn(caps, "notifications");
  const aiReady = capOn(caps, "aiDirect");
  const bridgeRef = (0, import_react2.useRef)(null);
  const recordsRef = (0, import_react2.useRef)([]);
  const candidatesRef = (0, import_react2.useRef)([]);
  const settingsRef = (0, import_react2.useRef)(settings);
  const memoryRef = (0, import_react2.useRef)(memory);
  const capsRef = (0, import_react2.useRef)(null);
  const runRef = (0, import_react2.useRef)(null);
  const activeRef = (0, import_react2.useRef)(true);
  const guardRef = (0, import_react2.useRef)("");
  const activeMetaRef = (0, import_react2.useRef)(null);
  const lastResultRef = (0, import_react2.useRef)(null);
  const partialRef = (0, import_react2.useRef)("");
  const steeredRef = (0, import_react2.useRef)(false);
  const applyPartialRef = (0, import_react2.useRef)(null);
  const finalizeRef = (0, import_react2.useRef)(null);
  const connectRef = (0, import_react2.useRef)(null);
  const bootedRef = (0, import_react2.useRef)(false);
  const navRef = (0, import_react2.useRef)({});
  const taskHostRef = (0, import_react2.useRef)(null);
  const confirmBusyRef = (0, import_react2.useRef)(false);
  const startingRef = (0, import_react2.useRef)(false);
  bridgeRef.current = bridge;
  recordsRef.current = records;
  candidatesRef.current = candidates;
  settingsRef.current = settings;
  memoryRef.current = memory;
  capsRef.current = caps;
  runRef.current = run;
  confirmBusyRef.current = confirmBusy;
  navRef.current = { page, sheet, recordId, setPage, setSheet, setRecordId };
  (0, import_react2.useEffect)(function mount() {
    let disposed = false;
    let timer = null;
    async function connect() {
      const wish = typeof window !== "undefined" ? window.dshWish : null;
      if (!wish) {
        if (!disposed && !bootedRef.current) {
          setBoot("waiting");
          if (timer) clearTimeout(timer);
          timer = setTimeout(function() {
            if (!disposed && !bootedRef.current) setBoot("unsupported");
          }, 4200);
        }
        return;
      }
      if (disposed) return;
      if (bootedRef.current) {
        registerActions(wish, memoryRef.current, settingsRef.current);
        return;
      }
      if (timer) {
        clearTimeout(timer);
        timer = null;
      }
      setBridge(wish);
      bridgeRef.current = wish;
      try {
        await wish.work.describe({
          title: TITLE,
          description: "\u5546\u54C1\u3001\u9152\u5E97\u3001\u673A\u7968\u90FD\u6BD4\u4EF7\uFF1A\u6DD8\u5B9D/\u62FC\u591A\u591A/\u6296\u97F3/\u4EAC\u4E1C\u4E0E\u643A\u7A0B/\u7F8E\u56E2/\u53BB\u54EA\u513F\uFF1B\u5F53\u524D\u9875\u76F4\u63A5\u7B97\uFF0C\u4E0D\u91CD\u590D\u641C\u7D22\u3001\u4E0D\u590D\u5236\u94FE\u63A5\uFF0C\u8BB0\u5F55\u5404\u5E73\u53F0\u4EF7\u683C\u4E0E\u6838\u9A8C\u65F6\u95F4\u3002",
          actions: []
        });
      } catch (error) {
      }
      await loadAll(wish);
      if (disposed) return;
      bootedRef.current = true;
      setBoot("ready");
      try {
        await wish.ui.ready();
      } catch (error) {
      }
      registerActions(wish, memoryRef.current, settingsRef.current);
    }
    connectRef.current = connect;
    connect();
    window.addEventListener("dsh-wish-ready", connect);
    return function() {
      disposed = true;
      if (timer) clearTimeout(timer);
      window.removeEventListener("dsh-wish-ready", connect);
    };
  }, []);
  (0, import_react2.useEffect)(
    function navigation() {
      if (!bridge || !bridge.ui || typeof bridge.ui.registerNavigation !== "function") return void 0;
      let unregister = null;
      try {
        unregister = bridge.ui.registerNavigation({
          back() {
            const current = navRef.current;
            if (current.sheet) {
              current.setSheet(null);
              return true;
            }
            if (current.page !== "home") {
              current.setPage("home");
              current.setRecordId("");
              return true;
            }
            return false;
          },
          settings() {
            const current = navRef.current;
            current.setSheet(null);
            current.setPage("settings");
          }
        });
      } catch (error) {
        console.warn("[price-radar] navigation registration failed", error);
      }
      return function() {
        try {
          if (typeof unregister === "function") unregister();
        } catch (error) {
        }
      };
    },
    [bridge]
  );
  (0, import_react2.useEffect)(
    function taskControl() {
      const node = taskHostRef.current;
      const wish = bridge;
      if (!wish || !node || !run) return void 0;
      let control = null;
      try {
        if (wish.ui && typeof wish.ui.mountTaskControl === "function") control = wish.ui.mountTaskControl(node);
      } catch (error) {
        console.warn("[price-radar] task control mount failed", error);
      }
      return function() {
        try {
          if (control && typeof control.dispose === "function") control.dispose();
        } catch (error) {
        }
      };
    },
    [bridge, run && run.sessionId, run && run.finishedAt]
  );
  (0, import_react2.useEffect)(
    function ticker() {
      if (!run || !run.running) return void 0;
      const timer = setInterval(function() {
        setTick(Date.now());
      }, 1e3);
      return function() {
        clearInterval(timer);
      };
    },
    [run && run.running]
  );
  (0, import_react2.useEffect)(
    function clock() {
      if (!active) return void 0;
      const timer = setInterval(function() {
        setTick(Date.now());
      }, 3e4);
      return function() {
        clearInterval(timer);
      };
    },
    [active]
  );
  (0, import_react2.useEffect)(
    function toastTimer() {
      if (!toast) return void 0;
      const timer = setTimeout(function() {
        setToast(null);
      }, 3400);
      return function() {
        clearTimeout(timer);
      };
    },
    [toast]
  );
  (0, import_react2.useEffect)(
    function visibility() {
      function handler(event) {
        const detail = event && event.detail;
        const on = !detail || detail.active !== false;
        activeRef.current = on;
        setActive(on);
        if (on) {
          void refreshCaps();
          void syncAgent();
        }
      }
      window.addEventListener("dsh-wish-visibility", handler);
      return function() {
        window.removeEventListener("dsh-wish-visibility", handler);
      };
    },
    [bridge]
  );
  (0, import_react2.useEffect)(
    function restoreRun() {
      if (boot !== "ready" || !bridge) return void 0;
      void syncAgent();
      return void 0;
    },
    [boot, bridge]
  );
  (0, import_react2.useEffect)(
    function autoRefreshLatest() {
      if (!active || page !== "records" && page !== "home") return void 0;
      const timer = setTimeout(function() {
        void importAgentResultIfNew(null, { silent: true });
      }, 400);
      return function() {
        clearTimeout(timer);
      };
    },
    [active, page, records.length]
  );
  (0, import_react2.useEffect)(
    function pollRun() {
      if (!run || !run.running || !bridge || !bridge.agent) return void 0;
      let stopped = false;
      let timer = null;
      async function step() {
        if (stopped) return;
        let status = null;
        try {
          status = await bridge.agent.status();
        } catch (error) {
          status = null;
        }
        if (stopped) return;
        if (status) {
          const phase = status.phase || "running";
          const terminal = !!TERMINAL[phase];
          if (terminal) {
            setRun(function(previous) {
              if (!previous) return previous;
              return {
                ...previous,
                sessionId: status.sessionId || previous.sessionId,
                phase,
                running: false,
                events: Array.isArray(status.events) ? status.events : previous.events,
                error: status.error ? str(status.error) : previous.error
              };
            });
            await finalizeRef.current(runRef.current || run, status);
            return;
          }
          let partial = null;
          try {
            partial = await bridge.agent.results();
          } catch (error) {
            partial = null;
          }
          const parsedPartial = normalizeCompareResult(partial);
          if (parsedPartial && applyPartialRef.current) {
            await applyPartialRef.current(runRef.current || run, parsedPartial, status);
          }
          setRun(function(previous) {
            if (!previous) return previous;
            const events = Array.isArray(status.events) ? status.events : previous.events;
            const progressed = events.length !== (previous.events || []).length;
            return {
              ...previous,
              sessionId: status.sessionId || previous.sessionId,
              phase,
              running: true,
              events,
              lastProgressAt: progressed ? Date.now() : previous.lastProgressAt || Date.now(),
              error: status.error ? str(status.error) : previous.error
            };
          });
          const current = runRef.current;
          if (current && !current.recordedCount && !current.nudged && ["running", "starting"].indexOf(phase) >= 0 && Date.now() - (current.startedAt || Date.now()) > 6e4 && bridge.agent && typeof bridge.agent.steer === "function") {
            current.nudged = true;
            setRun(function(previous) {
              return previous ? { ...previous, nudged: true } : previous;
            });
            try {
              await bridge.agent.steer(
                "\u5148\u4E0D\u8981\u7EE7\u7EED\u6EDA\u52A8\uFF0C\u4E5F\u4E0D\u8981\u8FDB\u5E97\u94FA\u9875\u3001\u8BC4\u4EF7\u9875\u6216\u5238\u4E2D\u5FC3\u3002\u73B0\u5728\u7ACB\u523B\u7528 write \u628A\u5F53\u524D\u5546\u54C1\u6807\u9898\u548C\u9875\u9762\u4EF7\u5199\u5165 agent-results.json\uFF08partial:true\u3001writtenAt\u3001runId\uFF09\uFF0C\u5199\u5B8C\u540E\u53EA\u67E5\u5176\u4ED6\u5E73\u53F0\u3002"
              );
            } catch (error) {
            }
          }
        }
        timer = setTimeout(step, 3e3);
      }
      step();
      return function() {
        stopped = true;
        if (timer) clearTimeout(timer);
      };
    },
    [run && run.running, run && run.sessionId, bridge]
  );
  (0, import_react2.useEffect)(
    function aiQueued() {
      if (!memoryEdit || memoryEdit.aiState !== "queued") return;
      void refineMemoryFromEdit(memoryEdit);
    },
    [memoryEdit && memoryEdit.aiState, memoryEdit && memoryEdit.platform]
  );
  async function loadAll(wish) {
    const [settingsResult, memoryResult, recordsResult, candidatesResult, activeResult, lastResult] = await Promise.all([
      safeRead(wish, "settings"),
      safeRead(wish, "memory"),
      safeRead(wish, "records"),
      safeRead(wish, "candidates"),
      safeRead(wish, "activeRun"),
      safeRead(wish, "lastAgentResult")
    ]);
    const normalizedSettings = normalizeSettings(settingsResult.value);
    const normalizedMemory = normalizeMemory(memoryResult.value);
    const normalizedRecords = normalizeRecords(recordsResult.value);
    const normalizedCandidates = normalizeCandidates(candidatesResult.value);
    settingsRef.current = normalizedSettings;
    memoryRef.current = normalizedMemory;
    recordsRef.current = normalizedRecords;
    candidatesRef.current = normalizedCandidates;
    setSettings(normalizedSettings);
    setMemory(normalizedMemory);
    setRecords(normalizedRecords);
    setCandidates(normalizedCandidates);
    setStart(blankStart(normalizedSettings));
    if (isObj(memoryResult.value) && (!Number.isFinite(Number(memoryResult.value.version)) || Number(memoryResult.value.version) < 5)) {
      try {
        await wish.data.write("memory", normalizedMemory);
      } catch (error) {
      }
    }
    if (isObj(settingsResult.value) && Number(settingsResult.value.version) < 4) {
      try {
        await wish.data.write("settings", normalizedSettings);
      } catch (error) {
      }
    }
    const activeMeta = isObj(activeResult.value) ? activeResult.value : null;
    activeMetaRef.current = activeMeta;
    lastResultRef.current = isObj(lastResult.value) ? lastResult.value : null;
    if (!settingsResult.ok || !recordsResult.ok) {
      setGlobalError("\u672C\u5730\u6570\u636E\u8BFB\u53D6\u4E0D\u5B8C\u6574\uFF0C\u4FEE\u6539\u4F1A\u5728\u4E0B\u6B21\u4FDD\u5B58\u65F6\u91CD\u65B0\u5199\u5165\u3002");
    }
    await refreshCaps();
  }
  async function refreshCaps() {
    const wish = bridgeRef.current;
    if (!wish || !wish.capabilities || typeof wish.capabilities.status !== "function") return;
    try {
      const previousOverlay = overlayState(capsRef.current);
      const previousA11y = a11yState(capsRef.current);
      const value = await wish.capabilities.status();
      capsRef.current = value;
      setCaps(value);
      setCapsError("");
      try {
        await wish.data.write("capsDebug", {
          at: Date.now(),
          keys: Object.keys(value || {}),
          overlay: value && value.overlay,
          phoneStatus: value && value.phoneStatus,
          system: value && value.system,
          permissions: value && value.permissions,
          bridge: {
            wish: Object.keys(wish || {}),
            actions: Object.keys(wish && wish.actions || {}),
            ui: Object.keys(wish && wish.ui || {}),
            shortcuts: Object.keys(wish && wish.shortcuts || {})
          }
        });
      } catch (error) {
      }
      if (overlayState(value) !== previousOverlay || a11yState(value) !== previousA11y) {
        void registerActions(wish, memoryRef.current, settingsRef.current);
      }
    } catch (error) {
      setCapsError("\u80FD\u529B\u72B6\u6001\u8BFB\u53D6\u5931\u8D25\uFF1A" + msg(error));
    }
  }
  async function openCapabilityCenter() {
    const wish = bridgeRef.current;
    if (!wish || !wish.capabilities || typeof wish.capabilities.request !== "function") {
      showToast("\u5F53\u524D\u7CFB\u7EDF\u4E0D\u652F\u6301\u6253\u5F00\u80FD\u529B\u4E2D\u5FC3");
      return;
    }
    try {
      await wish.capabilities.request();
    } catch (error) {
      setCapsError("\u6253\u5F00\u80FD\u529B\u4E2D\u5FC3\u5931\u8D25\uFF1A" + msg(error));
    }
    await refreshCaps();
  }
  function openCaps(reason) {
    setCapsError("");
    setSheet({ type: "caps", reason: reason || "" });
  }
  async function openFloatingControls(reason) {
    const wish = bridgeRef.current;
    const candidates2 = [];
    if (wish) {
      ["openFloatingSettings", "openActionsSettings", "openFloatingActions", "openActions"].forEach(function(name) {
        if (typeof wish[name] === "function") candidates2.push({ owner: wish, fn: wish[name] });
      });
      if (wish.ui) {
        ["openFloatingSettings", "openActionsSettings", "openActions"].forEach(function(name) {
          if (typeof wish.ui[name] === "function") candidates2.push({ owner: wish.ui, fn: wish.ui[name] });
        });
      }
      if (wish.actions) {
        ["openSettings", "settings", "configure", "manage"].forEach(function(name) {
          if (typeof wish.actions[name] === "function") candidates2.push({ owner: wish.actions, fn: wish.actions[name] });
        });
      }
      if (wish.overlay) {
        ["openSettings", "settings"].forEach(function(name) {
          if (typeof wish.overlay[name] === "function") candidates2.push({ owner: wish.overlay, fn: wish.overlay[name] });
        });
      }
      if (typeof wish.openPanel === "function") {
        ["permissions", "permissions-actions", "permissionsActions", "actions", "wish-permissions", "wish-actions"].forEach(function(id) {
          candidates2.push({ owner: wish, fn: function() {
            return wish.openPanel(id);
          } });
        });
      }
    }
    for (let i = 0; i < candidates2.length; i += 1) {
      try {
        await candidates2[i].fn.call(candidates2[i].owner);
        return true;
      } catch (error) {
      }
    }
    setSheet({ type: "floating", reason: reason || "" });
    return false;
  }
  function showToast(text) {
    setToast({ text, id: Date.now() + Math.random() });
  }
  async function registerActions(wish, nextMemory, nextSettings) {
    if (!wish || !wish.actions) return;
    try {
      if (typeof wish.actions.register === "function") await wish.actions.register(buildActions(nextMemory, nextSettings));
    } catch (error) {
      console.warn("[price-radar] action registration failed", error);
    }
    try {
      if (typeof wish.actions.show === "function") {
        const shown = await wish.actions.show();
        setActionsVisible(shown !== false);
      }
    } catch (error) {
      setActionsVisible(false);
    }
  }
  async function writeRecords(next) {
    try {
      await bridgeRef.current.data.write("records", { version: 2, items: next });
      return true;
    } catch (error) {
      setGlobalError("\u6BD4\u4EF7\u8BB0\u5F55\u4FDD\u5B58\u5931\u8D25\uFF1A" + msg(error));
      return false;
    }
  }
  async function writeCandidates(next) {
    try {
      await bridgeRef.current.data.write("candidates", { version: 1, items: next });
      return true;
    } catch (error) {
      setGlobalError("\u5019\u9009\u4FDD\u5B58\u5931\u8D25\uFF1A" + msg(error));
      return false;
    }
  }
  async function writeActive(meta) {
    try {
      await bridgeRef.current.data.write("activeRun", meta || null);
    } catch (error) {
    }
  }
  function updateWidget(next) {
    try {
      const wish = bridgeRef.current;
      if (!wish || !wish.widget || typeof wish.widget.update !== "function") return;
      const latest = next && next[0];
      if (!latest) {
        wish.widget.update("\u6BD4\u4EF7\u96F7\u8FBE\uFF1A\u8FD8\u6CA1\u6709\u6BD4\u4EF7\u8BB0\u5F55");
        return;
      }
      const best = bestChannel(latest);
      wish.widget.update(best ? "\u6700\u8FD1\u6BD4\u4EF7\uFF1A" + latest.title + " \xB7 " + priceWithUnit(best) : "\u6700\u8FD1\u6BD4\u4EF7\uFF1A" + latest.title + " \xB7 \u5F85\u6838\u9A8C");
    } catch (error) {
    }
  }
  async function changeSettings(patch) {
    if (patch.floating === true && overlayState(capsRef.current) === false) {
      setGlobalError("\u7CFB\u7EDF\u60AC\u6D6E\u7A97\u6743\u9650\u672A\u5F00\u542F\uFF0C\u4E0D\u80FD\u6253\u5F00\u60AC\u6D6E\u5165\u53E3\u3002\u8BF7\u5230\u7CFB\u7EDF\u8BBE\u7F6E\u5141\u8BB8 DSH \u663E\u793A\u5728\u5176\u4ED6\u5E94\u7528\u4E0A\u5C42\u3002");
      showToast("\u7CFB\u7EDF\u60AC\u6D6E\u7A97\u6743\u9650\u672A\u5F00\u542F");
      return;
    }
    if (patch.floating === true && a11yState(capsRef.current) === false) {
      setGlobalError("\u5171\u4EAB\u65E0\u969C\u788D\u670D\u52A1\u672A\u8FDE\u63A5\uFF0C\u4E0D\u80FD\u6253\u5F00\u60AC\u6D6E\u5165\u53E3\u3002\u8BF7\u5230\u80FD\u529B\u4E2D\u5FC3\u5F00\u542F\u65E0\u969C\u788D\u540E\u91CD\u8BD5\u3002");
      showToast("\u5171\u4EAB\u65E0\u969C\u788D\u670D\u52A1\u672A\u8FDE\u63A5");
      return;
    }
    const previous = settingsRef.current;
    const next = { ...previous, ...patch };
    if (patch.platforms && !patch.platforms.length) {
      showToast("\u81F3\u5C11\u4FDD\u7559\u4E00\u4E2A\u5546\u54C1\u6BD4\u4EF7\u5E73\u53F0");
      return;
    }
    if (patch.travelPlatforms && !patch.travelPlatforms.length) {
      showToast("\u81F3\u5C11\u4FDD\u7559\u4E00\u4E2A\u9152\u5E97/\u673A\u7968\u5E73\u53F0");
      return;
    }
    settingsRef.current = next;
    setSettings(next);
    setSaveHint({ text: "\u6B63\u5728\u4FDD\u5B58\u2026", state: "" });
    try {
      await bridgeRef.current.data.write("settings", next);
      setSaveHint({ text: "\u5DF2\u4FDD\u5B58", state: "" });
      await registerActions(bridgeRef.current, memoryRef.current, next);
      if (Object.prototype.hasOwnProperty.call(patch, "floating")) {
        showToast(next.floating ? "\u60AC\u6D6E\u5165\u53E3\u5DF2\u5F00\u542F" : "\u60AC\u6D6E\u5165\u53E3\u5DF2\u5173\u95ED");
      }
    } catch (error) {
      settingsRef.current = previous;
      setSettings(previous);
      setSaveHint({ text: "\u4FDD\u5B58\u5931\u8D25\uFF1A" + msg(error), state: "error" });
    }
  }
  async function saveMemory(next, successText) {
    const wish = bridgeRef.current;
    const previous = memoryRef.current;
    memoryRef.current = next;
    setMemory(next);
    setSaveHint({ text: "\u6B63\u5728\u4FDD\u5B58\u6BD4\u4EF7\u65B9\u6CD5\u2026", state: "" });
    try {
      await wish.data.write("memory", next);
      setSaveHint({ text: successText || "\u6BD4\u4EF7\u65B9\u6CD5\u5DF2\u4FDD\u5B58", state: "" });
      await registerActions(wish, next, settingsRef.current);
      return { ok: true };
    } catch (error) {
      memoryRef.current = previous;
      setMemory(previous);
      const text = "\u6BD4\u4EF7\u65B9\u6CD5\u4FDD\u5B58\u5931\u8D25\uFF1A" + msg(error);
      setSaveHint({ text, state: "error" });
      return { ok: false, error: text };
    }
  }
  async function beginRun(meta, prompt) {
    const wish = bridgeRef.current;
    if (!wish || !wish.agent) return { ok: false, error: "\u624B\u673A\u6865\u672A\u5C31\u7EEA" };
    const optimistic = {
      ...meta,
      sessionId: "",
      phase: "starting",
      running: true,
      events: [],
      error: "",
      startedAt: meta.startedAt || Date.now(),
      lastProgressAt: Date.now(),
      recordedCount: 0,
      steered: false,
      nudged: false
    };
    partialRef.current = "";
    steeredRef.current = false;
    runRef.current = optimistic;
    setRun(optimistic);
    activeMetaRef.current = { ...meta, startedAt: optimistic.startedAt };
    await writeActive(activeMetaRef.current);
    try {
      const response = await wish.agent.start(prompt);
      if (!response || response.started === false) throw new Error("\u4EFB\u52A1\u6CA1\u6709\u542F\u52A8\uFF0C\u8BF7\u68C0\u67E5\u624B\u673A\u64CD\u63A7\u6388\u6743\u548C\u65E0\u969C\u788D\u670D\u52A1");
      const next = { ...optimistic, sessionId: response.sessionId || "", phase: "running" };
      runRef.current = next;
      setRun(next);
      activeMetaRef.current = { ...activeMetaRef.current, sessionId: next.sessionId };
      await writeActive(activeMetaRef.current);
      return { ok: true };
    } catch (error) {
      const failed = { ...optimistic, phase: "failed", running: false, error: msg(error), finishedAt: Date.now() };
      runRef.current = failed;
      setRun(failed);
      activeMetaRef.current = null;
      await writeActive(null);
      return { ok: false, error: msg(error) };
    }
  }
  function openQuick() {
    setQuickUrl("");
    setQuickError("");
    setGlobalError("");
    setPage("quick");
  }
  async function pasteQuickLink() {
    try {
      if (!navigator.clipboard || typeof navigator.clipboard.readText !== "function") throw new Error("clipboard unavailable");
      const text = await navigator.clipboard.readText();
      const url = firstLinkUrl(text);
      if (!url) {
        showToast("\u526A\u8D34\u677F\u91CC\u6CA1\u6709\u94FE\u63A5\uFF0C\u8BF7\u957F\u6309\u8F93\u5165\u6846\u7C98\u8D34");
        return;
      }
      setQuickUrl(url);
      setQuickError("");
    } catch (error) {
      showToast("\u65E0\u6CD5\u8BFB\u53D6\u526A\u8D34\u677F\uFF0C\u8BF7\u957F\u6309\u8F93\u5165\u6846\u7C98\u8D34");
    }
  }
  function openAdvancedFromQuick() {
    const url = firstLinkUrl(quickUrl);
    const platform = platformFromLink(url);
    const kind = kindFromLink(url, platform);
    const base = blankStart(settingsRef.current);
    setStart({ ...base, kind, url });
    setStartError("");
    setGlobalError("");
    setPage("start");
  }
  async function startLinkComparison() {
    setQuickError("");
    const url = firstLinkUrl(quickUrl);
    if (!url) {
      setQuickError("\u5148\u7C98\u8D34\u4E00\u4E2A\u5546\u54C1 / \u9152\u5E97 / \u673A\u7968\u94FE\u63A5\u3002");
      return;
    }
    if (!phoneGranted) {
      openCaps("\u624B\u673A\u64CD\u63A7\u8FD8\u6CA1\u6709\u6388\u6743\u7ED9\u672C\u4F5C\u54C1\u3002\u6388\u6743\u540E\u8FD4\u56DE\uFF0C\u518D\u70B9\u5F00\u59CB\u6BD4\u4EF7\u3002");
      return;
    }
    if (a11y === false) {
      openCaps("\u624B\u673A\u64CD\u63A7\u5DF2\u6388\u6743\uFF0C\u4F46\u5171\u4EAB\u65E0\u969C\u788D\u670D\u52A1\u6CA1\u6709\u8FDE\u63A5\u3002\u8BF7\u5728\u80FD\u529B\u4E2D\u5FC3\u6253\u5F00\u540E\u8FD4\u56DE\u3002");
      return;
    }
    if (startingRef.current) {
      setQuickError("\u6B63\u5728\u542F\u52A8\uFF0C\u8BF7\u7A0D\u5019\u2026");
      return;
    }
    if (runRef.current && runRef.current.running) {
      setQuickError("\u5DF2\u6709\u4E00\u4E2A\u6BD4\u4EF7\u4EFB\u52A1\u5728\u8FD0\u884C\uFF0C\u5148\u7B49\u5B83\u7ED3\u675F\u6216\u505C\u6B62\u5B83\u3002");
      return;
    }
    const sourcePlatform = platformFromLink(url);
    const kind = kindFromLink(url, sourcePlatform);
    const basePlatforms = sourcePlatform ? kind === "product" ? settingsRef.current.platforms : settingsRef.current.travelPlatforms : settingsRef.current.platforms.concat(settingsRef.current.travelPlatforms || []);
    const targets = basePlatforms.filter(function(id, index) {
      return PLATFORM_MAP[id] && id !== sourcePlatform && basePlatforms.indexOf(id) === index;
    });
    if (!targets.length) {
      setQuickError("\u6CA1\u6709\u53EF\u67E5\u7684\u5176\u4ED6\u5E73\u53F0\uFF0C\u8BF7\u5148\u5728\u8BBE\u7F6E\u91CC\u5F00\u542F\u5E73\u53F0\u3002");
      return;
    }
    startingRef.current = true;
    try {
      const id = uid("p");
      const runId = uid("run");
      const now = Date.now();
      const placeholderItem = kind === "hotel" ? { hotelName: "\u6B63\u5728\u8BFB\u53D6\u94FE\u63A5\u2026", title: "\u6B63\u5728\u8BFB\u53D6\u94FE\u63A5\u2026", url } : { title: "\u6B63\u5728\u8BFB\u53D6\u94FE\u63A5\u2026", url };
      const record = normalizeRecord({
        id,
        createdAt: now,
        updatedAt: now,
        kind,
        item: placeholderItem,
        title: "\u6B63\u5728\u8BFB\u53D6\u94FE\u63A5\u2026",
        spec: "",
        url,
        note: "\u6B63\u5728\u6253\u5F00\u94FE\u63A5\u8BFB\u53D6\u9875\u9762\uFF0C\u8BC6\u522B\u5546\u54C1/\u9152\u5E97/\u673A\u7968\u548C\u9996\u5C4F\u4EF7\u683C\u2026",
        status: "comparing",
        phase: "starting",
        channels: [],
        missing: [],
        assumptions: [],
        eventsTail: [],
        lastRunAt: now
      });
      const previous = recordsRef.current;
      const next = [record].concat(previous).slice(0, 80);
      recordsRef.current = next;
      setRecords(next);
      if (!await writeRecords(next)) {
        recordsRef.current = previous;
        setRecords(previous);
        return;
      }
      const prompt = buildLinkComparePrompt({
        url,
        sourcePlatform,
        kind,
        platforms: targets,
        memory: memoryRef.current,
        runId
      });
      const meta = {
        kind: "compare",
        recordId: id,
        runId,
        mode: "link",
        vertical: kind,
        item: placeholderItem,
        input: {
          kind,
          item: placeholderItem,
          title: "",
          url,
          platforms: targets,
          sourcePlatform,
          quick: true
        },
        openOnFinish: true,
        startedAt: now
      };
      const result = await beginRun(meta, prompt);
      if (!result.ok) {
        recordsRef.current = previous;
        setRecords(previous);
        await writeRecords(previous);
        runRef.current = null;
        setRun(null);
        setQuickError("\u542F\u52A8\u5931\u8D25\uFF1A" + (result.error || "\u672A\u77E5\u9519\u8BEF"));
        return;
      }
      setRecordId(id);
      setPage("record");
      showToast("\u5DF2\u6309\u94FE\u63A5\u5F00\u59CB\u6BD4\u4EF7\uFF0C\u53EF\u4EE5\u9000\u51FA\u9875\u9762");
    } finally {
      startingRef.current = false;
    }
  }
  async function startComparison() {
    setStartError("");
    const wish = bridgeRef.current;
    const value = start;
    const kind = KINDS.indexOf(value.kind) >= 0 ? value.kind : "product";
    const item = itemFromStart(value);
    if (kind === "hotel") {
      if (!str(item.hotelName)) {
        setStartError("\u5148\u586B\u9152\u5E97\u540D\u3002");
        return;
      }
      if (!str(item.checkIn) || !str(item.checkOut)) {
        setStartError("\u9152\u5E97\u6BD4\u4EF7\u8981\u586B\u5165\u4F4F\u548C\u79BB\u5E97\u65E5\u671F\u3002");
        return;
      }
      if (item.rateMode === "specific" && !str(item.roomType)) {
        setStartError("\u5DF2\u9009\u201C\u6307\u5B9A\u623F\u578B\u201D\uFF0C\u8BF7\u586B\u623F\u578B\uFF1B\u6216\u5207\u56DE\u201C\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\u201D\u3002");
        return;
      }
    } else if (kind === "flight") {
      if (!str(item.flightNo)) {
        setStartError("\u5148\u586B\u822A\u73ED\u53F7\u3002");
        return;
      }
      if (!str(item.date)) {
        setStartError("\u673A\u7968\u6BD4\u4EF7\u8981\u586B\u51FA\u53D1\u65E5\u671F\u3002");
        return;
      }
    } else if (!str(item.title)) {
      setStartError("\u5148\u586B\u5546\u54C1\u540D\u3002");
      return;
    }
    if (!phoneGranted) {
      openCaps("\u624B\u673A\u64CD\u63A7\u8FD8\u6CA1\u6709\u6388\u6743\u7ED9\u672C\u4F5C\u54C1\u3002\u6388\u6743\u540E\u8FD4\u56DE\uFF0C\u518D\u70B9\u5F00\u59CB\u6BD4\u4EF7\u3002");
      return;
    }
    if (a11y === false) {
      openCaps("\u624B\u673A\u64CD\u63A7\u5DF2\u6388\u6743\uFF0C\u4F46\u5171\u4EAB\u65E0\u969C\u788D\u670D\u52A1\u6CA1\u6709\u8FDE\u63A5\u3002\u8BF7\u5728\u80FD\u529B\u4E2D\u5FC3\u6253\u5F00\u540E\u8FD4\u56DE\u3002");
      return;
    }
    if (startingRef.current) {
      setStartError("\u6B63\u5728\u542F\u52A8\uFF0C\u8BF7\u7A0D\u5019\u2026");
      return;
    }
    if (runRef.current && runRef.current.running) {
      setStartError("\u5DF2\u6709\u4E00\u4E2A\u6BD4\u4EF7\u4EFB\u52A1\u5728\u8FD0\u884C\uFF0C\u5148\u7B49\u5B83\u7ED3\u675F\u6216\u505C\u6B62\u5B83\u3002");
      return;
    }
    const platforms = startPlatforms(value, settingsRef.current);
    if (!platforms.length) {
      setStartError(kind === "product" ? "\u81F3\u5C11\u9009\u62E9\u4E00\u4E2A\u8981\u67E5\u8BE2\u7684\u5E73\u53F0\u3002" : "\u81F3\u5C11\u9009\u62E9\u4E00\u4E2A\u9152\u5E97/\u673A\u7968\u5E73\u53F0\u3002");
      return;
    }
    const source = value.source && value.skipSource && PLATFORM_MAP[value.source.platform] ? value.source : null;
    const targetPlatforms = source ? platforms.filter(function(id) {
      return id !== source.platform;
    }) : platforms.slice();
    if (!targetPlatforms.length) {
      setStartError("\u9664\u6765\u6E90\u5E73\u53F0\u5916\uFF0C\u81F3\u5C11\u518D\u9009\u4E00\u4E2A\u8981\u6BD4\u4EF7\u7684\u5E73\u53F0\uFF1B\u6216\u8005\u53D6\u6D88\u201C\u8DF3\u8FC7\u6765\u6E90\u5E73\u53F0\u641C\u7D22\u201D\u3002");
      return;
    }
    startingRef.current = true;
    try {
      const id = uid("p");
      const now = Date.now();
      const sourceChannel = channelFromSource(source, kind);
      const record = normalizeRecord({
        id,
        createdAt: now,
        updatedAt: now,
        kind,
        item,
        title: itemTitle(kind, item),
        spec: itemSummary(kind, item),
        url: value.url,
        note: value.note,
        status: "comparing",
        phase: "starting",
        sourcePlatform: source ? source.platform : "",
        sourceStore: source ? source.store || "" : "",
        sourcePrice: source ? source.price : null,
        sourceNote: source ? source.note || "" : "",
        sourceAt: source ? source.at || now : 0,
        capturedFrom: source ? source.from || "candidate" : "manual",
        channels: sourceChannel ? [sourceChannel] : [],
        missing: [],
        assumptions: [],
        eventsTail: [],
        lastRunAt: now
      });
      const previous = recordsRef.current;
      const next = [record].concat(previous).slice(0, 80);
      recordsRef.current = next;
      setRecords(next);
      if (!await writeRecords(next)) {
        recordsRef.current = previous;
        setRecords(previous);
        return;
      }
      const runId = uid("run");
      const prompt = buildComparePrompt({
        kind,
        item,
        title: itemTitle(kind, item),
        spec: itemSummary(kind, item),
        url: value.url,
        note: value.note,
        platforms: targetPlatforms,
        autoCoupon: value.autoCoupon,
        memory: memoryRef.current,
        source,
        runId
      });
      const meta = {
        kind: "compare",
        recordId: id,
        runId,
        vertical: kind,
        item,
        input: {
          kind,
          item,
          title: itemTitle(kind, item),
          spec: itemSummary(kind, item),
          url: value.url,
          platforms: targetPlatforms,
          source,
          sourcePlatform: source ? source.platform : ""
        },
        openOnFinish: true,
        startedAt: now
      };
      const result = await beginRun(meta, prompt);
      if (!result.ok) {
        const rolled = previous;
        recordsRef.current = rolled;
        setRecords(rolled);
        await writeRecords(rolled);
        runRef.current = null;
        setRun(null);
        setStartError("\u542F\u52A8\u5931\u8D25\uFF1A" + (result.error || "\u672A\u77E5\u9519\u8BEF"));
        return;
      }
      setRecordId(id);
      setPage("record");
      showToast(kind === "product" ? "\u6BD4\u4EF7\u4EFB\u52A1\u5DF2\u542F\u52A8\uFF0C\u53EF\u4EE5\u9000\u51FA\u9875\u9762\uFF0C\u4EFB\u52A1\u4F1A\u7EE7\u7EED" : "\u9152\u5E97/\u673A\u7968\u6BD4\u4EF7\u5DF2\u542F\u52A8\uFF0C\u53EF\u4EE5\u9000\u51FA\u9875\u9762\uFF0C\u4EFB\u52A1\u4F1A\u7EE7\u7EED");
    } finally {
      startingRef.current = false;
    }
  }
  async function verifyRecord(record) {
    if (!record) return;
    if (!phoneGranted) {
      openCaps("\u624B\u673A\u64CD\u63A7\u8FD8\u6CA1\u6709\u6388\u6743\u7ED9\u672C\u4F5C\u54C1\u3002\u6388\u6743\u540E\u8FD4\u56DE\uFF0C\u518D\u590D\u6838\u4EF7\u683C\u3002");
      return;
    }
    if (a11y === false) {
      openCaps("\u624B\u673A\u64CD\u63A7\u5DF2\u6388\u6743\uFF0C\u4F46\u5171\u4EAB\u65E0\u969C\u788D\u670D\u52A1\u6CA1\u6709\u8FDE\u63A5\u3002\u8BF7\u5728\u80FD\u529B\u4E2D\u5FC3\u6253\u5F00\u540E\u8FD4\u56DE\u3002");
      return;
    }
    if (runRef.current && runRef.current.running) {
      showToast("\u5DF2\u6709\u4EFB\u52A1\u5728\u8FDB\u884C\uFF0C\u5148\u7B49\u5B83\u7ED3\u675F\u6216\u505C\u6B62\u5B83");
      return;
    }
    const platforms = [];
    (record.channels || []).forEach(function(channel) {
      if (PLATFORM_MAP[channel.platform] && platforms.indexOf(channel.platform) < 0) platforms.push(channel.platform);
    });
    (record.missing || []).forEach(function(item) {
      if (PLATFORM_MAP[item.platform] && platforms.indexOf(item.platform) < 0) platforms.push(item.platform);
    });
    if (!platforms.length) {
      const fallback = record.kind === "hotel" || record.kind === "flight" ? settingsRef.current.travelPlatforms || TRAVEL_PLATFORM_IDS : settingsRef.current.platforms || [];
      fallback.forEach(function(id) {
        if (PLATFORM_MAP[id]) platforms.push(id);
      });
    }
    if (!platforms.length) {
      showToast("\u8FD9\u6761\u8BB0\u5F55\u6CA1\u6709\u53EF\u590D\u6838\u7684\u5E73\u53F0");
      return;
    }
    const previous = (record.channels || []).filter(function(channel) {
      return channel.price != null;
    }).map(function(channel) {
      return platformLabel(channel.platform) + " " + priceWithUnit(channel) + (channel.verifiedAt ? "\uFF08" + formatTime(parseTime(channel.verifiedAt)) + "\uFF09" : "");
    }).join("\uFF1B");
    const runId = uid("verify");
    const prompt = buildComparePrompt({
      kind: record.kind || "product",
      item: record.item,
      title: record.title,
      spec: record.spec,
      url: record.url,
      note: (record.kind === "hotel" ? "\u8FD9\u662F\u9152\u5E97\u4EF7\u683C\u590D\u6838\uFF1A\u540C\u9152\u5E97\u3001\u540C\u57CE\u5E02\u3001\u540C\u5165\u4F4F/\u79BB\u5E97\u65E5\u671F\u3001\u540C\u623F\u578B/\u5E8A\u578B/\u65E9\u9910/\u53D6\u6D88\u653F\u7B56\uFF1B\u53EA\u770B\u9996\u5C4F\u6BCF\u665A\u4EF7\uFF0C\u9ED8\u8BA4\u4E0D\u4E0B\u6ED1\u3002" : record.kind === "flight" ? "\u8FD9\u662F\u673A\u7968\u4EF7\u683C\u590D\u6838\uFF1A\u540C\u822A\u73ED\u53F7\u3001\u540C\u65E5\u671F\u3001\u540C\u822A\u7EBF\u3001\u540C\u8231\u4F4D/\u884C\u674E\uFF1B\u53EA\u770B\u9996\u5C4F\u7968\u4EF7\uFF0C\u9ED8\u8BA4\u4E0D\u4E0B\u6ED1\u3002" : "\u8FD9\u662F\u4EF7\u683C\u590D\u6838\uFF1A\u5546\u54C1\u6807\u9898\u548C\u89C4\u683C\u4E0D\u53D8\uFF0C\u5FC5\u987B\u6838\u5BF9\u989C\u8272/\u6B3E\u5F0F/\u5C3A\u7801\u662F\u5426\u4E00\u81F4\uFF1B\u53EA\u770B\u5546\u54C1\u9996\u5C4F\u4EF7\u683C\uFF0C\u9ED8\u8BA4\u4E0D\u4E0B\u6ED1\u3002") + (previous ? "\u4E0A\u6B21\u8BB0\u5F55\uFF1A" + previous + "\uFF1B\u4E0A\u6B21\u4EF7\u683C\u53EA\u4F5C\u53C2\u8003\uFF0C\u4E0D\u8981\u6CBF\u7528\u3002" : "") + "\u627E\u4E0D\u5230\u540C\u6B3E/\u540C\u623F\u578B/\u540C\u822A\u73ED\u6216\u6761\u4EF6\u4E0D\u540C\uFF0C\u8BB0\u5F55\u5DEE\u5F02\u5E76\u5199 missing/matchNote\uFF0C\u4E0D\u8981\u6362\u5546\u54C1\u3002",
      platforms,
      autoCoupon: settingsRef.current.autoCoupon !== false,
      memory: memoryRef.current,
      source: null,
      runId
    });
    const now = Date.now();
    const backup = recordsRef.current;
    const next = recordsRef.current.map(function(item) {
      if (item.id !== record.id) return item;
      return {
        ...item,
        status: "comparing",
        phase: "starting",
        updatedAt: now,
        lastRunAt: now,
        note: "\u6B63\u5728\u590D\u6838\u5E73\u53F0\u4EF7\u683C\u2026"
      };
    });
    recordsRef.current = next;
    setRecords(next);
    await writeRecords(next);
    const meta = {
      kind: "compare",
      recordId: record.id,
      runId,
      mode: "verify",
      vertical: record.kind || "product",
      item: record.item,
      input: {
        kind: record.kind || "product",
        item: record.item,
        title: record.title,
        spec: record.spec,
        url: record.url,
        platforms,
        verify: true
      },
      openOnFinish: true,
      startedAt: now
    };
    const result = await beginRun(meta, prompt);
    if (!result.ok) {
      recordsRef.current = backup;
      setRecords(backup);
      await writeRecords(backup);
      setGlobalError("\u590D\u6838\u542F\u52A8\u5931\u8D25\uFF1A" + (result.error || "\u672A\u77E5\u9519\u8BEF"));
      return;
    }
    showToast(kindLabel(record.kind) + "\u590D\u6838\u5DF2\u542F\u52A8\uFF1A" + platforms.map(platformLabel).join("\u3001"));
  }
  async function stopRun() {
    const wish = bridgeRef.current;
    if (!wish || !wish.agent) return;
    try {
      await wish.agent.stop();
      showToast("\u5DF2\u8BF7\u6C42\u505C\u6B62\u4EFB\u52A1");
    } catch (error) {
      showToast("\u505C\u6B62\u5931\u8D25\uFF1A" + msg(error));
    }
  }
  async function openTask() {
    const wish = bridgeRef.current;
    if (!wish || !wish.agent) return;
    try {
      await wish.agent.open();
    } catch (error) {
      showToast("\u6253\u5F00\u4EFB\u52A1\u5BF9\u8BDD\u5931\u8D25\uFF1A" + msg(error));
    }
  }
  async function markAgentResult(result) {
    if (!result) return;
    const record = { fingerprint: fingerprintOf(result), importedAt: Date.now() };
    lastResultRef.current = record;
    try {
      await bridgeRef.current.data.write("lastAgentResult", record);
    } catch (error) {
    }
  }
  async function importAgentResultIfNew(status, options) {
    const silent = !!(options && options.silent);
    const wish = bridgeRef.current;
    if (!wish || !wish.agent || typeof wish.agent.results !== "function") return false;
    if (runRef.current && runRef.current.running) return false;
    let result = null;
    try {
      result = await wish.agent.results();
    } catch (error) {
      return false;
    }
    if (!isObj(result)) return false;
    const fingerprint = fingerprintOf(result);
    if (lastResultRef.current && lastResultRef.current.fingerprint === fingerprint) return false;
    const kind = inferResultKind(result);
    if (kind === "candidate") {
      const candidate = normalizeCandidateResult(result);
      if (!candidate) {
        if (!silent) showToast("\u60AC\u6D6E\u5165\u53E3\u7684\u5019\u9009\u6CA1\u6709\u8BFB\u5230\u5546\u54C1\u540D\uFF0C\u53EF\u6253\u5F00\u4EFB\u52A1\u5BF9\u8BDD\u67E5\u770B");
        return false;
      }
      await markAgentResult(result);
      const next2 = [candidate].concat(
        candidatesRef.current.filter(function(item) {
          return !(item.title === candidate.title && item.spec === candidate.spec);
        })
      ).slice(0, 60);
      candidatesRef.current = next2;
      setCandidates(next2);
      await writeCandidates(next2);
      if (!silent) showToast("\u5DF2\u8BB0\u4E0B\uFF1A" + candidate.title);
      return true;
    }
    const parsed = normalizeCompareResult(result);
    if (!parsed) {
      const failureNote = isObj(result) && str(result.note) ? str(result.note) : "\u4EFB\u52A1\u6CA1\u6709\u8BFB\u5230\u9875\u9762\u6216\u5546\u54C1\u4FE1\u606F\uFF0C\u672A\u5B8C\u6210\u3002\u8BF7\u68C0\u67E5\u65E0\u969C\u788D\u670D\u52A1\u540E\u91CD\u8BD5\u3002";
      const failure = normalizeRecord({
        id: uid("p"),
        createdAt: Date.now(),
        updatedAt: Date.now(),
        kind: isObj(result) && KINDS.indexOf(result.vertical) >= 0 ? result.vertical : "product",
        item: isObj(result) && isObj(result.item) ? result.item : { title: "\u6BD4\u4EF7\u672A\u5F00\u59CB" },
        title: isObj(result) && str(result.title) ? str(result.title) : "\u6BD4\u4EF7\u672A\u5F00\u59CB",
        spec: isObj(result) && str(result.spec) ? str(result.spec) : "",
        note: failureNote,
        status: "failed",
        phase: "failed",
        channels: [],
        missing: normalizeMissing(isObj(result) ? result.missing : []),
        assumptions: [],
        eventsTail: [],
        lastRunAt: Date.now()
      });
      await markAgentResult(result);
      const failureNext = [failure].concat(
        recordsRef.current.filter(function(item) {
          return item.id !== failure.id;
        })
      ).slice(0, 80);
      recordsRef.current = failureNext;
      setRecords(failureNext);
      await writeRecords(failureNext);
      updateWidget(failureNext);
      if (!silent) showToast("\u6BD4\u4EF7\u672A\u5F00\u59CB\uFF1A" + clampText(failureNote, 80));
      if (!silent && navRef.current.page === "home") {
        setRecordId(failure.id);
        setPage("record");
      }
      return true;
    }
    const existing = recordsRef.current.find(function(item) {
      if (parsed.runId && item.runId && parsed.runId === item.runId) return true;
      if (str(parsed.title) && str(parsed.title) === str(item.title) && (!parsed.kind || !item.kind || parsed.kind === item.kind)) return true;
      if (parsed.kind === "hotel" && item.kind === "hotel" && parsed.item && item.item) {
        return str(parsed.item.hotelName) && str(parsed.item.hotelName) === str(item.item.hotelName) && str(parsed.item.checkIn) === str(item.item.checkIn);
      }
      if (parsed.kind === "flight" && item.kind === "flight" && parsed.item && item.item) {
        return str(parsed.item.flightNo) && str(parsed.item.flightNo) === str(item.item.flightNo) && str(parsed.item.date) === str(item.item.date);
      }
      return false;
    });
    await markAgentResult(result);
    if (existing) {
      await refreshRecord(existing, { silent: true });
      if (!silent) showToast("\u5DF2\u66F4\u65B0\u6700\u65B0\u6293\u4EF7\uFF1A" + (parsed.title || itemTitle(parsed.kind, parsed.item)));
      return true;
    }
    const sourceChannel = parsed.sourcePlatform ? parsed.channels.find(function(channel) {
      return channel.platform === parsed.sourcePlatform;
    }) : null;
    const record = normalizeRecord({
      id: uid("p"),
      createdAt: Date.now(),
      updatedAt: Date.now(),
      kind: parsed.kind,
      item: parsed.item,
      title: parsed.title || itemTitle(parsed.kind, parsed.item),
      spec: parsed.spec || itemSummary(parsed.kind, parsed.item),
      url: "",
      note: [parsed.note, parsed.needsUser ? "\u9700\u8981\u4F60\u786E\u8BA4\u89C4\u683C\u6216\u767B\u5F55\u72B6\u6001\u3002" : ""].filter(Boolean).join(" "),
      status: parsed.channels.length ? parsed.needsUser ? "interrupted" : "done" : "failed",
      phase: "succeeded",
      sourcePlatform: parsed.sourcePlatform,
      sourceStore: sourceChannel ? sourceChannel.store : "",
      sourcePrice: sourceChannel ? sourceChannel.price : null,
      sourceNote: sourceChannel ? sourceChannel.note : "",
      sourceAt: sourceChannel ? parseTime(sourceChannel.verifiedAt) : 0,
      capturedFrom: parsed.capturedFrom || (parsed.sourcePlatform ? "current-page" : "manual"),
      channels: parsed.channels,
      missing: parsed.missing,
      assumptions: parsed.assumptions,
      eventsTail: [],
      sessionId: status && status.sessionId || "",
      lastRunAt: Date.now()
    });
    const next = [record].concat(recordsRef.current).slice(0, 80);
    recordsRef.current = next;
    setRecords(next);
    await writeRecords(next);
    updateWidget(next);
    if (!silent) showToast("\u5DF2\u5BFC\u5165\u60AC\u6D6E\u5165\u53E3\u7684\u6BD4\u4EF7\u7ED3\u679C");
    if (!silent && navRef.current.page === "home") {
      setRecordId(record.id);
      setPage("record");
    }
    return true;
  }
  async function refreshLatestResult() {
    if (refreshingLatest) return;
    setRefreshingLatest(true);
    try {
      const imported = await importAgentResultIfNew(null, { silent: false });
      if (!imported) showToast("\u6CA1\u6709\u65B0\u7684\u6293\u4EF7\u7ED3\u679C");
    } finally {
      setRefreshingLatest(false);
    }
  }
  async function refreshRecord(record, options) {
    const silent = !!(options && options.silent);
    if (!record || refreshing === record.id) return false;
    const wish = bridgeRef.current;
    if (!wish || !wish.agent || typeof wish.agent.results !== "function") {
      if (!silent) showToast("\u5F53\u524D\u73AF\u5883\u4E0D\u652F\u6301\u62C9\u53D6\u6293\u4EF7\u7ED3\u679C");
      return false;
    }
    setRefreshing(record.id);
    try {
      const result = await wish.agent.results();
      if (!isObj(result)) {
        if (!silent) showToast("\u8FD8\u6CA1\u6709\u53EF\u62C9\u53D6\u7684\u6700\u65B0\u6293\u4EF7\u7ED3\u679C");
        return false;
      }
      const parsed = normalizeCompareResult(result);
      if (!parsed) {
        if (!silent) showToast(clampText(isObj(result) && str(result.note) || "\u6700\u65B0\u7ED3\u679C\u4E0D\u662F\u4EF7\u683C\u8BB0\u5F55", 90));
        return false;
      }
      const sameRun = !!(parsed.runId && record.runId && parsed.runId === record.runId);
      const parsedTitle = str(parsed.title);
      const sameTitle = !!(parsedTitle && parsedTitle === str(record.title));
      const sameHotel = !!(record.kind === "hotel" && parsed.item && record.item && str(parsed.item.hotelName) && str(parsed.item.hotelName) === str(record.item.hotelName));
      const sameFlight = !!(record.kind === "flight" && parsed.item && record.item && str(parsed.item.flightNo) && str(parsed.item.flightNo) === str(record.item.flightNo));
      if (!sameRun && !sameTitle && !sameHotel && !sameFlight) {
        if (!silent) showToast("\u6700\u65B0\u6293\u4EF7\u4E0D\u5C5E\u4E8E\u8FD9\u6761\u8BB0\u5F55\uFF0C\u672A\u5408\u5E76");
        return false;
      }
      const channels = mergeChannels(record.channels, parsed.channels);
      const sourceChannel = parsed.sourcePlatform ? channels.find(function(channel) {
        return channel.platform === parsed.sourcePlatform;
      }) : null;
      const nextStatus = parsed.partial ? "comparing" : parsed.channels.length ? parsed.needsUser ? "interrupted" : "done" : record.status;
      const next = normalizeRecord({
        ...record,
        kind: parsed.kind || record.kind,
        item: parsed.item || record.item,
        title: parsed.title || record.title,
        spec: parsed.spec || record.spec,
        note: parsed.note || record.note,
        status: nextStatus,
        phase: parsed.partial ? "running" : "succeeded",
        updatedAt: Date.now(),
        runId: parsed.runId || record.runId,
        sourcePlatform: parsed.sourcePlatform || record.sourcePlatform,
        sourceStore: sourceChannel ? sourceChannel.store : record.sourceStore,
        sourcePrice: sourceChannel ? sourceChannel.price : record.sourcePrice,
        sourceNote: sourceChannel ? sourceChannel.note : record.sourceNote,
        sourceAt: sourceChannel ? parseTime(sourceChannel.verifiedAt) : record.sourceAt,
        capturedFrom: parsed.capturedFrom || record.capturedFrom,
        channels,
        missing: parsed.missing || [],
        assumptions: parsed.assumptions && parsed.assumptions.length ? parsed.assumptions : record.assumptions,
        lastRunAt: Date.now()
      });
      const unchanged = JSON.stringify(next.channels) === JSON.stringify(record.channels) && next.note === record.note && next.status === record.status && next.title === record.title && next.spec === record.spec;
      if (unchanged) {
        if (!silent) showToast("\u5DF2\u662F\u6700\u65B0\u6293\u4EF7");
        return false;
      }
      const nextRecords = recordsRef.current.map(function(item) {
        return item.id === record.id ? next : item;
      });
      recordsRef.current = nextRecords;
      setRecords(nextRecords);
      await writeRecords(nextRecords);
      updateWidget(nextRecords);
      await markAgentResult(result);
      showToast(silent ? "\u6BD4\u4EF7\u5B8C\u6210\uFF0C\u7ED3\u679C\u5DF2\u81EA\u52A8\u5237\u65B0" : "\u5DF2\u5237\u65B0\u6700\u65B0\u6293\u4EF7");
      return true;
    } catch (error) {
      if (!silent) showToast("\u5237\u65B0\u5931\u8D25\uFF1A" + msg(error));
      return false;
    } finally {
      setRefreshing("");
    }
  }
  async function reconcileStaleRuns() {
    if (runRef.current && runRef.current.running) return;
    const now = Date.now();
    const stale = recordsRef.current.filter(function(item) {
      return item.status === "comparing" && now - (item.lastRunAt || item.updatedAt || 0) > 10 * 6e4;
    });
    if (!stale.length) return;
    const staleIds = {};
    stale.forEach(function(item) {
      staleIds[item.id] = true;
    });
    const next = recordsRef.current.map(function(item) {
      if (!staleIds[item.id]) return item;
      return {
        ...item,
        status: "interrupted",
        updatedAt: now,
        note: [item.note, "\u4EFB\u52A1\u5728\u540E\u53F0\u4E2D\u65AD\uFF0C\u6CA1\u6709\u62FF\u5230\u53EF\u786E\u8BA4\u7684\u7ED3\u679C\u3002\u53EF\u4EE5\u91CD\u65B0\u6BD4\u4EF7\u3002"].filter(Boolean).join(" ").slice(0, 500)
      };
    });
    recordsRef.current = next;
    setRecords(next);
    await writeRecords(next);
  }
  async function syncAgent() {
    const wish = bridgeRef.current;
    if (!wish || !wish.agent) return;
    let status = null;
    try {
      status = await wish.agent.status();
    } catch (error) {
      status = null;
    }
    if (status && (status.sessionId || status.running)) {
      const meta = activeMetaRef.current || { kind: "", recordId: "", startedAt: Date.now() };
      if (TERMINAL[status.phase]) {
        await finalizeRef.current(meta, status);
        return;
      }
      if (status.running || ["starting", "paused", "awaiting-confirmation"].indexOf(status.phase) >= 0) {
        const next = {
          ...meta,
          sessionId: status.sessionId || meta.sessionId || "",
          phase: status.phase || "running",
          running: true,
          events: Array.isArray(status.events) ? status.events : [],
          startedAt: meta.startedAt || Date.now(),
          lastProgressAt: meta.lastProgressAt || Date.now(),
          recordedCount: meta.recordedCount || 0,
          steered: meta.steered === true,
          nudged: meta.nudged === true
        };
        runRef.current = next;
        setRun(next);
        if (!next.recordId) await ensurePlaceholder(next, status);
        let partial = null;
        try {
          partial = await wish.agent.results();
        } catch (error) {
          partial = null;
        }
        const parsedPartial = normalizeCompareResult(partial);
        if (parsedPartial && applyPartialRef.current) {
          await applyPartialRef.current(next, parsedPartial, status);
        }
        return;
      }
    }
    await importAgentResultIfNew(status);
    await reconcileStaleRuns();
  }
  async function ensurePlaceholder(meta, status) {
    if (meta && meta.recordId) {
      const existing = recordsRef.current.find(function(item) {
        return item.id === meta.recordId;
      });
      if (existing) return meta.recordId;
    }
    const now = Date.now();
    const id = meta && meta.recordId || uid("p");
    const record = normalizeRecord({
      id,
      createdAt: now,
      updatedAt: now,
      kind: "product",
      item: { title: "\u6B63\u5728\u8BFB\u53D6\u5F53\u524D\u9875\u2026" },
      title: "\u6B63\u5728\u8BFB\u53D6\u5F53\u524D\u9875\u2026",
      spec: "",
      status: "comparing",
      phase: status && status.phase || "running",
      note: "\u52A9\u624B\u6B63\u5728\u8BFB\u53D6\u5F53\u524D\u9875\u548C\u9996\u5C4F\u4EF7\u683C\uFF0C\u7ED3\u679C\u4F1A\u8FB9\u6838\u9A8C\u8FB9\u5199\u5165\uFF1B\u53EF\u4EE5\u79BB\u5F00\u9875\u9762\u3002",
      channels: [],
      missing: [],
      assumptions: [],
      eventsTail: [],
      lastRunAt: now
    });
    const next = [record].concat(
      recordsRef.current.filter(function(item) {
        return item.id !== record.id;
      })
    ).slice(0, 80);
    recordsRef.current = next;
    setRecords(next);
    await writeRecords(next);
    if (meta) meta.recordId = id;
    const active2 = activeMetaRef.current || {
      kind: meta && meta.kind || "",
      recordId: id,
      startedAt: meta && meta.startedAt || now,
      sessionId: status && status.sessionId || ""
    };
    active2.recordId = id;
    active2.sessionId = status && status.sessionId || active2.sessionId || "";
    activeMetaRef.current = active2;
    await writeActive(active2);
    if (runRef.current) {
      runRef.current = { ...runRef.current, recordId: id };
      setRun(function(previous) {
        return previous ? { ...previous, recordId: id } : previous;
      });
    }
    if (navRef.current.page === "home") {
      setRecordId(id);
      setPage("record");
    }
    return id;
  }
  async function applyPartialResult(meta, parsed, status) {
    if (!parsed || !parsed.channels.length || parsed.partial !== true) return false;
    const writtenAt = parseTime(parsed.writtenAt);
    if (!writtenAt && !(meta && meta.runId && parsed.runId === meta.runId)) return false;
    if (writtenAt && Date.now() - writtenAt > 2 * 60 * 60 * 1e3) return false;
    if (meta && meta.runId && parsed.runId && parsed.runId !== meta.runId) return false;
    const input = meta && meta.input || {};
    const existing = meta && meta.recordId ? recordsRef.current.find(function(item2) {
      return item2.id === meta.recordId;
    }) : null;
    if (existing && ["done", "failed", "stopped", "interrupted"].indexOf(existing.status) >= 0) return false;
    const kind = parsed.kind || input.kind || existing && existing.kind || "product";
    const item = parsed.item || existing && existing.item || normalizeItem(kind, input.item || input);
    const title = parsed.title || input.title || existing && existing.title || itemTitle(kind, item);
    if (!title) return false;
    const channels = mergeChannels(existing ? existing.channels : [], parsed.channels);
    if (input.source && input.source.price != null && !channels.some(function(channel) {
      return channel.platform === input.source.platform;
    })) {
      const synthetic = channelFromSource(input.source);
      if (synthetic) channels.unshift(synthetic);
    }
    const fingerprint = fingerprintOf({
      title,
      spec: parsed.spec,
      channels,
      missing: parsed.missing,
      assumptions: parsed.assumptions,
      source: parsed.sourcePlatform
    });
    if (partialRef.current === fingerprint) return false;
    partialRef.current = fingerprint;
    const id = existing && existing.id || meta && meta.recordId || uid("p");
    const sourcePlatform = parsed.sourcePlatform || input.source && input.source.platform || existing && existing.sourcePlatform || "";
    const resultSource = sourcePlatform ? channels.find(function(channel) {
      return channel.platform === sourcePlatform;
    }) : null;
    const sourceInfo = (input.source && input.source.price != null ? input.source : null) || (resultSource ? {
      platform: sourcePlatform,
      price: resultSource.price,
      store: resultSource.store,
      note: resultSource.note,
      at: parseTime(resultSource.verifiedAt),
      from: parsed.capturedFrom || "current-page"
    } : null) || (existing && existing.sourcePlatform ? {
      platform: existing.sourcePlatform,
      price: existing.sourcePrice,
      store: existing.sourceStore,
      note: existing.sourceNote,
      at: existing.sourceAt,
      from: existing.capturedFrom
    } : null);
    let note = existing && existing.note || parsed.note || "";
    if (!note || note.indexOf("\u6BD4\u4EF7\u8FDB\u884C\u4E2D") === 0 || note.indexOf("\u6B63\u5728\u590D\u6838") === 0) {
      note = (meta && meta.mode === "verify" ? "\u6B63\u5728\u590D\u6838\u4EF7\u683C\uFF0C\u5DF2\u66F4\u65B0 " : "\u6BD4\u4EF7\u8FDB\u884C\u4E2D\uFF0C\u5DF2\u8BB0\u5F55 ") + channels.filter(function(channel) {
        return channel.price != null;
      }).length + " \u4E2A\u4EF7\u683C";
    }
    const record = normalizeRecord({
      id,
      createdAt: existing && existing.createdAt || Date.now(),
      updatedAt: Date.now(),
      kind,
      item,
      title,
      spec: parsed.spec || input.spec || existing && existing.spec || itemSummary(kind, item),
      url: input.url || existing && existing.url || "",
      note: note.slice(0, 500),
      status: "comparing",
      phase: status && status.phase || "running",
      sessionId: status && status.sessionId || meta && meta.sessionId || existing && existing.sessionId || "",
      sourcePlatform: sourceInfo ? sourceInfo.platform : sourcePlatform,
      sourceStore: sourceInfo ? sourceInfo.store || "" : "",
      sourcePrice: sourceInfo ? sourceInfo.price : null,
      sourceNote: sourceInfo ? sourceInfo.note || "" : "",
      sourceAt: sourceInfo ? sourceInfo.at || 0 : 0,
      capturedFrom: sourceInfo ? sourceInfo.from || "current-page" : "manual",
      channels,
      missing: parsed.missing.filter(function(item2) {
        return !channels.some(function(channel) {
          return channel.platform === item2.platform;
        });
      }),
      assumptions: parsed.assumptions,
      eventsTail: status && Array.isArray(status.events) ? historyTail(status.events) : existing ? existing.eventsTail : [],
      lastRunAt: Date.now(),
      reminderAt: existing ? existing.reminderAt : 0,
      reminderTiming: existing ? existing.reminderTiming : ""
    });
    const next = [record].concat(
      recordsRef.current.filter(function(item2) {
        return item2.id !== record.id;
      })
    ).sort(function(a, b) {
      return b.updatedAt - a.updatedAt;
    }).slice(0, 80);
    recordsRef.current = next;
    setRecords(next);
    await writeRecords(next);
    if (meta) {
      meta.recordId = id;
      if (!meta.runId && parsed.runId) meta.runId = parsed.runId;
      meta.vertical = kind;
      meta.item = item;
    }
    const activeMeta = activeMetaRef.current || {
      kind: meta && meta.kind || "",
      recordId: id,
      startedAt: meta && meta.startedAt || runRef.current && runRef.current.startedAt || Date.now(),
      sessionId: status && status.sessionId || "",
      runId: meta && meta.runId || parsed.runId || "",
      vertical: kind,
      item
    };
    activeMeta.recordId = id;
    activeMeta.runId = activeMeta.runId || parsed.runId || "";
    activeMeta.vertical = kind;
    activeMeta.item = item;
    activeMeta.sessionId = status && status.sessionId || activeMeta.sessionId || "";
    activeMetaRef.current = activeMeta;
    await writeActive(activeMeta);
    const count = channels.filter(function(channel) {
      return channel.price != null;
    }).length;
    if (runRef.current) {
      runRef.current = { ...runRef.current, recordId: id, lastProgressAt: Date.now(), recordedCount: count };
      setRun(function(previous) {
        return previous ? { ...previous, recordId: id, lastProgressAt: Date.now(), recordedCount: count } : previous;
      });
    }
    const wish = bridgeRef.current;
    const currentRun = runRef.current;
    if (currentRun && !currentRun.steered && (!status || status.running !== false) && wish && wish.agent && typeof wish.agent.steer === "function") {
      currentRun.steered = true;
      steeredRef.current = true;
      setRun(function(previous) {
        return previous ? { ...previous, steered: true } : previous;
      });
      try {
        const targets = selectedPlatformNames(settingsRef.current.platforms || []);
        await wish.agent.steer(
          "\u6765\u6E90\u9875\u5DF2\u7ECF\u4FDD\u5B58\u3002\u4E0D\u8981\u518D\u56DE\u5F53\u524D\u5E73\u53F0\uFF0C\u4E5F\u4E0D\u8981\u8FDB\u5E97\u94FA\u9875\u3001\u8BC4\u4EF7\u9875\u6216\u5238\u4E2D\u5FC3\uFF1B\u73B0\u5728\u6309\u987A\u5E8F\u67E5 " + targets + "\uFF0C\u8DF3\u8FC7\u5F53\u524D\u5E73\u53F0\uFF0C\u6BCF\u4E2A App \u53EA\u8FDB\u4E00\u6B21\uFF0C\u6700\u591A\u7EA6 12 \u6B65\uFF0C\u67E5\u5B8C\u4E00\u4E2A\u7ACB\u523B\u66F4\u65B0 agent-results.json\uFF0C\u7136\u540E\u7EE7\u7EED\u4E0B\u4E00\u4E2A\u3002"
        );
      } catch (error) {
      }
    }
    return true;
  }
  applyPartialRef.current = applyPartialResult;
  async function finalizeRun(meta, status) {
    const wish = bridgeRef.current;
    const phase = status && status.phase || meta && meta.phase || "stopped";
    const sessionId = status && status.sessionId || meta && meta.sessionId || "";
    const key = sessionId + ":" + phase + ":" + (meta && meta.recordId || "");
    if (guardRef.current === key) return;
    guardRef.current = key;
    let result = null;
    try {
      result = await wish.agent.results();
    } catch (error) {
      result = null;
    }
    const events = status && Array.isArray(status.events) ? status.events : [];
    if (result == null) {
      const parsed2 = parseJsonLoose(lastText(events));
      if (parsed2) result = parsed2;
    }
    const resultFingerprint = result ? fingerprintOf(result) : "";
    const alreadyImported = !!resultFingerprint && !(meta && meta.recordId) && lastResultRef.current && lastResultRef.current.fingerprint === resultFingerprint;
    if (alreadyImported) {
      activeMetaRef.current = null;
      await writeActive(null);
      if (runRef.current) {
        const settled = { ...runRef.current, running: false, phase, finishedAt: Date.now() };
        runRef.current = settled;
        setRun(settled);
      }
      return;
    }
    if (result) await markAgentResult(result);
    const resultKind = meta && meta.kind || inferResultKind(result) || "compare";
    const finished = {
      ...meta || {},
      kind: resultKind,
      sessionId,
      phase,
      running: false,
      events,
      error: status && status.error ? str(status.error) : "",
      finishedAt: Date.now()
    };
    runRef.current = finished;
    setRun(finished);
    activeMetaRef.current = null;
    await writeActive(null);
    if (resultKind === "candidate") {
      const candidate = normalizeCandidateResult(result);
      if (!candidate) {
        setGlobalError("\u4EFB\u52A1\u7ED3\u675F\uFF0C\u4F46\u6CA1\u6709\u8BFB\u5230\u5546\u54C1\u4FE1\u606F\u3002\u53EF\u4EE5\u6253\u5F00\u4EFB\u52A1\u5BF9\u8BDD\u67E5\u770B\u52A9\u624B\u770B\u5230\u4E86\u4EC0\u4E48\uFF0C\u6216\u624B\u52A8\u586B\u5199\u3002");
        return;
      }
      const next = [candidate].concat(candidatesRef.current).slice(0, 60);
      candidatesRef.current = next;
      setCandidates(next);
      await writeCandidates(next);
      showToast("\u5DF2\u8BB0\u4E0B\uFF1A" + candidate.title + "\uFF08\u6BD4\u4EF7\u65F6\u53EA\u67E5\u5176\u4ED6\u5E73\u53F0\uFF09");
      return;
    }
    const parsed = normalizeCompareResult(result);
    const input = meta && meta.input || {};
    const existing = meta && meta.recordId ? recordsRef.current.find(function(item2) {
      return item2.id === meta.recordId;
    }) : null;
    const kind = parsed && parsed.kind || input.kind || existing && existing.kind || "product";
    const item = parsed && parsed.item || input.item || existing && existing.item || normalizeItem(kind, input);
    const hasItemTitle = kind === "hotel" ? !!str(item.hotelName || item.title) : kind === "flight" ? !!str(item.flightNo || item.title) : !!str(item.title);
    const parsedEmpty = !!parsed && parsed.channels.length === 0 && !str(input.title) && !(isObj(result) && str(result.title)) && !(existing && existing.title) && !hasItemTitle;
    if ((!parsed || parsedEmpty) && !str(input.title) && !(isObj(result) && str(result.title)) && !(existing && existing.title) && !hasItemTitle) {
      const failureNote = isObj(result) && str(result.note) ? str(result.note) : "\u6CA1\u6709\u8BFB\u5230\u9875\u9762\u6216\u5546\u54C1\u4FE1\u606F\uFF0C\u4EFB\u52A1\u672A\u5B8C\u6210\u3002\u8BF7\u68C0\u67E5\u65E0\u969C\u788D\u670D\u52A1\u540E\u91CD\u8BD5\u3002";
      const failureId = meta && meta.recordId || uid("p");
      const failure = normalizeRecord({
        id: failureId,
        createdAt: Date.now(),
        updatedAt: Date.now(),
        kind,
        item,
        title: "\u6BD4\u4EF7\u672A\u5F00\u59CB",
        spec: "",
        note: failureNote,
        status: "failed",
        phase,
        sessionId,
        channels: [],
        missing: [],
        assumptions: [],
        eventsTail: historyTail(events),
        lastRunAt: Date.now()
      });
      const failureNext = [failure].concat(
        recordsRef.current.filter(function(item2) {
          return item2.id !== failure.id;
        })
      ).slice(0, 80);
      recordsRef.current = failureNext;
      setRecords(failureNext);
      await writeRecords(failureNext);
      setGlobalError(failureNote);
      if (navRef.current.page === "home") {
        setRecordId(failure.id);
        setPage("record");
      }
      return;
    }
    const selectedPlatforms = Array.isArray(input.platforms) ? input.platforms.filter(function(id2) {
      return !!PLATFORM_MAP[id2];
    }) : [];
    const inputSource = input.source && PLATFORM_MAP[input.source.platform] ? input.source : null;
    const sourcePlatform = parsed && parsed.sourcePlatform || inputSource && inputSource.platform || str(input.sourcePlatform) || existing && existing.sourcePlatform || "";
    const channels = mergeChannels(existing ? existing.channels : [], parsed ? parsed.channels : []);
    if (inputSource && inputSource.price != null) {
      const sourceIndex = channels.findIndex(function(channel) {
        return channel.platform === inputSource.platform;
      });
      if (sourceIndex < 0) {
        const synthetic = channelFromSource(inputSource, kind);
        if (synthetic) channels.unshift(synthetic);
      } else if (channels[sourceIndex].price == null) {
        channels[sourceIndex] = {
          ...channels[sourceIndex],
          price: inputSource.price,
          store: channels[sourceIndex].store || inputSource.store || "",
          url: channels[sourceIndex].url || inputSource.url || "",
          verifiedAt: channels[sourceIndex].verifiedAt || new Date(inputSource.at || Date.now()).toISOString(),
          note: [channels[sourceIndex].note, "\u6765\u6E90\u9875\u4EF7\u683C\u7531\u5019\u9009\u5E26\u5165"].filter(Boolean).join(" \xB7 ")
        };
      }
    }
    const missingRows = parsed ? parsed.missing.slice() : [];
    selectedPlatforms.forEach(function(id2) {
      const coveredByChannel = channels.some(function(channel) {
        return channel.platform === id2;
      });
      const coveredByMissing = missingRows.some(function(item2) {
        return item2.platform === id2;
      });
      if (!coveredByChannel && !coveredByMissing) {
        missingRows.push({ platform: id2, reason: "\u4EFB\u52A1\u7ED3\u675F\u65F6\u6CA1\u6709\u6838\u9A8C\u5230\u8FD9\u4E2A\u5E73\u53F0" });
      }
    });
    const id = existing && existing.id || meta && meta.recordId || uid("p");
    const title = parsed && parsed.title || input.title || existing && existing.title || itemTitle(kind, item);
    const spec = parsed && parsed.spec || input.spec || existing && existing.spec || itemSummary(kind, item);
    const url = parsed && parsed.url || input.url || existing && existing.url || "";
    const resultSource = sourcePlatform ? channels.find(function(channel) {
      return channel.platform === sourcePlatform;
    }) : null;
    const sourceInfo = inputSource || (resultSource ? {
      platform: sourcePlatform,
      price: resultSource.price,
      store: resultSource.store,
      url: resultSource.url,
      note: resultSource.note,
      at: parseTime(resultSource.verifiedAt),
      from: parsed && parsed.capturedFrom ? parsed.capturedFrom : existing ? existing.capturedFrom : "current-page"
    } : null) || (existing && existing.sourcePlatform ? {
      platform: existing.sourcePlatform,
      price: existing.sourcePrice,
      store: existing.sourceStore,
      url: "",
      note: existing.sourceNote,
      at: existing.sourceAt,
      from: existing.capturedFrom
    } : null);
    let nextStatus = "failed";
    if (phase === "succeeded") {
      if (parsed && parsed.channels.length) nextStatus = parsed.needsUser ? "interrupted" : "done";
      else if (channels.length) nextStatus = "interrupted";
      else nextStatus = "failed";
    } else if (phase === "interrupted") {
      nextStatus = "interrupted";
    } else if (phase === "stopped") {
      nextStatus = "stopped";
    } else if (phase === "failed") {
      nextStatus = "failed";
    }
    let note = "";
    if (parsed && parsed.note) note = parsed.note;
    if (parsed && parsed.needsUser) {
      note = [note, "\u9700\u8981\u4F60\u786E\u8BA4\u89C4\u683C\u6216\u5904\u7406\u767B\u5F55/\u9A8C\u8BC1\u540E\u91CD\u8BD5\u3002"].filter(Boolean).join(" ");
    }
    if (!parsed) {
      note = [note, channels.length ? "\u4EFB\u52A1\u7ED3\u675F\uFF1B\u5DF2\u4FDD\u5B58 " + channels.filter(function(channel) {
        return channel.price != null;
      }).length + " \u4E2A\u5DF2\u6838\u9A8C\u4EF7\u683C\u3002" : "\u4EFB\u52A1\u7ED3\u675F\u4F46\u6CA1\u6709\u89E3\u6790\u5230\u6BD4\u4EF7\u7ED3\u679C\u3002\u6253\u5F00\u4EFB\u52A1\u5BF9\u8BDD\u53EF\u4EE5\u67E5\u770B\u52A9\u624B\u5B9E\u9645\u770B\u5230\u4E86\u4EC0\u4E48\u3002"].filter(Boolean).join(" ");
    }
    if (phase === "succeeded" && !channels.length) {
      note = [note, "\u8FD9\u6B21\u6CA1\u6709\u62FF\u5230\u53EF\u786E\u8BA4\u7684\u4EF7\u683C\uFF0C\u672A\u6CBF\u7528\u65E7\u6570\u636E\u3002"].filter(Boolean).join(" ");
    }
    if ((phase === "stopped" || phase === "failed") && channels.length) {
      note = [note, "\u5DF2\u4FDD\u5B58\u505C\u4E0B\u524D\u6838\u9A8C\u5230\u7684\u4EF7\u683C\u3002"].filter(Boolean).join(" ");
    }
    const finalMissing = missingRows.filter(function(item2) {
      return !channels.some(function(channel) {
        return channel.platform === item2.platform;
      });
    });
    const record = normalizeRecord({
      id,
      createdAt: existing && existing.createdAt || Date.now(),
      updatedAt: Date.now(),
      kind,
      item,
      title,
      spec,
      url,
      note: note.slice(0, 500),
      status: nextStatus,
      phase,
      sessionId,
      sourcePlatform: sourceInfo ? sourceInfo.platform : "",
      sourceStore: sourceInfo ? sourceInfo.store || "" : "",
      sourcePrice: sourceInfo ? sourceInfo.price : null,
      sourceNote: sourceInfo ? sourceInfo.note || "" : "",
      sourceAt: sourceInfo ? sourceInfo.at || 0 : 0,
      capturedFrom: sourceInfo ? sourceInfo.from || "candidate" : "manual",
      channels,
      missing: finalMissing,
      assumptions: parsed ? parsed.assumptions : existing ? existing.assumptions : [],
      eventsTail: historyTail(events),
      lastRunAt: Date.now(),
      reminderAt: existing ? existing.reminderAt : 0,
      reminderTiming: existing ? existing.reminderTiming : ""
    });
    const nextRecords = [record].concat(
      recordsRef.current.filter(function(item2) {
        return item2.id !== record.id;
      })
    ).sort(function(a, b) {
      return b.updatedAt - a.updatedAt;
    }).slice(0, 80);
    recordsRef.current = nextRecords;
    setRecords(nextRecords);
    await writeRecords(nextRecords);
    updateWidget(nextRecords);
    partialRef.current = "";
    if (nextStatus === "done") {
      const best = bestChannel(record);
      const prefix = meta && meta.mode === "verify" ? "\u590D\u6838\u5B8C\u6210" : kindLabel(kind) + "\u6BD4\u4EF7\u5B8C\u6210";
      showToast(best ? prefix + "\uFF1A\u5DF2\u6838\u9A8C\u6765\u6E90\u4E2D " + priceWithUnit(best) + " \u6700\u4F4E" : prefix + "\uFF1A\u4EF7\u683C\u5DF2\u8BB0\u5F55\uFF0C\u4F46\u89C4\u683C/\u65F6\u95F4/\u6B3E\u5F0F/\u6B63\u89C4\u6E20\u9053\u4E0D\u9F50");
    } else if (nextStatus === "interrupted") {
      showToast("\u4EFB\u52A1\u505C\u4E0B\u7B49\u4F60\u786E\u8BA4\uFF0C\u6253\u5F00\u8BB0\u5F55\u770B\u539F\u56E0");
    } else if (nextStatus === "stopped") {
      showToast("\u6BD4\u4EF7\u4EFB\u52A1\u5DF2\u505C\u6B62");
    } else {
      showToast("\u8FD9\u6B21\u6BD4\u4EF7\u6CA1\u6709\u5B8C\u6210\uFF0C\u8BB0\u5F55\u91CC\u5199\u4E86\u539F\u56E0");
    }
    if (meta && meta.openOnFinish && ["home", "start"].indexOf(navRef.current.page) >= 0 || navRef.current.page === "home") {
      setRecordId(record.id);
      setPage("record");
    }
    [600, 1800].forEach(function(delay) {
      window.setTimeout(function() {
        void refreshRecord(record, { silent: true });
      }, delay);
    });
  }
  finalizeRef.current = finalizeRun;
  function floatingBlockedNow() {
    const state = overlayState(capsRef.current);
    if (state === false || a11yState(capsRef.current) === false) return true;
    return state === null && actionsVisible === false && settingsRef.current.floating !== false;
  }
  async function handleFloatingToggle() {
    if (refreshCaps) await refreshCaps();
    if (floatingBlockedNow()) {
      const overlayOff = overlayState(capsRef.current) === false;
      const a11yOff = a11yState(capsRef.current) === false;
      const reason = overlayOff ? "\u7CFB\u7EDF\u60AC\u6D6E\u7A97\u6743\u9650\u672A\u5F00\u542F\uFF0C\u4E0D\u80FD\u6253\u5F00\u60AC\u6D6E\u5165\u53E3\u3002\u8BF7\u5230\u7CFB\u7EDF\u8BBE\u7F6E\u5141\u8BB8 DSH \u663E\u793A\u5728\u5176\u4ED6\u5E94\u7528\u4E0A\u5C42\uFF0C\u6216\u6253\u5F00\u80FD\u529B\u4E2D\u5FC3\u6388\u6743\u3002" : a11yOff ? "\u5171\u4EAB\u65E0\u969C\u788D\u670D\u52A1\u672A\u8FDE\u63A5\uFF0C\u4E0D\u80FD\u6253\u5F00\u60AC\u6D6E\u5165\u53E3\u3002\u8BF7\u5230\u80FD\u529B\u4E2D\u5FC3\u5F00\u542F\u65E0\u969C\u788D\u540E\u91CD\u8BD5\u3002" : "\u60AC\u6D6E\u5165\u53E3\u5F53\u524D\u4E0D\u53EF\u7528\uFF08\u53EF\u80FD\u5DF2\u88AB\u9690\u85CF\u6216\u7CFB\u7EDF\u6743\u9650\u672A\u5F00\uFF09\uFF0C\u8BF7\u5148\u5728\u7CFB\u7EDF\u60AC\u6D6E\u8BBE\u7F6E\u4E2D\u6062\u590D\u3002";
      setGlobalError(reason);
      showToast(overlayOff ? "\u7CFB\u7EDF\u60AC\u6D6E\u7A97\u6743\u9650\u672A\u5F00\u542F" : a11yOff ? "\u5171\u4EAB\u65E0\u969C\u788D\u670D\u52A1\u672A\u8FDE\u63A5" : "\u60AC\u6D6E\u5165\u53E3\u4E0D\u53EF\u7528");
      void openFloatingControls(reason).then(function() {
        void refreshCaps().then(function() {
          if (overlayState(capsRef.current) === true && a11yState(capsRef.current) === true) {
            void changeSettings({ floating: true });
          }
        });
      });
      return;
    }
    await changeSettings({ floating: !settingsRef.current.floating });
  }
  function startEntryBlocked() {
    const state = overlayState(capsRef.current);
    return state === false || state === null && actionsVisible === false && settingsRef.current.floating !== false;
  }
  function openStart(candidate) {
    setStart(startFromCandidate(candidate, settingsRef.current));
    setStartError("");
    setGlobalError("");
    setPage("start");
  }
  function openAdd(withCamera) {
    setForm(blankForm());
    setPhoto(null);
    setFormError("");
    setPage("add");
    if (withCamera) void capturePhoto();
  }
  async function capturePhoto() {
    const wish = bridgeRef.current;
    if (!wish || !wish.camera || typeof wish.camera.capture !== "function") {
      setPhoto({ state: "error", error: "\u5F53\u524D\u73AF\u5883\u4E0D\u652F\u6301\u76F8\u673A\u3002\u53EF\u4EE5\u624B\u52A8\u586B\u5199\uFF0C\u6216\u7C98\u8D34\u5546\u54C1\u9875\u6587\u5B57\u3002" });
      return;
    }
    setPhoto({ state: "capturing" });
    try {
      const shot = await wish.camera.capture();
      if (!shot || !shot.data) {
        setPhoto(null);
        return;
      }
      const mediaType = shot.mediaType || "image/jpeg";
      const next = {
        state: "captured",
        url: "data:" + mediaType + ";base64," + shot.data,
        data: shot.data,
        mediaType,
        ocr: "",
        error: ""
      };
      setPhoto(next);
      if (wish.ocr && typeof wish.ocr.recognize === "function") {
        try {
          const ocr = await wish.ocr.recognize({ data: shot.data, script: "chinese" });
          if (ocr && str(ocr.text)) {
            setPhoto(function(current) {
              return current ? { ...current, ocr: str(ocr.text) } : current;
            });
          }
        } catch (error) {
        }
      }
    } catch (error) {
      setPhoto({ state: "error", error: "\u76F8\u673A\u6CA1\u6709\u8FD4\u56DE\u7167\u7247\uFF1A" + msg(error) });
    }
  }
  async function readPhotoWithAI() {
    const current = photo;
    const wish = bridgeRef.current;
    if (!current || !current.data) return;
    if (!wish || !wish.ai || typeof wish.ai.complete !== "function") {
      setPhoto({ ...current, state: "error", error: "\u5F53\u524D\u73AF\u5883\u4E0D\u652F\u6301\u6A21\u578B\u8C03\u7528\uFF0C\u53EF\u4EE5\u624B\u52A8\u586B\u5199\u3002" });
      return;
    }
    setPhoto({ ...current, state: "reading", error: "" });
    try {
      const response = await wish.ai.complete({
        prompt: buildCameraPrompt(current.ocr),
        image: { data: current.data, mediaType: current.mediaType }
      });
      const parsed = parseJsonLoose(response.text);
      if (!parsed) throw new Error("AI \u8FD4\u56DE\u7684\u5185\u5BB9\u65E0\u6CD5\u89E3\u6790");
      setForm(function(previous) {
        return {
          ...previous,
          title: str(parsed.title) || previous.title,
          spec: str(parsed.spec) || previous.spec,
          url: str(parsed.url) || previous.url,
          price: numberOrNull(parsed.price) != null ? String(numberOrNull(parsed.price)) : previous.price,
          sourcePlatform: PLATFORM_MAP[str(parsed.platform)] ? str(parsed.platform) : previous.sourcePlatform,
          sourceStore: str(parsed.store) || previous.sourceStore,
          note: [str(parsed.note), previous.note].filter(Boolean).join(" \xB7 ")
        };
      });
      setPhoto({ ...current, state: "done", error: "" });
      showToast("\u5DF2\u8BFB\u53D6\u5546\u54C1\u4FE1\u606F\uFF0C\u6838\u5BF9\u540E\u518D\u52A0\u5165\u5019\u9009");
    } catch (error) {
      setPhoto({ ...current, state: "error", error: "AI \u8BFB\u53D6\u5931\u8D25\uFF1A" + msg(error) + "\u3002\u53EF\u4EE5\u624B\u52A8\u586B\u5199\uFF0C\u56FE\u7247\u4ECD\u4FDD\u7559\u3002" });
    }
  }
  async function saveCandidate(andCompare) {
    setFormError("");
    const kind = KINDS.indexOf(form.kind) >= 0 ? form.kind : "product";
    const item = itemFromForm(form);
    if (!itemTitle(kind, item)) {
      setFormError(kind === "hotel" ? "\u5148\u586B\u9152\u5E97\u540D\u3002" : kind === "flight" ? "\u5148\u586B\u822A\u73ED\u53F7\u3002" : "\u5148\u586B\u5546\u54C1\u540D\uFF0C\u6216\u62CD\u5546\u54C1\u9875\u8BA9 AI \u8BC6\u522B\u3002");
      return;
    }
    if (kind === "hotel" && (!str(item.checkIn) || !str(item.checkOut))) {
      setFormError("\u9152\u5E97\u5019\u9009\u8981\u586B\u5165\u4F4F\u548C\u79BB\u5E97\u65E5\u671F\u3002");
      return;
    }
    if (kind === "hotel" && item.rateMode === "specific" && !str(item.roomType)) {
      setFormError("\u5DF2\u9009\u201C\u6307\u5B9A\u623F\u578B\u201D\uFF0C\u8BF7\u586B\u623F\u578B\uFF1B\u6216\u5207\u56DE\u201C\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\u201D\u3002");
      return;
    }
    if (kind === "flight" && !str(item.date)) {
      setFormError("\u673A\u7968\u5019\u9009\u8981\u586B\u51FA\u53D1\u65E5\u671F\u3002");
      return;
    }
    const candidate = normalizeCandidate({
      kind,
      item,
      title: itemTitle(kind, item),
      spec: itemSummary(kind, item),
      url: form.url,
      sourceUrl: form.url,
      sourcePlatform: form.sourcePlatform,
      sourceStore: form.sourceStore,
      sourcePrice: numberOrNull(form.price),
      sourceNote: form.note,
      capturedAt: Date.now(),
      capturedFrom: photo ? "camera" : "manual",
      note: form.note,
      priceHint: numberOrNull(form.price)
    });
    if (!candidate) {
      setFormError("\u6807\u9898\u4E0D\u80FD\u4E3A\u7A7A");
      return;
    }
    const next = [candidate].concat(candidatesRef.current).slice(0, 60);
    if (!await writeCandidates(next)) {
      setFormError("\u5019\u9009\u4FDD\u5B58\u5931\u8D25\uFF0C\u8F93\u5165\u5DF2\u4FDD\u7559");
      return;
    }
    candidatesRef.current = next;
    setCandidates(next);
    setForm(blankForm());
    setPhoto(null);
    showToast(candidate.sourcePrice != null ? "\u5DF2\u8BB0\u4E0B" + kindLabel(candidate.kind) + "\uFF1A" + candidate.title : "\u5DF2\u52A0\u5165\u5019\u9009");
    if (andCompare) openStart(candidate);
    else {
      setPage("home");
      setStart(blankStart(settingsRef.current));
    }
  }
  async function removeCandidate(candidate) {
    return async function() {
      const next = candidatesRef.current.filter(function(item) {
        return item.id !== candidate.id;
      });
      candidatesRef.current = next;
      setCandidates(next);
      if (!await writeCandidates(next)) throw new Error("\u5220\u9664\u5931\u8D25\uFF0C\u8BF7\u91CD\u8BD5");
      showToast("\u5DF2\u79FB\u9664\u5019\u9009");
    }();
  }
  function askRemoveCandidate(candidate) {
    setConfirmError("");
    setSheet({
      type: "confirm",
      title: "\u79FB\u9664\u8FD9\u4E2A\u5019\u9009\uFF1F",
      body: candidate.title + "\u3002\u53EA\u5220\u9664\u5019\u9009\uFF0C\u4E0D\u5F71\u54CD\u5DF2\u6709\u6BD4\u4EF7\u8BB0\u5F55\u3002",
      confirmLabel: "\u79FB\u9664",
      danger: true,
      action: function() {
        return removeCandidate(candidate);
      }
    });
  }
  function openRecord(id) {
    setRecordId(id);
    setPage("record");
  }
  function askDeleteRecord(record) {
    if (record.status === "comparing" && runRef.current && runRef.current.running && runRef.current.recordId === record.id) {
      showToast("\u8FD9\u6B21\u6BD4\u4EF7\u8FD8\u5728\u8FDB\u884C\uFF0C\u5148\u505C\u6B62\u4EFB\u52A1\u518D\u5220\u9664\u3002");
      return;
    }
    setConfirmError("");
    setSheet({
      type: "confirm",
      title: "\u5220\u9664\u8FD9\u6761\u6BD4\u4EF7\u8BB0\u5F55\uFF1F",
      body: "\u4F1A\u540C\u65F6\u53D6\u6D88\u8FD9\u6761\u8BB0\u5F55\u5173\u8054\u7684\u63D0\u9192\u3002\u4EF7\u683C\u3001\u94FE\u63A5\u548C\u6838\u9A8C\u65F6\u95F4\u7684\u8BB0\u5F55\u90FD\u4F1A\u5220\u9664\uFF0C\u4E0D\u53EF\u6062\u590D\u3002",
      confirmLabel: "\u5220\u9664",
      danger: true,
      action: async function() {
        const wish = bridgeRef.current;
        if (record.reminderAt && wish && wish.reminders && wish.reminders.cancel) {
          try {
            await wish.reminders.cancel("price-" + record.id);
          } catch (error) {
          }
        }
        const next = recordsRef.current.filter(function(item) {
          return item.id !== record.id;
        });
        recordsRef.current = next;
        setRecords(next);
        if (!await writeRecords(next)) throw new Error("\u5220\u9664\u5931\u8D25\uFF0C\u8BF7\u91CD\u8BD5");
        updateWidget(next);
        if (recordId === record.id) {
          setRecordId("");
          setPage("records");
        }
        showToast("\u5DF2\u5220\u9664\u6BD4\u4EF7\u8BB0\u5F55");
      }
    });
  }
  async function remind(record, minutes) {
    if (!remindersGranted) {
      openCaps("\u540E\u53F0\u63D0\u9192\u8FD8\u6CA1\u6709\u6388\u6743\u7ED9\u672C\u4F5C\u54C1\u3002\u6388\u6743\u540E\u56DE\u6765\u518D\u5B89\u6392\u63D0\u9192\u3002");
      return;
    }
    const wish = bridgeRef.current;
    if (!wish || !wish.reminders || typeof wish.reminders.schedule !== "function") {
      showToast("\u5F53\u524D\u73AF\u5883\u4E0D\u652F\u6301\u7CFB\u7EDF\u63D0\u9192");
      return;
    }
    setRemindBusy(record.id + ":" + minutes);
    try {
      if (record.reminderAt && wish.reminders.cancel) {
        try {
          await wish.reminders.cancel("price-" + record.id);
        } catch (error) {
        }
      }
      const at = Date.now() + minutes * 6e4;
      const response = await wish.reminders.schedule({
        id: "price-" + record.id,
        at,
        title: "\u56DE\u6765\u6BD4\u4EF7\uFF1A" + record.title,
        body: "\u91CD\u65B0\u6838\u5BF9\u4EF7\u683C\u548C\u5238\u518D\u51B3\u5B9A\uFF1B\u4E0A\u6B21\u4EF7\u683C\u53EA\u4EE3\u8868\u5F53\u65F6\u9875\u9762\u3002"
      });
      const timing = response && response.timing === "inexact" ? "inexact" : "exact";
      const next = recordsRef.current.map(function(item) {
        if (item.id !== record.id) return item;
        return { ...item, reminderAt: at, reminderTiming: timing };
      });
      recordsRef.current = next;
      setRecords(next);
      await writeRecords(next);
      showToast(timing === "exact" ? "\u5DF2\u5B89\u6392\u7CFB\u7EDF\u63D0\u9192" : "\u5DF2\u5B89\u6392\u63D0\u9192\uFF1B\u7CFB\u7EDF\u53EF\u80FD\u5EF6\u8FDF\u51E0\u5206\u949F");
    } catch (error) {
      showToast("\u63D0\u9192\u5B89\u6392\u5931\u8D25\uFF1A" + msg(error));
    } finally {
      setRemindBusy("");
    }
  }
  async function cancelReminder(record) {
    const wish = bridgeRef.current;
    setRemindBusy(record.id + ":cancel");
    try {
      if (wish && wish.reminders && wish.reminders.cancel) await wish.reminders.cancel("price-" + record.id);
      const next = recordsRef.current.map(function(item) {
        if (item.id !== record.id) return item;
        return { ...item, reminderAt: 0, reminderTiming: "" };
      });
      recordsRef.current = next;
      setRecords(next);
      await writeRecords(next);
      showToast("\u5DF2\u53D6\u6D88\u63D0\u9192");
    } catch (error) {
      showToast("\u53D6\u6D88\u5931\u8D25\uFF1A" + msg(error));
    } finally {
      setRemindBusy("");
    }
  }
  async function testReminder() {
    if (!remindersGranted) {
      openCaps("\u540E\u53F0\u63D0\u9192\u8FD8\u6CA1\u6709\u6388\u6743\u7ED9\u672C\u4F5C\u54C1\u3002\u6388\u6743\u540E\u56DE\u6765\u518D\u6D4B\u8BD5\u3002");
      return;
    }
    const wish = bridgeRef.current;
    setRemindBusy("test");
    try {
      const response = await wish.reminders.schedule({
        id: "price-test",
        at: Date.now() + 6e4,
        title: "\u6BD4\u4EF7\u96F7\u8FBE\u6D4B\u8BD5\u63D0\u9192",
        body: "\u540E\u53F0\u63D0\u9192\u53EF\u7528\uFF1B\u79BB\u5F00\u9875\u9762\u4E5F\u4F1A\u89E6\u53D1\u3002"
      });
      showToast(response && response.timing === "inexact" ? "\u6D4B\u8BD5\u63D0\u9192\u5DF2\u5B89\u6392\uFF1B\u7CFB\u7EDF\u53EF\u80FD\u5EF6\u8FDF" : "\u6D4B\u8BD5\u63D0\u9192\u5DF2\u5B89\u6392\uFF0C1 \u5206\u949F\u540E\u89E6\u53D1");
    } catch (error) {
      showToast("\u6D4B\u8BD5\u63D0\u9192\u5931\u8D25\uFF1A" + msg(error));
    } finally {
      setRemindBusy("");
    }
  }
  async function clearAll() {
    if (runRef.current && runRef.current.running) {
      throw new Error("\u5148\u505C\u6B62\u8FDB\u884C\u4E2D\u7684\u6BD4\u4EF7\u4EFB\u52A1\uFF0C\u518D\u6E05\u7A7A\u6570\u636E\u3002");
    }
    const wish = bridgeRef.current;
    for (let i = 0; i < recordsRef.current.length; i += 1) {
      const item = recordsRef.current[i];
      if (item.reminderAt && wish.reminders && wish.reminders.cancel) {
        try {
          await wish.reminders.cancel("price-" + item.id);
        } catch (error) {
        }
      }
    }
    recordsRef.current = [];
    candidatesRef.current = [];
    setRecords([]);
    setCandidates([]);
    await writeRecords([]);
    await writeCandidates([]);
    updateWidget([]);
    setPage("home");
    showToast("\u5DF2\u6E05\u7A7A\u672C\u4F5C\u54C1\u7684\u6570\u636E");
  }
  async function exportAll() {
    const wish = bridgeRef.current;
    if (!wish || !wish.files || typeof wish.files.export !== "function") {
      showToast("\u5F53\u524D\u73AF\u5883\u4E0D\u652F\u6301\u5BFC\u51FA\u6587\u4EF6");
      return;
    }
    const payload = {
      work: TITLE,
      version: VERSION,
      exportedAt: (/* @__PURE__ */ new Date()).toISOString(),
      records: recordsRef.current,
      candidates: candidatesRef.current
    };
    const data = toBase64(JSON.stringify(payload, null, 2));
    if (!data) {
      showToast("\u5BFC\u51FA\u5185\u5BB9\u7F16\u7801\u5931\u8D25");
      return;
    }
    try {
      await wish.files.export({ name: "\u6BD4\u4EF7\u96F7\u8FBE-" + todayLabel() + ".json", mime: "application/json", data });
      showToast("\u5DF2\u6253\u5F00\u7CFB\u7EDF\u4FDD\u5B58\u9762\u677F");
    } catch (error) {
      showToast("\u5BFC\u51FA\u5931\u8D25\uFF1A" + msg(error));
    }
  }
  function askPublish() {
    setConfirmError("");
    setSheet({
      type: "confirm",
      title: "\u53D1\u5E03\u201C" + TITLE + "\u201D\uFF1F",
      body: "\u786E\u8BA4\u9996\u9875\u3001\u6BD4\u4EF7\u6D41\u7A0B\u548C\u8BB0\u5F55\u90FD\u68C0\u67E5\u8FC7\u518D\u53D1\u5E03\u3002\u53D1\u5E03\u540E\u4F1A\u51FA\u73B0\u5728\u4F5C\u54C1\u5899\u3002",
      confirmLabel: "\u53D1\u5E03",
      action: async function() {
        const wish = bridgeRef.current;
        if (!wish || typeof wish.publish !== "function") throw new Error("\u5F53\u524D\u73AF\u5883\u4E0D\u652F\u6301\u53D1\u5E03");
        await wish.publish({ title: TITLE, panel: PANEL_ID });
        showToast("\u5DF2\u53D1\u5E03\u5230\u4F5C\u54C1\u5899");
      }
    });
  }
  function askClear() {
    setConfirmError("");
    setSheet({
      type: "confirm",
      title: "\u6E05\u7A7A\u5168\u90E8\u6570\u636E\uFF1F",
      body: "\u4F1A\u5220\u9664 " + recordsRef.current.length + " \u6761\u6BD4\u4EF7\u8BB0\u5F55\uFF0C\u5E76\u53D6\u6D88\u672C\u4F5C\u54C1\u5B89\u6392\u7684\u63D0\u9192\u3002\u6B64\u64CD\u4F5C\u4E0D\u53EF\u6062\u590D\u3002",
      confirmLabel: "\u6E05\u7A7A",
      danger: true,
      action: clearAll
    });
  }
  async function runConfirm() {
    if (!sheet || sheet.type !== "confirm") return;
    setConfirmBusy(true);
    setConfirmError("");
    try {
      if (sheet.action) await sheet.action();
      setSheet(null);
    } catch (error) {
      setConfirmError(msg(error));
    } finally {
      setConfirmBusy(false);
    }
  }
  function beginMemoryEdit(platformId2, withAI) {
    const entry = memoryRef.current.platforms[platformId2] || { steps: [], coupon: "", notes: "" };
    setMemoryEdit({
      platform: platformId2,
      stepsText: (entry.steps || []).join("\n"),
      coupon: entry.coupon || "",
      notes: entry.notes || "",
      saving: false,
      error: "",
      aiState: withAI ? "queued" : "idle",
      preview: null
    });
  }
  async function refineMemoryFromEdit(edit) {
    const wish = bridgeRef.current;
    if (!edit) return;
    if (!wish || !wish.ai || typeof wish.ai.complete !== "function") {
      setMemoryEdit(function(current) {
        return current && current.platform === edit.platform ? { ...current, aiState: "error", error: "\u5F53\u524D\u73AF\u5883\u4E0D\u652F\u6301\u6A21\u578B\u8C03\u7528\uFF0C\u53EF\u4EE5\u76F4\u63A5\u624B\u52A8\u7F16\u8F91\u3002" } : current;
      });
      return;
    }
    setMemoryEdit(function(current) {
      return current && current.platform === edit.platform ? { ...current, aiState: "running", error: "" } : current;
    });
    const latest = recordsRef.current.find(function(item) {
      return (item.channels || []).some(function(channel) {
        return channel.platform === edit.platform;
      });
    }) || recordsRef.current[0];
    const entry = {
      steps: edit.stepsText.split("\n").map(function(line) {
        return line.trim();
      }).filter(Boolean),
      coupon: edit.coupon,
      notes: edit.notes
    };
    try {
      const response = await wish.ai.complete({
        prompt: buildMemoryRefinePrompt(edit.platform, entry, latest ? latest.eventsTail : [])
      });
      const parsed = parseJsonLoose(response.text);
      const steps = parsed && Array.isArray(parsed.steps) ? parsed.steps.map(str).filter(Boolean).slice(0, 12) : [];
      if (!steps.length) throw new Error("AI \u6CA1\u6709\u8FD4\u56DE\u53EF\u7528\u6B65\u9AA4\uFF0C\u53EF\u4EE5\u624B\u52A8\u7F16\u8F91");
      setMemoryEdit(function(current) {
        if (!current || current.platform !== edit.platform) return current;
        return {
          ...current,
          aiState: "done",
          error: "",
          preview: {
            steps,
            coupon: str(parsed.coupon) || current.coupon,
            notes: str(parsed.notes) || current.notes
          }
        };
      });
    } catch (error) {
      setMemoryEdit(function(current) {
        if (!current || current.platform !== edit.platform) return current;
        return { ...current, aiState: "error", error: "AI \u4F18\u5316\u5931\u8D25\uFF1A" + msg(error) + "\u3002\u53EF\u4EE5\u624B\u52A8\u7F16\u8F91\u540E\u4FDD\u5B58\u3002" };
      });
    }
  }
  function applyMemoryPreview() {
    setMemoryEdit(function(current) {
      if (!current || !current.preview) return current;
      return {
        ...current,
        stepsText: current.preview.steps.join("\n"),
        coupon: current.preview.coupon,
        notes: current.preview.notes,
        preview: null,
        aiState: "idle"
      };
    });
  }
  async function commitMemoryEdit() {
    const edit = memoryEdit;
    if (!edit) return;
    const steps = edit.stepsText.split("\n").map(function(line) {
      return line.trim();
    }).filter(Boolean).slice(0, 12);
    if (!steps.length) {
      setMemoryEdit({ ...edit, error: "\u81F3\u5C11\u4FDD\u7559\u4E00\u6761\u6B65\u9AA4\u3002" });
      return;
    }
    const next = JSON.parse(JSON.stringify(memoryRef.current));
    next.platforms[edit.platform] = {
      steps,
      coupon: str(edit.coupon) || (defaultMemory().platforms[edit.platform].coupon || ""),
      notes: str(edit.notes).slice(0, 500)
    };
    next.updatedAt = Date.now();
    setMemoryEdit({ ...edit, saving: true, error: "" });
    const result = await saveMemory(next, "\u6BD4\u4EF7\u65B9\u6CD5\u5DF2\u66F4\u65B0\uFF0C\u4E0B\u6B21\u6BD4\u4EF7\u4F1A\u6309\u65B0\u65B9\u6CD5\u6267\u884C");
    if (result.ok) setMemoryEdit(null);
    else setMemoryEdit({ ...edit, saving: false, error: result.error || "\u4FDD\u5B58\u5931\u8D25" });
  }
  function askResetMemory(platformId2) {
    setConfirmError("");
    setSheet({
      type: "confirm",
      title: "\u6062\u590D\u201C" + platformLabel(platformId2) + "\u201D\u7684\u9ED8\u8BA4\u6BD4\u4EF7\u65B9\u6CD5\uFF1F",
      body: "\u4F1A\u8986\u76D6\u4F60\u4E3A\u8FD9\u4E2A\u5E73\u53F0\u7F16\u8F91\u8FC7\u7684\u6B65\u9AA4\u548C\u9886\u5238\u8981\u70B9\uFF0C\u5176\u4ED6\u5E73\u53F0\u4E0D\u53D7\u5F71\u54CD\u3002",
      confirmLabel: "\u6062\u590D\u9ED8\u8BA4",
      action: async function() {
        const fresh = defaultMemory();
        const next = JSON.parse(JSON.stringify(memoryRef.current));
        next.platforms[platformId2] = fresh.platforms[platformId2];
        next.updatedAt = Date.now();
        const result = await saveMemory(next, "\u5DF2\u6062\u590D\u9ED8\u8BA4\u6BD4\u4EF7\u65B9\u6CD5");
        if (!result.ok) throw new Error(result.error || "\u6062\u590D\u5931\u8D25");
      }
    });
  }
  function setStartField(key, value) {
    setStart(function(previous) {
      return { ...previous, [key]: value };
    });
  }
  function setStartSourceField(key, value) {
    setStart(function(previous) {
      if (!previous.source) return previous;
      return { ...previous, source: { ...previous.source, [key]: value } };
    });
  }
  function toggleStartPlatform(id) {
    setStart(function(previous) {
      const key = previous.kind === "product" ? "platforms" : "travelPlatforms";
      const list = previous[key] || [];
      const exists = list.indexOf(id) >= 0;
      const next = exists ? list.filter(function(item) {
        return item !== id;
      }) : list.concat(id);
      return { ...previous, [key]: next };
    });
  }
  function setStartKind(kind) {
    setStart(function(previous) {
      return { ...previous, kind, source: null };
    });
    setStartError("");
  }
  function setFormField(key, value) {
    setForm(function(previous) {
      return { ...previous, [key]: value };
    });
  }
  function setAllSettingsPlatforms(id) {
    const current = settingsRef.current.platforms || [];
    const exists = current.indexOf(id) >= 0;
    const next = exists ? current.filter(function(item) {
      return item !== id;
    }) : current.concat(id);
    void changeSettings({ platforms: next });
  }
  function setAllTravelPlatforms(id) {
    const current = settingsRef.current.travelPlatforms || [];
    const exists = current.indexOf(id) >= 0;
    const next = exists ? current.filter(function(item) {
      return item !== id;
    }) : current.concat(id);
    void changeSettings({ travelPlatforms: next });
  }
  function renderHeader() {
    const metaMap = {
      home: { kicker: "PRICE RADAR", title: TITLE, sub: "\u5B98\u65D7 \xB7 \u767E\u8865 \xB7 \u81EA\u8425 \xB7 \u9ED1\u6807" },
      records: { kicker: "VERIFIED ONLY", title: "\u6BD4\u4EF7\u8BB0\u5F55", sub: "\u53EA\u8BA4\u5DF2\u6838\u9A8C\u7684\u6765\u6E90\u4E0E\u65F6\u95F4" },
      memory: { kicker: "PLAYBOOK", title: "\u6BD4\u4EF7\u65B9\u6CD5", sub: "\u5546\u54C1 / \u9152\u5E97 / \u673A\u7968\u5404\u5E73\u53F0\u7684\u6BD4\u4EF7\u65B9\u6CD5" },
      settings: { kicker: "WORK", title: "\u4F5C\u54C1\u8BBE\u7F6E", sub: "\u5165\u53E3\u3001\u63D0\u9192\u4E0E\u672C\u5730\u6570\u636E" },
      quick: { kicker: "PASTE LINK", title: "\u5F00\u59CB\u6BD4\u4EF7", sub: "\u8D34\u4E2A\u94FE\u63A5\u5C31\u884C" },
      start: { kicker: "START COMPARE", title: "\u5F00\u59CB\u6BD4\u4EF7", sub: "\u540C\u89C4\u683C\uFF0C\u8DE8\u5E73\u53F0" },
      record: { kicker: "COMPARE DETAIL", title: "\u8BB0\u5F55\u8BE6\u60C5", sub: "\u4EF7\u683C\u3001\u94FE\u63A5\u4E0E\u6838\u9A8C\u65F6\u95F4" }
    };
    const meta = metaMap[page] || metaMap.home;
    const subpage = page === "start" || page === "quick" || page === "record";
    return /* @__PURE__ */ import_react2.default.createElement("header", { className: "wish-header pr-head" }, subpage ? /* @__PURE__ */ import_react2.default.createElement(
      "button",
      {
        type: "button",
        className: "pr-back",
        "aria-label": "\u8FD4\u56DE",
        onClick: function() {
          setPage("home");
          setRecordId("");
        }
      },
      /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "back", size: 21 })
    ) : null, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-head-copy" }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-kicker" }, /* @__PURE__ */ import_react2.default.createElement("span", null, meta.kicker), page === "home" ? /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-live" }, /* @__PURE__ */ import_react2.default.createElement("i", null), "\u60AC\u6D6E\u5165\u53E3") : null), /* @__PURE__ */ import_react2.default.createElement("h1", null, meta.title), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-sub" }, meta.sub)));
  }
  function renderRun() {
    if (!run) return null;
    const meta = runStatusMeta(run);
    const events = compactEvents(run.events);
    const elapsed = elapsedLabel((run.finishedAt || Date.now()) - (run.startedAt || Date.now()));
    const liveRecord = run.recordId ? records.find(function(item) {
      return item.id === run.recordId;
    }) : null;
    const savedPrices = liveRecord ? liveRecord.channels.filter(function(channel) {
      return channel.price != null;
    }) : [];
    const stalled = run.running && ["running", "starting"].indexOf(run.phase) >= 0 && Date.now() - (run.lastProgressAt || run.startedAt || Date.now()) > 18e4;
    return /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-task pr-glass", "aria-label": "\u8FDB\u884C\u4E2D\u7684\u6BD4\u4EF7\u4EFB\u52A1" }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-task-top" }, run.running ? /* @__PURE__ */ import_react2.default.createElement(Radar, { small: true }) : /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-task-done" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: run.phase === "succeeded" ? "check" : "alert", size: 20 })), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-task-copy" }, /* @__PURE__ */ import_react2.default.createElement("strong", null, run.running ? run.mode === "verify" ? "\u6B63\u5728\u590D\u6838\u4EF7\u683C" : "\u6BD4\u4EF7\u8FDB\u884C\u4E2D" : "\u6700\u8FD1\u4E00\u6B21\u4EFB\u52A1"), /* @__PURE__ */ import_react2.default.createElement("span", { role: "status", "aria-live": "polite" }, phaseLabel(run.phase), " \xB7 ", elapsed)), /* @__PURE__ */ import_react2.default.createElement(StatusPill, { meta })), savedPrices.length ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-live-prices" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-live-dot", "aria-hidden": "true" }), /* @__PURE__ */ import_react2.default.createElement("span", null, "\u5DF2\u4FDD\u5B58 ", savedPrices.length, " \u4E2A\u4EF7\u683C"), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-live-list" }, savedPrices.slice(0, 4).map(function(channel) {
      return platformLabel(channel.platform) + " " + priceWithUnit(channel);
    }).join(" \xB7 "))) : null, stalled ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-stall" }, "\u770B\u8D77\u6765\u5361\u4F4F\u4E86\u3002\u5DF2\u4FDD\u5B58\u7684\u4EF7\u683C\u4E0D\u4F1A\u4E22\uFF1B\u5EFA\u8BAE\u5148\u505C\u6B62\u4EFB\u52A1\u770B\u7ED3\u679C\uFF0C\u518D\u91CD\u8BD5\u3002") : null, events.length ? /* @__PURE__ */ import_react2.default.createElement("ul", { className: "pr-events" }, events.map(function(event, index) {
      return /* @__PURE__ */ import_react2.default.createElement("li", { key: index, "data-kind": event.kind }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-event-dot" }), /* @__PURE__ */ import_react2.default.createElement("span", null, event.kind === "tool" ? "\u6267\u884C\uFF1A" + event.text : event.text));
    })) : null, run.running && !run.finishedAt && !TERMINAL[run.phase] ? /* @__PURE__ */ import_react2.default.createElement("div", { ref: taskHostRef, className: "pr-task-control" }) : null, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-btn-row" }, /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "pr-link", onClick: openTask }, "\u67E5\u770B\u4EFB\u52A1\u5BF9\u8BDD"), run.running ? /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "pr-link danger", onClick: stopRun }, "\u505C\u6B62\u4EFB\u52A1") : /* @__PURE__ */ import_react2.default.createElement(
      "button",
      {
        type: "button",
        className: "pr-link muted",
        onClick: function() {
          setRun(null);
          guardRef.current = "";
        }
      },
      "\u6536\u8D77"
    )));
  }
  function renderRecordCard(record) {
    const meta = recordStatus(record);
    const best = bestChannel(record);
    const samePriced = record.channels.filter(function(channel) {
      if (channel.price == null) return false;
      if (record.kind === "hotel") return true;
      return channel.match === "same" || !channel.match;
    });
    const refPriced = record.kind === "hotel" ? [] : record.channels.filter(function(channel) {
      return channel.price != null && (channel.match === "different" || channel.match === "unknown");
    });
    return /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "pr-record pr-glass", key: record.id, onClick: function() {
      openRecord(record.id);
    } }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-record-top" }, /* @__PURE__ */ import_react2.default.createElement(StatusPill, { meta }), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-kind-badge" }, kindLabel(record.kind)), /* @__PURE__ */ import_react2.default.createElement("time", null, agoLabel(record.updatedAt, tick))), /* @__PURE__ */ import_react2.default.createElement("strong", { className: "pr-record-title" }, record.title), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-record-meta" }, record.spec ? /* @__PURE__ */ import_react2.default.createElement("span", null, record.spec) : /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-warn-text" }, "\u89C4\u683C\u672A\u8BB0\u5F55"), /* @__PURE__ */ import_react2.default.createElement("span", null, record.kind === "hotel" ? samePriced.length + " \u4E2A\u9152\u5E97\u4EF7\u683C" : samePriced.length + " \u4E2A\u540C\u6B3E" + (refPriced.length ? " \xB7 " + refPriced.length + " \u4E2A\u53C2\u8003" : "")), best ? /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-best-mini" }, priceWithUnit(best)) : null), record.channels.length || record.missing.length ? /* @__PURE__ */ import_react2.default.createElement(import_react2.default.Fragment, null, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-platform-prices" }, samePriced.slice(0, 4).map(function(channel, index) {
      return /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-price-chip", key: "s" + index, "data-match": channel.match || "same" }, /* @__PURE__ */ import_react2.default.createElement("i", { style: { background: platformColor(channel.platform) } }), platformLabel(channel.platform), /* @__PURE__ */ import_react2.default.createElement("strong", null, priceWithUnit(channel)), channel.match === "close" ? /* @__PURE__ */ import_react2.default.createElement("em", null, "\u6761\u4EF6\u63A5\u8FD1") : channel.match === "different" ? /* @__PURE__ */ import_react2.default.createElement("em", null, "\u5DEE\u5F02") : channel.match === "unknown" ? /* @__PURE__ */ import_react2.default.createElement("em", null, "\u5F85\u786E\u8BA4") : null);
    }), record.missing.slice(0, 2).map(function(item, index) {
      return /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-price-chip", key: "m" + index, "data-missing": "true" }, /* @__PURE__ */ import_react2.default.createElement("i", { style: { background: platformColor(item.platform) } }), platformLabel(item.platform), /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u672A\u6838\u9A8C"));
    })), refPriced.length ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-reference-prices" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-reference-label" }, "\u975E\u540C\u6B3E\u53C2\u8003"), refPriced.slice(0, 3).map(function(channel, index) {
      return /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-price-chip", key: "r" + index, "data-reference": "true" }, /* @__PURE__ */ import_react2.default.createElement("i", { style: { background: platformColor(channel.platform) } }), platformLabel(channel.platform), /* @__PURE__ */ import_react2.default.createElement("strong", null, priceWithUnit(channel)), /* @__PURE__ */ import_react2.default.createElement("em", null, channel.match === "different" ? "\u5DEE\u5F02" : "\u5F85\u786E\u8BA4"));
    })) : null) : null);
  }
  function renderHome() {
    const verifiedCount = records.reduce(function(sum, record) {
      return sum + record.channels.filter(function(channel) {
        return channel.price != null;
      }).length;
    }, 0);
    const recent = records.slice(0, 3);
    const reminderCount = records.filter(function(record) {
      return !!record.reminderAt;
    }).length;
    return /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-stack" }, globalError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, globalError) : null, phoneGranted && a11y === false ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-a11y-banner pr-warnline", role: "alert" }, /* @__PURE__ */ import_react2.default.createElement("span", null, "\u624B\u673A\u65E0\u969C\u788D\u672A\u8FDE\u63A5\uFF1A\u60AC\u6D6E\u6BD4\u4EF7\u4F1A\u8BFB\u4E0D\u5230\u5C4F\u5E55\uFF08\u7F8E\u56E2/\u643A\u7A0B/\u53BB\u54EA\u513F\u4E5F\u4E00\u6837\uFF09\u3002"), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "pr-link", onClick: function() {
      void openFloatingControls("\u624B\u673A\u65E0\u969C\u788D\u672A\u8FDE\u63A5\uFF0C\u60AC\u6D6E\u6BD4\u4EF7\u8BFB\u4E0D\u5230\u5C4F\u5E55\u3002");
    } }, "\u53BB\u5F00\u542F")) : null, /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-hero" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-hero-glow", "aria-hidden": "true" }), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-hero-radar" }, /* @__PURE__ */ import_react2.default.createElement(Radar, null)), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-eyebrow" }, "\u540C\u4E00\u4EF6\u5546\u54C1 / \u540C\u4E00\u5BB6\u9152\u5E97 / \u540C\u4E00\u4E2A\u822A\u73ED"), /* @__PURE__ */ import_react2.default.createElement("h2", null, "\u628A\u5546\u54C1\u3001\u9152\u5E97\u3001\u673A\u7968", /* @__PURE__ */ import_react2.default.createElement("br", null), "\u4E00\u6B21\u6BD4\u6E05\u695A\u3002"), /* @__PURE__ */ import_react2.default.createElement("p", null, "\u5546\u54C1\u770B\u5B98\u65D7/\u767E\u8865/\u81EA\u8425\uFF0C\u9152\u5E97\u548C\u673A\u7968\u770B\u5B98\u65B9/\u81EA\u8425\uFF1B\u4F60\u5728\u54EA\u4E2A App \u53D1\u8D77\uFF0C\u5C31\u5148\u7B97\u90A3\u4E00\u9875\uFF0C\u4E0D\u590D\u5236\u94FE\u63A5\u3001\u4E0D\u70B9\u5206\u4EAB\u3002"), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "pr-cta", onClick: function() {
      openQuick();
    } }, /* @__PURE__ */ import_react2.default.createElement("span", null, "\u5F00\u59CB\u6BD4\u4EF7"), /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "arrow", size: 19 }))), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-stats" }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-stat pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("strong", null, records.length), /* @__PURE__ */ import_react2.default.createElement("span", null, "\u6761\u6BD4\u4EF7")), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-stat pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("strong", null, verifiedCount), /* @__PURE__ */ import_react2.default.createElement("span", null, "\u4E2A\u5DF2\u6838\u9A8C\u6E20\u9053")), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-stat pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("strong", null, reminderCount), /* @__PURE__ */ import_react2.default.createElement("span", null, "\u6761\u63D0\u9192"))), /* @__PURE__ */ import_react2.default.createElement(
      "button",
      {
        type: "button",
        className: "pr-float pr-glass",
        onClick: function() {
          void openFloatingControls(overlay === false ? "\u7CFB\u7EDF\u60AC\u6D6E\u7A97\u6743\u9650\u672A\u5F00\u542F\uFF0C\u8BF7\u5230\u300C\u6743\u9650\u4E0E\u52A8\u4F5C\u300D\u4E2D\u5F00\u542F\u3002" : a11yBlocked ? "\u65E0\u969C\u788D\u670D\u52A1\u672A\u8FDE\u63A5\uFF0C\u8BF7\u5230\u300C\u6743\u9650\u4E0E\u52A8\u4F5C\u300D\u4E2D\u5F00\u542F\u3002" : "\u5728\u53F3\u4E0A\u89D2 \u22EF \u2192\u300C\u6743\u9650\u4E0E\u52A8\u4F5C\u300D\u4E2D\u7BA1\u7406\u60AC\u6D6E\u5165\u53E3\u3002");
        }
      },
      /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-float-icon" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "float", size: 20 })),
      /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-float-copy" }, /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u8DE8 App \u60AC\u6D6E\u5165\u53E3"), /* @__PURE__ */ import_react2.default.createElement("small", null, overlay === false ? "\u7CFB\u7EDF\u60AC\u6D6E\u7A97\u6743\u9650\u672A\u5F00\u542F \xB7 \u53BB\u300C\u6743\u9650\u4E0E\u52A8\u4F5C\u300D\u5F00\u542F" : a11yBlocked ? "\u65E0\u969C\u788D\u670D\u52A1\u672A\u8FDE\u63A5 \xB7 \u53BB\u300C\u6743\u9650\u4E0E\u52A8\u4F5C\u300D\u5F00\u542F" : floatingHidden || actionsVisible === false ? "\u5DF2\u5173\u95ED \xB7 \u53BB\u300C\u6743\u9650\u4E0E\u52A8\u4F5C\u300D\u5F00\u542F" : "\u5DF2\u5F00\u542F \xB7 \u5728\u300C\u6743\u9650\u4E0E\u52A8\u4F5C\u300D\u4E2D\u7BA1\u7406")),
      /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "chevron", size: 18 })
    ), renderRun(), /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-section" }, /* @__PURE__ */ import_react2.default.createElement(
      SectionHead,
      {
        title: "\u6700\u8FD1\u6BD4\u4EF7",
        action: records.length ? /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-head-actions" }, /* @__PURE__ */ import_react2.default.createElement(
          "button",
          {
            type: "button",
            className: "pr-link",
            disabled: refreshingLatest,
            onClick: function() {
              void refreshLatestResult();
            }
          },
          /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "refresh", size: 14 }),
          " ",
          refreshingLatest ? "\u5237\u65B0\u4E2D\u2026" : "\u5237\u65B0"
        ), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "pr-link", onClick: function() {
          setPage("records");
        } }, "\u5168\u90E8")) : null
      }
    ), recent.length ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-list" }, recent.map(renderRecordCard)) : /* @__PURE__ */ import_react2.default.createElement(Empty, { icon: "compare", title: "\u8FD8\u6CA1\u6709\u6BD4\u4EF7\u8BB0\u5F55", body: "\u7B2C\u4E00\u6B21\u6BD4\u4EF7\u5B8C\u6210\u540E\uFF0C\u4EF7\u683C\u3001\u5238\u6761\u4EF6\u3001\u94FE\u63A5\u548C\u6838\u9A8C\u65F6\u95F4\u4F1A\u4FDD\u5B58\u5728\u8FD9\u91CC\u3002" })), /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-caps-strip pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-dot", "data-ok": phoneGranted && a11y !== false ? "true" : "false" }), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-caps-text" }, "\u624B\u673A\u64CD\u63A7 ", phoneGranted ? a11y === false ? "\u5DF2\u6388\u6743 \xB7 \u65E0\u969C\u788D\u672A\u8FDE\u63A5" : "\u5DF2\u6388\u6743" : "\u672A\u6388\u6743", /* @__PURE__ */ import_react2.default.createElement("i", null, "\xB7"), " \u540E\u53F0\u63D0\u9192 ", remindersGranted ? "\u5DF2\u6388\u6743" : "\u672A\u6388\u6743", /* @__PURE__ */ import_react2.default.createElement("i", null, "\xB7"), " \u6A21\u578B ", aiReady ? "\u53EF\u7528" : "\u5F85\u68C0\u67E5"), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "pr-link", onClick: function() {
      openCaps("");
    } }, "\u67E5\u770B")), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-version" }, "\u6BD4\u4EF7\u96F7\u8FBE v", VERSION));
  }
  function renderRecords() {
    return /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-stack" }, globalError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, globalError) : null, records.length ? /* @__PURE__ */ import_react2.default.createElement(import_react2.default.Fragment, null, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-records-top" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-caption" }, records.length, " \u6761\u8BB0\u5F55"), /* @__PURE__ */ import_react2.default.createElement(
      "button",
      {
        type: "button",
        className: "pr-link",
        disabled: refreshingLatest,
        onClick: function() {
          void refreshLatestResult();
        }
      },
      /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "refresh", size: 15 }),
      " ",
      refreshingLatest ? "\u5237\u65B0\u4E2D\u2026" : "\u5237\u65B0"
    )), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-list" }, records.map(renderRecordCard)), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button secondary", onClick: exportAll }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "download", size: 17 }), " \u5BFC\u51FA\u5168\u90E8\u8BB0\u5F55")) : /* @__PURE__ */ import_react2.default.createElement(
      Empty,
      {
        icon: "record",
        title: "\u8FD8\u6CA1\u6709\u8BB0\u5F55",
        body: "\u4ECE\u9996\u9875\u5F00\u59CB\u4E00\u6B21\u6BD4\u4EF7\uFF0C\u7ED3\u679C\u4F1A\u5E26\u5E73\u53F0\u3001\u5E97\u94FA\u7C7B\u578B\u3001\u4EF7\u683C\u3001\u5238\u6761\u4EF6\u548C\u6838\u9A8C\u65F6\u95F4\u4FDD\u5B58\u4E0B\u6765\u3002",
        action: /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button", onClick: function() {
          openStart(null);
        } }, "\u5F00\u59CB\u7B2C\u4E00\u6B21\u6BD4\u4EF7")
      }
    ));
  }
  function renderChannelTable(record) {
    if (!record.channels.length && !record.missing.length) {
      return /* @__PURE__ */ import_react2.default.createElement(Empty, { icon: "alert", title: "\u8FD9\u6B21\u6CA1\u6709\u53EF\u786E\u8BA4\u7684\u4EF7\u683C", body: record.note || "\u53EF\u4EE5\u91CD\u65B0\u6BD4\u4EF7\uFF0C\u6216\u6253\u5F00\u4EFB\u52A1\u5BF9\u8BDD\u770B\u52A9\u624B\u505C\u5728\u54EA\u4E00\u6B65\u3002" });
    }
    const best = bestChannel(record);
    return /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-channel-list" }, record.channels.map(function(channel, index) {
      const authentic = isAuthenticChannel(channel);
      const isBest = best === channel;
      return /* @__PURE__ */ import_react2.default.createElement(
        "article",
        {
          className: "pr-channel-card pr-glass" + (authentic ? "" : " pr-unverified-row"),
          key: "c" + index,
          "data-lowest": isBest ? "true" : void 0
        },
        /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-channel-head" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-channel-store" }, /* @__PURE__ */ import_react2.default.createElement(PlatformDot, { platform: channel.platform }), /* @__PURE__ */ import_react2.default.createElement("span", null, /* @__PURE__ */ import_react2.default.createElement("strong", null, channel.store || channel.label || platformLabel(channel.platform)), /* @__PURE__ */ import_react2.default.createElement("small", null, platformLabel(channel.platform), authentic ? "" : " \xB7 \u672A\u6807\u6B63\u54C1\u7C7B\u578B"))), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-channel-price" }, /* @__PURE__ */ import_react2.default.createElement("strong", null, priceWithUnit(channel)), /* @__PURE__ */ import_react2.default.createElement("small", null, channel.priceUnit === "night" ? "\u6BCF\u665A" : channel.priceUnit === "ticket" ? "\u6BCF\u4EBA" : formatShipping(channel.shipping)))),
        /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-channel-tags" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-match", "data-tone": matchMeta(channel, record.kind).tone || void 0 }, matchMeta(channel, record.kind).label), isBest ? /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-best-tag" }, "\u5DF2\u6838\u9A8C\u6700\u4F4E") : null),
        /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-channel-condition" }, channel.condition || "\u65E0\u989D\u5916\u6761\u4EF6"),
        channel.specSeen || channel.matchNote || Object.keys(channel.details || {}).length || channel.coupons.length ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-channel-detail" }, channel.specSeen ? /* @__PURE__ */ import_react2.default.createElement("small", null, "\u9875\u9762\uFF1A", channel.specSeen) : null, channel.matchNote ? /* @__PURE__ */ import_react2.default.createElement("small", null, "\u5DEE\u5F02\uFF1A", channel.matchNote) : null, Object.keys(channel.details || {}).slice(0, 5).map(function(key) {
          return /* @__PURE__ */ import_react2.default.createElement("small", { key }, key, "\uFF1A", channel.details[key]);
        }), channel.coupons.length ? /* @__PURE__ */ import_react2.default.createElement("small", null, "\u5238\uFF1A", channel.coupons.join(" \xB7 ")) : null) : null
      );
    }), record.missing.map(function(item, index) {
      return /* @__PURE__ */ import_react2.default.createElement("article", { className: "pr-channel-card pr-glass pr-missing-row", key: "m" + index }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-channel-head" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-channel-store" }, /* @__PURE__ */ import_react2.default.createElement(PlatformDot, { platform: item.platform }), /* @__PURE__ */ import_react2.default.createElement("span", null, /* @__PURE__ */ import_react2.default.createElement("strong", null, platformLabel(item.platform)), /* @__PURE__ */ import_react2.default.createElement("small", null, "\u672A\u6838\u9A8C"))), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-channel-price" }, /* @__PURE__ */ import_react2.default.createElement("strong", { className: "muted" }, "\u2014"), /* @__PURE__ */ import_react2.default.createElement("small", null, "\u6CA1\u6709\u53EF\u7528\u4EF7\u683C"))), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-channel-condition" }, item.reason));
    }));
  }
  function renderRecordPage() {
    const record = records.find(function(item) {
      return item.id === recordId;
    });
    if (!record) {
      return /* @__PURE__ */ import_react2.default.createElement(
        Empty,
        {
          icon: "record",
          title: "\u8BB0\u5F55\u4E0D\u5728\u4E86",
          body: "\u5B83\u53EF\u80FD\u5DF2\u88AB\u5220\u9664\u3002\u8FD4\u56DE\u8BB0\u5F55\u5217\u8868\u67E5\u770B\u5176\u4ED6\u6BD4\u4EF7\u3002",
          action: /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button", onClick: function() {
            setPage("records");
          } }, "\u56DE\u5230\u8BB0\u5F55")
        }
      );
    }
    const meta = recordStatus(record);
    const claimable = claimableChannels(record.channels);
    const best = bestChannel(record);
    const priced = record.channels.filter(function(channel) {
      return channel.price != null;
    });
    const samePriced = priced.filter(function(channel) {
      return channel.match === "same" || !channel.match;
    });
    const refPriced = priced.filter(function(channel) {
      return channel.match === "different" || channel.match === "unknown";
    });
    const nonAuthentic = priced.filter(function(channel) {
      return !isAuthenticChannel(channel);
    });
    const dataIncomplete = priced.length > 0 && claimable.length === 0;
    const missingTime = record.channels.filter(function(channel) {
      return channel.price != null && !channel.verifiedAt;
    });
    const missingLink = priced.filter(function(channel) {
      return !channel.url;
    });
    const emptyReason = !record.spec ? "\u89C4\u683C\u672A\u8BB0\u5F55\uFF0C\u4E0D\u80FD\u786E\u8BA4\u4E3A\u540C\u6B3E" : nonAuthentic.length && nonAuthentic.length === priced.length ? "\u62A5\u4EF7\u6E20\u9053\u672A\u6807\u51FA\u6B63\u54C1\u7C7B\u578B" : missingTime.length && missingTime.length === priced.length ? "\u6709\u62A5\u4EF7\u4F46\u7F3A\u6838\u9A8C\u65F6\u95F4" : dataIncomplete ? "\u6709\u62A5\u4EF7\u4F46\u7F3A\u6838\u9A8C\u65F6\u95F4\u6216\u6B63\u54C1\u7C7B\u578B" : "\u8FD8\u6CA1\u6709\u53EF\u786E\u8BA4\u7684\u540C\u89C4\u683C\u4EF7\u683C";
    return /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-stack" }, globalError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, globalError) : null, run && run.recordId === record.id && run.running && !run.finishedAt && !TERMINAL[run.phase] ? renderRun() : null, record.status === "comparing" ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-waiting pr-glass" }, /* @__PURE__ */ import_react2.default.createElement(Radar, { small: true }), /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u6B63\u5728\u7B49\u5F85\u52A9\u624B\u5904\u7406\u2026"), /* @__PURE__ */ import_react2.default.createElement("p", null, "\u6B63\u5728\u8BFB\u53D6\u5546\u54C1/\u9152\u5E97/\u673A\u7968\u548C\u9996\u5C4F\u4EF7\u683C\uFF1B\u6838\u9A8C\u5230\u4E00\u4E2A\u5E73\u53F0\u5C31\u4F1A\u5199\u5165\u8FD9\u6761\u8BB0\u5F55\uFF0C\u53EF\u4EE5\u79BB\u5F00\u9875\u9762\u3002"))) : null, /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-detail-head pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-detail-top" }, /* @__PURE__ */ import_react2.default.createElement(StatusPill, { meta }), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-kind-badge" }, kindLabel(record.kind)), /* @__PURE__ */ import_react2.default.createElement("time", null, formatDateTime(record.updatedAt))), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-detail-actions" }, /* @__PURE__ */ import_react2.default.createElement(
      "button",
      {
        type: "button",
        className: "pr-link",
        disabled: refreshing === record.id,
        onClick: function() {
          void refreshRecord(record);
        }
      },
      /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "refresh", size: 16 }),
      " ",
      refreshing === record.id ? "\u5237\u65B0\u4E2D\u2026" : "\u5237\u65B0\u6293\u4EF7"
    ), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-caption" }, "\u62C9\u53D6\u6700\u65B0\u6293\u4EF7\uFF0C\u4E0D\u542F\u52A8\u65B0\u4EFB\u52A1")), /* @__PURE__ */ import_react2.default.createElement("h2", null, record.title), record.spec ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-spec" }, record.kind === "hotel" ? "\u6761\u4EF6" : record.kind === "flight" ? "\u822A\u73ED" : "\u89C4\u683C", "\uFF1A", record.spec) : /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-warnline" }, "\u5173\u952E\u6761\u4EF6\u672A\u8BB0\u5F55\uFF0C\u6682\u4E0D\u5224\u5B9A\u6700\u4F4E\u4EF7\u3002"), record.kind === "hotel" || record.kind === "flight" ? /* @__PURE__ */ import_react2.default.createElement("dl", { className: "pr-item-facts" }, record.kind === "hotel" ? /* @__PURE__ */ import_react2.default.createElement(import_react2.default.Fragment, null, record.item && record.item.city ? /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("dt", null, "\u57CE\u5E02"), /* @__PURE__ */ import_react2.default.createElement("dd", null, record.item.city)) : null, record.item && record.item.checkIn ? /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("dt", null, "\u5165\u4F4F"), /* @__PURE__ */ import_react2.default.createElement("dd", null, record.item.checkIn, " \u2192 ", record.item.checkOut || "\u2014", record.item.nights ? " \xB7 " + record.item.nights + " \u665A" : "")) : null, /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("dt", null, "\u53E3\u5F84"), /* @__PURE__ */ import_react2.default.createElement("dd", null, record.item && record.item.rateMode === "specific" ? "\u6307\u5B9A\u623F\u578B" : "\u6700\u4F4E\u4EF7\u65E5\u5386\u623F")), record.item && record.item.roomType ? /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("dt", null, "\u623F\u578B"), /* @__PURE__ */ import_react2.default.createElement("dd", null, record.item.roomType)) : null, record.item && record.item.bedType ? /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("dt", null, "\u5E8A\u578B"), /* @__PURE__ */ import_react2.default.createElement("dd", null, record.item.bedType)) : null, record.item && record.item.breakfast ? /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("dt", null, "\u65E9\u9910"), /* @__PURE__ */ import_react2.default.createElement("dd", null, record.item.breakfast)) : null, record.item && record.item.cancelPolicy ? /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("dt", null, "\u53D6\u6D88"), /* @__PURE__ */ import_react2.default.createElement("dd", null, record.item.cancelPolicy)) : null) : /* @__PURE__ */ import_react2.default.createElement(import_react2.default.Fragment, null, record.item && record.item.airline ? /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("dt", null, "\u822A\u53F8"), /* @__PURE__ */ import_react2.default.createElement("dd", null, record.item.airline)) : null, record.item && record.item.date ? /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("dt", null, "\u65E5\u671F"), /* @__PURE__ */ import_react2.default.createElement("dd", null, record.item.date)) : null, record.item && (record.item.from || record.item.to) ? /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("dt", null, "\u822A\u7EBF"), /* @__PURE__ */ import_react2.default.createElement("dd", null, record.item.from || "\u2014", " \u2192 ", record.item.to || "\u2014")) : null, record.item && record.item.cabin ? /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("dt", null, "\u8231\u4F4D"), /* @__PURE__ */ import_react2.default.createElement("dd", null, record.item.cabin)) : null, record.item && record.item.baggage ? /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("dt", null, "\u884C\u674E"), /* @__PURE__ */ import_react2.default.createElement("dd", null, record.item.baggage)) : null)) : null, record.sourcePlatform ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-caption pr-source-line" }, "\u6765\u6E90\uFF1A", platformLabel(record.sourcePlatform), " \u5546\u54C1\u9875 \xB7 ", record.capturedFrom === "current-page" ? "\u5F53\u524D\u9875\u76F4\u63A5\u6838\u9A8C" : record.capturedFrom === "camera" ? "\u62CD\u7167\u8BC6\u522B\u5E26\u5165" : record.capturedFrom === "candidate" ? "\u5019\u9009\u5E26\u5165" : "\u624B\u52A8\u586B\u5199", record.sourceAt ? " \xB7 " + formatDateTime(record.sourceAt) : "") : null, record.note ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note" }, record.note) : null, best ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-bestbox" }, /* @__PURE__ */ import_react2.default.createElement("span", null, record.kind === "hotel" ? "\u5DF2\u6838\u9A8C\u6765\u6E90\u4E2D\u7684\u6700\u4F4E\u65E5\u5386\u623F" : "\u5DF2\u6838\u9A8C\u6765\u6E90\u4E2D\u7684\u6700\u4F4E"), /* @__PURE__ */ import_react2.default.createElement("strong", null, priceWithUnit(best)), /* @__PURE__ */ import_react2.default.createElement("small", null, platformLabel(best.platform), " \xB7 ", best.store || best.label || "\u6E20\u9053", " \xB7 \u6838\u9A8C\u4E8E ", formatDateTime(parseTime(best.verifiedAt)), best.match !== "same" && record.kind === "hotel" ? " \xB7 \u623F\u578B/\u65E9\u9910/\u53D6\u6D88\u6709\u5DEE\u5F02\uFF0C\u5DF2\u5907\u6CE8" : "", best.url ? "" : " \xB7 \u6765\u6E90\u9875\u672A\u7559\u94FE\u63A5")) : /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-bestbox empty" }, /* @__PURE__ */ import_react2.default.createElement("span", null, "\u6682\u65E0\u6700\u4F4E\u4EF7\u7ED3\u8BBA"), /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u2014"), /* @__PURE__ */ import_react2.default.createElement("small", null, emptyReason)), missingTime.length ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-warnline" }, "\u6709 ", missingTime.length, " \u6761\u62A5\u4EF7\u7F3A\u5C11\u6838\u9A8C\u65F6\u95F4\uFF0C\u672A\u53C2\u4E0E\u6700\u4F4E\u4EF7\u5224\u5B9A\uFF1A", missingTime.map(function(channel) {
      return platformLabel(channel.platform);
    }).join("\u3001"), "\u3002") : null, missingLink.length ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, "\u6709 ", missingLink.length, " \u6761\u4EF7\u683C\u6CA1\u6709\u4FDD\u5B58\u94FE\u63A5\uFF1B\u8FD9\u662F\u6309\u9875\u9762\u6838\u9A8C\u8BB0\u5F55\u7684\uFF0C\u56DE\u770B\u65F6\u6309\u5E73\u53F0\u91CD\u65B0\u6253\u5F00 App \u5373\u53EF\uFF0C\u4E0D\u7528\u4E3A\u4E86\u94FE\u63A5\u53BB\u590D\u5236\u6216\u5206\u4EAB\u3002") : null, priced.length ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, record.kind === "hotel" ? "\u5DF2\u8BB0\u5F55 " + priced.length + " \u4E2A\u9152\u5E97\u4EF7\u683C\uFF1B\u9ED8\u8BA4\u6309\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\u6BD4\u8F83\uFF0C\u623F\u578B/\u65E9\u9910/\u53D6\u6D88\u5DEE\u5F02\u5DF2\u5907\u6CE8\u3002\u4EF7\u683C\u4F1A\u968F\u65E5\u671F\u548C\u623F\u6001\u53D8\u5316\uFF0C\u5EFA\u8BAE\u6309\u9700\u590D\u6838\u3002" : "\u5DF2\u8BB0\u5F55 " + samePriced.length + " \u4E2A\u540C\u6B3E\u5E73\u53F0\u4EF7\u683C" + (refPriced.length ? "\uFF1B\u53E6\u6709 " + refPriced.length + " \u4E2A\u975E\u540C\u6B3E\u53C2\u8003\uFF08\u5DF2\u5907\u6CE8\uFF0C\u4E0D\u53C2\u4E0E\u6700\u4F4E\u4EF7\uFF09" : "") + "\u3002\u5176\u4E2D " + claimable.length + " \u4E2A\u540C\u65F6\u6EE1\u8DB3\u540C\u6B3E\u3001\u6B63\u54C1\u6807\u8BC6\u548C\u6838\u9A8C\u65F6\u95F4\uFF1B\u4EF7\u683C\u4F1A\u968F\u9875\u9762\u53D8\u5316\uFF0C\u5EFA\u8BAE\u6309\u9700\u590D\u6838\u3002") : null, record.channels.some(function(channel) {
      return channel.match === "different";
    }) ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-warnline" }, "\u6709 ", record.channels.filter(function(channel) {
      return channel.match === "different";
    }).length, " \u4E2A\u5E73\u53F0\u7684", record.kind === "hotel" ? "\u623F\u578B/\u65E5\u671F" : record.kind === "flight" ? "\u822A\u73ED/\u8231\u4F4D" : "\u989C\u8272/\u6B3E\u5F0F/\u5C3A\u7801", "\u4E0E\u76EE\u6807\u4E0D\u540C\uFF0C\u5DF2\u8BB0\u5F55\u4EF7\u683C\u548C\u5DEE\u5F02\uFF1B", record.kind === "hotel" ? "\u4ECD\u4F5C\u4E3A\u6700\u4F4E\u65E5\u5386\u623F\u5C55\u793A\uFF0C\u4F46\u8BF7\u6309\u5907\u6CE8\u6761\u4EF6\u5224\u65AD\u3002" : "\u672A\u53C2\u4E0E\u6700\u4F4E\u4EF7\u5224\u5B9A\u3002") : null, record.channels.some(function(channel) {
      return channel.match === "unknown";
    }) ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, "\u6709 ", record.channels.filter(function(channel) {
      return channel.match === "unknown";
    }).length, " \u4E2A\u5E73\u53F0\u7684\u9996\u5C4F\u770B\u4E0D\u6E05\u6761\u4EF6\uFF0C\u5DF2\u6807\u6CE8\u201C\u5F85\u786E\u8BA4\u201D\uFF0C\u8BF7\u6309\u5907\u6CE8\u5224\u65AD\u3002") : null, nonAuthentic.length ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-warnline" }, "\u6709 ", nonAuthentic.length, " \u6761\u62A5\u4EF7\u6CA1\u6709\u6807\u660E\u5B98\u65D7\u3001\u767E\u8865\u3001\u81EA\u8425\u3001\u5929\u732B\u56FD\u9645\u3001\u8D85\u503C\u8D2D\u6216\u54C1\u724C\u9ED1\u6807\uFF0C\u672A\u53C2\u4E0E\u6700\u4F4E\u4EF7\u5224\u5B9A\u3002") : null), /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-section" }, /* @__PURE__ */ import_react2.default.createElement(SectionHead, { title: "\u5404\u5E73\u53F0\u4EF7\u683C", action: /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-caption" }, record.channels.length + record.missing.length, " \u4E2A\u6E20\u9053") }), renderChannelTable(record)), record.channels.length ? /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-section" }, /* @__PURE__ */ import_react2.default.createElement(SectionHead, { title: "\u6765\u6E90\u4E0E\u6838\u9A8C\u65F6\u95F4", action: /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-caption" }, "\u94FE\u63A5\u53EF\u4E0D\u586B\uFF0C\u65F6\u95F4\u66F4\u91CD\u8981") }), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-list" }, record.channels.map(function(channel, index) {
      return /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-source pr-glass", key: index }, /* @__PURE__ */ import_react2.default.createElement(PlatformDot, { platform: channel.platform }), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-source-body" }, channel.url ? /* @__PURE__ */ import_react2.default.createElement("a", { href: channel.url, target: "_blank", rel: "noreferrer" }, channel.linkKind === "search" ? "\u641C\u7D22\u9875 \xB7 " : "", channel.url) : /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-source-nolink" }, channel.linkKind === "current" ? "\u5F53\u524D\u9875\u9762\u6838\u9A8C\uFF0C\u672A\u4FDD\u5B58\u94FE\u63A5" : "\u9875\u9762\u6838\u9A8C\uFF0C\u672A\u4FDD\u5B58\u94FE\u63A5"), /* @__PURE__ */ import_react2.default.createElement("time", null, channel.verifiedAt ? "\u6838\u9A8C\u4E8E " + formatDateTime(parseTime(channel.verifiedAt)) : "\u7F3A\u5C11\u6838\u9A8C\u65F6\u95F4", channel.verifiedAt && Date.now() - parseTime(channel.verifiedAt) > 24 * 60 * 60 * 1e3 ? " \xB7 \u5EFA\u8BAE\u590D\u6838" : ""), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-source-match" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-match", "data-tone": matchMeta(channel, record.kind).tone || void 0 }, matchMeta(channel, record.kind).label), channel.specSeen ? /* @__PURE__ */ import_react2.default.createElement("span", null, "\u9875\u9762\u663E\u793A\uFF1A", channel.specSeen) : null), channel.matchNote ? /* @__PURE__ */ import_react2.default.createElement("p", null, "\u5DEE\u5F02\uFF1A", channel.matchNote) : null, channel.coupons.length ? /* @__PURE__ */ import_react2.default.createElement("p", null, "\u5238\uFF1A", channel.coupons.join(" \xB7 ")) : null, channel.note ? /* @__PURE__ */ import_react2.default.createElement("p", null, channel.note) : null));
    }))) : null, record.assumptions.length ? /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-section" }, /* @__PURE__ */ import_react2.default.createElement(SectionHead, { title: "\u4F18\u60E0\u5047\u8BBE" }), /* @__PURE__ */ import_react2.default.createElement("ul", { className: "pr-assumptions" }, record.assumptions.map(function(item, index) {
      return /* @__PURE__ */ import_react2.default.createElement("li", { key: index }, item);
    }))) : null, /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-action-card pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-action-head" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-action-icon" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "bell", size: 18 })), /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u4EF7\u683C\u63D0\u9192"), /* @__PURE__ */ import_react2.default.createElement("small", null, "\u4EF7\u683C\u4F1A\u53D8\uFF0C\u63D0\u9192\u7531\u7CFB\u7EDF\u95F9\u949F\u4FDD\u5B58\uFF0C\u79BB\u5F00\u9875\u9762\u4E5F\u4F1A\u54CD\u3002"))), record.reminderAt ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-reminder-set" }, /* @__PURE__ */ import_react2.default.createElement("span", null, "\u5DF2\u5B89\u6392 ", formatDateTime(record.reminderAt), record.reminderTiming === "inexact" ? "\uFF08\u7CFB\u7EDF\u53EF\u80FD\u5EF6\u8FDF\uFF09" : ""), /* @__PURE__ */ import_react2.default.createElement(
      "button",
      {
        type: "button",
        className: "pr-link muted",
        disabled: remindBusy === record.id + ":cancel",
        onClick: function() {
          void cancelReminder(record);
        }
      },
      remindBusy === record.id + ":cancel" ? "\u53D6\u6D88\u4E2D\u2026" : "\u53D6\u6D88\u63D0\u9192"
    )) : /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-chips" }, [
      [30, "30 \u5206\u949F\u540E"],
      [120, "2 \u5C0F\u65F6\u540E"],
      [1440, "24 \u5C0F\u65F6\u540E"]
    ].map(function(item) {
      return /* @__PURE__ */ import_react2.default.createElement(
        "button",
        {
          type: "button",
          key: item[0],
          className: "pr-chip",
          disabled: remindBusy === record.id + ":" + item[0],
          onClick: function() {
            void remind(record, item[0]);
          }
        },
        remindBusy === record.id + ":" + item[0] ? "\u5B89\u6392\u4E2D\u2026" : item[1]
      );
    })), !remindersGranted ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, "\u63D0\u9192\u672A\u6388\u6743\u7ED9\u672C\u4F5C\u54C1\uFF0C\u70B9\u4E0A\u9762\u7684\u65F6\u95F4\u4F1A\u6253\u5F00\u80FD\u529B\u4E2D\u5FC3\u3002") : null), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, "\u201C\u590D\u6838\u4EF7\u683C\u201D\u4F1A\u542F\u52A8\u65B0\u4EFB\u52A1\uFF1B\u53EA\u8865\u6700\u65B0\u7ED3\u679C\u65F6\u7528\u9875\u9762\u9876\u90E8\u7684\u201C\u5237\u65B0\u6293\u4EF7\u201D\u3002"), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-btn-row" }, /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button", onClick: function() {
      void verifyRecord(record);
    } }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "refresh", size: 17 }), " \u590D\u6838\u4EF7\u683C"), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button secondary", onClick: exportAll }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "download", size: 17 }), " \u5BFC\u51FA"), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button danger", onClick: function() {
      askDeleteRecord(record);
    } }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "trash", size: 17 }), " \u5220\u9664"), record.sessionId ? /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button secondary", onClick: openTask }, "\u67E5\u770B\u4EFB\u52A1") : null), record.eventsTail.length ? /* @__PURE__ */ import_react2.default.createElement("details", { className: "pr-details" }, /* @__PURE__ */ import_react2.default.createElement("summary", null, "\u6700\u8FD1\u4E00\u6B21\u4EFB\u52A1\u6B65\u9AA4"), /* @__PURE__ */ import_react2.default.createElement("ul", null, record.eventsTail.map(function(item, index) {
      return /* @__PURE__ */ import_react2.default.createElement("li", { key: index }, item);
    }))) : null);
  }
  function renderMemoryEditor(edit) {
    return /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-mem-editor" }, /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u9886\u5238\u8981\u70B9", hint: "\u6BCF\u6B21\u6BD4\u4EF7\u90FD\u4F1A\u68C0\u67E5", id: "mem-coupon-" + edit.platform }, /* @__PURE__ */ import_react2.default.createElement(
      "input",
      {
        id: "mem-coupon-" + edit.platform,
        className: "wish-input",
        type: "text",
        value: edit.coupon,
        onChange: function(event) {
          setMemoryEdit({ ...edit, coupon: event.target.value });
        }
      }
    )), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u64CD\u4F5C\u6B65\u9AA4", hint: "\u4E00\u884C\u4E00\u6B65\uFF0C\u6309\u6267\u884C\u987A\u5E8F", id: "mem-steps-" + edit.platform }, /* @__PURE__ */ import_react2.default.createElement(
      "textarea",
      {
        id: "mem-steps-" + edit.platform,
        className: "wish-input pr-textarea",
        rows: 7,
        value: edit.stepsText,
        onChange: function(event) {
          setMemoryEdit({ ...edit, stepsText: event.target.value });
        }
      }
    )), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u8865\u5145\u8BF4\u660E", hint: "\u9009\u586B\uFF0C\u4F8B\u5982\u5E38\u89C1\u5F39\u7A97", id: "mem-notes-" + edit.platform }, /* @__PURE__ */ import_react2.default.createElement(
      "textarea",
      {
        id: "mem-notes-" + edit.platform,
        className: "wish-input pr-textarea",
        rows: 2,
        value: edit.notes,
        onChange: function(event) {
          setMemoryEdit({ ...edit, notes: event.target.value });
        }
      }
    )), edit.aiState === "running" || edit.aiState === "queued" ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-ai-loading" }, /* @__PURE__ */ import_react2.default.createElement(Spinner, { small: true }), /* @__PURE__ */ import_react2.default.createElement("span", null, "\u6B63\u5728\u6839\u636E\u6700\u8FD1\u4E00\u6B21\u4EFB\u52A1\u4F18\u5316\u6BD4\u4EF7\u65B9\u6CD5\u2026")) : null, edit.error ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, edit.error) : null, edit.preview ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-preview pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("strong", null, "AI \u5EFA\u8BAE"), /* @__PURE__ */ import_react2.default.createElement("ol", null, edit.preview.steps.map(function(step, index) {
      return /* @__PURE__ */ import_react2.default.createElement("li", { key: index }, step);
    })), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, "\u9886\u5238\uFF1A", edit.preview.coupon), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-btn-row" }, /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button", onClick: applyMemoryPreview }, "\u5E94\u7528\u5EFA\u8BAE"), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button secondary", onClick: function() {
      setMemoryEdit({ ...edit, preview: null });
    } }, "\u5FFD\u7565"))) : null, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-btn-row" }, /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button", disabled: edit.saving, onClick: commitMemoryEdit }, edit.saving ? "\u4FDD\u5B58\u4E2D\u2026" : "\u4FDD\u5B58\u65B9\u6CD5"), /* @__PURE__ */ import_react2.default.createElement(
      "button",
      {
        type: "button",
        className: "wish-button secondary",
        disabled: edit.aiState === "running" || edit.aiState === "queued",
        onClick: function() {
          void refineMemoryFromEdit(edit);
        }
      },
      /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "spark", size: 16 }),
      " \u8BA9 AI \u4F18\u5316"
    ), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "pr-link muted", onClick: function() {
      setMemoryEdit(null);
    } }, "\u53D6\u6D88")), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-save-state", "data-state": saveHint.state || void 0 }, saveHint.text));
  }
  function renderMemory() {
    function memoryCard(platform) {
      const entry = memory.platforms[platform.id] || { steps: [], coupon: "", notes: "" };
      const editing = memoryEdit && memoryEdit.platform === platform.id;
      return /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-mem pr-glass", key: platform.id }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-mem-head" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-mem-title" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-dot", style: { background: platform.color } }), platform.name, /* @__PURE__ */ import_react2.default.createElement("small", null, platform.channels.join(" / "))), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-mem-time" }, memory.updatedAt ? agoLabel(memory.updatedAt, tick) : "\u9ED8\u8BA4\u65B9\u6CD5")), editing ? renderMemoryEditor(memoryEdit) : /* @__PURE__ */ import_react2.default.createElement(import_react2.default.Fragment, null, /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-coupon" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: platform.travel ? "tag" : "tag", size: 15 }), /* @__PURE__ */ import_react2.default.createElement("span", null, entry.coupon)), /* @__PURE__ */ import_react2.default.createElement("ol", { className: "pr-steps" }, (entry.steps || []).map(function(step, index) {
        return /* @__PURE__ */ import_react2.default.createElement("li", { key: index }, step);
      })), entry.notes ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, "\u8865\u5145\uFF1A", entry.notes) : null, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-mem-actions" }, /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "pr-link", onClick: function() {
        beginMemoryEdit(platform.id, false);
      } }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "edit", size: 15 }), " \u7F16\u8F91"), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "pr-link", onClick: function() {
        beginMemoryEdit(platform.id, true);
      } }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "spark", size: 15 }), " AI \u4F18\u5316"), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "pr-link muted", onClick: function() {
        askResetMemory(platform.id);
      } }, "\u6062\u590D\u9ED8\u8BA4"))));
    }
    return /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-stack" }, globalError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, globalError) : null, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-page-intro" }, /* @__PURE__ */ import_react2.default.createElement("h2", null, "\u6BD4\u4EF7\u65B9\u6CD5"), /* @__PURE__ */ import_react2.default.createElement("p", null, "\u6BCF\u4E2A\u5E73\u53F0\u7684\u6BD4\u4EF7\u65B9\u6CD5\u4F1A\u76F4\u63A5\u5199\u8FDB\u4EFB\u52A1\u63D0\u793A\u8BCD\u3002\u754C\u9762\u53D8\u4E86\u5C31\u6539\u8FD9\u91CC\uFF0C\u6216\u8BA9 AI \u6839\u636E\u6700\u8FD1\u4E00\u6B21\u4EFB\u52A1\u4F18\u5316\uFF1B\u4FDD\u5B58\u540E\u4E0B\u4E00\u6B21\u6BD4\u4EF7\u7ACB\u5373\u751F\u6548\u3002")), /* @__PURE__ */ import_react2.default.createElement(SectionHead, { title: "\u5546\u54C1\u5E73\u53F0", action: /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-caption" }, "\u6DD8\u5B9D / \u62FC\u591A\u591A / \u6296\u97F3 / \u4EAC\u4E1C") }), PLATFORMS.map(memoryCard), /* @__PURE__ */ import_react2.default.createElement(SectionHead, { title: "\u9152\u5E97 / \u673A\u7968\u5E73\u53F0", action: /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-caption" }, "\u643A\u7A0B / \u7F8E\u56E2 / \u53BB\u54EA\u513F") }), TRAVEL_PLATFORMS.map(memoryCard), /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-rule pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-rule-head" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "shield", size: 18 }), /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u53EA\u8BB0\u5F55\u6709\u6B63\u54C1/\u6B63\u89C4\u5FC3\u667A\u7684\u6E20\u9053")), /* @__PURE__ */ import_react2.default.createElement("ul", null, /* @__PURE__ */ import_react2.default.createElement("li", null, "\u6DD8\u5B9D / \u5929\u732B\uFF1A\u5B98\u65B9\u65D7\u8230\u5E97\u3001\u5929\u732B\u56FD\u9645\u3001\u767E\u4EBF\u8865\u8D34\u3001\u54C1\u724C\u8D85\u503C\u8D2D"), /* @__PURE__ */ import_react2.default.createElement("li", null, "\u62FC\u591A\u591A\uFF1A\u767E\u4EBF\u8865\u8D34\u3001\u5B98\u65B9\u65D7\u8230\u5E97\u3001\u54C1\u724C\u9ED1\u6807"), /* @__PURE__ */ import_react2.default.createElement("li", null, "\u6296\u97F3\u5546\u57CE\uFF1A\u54C1\u724C\u9ED1\u6807\u3001\u5B98\u65B9\u65D7\u8230\u5E97\u3001\u8D85\u503C\u8D2D"), /* @__PURE__ */ import_react2.default.createElement("li", null, "\u4EAC\u4E1C\uFF1A\u4EAC\u4E1C\u81EA\u8425\u3001\u5B98\u65B9\u65D7\u8230\u5E97\u3001\u767E\u4EBF\u8865\u8D34\u3001\u4EAC\u4E1C\u56FD\u9645"), /* @__PURE__ */ import_react2.default.createElement("li", null, "\u9152\u5E97\uFF1A\u9152\u5E97\u5B98\u65B9/\u8FDE\u9501\u5B98\u65B9\u3001\u643A\u7A0B\u81EA\u8425\u3001\u7F8E\u56E2\u81EA\u8425\u3001\u53BB\u54EA\u513F\u81EA\u8425"), /* @__PURE__ */ import_react2.default.createElement("li", null, "\u673A\u7968\uFF1A\u822A\u53F8\u5B98\u65B9\u3001\u643A\u7A0B\u81EA\u8425\u3001\u7F8E\u56E2\u81EA\u8425\u3001\u53BB\u54EA\u513F\u81EA\u8425")), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, "C \u5E97\u3001\u4E2A\u4EBA\u5E97\u3001\u62CD\u5356\u3001\u4E8C\u624B\u3001\u7B2C\u4E09\u65B9\u4EE3\u7406\u4E0D\u8FDB\u5165\u6BD4\u4EF7\u8868\uFF1B\u62FF\u4E0D\u5230\u7684\u4EF7\u683C\u7528\u7A7A\u503C\u8868\u793A\uFF0C\u4E0D\u4F30\u7B97\u3001\u4E0D\u6CBF\u7528\u65E7\u4EF7\u3002")));
  }
  function renderSettings() {
    const recordCount = records.length;
    return /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-settings pr-settings" }, globalError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, globalError) : null, /* @__PURE__ */ import_react2.default.createElement("fieldset", null, /* @__PURE__ */ import_react2.default.createElement("legend", null, "\u5165\u53E3\u4E0E\u6BD4\u4EF7"), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-setting" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-setting-label" }, "\u8DE8 App \u60AC\u6D6E\u5165\u53E3", /* @__PURE__ */ import_react2.default.createElement("small", null, "\u5728\u53F3\u4E0A\u89D2 \u22EF \u2192\u300C\u6743\u9650\u4E0E\u52A8\u4F5C\u300D\u4E2D\u5F00\u542F/\u5173\u95ED\u548C\u7BA1\u7406\uFF1B\u672C\u4F5C\u54C1\u4E0D\u5355\u72EC\u63D0\u4F9B\u5F00\u5173\u3002")), /* @__PURE__ */ import_react2.default.createElement(
      "button",
      {
        type: "button",
        className: "wish-button secondary",
        onClick: function() {
          void openFloatingControls("\u5728\u53F3\u4E0A\u89D2 \u22EF \u2192\u300C\u6743\u9650\u4E0E\u52A8\u4F5C\u300D\u4E2D\u7BA1\u7406\u60AC\u6D6E\u5165\u53E3\u3002");
        }
      },
      "\u67E5\u770B"
    )), /* @__PURE__ */ import_react2.default.createElement("label", { className: "wish-setting" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-setting-label" }, "\u4ECE\u5546\u54C1\u9875\u53D1\u8D77\u65F6\u8DF3\u8FC7\u5F53\u524D\u5E73\u53F0", /* @__PURE__ */ import_react2.default.createElement("small", null, "\u5F53\u524D\u9875\u76F4\u63A5\u4F5C\u4E3A\u6765\u6E90\uFF1B\u4E0D\u91CD\u65B0\u641C\u7D22\u3001\u4E0D\u590D\u5236\u94FE\u63A5\uFF0C\u53EA\u67E5\u5176\u4ED6\u5E73\u53F0")), /* @__PURE__ */ import_react2.default.createElement(
      "input",
      {
        type: "checkbox",
        checked: settings.skipSource,
        onChange: function(event) {
          void changeSettings({ skipSource: event.target.checked });
        }
      }
    )), /* @__PURE__ */ import_react2.default.createElement("label", { className: "wish-setting" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-setting-label" }, "\u81EA\u52A8\u68C0\u67E5\u9886\u5238\u4E0E\u6EE1\u51CF", /* @__PURE__ */ import_react2.default.createElement("small", null, "\u53EA\u5728\u9700\u8981\u65F6\u67E5\u4E00\u6B21\uFF1A\u6DD8\u5B9D\u6211\u7684\u5238\u3001\u62FC\u591A\u591A\u767E\u8865\u4F1A\u5458\u5165\u53E3\u3001\u6296\u97F3\u5546\u57CE\u9886\u5238\u9875\u3001\u4EAC\u4E1C\u9886\u5238\u533A")), /* @__PURE__ */ import_react2.default.createElement(
      "input",
      {
        type: "checkbox",
        checked: settings.autoCoupon,
        onChange: function(event) {
          void changeSettings({ autoCoupon: event.target.checked });
        }
      }
    )), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-setting pr-setting-stack" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-setting-label" }, "\u9ED8\u8BA4\u6BD4\u4EF7\u5E73\u53F0", /* @__PURE__ */ import_react2.default.createElement("small", null, "\u5F53\u524D\uFF1A", selectedPlatformNames(settings.platforms) || "\u672A\u9009\u62E9")), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-chips" }, PLATFORMS.map(function(platform) {
      const on = settings.platforms.indexOf(platform.id) >= 0;
      return /* @__PURE__ */ import_react2.default.createElement(
        "button",
        {
          type: "button",
          key: platform.id,
          className: "pr-chip",
          "data-on": on ? "true" : "false",
          "aria-pressed": on,
          onClick: function() {
            setAllSettingsPlatforms(platform.id);
          }
        },
        /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-chip-dot", style: { background: platform.color } }),
        platform.name,
        on ? /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "check", size: 14 }) : null
      );
    }))), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, "\u624B\u673A\u64CD\u63A7\u6309\u4F5C\u54C1\u6388\u6743\u4E00\u6B21\uFF1B\u6574\u573A\u6BD4\u4EF7\u53EA\u542F\u52A8\u4E00\u4E2A\u4EFB\u52A1\uFF0C\u4E0D\u4F1A\u4E3A\u6BCF\u4E2A App \u91CD\u65B0\u7533\u8BF7\u6388\u6743\u3002"), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-save-state", "data-state": saveHint.state || void 0 }, saveHint.text)), /* @__PURE__ */ import_react2.default.createElement("fieldset", null, /* @__PURE__ */ import_react2.default.createElement("legend", null, "\u9152\u5E97 / \u673A\u7968\u5E73\u53F0"), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-setting pr-setting-stack" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-setting-label" }, "\u9ED8\u8BA4\u51FA\u884C\u5E73\u53F0", /* @__PURE__ */ import_react2.default.createElement("small", null, "\u5F53\u524D\uFF1A", selectedPlatformNames(settings.travelPlatforms) || "\u672A\u9009\u62E9", "\uFF1B\u9152\u5E97\u540C\u65E5\u671F\u540C\u623F\u578B\u3001\u673A\u7968\u540C\u822A\u73ED\u540C\u8231\u4F4D\u624D\u6BD4\u8F83")), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-chips" }, TRAVEL_PLATFORMS.map(function(platform) {
      const on = (settings.travelPlatforms || []).indexOf(platform.id) >= 0;
      return /* @__PURE__ */ import_react2.default.createElement(
        "button",
        {
          type: "button",
          key: platform.id,
          className: "pr-chip",
          "data-on": on ? "true" : "false",
          "aria-pressed": on,
          onClick: function() {
            setAllTravelPlatforms(platform.id);
          }
        },
        /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-chip-dot", style: { background: platform.color } }),
        platform.name,
        on ? /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "check", size: 14 }) : null
      );
    }))), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, "\u643A\u7A0B\u3001\u7F8E\u56E2\u3001\u53BB\u54EA\u513F\u53EA\u8BB0\u5F55\u9152\u5E97\u5B98\u65B9/\u81EA\u8425\u3001\u822A\u53F8\u5B98\u65B9/\u81EA\u8425\uFF1B\u7B2C\u4E09\u65B9\u4EE3\u7406\u4E0D\u8FDB\u5165\u6700\u4F4E\u4EF7\u3002")), /* @__PURE__ */ import_react2.default.createElement("fieldset", null, /* @__PURE__ */ import_react2.default.createElement("legend", null, "\u540E\u53F0\u63D0\u9192"), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-setting" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-setting-label" }, "\u4F5C\u54C1\u63D0\u9192\u6388\u6743", /* @__PURE__ */ import_react2.default.createElement("small", null, remindersGranted ? "\u5DF2\u6388\u6743\u7ED9\u672C\u4F5C\u54C1\uFF0C\u63D0\u9192\u7531\u7CFB\u7EDF AlarmManager \u4FDD\u5B58" : "\u672A\u6388\u6743\uFF1B\u9700\u8981\u65F6\u518D\u6253\u5F00\u80FD\u529B\u4E2D\u5FC3\uFF0C\u4E0D\u4F1A\u81EA\u52A8\u7D22\u53D6")), /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-badge", "data-state": remindersGranted ? "ready" : void 0 }, remindersGranted ? "\u5DF2\u6388\u6743" : "\u672A\u6388\u6743")), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-setting" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-setting-label" }, "\u6D4B\u8BD5\u540E\u53F0\u63D0\u9192", /* @__PURE__ */ import_react2.default.createElement("small", null, "1 \u5206\u949F\u540E\u89E6\u53D1\uFF1B\u53EF\u9000\u51FA\u9875\u9762\u9A8C\u8BC1")), /* @__PURE__ */ import_react2.default.createElement(
      "button",
      {
        type: "button",
        className: "wish-button secondary",
        disabled: remindBusy === "test",
        onClick: testReminder
      },
      remindBusy === "test" ? "\u5B89\u6392\u4E2D\u2026" : "\u6D4B\u8BD5\u4E00\u6B21"
    )), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, remindersGranted ? "\u5982\u679C\u8FD4\u56DE\u7684 timing \u662F inexact\uFF0C\u7CFB\u7EDF\u53EF\u80FD\u5EF6\u8FDF\u51E0\u5206\u949F\uFF1B\u4F5C\u54C1\u4F1A\u5728\u5B89\u6392\u540E\u8BF4\u660E\u3002" : "\u63D0\u9192\u672A\u6388\u6743\u65F6\u70B9\u6D4B\u8BD5\u4F1A\u6253\u5F00\u80FD\u529B\u4E2D\u5FC3\uFF0C\u6388\u6743\u540E\u8FD4\u56DE\u518D\u8BD5\u3002")), /* @__PURE__ */ import_react2.default.createElement("fieldset", null, /* @__PURE__ */ import_react2.default.createElement("legend", null, "\u672C\u5730\u6570\u636E"), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-setting" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-setting-label" }, "\u6BD4\u4EF7\u8BB0\u5F55", /* @__PURE__ */ import_react2.default.createElement("small", null, "\u5171 ", recordCount, " \u6761\uFF0C\u4FDD\u5B58\u5728\u672C\u4F5C\u54C1\uFF0C\u4E0D\u4E0A\u4F20")), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button secondary", onClick: exportAll, disabled: !recordCount }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "download", size: 16 }), " \u5BFC\u51FA")), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-setting" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-setting-label" }, "\u672C\u5730\u8BB0\u5F55\u6E05\u7406", /* @__PURE__ */ import_react2.default.createElement("small", null, "\u53EA\u5F71\u54CD\u672C\u4F5C\u54C1\u8BB0\u5F55\uFF0C\u4E0D\u5F71\u54CD\u5176\u4ED6\u4F5C\u54C1")), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button danger", onClick: askClear, disabled: !recordCount }, "\u6E05\u7A7A"))), /* @__PURE__ */ import_react2.default.createElement("fieldset", null, /* @__PURE__ */ import_react2.default.createElement("legend", null, "\u80FD\u529B\u4E0E\u6388\u6743"), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-cap-row" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-cap-icon", "data-ok": phoneGranted ? "true" : "false" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: phoneGranted ? "check" : "phone", size: 17 })), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-cap-copy" }, /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u624B\u673A\u64CD\u63A7"), /* @__PURE__ */ import_react2.default.createElement("small", null, phoneGranted ? a11y === false ? "\u5DF2\u6388\u6743\uFF0C\u4F46\u5171\u4EAB\u65E0\u969C\u788D\u670D\u52A1\u672A\u8FDE\u63A5" : "\u5DF2\u6388\u6743\uFF0C\u53EF\u542F\u52A8\u771F\u5B9E\u6BD4\u4EF7\u4EFB\u52A1" : "\u672A\u6388\u6743\uFF1B\u5F00\u59CB\u6BD4\u4EF7\u65F6\u4F1A\u63D0\u793A\u53BB\u80FD\u529B\u4E2D\u5FC3")), /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-badge", "data-state": phoneGranted ? "ready" : "error" }, phoneGranted ? "\u5DF2\u5F00\u542F" : "\u672A\u5F00\u542F")), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-cap-row" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-cap-icon", "data-ok": aiReady ? "true" : "unknown" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: aiReady ? "check" : "spark", size: 17 })), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-cap-copy" }, /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u5DF2\u767B\u5F55\u6A21\u578B"), /* @__PURE__ */ import_react2.default.createElement("small", null, aiReady ? "\u53EF\u76F4\u63A5\u770B\u56FE\u3001\u4F18\u5316\u6BD4\u4EF7\u65B9\u6CD5\uFF0C\u4E0D\u9700\u8981\u586B Key" : "\u6A21\u578B\u72B6\u6001\u672A\u77E5\uFF0CAI \u529F\u80FD\u4F1A\u63D0\u793A\u5931\u8D25\u539F\u56E0")), /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-badge", "data-state": aiReady ? "ready" : void 0 }, aiReady ? "\u53EF\u7528" : "\u5F85\u68C0\u67E5")), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-setting" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-setting-label" }, "\u6253\u5F00\u80FD\u529B\u4E2D\u5FC3", /* @__PURE__ */ import_react2.default.createElement("small", null, "\u53EA\u5728\u9700\u8981\u65F6\u6253\u5F00\uFF1B\u5DF2\u5F00\u542F\u7684\u80FD\u529B\u4E0D\u4F1A\u91CD\u590D\u7D22\u53D6")), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button secondary", onClick: function() {
      openCaps("");
    } }, "\u67E5\u770B"))), /* @__PURE__ */ import_react2.default.createElement("fieldset", null, /* @__PURE__ */ import_react2.default.createElement("legend", null, "\u4F5C\u54C1"), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-setting" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-setting-label" }, "\u5BA2\u6237\u7AEF\u7248\u672C", /* @__PURE__ */ import_react2.default.createElement("small", null, "\u7528\u4E8E\u786E\u8BA4\u9875\u9762\u662F\u5426\u5DF2\u52A0\u8F7D\u6700\u65B0\u4EE3\u7801")), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-caption" }, "v", VERSION)), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-setting" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "wish-setting-label" }, "\u53D1\u5E03\u5230\u4F5C\u54C1\u5899", /* @__PURE__ */ import_react2.default.createElement("small", null, "\u786E\u8BA4\u6D41\u7A0B\u53EF\u7528\u540E\u518D\u53D1\u5E03")), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button", onClick: askPublish }, "\u53D1\u5E03")), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, TITLE, " v", VERSION, "\u3002\u6BD4\u4EF7\u901A\u8FC7\u5171\u4EAB\u65E0\u969C\u788D\u670D\u52A1\u771F\u5B9E\u8BFB\u5C4F\uFF1B\u4F5C\u54C1\u4E0D\u8BFB\u53D6\u767B\u5F55\u51ED\u636E\uFF0C\u4E0D\u4EE3\u66FF\u4F60\u4E0B\u5355\u6216\u4ED8\u6B3E\uFF0C\u4E5F\u4E0D\u4F1A\u58F0\u79F0\u672A\u7ECF\u6838\u9A8C\u7684\u201C\u5168\u7F51\u6700\u4F4E\u201D\u3002")));
  }
  function renderAdd() {
    const kind = KINDS.indexOf(form.kind) >= 0 ? form.kind : "product";
    const isTravel = kind === "hotel" || kind === "flight";
    const platformDefs = isTravel ? TRAVEL_PLATFORMS : PLATFORMS;
    const busyCamera = photo && (photo.state === "capturing" || photo.state === "reading");
    return /* @__PURE__ */ import_react2.default.createElement(
      "form",
      {
        className: "pr-stack",
        onSubmit: function(event) {
          event.preventDefault();
          void saveCandidate(false);
        }
      },
      globalError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, globalError) : null,
      /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-kind-tabs", role: "tablist", "aria-label": "\u5019\u9009\u7C7B\u578B" }, KIND_TABS.map(function(tab) {
        const active2 = kind === tab.id;
        return /* @__PURE__ */ import_react2.default.createElement(
          "button",
          {
            type: "button",
            key: tab.id,
            role: "tab",
            className: "pr-kind-tab",
            "aria-selected": active2,
            "data-on": active2 ? "true" : "false",
            onClick: function() {
              setForm(function(previous) {
                return { ...previous, kind: tab.id, sourcePlatform: "" };
              });
              setFormError("");
            }
          },
          /* @__PURE__ */ import_react2.default.createElement(Icon, { name: tab.icon, size: 17 }),
          /* @__PURE__ */ import_react2.default.createElement("span", null, tab.label)
        );
      })),
      !isTravel ? /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-camera pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-camera-head" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-action-icon" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "camera", size: 19 })), /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u62CD\u5546\u54C1\u9875"), /* @__PURE__ */ import_react2.default.createElement("small", null, "\u672C\u5730 OCR \u5148\u8BFB\u6587\u5B57\uFF0C\u518D\u7528\u5F53\u524D\u5DF2\u767B\u5F55\u6A21\u578B\u6574\u7406\uFF1B\u4E0D\u9700\u8981\u590D\u5236\u94FE\u63A5\uFF0C\u56FE\u7247\u53EA\u5728\u672C\u9875\u9884\u89C8\uFF0C\u4E0D\u4FDD\u5B58\u3002"))), photo && photo.url ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-photo-wrap" }, /* @__PURE__ */ import_react2.default.createElement("img", { src: photo.url, alt: "\u5546\u54C1\u9875\u9884\u89C8" }), busyCamera ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-photo-busy" }, /* @__PURE__ */ import_react2.default.createElement(Radar, { small: true }), /* @__PURE__ */ import_react2.default.createElement("span", null, photo.state === "reading" ? "AI \u6B63\u5728\u8BFB\u56FE" : "\u6B63\u5728\u6253\u5F00\u76F8\u673A")) : null) : null, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-btn-row" }, /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button secondary", disabled: busyCamera, onClick: function() {
        void capturePhoto();
      } }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "camera", size: 17 }), " ", photo && photo.url ? "\u91CD\u62CD" : "\u62CD\u7167"), /* @__PURE__ */ import_react2.default.createElement(
        "button",
        {
          type: "button",
          className: "wish-button",
          disabled: !photo || !photo.data || busyCamera,
          onClick: function() {
            void readPhotoWithAI();
          }
        },
        /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "spark", size: 17 }),
        " ",
        photo && photo.state === "reading" ? "\u8BFB\u53D6\u4E2D\u2026" : "AI \u8BFB\u53D6\u5546\u54C1"
      )), photo && photo.state === "reading" ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-progress" }, /* @__PURE__ */ import_react2.default.createElement("span", null)) : null, photo && photo.error ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, photo.error) : null, photo && photo.state === "done" ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-success-line" }, "\u5DF2\u586B\u5165\u5546\u54C1\u4FE1\u606F\uFF0C\u6838\u5BF9\u540E\u518D\u4FDD\u5B58\u3002") : null, photo && photo.ocr ? /* @__PURE__ */ import_react2.default.createElement("details", { className: "pr-details" }, /* @__PURE__ */ import_react2.default.createElement("summary", null, "\u672C\u5730 OCR \u6587\u5B57\uFF08", photo.ocr.length, " \u5B57\uFF09"), /* @__PURE__ */ import_react2.default.createElement("pre", { className: "pr-raw" }, clampText(photo.ocr, 900))) : null) : /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-note-card" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: kind === "hotel" ? "bed" : "plane", size: 17 }), /* @__PURE__ */ import_react2.default.createElement("span", null, kind === "hotel" ? "\u9152\u5E97\u5EFA\u8BAE\u7528\u60AC\u6D6E\u5165\u53E3\u300C\u8BB0\u4E0B\u8FD9\u4EF6\u300D\u76F4\u63A5\u6293\u5F53\u524D\u9875\uFF0C\u6216\u624B\u52A8\u586B\u9152\u5E97\u540D\u3001\u65E5\u671F\u3001\u623F\u578B\u548C\u9996\u5C4F\u4EF7\u3002" : "\u673A\u7968\u5EFA\u8BAE\u7528\u60AC\u6D6E\u5165\u53E3\u300C\u8BB0\u4E0B\u8FD9\u4EF6\u300D\u76F4\u63A5\u6293\u5F53\u524D\u9875\uFF0C\u6216\u624B\u52A8\u586B\u822A\u73ED\u53F7\u3001\u65E5\u671F\u3001\u822A\u7EBF\u548C\u9996\u5C4F\u4EF7\u3002")),
      /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-form-card pr-glass" }, kind === "hotel" ? /* @__PURE__ */ import_react2.default.createElement(import_react2.default.Fragment, null, /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u9152\u5E97\u540D", hint: "\u5FC5\u586B", id: "cand-hotel-name" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-hotel-name", className: "wish-input", type: "text", value: form.hotelName, placeholder: "\u4F8B\u5982 \u4E0A\u6D77\u5916\u6EE9\u67D0\u9152\u5E97", autoComplete: "off", onChange: function(event) {
        setFormField("hotelName", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u57CE\u5E02", hint: "\u9009\u586B", id: "cand-city" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-city", className: "wish-input", type: "text", value: form.city, placeholder: "\u4F8B\u5982 \u4E0A\u6D77", autoComplete: "off", onChange: function(event) {
        setFormField("city", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-form-grid" }, /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u5165\u4F4F", hint: "\u5FC5\u586B", id: "cand-checkin" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-checkin", className: "wish-input", type: "date", value: form.checkIn, onChange: function(event) {
        setFormField("checkIn", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u79BB\u5E97", hint: "\u5FC5\u586B", id: "cand-checkout" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-checkout", className: "wish-input", type: "date", value: form.checkOut, onChange: function(event) {
        setFormField("checkOut", event.target.value);
      } }))), /* @__PURE__ */ import_react2.default.createElement(
        "button",
        {
          type: "button",
          className: "pr-link",
          onClick: function() {
            setForm({ ...form, checkIn: localDateStamp(0), checkOut: localDateStamp(1) });
          }
        },
        "\u4ECA\u5929 \u2192 \u660E\u5929\uFF08\u8DF3\u8FC7\u65E5\u671F\u9009\u62E9\u5668\uFF09"
      ), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u623F\u578B\u53E3\u5F84", hint: "\u9ED8\u8BA4\u6700\u4F4E\u4EF7\u65E5\u5386\u623F", id: "cand-rate-mode" }, /* @__PURE__ */ import_react2.default.createElement("select", { id: "cand-rate-mode", className: "wish-select", value: form.rateMode, onChange: function(event) {
        setFormField("rateMode", event.target.value);
      } }, /* @__PURE__ */ import_react2.default.createElement("option", { value: "lowest" }, "\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\uFF08\u9ED8\u8BA4\uFF09"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "specific" }, "\u6307\u5B9A\u623F\u578B"))), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u623F\u578B", hint: form.rateMode === "specific" ? "\u6307\u5B9A\u623F\u578B\u65F6\u5FC5\u586B" : "\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\u53EF\u7559\u7A7A", id: "cand-room" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-room", className: "wish-input", type: "text", value: form.roomType, placeholder: "\u623F\u578B / \u5E8A\u578B / \u65E9\u9910", autoComplete: "off", onChange: function(event) {
        setFormField("roomType", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u4EBA\u6570", hint: "\u5165\u4F4F\u4EBA\u6570", id: "cand-guests" }, /* @__PURE__ */ import_react2.default.createElement("select", { id: "cand-guests", className: "wish-select", value: form.guests, onChange: function(event) {
        setFormField("guests", event.target.value);
      } }, /* @__PURE__ */ import_react2.default.createElement("option", { value: "1 \u4EBA" }, "1 \u4EBA"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "2 \u4EBA" }, "2 \u4EBA"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "3 \u4EBA" }, "3 \u4EBA"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "4 \u4EBA" }, "4 \u4EBA")))) : kind === "flight" ? /* @__PURE__ */ import_react2.default.createElement(import_react2.default.Fragment, null, /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u822A\u73ED\u53F7", hint: "\u5FC5\u586B", id: "cand-flight-no" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-flight-no", className: "wish-input", type: "text", value: form.flightNo, placeholder: "\u4F8B\u5982 MU1234", autoComplete: "off", onChange: function(event) {
        setFormField("flightNo", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u822A\u53F8", hint: "\u9009\u586B", id: "cand-airline" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-airline", className: "wish-input", type: "text", value: form.airline, placeholder: "\u4F8B\u5982 \u4E1C\u65B9\u822A\u7A7A", autoComplete: "off", onChange: function(event) {
        setFormField("airline", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u51FA\u53D1\u65E5\u671F", hint: "\u5FC5\u586B", id: "cand-flight-date" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-flight-date", className: "wish-input", type: "date", value: form.date, onChange: function(event) {
        setFormField("date", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-form-grid" }, /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u51FA\u53D1\u673A\u573A", hint: "\u9009\u586B", id: "cand-from" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-from", className: "wish-input", type: "text", value: form.from, placeholder: "\u4F8B\u5982 \u8679\u6865 T2", autoComplete: "off", onChange: function(event) {
        setFormField("from", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u5230\u8FBE\u673A\u573A", hint: "\u9009\u586B", id: "cand-to" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-to", className: "wish-input", type: "text", value: form.to, placeholder: "\u4F8B\u5982 \u9996\u90FD T3", autoComplete: "off", onChange: function(event) {
        setFormField("to", event.target.value);
      } }))), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u8231\u4F4D", hint: "\u9ED8\u8BA4\u7ECF\u6D4E\u8231", id: "cand-cabin" }, /* @__PURE__ */ import_react2.default.createElement("select", { id: "cand-cabin", className: "wish-select", value: form.cabin, onChange: function(event) {
        setFormField("cabin", event.target.value);
      } }, /* @__PURE__ */ import_react2.default.createElement("option", { value: "\u7ECF\u6D4E\u8231" }, "\u7ECF\u6D4E\u8231"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "\u8D85\u7EA7\u7ECF\u6D4E\u8231" }, "\u8D85\u7EA7\u7ECF\u6D4E\u8231"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "\u516C\u52A1\u8231" }, "\u516C\u52A1\u8231"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "\u5934\u7B49\u8231" }, "\u5934\u7B49\u8231")))) : /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u5546\u54C1\u540D", hint: "\u5FC5\u586B", id: "cand-title" }, /* @__PURE__ */ import_react2.default.createElement(
        "input",
        {
          id: "cand-title",
          className: "wish-input",
          type: "text",
          value: form.title,
          placeholder: "\u4F8B\u5982 \u67D0\u54C1\u724C\u964D\u566A\u8033\u673A Air 4",
          autoComplete: "off",
          onChange: function(event) {
            setFormField("title", event.target.value);
          }
        }
      )), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u6765\u6E90\u5E73\u53F0", hint: "\u6709\u4EF7\u683C\u65F6\u4F1A\u8DF3\u8FC7\u8FD9\u4E2A\u5E73\u53F0\u7684\u641C\u7D22", id: "cand-platform" }, /* @__PURE__ */ import_react2.default.createElement(
        "select",
        {
          id: "cand-platform",
          className: "wish-select",
          value: form.sourcePlatform,
          onChange: function(event) {
            setFormField("sourcePlatform", event.target.value);
          }
        },
        /* @__PURE__ */ import_react2.default.createElement("option", { value: "" }, "\u4E0D\u6307\u5B9A\uFF08\u6BD4\u4EF7\u65F6\u67E5\u6240\u6709\u5E73\u53F0\uFF09"),
        platformDefs.map(function(platform) {
          return /* @__PURE__ */ import_react2.default.createElement("option", { key: platform.id, value: platform.id }, platform.name);
        })
      )), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u6765\u6E90\u9875\u9762\u4EF7\u683C", hint: kind === "hotel" ? "\u6BCF\u665A\u9996\u5C4F\u4EF7" : kind === "flight" ? "\u6BCF\u4EBA\u9996\u5C4F\u7968\u4EF7" : "\u8BB0\u4E0B\u4EF7\u683C\uFF1B\u6BD4\u4EF7\u65F6\u8FD9\u4E00\u9875\u76F4\u63A5\u7B97", id: "cand-price" }, /* @__PURE__ */ import_react2.default.createElement(
        "input",
        {
          id: "cand-price",
          className: "wish-input",
          type: "text",
          inputMode: "decimal",
          value: form.price,
          placeholder: "\u4F8B\u5982 199",
          onChange: function(event) {
            setFormField("price", event.target.value);
          }
        }
      )), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, isTravel ? "\u53EA\u8BB0\u5173\u952E\u6761\u4EF6\u4E5F\u53EF\u4EE5\uFF1B\u6BD4\u4EF7\u65F6\u53EA\u67E5\u5176\u4ED6\u5E73\u53F0\uFF0C\u4E0D\u91CD\u65B0\u641C\u7D22\u6765\u6E90\u5E73\u53F0\uFF0C\u4E0D\u540C\u623F\u578B/\u822A\u73ED\u4F1A\u5907\u6CE8\uFF0C\u4E0D\u53C2\u4E0E\u6700\u4F4E\u4EF7\u3002" : "\u53EA\u8BB0\u540D\u5B57\u548C\u4EF7\u683C\u4E5F\u53EF\u4EE5\u3002\u6BD4\u4EF7\u65F6\u53EA\u67E5\u5176\u4ED6\u5E73\u53F0\uFF0C\u4E0D\u4F1A\u518D\u641C\u8FD9\u4E2A\u5E73\u53F0\uFF0C\u4E5F\u4E0D\u4F1A\u8BA9\u4F60\u590D\u5236\u94FE\u63A5\u3002"), /* @__PURE__ */ import_react2.default.createElement("details", { className: "pr-details" }, /* @__PURE__ */ import_react2.default.createElement("summary", null, kind === "hotel" ? "\u66F4\u591A\uFF08\u5E8A\u578B\u3001\u65E9\u9910\u3001\u53D6\u6D88\u653F\u7B56\u3001\u6E20\u9053\u3001\u94FE\u63A5\uFF09" : kind === "flight" ? "\u66F4\u591A\uFF08\u6E20\u9053\u7C7B\u578B\u3001\u94FE\u63A5\u3001\u5907\u6CE8\uFF09" : "\u66F4\u591A\uFF08\u89C4\u683C\u3001\u5E97\u94FA\u3001\u94FE\u63A5\u3001\u5907\u6CE8\uFF09"), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-details-fields" }, kind === "hotel" ? /* @__PURE__ */ import_react2.default.createElement(import_react2.default.Fragment, null, /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u5E8A\u578B", hint: "\u9009\u586B", id: "cand-bed" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-bed", className: "wish-input", type: "text", value: form.bedType, placeholder: "\u5927\u5E8A / \u53CC\u5E8A", autoComplete: "off", onChange: function(event) {
        setFormField("bedType", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u65E9\u9910", hint: "\u9009\u586B", id: "cand-breakfast" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-breakfast", className: "wish-input", type: "text", value: form.breakfast, placeholder: "\u542B\u53CC\u65E9 / \u65E0\u65E9", autoComplete: "off", onChange: function(event) {
        setFormField("breakfast", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u53D6\u6D88\u653F\u7B56", hint: "\u9009\u586B", id: "cand-cancel" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "cand-cancel", className: "wish-input", type: "text", value: form.cancelPolicy, placeholder: "\u514D\u8D39\u53D6\u6D88 / \u4E0D\u53EF\u53D6\u6D88", autoComplete: "off", onChange: function(event) {
        setFormField("cancelPolicy", event.target.value);
      } }))) : null, kind === "product" ? /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u89C4\u683C", hint: "\u578B\u53F7 / \u5BB9\u91CF / \u989C\u8272 / \u6570\u91CF", id: "cand-spec" }, /* @__PURE__ */ import_react2.default.createElement(
        "input",
        {
          id: "cand-spec",
          className: "wish-input",
          type: "text",
          value: form.spec,
          placeholder: "\u4F8B\u5982 \u767D\u8272 / \u5355\u53EA\u88C5 / \u6807\u51C6\u7248",
          autoComplete: "off",
          onChange: function(event) {
            setFormField("spec", event.target.value);
          }
        }
      )) : null, /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u6E20\u9053\u7C7B\u578B", hint: isTravel ? "\u9152\u5E97\u5B98\u65B9 / \u81EA\u8425 / \u822A\u53F8\u5B98\u65B9\u624D\u7B97\u6B63\u89C4\u6E20\u9053" : "\u5B98\u65D7 / \u767E\u8865 / \u81EA\u8425 / \u9ED1\u6807\u624D\u7B97\u6B63\u54C1\u6E20\u9053", id: "cand-store" }, /* @__PURE__ */ import_react2.default.createElement(
        "input",
        {
          id: "cand-store",
          className: "wish-input",
          type: "text",
          value: form.sourceStore,
          placeholder: kind === "hotel" ? "\u9152\u5E97\u5B98\u65B9 / \u643A\u7A0B\u81EA\u8425 / \u7F8E\u56E2\u81EA\u8425" : kind === "flight" ? "\u822A\u53F8\u5B98\u65B9 / \u643A\u7A0B\u81EA\u8425 / \u53BB\u54EA\u513F\u81EA\u8425" : "\u4F8B\u5982 \u5B98\u65B9\u65D7\u8230\u5E97",
          autoComplete: "off",
          onChange: function(event) {
            setFormField("sourceStore", event.target.value);
          }
        }
      )), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u94FE\u63A5\uFF08\u9009\u586B\uFF09", hint: "\u4E0D\u7528\u7279\u610F\u590D\u5236\uFF0C\u80FD\u8BFB\u5230\u518D\u586B", id: "cand-url" }, /* @__PURE__ */ import_react2.default.createElement(
        "input",
        {
          id: "cand-url",
          className: "wish-input",
          type: "url",
          value: form.url,
          placeholder: "https://\u2026\uFF08\u53EF\u4E0D\u586B\uFF09",
          autoComplete: "off",
          onChange: function(event) {
            setFormField("url", event.target.value);
          }
        }
      )), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u5907\u6CE8", hint: "\u9009\u586B", id: "cand-note" }, /* @__PURE__ */ import_react2.default.createElement(
        "textarea",
        {
          id: "cand-note",
          className: "wish-input pr-textarea",
          rows: 2,
          value: form.note,
          placeholder: isTravel ? "\u4F8B\u5982 \u9996\u5C4F\u4F1A\u5458\u4EF7 / \u542B\u7A0E\u8D39 / \u9700\u767B\u5F55" : "\u4F8B\u5982 \u9875\u9762\u663E\u793A\u5238\u540E\u4EF7\uFF0C\u8FD0\u8D39\u5F85\u786E\u8BA4",
          onChange: function(event) {
            setFormField("note", event.target.value);
          }
        }
      )))), formError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, formError) : null, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-btn-row" }, /* @__PURE__ */ import_react2.default.createElement("button", { type: "submit", className: "wish-button" }, "\u4FDD\u5B58\u5019\u9009"), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button secondary", onClick: function() {
        void saveCandidate(true);
      } }, "\u4FDD\u5B58\u5E76\u6BD4\u4EF7")))
    );
  }
  function renderQuick() {
    const url = firstLinkUrl(quickUrl);
    const source = platformFromLink(url);
    const kind = kindFromLink(url, source);
    const sourceName = source ? PLATFORM_MAP[source].name : "\u5F85\u8BC6\u522B";
    const kindName = kind === "hotel" ? "\u9152\u5E97" : kind === "flight" ? "\u673A\u7968" : "\u5546\u54C1";
    return /* @__PURE__ */ import_react2.default.createElement(
      "form",
      {
        className: "pr-stack",
        onSubmit: function(event) {
          event.preventDefault();
          void startLinkComparison();
        }
      },
      globalError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, globalError) : null,
      /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-quick pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-start-top" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-action-icon" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "link", size: 19 })), /* @__PURE__ */ import_react2.default.createElement("div", { style: { flex: 1, minWidth: 0 } }, /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u8D34\u4E2A\u94FE\u63A5\u5C31\u884C"), /* @__PURE__ */ import_react2.default.createElement("small", null, "\u6DD8\u5B9D / \u4EAC\u4E1C / \u62FC\u591A\u591A / \u6296\u97F3 / \u643A\u7A0B / \u7F8E\u56E2 / \u53BB\u54EA\u513F\u90FD\u53EF\u4EE5\uFF1B\u53EA\u8BFB\u9996\u5C4F\u4EF7\u683C\uFF0C\u4E0D\u590D\u5236\u3001\u4E0D\u5206\u4EAB\u3001\u4E0D\u4E0B\u5355\u3002")), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-badge" }, "\u53EA\u8BFB")), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u5546\u54C1 / \u9152\u5E97 / \u673A\u7968\u94FE\u63A5", hint: "\u7C98\u8D34\u5B8C\u6574\u94FE\u63A5", id: "quick-url" }, /* @__PURE__ */ import_react2.default.createElement(
        "textarea",
        {
          id: "quick-url",
          className: "wish-input pr-textarea",
          rows: 4,
          value: quickUrl,
          placeholder: "\u7C98\u8D34\u94FE\u63A5\uFF0C\u4F8B\u5982 https://\u2026",
          onChange: function(event) {
            setQuickUrl(event.target.value);
            setQuickError("");
          }
        }
      )), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-quick-meta" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-tag" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "link", size: 13 }), " ", sourceName), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-tag" }, kindName), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-caption" }, "\u6253\u5F00\u94FE\u63A5\u540E\u4F1A\u81EA\u52A8\u8BC6\u522B\u771F\u5B9E\u7C7B\u578B")), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-btn-row" }, /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button secondary", onClick: function() {
        void pasteQuickLink();
      } }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "scan", size: 17 }), " \u7C98\u8D34"), /* @__PURE__ */ import_react2.default.createElement("button", { type: "submit", className: "wish-button" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "compare", size: 17 }), " \u5F00\u59CB\u6BD4\u4EF7")), quickError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, quickError) : null, /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, "\u94FE\u63A5\u6253\u4E0D\u5F00\u6216\u843D\u5230\u6D4F\u89C8\u5668\u65F6\uFF0C\u52A9\u624B\u4F1A\u56DE\u5230\u5BF9\u5E94 App \u7528\u94FE\u63A5\u91CC\u7684\u540D\u79F0\u641C\u7D22\uFF1B\u4E0D\u4F1A\u505C\u5728\u6D4F\u89C8\u5668\uFF0C\u4E5F\u4E0D\u4F1A\u8BA9\u4F60\u518D\u586B\u4E00\u5806\u5B57\u6BB5\u3002")),
      /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "pr-link", onClick: openAdvancedFromQuick }, "\u624B\u52A8\u586B\u5199\u5546\u54C1 / \u9152\u5E97 / \u673A\u7968\u4FE1\u606F")
    );
  }
  function renderStart() {
    const kind = KINDS.indexOf(start.kind) >= 0 ? start.kind : "product";
    const isTravel = kind === "hotel" || kind === "flight";
    const platformDefs = isTravel ? TRAVEL_PLATFORMS : PLATFORMS;
    const platformList = isTravel ? start.travelPlatforms || [] : start.platforms || [];
    const sourceId = start.source && start.skipSource ? start.source.platform : "";
    return /* @__PURE__ */ import_react2.default.createElement(
      "form",
      {
        className: "pr-stack",
        onSubmit: function(event) {
          event.preventDefault();
          void startComparison();
        }
      },
      globalError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, globalError) : null,
      /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-kind-tabs", role: "tablist", "aria-label": "\u6BD4\u4EF7\u7C7B\u578B" }, KIND_TABS.map(function(tab) {
        const active2 = kind === tab.id;
        return /* @__PURE__ */ import_react2.default.createElement(
          "button",
          {
            type: "button",
            key: tab.id,
            role: "tab",
            className: "pr-kind-tab",
            "aria-selected": active2,
            "data-on": active2 ? "true" : "false",
            onClick: function() {
              setStartKind(tab.id);
            }
          },
          /* @__PURE__ */ import_react2.default.createElement(Icon, { name: tab.icon, size: 17 }),
          /* @__PURE__ */ import_react2.default.createElement("span", null, tab.label)
        );
      })),
      /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-start-head pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-start-top" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-action-icon" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: isTravel ? kind === "hotel" ? "bed" : "plane" : "compare", size: 19 })), /* @__PURE__ */ import_react2.default.createElement("div", { style: { flex: 1, minWidth: 0 } }, /* @__PURE__ */ import_react2.default.createElement("strong", null, kind === "hotel" ? "\u540C\u9152\u5E97\u3001\u540C\u65E5\u671F\u3001\u540C\u623F\u578B" : kind === "flight" ? "\u540C\u822A\u73ED\u3001\u540C\u65E5\u671F\u3001\u540C\u8231\u4F4D" : "\u5F53\u524D\u9875\u76F4\u63A5\u7B97\uFF0C\u5176\u4ED6\u5E73\u53F0\u5404\u8FDB\u4E00\u6B21"), /* @__PURE__ */ import_react2.default.createElement("small", null, isTravel ? "\u53EA\u770B\u9996\u5C4F\u4EF7\uFF0C\u4E0D\u6DF1\u6316\u8BE6\u60C5\uFF1B\u4E0D\u540C\u623F\u578B/\u822A\u73ED/\u8231\u4F4D\u4F1A\u5907\u6CE8\uFF0C\u4E0D\u53C2\u4E0E\u6700\u4F4E\u4EF7\u3002" : "\u4E0D\u91CD\u65B0\u641C\u7D22\u5F53\u524D\u5E73\u53F0\uFF0C\u4E0D\u70B9\u5206\u4EAB\u3001\u4E0D\u590D\u5236\u94FE\u63A5\uFF1B\u53EA\u8BFB\u4EF7\u683C\u548C\u5238\uFF0C\u4E0D\u4E0B\u5355\u3002")), /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-badge" }, "\u53EA\u8BFB")), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-start-channels" }, platformDefs.map(function(platform) {
        const isSource = platform.id === sourceId;
        const on = isSource || platformList.indexOf(platform.id) >= 0;
        return /* @__PURE__ */ import_react2.default.createElement(
          "button",
          {
            type: "button",
            key: platform.id,
            className: "pr-chip",
            "data-on": on ? "true" : "false",
            "data-source": isSource ? "true" : void 0,
            "aria-pressed": on,
            disabled: isSource,
            onClick: function() {
              toggleStartPlatform(platform.id);
            }
          },
          /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-chip-dot", style: { background: platform.color } }),
          platform.name,
          isSource ? /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-chip-source" }, "\u6765\u6E90") : on ? /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "check", size: 14 }) : null
        );
      }))),
      start.source ? /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-source-banner pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-source-banner-top" }, /* @__PURE__ */ import_react2.default.createElement(PlatformDot, { platform: start.source.platform }), /* @__PURE__ */ import_react2.default.createElement("div", null, /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u5DF2\u5728", platformLabel(start.source.platform), "\u5F53\u524D\u9875\u6838\u9A8C"), /* @__PURE__ */ import_react2.default.createElement("small", null, start.source.price != null ? formatPrice(start.source.price) : "\u4EF7\u683C\u5F85\u786E\u8BA4", start.source.store ? " \xB7 " + start.source.store : " \xB7 \u6E20\u9053\u7C7B\u578B\u4EE5\u9875\u9762\u4E3A\u51C6", start.source.at ? " \xB7 " + formatTime(start.source.at) : ""))), /* @__PURE__ */ import_react2.default.createElement(Field, { label: isTravel ? "\u6E20\u9053\u7C7B\u578B" : "\u6765\u6E90\u5E97\u94FA\u7C7B\u578B", hint: "\u5B98\u65D7 / \u81EA\u8425 / \u5B98\u65B9 / \u822A\u53F8\u624D\u7B97\u6B63\u89C4\u6E20\u9053", id: "start-source-store" }, /* @__PURE__ */ import_react2.default.createElement(
        "input",
        {
          id: "start-source-store",
          className: "wish-input",
          type: "text",
          value: start.source.store || "",
          placeholder: kind === "hotel" ? "\u9152\u5E97\u5B98\u65B9 / \u643A\u7A0B\u81EA\u8425 / \u7F8E\u56E2\u81EA\u8425" : kind === "flight" ? "\u822A\u53F8\u5B98\u65B9 / \u643A\u7A0B\u81EA\u8425 / \u53BB\u54EA\u513F\u81EA\u8425" : "\u5B98\u65B9\u65D7\u8230\u5E97 / \u767E\u4EBF\u8865\u8D34 / \u81EA\u8425 / \u54C1\u724C\u9ED1\u6807",
          autoComplete: "off",
          onChange: function(event) {
            setStartSourceField("store", event.target.value);
          }
        }
      )), /* @__PURE__ */ import_react2.default.createElement("label", { className: "pr-toggle-row" }, /* @__PURE__ */ import_react2.default.createElement("span", null, /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u8DF3\u8FC7", platformLabel(start.source.platform), "\u641C\u7D22"), /* @__PURE__ */ import_react2.default.createElement("small", null, "\u76F4\u63A5\u7528\u8FD9\u4E00\u9875\u505A\u6765\u6E90\uFF1B\u8FD9\u6B21\u53EA\u67E5\u5176\u4ED6\u5E73\u53F0\u3002\u53D6\u6D88\u52FE\u9009\u624D\u4F1A\u91CD\u65B0\u641C\u7D22\u5B83\u3002")), /* @__PURE__ */ import_react2.default.createElement(
        "input",
        {
          type: "checkbox",
          checked: start.skipSource,
          onChange: function(event) {
            setStartField("skipSource", event.target.checked);
          }
        }
      )), start.source.at && Date.now() - start.source.at > 30 * 6e4 ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-warnline" }, "\u8FD9\u4E2A\u6765\u6E90\u4EF7\u683C\u8BB0\u5F55\u4E8E ", formatTime(start.source.at), "\uFF0C\u53EF\u80FD\u5DF2\u7ECF\u53D8\u4E86\u3002\u9ED8\u8BA4\u4F1A\u91CD\u65B0\u641C\u7D22\u786E\u8BA4\uFF1B\u6025\u7684\u8BDD\u4E5F\u53EF\u4EE5\u624B\u52A8\u52FE\u9009\u8DF3\u8FC7\u3002") : null) : /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-note-card" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "float", size: 17 }), /* @__PURE__ */ import_react2.default.createElement("span", null, isTravel ? "\u5728\u9152\u5E97/\u673A\u7968\u8BE6\u60C5\u9875\u7528\u60AC\u6D6E\u5165\u53E3\u53D1\u8D77\u65F6\uFF0C\u5F53\u524D\u5E73\u53F0\u4F1A\u76F4\u63A5\u7528\u8FD9\u4E00\u9875\uFF0C\u4E0D\u518D\u91CD\u590D\u641C\u7D22\uFF1B\u540C\u9152\u5E97/\u540C\u822A\u73ED\u624D\u8FDB\u5165\u6BD4\u4EF7\u3002" : "\u4ECE\u5546\u54C1\u9875\u7528\u60AC\u6D6E\u5165\u53E3\u53D1\u8D77\u65F6\uFF0C\u5F53\u524D\u5E73\u53F0\u4F1A\u76F4\u63A5\u7528\u8FD9\u4E00\u9875\uFF0C\u4E0D\u518D\u91CD\u590D\u641C\u7D22\uFF1B\u4E0D\u590D\u5236\u94FE\u63A5\uFF0C\u4E5F\u4E0D\u70B9\u5206\u4EAB\u3002")),
      /* @__PURE__ */ import_react2.default.createElement("section", { className: "pr-form-card pr-glass" }, kind === "hotel" ? /* @__PURE__ */ import_react2.default.createElement(import_react2.default.Fragment, null, /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u9152\u5E97\u540D", hint: "\u5FC5\u586B", id: "start-hotel-name" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-hotel-name", className: "wish-input", type: "text", value: start.hotelName, placeholder: "\u4F8B\u5982 \u4E0A\u6D77\u5916\u6EE9\u67D0\u9152\u5E97", autoComplete: "off", onChange: function(event) {
        setStartField("hotelName", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u57CE\u5E02", hint: "\u9009\u586B", id: "start-city" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-city", className: "wish-input", type: "text", value: start.city, placeholder: "\u4F8B\u5982 \u4E0A\u6D77", autoComplete: "off", onChange: function(event) {
        setStartField("city", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-form-grid" }, /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u5165\u4F4F", hint: "\u5FC5\u586B", id: "start-checkin" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-checkin", className: "wish-input", type: "date", value: start.checkIn, onChange: function(event) {
        setStartField("checkIn", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u79BB\u5E97", hint: "\u5FC5\u586B", id: "start-checkout" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-checkout", className: "wish-input", type: "date", value: start.checkOut, onChange: function(event) {
        setStartField("checkOut", event.target.value);
      } }))), /* @__PURE__ */ import_react2.default.createElement(
        "button",
        {
          type: "button",
          className: "pr-link",
          onClick: function() {
            setStart({ ...start, checkIn: localDateStamp(0), checkOut: localDateStamp(1) });
          }
        },
        "\u4ECA\u5929 \u2192 \u660E\u5929\uFF08\u8DF3\u8FC7\u65E5\u671F\u9009\u62E9\u5668\uFF09"
      ), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u623F\u578B\u53E3\u5F84", hint: "\u9ED8\u8BA4\u6700\u4F4E\u4EF7\u65E5\u5386\u623F", id: "start-rate-mode" }, /* @__PURE__ */ import_react2.default.createElement("select", { id: "start-rate-mode", className: "wish-select", value: start.rateMode, onChange: function(event) {
        setStartField("rateMode", event.target.value);
      } }, /* @__PURE__ */ import_react2.default.createElement("option", { value: "lowest" }, "\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\uFF08\u9ED8\u8BA4\uFF09"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "specific" }, "\u6307\u5B9A\u623F\u578B"))), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u623F\u578B", hint: start.rateMode === "specific" ? "\u6307\u5B9A\u623F\u578B\u65F6\u5FC5\u586B" : "\u6700\u4F4E\u4EF7\u65E5\u5386\u623F\u53EF\u7559\u7A7A", id: "start-room" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-room", className: "wish-input", type: "text", value: start.roomType, placeholder: "\u623F\u578B / \u5E8A\u578B / \u65E9\u9910", autoComplete: "off", onChange: function(event) {
        setStartField("roomType", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u4EBA\u6570", hint: "\u5165\u4F4F\u4EBA\u6570", id: "start-guests" }, /* @__PURE__ */ import_react2.default.createElement("select", { id: "start-guests", className: "wish-select", value: start.guests, onChange: function(event) {
        setStartField("guests", event.target.value);
      } }, /* @__PURE__ */ import_react2.default.createElement("option", { value: "1 \u4EBA" }, "1 \u4EBA"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "2 \u4EBA" }, "2 \u4EBA"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "3 \u4EBA" }, "3 \u4EBA"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "4 \u4EBA" }, "4 \u4EBA")))) : kind === "flight" ? /* @__PURE__ */ import_react2.default.createElement(import_react2.default.Fragment, null, /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u822A\u73ED\u53F7", hint: "\u5FC5\u586B", id: "start-flight-no" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-flight-no", className: "wish-input", type: "text", value: start.flightNo, placeholder: "\u4F8B\u5982 MU1234", autoComplete: "off", onChange: function(event) {
        setStartField("flightNo", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u822A\u53F8", hint: "\u9009\u586B", id: "start-airline" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-airline", className: "wish-input", type: "text", value: start.airline, placeholder: "\u4F8B\u5982 \u4E1C\u65B9\u822A\u7A7A", autoComplete: "off", onChange: function(event) {
        setStartField("airline", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u51FA\u53D1\u65E5\u671F", hint: "\u5FC5\u586B", id: "start-flight-date" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-flight-date", className: "wish-input", type: "date", value: start.date, onChange: function(event) {
        setStartField("date", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-form-grid" }, /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u51FA\u53D1\u673A\u573A", hint: "\u9009\u586B", id: "start-from" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-from", className: "wish-input", type: "text", value: start.from, placeholder: "\u4F8B\u5982 \u8679\u6865 T2", autoComplete: "off", onChange: function(event) {
        setStartField("from", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u5230\u8FBE\u673A\u573A", hint: "\u9009\u586B", id: "start-to" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-to", className: "wish-input", type: "text", value: start.to, placeholder: "\u4F8B\u5982 \u9996\u90FD T3", autoComplete: "off", onChange: function(event) {
        setStartField("to", event.target.value);
      } }))), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u8231\u4F4D", hint: "\u9ED8\u8BA4\u7ECF\u6D4E\u8231", id: "start-cabin" }, /* @__PURE__ */ import_react2.default.createElement("select", { id: "start-cabin", className: "wish-select", value: start.cabin, onChange: function(event) {
        setStartField("cabin", event.target.value);
      } }, /* @__PURE__ */ import_react2.default.createElement("option", { value: "\u7ECF\u6D4E\u8231" }, "\u7ECF\u6D4E\u8231"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "\u8D85\u7EA7\u7ECF\u6D4E\u8231" }, "\u8D85\u7EA7\u7ECF\u6D4E\u8231"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "\u516C\u52A1\u8231" }, "\u516C\u52A1\u8231"), /* @__PURE__ */ import_react2.default.createElement("option", { value: "\u5934\u7B49\u8231" }, "\u5934\u7B49\u8231")))) : /* @__PURE__ */ import_react2.default.createElement(import_react2.default.Fragment, null, /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u5546\u54C1\u540D", hint: "\u5FC5\u586B", id: "start-title" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-title", className: "wish-input", type: "text", value: start.title, placeholder: "\u8981\u6BD4\u8F83\u7684\u5546\u54C1", autoComplete: "off", onChange: function(event) {
        setStartField("title", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u89C4\u683C", hint: "\u5FC5\u987B\u540C\u6B3E\u540C\u89C4\u683C", id: "start-spec" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-spec", className: "wish-input", type: "text", value: start.spec, placeholder: "\u578B\u53F7 / \u5BB9\u91CF / \u989C\u8272 / \u6570\u91CF", autoComplete: "off", onChange: function(event) {
        setStartField("spec", event.target.value);
      } })), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u94FE\u63A5\uFF08\u9009\u586B\uFF09", hint: "\u4E0D\u7528\u7279\u610F\u590D\u5236\uFF0C\u80FD\u8BFB\u5230\u518D\u586B", id: "start-url" }, /* @__PURE__ */ import_react2.default.createElement("input", { id: "start-url", className: "wish-input", type: "url", value: start.url, placeholder: "https://\u2026", autoComplete: "off", onChange: function(event) {
        setStartField("url", event.target.value);
      } }))), /* @__PURE__ */ import_react2.default.createElement(Field, { label: "\u8865\u5145\u8981\u6C42", hint: "\u9009\u586B", id: "start-note" }, /* @__PURE__ */ import_react2.default.createElement(
        "textarea",
        {
          id: "start-note",
          className: "wish-input pr-textarea",
          rows: 3,
          value: start.note,
          placeholder: kind === "hotel" ? "\u4F8B\u5982\uFF1A\u53EA\u770B\u542B\u65E9\u3001\u514D\u8D39\u53D6\u6D88\uFF1B\u4F1A\u5458\u4EF7\u9700\u767B\u5F55" : kind === "flight" ? "\u4F8B\u5982\uFF1A\u53EA\u770B\u76F4\u98DE\u3001\u542B 20kg \u6258\u8FD0" : "\u4F8B\u5982\uFF1A\u53EA\u770B\u5B98\u65B9\u65D7\u8230\u5E97\u548C\u767E\u4EBF\u8865\u8D34",
          onChange: function(event) {
            setStartField("note", event.target.value);
          }
        }
      )), /* @__PURE__ */ import_react2.default.createElement("label", { className: "pr-toggle-row" }, /* @__PURE__ */ import_react2.default.createElement("span", null, /* @__PURE__ */ import_react2.default.createElement("strong", null, isTravel ? "\u68C0\u67E5\u4F1A\u5458\u4EF7/\u7A0E\u8D39/\u5238" : "\u68C0\u67E5\u9886\u5238\u4E0E\u6EE1\u51CF"), /* @__PURE__ */ import_react2.default.createElement("small", null, isTravel ? "\u53EA\u770B\u9875\u9762\u660E\u786E\u663E\u793A\u4E14\u53EF\u7528\uFF1B\u4E0D\u6DF1\u6316\u5238\u4E2D\u5FC3" : "\u53EA\u5728\u9700\u8981\u65F6\u67E5\u4E00\u6B21\uFF1A\u6DD8\u5B9D\u6211\u7684\u5238\u3001\u62FC\u591A\u591A\u767E\u8865\u4F1A\u5458\u5165\u53E3\u3001\u6296\u97F3\u5546\u57CE\u9886\u5238\u9875\u3001\u4EAC\u4E1C\u9886\u5238\u533A")), /* @__PURE__ */ import_react2.default.createElement(
        "input",
        {
          type: "checkbox",
          checked: start.autoCoupon,
          onChange: function(event) {
            setStartField("autoCoupon", event.target.checked);
          }
        }
      )), /* @__PURE__ */ import_react2.default.createElement("details", { className: "pr-details" }, /* @__PURE__ */ import_react2.default.createElement("summary", null, "\u672C\u6B21\u4F1A\u9075\u5B88\u7684", isTravel ? "\u6B63\u89C4" : "\u6B63\u54C1", "\u6E20\u9053"), /* @__PURE__ */ import_react2.default.createElement("ul", { className: "pr-whitelist" }, platformDefs.map(function(platform) {
        return /* @__PURE__ */ import_react2.default.createElement("li", { key: platform.id }, /* @__PURE__ */ import_react2.default.createElement("strong", null, platform.name), platform.channels.join(" / "));
      }))), startError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, startError) : null, /* @__PURE__ */ import_react2.default.createElement("button", { type: "submit", className: "wish-button pr-submit" }, phoneGranted ? start.source && start.skipSource ? "\u5F00\u59CB\u6BD4\u4EF7\uFF08\u53EA\u67E5\u5176\u4ED6\u5E73\u53F0\uFF09" : "\u5F00\u59CB\u771F\u5B9E\u6BD4\u4EF7" : "\u5148\u5F00\u542F\u624B\u673A\u64CD\u63A7"), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, phoneGranted ? "\u6574\u573A\u6BD4\u4EF7\u53EA\u542F\u52A8\u4E00\u4E2A\u4EFB\u52A1\uFF0C\u4E00\u6B21\u6388\u6743\u8986\u76D6\u6240\u6709\u5E73\u53F0\uFF0C\u4E0D\u4F1A\u4E3A\u6BCF\u4E2A App \u91CD\u65B0\u7533\u8BF7\u3002\u4EFB\u52A1\u5728\u540E\u53F0\u7EE7\u7EED\uFF0C\u9047\u5230\u767B\u5F55\u3001\u9A8C\u8BC1\u7801\u6216\u652F\u4ED8\u4F1A\u505C\u4E0B\u7B49\u4F60\u3002" : "\u624B\u673A\u64CD\u63A7\u8FD8\u6CA1\u6388\u6743\u7ED9\u672C\u4F5C\u54C1\u3002\u70B9\u6309\u94AE\u4F1A\u6253\u5F00\u80FD\u529B\u4E2D\u5FC3\uFF0C\u6388\u6743\u4E00\u6B21\u5373\u53EF\u8986\u76D6\u6574\u573A\u6BD4\u4EF7\uFF0C\u4E4B\u540E\u4E0D\u7528\u6BCF\u4E2A App \u518D\u6388\u6743\u3002")),
      run ? renderRun() : null
    );
  }
  function renderBoot() {
    return /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-boot" }, /* @__PURE__ */ import_react2.default.createElement(Radar, null), /* @__PURE__ */ import_react2.default.createElement("strong", { role: "status" }, "\u6B63\u5728\u8FDE\u63A5\u624B\u673A\u80FD\u529B"), /* @__PURE__ */ import_react2.default.createElement("p", null, "\u8BFB\u53D6\u672C\u5730\u8BB0\u5F55\u3001\u63D0\u9192\u4E0E\u6A21\u578B\u72B6\u6001\u2026"), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-skel-card pr-glass" }, /* @__PURE__ */ import_react2.default.createElement(SkeletonLine, { width: "46%", height: 14 }), /* @__PURE__ */ import_react2.default.createElement(SkeletonLine, { width: "78%" }), /* @__PURE__ */ import_react2.default.createElement(SkeletonLine, { width: "62%" })), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-skel-card pr-glass" }, /* @__PURE__ */ import_react2.default.createElement(SkeletonLine, { width: "38%", height: 14 }), /* @__PURE__ */ import_react2.default.createElement(SkeletonLine, { width: "70%" })));
  }
  function renderUnsupported() {
    return /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-unsupported pr-glass" }, /* @__PURE__ */ import_react2.default.createElement("span", { className: "pr-empty-icon" }, /* @__PURE__ */ import_react2.default.createElement(Icon, { name: "phone", size: 26 })), /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u8BF7\u5728 DSH \u624B\u673A App \u91CC\u6253\u5F00"), /* @__PURE__ */ import_react2.default.createElement("p", null, "\u5F53\u524D\u9875\u9762\u6CA1\u6709\u68C0\u6D4B\u5230\u624B\u673A\u6865\u3002\u4F5C\u54C1\u5B89\u88C5\u540E\uFF0C\u4ECE\u7CFB\u7EDF\u201C\u6253\u5F00\u4F5C\u54C1\u201D\u8FDB\u5165\uFF1B\u7F51\u9875\u9884\u89C8\u4E0D\u4F1A\u4F2A\u9020\u624B\u673A\u7ED3\u679C\u3002"), /* @__PURE__ */ import_react2.default.createElement(
      "button",
      {
        type: "button",
        className: "wish-button",
        onClick: function() {
          bootedRef.current = false;
          setBoot("waiting");
          if (typeof window !== "undefined" && window.dshWish && connectRef.current) connectRef.current();
          else setTimeout(function() {
            if (!window.dshWish) setBoot("unsupported");
          }, 2500);
        }
      },
      "\u91CD\u65B0\u68C0\u6D4B"
    ));
  }
  function renderSheet() {
    if (!sheet) return null;
    if (sheet.type === "caps") {
      return /* @__PURE__ */ import_react2.default.createElement(Sheet, { title: "\u80FD\u529B\u4E0E\u6388\u6743", subtitle: sheet.reason || "\u53EA\u663E\u793A\u771F\u5B9E\u72B6\u6001\uFF1B\u5DF2\u5F00\u542F\u7684\u4E0D\u4F1A\u91CD\u590D\u7D22\u53D6\u3002", onClose: function() {
        setSheet(null);
      } }, capsError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, capsError) : null, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-cap-list" }, /* @__PURE__ */ import_react2.default.createElement(
        CapRow,
        {
          label: "\u624B\u673A\u64CD\u63A7",
          ok: phoneGranted,
          text: phoneGranted ? a11y === false ? "\u4F5C\u54C1\u5DF2\u6388\u6743\uFF0C\u4F46\u5171\u4EAB\u65E0\u969C\u788D\u670D\u52A1\u672A\u8FDE\u63A5\uFF0C\u8BF7\u5230\u80FD\u529B\u4E2D\u5FC3\u6253\u5F00\u3002" : "\u5DF2\u6388\u6743\uFF0C\u53EF\u542F\u52A8\u771F\u5B9E\u8BFB\u5C4F\u4E0E\u70B9\u51FB\u4EFB\u52A1\u3002" : "\u5728\u80FD\u529B\u4E2D\u5FC3\u4E3A\u672C\u4F5C\u54C1\u6388\u6743\uFF1B\u7CFB\u7EDF\u5171\u4EAB\u4E00\u4E2A\u65E0\u969C\u788D\u670D\u52A1\u3002"
        }
      ), /* @__PURE__ */ import_react2.default.createElement(
        CapRow,
        {
          label: "\u60AC\u6D6E\u7A97\u6743\u9650",
          ok: overlay,
          text: overlay === true ? "\u5141\u8BB8\u663E\u793A\u5728\u5176\u4ED6\u5E94\u7528\u4E0A\u5C42\uFF0C\u60AC\u6D6E\u5165\u53E3\u53EF\u7528\u3002" : overlay === false ? "\u7CFB\u7EDF\u672A\u5141\u8BB8 DSH \u663E\u793A\u5728\u5176\u4ED6\u5E94\u7528\u4E0A\u5C42\uFF1B\u60AC\u6D6E\u5165\u53E3\u65E0\u6CD5\u5F00\u542F\uFF0C\u9996\u9875\u4F1A\u62A5\u9519\u3002\u8BF7\u5230\u7CFB\u7EDF\u8BBE\u7F6E\u6388\u6743\u3002" : "\u5F53\u524D\u6CA1\u6709\u8FD4\u56DE\u60AC\u6D6E\u7A97\u6743\u9650\u72B6\u6001\u3002"
        }
      ), /* @__PURE__ */ import_react2.default.createElement(
        CapRow,
        {
          label: "\u5171\u4EAB\u65E0\u969C\u788D\u670D\u52A1",
          ok: a11y,
          text: a11y === true ? "serviceConnected=true\uFF0C\u8BFB\u5C4F/\u70B9\u51FB\u53EF\u7528\u3002" : a11y === false ? "serviceConnected=false\u3002\u5373\u4F7F\u7CFB\u7EDF\u8BBE\u7F6E\u91CC\u5F00\u5173\u662F\u5F00\u7740\u7684\uFF0CDSH \u4E5F\u6CA1\u6709\u8FDE\u4E0A\u670D\u52A1\uFF1A\u8BF7\u5173\u95ED\u518D\u5F00\u542F DSH \u65E0\u969C\u788D\uFF0C\u6216\u91CD\u542F DSH \u540E\u70B9\u201C\u5237\u65B0\u72B6\u6001\u201D\u3002" : "\u5F53\u524D\u6CA1\u6709\u8FD4\u56DE\u65E0\u969C\u788D\u670D\u52A1\u72B6\u6001\uFF0C\u5148\u70B9\u201C\u5237\u65B0\u72B6\u6001\u201D\u3002"
        }
      ), /* @__PURE__ */ import_react2.default.createElement(
        CapRow,
        {
          label: "\u624B\u673A\u6865",
          ok: phoneBridgeState(caps),
          text: phoneBridgeState(caps) === true ? "bridgeListening=true\uFF0C\u624B\u673A\u5DE5\u5177\u5DF2\u6302\u8F7D\u3002" : phoneBridgeState(caps) === false ? "bridgeListening=false\uFF0C\u624B\u673A\u5DE5\u5177\u5F53\u524D\u6CA1\u6709\u76D1\u542C\u3002" : "\u6CA1\u6709\u8FD4\u56DE\u624B\u673A\u6865\u72B6\u6001\u3002"
        }
      ), /* @__PURE__ */ import_react2.default.createElement(CapRow, { label: "\u540E\u53F0\u63D0\u9192", ok: remindersGranted, text: remindersGranted ? "\u53EF\u4EE5\u5B89\u6392\u7CFB\u7EDF\u7EA7\u63D0\u9192\u3002" : "\u9700\u8981\u4F5C\u54C1\u7EA7\u6388\u6743\u540E\u624D\u80FD\u5B89\u6392\u63D0\u9192\u3002" }), /* @__PURE__ */ import_react2.default.createElement(CapRow, { label: "\u7CFB\u7EDF\u901A\u77E5", ok: systemNotifications, text: systemNotifications ? "\u901A\u77E5\u6743\u9650\u5DF2\u5F00\u542F\uFF0C\u63D0\u9192\u53EF\u89C1\u3002" : "\u672A\u5F00\u542F\uFF0C\u63D0\u9192\u53EF\u80FD\u4E0D\u53EF\u89C1\u3002" }), /* @__PURE__ */ import_react2.default.createElement(CapRow, { label: "\u7CBE\u786E\u95F9\u949F", ok: capOn(caps, "exact"), text: capOn(caps, "exact") ? "\u53EF\u4EE5\u6309\u51C6\u786E\u65F6\u95F4\u89E6\u53D1\u63D0\u9192\u3002" : "\u53EF\u80FD\u53EA\u80FD\u5B89\u6392\u4E0D\u7CBE\u786E\u63D0\u9192\u3002" }), /* @__PURE__ */ import_react2.default.createElement(CapRow, { label: "\u5DF2\u767B\u5F55\u6A21\u578B", ok: aiReady, text: aiReady ? "\u53EF\u76F4\u63A5\u8C03\u7528\u5F53\u524D\u767B\u5F55\u8D26\u53F7\u7684\u6A21\u578B\uFF0C\u4E0D\u9700\u8981\u586B Key\u3002" : "\u5F53\u524D\u4E0D\u53EF\u7528\uFF0C\u8BF7\u68C0\u67E5\u6A21\u578B\u767B\u5F55\u3002" }), /* @__PURE__ */ import_react2.default.createElement(CapRow, { label: "\u6587\u4EF6\u5BFC\u51FA", ok: capOn(caps, "files"), text: capOn(caps, "files") ? "\u53EF\u4EE5\u901A\u8FC7\u7CFB\u7EDF\u4FDD\u5B58\u6BD4\u4EF7\u8BB0\u5F55\u3002" : "\u5BFC\u51FA\u53EF\u80FD\u4E0D\u53EF\u7528\u3002" })), overlay === false ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-warnline" }, "\u7CFB\u7EDF\u60AC\u6D6E\u7A97\u6743\u9650\u672A\u5F00\u542F\uFF0C\u60AC\u6D6E\u5165\u53E3\u65E0\u6CD5\u542F\u7528\uFF1B\u8BF7\u70B9\u201C\u6253\u5F00\u80FD\u529B\u4E2D\u5FC3\u201D\u6388\u6743\uFF0C\u6216\u5230\u7CFB\u7EDF\u8BBE\u7F6E\u5141\u8BB8 DSH \u663E\u793A\u5728\u5176\u4ED6\u5E94\u7528\u4E0A\u5C42\u3002") : null, /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-btn-row" }, /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button", onClick: openCapabilityCenter }, "\u6253\u5F00\u80FD\u529B\u4E2D\u5FC3"), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button secondary", onClick: function() {
        void refreshCaps();
      } }, "\u5237\u65B0\u72B6\u6001")), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, "\u4F5C\u54C1\u4E0D\u8BFB\u53D6\u3001\u4F20\u9012\u6216\u4FDD\u5B58\u767B\u5F55\u51ED\u636E\uFF1B\u624B\u673A\u64CD\u63A7\u7531\u7CFB\u7EDF\u5171\u4EAB\u7684\u65E0\u969C\u788D\u670D\u52A1\u6267\u884C\u3002"));
    }
    if (sheet.type === "floating") {
      return /* @__PURE__ */ import_react2.default.createElement(Sheet, { title: "\u6743\u9650\u4E0E\u52A8\u4F5C", subtitle: sheet.reason || "\u60AC\u6D6E\u5165\u53E3\u3001\u7CFB\u7EDF\u6743\u9650\u548C\u684C\u9762\u52A8\u4F5C\u7EDF\u4E00\u5728\u8FD9\u91CC\u7BA1\u7406\u3002", onClose: function() {
        setSheet(null);
      } }, /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note" }, "\u8BF7\u70B9\u53F3\u4E0A\u89D2 ", /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u22EF"), " \u2192 ", /* @__PURE__ */ import_react2.default.createElement("strong", null, "\u6743\u9650\u4E0E\u52A8\u4F5C"), "\uFF0C\u7BA1\u7406\u60AC\u6D6E\u5165\u53E3\u3001\u60AC\u6D6E\u7A97\u6743\u9650\u548C\u65E0\u969C\u788D\u670D\u52A1\u3002"), /* @__PURE__ */ import_react2.default.createElement("p", { className: "pr-note-sm" }, "\u5982\u679C\u9875\u9762\u6CA1\u6709\u81EA\u52A8\u6253\u5F00\uFF0C\u8BF7\u6309\u4E0A\u9762\u7684\u5165\u53E3\u624B\u52A8\u8FDB\u5165\uFF1B\u60AC\u6D6E\u6BD4\u4EF7\u8FD8\u9700\u8981\u65E0\u969C\u788D\u670D\u52A1\u5DF2\u8FDE\u63A5\u3002"), /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-btn-row" }, /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button", onClick: function() {
        void openCapabilityCenter();
      } }, "\u6253\u5F00\u80FD\u529B\u4E2D\u5FC3"), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button secondary", onClick: function() {
        void refreshCaps();
      } }, "\u5237\u65B0\u72B6\u6001")));
    }
    if (sheet.type === "confirm") {
      return /* @__PURE__ */ import_react2.default.createElement(
        Sheet,
        {
          title: sheet.title,
          subtitle: sheet.body,
          label: sheet.title,
          onClose: confirmBusy ? void 0 : function() {
            setSheet(null);
          }
        },
        confirmError ? /* @__PURE__ */ import_react2.default.createElement("p", { className: "wish-error", role: "alert" }, confirmError) : null,
        /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-btn-row" }, /* @__PURE__ */ import_react2.default.createElement(
          "button",
          {
            type: "button",
            className: "wish-button",
            "data-variant": sheet.danger ? "danger" : void 0,
            disabled: confirmBusy,
            onClick: runConfirm
          },
          confirmBusy ? "\u5904\u7406\u4E2D\u2026" : sheet.confirmLabel || "\u786E\u8BA4"
        ), /* @__PURE__ */ import_react2.default.createElement("button", { type: "button", className: "wish-button secondary", disabled: confirmBusy, onClick: function() {
          setSheet(null);
        } }, "\u53D6\u6D88"))
      );
    }
    return null;
  }
  function renderTabs() {
    if (["home", "records", "memory", "settings"].indexOf(page) < 0) return null;
    const tabs = [
      { id: "home", label: "\u6BD4\u4EF7", icon: "compare" },
      { id: "records", label: "\u8BB0\u5F55", icon: "record" },
      { id: "memory", label: "\u6BD4\u4EF7\u65B9\u6CD5", icon: "memory" },
      { id: "settings", label: "\u8BBE\u7F6E", icon: "settings" }
    ];
    return /* @__PURE__ */ import_react2.default.createElement("nav", { className: "wish-tabs pr-tabs", "aria-label": "\u4F5C\u54C1\u5BFC\u822A" }, tabs.map(function(tab) {
      const current = page === tab.id;
      return /* @__PURE__ */ import_react2.default.createElement(
        "button",
        {
          type: "button",
          key: tab.id,
          className: "pr-tab",
          "aria-current": current ? "page" : void 0,
          onClick: function() {
            setPage(tab.id);
            setRecordId("");
            setGlobalError("");
          }
        },
        /* @__PURE__ */ import_react2.default.createElement(Icon, { name: tab.icon, size: 21 }),
        /* @__PURE__ */ import_react2.default.createElement("span", null, tab.label)
      );
    }));
  }
  let content = null;
  if (boot !== "ready") content = boot === "unsupported" ? renderUnsupported() : renderBoot();
  else if (page === "home") content = renderHome();
  else if (page === "records") content = renderRecords();
  else if (page === "memory") content = renderMemory();
  else if (page === "settings") content = renderSettings();
  else if (page === "quick") content = renderQuick();
  else if (page === "start") content = renderStart();
  else if (page === "record") content = renderRecordPage();
  return /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-app wish-app wish-scaffold", "data-active": active ? "true" : "false" }, /* @__PURE__ */ import_react2.default.createElement("style", null, style_default), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-page" }, renderHeader(), /* @__PURE__ */ import_react2.default.createElement("div", { className: "wish-content pr-content" }, content), renderTabs()), renderSheet(), toast ? /* @__PURE__ */ import_react2.default.createElement("div", { className: "pr-toast", role: "status", "aria-live": "polite" }, toast.text) : null);
}

// src/entry.jsx
function getWish() {
  if (typeof window === "undefined") return null;
  try {
    const value = window.dshWish;
    return value && typeof value === "object" ? value : null;
  } catch (error) {
    return null;
  }
}
function PanelIcon() {
  return import_react3.default.createElement(
    "svg",
    {
      width: 22,
      height: 22,
      viewBox: "0 0 24 24",
      fill: "none",
      "aria-hidden": true,
      style: { display: "block" }
    },
    import_react3.default.createElement("circle", { cx: 12, cy: 12, r: 8.4, stroke: "currentColor", strokeWidth: 1.7, opacity: 0.9 }),
    import_react3.default.createElement("circle", { cx: 12, cy: 12, r: 4.6, stroke: "currentColor", strokeWidth: 1.5, opacity: 0.55 }),
    import_react3.default.createElement("path", { d: "M12 12l5.6-5.6", stroke: "#68c39e", strokeWidth: 2, strokeLinecap: "round" }),
    import_react3.default.createElement("circle", { cx: 12, cy: 12, r: 1.9, fill: "#4d6bfe" })
  );
}
var plugin = {
  inject: ["slots", "layout"],
  apply(ctx) {
    ctx.effect(
      function() {
        let disposePanel = null;
        let described = false;
        let actionsRegistered = false;
        const registerPanel = function() {
          const wish = getWish();
          if (!wish || typeof wish.registerPanel !== "function" || disposePanel) return;
          try {
            disposePanel = wish.registerPanel(PANEL_ID, function() {
              try {
                ctx.layout.selectPanel(PANEL_ID);
              } catch (error) {
                console.error("[price-radar] panel navigation failed", error);
              }
            });
          } catch (error) {
            console.error("[price-radar] host panel registration failed", error);
          }
        };
        const describeWork = function() {
          const wish = getWish();
          if (described || !wish || !wish.work || typeof wish.work.describe !== "function") return;
          described = true;
          try {
            const result = wish.work.describe({
              title: TITLE,
              description: "\u5546\u54C1\u3001\u9152\u5E97\u3001\u673A\u7968\u90FD\u6BD4\u4EF7\uFF1A\u6DD8\u5B9D/\u62FC\u591A\u591A/\u6296\u97F3/\u4EAC\u4E1C\u4E0E\u643A\u7A0B/\u7F8E\u56E2/\u53BB\u54EA\u513F\uFF1B\u5F53\u524D\u9875\u76F4\u63A5\u7B97\uFF0C\u4E0D\u91CD\u590D\u641C\u7D22\u3001\u4E0D\u590D\u5236\u94FE\u63A5\uFF0C\u8BB0\u5F55\u5404\u5E73\u53F0\u4EF7\u683C\u4E0E\u6838\u9A8C\u65F6\u95F4\u3002",
              actions: []
            });
            if (result && typeof result.catch === "function") result.catch(function() {
            });
          } catch (error) {
            described = false;
          }
        };
        const registerActions = function() {
          const wish = getWish();
          if (actionsRegistered || !wish || !wish.actions || typeof wish.actions.register !== "function") return;
          actionsRegistered = true;
          try {
            const result = wish.actions.register(buildActions(defaultMemory(), defaultSettings()));
            if (result && typeof result.catch === "function") {
              result.catch(function() {
                actionsRegistered = false;
              });
            }
          } catch (error) {
            actionsRegistered = false;
            console.warn("[price-radar] action registration failed", error);
          }
        };
        const bind = function() {
          registerPanel();
          describeWork();
          registerActions();
        };
        bind();
        window.addEventListener("dsh-wish-ready", bind);
        return function() {
          window.removeEventListener("dsh-wish-ready", bind);
          if (disposePanel) {
            try {
              disposePanel();
            } catch (error) {
              console.error("[price-radar] panel unregistration failed", error);
            }
            disposePanel = null;
          }
        };
      },
      "price-radar: host panel, title and floating actions"
    );
    ctx.slots.inject("main", function() {
      return ctx.slots.register({ name: "main", key: PANEL_ID }, App);
    });
    ctx.slots.inject("sidebar.panellist", function() {
      return ctx.slots.register(
        {
          name: "sidebar.panellist",
          id: PANEL_ID,
          order: 16,
          label: function() {
            return TITLE;
          }
        },
        PanelIcon
      );
    });
  }
};
var entry_default = plugin;

    return module.exports.default;
  },
});
