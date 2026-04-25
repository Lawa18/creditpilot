import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { SkeletonCard } from "@/components/SkeletonCard";
import { Badge } from "@/components/ui/badge";
import { Brain, ExternalLink, ShieldAlert } from "lucide-react";
import { cn } from "@/lib/utils";
import { Progress } from "@/components/ui/progress";

const getRiskColor = (score: number | null) => {
  if (score == null) return "text-muted-foreground";
  if (score >= 70) return "text-severity-critical";
  if (score >= 40) return "text-agent-aging";
  return "text-risk-current";
};

const getRiskLabel = (score: number | null) => {
  if (score == null) return "Not analyzed";
  if (score >= 70) return "High Risk";
  if (score >= 40) return "Moderate";
  return "Low Risk";
};

export default function SecFilings() {
  const { data: dashboard, isLoading: loadingDashboard } = useQuery({
    queryKey: ["sec-dashboard"],
    queryFn: async () => {
      const { data } = await supabase.from("v_sec_monitoring_dashboard").select("*");
      return data ?? [];
    },
  });

  const { data: secEvents } = useQuery({
    queryKey: ["sec-credit-events"],
    queryFn: async () => {
      const { data } = await supabase
        .from("credit_events")
        .select("customer_id, event_type")
        .eq("agent_name", "sec_monitor_agent");
      return data ?? [];
    },
  });

  // Group event_type values by customer_id
  const eventsByCustomer = (secEvents ?? []).reduce<Record<string, string[]>>((acc, e: any) => {
    if (!acc[e.customer_id]) acc[e.customer_id] = [];
    if (!acc[e.customer_id].includes(e.event_type)) acc[e.customer_id].push(e.event_type);
    return acc;
  }, {});

  if (loadingDashboard) return <div className="space-y-4"><SkeletonCard /><SkeletonCard /><SkeletonCard /></div>;

  if (!dashboard || dashboard.length === 0) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-xl font-semibold text-foreground">SEC Filings</h1>
          <p className="text-xs text-muted-foreground mt-1">SEC filing data for monitored customers.</p>
        </div>
        <div className="flex items-center justify-center h-64 border border-dashed rounded-xl text-muted-foreground text-sm">
          No monitored customers found. Agents will populate this automatically.
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-semibold text-foreground">SEC Filings</h1>
        <p className="text-xs text-muted-foreground mt-1">SEC filing data for monitored customers.</p>
      </div>

      <div className="space-y-4">
        {(dashboard ?? []).map((d: any) => {
          const events = eventsByCustomer[d.customer_id] ?? [];
          const secUrl = `https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=${d.cik}&type=10-K&dateb=&owner=include&count=10`;
          return (
            <div key={d.id} className="bg-card rounded-xl border overflow-hidden">
              <div className="p-4">
                {/* Header row */}
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <p className="text-sm font-semibold text-foreground">
                      {d.company_name}{" "}
                      <span className="text-muted-foreground font-normal">{d.ticker}</span>
                    </p>
                    <p className="text-[10px] font-mono text-muted-foreground mt-0.5">CIK: {d.cik}</p>
                  </div>
                  <div className="flex items-center gap-3 shrink-0">
                    {d.ai_risk_score != null && (
                      <div className="flex items-center gap-2">
                        <Brain className="h-3.5 w-3.5 text-agent-sec" />
                        <div className="w-16">
                          <Progress value={d.ai_risk_score} className="h-1.5" />
                        </div>
                        <span className={cn("text-xs font-semibold", getRiskColor(d.ai_risk_score))}>
                          {getRiskLabel(d.ai_risk_score)}
                        </span>
                      </div>
                    )}
                    <a
                      href={secUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground transition-colors"
                    >
                      View SEC Filings <ExternalLink className="h-3 w-3" />
                    </a>
                  </div>
                </div>

                {/* Filing dates */}
                <div className="flex gap-6 mt-3 text-xs">
                  <div><span className="text-muted-foreground">Last 10-K:</span> <span className="font-medium">{d.last_10k_date ?? "N/A"}</span></div>
                  <div><span className="text-muted-foreground">Last 10-Q:</span> <span className="font-medium">{d.last_10q_date ?? "N/A"}</span></div>
                </div>

                {/* AI summary */}
                {d.ai_summary && (
                  <div className="mt-3 flex items-start gap-1.5 bg-agent-sec/5 rounded-lg p-2">
                    <ShieldAlert className="h-3.5 w-3.5 text-agent-sec mt-0.5 shrink-0" />
                    <p className="text-xs text-muted-foreground">{d.ai_summary}</p>
                  </div>
                )}

                {/* Risk signals from credit_events */}
                {events.length > 0 && (
                  <div className="flex gap-1.5 mt-3 flex-wrap">
                    {events.map((e) => (
                      <Badge key={e} variant="secondary" className="text-[10px]">
                        {e.replace(/_/g, " ")}
                      </Badge>
                    ))}
                  </div>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
