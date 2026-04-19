import React, { useState, useEffect, useRef, useCallback } from "react";
import { useQuery, useQueryClient, useMutation } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { getAgentConfig } from "@/lib/constants";
import { formatCurrency } from "@/lib/format";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { format } from "date-fns";
import { Clock, Play, Loader2, CheckCircle2, XCircle, AlertTriangle, Mail, MessageSquare, RotateCcw } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { AgentPill } from "@/components/AgentPill";
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

export default function Actions() {
  const queryClient = useQueryClient();
  const [runningAgents, setRunningAgents] = useState<Set<string>>(new Set());
  const runningRef = useRef(false);
  const [logEntries, setLogEntries] = useState<LogEntry[]>([]);
  const [latestRunId, setLatestRunId] = useState<string | null>(null);
  const [selectedAgent, setSelectedAgent] = useState<string>("all");
  const [outputTab, setOutputTab] = useState("messages");
  const [rejectingId, setRejectingId] = useState<string | null>(null);
  const [rejectNote, setRejectNote] = useState("");
  const [expandedMessages, setExpandedMessages] = useState<Set<string>>(new Set());
  const [resetting, setResetting] = useState(false);
  const logRef = useRef<HTMLDivElement>(null);

  const [sessionActivated, setSessionActivated] = useState(() =>
    sessionStorage.getItem("demo_activated") === "true"
  );
  const [sessionAgents, setSessionAgents] = useState<Set<string>>(() => {
    try {
      const stored = sessionStorage.getItem("demo_agents");
      return new Set<string>(stored ? JSON.parse(stored) : []);
    } catch {
      return new Set<string>();
    }
  });
  const [revealCached, setRevealCached] = useState(false);

  const activateSession = useCallback((agentName: string) => {
    sessionStorage.setItem("demo_activated", "true");
    setSessionActivated(true);
    setSessionAgents((prev) => {
      const next = new Set(prev);
      next.add(agentName);
      sessionStorage.setItem("demo_agents", JSON.stringify(Array.from(next)));
      return next;
    });
  }, []);

  const addLog = useCallback((entry: Omit<LogEntry, "id">) => {
    setLogEntries((prev) => [...prev, { ...entry, id: crypto.randomUUID() }]);
  }, []);

  const isSessionAgentVisible = useCallback(
    (agentName: string | null | undefined) => !!agentName && sessionAgents.has(agentName),
    [sessionAgents]
  );

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
    if (latestRun?.id) setLatestRunId(latestRun.id);
  }, [latestRun]);

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

  const { data: allMessages, refetch: refetchMessages } = useQuery({
    queryKey: ["demo-messages-all"],
    queryFn: async () => {
      const { data } = await supabase
        .from("agent_messages")
        .select("*, customers(company_name, ticker)")
        .order("created_at", { ascending: true });
      return data ?? [];
    },
  });

  const latestRunIdPerAgent = React.useMemo(() => {
    const map: Record<string, string> = {};
    if (agentLastRuns) {
      for (const agent of AGENTS) {
        const run = agentLastRuns[agent.name];
        if (run?.id) map[agent.name] = run.id;
      }
    }
    return map;
  }, [agentLastRuns]);

  const messages = (allMessages ?? []).filter(
    (m: any) =>
      sessionActivated &&
      isSessionAgentVisible(m.agent_name) &&
      (selectedAgent === "all" || m.agent_name === selectedAgent)
  );

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

  const filteredPending = (pendingActions ?? []).filter(
    (a: any) =>
      a.status === "pending" &&
      sessionActivated &&
      isSessionAgentVisible(a.agent_name) &&
      (selectedAgent === "all" || a.agent_name === selectedAgent)
  );
  const pendingCount = filteredPending.length;

  const { data: allRuns } = useQuery({
    queryKey: ["all-agent-runs"],
    queryFn: async () => {
      const { data } = await supabase
        .from("agent_runs")
        .select("*")
        .order("started_at", { ascending: true });
      return data ?? [];
    },
  });

  useEffect(() => {
    if (!allRuns) return;
    const initialLogs: LogEntry[] = [];
    (allRuns as any[]).forEach((run) => {
      initialLogs.push({
        id: `run-start-${run.id}`,
        timestamp: run.started_at,
        icon: run.status === "running" ? "start" : run.status === "completed" ? "complete" : "fail",
        text:
          run.status === "running"
            ? `${getAgentConfig(run.agent_name).label} started — scanning portfolio`
            : run.status === "completed"
            ? `Run complete — ${run.summary ?? "done"}`
            : `Run failed`,
        agentName: run.agent_name,
      });
    });
    (allMessages ?? []).forEach((m: any) => {
      initialLogs.push({
        id: `msg-${m.id}`,
        timestamp: m.created_at,
        icon: "message",
        text: `Composed ${m.template_type ?? m.channel} for ${m.customers?.company_name ?? "unknown"}`,
        agentName: m.agent_name,
      });
    });
    (pendingActions ?? []).forEach((a: any) => {
      initialLogs.push({
        id: `pending-${a.id}`,
        timestamp: a.created_at,
        icon: "pending",
        text: `Pending approval: ${a.action_type?.replace(/_/g, " ")} for ${a.customers?.company_name ?? "unknown"}`,
        agentName: a.agent_name,
      });
    });
    setLogEntries(initialLogs.sort((a, b) => a.timestamp.localeCompare(b.timestamp)));
  }, [allRuns, allMessages, pendingActions]);

  const filteredLogEntries = sessionActivated
    ? logEntries.filter(
        (e) =>
          isSessionAgentVisible(e.agentName) &&
          (selectedAgent === "all" || e.agentName === selectedAgent)
      )
    : [];

  useEffect(() => {
    const channel = supabase
      .channel("actions-realtime")
      .on("postgres_changes", { event: "*", schema: "public", table: "agent_runs" }, (payload: any) => {
        const row = payload.new;
        if (!row) return;
        queryClient.invalidateQueries({ queryKey: ["agent-last-runs"] });
        queryClient.invalidateQueries({ queryKey: ["latest-run"] });
        queryClient.invalidateQueries({ queryKey: ["all-agent-runs"] });
        if (row.run_id) setLatestRunId(row.run_id);
        if (row.status === "running") {
          setRunningAgents((prev) => new Set(prev).add(row.agent_name));
          addLog({ timestamp: row.started_at, icon: "start", text: `${getAgentConfig(row.agent_name).label} started — scanning portfolio`, agentName: row.agent_name });
        } else if (row.status === "completed") {
          setRunningAgents((prev) => { const s = new Set(prev); s.delete(row.agent_name); return s; });
          runningRef.current = false;
          addLog({ timestamp: row.completed_at ?? new Date().toISOString(), icon: "complete", text: `Run complete — ${row.summary ?? "done"}`, agentName: row.agent_name });
          refetchMessages();
          refetchPending();
          queryClient.invalidateQueries({ queryKey: ["pending-actions-count"] });
        } else if (row.status === "failed") {
          setRunningAgents((prev) => { const s = new Set(prev); s.delete(row.agent_name); return s; });
          runningRef.current = false;
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

  useEffect(() => {
    if (logRef.current) logRef.current.scrollTop = logRef.current.scrollHeight;
  }, [logEntries]);

  const runAgent = async (agent: typeof AGENTS[number]) => {
    if (runningRef.current) return;

    const finishLaunch = () => {
      setRunningAgents((prev) => { const next = new Set(prev); next.delete(agent.name); return next; });
      runningRef.current = false;
    };

    const isRateLimitedError = (error: unknown): boolean => {
      if (!error) return false;
      const err = error as any;
      if (err.context && typeof err.context.status === "number" && err.context.status === 429) return true;
      if (err.name === "FunctionsHttpError" || err.constructor?.name === "FunctionsHttpError") return true;
      const msg = (err.message ?? err.error ?? "").toLowerCase();
      return msg.includes("rate_limited") || msg.includes("recently") || msg.includes("429") || msg.includes("non-2xx");
    };

    const isBudgetError = (error: unknown): boolean => {
      if (!error) return false;
      const err = error as any;
      const msg = (err.message ?? err.error ?? "").toLowerCase();
      return msg.includes("token_cap") || msg.includes("budget");
    };

    const revealCachedResults = async (message: string) => {
      activateSession(agent.name);
      setRevealCached(true);
      toast.info(message, { duration: 5000 });
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ["agent-last-runs"] }),
        queryClient.invalidateQueries({ queryKey: ["latest-run"] }),
        queryClient.invalidateQueries({ queryKey: ["all-agent-runs"] }),
        queryClient.invalidateQueries({ queryKey: ["demo-messages-all"] }),
        queryClient.invalidateQueries({ queryKey: ["demo-pending"] }),
      ]);
    };

    runningRef.current = true;
    setRevealCached(false);
    setRunningAgents((prev) => new Set(prev).add(agent.name));

    try {
      const { data, error } = await supabase.functions.invoke(agent.fnName, {
        body: { triggered_by: "actions_page" },
      });

      if (error) {
        if (isRateLimitedError(error)) {
          await revealCachedResults("This agent was run recently. Loading cached results.");
        } else if (isBudgetError(error)) {
          await revealCachedResults("AI analysis budget reached. Loading cached results.");
        } else {
          toast.error(`Failed to invoke ${agent.label}`);
        }
        finishLaunch();
        return;
      }

      activateSession(agent.name);
      finishLaunch();
      if ((data as { run_id?: string } | null)?.run_id) {
        setLatestRunId((data as { run_id: string }).run_id);
      }
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ["agent-last-runs"] }),
        queryClient.invalidateQueries({ queryKey: ["latest-run"] }),
        queryClient.invalidateQueries({ queryKey: ["all-agent-runs"] }),
      ]);
    } catch (error) {
      if (isRateLimitedError(error)) {
        await revealCachedResults("This agent was run recently. Loading cached results.");
      } else if (isBudgetError(error)) {
        await revealCachedResults("AI analysis budget reached. Loading cached results.");
      } else {
        toast.error(`Failed to invoke ${agent.label}`);
      }
      finishLaunch();
    }
  };

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
        description: `Approved via actions page. ${action.rationale ?? ""}`,
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

  const resetDemo = async () => {
    setResetting(true);
    try {
      await supabase.from("pending_actions").update({ status: "pending" }).eq("agent_name", "ar_aging_agent");
      await supabase.from("sec_monitoring").update({ alert_triggered: true }).in("customer_id", [
        "c0000001-0000-0000-0000-000000000021",
        "c0000001-0000-0000-0000-000000000049",
      ]);

      const { data: pendingActionsData } = await supabase
        .from("pending_actions")
        .select("customer_id, current_value, action_type")
        .eq("agent_name", "ar_aging_agent")
        .eq("action_type", "CREDIT_LIMIT_REDUCTION");

      if (pendingActionsData && pendingActionsData.length > 0) {
        for (const action of pendingActionsData) {
          if (action.current_value != null) {
            await supabase.from("customers").update({ credit_limit: action.current_value }).eq("id", action.customer_id);
          }
        }
      }

      await supabase.from("negative_news").update({ reviewed: false, reviewed_by: null, reviewed_at: null }).not("id", "is", null);

      setLogEntries([]);
      setLatestRunId(null);
      setRunningAgents(new Set());
      setRevealCached(false);
      sessionStorage.removeItem("demo_activated");
      sessionStorage.removeItem("demo_agents");
      sessionStorage.removeItem("demo_initialized");
      setSessionActivated(false);
      setSessionAgents(new Set());

      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ["agent-last-runs"] }),
        queryClient.invalidateQueries({ queryKey: ["latest-run"] }),
        queryClient.invalidateQueries({ queryKey: ["all-agent-runs"] }),
        queryClient.invalidateQueries({ queryKey: ["demo-messages-all"] }),
        queryClient.invalidateQueries({ queryKey: ["demo-pending"] }),
        queryClient.invalidateQueries({ queryKey: ["pending-actions-count"] }),
        queryClient.invalidateQueries({ queryKey: ["activity-feed"] }),
        queryClient.invalidateQueries({ queryKey: ["sidebar-badges"] }),
      ]);

      toast.success("Demo reset successfully");
    } catch {
      toast.error("Failed to reset demo");
    } finally {
      setResetting(false);
    }
  };

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
    <div className="space-y-4">
      {/* Page header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold text-foreground">Pending Actions</h1>
          <p className="text-xs text-muted-foreground mt-1">
            Run agents to scan the portfolio and review AI-generated recommendations.
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
                This will clear all agent runs, messages, and pending actions. This cannot be undone.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <AlertDialogFooter>
              <AlertDialogCancel>Cancel</AlertDialogCancel>
              <AlertDialogAction
                onClick={resetDemo}
                disabled={resetting}
                className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
              >
                {resetting ? <Loader2 className="h-3.5 w-3.5 animate-spin mr-1" /> : null}
                Reset
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
      </div>

      {/* Agent filter tabs */}
      <div className="flex gap-2">
        <button
          onClick={() => setSelectedAgent("all")}
          className={cn(
            "px-3 py-1.5 rounded-lg text-xs font-medium transition-colors",
            selectedAgent === "all"
              ? "bg-primary text-primary-foreground"
              : "bg-muted text-muted-foreground hover:text-foreground"
          )}
        >
          All Agents
        </button>
        {AGENTS.map((agent) => {
          const config = getAgentConfig(agent.name);
          return (
            <button
              key={agent.name}
              onClick={() => setSelectedAgent(agent.name)}
              className={cn(
                "px-3 py-1.5 rounded-lg text-xs font-medium transition-colors",
                selectedAgent === agent.name
                  ? "text-primary-foreground"
                  : "bg-muted text-muted-foreground hover:text-foreground"
              )}
              style={selectedAgent === agent.name ? { backgroundColor: `hsl(var(--${config.colorClass}))` } : undefined}
            >
              {agent.label}
            </button>
          );
        })}
      </div>

      {/* 3-column grid */}
      <div className="grid grid-cols-[260px_1fr_360px] gap-4">
        {/* LEFT — Agent Controls */}
        <div className="space-y-3">
          {AGENTS.map((agent) => {
            const config = getAgentConfig(agent.name);
            const lastRun = agentLastRuns?.[agent.name];
            const minutesAgo = lastRun?.started_at
              ? Math.round((Date.now() - new Date(lastRun.started_at).getTime()) / 60000)
              : null;
            const isRunning = runningAgents.has(agent.name);
            const isAgentVisible = sessionActivated && isSessionAgentVisible(agent.name);

            return (
              <div key={agent.name} className="bg-card rounded-xl border shadow-sm overflow-hidden">
                <div className="h-1" style={{ backgroundColor: `hsl(var(--${config.colorClass}))` }} />
                <div className="p-4 space-y-3">
                  <div>
                    <p className="font-semibold text-sm text-foreground">{agent.label}</p>
                    <p className="text-[10px] font-mono text-muted-foreground">{agent.name}</p>
                  </div>
                  {isAgentVisible ? (
                    <>
                      <p className="text-xs text-muted-foreground">
                        Last run: {minutesAgo != null ? `${minutesAgo}m ago` : "Never"}
                      </p>
                      {lastRun && lastRun.status === "completed" && (
                        <div className={cn("grid grid-cols-3 gap-2 text-center", revealCached ? "animate-in fade-in slide-in-from-bottom-2" : "")}>
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
                    </>
                  ) : (
                    <p className="text-xs text-muted-foreground">Click Run Agent to start</p>
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
          <div ref={logRef} className="flex-1 overflow-auto max-h-[580px] p-4 space-y-2">
            {filteredLogEntries.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-16 text-muted-foreground">
                <Clock className="h-8 w-8 mb-3 opacity-50" />
                <p className="text-sm">No agent runs yet.</p>
                <p className="text-xs">Click Run Agent to see the agents work in real time.</p>
              </div>
            ) : (
              filteredLogEntries.map((entry) => (
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

            <TabsContent value="messages" className="flex-1 overflow-auto max-h-[540px] p-4 space-y-3 mt-0">
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
                          <div className="border-l-4 pl-3 space-y-1" style={{ borderColor: `hsl(var(--${getAgentConfig(msg.agent_name).colorClass}))` }}>
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

            <TabsContent value="pending" className="flex-1 overflow-auto max-h-[540px] p-4 space-y-3 mt-0">
              {filteredPending.length === 0 ? (
                <p className="text-sm text-muted-foreground text-center py-8">No pending actions.</p>
              ) : (
                filteredPending.map((action: any) => {
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
