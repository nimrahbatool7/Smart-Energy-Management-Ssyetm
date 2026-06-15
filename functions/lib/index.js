"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateInsights = exports.budgetMonitor = exports.dailyAggregation = exports.onApplianceWrite = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 1: Calculate usage when appliance is added or updated
// ─────────────────────────────────────────────────────────────────────────────
exports.onApplianceWrite = functions.firestore
    .document("users/{userId}/appliances/{applianceId}")
    .onWrite(async (change, context) => {
    var _a, _b, _c, _d;
    const { userId, applianceId } = context.params;
    // If deleted, skip
    if (!change.after.exists)
        return null;
    const data = change.after.data();
    const wattage = (_a = data.wattage) !== null && _a !== void 0 ? _a : 0;
    const hours = (_b = data.dailyUsageHours) !== null && _b !== void 0 ? _b : 0;
    const quantity = (_c = data.quantity) !== null && _c !== void 0 ? _c : 1;
    // Get unit price from home settings
    const homeDoc = await db.doc(`users/${userId}`).get();
    const unitPrice = homeDoc.exists ? ((_d = homeDoc.data().unitPrice) !== null && _d !== void 0 ? _d : 15) : 15;
    // Daily kWh per appliance
    const dailyKwh = (wattage * hours * quantity) / 1000;
    const dailyCost = dailyKwh * unitPrice;
    const monthlyKwh = dailyKwh * 30;
    const monthlyCost = dailyCost * 30;
    // Log usage entry
    await db.collection(`users/${userId}/usageLogs`).add({
        applianceId,
        applianceName: data.name,
        date: admin.firestore.FieldValue.serverTimestamp(),
        dailyKwh,
        dailyCost,
        monthlyKwh,
        monthlyCost,
    });
    // Update the appliance with computed fields
    await change.after.ref.update({
        computedDailyKwh: dailyKwh,
        computedMonthlyCost: monthlyCost,
        status: hours > 8 ? "High Usage" : "Normal",
    });
    // Check for high usage
    if (hours > 8) {
        await _createAlert(userId, {
            type: "appliance",
            message: `${data.name} is running for ${hours}h/day. Consider reducing usage to save energy.`,
            severity: "high",
        });
    }
    return null;
});
// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 2: Daily Aggregation — runs every midnight PKT (UTC+5)
// ─────────────────────────────────────────────────────────────────────────────
exports.dailyAggregation = functions.pubsub
    .schedule("0 19 * * *") // 19:00 UTC = midnight PKT
    .timeZone("UTC")
    .onRun(async () => {
    var _a, _b, _c, _d, _e, _f, _g;
    const usersSnap = await db.collection("users").get();
    for (const userDoc of usersSnap.docs) {
        const uid = userDoc.id;
        const logsSnap = await db
            .collection(`users/${uid}/usageLogs`)
            .orderBy("date", "desc")
            .limit(50)
            .get();
        let totalKwh = 0;
        let totalCost = 0;
        const applianceCounts = {};
        for (const log of logsSnap.docs) {
            const d = log.data();
            totalKwh += (_a = d.dailyKwh) !== null && _a !== void 0 ? _a : 0;
            totalCost += (_b = d.dailyCost) !== null && _b !== void 0 ? _b : 0;
            const name = (_c = d.applianceName) !== null && _c !== void 0 ? _c : "Unknown";
            applianceCounts[name] = ((_d = applianceCounts[name]) !== null && _d !== void 0 ? _d : 0) + ((_e = d.dailyKwh) !== null && _e !== void 0 ? _e : 0);
        }
        const topAppliance = (_g = (_f = Object.entries(applianceCounts).sort((a, b) => b[1] - a[1])[0]) === null || _f === void 0 ? void 0 : _f[0]) !== null && _g !== void 0 ? _g : "";
        const today = new Date().toISOString().split("T")[0];
        await db.doc(`users/${uid}/dailySummary/${today}`).set({
            totalKwh,
            totalCost,
            topAppliance,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 3: Budget Monitor — triggered on usage log write
// ─────────────────────────────────────────────────────────────────────────────
exports.budgetMonitor = functions.firestore
    .document("users/{userId}/usageLogs/{logId}")
    .onCreate(async (snap, context) => {
    var _a, _b;
    const { userId } = context.params;
    const homeDoc = await db.doc(`users/${userId}`).get();
    if (!homeDoc.exists)
        return null;
    const budget = (_a = homeDoc.data().monthlyBudget) !== null && _a !== void 0 ? _a : 0;
    if (budget <= 0)
        return null;
    // Sum all costs this month
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const logsSnap = await db
        .collection(`users/${userId}/usageLogs`)
        .where("date", ">=", admin.firestore.Timestamp.fromDate(startOfMonth))
        .get();
    let totalCost = 0;
    for (const d of logsSnap.docs) {
        totalCost += (_b = d.data().dailyCost) !== null && _b !== void 0 ? _b : 0;
    }
    const projectedMonthly = totalCost * (30 / now.getDate());
    if (projectedMonthly > budget) {
        await _createAlert(userId, {
            type: "budget",
            message: `Projected monthly bill (Rs ${projectedMonthly.toFixed(0)}) exceeds your budget (Rs ${budget}). Consider reducing usage.`,
            severity: "high",
        });
    }
    else if (projectedMonthly > budget * 0.8) {
        await _createAlert(userId, {
            type: "budget",
            message: `You've used 80% of your monthly budget. Projected bill: Rs ${projectedMonthly.toFixed(0)}.`,
            severity: "medium",
        });
    }
    return null;
});
// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 4: AI Insight Generator — runs daily
// ─────────────────────────────────────────────────────────────────────────────
exports.generateInsights = functions.pubsub
    .schedule("0 20 * * *") // 20:00 UTC = 1:00 AM PKT
    .timeZone("UTC")
    .onRun(async () => {
    var _a, _b;
    const usersSnap = await db.collection("users").get();
    for (const userDoc of usersSnap.docs) {
        const uid = userDoc.id;
        const appliancesSnap = await db.collection(`users/${uid}/appliances`).get();
        let totalKwh = 0;
        const applianceKwh = {};
        for (const app of appliancesSnap.docs) {
            const d = app.data();
            const kwh = (_a = d.computedDailyKwh) !== null && _a !== void 0 ? _a : 0;
            totalKwh += kwh;
            applianceKwh[(_b = d.name) !== null && _b !== void 0 ? _b : "Unknown"] = kwh;
        }
        for (const [name, kwh] of Object.entries(applianceKwh)) {
            if (totalKwh > 0 && kwh / totalKwh > 0.4) {
                await db.collection(`users/${uid}/insights`).add({
                    type: "optimization",
                    message: `${name} consumes ${((kwh / totalKwh) * 100).toFixed(0)}% of your total energy. Consider reducing its usage by 1 hour to save significantly.`,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                });
            }
        }
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Helper: Create Alert
// ─────────────────────────────────────────────────────────────────────────────
async function _createAlert(uid, alert) {
    await db.collection(`users/${uid}/alerts`).add(Object.assign(Object.assign({}, alert), { read: false, createdAt: admin.firestore.FieldValue.serverTimestamp() }));
}
//# sourceMappingURL=index.js.map