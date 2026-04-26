// src/components/CIAChat.tsx
// Credit Intelligence Agent — Perplexity-style persistent chat bar

import { useState, useRef, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useCIA, type CIAMessage, type Source } from "@/hooks/useCIA";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import ReactMarkdown from "react-markdown";

// ─── Sub-components ───────────────────────────────────────────────────────────

function LoadingDots() {
  return (
    <div className="flex gap-1 items-center py-1">
      <span className="w-1.5 h-1.5 bg-muted-foreground/40 rounded-full animate-bounce [animation-delay:0ms]" />
      <span className="w-1.5 h-1.5 bg-muted-foreground/40 rounded-full animate-bounce [animation-delay:150ms]" />
      <span className="w-1.5 h-1.5 bg-muted-foreground/40 rounded-full animate-bounce [animation-delay:300ms]" />
    </div>
  );
}

function severityDot(severity: string) {
  if (severity === "critical" || severity === "high") return "bg-red-500";
  if (severity === "medium") return "bg-amber-400";
  return "bg-muted-foreground/40";
}

function agentLabel(agent: string) {
  if (agent.includes("ar_aging") || agent.includes("ar-aging")) return "AR";
  if (agent.includes("news")) return "News";
  if (agent.includes("sec")) return "SEC";
  if (agent.includes("cia")) return "CIA";
  return agent;
}

function confidenceBadgeClass(confidence: string) {
  if (confidence === "High") return "bg-emerald-500/10 text-emerald-600";
  if (confidence === "Medium") return "bg-amber-500/10 text-amber-600";
  return "bg-red-500/10 text-red-600";
}

function ConfidenceDot({ confidence }: { confidence: string }) {
  const color =
    confidence === "High"
      ? "bg-emerald-500"
      : confidence === "Medium"
      ? "bg-amber-400"
      : "bg-red-500";
  return <span className={cn("inline-block w-1.5 h-1.5 rounded-full ml-1 mb-0.5", color)} />;
}

interface SourceCardsProps {
  sources: Source[];
  onSourceClick: (eventId: string) => void;
}

function SourceCards({ sources, onSourceClick }: SourceCardsProps) {
  if (sources.length === 0) return null;
  return (
    <div className="rounded-lg border border-border overflow-hidden divide-y divide-border">
      {sources.map(s => (
        <button
          key={s.event_id}
          onClick={() => onSourceClick(s.event_id)}
          className="w-full flex items-center gap-2 px-3 py-2 text-xs hover:bg-secondary/50 text-left transition-colors"
        >
          <span className={cn("w-2 h-2 rounded-full shrink-0", severityDot(s.severity))} />
          <span className="font-medium truncate">{s.customer_name}</span>
          <span className="text-muted-foreground shrink-0">·</span>
          <span className="text-muted-foreground shrink-0">{agentLabel(s.agent)}</span>
          <span className="text-muted-foreground shrink-0">·</span>
          <span className="font-mono text-[10px] text-muted-foreground truncate">{s.event_type.replace(/_/g, " ")}</span>
        </button>
      ))}
    </div>
  );
}

interface QuestionAnswerProps {
  msg: CIAMessage;
  onSourceClick: (eventId: string) => void;
}

function QuestionAnswer({ msg, onSourceClick }: QuestionAnswerProps) {
  return (
    <div className="space-y-3">
      {/* Answer text */}
      <div className="prose prose-sm max-w-none text-foreground prose-p:text-sm prose-p:leading-relaxed">
        <ReactMarkdown>{msg.answer ?? ""}</ReactMarkdown>
      </div>

      {/* Sources + confidence */}
      {(msg.sources?.length ?? 0) > 0 && (
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-semibold uppercase tracking-wide text-muted-foreground">
              Sources
            </span>
            {msg.confidence && (
              <span className={cn("text-[10px] font-medium px-2 py-0.5 rounded-full flex items-center gap-0.5", confidenceBadgeClass(msg.confidence))}>
                Confidence: {msg.confidence}
                <ConfidenceDot confidence={msg.confidence} />
              </span>
            )}
          </div>
          <SourceCards sources={msg.sources!} onSourceClick={onSourceClick} />
          {msg.confidence_reason && (
            <p className="text-[10px] text-muted-foreground italic">"{msg.confidence_reason}"</p>
          )}
        </div>
      )}
    </div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────

export function CIAChat() {
  const {
    messages,
    suggestions,
    isLoading,
    error,
    staleAgents,
    askQuestion,
    runBriefing,
    clearMessages,
  } = useCIA();

  const [input, setInput] = useState("");
  const [isOpen, setIsOpen] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);
  const navigate = useNavigate();

  const hasMessages = messages.length > 0;

  // Auto-scroll to latest message
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages, isLoading]);

  const handleSubmit = async () => {
    if (!input.trim() || isLoading) return;
    const q = input.trim();
    setInput("");
    setIsOpen(true);
    await askQuestion(q);
  };

  const handleSuggestion = async (q: string) => {
    setIsOpen(true);
    await askQuestion(q);
  };

  const handleRunBriefing = async () => {
    setIsOpen(true);
    await runBriefing();
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      e.preventDefault();
      handleSubmit();
    }
  };

  const handleSourceClick = (eventId: string) => {
    navigate(`/events?event_id=${eventId}`);
    setIsOpen(false);
  };

  // Spacer height — keeps page content above the bar
  const spacerClass = !isOpen
    ? "h-16"
    : hasMessages
    ? "h-[520px]"
    : "h-64";

  return (
    <>
      {/* ── Fixed bottom bar ─────────────────────────────────────────────── */}
      <div className="fixed bottom-0 left-0 right-0 z-50 bg-background border-t border-border shadow-[0_-4px_24px_rgba(0,0,0,0.07)]">

        {/* Expanded panel */}
        {isOpen && (
          <div className="max-w-4xl mx-auto">
            {/* Header */}
            <div className="flex items-center justify-between px-4 py-2.5 border-b border-border">
              <div className="flex items-center gap-2">
                <span className="text-[11px] font-bold tracking-widest text-primary">CIA</span>
                {!hasMessages && (
                  <span className="text-xs text-muted-foreground">Credit Intelligence Agent</span>
                )}
                {staleAgents.length > 0 && (
                  <div className="flex items-center gap-1.5 ml-2">
                    <span className="text-[10px] text-amber-600 font-medium">Stale data:</span>
                    {staleAgents.map(a => (
                      <Badge key={a} variant="outline" className="text-amber-600 border-amber-300 text-[10px] h-4 px-1">
                        {a.replace("-agent", "")}
                      </Badge>
                    ))}
                  </div>
                )}
              </div>
              <button
                onClick={() => setIsOpen(false)}
                className="text-muted-foreground hover:text-foreground text-sm px-1 transition-colors"
                aria-label="Close"
              >
                ✕
              </button>
            </div>

            {/* Content area */}
            {hasMessages ? (
              /* Message thread */
              <div
                ref={scrollRef}
                className="overflow-y-auto h-[400px] px-4 py-3"
              >
                <div className="max-w-3xl mx-auto space-y-5">
                  {messages.map((msg, i) => (
                    <div key={i}>
                      {msg.role === "user" ? (
                        <div className="text-sm text-foreground">
                          <span className="text-[10px] font-semibold uppercase tracking-wide text-muted-foreground mr-2">
                            You
                          </span>
                          {msg.content}
                        </div>
                      ) : msg.answer != null ? (
                        <QuestionAnswer msg={msg} onSourceClick={handleSourceClick} />
                      ) : (
                        /* Briefing-mode markdown */
                        <div className="prose prose-sm max-w-none text-foreground prose-p:text-sm">
                          <ReactMarkdown>{msg.content ?? ""}</ReactMarkdown>
                        </div>
                      )}
                    </div>
                  ))}
                  {isLoading && <LoadingDots />}
                </div>
              </div>
            ) : (
              /* Suggestion chips — shown before first message */
              <div className="px-4 py-3">
                <p className="text-[10px] font-semibold uppercase tracking-wide text-muted-foreground mb-2">
                  Suggested questions
                </p>
                <div className="grid grid-cols-2 gap-2">
                  {suggestions.map((s, i) => (
                    <button
                      key={i}
                      onClick={() => handleSuggestion(s)}
                      disabled={isLoading}
                      className="text-left text-xs px-3 py-2 rounded-lg border border-border bg-secondary/40 hover:bg-secondary transition-colors disabled:opacity-50"
                    >
                      {s}
                    </button>
                  ))}
                </div>
                {isLoading && (
                  <div className="mt-3">
                    <LoadingDots />
                  </div>
                )}
              </div>
            )}
          </div>
        )}

        {/* ── Input bar (always visible) ──────────────────────────────────── */}
        <div className="max-w-4xl mx-auto px-4 py-2.5 flex items-center gap-2">
          <input
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            onFocus={() => setIsOpen(true)}
            placeholder={hasMessages ? "Ask a follow-up…" : "Ask CIA a question…"}
            disabled={isLoading}
            className="flex-1 h-9 text-sm px-3 rounded-md border border-input bg-background placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-ring disabled:opacity-50"
          />
          {hasMessages ? (
            <Button
              size="sm"
              className="h-9 w-9 p-0 shrink-0"
              onClick={handleSubmit}
              disabled={isLoading || !input.trim()}
              aria-label="Send"
            >
              →
            </Button>
          ) : (
            <Button
              size="sm"
              className="h-9 shrink-0"
              onClick={handleRunBriefing}
              disabled={isLoading}
            >
              {isLoading ? "Analysing…" : "Run Briefing"}
            </Button>
          )}
        </div>

        {error && (
          <div className="max-w-4xl mx-auto px-4 pb-2 text-xs text-destructive">
            {error}
          </div>
        )}
      </div>

      {/* ── Spacer ───────────────────────────────────────────────────────── */}
      <div className={cn("transition-all duration-300", spacerClass)} />
    </>
  );
}
