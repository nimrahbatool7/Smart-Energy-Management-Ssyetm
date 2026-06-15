import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 1: Calculate usage when appliance is added or updated
// ─────────────────────────────────────────────────────────────────────────────
export const onApplianceWrite = functions.firestore
  .document("users/{userId}/appliances/{applianceId}")
  .onWrite(async (change: functions.Change<functions.firestore.DocumentSnapshot>, context: functions.EventContext) => {
    const { userId, applianceId } = context.params;

    // If deleted, skip
    if (!change.after.exists) return null;

    const data = change.after.data()!;
    const wattage: number = data.wattage ?? 0;
    const hours: number = data.dailyUsageHours ?? 0;
    const quantity: number = data.quantity ?? 1;

    // Get unit price from home settings
    const homeDoc = await db.doc(`users/${userId}`).get();
    const unitPrice: number = homeDoc.exists ? (homeDoc.data()!.unitPrice ?? 15) : 15;

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
export const dailyAggregation = functions.pubsub
  .schedule("0 19 * * *") // 19:00 UTC = midnight PKT
  .timeZone("UTC")
  .onRun(async () => {
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
      const applianceCounts: Record<string, number> = {};

      for (const log of logsSnap.docs) {
        const d = log.data();
        totalKwh += d.dailyKwh ?? 0;
        totalCost += d.dailyCost ?? 0;
        const name = d.applianceName ?? "Unknown";
        applianceCounts[name] = (applianceCounts[name] ?? 0) + (d.dailyKwh ?? 0);
      }

      const topAppliance = Object.entries(applianceCounts).sort((a, b) => b[1] - a[1])[0]?.[0] ?? "";
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
export const budgetMonitor = functions.firestore
  .document("users/{userId}/usageLogs/{logId}")
  .onCreate(async (snap: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    const { userId } = context.params;

    const homeDoc = await db.doc(`users/${userId}`).get();
    if (!homeDoc.exists) return null;
    const budget: number = homeDoc.data()!.monthlyBudget ?? 0;
    if (budget <= 0) return null;

    // Sum all costs this month
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const logsSnap = await db
      .collection(`users/${userId}/usageLogs`)
      .where("date", ">=", admin.firestore.Timestamp.fromDate(startOfMonth))
      .get();

    let totalCost = 0;
    for (const d of logsSnap.docs) {
      totalCost += d.data().dailyCost ?? 0;
    }

    const projectedMonthly = totalCost * (30 / now.getDate());

    if (projectedMonthly > budget) {
      await _createAlert(userId, {
        type: "budget",
        message: `Projected monthly bill (Rs ${projectedMonthly.toFixed(0)}) exceeds your budget (Rs ${budget}). Consider reducing usage.`,
        severity: "high",
      });
    } else if (projectedMonthly > budget * 0.8) {
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
export const generateInsights = functions.pubsub
  .schedule("0 20 * * *") // 20:00 UTC = 1:00 AM PKT
  .timeZone("UTC")
  .onRun(async () => {
    const usersSnap = await db.collection("users").get();

    for (const userDoc of usersSnap.docs) {
      const uid = userDoc.id;
      const appliancesSnap = await db.collection(`users/${uid}/appliances`).get();

      let totalKwh = 0;
      const applianceKwh: Record<string, number> = {};

      for (const app of appliancesSnap.docs) {
        const d = app.data();
        const kwh = d.computedDailyKwh ?? 0;
        totalKwh += kwh;
        applianceKwh[d.name ?? "Unknown"] = kwh;
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
async function _createAlert(uid: string, alert: { type: string; message: string; severity: string }) {
  await db.collection(`users/${uid}/alerts`).add({
    ...alert,
    read: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
