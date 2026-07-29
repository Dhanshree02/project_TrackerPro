import React from "react";
import { Wallet, CheckCircle2, Clock, FileText } from "lucide-react";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { DhInvoice } from "@/types/domain.types";

interface InvoicesTabProps {
  invoices: DhInvoice[];
  currency?: string;
}

export function InvoicesTab({ invoices, currency = "INR" }: InvoicesTabProps) {
  const totalAmount = invoices.reduce((sum, inv) => sum + (inv.invoiceAmount || 0), 0);
  const paidInvoices = invoices.filter((i) => i.paymentStatus === "Received");
  const paidAmount = paidInvoices.reduce((sum, inv) => sum + (inv.invoiceAmount || 0), 0);
  const pendingAmount = totalAmount - paidAmount;

  return (
    <div className="space-y-4">
      {/* Metric Cards */}
      <div className="grid gap-3 sm:grid-cols-3">
        <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
          <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground flex items-center gap-1.5">
            <Wallet className="h-3.5 w-3.5 text-primary" /> Total Invoiced
          </div>
          <p className="mt-2 text-2xl font-bold tabular-nums">{formatCurrency(totalAmount, currency)}</p>
        </div>
        <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
          <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground flex items-center gap-1.5">
            <CheckCircle2 className="h-3.5 w-3.5 text-success" /> Payment Received
          </div>
          <p className="mt-2 text-2xl font-bold tabular-nums text-success">{formatCurrency(paidAmount, currency)}</p>
        </div>
        <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
          <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground flex items-center gap-1.5">
            <Clock className="h-3.5 w-3.5 text-amber-500" /> Payment Pending
          </div>
          <p className="mt-2 text-2xl font-bold tabular-nums text-amber-600">{formatCurrency(pendingAmount, currency)}</p>
        </div>
      </div>

      {/* Invoice Table */}
      <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-4 py-3 font-medium">Milestone / Description</th>
              <th className="px-4 py-3 font-medium">Invoice No.</th>
              <th className="px-4 py-3 font-medium">Target Date</th>
              <th className="px-4 py-3 font-medium">Amount</th>
              <th className="px-4 py-3 font-medium">Invoice Status</th>
              <th className="px-4 py-3 font-medium text-right">Payment Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {invoices.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-4 py-8 text-center text-xs text-muted-foreground">
                  No invoice milestones scheduled for this project.
                </td>
              </tr>
            ) : (
              invoices.map((inv) => {
                const isPaid = inv.paymentStatus === "Received";
                const isRaised = inv.invoiceStatus === "Raised";
                return (
                  <tr key={inv.id} className="hover:bg-accent/30 transition-colors">
                    <td className="px-4 py-3 font-medium">{inv.milestone}</td>
                    <td className="px-4 py-3 font-mono text-xs">{inv.invoiceNumber || "—"}</td>
                    <td className="px-4 py-3 text-muted-foreground">{formatDate(inv.invoiceTargetDate)}</td>
                    <td className="px-4 py-3 font-medium tabular-nums">{formatCurrency(inv.invoiceAmount || 0, inv.currency || currency)}</td>
                    <td className="px-4 py-3">
                      <span className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-medium border ${
                        isRaised ? "bg-info/10 text-info border-info/30" : "bg-muted text-muted-foreground border-border"
                      }`}>
                        {isRaised ? "Raised" : "Not Raised"}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-right">
                      <span className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[11px] font-medium border ${
                        isPaid ? "bg-success/10 text-success border-success/30" : "bg-amber-500/10 text-amber-600 border-amber-500/30"
                      }`}>
                        {isPaid ? "Paid" : "Pending"}
                      </span>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
