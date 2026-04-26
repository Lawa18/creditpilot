// src/hooks/useCIA.ts
// Hook for interacting with the CIA (Credit Intelligence Agent)

import { useState, useCallback, useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";

export interface Source {
  event_id: string;
  customer_name: string;
  event_type: string;
  severity: "critical" | "high" | "medium" | "low" | "info";
  date: string;
  agent: string;
}

export interface CIAMessage {
  role: "user" | "assistant";
  // Shared field for user messages and briefing-mode assistant messages
  content?: string;
  // Question-mode assistant messages
  answer?: string;
  sources?: Source[];
  confidence?: string;
  confidence_reason?: string;
}

interface UseCIAReturn {
  messages: CIAMessage[];
  suggestions: string[];
  isLoading: boolean;
  error: string | null;
  staleAgents: string[];
  fetchSuggestions: () => Promise<void>;
  askQuestion: (question: string) => Promise<void>;
  runBriefing: () => Promise<void>;
  clearMessages: () => void;
}

export function useCIA(): UseCIAReturn {
  const [messages, setMessages] = useState<CIAMessage[]>([]);
  const [suggestions, setSuggestions] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [staleAgents, setStaleAgents] = useState<string[]>([]);

  // ── Suggestions (cached in sessionStorage) ────────────────────────────────
  const fetchSuggestions = useCallback(async () => {
    const cached = sessionStorage.getItem("cia_suggestions");
    if (cached) {
      try {
        setSuggestions(JSON.parse(cached));
        return;
      } catch {
        // ignore corrupt cache
      }
    }
    try {
      const { data, error: fnError } = await supabase.functions.invoke("cia-agent", {
        body: { mode: "suggestions" },
      });
      if (!fnError && Array.isArray(data?.suggestions)) {
        setSuggestions(data.suggestions);
        sessionStorage.setItem("cia_suggestions", JSON.stringify(data.suggestions));
      }
    } catch {
      // silent — suggestions are optional UX
    }
  }, []);

  useEffect(() => {
    fetchSuggestions();
  }, [fetchSuggestions]);

  // ── Ask a question (Perplexity-style structured answer) ───────────────────
  const askQuestion = useCallback(async (question: string) => {
    setIsLoading(true);
    setError(null);
    setMessages(prev => [...prev, { role: "user", content: question }]);

    try {
      const { data, error: fnError } = await supabase.functions.invoke("cia-agent", {
        body: { mode: "question", question },
      });

      if (fnError) throw new Error(fnError.message);
      if (data?.error) throw new Error(data.error);

      setMessages(prev => [
        ...prev,
        {
          role: "assistant",
          answer: data.answer ?? "",
          sources: data.sources ?? [],
          confidence: data.confidence ?? null,
          confidence_reason: data.confidence_reason ?? null,
        },
      ]);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unknown error");
    } finally {
      setIsLoading(false);
    }
  }, []);

  // ── Run daily briefing (existing behavior) ────────────────────────────────
  const runBriefing = useCallback(async () => {
    setIsLoading(true);
    setError(null);

    try {
      const { data, error: fnError } = await supabase.functions.invoke("cia-agent", {
        body: { mode: "briefing" },
      });

      if (fnError) throw new Error(fnError.message);

      setStaleAgents(data.stale_agents ?? []);
      setMessages(prev => [
        ...prev,
        { role: "assistant", content: data.briefing ?? "" },
      ]);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unknown error");
    } finally {
      setIsLoading(false);
    }
  }, []);

  // ── Clear ─────────────────────────────────────────────────────────────────
  const clearMessages = useCallback(() => {
    setMessages([]);
    setError(null);
    setStaleAgents([]);
  }, []);

  return {
    messages,
    suggestions,
    isLoading,
    error,
    staleAgents,
    fetchSuggestions,
    askQuestion,
    runBriefing,
    clearMessages,
  };
}
