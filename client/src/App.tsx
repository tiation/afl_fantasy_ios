import { Switch, Route } from "wouter";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import Layout from "@/components/Layout";
import NotFound from "@/pages/not-found";
import Dashboard from "@/pages/dashboard";
import Lineup from "@/pages/lineup";
import Leagues from "@/pages/leagues";
import Stats from "@/pages/stats";
import PlayerStats from "@/pages/player-stats";
import ToolsSimple from "@/pages/tools-simple";
import ToolsAccordion from "@/pages/tools-accordion";
import TeamPage from "@/pages/team-page";
import UserProfile from "@/pages/profile";
import TradeAnalyzer from "@/pages/trade-analyzer";
import PreviewTool from "@/pages/preview-tool";
import GuildCodex from "@/pages/GuildCodex";
import Support from "@/pages/Support";
import ReleaseNotes from "@/pages/ReleaseNotes";
import PrivacyPolicy from "@/pages/PrivacyPolicy";
import TermsOfService from "@/pages/TermsOfService";
import ContactUs from "@/pages/ContactUs";
import Features from "@/pages/Features";

function Router() {
  return (
    <Layout>
      <Switch>
        <Route path="/" component={Dashboard} />
        <Route path="/player-stats" component={PlayerStats} />
        <Route path="/lineup" component={Lineup} />
        <Route path="/leagues" component={Leagues} />
        <Route path="/stats" component={Stats} />
        <Route path="/profile" component={UserProfile} />
        <Route path="/trade-analyzer" component={TradeAnalyzer} />
        <Route path="/tools-simple" component={ToolsSimple} />
        <Route path="/tools-accordion" component={ToolsAccordion} />
        <Route path="/team" component={TeamPage} />
        <Route path="/preview-tool" component={PreviewTool} />
        <Route path="/guild-codex" component={GuildCodex} />
        <Route path="/support" component={Support} />
        <Route path="/release-notes" component={ReleaseNotes} />
        <Route path="/privacy-policy" component={PrivacyPolicy} />
        <Route path="/terms-of-service" component={TermsOfService} />
        <Route path="/contact-us" component={ContactUs} />
        <Route path="/features" component={Features} />
        <Route component={NotFound} />
      </Switch>
    </Layout>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Toaster />
      <Router />
    </QueryClientProvider>
  );
}

export default App;