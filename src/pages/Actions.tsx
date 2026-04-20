import { useState } from "react";
import { useQuery, useQueryClient, useMutation } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { formatCurrency } from "@/lib/format";
import { relativeTime } from "@/lib/format";
import { toast } from "sonner";
import { format } from "date-fns";
import { Loader2, CheckCircle2, XCircle, RotateCcw } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Textarea } from "@/components/ui/textarea";
import { AgentPill } from "@/components/AgentPill";
import { SeverityBadge } from "@/components/SeverityBadge";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";

const SEVERITY_RANK: Record<string, number> = {
  critical: 4, high: 3, medium: 2, low: 1, info: 0,
};

export default function Actions() {
  const queryClient = useQueryClient();
  const [rejectingId, setRejectingId] = useState<string | null>(null);
  const [rejectNote, setRejectNote] = useState("");
  const [resetting, setResetting] = useState(false);

  // ── Credit Events ───────────────────────────────────────────────────────────
  const { data: creditEvents, isLoading: eventsLoading } = useQuery({
    queryKey: ["credit-events-recent"],
    queryFn: async () => {
      const { data } = await supabase
        .from("credit_events")
        .select("*, customers(company_name, ticker)")
        .order("created_at", { ascending: false })
        .limit(20);
      // Sort by severity rank desc, then created_at desc
      return (data ?? []).sort((a: any, b: any) => {
        const diff = (SEVERITY_RANK[b.severity] ?? 0) - (SEVERITY_RANK[a.severity] ?? 0);
        return diff !== 0 ? diff : b.created_at.localeCompare(a.created_at);
      });
    },
    refetchInterval: 30000,
  });

  // ── Pending Actions ─────────────────────────────────────────────────────────
  const { data: pendingActions, refetch: refetchPending } = useQuery({
    queryKey: ["actions-pending"],
    queryFn: async () => {
      const { data } = await supabase
        .from("pending_actions")
        .select("*, customers(company_name, ticker, credit_limit)")
        .eq("status", "pending")
        .order("created_at", { ascending: false });
      return data ?? [];
    },
    refetchInterval: 30000,
  });

  // ── Approve ─────────────────────────────────────────────────────────────────
  const approveMutation = useMutation({
    mutationFn: async (action: any) => {
      await supabase.from("pending_actions").update({
        status: "approved",
        reviewed_by: "credit_manager",
        reviewed_at: new Date().toISOString(),
      }).eq("id", action.id);

      if (action.action_type === "CREDIT_LIMIT_REDUCTION" && action.proposed_value != null) {
        await supabase.from("customers").update({ credit_limit: action.proposed_value }).eq("id", action.customer_id);
      }

      await supabase.from("credit_actions").insert({
        customer_id: action.customer_id,
        action_date: new Date().toISOString().split("T")[0],
        action_type: action.action_type,
        description: `Approved. ${action.rationale ?? ""}`,
        agent_name: action.agent_name,
      });
    },
    onSuccess: () => {
      refetchPending();
      queryClient.invalidateQueries({ queryKey: ["pending-actions-count"] });
      queryClient.invalidateQueries({ queryKey: ["activity-feed"] });
      toast.success("Action approved");
    },
  });

  // ── Reject ──────────────────────────────────────────────────────────────────
  const rejectMutation = useMutation({
    mutationFn: async ({ id, note }: { id: string; note: string }) => {
      await supabase.from("pending_actions").update({
        status: "rejected",
        reviewed_by: "credit_manager",
        reviewed_at: new Date().toISOString(),
        review_note: note,
      }).eq("id", id);
    },
    onSuccess: () => {
      refetchPending();
      queryClient.invalidateQueries({ queryKey: ["pending-actions-count"] });
      setRejectingId(null);
      setRejectNote("");
      toast.success("Action rejected");
    },
  });

  // ── Reset Demo ──────────────────────────────────────────────────────────────
  const SEED_PENDING_IDS = [
    "a0000001-0000-0000-0000-000000000001",
    "a0000001-0000-0000-0000-000000000002",
    "a0000001-0000-0000-0000-000000000003",
  ];
  const SEED_CREDIT_LIMITS = [
    { id: "c0000001-0000-0000-0000-000000000029", limit: 3000000 },
    { id: "c0000001-0000-0000-0000-000000000008", limit: 4500000 },
    { id: "c0000001-0000-0000-0000-000000000005", limit: 5000000 },
  ];

  const resetDemo = async () => {
    setResetting(true);
    try {
      // Reset seed pending actions back to pending
      await supabase.from("pending_actions").update({ status: "pending", reviewed_by: null, reviewed_at: null, review_note: null }).in("id", SEED_PENDING_IDS);

      // Reset credit limits for the 3 seed customers
      for (const { id, limit } of SEED_CREDIT_LIMITS) {
        await supabase.from("customers").update({ credit_limit: limit }).eq("id", id);
      }

      // Reset SEC alerts
      await supabase.from("sec_monitoring").update({ alert_triggered: true }).in("customer_id", [
        "c0000001-0000-0000-0000-000000000021",
        "c0000001-0000-0000-0000-000000000049",
      ]);

      await supabase.from("negative_news").update({ reviewed: false, reviewed_by: null, reviewed_at: null }).not("id", "is", null);

      sessionStorage.removeItem("demo_activated");
      sessionStorage.removeItem("demo_agents");
      sessionStorage.removeItem("demo_initialized");

      queryClient.invalidateQueries();
      toast.success("Demo reset successfully");
    } catch {
      toast.error("Failed to reset demo");
    } finally {
      setResetting(false);
    }
  };

  const agentLabel: Record<string, string> = {
    ar_aging_agent: "AR Aging",
    news_monitor_agent: "News Monitor",
    sec_monitor_agent: "SEC Monitor",
    "cia-agent": "CIA",
  };

  return (
    <div className="space-y-6 pb-48">
      {/* Page header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold text-foreground">Pending Actions</h1>
          <p className="text-xs text-muted-foreground mt-1">
            Recent credit events and AI-recommended actions awaiting approval.
          </p>
        </div>
        <AlertDialog>
          <AlertDialogTrigger asChild>
            <Button variant="outline" size="sm" className="gap-1.5 text-muted-foreground">
              <RotateCcw className="h-3.5 w-3.5" />
              Reset Demo
            </Button>
          </AlertDialogTrigger>
          <AlertDialogContent>
            <AlertDialogHeader>
              <AlertDialogTitle>Reset the demo?</AlertDialogTitle>
              <AlertDialogDescription>
                This will restore all pending actions, SEC alerts, credit limits, and news reviewed state.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <AlertDialogFooter>
              <AlertDialogCancel>Cancel</AlertDialogCancel>
              <AlertDialogAction
                onClick={resetDemo}
                disabled={resetting}
                className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
              >
                {resetting && <Loader2 className="h-3.5 w-3.5 animate-spin mr-1" />}
                Reset
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
      </div>

      {/* Pending Actions — first */}
      <div>
        <div className="flex items-center gap-2 mb-3">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-muted-foreground">
            Actions Awaiting Approval
          </h2>
          {(pendingActions?.length ?? 0) > 0 && (
            <span className="bg-severity-critical text-primary-foreground text-[10px] font-semibold px-1.5 py-0.5 rounded-full min-w-[18px] text-center">
              {pendingActions!.length}
            </span>
          )}
        </div>

        {!pendingActions || pendingActions.length === 0 ? (
          <div className="flex items-center justify-center h-24 border border-dashed rounded-xl text-muted-foreground text-sm">
            No pending actions.
          </div>
        ) : (
          <div className="space-y-3">
            {(pendingActions as any[]).map((action) => {
              const cust = action.customers;
              return (
                <div key={action.id} className="bg-card rounded-xl border p-4 space-y-3 text-xs">
                  <div className="flex items-center gap-2">
                    <Badge className="bg-agent-aging/15 text-agent-aging border-0 text-[10px]">
                      ⚠ PENDING APPROVAL
                    </Badge>
                    <AgentPill agentName={action.agent_name} />
                  </div>
                  <p className="text-sm font-semibold text-foreground">
                    {cust?.company_name}{" "}
                    {cust?.ticker && (
                      <span className="text-muted-foreground font-normal">({cust.ticker})</span>
                    )}
                  </p>
                  <p className="text-foreground">
                    Action:{" "}
                    <span className="font-medium capitalize">
                      {action.action_type?.replace(/_/g, " ").toLowerCase()}
                    </span>
                  </p>
                  {action.action_type === "CREDIT_LIMIT_REDUCTION" && (
                    <p className="font-mono text-foreground">
                      {formatCurrency(action.current_value)} → {formatCurrency(action.proposed_value)}
                    </p>
                  )}
                  {action.rationale && (
                    <p className="text-muted-foreground italic">"{action.rationale}"</p>
                  )}
                  <p className="text-muted-foreground text-[10px]">
                    Created {format(new Date(action.created_at), "MMM d, HH:mm")}
                  </p>

                  {rejectingId === action.id ? (
                    <div className="space-y-2">
                      <Textarea
                        placeholder="Rejection reason..."
                        value={rejectNote}
                        onChange={(e) => setRejectNote(e.target.value)}
                        className="text-xs min-h-[60px]"
                      />
                      <div className="flex gap-2">
                        <Button
                          size="sm"
                          variant="destructive"
                          className="h-7 text-xs"
                          onClick={() => rejectMutation.mutate({ id: action.id, note: rejectNote })}
                          disabled={rejectMutation.isPending}
                        >
                          Confirm Reject
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          className="h-7 text-xs"
                          onClick={() => { setRejectingId(null); setRejectNote(""); }}
                        >
                          Cancel
                        </Button>
                      </div>
                    </div>
                  ) : (
                    <div className="flex gap-2">
                      <Button
                        size="sm"
                        className="h-7 text-xs bg-risk-current hover:bg-risk-current/90 text-primary-foreground"
                        onClick={() => approveMutation.mutate(action)}
                        disabled={approveMutation.isPending}
                      >
                        <CheckCircle2 className="h-3 w-3 mr-1" /> Approve
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        className="h-7 text-xs text-severity-critical border-severity-critical/30"
                        onClick={() => setRejectingId(action.id)}
                      >
                        <XCircle className="h-3 w-3 mr-1" /> Reject
                      </Button>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Recent Credit Events */}
      <div>
        <h2 className="text-sm font-semibold uppercase tracking-wide text-muted-foreground mb-3">
          Recent Credit Events
        </h2>
        <div className="bg-card rounded-xl border overflow-hidden">
          {eventsLoading ? (
            <div className="flex items-center justify-center h-24 text-muted-foreground text-sm">
              <Loader2 className="h-4 w-4 animate-spin mr-2" /> Loading signals…
            </div>
          ) : !creditEvents || creditEvents.length === 0 ? (
            <div className="flex items-center justify-center h-24 text-muted-foreground text-sm">
              No credit signals in the last 24 hours.
            </div>
          ) : (
            <table className="w-full text-sm">
              <thead className="bg-secondary/50">
                <tr className="text-xs text-muted-foreground">
                  <th className="text-left p-3 font-medium">Severity</th>
                  <th className="text-left p-3 font-medium">Customer</th>
                  <th className="text-left p-3 font-medium">Event</th>
                  <th className="text-left p-3 font-medium">Agent</th>
                  <th className="text-left p-3 font-medium">Time</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {(creditEvents as any[]).map((evt) => {
                  const cust = evt.customers;
                  return (
                    <tr key={evt.id} className="hover:bg-secondary/30 transition-colors">
                      <td className="p-3">
                        <SeverityBadge severity={evt.severity} />
                      </td>
                      <td className="p-3">
                        <span className="font-medium text-xs">{cust?.company_name ?? "—"}</span>
                        {cust?.ticker && (
                          <span className="text-muted-foreground text-[10px] ml-1.5">{cust.ticker}</span>
                        )}
                      </td>
                      <td className="p-3 text-xs max-w-xs">
                        <span className="font-mono text-[10px] text-muted-foreground bg-secondary px-1.5 py-0.5 rounded">
                          {evt.event_type}
                        </span>
                        {evt.title && (
                          <p className="text-foreground mt-0.5 truncate max-w-[220px]">{evt.title}</p>
                        )}
                      </td>
                      <td className="p-3">
                        <AgentPill agentName={evt.source_agent} />
                      </td>
                      <td className="p-3 text-xs text-muted-foreground whitespace-nowrap">
                        {relativeTime(evt.created_at)}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}
