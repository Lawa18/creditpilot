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
            <span className="text-foreground font-medium">MyCreditPilot</span> is an open-source collection of autonomous AI agents that handle the day-to-day work of B2B credit management: credit limit adjustments, AR aging reviews, news monitoring, SEC filing alerts, and more.
          </p>

          <p>
            I built it to explore what modern AI agents can do for trade credit — starting with a demo company and dummy data to show the agents in action.
          </p>

          <Separator />

          <div className="space-y-2">
            <p className="text-foreground font-medium">
              Want to run it on your own data? Deploy it yourself →{" "}
              <a
                href="https://github.com/larsewallin/mycreditpilot"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1 text-primary hover:underline"
              >
                GitHub
                <ExternalLink className="h-3 w-3" />
              </a>
            </p>
            <p>
              The agents connect directly to your ERP or AR system. Local deployment takes four environment variables and a few minutes.
            </p>
          </div>

          <Separator />

          <div className="space-y-2">
            <p>
              By day I work in trade credit insurance at{" "}
              <a
                href="https://www.coface.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-foreground font-medium hover:underline"
              >
                Coface
              </a>
              . Follow along as new agents ship — or reach out if trade credit insurance is relevant to your business.
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
