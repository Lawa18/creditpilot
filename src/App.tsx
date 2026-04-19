import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route, Outlet } from "react-router-dom";
import { AppSidebar } from "@/components/AppSidebar";
import { CIAChat } from "@/components/CIAChat";
import ActivityFeed from "@/pages/ActivityFeed";
import NewsMonitor from "@/pages/NewsMonitor";
import ArAging from "@/pages/ArAging";
import SecFilings from "@/pages/SecFilings";
import Customers from "@/pages/Customers";
import Demo from "@/pages/Demo";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

function SidebarLayout() {
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
          <Route path="/demo" element={<Demo />} />
          <Route element={<SidebarLayout />}>
            <Route path="/" element={<ActivityFeed />} />
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
