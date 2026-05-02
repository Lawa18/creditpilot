// src/pages/CIA.tsx
// Perplexity-style CIA answer page

import { useState, useEffect } from "react";
import { useSearchParams, useNavigate } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import { cn } from "@/lib/utils";
import ReactMarkdown from "react-markdown";

// ─── Types ────────────────────────────────────────────────────────────────────

interface Source {
  event_id: string;
  customer_name: string;
  event_type: string;
  severity: "critical" | "high" | "medium" | "low" | "info";
  date: string;
  agent: string;
}

interface CIAAnswer {
  answer: string;
  sources: Source[];
  confidence: "High" | "Medium" | "Low";
  confidence_reason: string;
  relatedQuestions?: string[];
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

function severityDot(severity: string) {
  if (severity === "critical" || severity === "high") return "bg-red-500";
  if (severity === "medium") return "bg-amber-400";
  return "bg-gray-300";
}

function agentLabel(agent: string) {
  if (agent.includes("ar_aging") || agent.includes("ar-aging")) return "AR";
  if (agent.includes("news")) return "News";
  if (agent.includes("sec")) return "SEC";
  if (agent.includes("cia")) return "CIA";
  return agent;
}

function formatDate(dateStr: string) {
  try {
    return new Date(dateStr).toLocaleDateString("en-US", { month: "short", day: "numeric" });
  } catch {
    return "";
  }
}

function confidenceDot(confidence: string) {
  if (confidence === "High") return "bg-emerald-500";
  if (confidence === "Medium") return "bg-amber-400";
  return "bg-red-500";
}

function confidenceText(confidence: string) {
  if (confidence === "High") return "text-emerald-700";
  if (confidence === "Medium") return "text-amber-700";
  return "text-red-700";
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

function AnswerSkeleton({ question }: { question: string }) {
  return (
    <div className="space-y-6">
      {/* Question bubble */}
      <div className="flex justify-end">
        <div className="bg-gray-100 rounded-2xl px-4 py-2.5 text-sm text-gray-800 max-w-[80%]">
          {question}
        </div>
      </div>

      {/* Loading dots + shimmer lines */}
      <div className="space-y-4 pt-2">
        <div className="flex gap-1 items-center h-5">
          <span className="w-2 h-2 bg-gray-400 rounded-full animate-bounce [animation-delay:0ms]" />
          <span className="w-2 h-2 bg-gray-400 rounded-full animate-bounce [animation-delay:150ms]" />
          <span className="w-2 h-2 bg-gray-400 rounded-full animate-bounce [animation-delay:300ms]" />
        </div>
        <div className="space-y-2.5 animate-pulse">
          <div className="h-4 bg-gray-100 rounded-md w-full" />
          <div className="h-4 bg-gray-100 rounded-md w-3/4" />
          <div className="h-4 bg-gray-100 rounded-md w-full" />
        </div>
      </div>
    </div>
  );
}

// ─── Main Page ────────────────────────────────────────────────────────────────

export default function CIA() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const question = searchParams.get("q") ?? "";

  const [answer, setAnswer] = useState<CIAAnswer | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [related, setRelated] = useState<string[]>([]);

  // Fetch answer whenever question changes
  useEffect(() => {
    if (!question) return;
    setAnswer(null);
    setError(null);
    setRelated([]);
    setIsLoading(true);

    supabase.functions
      .invoke("cia-agent", { body: { mode: "question", question } })
      .then(({ data, error: fnError }) => {
        if (fnError) throw new Error(fnError.message);
        if (data?.error) throw new Error(data.error);
        setAnswer(data as CIAAnswer);
      })
      .catch(err => setError(err instanceof Error ? err.message : "Unknown error"))
      .finally(() => setIsLoading(false));
  }, [question]);

  // Use contextual follow-up questions returned with the answer
  useEffect(() => {
    if (!answer) return;
    if (Array.isArray(answer.relatedQuestions) && answer.relatedQuestions.length > 0) {
      setRelated(answer.relatedQuestions.filter(s => s !== question).slice(0, 3));
    }
  }, [answer, question]);

  const handleSourceClick = (eventId: string) => {
    navigate(`/events?event_id=${eventId}`);
  };

  const handleRelated = (q: string) => {
    navigate(`/cia?q=${encodeURIComponent(q)}`);
  };

  if (!question) {
    return (
      <div className="max-w-[720px] mx-auto py-16 text-center text-muted-foreground text-sm">
        Use the search bar below to ask CIA a question about your portfolio.
      </div>
    );
  }

  return (
    <div className="max-w-[720px] mx-auto py-6 space-y-8">

      {isLoading && <AnswerSkeleton question={question} />}

      {error && (
        <div className="space-y-4">
          <div className="flex justify-end">
            <div className="bg-gray-100 rounded-2xl px-4 py-2.5 text-sm text-gray-800 max-w-[80%]">
              {question}
            </div>
          </div>
          <p className="text-sm text-destructive">{error}</p>
        </div>
      )}

      {answer && !isLoading && (
        <>
          {/* Question bubble */}
          <div className="flex justify-end">
            <div className="bg-gray-100 rounded-2xl px-4 py-2.5 text-sm text-gray-800 max-w-[80%] leading-relaxed">
              {question}
            </div>
          </div>

          {/* Answer section */}
          <div className="space-y-1">
            <p className="text-xs font-semibold uppercase tracking-widest text-muted-foreground">Answer</p>
            <div className="border-t border-gray-100 pt-4">
              <div className="prose prose-base max-w-none text-gray-800 prose-p:leading-relaxed prose-strong:text-gray-900 prose-p:text-base">
                <ReactMarkdown>{answer.answer}</ReactMarkdown>
              </div>
            </div>
          </div>

          {/* Sources section */}
          {answer.sources.length > 0 && (
            <div className="space-y-1">
              <p className="text-xs font-semibold uppercase tracking-widest text-muted-foreground">Sources</p>
              <div className="border-t border-gray-100 pt-3 space-y-2">
                {answer.sources.map((s, i) => (
                  <button
                    key={s.event_id}
                    onClick={() => handleSourceClick(s.event_id)}
                    className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg border border-gray-100 bg-white hover:bg-gray-50 transition-colors text-left group"
                  >
                    <span className="text-xs font-mono text-muted-foreground w-4 shrink-0">[{i + 1}]</span>
                    <span className={cn("w-2 h-2 rounded-full shrink-0", severityDot(s.severity))} />
                    <span className="text-sm font-medium text-gray-800 truncate">{s.customer_name}</span>
                    <span className="text-gray-300">·</span>
                    <span className="text-xs text-muted-foreground shrink-0">{agentLabel(s.agent)}</span>
                    <span className="text-gray-300">·</span>
                    <span className="text-xs font-mono text-muted-foreground truncate">{s.event_type.replace(/_/g, " ")}</span>
                    <span className="text-gray-300 ml-auto">·</span>
                    <span className="text-xs text-muted-foreground shrink-0">{formatDate(s.date)}</span>
                  </button>
                ))}

                {/* Confidence */}
                <div className="flex items-center gap-2 pt-1 pl-1">
                  <span className={cn("text-sm font-medium", confidenceText(answer.confidence))}>
                    Confidence: {answer.confidence}
                  </span>
                  <span className={cn("w-2 h-2 rounded-full", confidenceDot(answer.confidence))} />
                </div>
                {answer.confidence_reason && (
                  <p className="text-xs text-muted-foreground italic pl-1">
                    "{answer.confidence_reason}"
                  </p>
                )}
              </div>
            </div>
          )}

          {/* Related questions */}
          {related.length > 0 && (
            <div className="space-y-1">
              <p className="text-xs font-semibold uppercase tracking-widest text-muted-foreground">Related questions</p>
              <div className="border-t border-gray-100 pt-3 space-y-1">
                {related.map((q, i) => (
                  <button
                    key={i}
                    onClick={() => handleRelated(q)}
                    className="w-full flex items-center gap-2 px-3 py-2 rounded-lg text-sm text-left text-gray-700 hover:bg-gray-50 transition-colors group"
                  >
                    <span className="text-muted-foreground group-hover:text-foreground transition-colors">→</span>
                    <span>{q}</span>
                  </button>
                ))}
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}
