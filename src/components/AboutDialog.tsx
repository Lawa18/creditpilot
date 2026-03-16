import { Info, Linkedin, Shield, ExternalLink } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";

export function AboutDialog() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <button className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-sidebar-muted hover:text-sidebar-foreground hover:bg-sidebar-accent/50 transition-colors w-full">
          <Info className="h-4 w-4 shrink-0" />
          <span className="flex-1 text-left">About this project</span>
        </button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2 text-lg">
            <Shield className="h-5 w-5 text-primary" />
            About My Credit Pilot
          </DialogTitle>
        </DialogHeader>

        <div className="space-y-4 text-sm text-muted-foreground leading-relaxed">
          <p>
            Hey! I'm <span className="text-foreground font-medium">Lars-Erik Wallin</span>, and I built this as a working concept for what
            AI-powered credit risk monitoring could look like in practice.
          </p>

          <p>
            The idea is simple: instead of manually tracking customer risk across
            news, SEC filings, and AR aging reports, autonomous agents do the
            heavy lifting — surfacing the signals that matter so credit teams can
            act faster.
          </p>

          <Separator />

          <div className="space-y-2">
            <h3 className="text-foreground font-medium flex items-center gap-2">
              <Shield className="h-4 w-4 text-primary" />
              Trade Credit Insurance with Coface
            </h3>
            <p>
              Tools like this work even better when paired with trade credit
              insurance. <span className="text-foreground font-medium">Coface</span> helps
              businesses protect their receivables and trade with confidence —
              covering the risk that customers can't pay.
            </p>
            <a
              href="https://www.coface.com"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-1.5 text-primary hover:underline font-medium"
            >
              Learn more about Coface
              <ExternalLink className="h-3.5 w-3.5" />
            </a>
          </div>

          <Separator />

          <div className="space-y-2">
            <p>
              If you're in credit risk, trade finance, or just curious about
              what's possible with AI agents — I'd love to connect!
            </p>
            <Button asChild variant="outline" className="gap-2">
              <a
                href="https://www.linkedin.com/in/larsewallin/"
                target="_blank"
                rel="noopener noreferrer"
              >
                <Linkedin className="h-4 w-4" />
                Connect on LinkedIn
              </a>
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
