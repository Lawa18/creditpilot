// src/hooks/useCIA.ts
// Hook for interacting with the CIA (Credit Intelligence Agent)

import { useState, useCallback } from "react";
import { supabase } from "@/integrations/supabase/client";

interface CIAMessage {
  role: "user" | "assistant";
  content: string;
}

interface CIAResponse {
  run_id: string | null;
  demo: boolean;
  briefing: string;
  events_processed: number;
  composite_risks_detected?: number;
  stale_agents: string[];
  messages: CIAMessage[];
}

interface UseCIAReturn {
  messages: CIAMessage[];
  isLoading: boolean;
  error: string | null;
  staleAgents: string[];
  runCIA: (question?: string, forceRefresh?: boolean) => Promise<void>;
  askQuestion: (question: string) => Promise<void>;
  clearMessages: () => void;
}

export function useCIA(): UseCIAReturn {
  const [messages, setMessages] = useState<CIAMessage[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [staleAgents, setStaleAgents] = useState<string[]>([]);

  const invoke = useCallback(async (question?: string, forceRefresh = false) => {
    setIsLoading(true);
    setError(null);

    try {
      const { data, error: fnError } = await supabase.functions.invoke("cia-agent", {
        body: {
          question: question ?? undefined,
          force_refresh: forceRefresh,
        },
      });

      if (fnError) throw new Error(fnError.message);

      const result = data as CIAResponse;
      setStaleAgents(result.stale_agents ?? []);

      // Append messages (preserving history for threaded follow-ups)
      setMessages(prev => {
        const next = [...prev];
        if (question) {
          next.push({ role: "user", content: question });
        }
        next.push({ role: "assistant", content: result.briefing });
        return next;
      });
    } catch (err) {
      const msg = err instanceof Error ? err.message : "Unknown error";
      setError(msg);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const runCIA = useCallback(
    (question?: string, forceRefresh = false) => invoke(question, forceRefresh),
    [invoke]
  );

  const askQuestion = useCallback(
    (question: string) => invoke(question, false),
    [invoke]
  );

  const clearMessages = useCallback(() => {
    setMessages([]);
    setError(null);
    setStaleAgents([]);
  }, []);

  return { messages, isLoading, error, staleAgents, runCIA, askQuestion, clearMessages };
}
