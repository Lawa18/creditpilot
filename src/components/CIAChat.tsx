// src/components/CIAChat.tsx
// Credit Intelligence Agent — Perplexity-style persistent chat bar
// Drop this into your layout so it appears on every page.

import { useState, useRef, useEffect } from "react";
import { useCIA } from "@/hooks/useCIA";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { ScrollArea } from "@/components/ui/scroll-area";
import { cn } from "@/lib/utils";
import ReactMarkdown from "react-markdown";

// Note: install react-markdown if not present:  npm install react-markdown

export function CIAChat() {
  const { messages, isLoading, error, staleAgents, runCIA, askQuestion, clearMessages } = useCIA();
  const [input, setInput] = useState("");
  const [isOpen, setIsOpen] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Auto-scroll to latest message
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const handleRunBriefing = async () => {
    setIsOpen(true);
    await runCIA();
  };

  const handleSubmit = async () => {
    if (!input.trim() || isLoading) return;
    const q = input.trim();
    setInput("");
    if (messages.length === 0) {
      // First message — run full briefing with question
      await runCIA(q);
    } else {
      // Follow-up question
      await askQuestion(q);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  };

  return (
    <>
      {/* Floating trigger bar — always visible at bottom */}
      <div className="fixed bottom-0 left-0 right-0 z-50 border-t border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/80">
        {/* Stale agents warning */}
        {staleAgents.length > 0 && isOpen && (
          <div className="flex items-center gap-2 px-4 py-1.5 text-xs text-amber-600 bg-amber-50 border-b border-amber-100">
            <span className="font-medium">Stale data:</span>
            {staleAgents.map(a => (
              <Badge key={a} variant="outline" className="text-amber-600 border-amber-300 text-xs">
                {a.replace("-agent", "")}
              </Badge>
            ))}
            <span className="text-amber-500">— run agents to refresh</span>
          </div>
        )}

        {/* Expanded message panel */}
        {isOpen && messages.length > 0 && (
          <div className="border-b border-border">
            <ScrollArea className="h-[380px] px-4 py-3" ref={scrollRef as React.RefObject<HTMLDivElement>}>
              <div className="max-w-4xl mx-auto space-y-4">
                {messages.map((msg, i) => (
                  <div
                    key={i}
                    className={cn(
                      "flex gap-3",
                      msg.role === "user" ? "justify-end" : "justify-start"
                    )}
                  >
                    {msg.role === "assistant" && (
                      <div className="flex-shrink-0 w-7 h-7 rounded-full bg-primary/10 flex items-center justify-center text-xs font-bold text-primary">
                        CIA
                      </div>
                    )}
                    <div
                      className={cn(
                        "max-w-[85%] rounded-lg px-4 py-2.5 text-sm",
                        msg.role === "user"
                          ? "bg-primary text-primary-foreground"
                          : "bg-muted prose prose-sm max-w-none"
                      )}
                    >
                      {msg.role === "assistant" ? (
                        <ReactMarkdown>{msg.content}</ReactMarkdown>
                      ) : (
                        msg.content
                      )}
                    </div>
                    {msg.role === "user" && (
                      <div className="flex-shrink-0 w-7 h-7 rounded-full bg-secondary flex items-center justify-center text-xs font-bold">
                        You
                      </div>
                    )}
                  </div>
                ))}

                {isLoading && (
                  <div className="flex gap-3 justify-start">
                    <div className="flex-shrink-0 w-7 h-7 rounded-full bg-primary/10 flex items-center justify-center text-xs font-bold text-primary">
                      CIA
                    </div>
                    <div className="bg-muted rounded-lg px-4 py-2.5">
                      <div className="flex gap-1 items-center h-4">
                        <span className="w-1.5 h-1.5 bg-primary/40 rounded-full animate-bounce [animation-delay:0ms]" />
                        <span className="w-1.5 h-1.5 bg-primary/40 rounded-full animate-bounce [animation-delay:150ms]" />
                        <span className="w-1.5 h-1.5 bg-primary/40 rounded-full animate-bounce [animation-delay:300ms]" />
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </ScrollArea>
          </div>
        )}

        {/* Input bar */}
        <div className="flex items-end gap-2 px-4 py-3 max-w-4xl mx-auto w-full">
          {/* Toggle / collapse */}
          {messages.length > 0 && (
            <Button
              variant="ghost"
              size="sm"
              className="flex-shrink-0 h-9 w-9 p-0"
              onClick={() => setIsOpen(o => !o)}
              title={isOpen ? "Collapse" : "Expand"}
            >
              {isOpen ? "↓" : "↑"}
            </Button>
          )}

          {/* Question input */}
          <Textarea
            ref={textareaRef}
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder={
              messages.length === 0
                ? "Ask CIA a question or click Run Briefing…"
                : "Ask a follow-up…"
            }
            rows={1}
            className="flex-1 min-h-[40px] max-h-[120px] resize-none text-sm py-2.5"
            disabled={isLoading}
            onClick={() => setIsOpen(true)}
          />

          {/* Run Briefing CTA — only before first message */}
          {messages.length === 0 && (
            <Button
              onClick={handleRunBriefing}
              disabled={isLoading}
              size="sm"
              className="flex-shrink-0 h-9"
            >
              {isLoading ? "Analysing…" : "Run Briefing"}
            </Button>
          )}

          {/* Send follow-up */}
          {messages.length > 0 && (
            <Button
              onClick={handleSubmit}
              disabled={isLoading || !input.trim()}
              size="sm"
              className="flex-shrink-0 h-9"
            >
              Send
            </Button>
          )}

          {/* Clear */}
          {messages.length > 0 && !isLoading && (
            <Button
              variant="ghost"
              size="sm"
              className="flex-shrink-0 h-9 text-muted-foreground"
              onClick={clearMessages}
              title="Clear conversation"
            >
              ✕
            </Button>
          )}
        </div>

        {error && (
          <div className="px-4 pb-2 text-xs text-destructive">
            Error: {error}
          </div>
        )}
      </div>

      {/* Spacer so page content isn't hidden behind the bar */}
      <div className={cn(
        "transition-all",
        isOpen && messages.length > 0 ? "h-[480px]" : "h-[68px]"
      )} />
    </>
  );
}
