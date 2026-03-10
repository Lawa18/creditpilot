import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { SkeletonCard } from "@/components/SkeletonCard";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { AlertTriangle, Brain, ShieldAlert } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import { Progress } from "@/components/ui/progress";

export default function SecFilings() {
  const [expanded, setExpanded] = useState<string | null>(null);
  const queryClient = useQueryClient();

  const { data: dashboard, isLoading } = useQuery({
    queryKey: ["sec-dashboard"],
    queryFn: async () => {
      const { data } = await supabase.from("v_sec_monitoring_dashboard").select("*");
      return data ?? [];
    },
  });

  const { data: filings } = useQuery({
    queryKey: ["sec-filings", expanded],
    queryFn: async () => {
      if (!expanded) return [];
      const { data } = await supabase.from("sec_filings").select("*").eq("customer_id", expanded).order("filing_date", { ascending: false });
      return data ?? [];
    },
    enabled: !!expanded,
  });

  const markReviewed = useMutation({
    mutationFn: async (id: string) => {
      await supabase.from("sec_filings").update({ reviewed: true, reviewed_by: "credit_manager", reviewed_at: new Date().toISOString() }).eq("id", id);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["sec-filings"] });
      queryClient.invalidateQueries({ queryKey: ["sidebar-badges"] });
      toast.success("Filing marked as reviewed");
    },
  });

  const alerts = (dashboard ?? []).filter((d: any) => d.alert_triggered);

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

  if (isLoading) return <div className="space-y-4"><SkeletonCard /><SkeletonCard /><SkeletonCard /></div>;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold text-foreground">SEC Filing Monitor Agent</h1>
          <p className="text-xs text-muted-foreground mt-1">
            {dashboard?.length ?? 0} monitored customers
            {alerts.length > 0 && <span className="text-severity-critical font-medium ml-2">· {alerts.length} active alerts</span>}
          </p>
        </div>
      </div>

      {/* Alert Banner */}
      {alerts.length > 0 && (
        <div className="bg-severity-critical/10 border border-severity-critical/20 rounded-xl p-4 flex items-center gap-3">
          <AlertTriangle className="h-5 w-5 text-severity-critical shrink-0" />
          <div>
            <p className="text-sm font-semibold text-severity-critical">⚠ {alerts.length} customer{alerts.length > 1 ? "s have" : " has"} active SEC alerts</p>
            <p className="text-xs text-muted-foreground mt-0.5">{alerts.map((a: any) => a.company_name).join(", ")}</p>
          </div>
        </div>
      )}

      {/* Monitored Customers */}
      <div className="space-y-4">
        {(dashboard ?? []).map((d: any) => (
          <div key={d.id} className="bg-card rounded-xl border overflow-hidden">
            <div className="p-4">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-semibold text-foreground">{d.company_name} <span className="text-muted-foreground font-normal">{d.ticker}</span></p>
                  <p className="text-[10px] font-mono text-muted-foreground">CIK: {d.cik}</p>
                </div>
                <div className="flex items-center gap-3">
                  {/* AI Risk Score */}
                  {d.ai_risk_score != null && (
                    <div className="flex items-center gap-2">
                      <Brain className="h-3.5 w-3.5 text-agent-sec" />
                      <div className="w-16">
                        <Progress value={d.ai_risk_score} className="h-1.5" />
                      </div>
                      <span className={cn("text-xs font-semibold", getRiskColor(d.ai_risk_score))}>
                        {d.ai_risk_score}
                      </span>
                    </div>
                  )}
                  {d.alert_triggered ? (
                    <Badge variant="destructive" className="text-[10px]">ALERT ACTIVE</Badge>
                  ) : (
                    <Badge className="bg-risk-current/15 text-risk-current border-0 text-[10px]">Clear</Badge>
                  )}
                  <Button size="sm" variant="outline" className="h-7 text-xs" onClick={() => setExpanded(expanded === d.customer_id ? null : d.customer_id)}>
                    {expanded === d.customer_id ? "Hide" : "View"} Filings
                  </Button>
                </div>
              </div>
              <div className="flex gap-6 mt-3 text-xs">
                <div><span className="text-muted-foreground">Last 10-K:</span> <span className="font-medium">{d.last_10k_date ?? "N/A"}</span></div>
                <div><span className="text-muted-foreground">Last 10-Q:</span> <span className="font-medium">{d.last_10q_date ?? "N/A"}</span></div>
                {d.ai_risk_score != null && (
                  <div><span className="text-muted-foreground">AI Risk:</span> <span className={cn("font-medium", getRiskColor(d.ai_risk_score))}>{getRiskLabel(d.ai_risk_score)}</span></div>
                )}
              </div>
              {/* AI Summary */}
              {d.ai_summary && (
                <div className="mt-2 flex items-start gap-1.5 bg-agent-sec/5 rounded-lg p-2">
                  <ShieldAlert className="h-3.5 w-3.5 text-agent-sec mt-0.5 shrink-0" />
                  <p className="text-xs text-muted-foreground">{d.ai_summary}</p>
                </div>
              )}
              {d.risk_signals?.length > 0 && (
                <div className="flex gap-1.5 mt-2 flex-wrap">
                  {d.risk_signals.map((s: string) => (
                    <Badge key={s} variant="secondary" className="text-[10px]">{s.replace(/_/g, " ")}</Badge>
                  ))}
                </div>
              )}
            </div>

            {/* Expanded filings */}
            {expanded === d.customer_id && filings && (
              <div className="border-t bg-secondary/20">
                {filings.map((f: any) => {
                  const typeColor = f.filing_type === "10-K" ? "bg-agent-news/15 text-agent-news" : f.filing_type === "8-K" ? "bg-agent-sec/15 text-agent-sec" : "bg-agent-aging/15 text-agent-aging";
                  return (
                    <div key={f.id} className="p-4 border-b last:border-0 flex items-start justify-between gap-4">
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-xs text-muted-foreground">{f.filing_date}</span>
                          <Badge className={cn("text-[10px] border-0", typeColor)}>{f.filing_type}</Badge>
                          {f.ai_risk_score != null && (
                            <Badge variant="outline" className={cn("text-[10px]", getRiskColor(f.ai_risk_score))}>
                              AI: {f.ai_risk_score}/100
                            </Badge>
                          )}
                        </div>
                        <p className="text-xs text-foreground">{f.key_findings}</p>
                        {f.ai_summary && (
                          <p className="text-xs text-muted-foreground mt-1 italic">🤖 {f.ai_summary}</p>
                        )}
                        {f.risk_signals?.length > 0 && (
                          <div className="flex gap-1.5 mt-1.5 flex-wrap">
                            {f.risk_signals.map((s: string) => (
                              <Badge key={s} variant="outline" className="text-[10px]">{s.replace(/_/g, " ")}</Badge>
                            ))}
                          </div>
                        )}
                      </div>
                      <div className="shrink-0">
                        {f.reviewed ? (
                          <span className="text-risk-current text-xs">✓ Reviewed</span>
                        ) : (
                          <Button size="sm" variant="outline" className="h-7 text-xs" onClick={() => markReviewed.mutate(f.id)}>Mark Reviewed</Button>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
