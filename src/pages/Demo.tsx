import { useState, useEffect, useRef, useCallback } from "react";
import { useQuery, useQueryClient, useMutation } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { getAgentConfig } from "@/lib/constants";
import { formatCurrency } from "@/lib/format";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { format } from "date-fns";
import { Clock, Play, Loader2, CheckCircle2, XCircle, AlertTriangle, Mail, MessageSquare, ArrowLeft } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { AgentPill } from "@/components/AgentPill";
import { Link } from "react-router-dom";

type LogEntry = {
  id: string;
  timestamp: string;
  icon: "start" | "complete" | "fail" | "message" | "pending";
  text: string;
  agentName: string | null;
};

const AGENTS = [
  { name: "ar_aging_agent", label: "AR Aging Agent", fnName: "ar-aging-agent" },
  { name: "news_monitor_agent", label: "News Monitor Agent", fnName: "news-monitor-agent" },
  { name: "sec_monitor_agent", label: "SEC Filing Agent", fnName: "sec-monitor-agent" },
];

export default function Demo() {
  const queryClient = useQueryClient();
  const [runningAgents, setRunningAgents] = useState<Set<string>>(new Set());
  const [logEntries, setLogEntries] = useState<LogEntry[]>([]);
  const [latestRunId, setLatestRunId] = useState<string | null>(null);
  const [outputTab, setOutputTab] = useState("messages");
  const [rejectingId, setRejectingId] = useState<string | null>(null);
  const [rejectNote, setRejectNote] = useState("");
  const [expandedMessages, setExpandedMessages] = useState<Set<string>>(new Set());
  const logRef = useRef<HTMLDivElement>(null);

  const addLog = useCallback((entry: Omit<LogEntry, "id">) => {
    setLogEntries((prev) => [...prev, { ...entry, id: crypto.randomUUID() }]);
  }, []);

  // Fetch latest run on mount
  const { data: latestRun } = useQuery({
    queryKey: ["latest-run"],
    queryFn: async () => {
      const { data } = await supabase
        .from("agent_runs")
        .select("*")
        .order("started_at", { ascending: false })
        .limit(1)
        .maybeSingle();
      return data;
    },
  });

  useEffect(() => {
    if (latestRun?.run_id) setLatestRunId(latestRun.run_id);
  }, [latestRun]);

  // Fetch last run per agent
  const { data: agentLastRuns } = useQuery({
    queryKey: ["agent-last-runs"],
    queryFn: async () => {
      const results: Record<string, any> = {};
      for (const agent of AGENTS) {
        const { data } = await supabase
          .from("agent_runs")
          .select("*")
          .eq("agent_name", agent.name)
          .order("started_at", { ascending: false })
          .limit(1)
          .maybeSingle();
        results[agent.name] = data;
      }
      return results;
    },
  });

  // Messages for latest run
  const { data: messages, refetch: refetchMessages } = useQuery({
    queryKey: ["demo-messages", latestRunId],
    queryFn: async () => {
      if (!latestRunId) return [];
      const { data } = await supabase
        .from("agent_messages")
        .select("*, customers(company_name, ticker)")
        .eq("run_id", latestRunId)
        .order("created_at", { ascending: true });
      return data ?? [];
    },
    enabled: !!latestRunId,
  });

  // Pending actions (all, not just latest run)
  const { data: pendingActions, refetch: refetchPending } = useQuery({
    queryKey: ["demo-pending"],
    queryFn: async () => {
      const { data } = await supabase
        .from("pending_actions")
        .select("*, customers(company_name, ticker, credit_limit)")
        .order("created_at", { ascending: false });
      return data ?? [];
    },
  });

  const pendingCount = (pendingActions ?? []).filter((a: any) => a.status === "pending").length;

  // Load initial log entries from latest run
  useEffect(() => {
    if (!latestRunId || !messages) return;
    const initialLogs: LogEntry[] = [];
    if (latestRun) {
      initialLogs.push({
        id: `run-start-${latestRun.id}`,
        timestamp: latestRun.started_at,
        icon: latestRun.status === "running" ? "start" : latestRun.status === "completed" ? "complete" : "fail",
        text: latestRun.status === "running"
          ? `${getAgentConfig(latestRun.agent_name).label} started — scanning portfolio`
          : latestRun.status === "completed"
          ? `Run complete — ${latestRun.summary ?? "done"}`
          : `Run failed`,
        agentName: latestRun.agent_name,
      });
    }
    (messages as any[]).forEach((m) => {
      initialLogs.push({
        id: `msg-${m.id}`,
        timestamp: m.created_at,
        icon: "message",
        text: `Composed ${m.template_type ?? m.channel} for ${(m as any).customers?.company_name ?? "unknown"}`,
        agentName: m.agent_name,
      });
    });
    (pendingActions ?? []).filter((a: any) => a.run_id === latestRunId).forEach((a: any) => {
      initialLogs.push({
        id: `pending-${a.id}`,
        timestamp: a.created_at,
        icon: "pending",
        text: `Pending approval: ${a.action_type?.replace(/_/g, " ")} for ${(a as any).customers?.company_name ?? "unknown"}`,
        agentName: a.agent_name,
      });
    });
    setLogEntries(initialLogs.sort((a, b) => a.timestamp.localeCompare(b.timestamp)));
  }, [latestRunId, messages, pendingActions, latestRun]);

  // Realtime subscription
  useEffect(() => {
    const channel = supabase
      .channel("demo-realtime")
      .on("postgres_changes", { event: "*", schema: "public", table: "agent_runs" }, (payload: any) => {
        const row = payload.new;
        if (!row) return;
        queryClient.invalidateQueries({ queryKey: ["agent-last-runs"] });
        queryClient.invalidateQueries({ queryKey: ["latest-run"] });
        if (row.run_id) setLatestRunId(row.run_id);
        if (row.status === "running") {
          setRunningAgents((prev) => new Set(prev).add(row.agent_name));
          addLog({ timestamp: row.started_at, icon: "start", text: `${getAgentConfig(row.agent_name).label} started — scanning portfolio`, agentName: row.agent_name });
        } else if (row.status === "completed") {
          setRunningAgents((prev) => { const s = new Set(prev); s.delete(row.agent_name); return s; });
          addLog({ timestamp: row.completed_at ?? new Date().toISOString(), icon: "complete", text: `Run complete — ${row.summary ?? "done"}`, agentName: row.agent_name });
          refetchMessages();
          refetchPending();
          queryClient.invalidateQueries({ queryKey: ["pending-actions-count"] });
        } else if (row.status === "failed") {
          setRunningAgents((prev) => { const s = new Set(prev); s.delete(row.agent_name); return s; });
          addLog({ timestamp: row.completed_at ?? new Date().toISOString(), icon: "fail", text: `Run failed — ${row.summary ?? "error"}`, agentName: row.agent_name });
        }
      })
      .on("postgres_changes", { event: "INSERT", schema: "public", table: "agent_messages" }, (payload: any) => {
        const row = payload.new;
        if (!row) return;
        refetchMessages();
        addLog({ timestamp: row.created_at, icon: "message", text: `Composed ${row.template_type ?? row.channel} for customer`, agentName: row.agent_name });
      })
      .on("postgres_changes", { event: "INSERT", schema: "public", table: "pending_actions" }, (payload: any) => {
        const row = payload.new;
        if (!row) return;
        refetchPending();
        queryClient.invalidateQueries({ queryKey: ["pending-actions-count"] });
        addLog({ timestamp: row.created_at, icon: "pending", text: `Pending approval: ${row.action_type?.replace(/_/g, " ")}`, agentName: row.agent_name });
      })
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, [addLog, queryClient, refetchMessages, refetchPending]);

  // Scroll log to bottom
  useEffect(() => {
    if (logRef.current) logRef.current.scrollTop = logRef.current.scrollHeight;
  }, [logEntries]);

  // Run agent
  const runAgent = async (agent: typeof AGENTS[number]) => {
    setRunningAgents((prev) => new Set(prev).add(agent.name));
    try {
      const { error } = await supabase.functions.invoke(agent.fnName, {
        body: { triggered_by: "demo_page" },
      });
      if (error) {
        toast.error(`Failed to invoke ${agent.label}`);
        setRunningAgents((prev) => { const s = new Set(prev); s.delete(agent.name); return s; });
      }
    } catch {
      toast.error(`Failed to invoke ${agent.label}`);
      setRunningAgents((prev) => { const s = new Set(prev); s.delete(agent.name); return s; });
    }
  };

  // Approve action
  const approveMutation = useMutation({
    mutationFn: async (action: any) => {
      await supabase.from("pending_actions").update({
        status: "approved",
        reviewed_by: "demo_user",
        reviewed_at: new Date().toISOString(),
      }).eq("id", action.id);

      if (action.action_type === "CREDIT_LIMIT_REDUCTION" && action.proposed_value != null) {
        await supabase.from("customers").update({ credit_limit: action.proposed_value }).eq("id", action.customer_id);
      }

      await supabase.from("credit_actions").insert({
        customer_id: action.customer_id,
        action_date: new Date().toISOString().split("T")[0],
        action_type: action.action_type,
        description: `Approved via demo page. ${action.rationale ?? ""}`,
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

  // Reject action
  const rejectMutation = useMutation({
    mutationFn: async ({ id, note }: { id: string; note: string }) => {
      await supabase.from("pending_actions").update({
        status: "rejected",
        reviewed_by: "demo_user",
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

  const anyRunning = runningAgents.size > 0;

  const logIcon = (type: LogEntry["icon"]) => {
    switch (type) {
      case "start": return <span className="text-agent-news">◎</span>;
      case "complete": return <CheckCircle2 className="h-3.5 w-3.5 text-risk-current" />;
      case "fail": return <XCircle className="h-3.5 w-3.5 text-severity-critical" />;
      case "message": return <span className="text-agent-news">→</span>;
      case "pending": return <AlertTriangle className="h-3.5 w-3.5 text-agent-aging" />;
    }
  };

  const toggleExpand = (id: string) => {
    setExpandedMessages((prev) => {
      const s = new Set(prev);
      s.has(id) ? s.delete(id) : s.add(id);
      return s;
    });
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="bg-sidebar text-sidebar-foreground px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link to="/" className="text-sidebar-muted hover:text-sidebar-foreground transition-colors">
            <ArrowLeft className="h-4 w-4" />
          </Link>
          <h1 className="font-semibold">Credit Agent Observer — Live Demo</h1>
        </div>
        <p className="text-sm text-sidebar-muted">Global Trading Solutions Inc · 49 customers · $103M portfolio</p>
      </header>

      {/* 3-column layout */}
      <div className="max-w-[1400px] mx-auto p-6 grid grid-cols-[280px_1fr_380px] gap-6">
        {/* LEFT — Agent Controls */}
        <div className="space-y-4">
          {AGENTS.map((agent) => {
            const config = getAgentConfig(agent.name);
            const lastRun = agentLastRuns?.[agent.name];
            const minutesAgo = lastRun?.started_at
              ? Math.round((Date.now() - new Date(lastRun.started_at).getTime()) / 60000)
              : null;
            const isRunning = runningAgents.has(agent.name);

            return (
              <div key={agent.name} className="bg-card rounded-xl border shadow-sm overflow-hidden">
                <div className={cn("h-1", config.bgClass.replace("/10", ""))} style={{ backgroundColor: `hsl(var(--${config.colorClass}))` }} />
                <div className="p-4 space-y-3">
                  <div>
                    <p className="font-semibold text-sm text-foreground">{agent.label}</p>
                    <p className="text-[10px] font-mono text-muted-foreground">{agent.name}</p>
                  </div>
                  <p className="text-xs text-muted-foreground">
                    Last run: {minutesAgo != null ? `${minutesAgo}m ago` : "Never"}
                  </p>
                  {lastRun && lastRun.status === "completed" && (
                    <div className="grid grid-cols-3 gap-2 text-center">
                      <div>
                        <p className="text-lg font-bold text-foreground">{lastRun.customers_scanned ?? 0}</p>
                        <p className="text-[10px] text-muted-foreground">Scanned</p>
                      </div>
                      <div>
                        <p className="text-lg font-bold text-foreground">{lastRun.conditions_found ?? 0}</p>
                        <p className="text-[10px] text-muted-foreground">Found</p>
                      </div>
                      <div>
                        <p className="text-lg font-bold text-foreground">{lastRun.messages_composed ?? 0}</p>
                        <p className="text-[10px] text-muted-foreground">Messages</p>
                      </div>
                    </div>
                  )}
                  <Button
                    className="w-full text-xs"
                    disabled={anyRunning}
                    onClick={() => runAgent(agent)}
                    style={!anyRunning ? { backgroundColor: `hsl(var(--${config.colorClass}))` } : undefined}
                  >
                    {isRunning ? (
                      <><Loader2 className="h-3.5 w-3.5 animate-spin" /> Running...</>
                    ) : (
                      <><Play className="h-3.5 w-3.5" /> Run Agent</>
                    )}
                  </Button>
                </div>
              </div>
            );
          })}
        </div>

        {/* CENTER — Live Execution Log */}
        <div className="bg-card rounded-xl border shadow-sm flex flex-col">
          <div className="px-4 py-3 border-b">
            <h2 className="text-sm font-semibold text-foreground">Live Execution Log</h2>
          </div>
          <div ref={logRef} className="flex-1 overflow-auto max-h-[600px] p-4 space-y-2">
            {logEntries.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-16 text-muted-foreground">
                <Clock className="h-8 w-8 mb-3 opacity-50" />
                <p className="text-sm">No agent runs yet.</p>
                <p className="text-xs">Click Run Agent to see the agents work in real time.</p>
              </div>
            ) : (
              logEntries.map((entry) => (
                <div key={entry.id} className="flex items-start gap-2 text-xs">
                  <span className="font-mono text-muted-foreground whitespace-nowrap w-16 shrink-0">
                    {format(new Date(entry.timestamp), "HH:mm:ss")}
                  </span>
                  <span className="shrink-0 mt-0.5">{logIcon(entry.icon)}</span>
                  <span className="text-foreground">{entry.text}</span>
                </div>
              ))
            )}
          </div>
        </div>

        {/* RIGHT — Output */}
        <div className="bg-card rounded-xl border shadow-sm flex flex-col">
          <Tabs value={outputTab} onValueChange={setOutputTab} className="flex flex-col flex-1">
            <div className="px-4 pt-3">
              <TabsList className="h-8">
                <TabsTrigger value="messages" className="text-xs h-7">Messages</TabsTrigger>
                <TabsTrigger value="pending" className="text-xs h-7 gap-1.5">
                  Pending Actions
                  {pendingCount > 0 && (
                    <span className="bg-severity-critical text-primary-foreground text-[10px] font-semibold px-1.5 py-0.5 rounded-full min-w-[18px] text-center">
                      {pendingCount}
                    </span>
                  )}
                </TabsTrigger>
              </TabsList>
            </div>

            <TabsContent value="messages" className="flex-1 overflow-auto max-h-[560px] p-4 space-y-3 mt-0">
              {!messages || messages.length === 0 ? (
                <p className="text-sm text-muted-foreground text-center py-8">No messages from this run yet.</p>
              ) : (
                (messages as any[]).map((msg) => {
                  const isExpanded = expandedMessages.has(msg.id);
                  const bodyLines = (msg.body ?? "").split("\n");
                  const isLong = bodyLines.length > 8;
                  const displayBody = isExpanded ? msg.body : bodyLines.slice(0, 8).join("\n");
                  const cust = (msg as any).customers;

                  return (
                    <div key={msg.id} className="bg-background rounded-lg border p-3 space-y-2 text-xs">
                      <div className="flex items-center gap-2">
                        {msg.channel === "email" ? (
                          <span className="flex items-center gap-1 text-agent-news font-semibold"><Mail className="h-3 w-3" /> EMAIL</span>
                        ) : (
                          <span className="flex items-center gap-1 text-agent-sec font-semibold"><MessageSquare className="h-3 w-3" /> TEAMS</span>
                        )}
                        {msg.template_type && (
                          <Badge variant="outline" className="text-[10px] h-5">{msg.template_type}</Badge>
                        )}
                      </div>

                      {msg.channel === "email" ? (
                        <>
                          <p className="text-muted-foreground">
                            To: <span className="text-foreground">{msg.recipient_name}</span>
                            {cust && <span className="ml-2">· Re: {cust.company_name} ({cust.ticker})</span>}
                          </p>
                          <hr className="border-border" />
                          <p className="font-medium text-foreground">Subject: {msg.subject}</p>
                          <pre className="whitespace-pre-wrap text-muted-foreground font-sans">{displayBody}</pre>
                        </>
                      ) : (
                        <>
                          <p className="text-muted-foreground">→ {msg.recipient_name}</p>
                          <div className={cn("border-l-4 pl-3 space-y-1")} style={{ borderColor: `hsl(var(--${getAgentConfig(msg.agent_name).colorClass}))` }}>
                            {bodyLines.length > 0 && <p className="font-semibold text-foreground">{bodyLines[0]}</p>}
                            <pre className="whitespace-pre-wrap text-muted-foreground font-sans">{(isExpanded ? bodyLines : bodyLines.slice(1, 8)).slice(1).join("\n")}</pre>
                          </div>
                        </>
                      )}

                      {isLong && (
                        <button onClick={() => toggleExpand(msg.id)} className="text-primary text-[10px] hover:underline">
                          {isExpanded ? "Show less" : "Show more"}
                        </button>
                      )}
                    </div>
                  );
                })
              )}
            </TabsContent>

            <TabsContent value="pending" className="flex-1 overflow-auto max-h-[560px] p-4 space-y-3 mt-0">
              {!pendingActions || pendingActions.length === 0 ? (
                <p className="text-sm text-muted-foreground text-center py-8">No pending actions.</p>
              ) : (
                (pendingActions as any[]).map((action) => {
                  const cust = (action as any).customers;
                  const isReviewed = action.status !== "pending";

                  if (isReviewed) {
                    return (
                      <div key={action.id} className="bg-background rounded-lg border p-3 text-xs flex items-center gap-2">
                        <span className="text-foreground font-medium">{cust?.company_name}</span>
                        <span className="text-muted-foreground">— {action.action_type?.replace(/_/g, " ")}</span>
                        <span className="ml-auto">
                          {action.status === "approved" ? (
                            <Badge className="bg-risk-current/15 text-risk-current border-0 text-[10px]">✓ Approved</Badge>
                          ) : (
                            <Badge className="bg-severity-critical/15 text-severity-critical border-0 text-[10px]">✗ Rejected</Badge>
                          )}
                        </span>
                        <span className="text-muted-foreground text-[10px]">
                          by {action.reviewed_by} {action.reviewed_at && format(new Date(action.reviewed_at), "HH:mm")}
                        </span>
                      </div>
                    );
                  }

                  return (
                    <div key={action.id} className="bg-background rounded-lg border p-4 space-y-3 text-xs">
                      <div className="flex items-center gap-2">
                        <Badge className="bg-agent-aging/15 text-agent-aging border-0 text-[10px]">⚠ PENDING APPROVAL</Badge>
                        <AgentPill agentName={action.agent_name} />
                      </div>
                      <p className="text-sm font-semibold text-foreground">
                        {cust?.company_name} {cust?.ticker && <span className="text-muted-foreground font-normal">({cust.ticker})</span>}
                      </p>
                      <p className="text-foreground">
                        Action: <span className="font-medium capitalize">{action.action_type?.replace(/_/g, " ").toLowerCase()}</span>
                      </p>
                      {action.action_type === "CREDIT_LIMIT_REDUCTION" && (
                        <p className="font-mono text-foreground">
                          {formatCurrency(action.current_value)} → {formatCurrency(action.proposed_value)}
                        </p>
                      )}
                      {action.rationale && (
                        <p className="text-muted-foreground italic">"{action.rationale}"</p>
                      )}

                      {rejectingId === action.id ? (
                        <div className="space-y-2">
                          <Textarea
                            placeholder="Rejection reason..."
                            value={rejectNote}
                            onChange={(e) => setRejectNote(e.target.value)}
                            className="text-xs min-h-[60px]"
                          />
                          <div className="flex gap-2">
                            <Button size="sm" variant="destructive" className="h-7 text-xs" onClick={() => rejectMutation.mutate({ id: action.id, note: rejectNote })} disabled={rejectMutation.isPending}>
                              Confirm Reject
                            </Button>
                            <Button size="sm" variant="ghost" className="h-7 text-xs" onClick={() => { setRejectingId(null); setRejectNote(""); }}>
                              Cancel
                            </Button>
                          </div>
                        </div>
                      ) : (
                        <div className="flex gap-2">
                          <Button size="sm" className="h-7 text-xs bg-risk-current hover:bg-risk-current/90 text-primary-foreground" onClick={() => approveMutation.mutate(action)} disabled={approveMutation.isPending}>
                            <CheckCircle2 className="h-3 w-3" /> Approve
                          </Button>
                          <Button size="sm" variant="outline" className="h-7 text-xs text-severity-critical border-severity-critical/30" onClick={() => setRejectingId(action.id)}>
                            <XCircle className="h-3 w-3" /> Reject
                          </Button>
                        </div>
                      )}
                    </div>
                  );
                })
              )}
            </TabsContent>
          </Tabs>
        </div>
      </div>
    </div>
  );
}
