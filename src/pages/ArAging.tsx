import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { RiskTierBadge } from "@/components/RiskTierBadge";
import { formatCurrency, formatPct, relativeTime } from "@/lib/format";
import { SkeletonCard, SkeletonTable } from "@/components/SkeletonCard";
import { Button } from "@/components/ui/button";
import { RefreshCw } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

export default function ArAging() {
  const [refreshing, setRefreshing] = useState(false);

  const { data: portfolio, isLoading: pLoading, refetch: refetchPortfolio } = useQuery({
    queryKey: ["ar-portfolio"],
    queryFn: async () => {
      const { data } = await supabase.from("v_ar_aging_portfolio").select("*").single();
      return data;
    },
  });

  const { data: customers, isLoading: cLoading, refetch: refetchCustomers } = useQuery({
    queryKey: ["ar-aging-customers"],
    queryFn: async () => {
      const { data } = await supabase.from("v_ar_aging_current").select("*").order("total_ar", { ascending: false });
      return data ?? [];
    },
  });

  const { data: actions } = useQuery({
    queryKey: ["ar-aging-actions"],
    queryFn: async () => {
      const { data } = await supabase
        .from("credit_actions")
        .select("*, customers!inner(company_name, ticker)")
        .eq("agent_name", "ar_aging_agent")
        .order("created_at", { ascending: false })
        .limit(20);
      return data ?? [];
    },
  });

  const handleRefresh = async () => {
    setRefreshing(true);
    try {
      const { error } = await supabase.rpc("fn_refresh_all_ar_aging", { p_as_of: new Date().toISOString().split("T")[0] });
      if (error) throw error;
      await Promise.all([refetchPortfolio(), refetchCustomers()]);
      toast.success("AR aging refreshed");
    } catch { toast.error("Failed to refresh"); }
    setRefreshing(false);
  };

  const total = Number(portfolio?.total_ar) || 1;
  const segments = [
    { label: "Current", value: Number(portfolio?.total_current) || 0, className: "bg-aging-current" },
    { label: "1–30", value: Number(portfolio?.total_1_30) || 0, className: "bg-aging-1-30" },
    { label: "31–60", value: Number(portfolio?.total_31_60) || 0, className: "bg-aging-31-60" },
    { label: "61–90", value: Number(portfolio?.total_61_90) || 0, className: "bg-aging-61-90" },
    { label: "90+", value: Number(portfolio?.total_over_90) || 0, className: "bg-aging-over-90" },
  ];

  if (pLoading) return <div className="space-y-4"><SkeletonCard /><SkeletonTable /></div>;

  return (
    <div className="flex gap-6">
      <div className="flex-1 space-y-6 min-w-0">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-semibold text-foreground">AR Aging Agent</h1>
          <Button size="sm" variant="outline" onClick={handleRefresh} disabled={refreshing} className="h-8 text-xs gap-2">
            <RefreshCw className={`h-3 w-3 ${refreshing ? "animate-spin" : ""}`} />
            Refresh Aging
          </Button>
        </div>

        {/* Portfolio Bar */}
        <div className="bg-card rounded-xl border p-4">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-muted-foreground mb-3">Portfolio Aging</h2>
          <div className="flex h-8 rounded-lg overflow-hidden">
            {segments.map((s) => {
              const pct = total > 0 ? (s.value / total) * 100 : 0;
              if (pct === 0) return null;
              return (
                <div key={s.label} className={`${s.className} relative`} style={{ width: `${pct}%` }} title={`${s.label}: ${formatCurrency(s.value)}`} />
              );
            })}
          </div>
          <div className="flex mt-2 gap-4">
            {segments.map((s) => (
              <div key={s.label} className="text-xs">
                <div className="flex items-center gap-1.5">
                  <span className={`w-2.5 h-2.5 rounded-sm ${s.className}`} />
                  <span className="text-muted-foreground">{s.label}</span>
                </div>
                <p className="font-medium text-foreground ml-4">{formatCurrency(s.value)}</p>
                <p className="text-muted-foreground ml-4">{total > 0 ? ((s.value / total) * 100).toFixed(1) : 0}%</p>
              </div>
            ))}
          </div>
        </div>

        {/* Customer Table */}
        {cLoading ? <SkeletonTable rows={10} /> : (
          <div className="bg-card rounded-xl border overflow-hidden">
            <table className="w-full text-xs">
              <thead className="bg-secondary/50 sticky top-0">
                <tr className="text-muted-foreground">
                  <th className="text-left p-3 font-medium">Customer</th>
                  <th className="text-left p-3 font-medium">Risk</th>
                  <th className="text-right p-3 font-medium">Current</th>
                  <th className="text-right p-3 font-medium">1–30</th>
                  <th className="text-right p-3 font-medium">31–60</th>
                  <th className="text-right p-3 font-medium">61–90</th>
                  <th className="text-right p-3 font-medium">90+</th>
                  <th className="text-right p-3 font-medium">Total</th>
                  <th className="text-right p-3 font-medium">Util%</th>
                  <th className="text-right p-3 font-medium">DSO</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {(customers ?? []).filter(c => Number(c.total_ar) > 0).map((c: any) => (
                  <tr key={c.id} className="hover:bg-secondary/30">
                    <td className="p-3 font-medium">{c.company_name} <span className="text-muted-foreground ml-1">{c.ticker}</span></td>
                    <td className="p-3"><RiskTierBadge tier={c.risk_tier} /></td>
                    <td className="p-3 text-right">{formatCurrency(c.current_amount)}</td>
                    <td className="p-3 text-right">{formatCurrency(c.days_1_30)}</td>
                    <td className="p-3 text-right">{formatCurrency(c.days_31_60)}</td>
                    <td className="p-3 text-right">{formatCurrency(c.days_61_90)}</td>
                    <td className="p-3 text-right">{formatCurrency(c.days_over_90)}</td>
                    <td className="p-3 text-right font-semibold">{formatCurrency(c.total_ar)}</td>
                    <td className="p-3 text-right">{formatPct(c.utilization_pct)}</td>
                    <td className="p-3 text-right">{c.dso ?? 0}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Right sidebar - recent actions */}
      <div className="w-72 shrink-0">
        <h2 className="text-sm font-semibold uppercase tracking-wide text-muted-foreground mb-3">Recent Agent Actions</h2>
        <div className="space-y-2">
          {(actions ?? []).map((a: any) => (
            <div key={a.id} className="bg-card rounded-lg border p-3 border-l-4 border-l-agent-aging">
              <p className="text-[10px] text-muted-foreground">{relativeTime(a.created_at)}</p>
              <p className="text-xs font-medium text-foreground">{(a.customers as any).company_name}</p>
              <p className="text-xs text-muted-foreground capitalize">{a.action_type.replace(/_/g, " ")}</p>
              <p className="text-[10px] text-muted-foreground mt-1 line-clamp-2">{a.description}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
