import { useEffect } from "react";
import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, Outlet, Navigate } from "react-router-dom";
import { AppSidebar } from "@/components/AppSidebar";
import { CIAChat } from "@/components/CIAChat";
import { supabase } from "@/integrations/supabase/client";
import { DEMO_MODE } from "@/lib/constants";
import ActivityFeed from "@/pages/ActivityFeed";
import NewsMonitor from "@/pages/NewsMonitor";
import ArAging from "@/pages/ArAging";
import SecFilings from "@/pages/SecFilings";
import Customers from "@/pages/Customers";
import Actions from "@/pages/Actions";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

function SidebarLayout() {
  useEffect(() => {
    if (!DEMO_MODE) return;
    if (sessionStorage.getItem("demo_initialized") === "true") return;

    const autoRun = async () => {
      try {
        await Promise.all([
          supabase.functions.invoke("ar-aging-agent", { body: { triggered_by: "auto" } }),
          supabase.functions.invoke("news-monitor-agent", { body: { triggered_by: "auto" } }),
          supabase.functions.invoke("sec-monitor-agent", { body: { triggered_by: "auto" } }),
        ]);
        await supabase.functions.invoke("cia-agent", { body: {} });

        sessionStorage.setItem("demo_initialized", "true");
        sessionStorage.setItem("demo_activated", "true");
        sessionStorage.setItem(
          "demo_agents",
          JSON.stringify(["ar_aging_agent", "news_monitor_agent", "sec_monitor_agent"])
        );

        queryClient.invalidateQueries();
      } catch {
        // silent — demo still works via manual run
      }
    };

    autoRun();
  }, []);

  return (
    <div className="flex min-h-screen w-full">
      <AppSidebar />
      <main className="flex-1 p-6 overflow-auto">
        <Outlet />
      </main>
      <CIAChat />
    </div>
  );
}

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <Routes>
          <Route element={<SidebarLayout />}>
            <Route path="/" element={<ActivityFeed />} />
            <Route path="/actions" element={<Actions />} />
            <Route path="/demo" element={<Navigate to="/actions" replace />} />
            <Route path="/news" element={<NewsMonitor />} />
            <Route path="/aging" element={<ArAging />} />
            <Route path="/sec" element={<SecFilings />} />
            <Route path="/customers" element={<Customers />} />
            <Route path="*" element={<NotFound />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
