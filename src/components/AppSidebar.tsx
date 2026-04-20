import { Zap, Newspaper, BarChart2, FileSearch, Users } from "lucide-react";
import { AboutDialog } from "@/components/AboutDialog";
import { NavLink } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { cn } from "@/lib/utils";
import { DEMO_MODE } from "@/lib/constants";

const navItems = [
  { title: "Activity Feed", path: "/feed", icon: Zap },
  { title: "News Monitor", path: "/news", icon: Newspaper, badgeKey: "news" as const },
  { title: "AR Aging", path: "/aging", icon: BarChart2 },
  { title: "SEC Filings", path: "/sec", icon: FileSearch, badgeKey: "sec" as const },
  { title: "Customers", path: "/customers", icon: Users },
];

const demoItem = { title: "Pending Actions", path: "/actions", icon: Zap };

export function AppSidebar() {
  const { data: badges } = useQuery({
    queryKey: ["sidebar-badges"],
    queryFn: async () => {
      const hasActiveSession = sessionStorage.getItem("demo_activated") === "true";

      const newsCount = (DEMO_MODE && !hasActiveSession) ? 0 : await supabase
        .from("negative_news")
        .select("id", { count: "exact", head: true })
        .eq("reviewed", false)
        .then(({ count }) => count ?? 0);

      const { count: secCount } = await supabase
        .from("sec_filings")
        .select("id", { count: "exact", head: true })
        .eq("reviewed", false);

      return { news: newsCount, sec: secCount ?? 0 };
    },
    refetchInterval: 30000,
  });

  const { data: company } = useQuery({
    queryKey: ["company"],
    queryFn: async () => {
      const { data } = await supabase.from("company").select("name").limit(1).single();
      return data;
    },
  });

  return (
    <aside className="w-64 min-h-screen bg-sidebar flex flex-col shrink-0">
      <div className="p-5 border-b border-sidebar-border">
        <h1 className="text-sidebar-foreground font-semibold text-base">My Credit Pilot</h1>
        <p className="text-sidebar-muted text-xs mt-0.5">Global Trading Solutions Inc</p>
      </div>

      <nav className="flex-1 p-3 space-y-0.5">
        <NavLink
          to={demoItem.path}
          className={({ isActive }) =>
            cn(
              "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors",
              isActive
                ? "bg-sidebar-accent text-sidebar-foreground font-medium"
                : "text-sidebar-muted hover:text-sidebar-foreground hover:bg-sidebar-accent/50"
            )
          }
        >
          <demoItem.icon className="h-4 w-4 shrink-0" />
          <span className="flex-1">⚡ {demoItem.title}</span>
          <span className="w-2 h-2 rounded-full bg-risk-current animate-pulse" />
        </NavLink>

        <div className="my-2 border-t border-sidebar-border" />

        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            end={item.path === "/"}
            className={({ isActive }) =>
              cn(
                "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors",
                isActive
                  ? "bg-sidebar-accent text-sidebar-foreground font-medium"
                  : "text-sidebar-muted hover:text-sidebar-foreground hover:bg-sidebar-accent/50"
              )
            }
          >
            <item.icon className="h-4 w-4 shrink-0" />
            <span className="flex-1">{item.title}</span>
            {item.badgeKey && badges && badges[item.badgeKey] > 0 && (
              <span className="bg-severity-critical text-primary-foreground text-[10px] font-semibold px-1.5 py-0.5 rounded-full min-w-[18px] text-center">
                {badges[item.badgeKey]}
              </span>
            )}
          </NavLink>
        ))}
      </nav>

      <div className="p-3 border-t border-sidebar-border space-y-1">
        <AboutDialog />
        <p className="text-sidebar-muted text-xs px-3">{company?.name ?? "Loading..."}</p>
      </div>
    </aside>
  );
}
