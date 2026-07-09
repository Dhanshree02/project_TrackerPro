import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useState, useMemo } from "react";
import { Network, Search, Mail, Phone, MapPin } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { Avatar } from "@/components/pills";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/dh-org-tree")({
  head: () => ({
    meta: [
      { title: "Organization Tree/Hierarchy — Pulse PMO" },
      { name: "description", content: "Visual organizational directory and reporting structures." },
    ],
  }),
  component: OrgTreePage,
});

interface OrgNode {
  id: string;
  name: string;
  role: string;
  dept: string;
  email: string;
  phone: string;
  location: string;
  reports?: OrgNode[];
}

const orgData: OrgNode = {
  id: "EMP-1001",
  name: "Rakesh Menon",
  role: "Chief Executive Officer / Director",
  dept: "Executive Office",
  email: "rakesh.menon@acmecorp.com",
  phone: "+91 98765 43210",
  location: "HQ Tower, Bengaluru",
  reports: [
    {
      id: "EMP-1002",
      name: "Sunita Verma",
      role: "VP of Engineering",
      dept: "Engineering",
      email: "sunita.verma@acmecorp.com",
      phone: "+91 98765 43211",
      location: "HQ Tower, Bengaluru",
      reports: [
        {
          id: "EMP-1003",
          name: "David Thomas",
          role: "Tech Lead - Platform",
          dept: "Engineering",
          email: "david.thomas@acmecorp.com",
          phone: "+91 98765 43212",
          location: "Tech Park East, Pune",
        },
        {
          id: "EMP-1004",
          name: "Anu Krishnan",
          role: "Engineering Manager - Apps",
          dept: "Engineering",
          email: "anu.krishnan@acmecorp.com",
          phone: "+91 98765 43213",
          location: "Tech Park West, Mumbai",
        }
      ]
    },
    {
      id: "EMP-1005",
      name: "Mohit Bansal",
      role: "VP of Product Management",
      dept: "Product",
      email: "mohit.bansal@acmecorp.com",
      phone: "+91 98765 43214",
      location: "Innovation Hub, Delhi NCR",
      reports: [
        {
          id: "EMP-1006",
          name: "Lakshmi Iyer",
          role: "Senior Product Manager",
          dept: "Product",
          email: "lakshmi.iyer@acmecorp.com",
          phone: "+91 98765 43215",
          location: "Innovation Hub, Delhi NCR",
        }
      ]
    },
    {
      id: "EMP-1007",
      name: "Priya Sharma",
      role: "Director of UX Design",
      dept: "Design",
      email: "priya.sharma@acmecorp.com",
      phone: "+91 98765 43216",
      location: "Central Office, Bengaluru",
      reports: [
        {
          id: "EMP-1008",
          name: "Rajesh Nair",
          role: "UX Design Lead",
          dept: "Design",
          email: "rajesh.nair@acmecorp.com",
          phone: "+91 98765 43217",
          location: "Central Office, Bengaluru",
        }
      ]
    }
  ]
};

function OrgTreePage() {
  const { isDhanshree } = useRoleContext();
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedNode, setSelectedNode] = useState<OrgNode | null>(orgData);

  if (!isDhanshree) return <Navigate to="/" />;

  // Search logic to find a node in the tree recursively
  const allNodes = useMemo(() => {
    const flatList: OrgNode[] = [];
    const traverse = (node: OrgNode) => {
      flatList.push(node);
      if (node.reports) {
        node.reports.forEach(traverse);
      }
    };
    traverse(orgData);
    return flatList;
  }, []);

  const searchResults = useMemo(() => {
    if (!searchQuery) return [];
    return allNodes.filter(
      (n) =>
        n.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        n.role.toLowerCase().includes(searchQuery.toLowerCase()) ||
        n.dept.toLowerCase().includes(searchQuery.toLowerCase())
    );
  }, [searchQuery, allNodes]);

  // Check if a node is currently matches the search query to highlight it
  const isSearchMatch = (node: OrgNode) => {
    if (!searchQuery) return false;
    return (
      node.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      node.role.toLowerCase().includes(searchQuery.toLowerCase())
    );
  };

  return (
    <AppShell title="Organization Hierarchy" subtitle="Explore the organizational hierarchy and reporting lines.">
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        
        {/* Left Side: Search & Details Card */}
        <div className="lg:col-span-1 space-y-4">
          <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
            <h3 className="text-sm font-semibold mb-3 flex items-center gap-1.5">
              <Network className="h-4 w-4 text-primary" /> Search Hierarchy
            </h3>
            <div className="relative">
              <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <input
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search name or role..."
                className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
              />
            </div>
            {searchQuery && searchResults.length > 0 && (
              <div className="mt-3 divide-y divide-border border-t border-border max-h-48 overflow-y-auto">
                {searchResults.map((node) => (
                  <button
                    key={node.id}
                    onClick={() => {
                      setSelectedNode(node);
                      setSearchQuery("");
                    }}
                    className="w-full text-left py-2 px-1 hover:bg-accent/40 text-xs transition-colors flex flex-col gap-0.5"
                  >
                    <span className="font-semibold">{node.name}</span>
                    <span className="text-[10px] text-muted-foreground">{node.role} ({node.dept})</span>
                  </button>
                ))}
              </div>
            )}
          </div>

          {selectedNode && (
            <div className="rounded-xl border border-border bg-card p-5 shadow-sm space-y-4 transition-all duration-200">
              <div className="flex flex-col items-center text-center pb-4 border-b border-border">
                <Avatar name={selectedNode.name} size={64} className="mb-3 ring-2 ring-primary/20" />
                <h4 className="font-bold text-base text-foreground leading-tight">{selectedNode.name}</h4>
                <p className="text-xs font-medium text-primary mt-1">{selectedNode.role}</p>
                <span className="mt-2 inline-flex items-center rounded-full bg-muted border border-border px-2.5 py-0.5 text-[10px] font-semibold text-muted-foreground">
                  {selectedNode.dept}
                </span>
              </div>
              <div className="space-y-3 text-xs">
                <div className="flex items-center gap-2.5 text-muted-foreground">
                  <Mail className="h-3.5 w-3.5" />
                  <a href={`mailto:${selectedNode.email}`} className="hover:text-foreground hover:underline truncate">{selectedNode.email}</a>
                </div>
                <div className="flex items-center gap-2.5 text-muted-foreground">
                  <Phone className="h-3.5 w-3.5" />
                  <span>{selectedNode.phone}</span>
                </div>
                <div className="flex items-center gap-2.5 text-muted-foreground">
                  <MapPin className="h-3.5 w-3.5" />
                  <span>{selectedNode.location}</span>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Right Side: Tree Chart Visualizer */}
        <div className="lg:col-span-3 rounded-xl border border-border bg-card p-6 shadow-sm flex flex-col overflow-x-auto min-h-[500px]">
          <h3 className="text-sm font-semibold mb-6">Interactive Tree View</h3>
          
          <div className="flex-1 flex flex-col items-center justify-start py-4 space-y-8 select-none">
            {/* Level 1: CEO */}
            <div className="flex flex-col items-center">
              <NodeCard node={orgData} selected={selectedNode?.id === orgData.id} highlighted={isSearchMatch(orgData)} onClick={setSelectedNode} />
            </div>

            {/* Connecting line CEO -> VPs */}
            <div className="h-8 w-px bg-border relative">
              <div className="absolute top-8 left-1/2 -translate-x-1/2 h-px w-[80%] bg-border" style={{ width: "calc(100% * 1.5)" }} />
            </div>

            {/* Level 2: VPs */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 relative">
              {orgData.reports?.map((vp) => (
                <div key={vp.id} className="flex flex-col items-center relative">
                  {/* Vertical connector from horizontal line to card */}
                  <div className="h-4 w-px bg-border mb-2" />
                  
                  <NodeCard node={vp} selected={selectedNode?.id === vp.id} highlighted={isSearchMatch(vp)} onClick={setSelectedNode} />

                  {/* Level 3 Reports connector */}
                  {vp.reports && vp.reports.length > 0 && (
                    <>
                      <div className="h-6 w-px bg-border relative mt-2">
                        {vp.reports.length > 1 && (
                          <div className="absolute top-6 left-1/2 -translate-x-1/2 h-px w-[120px] bg-border" />
                        )}
                      </div>
                      
                      {/* Level 3 Grid */}
                      <div className={cn("grid gap-4 mt-6", vp.reports.length > 1 ? "grid-cols-2" : "grid-cols-1")}>
                        {vp.reports.map((sub) => (
                          <div key={sub.id} className="flex flex-col items-center">
                            <div className="h-4 w-px bg-border mb-2" />
                            <NodeCard node={sub} selected={selectedNode?.id === sub.id} highlighted={isSearchMatch(sub)} onClick={setSelectedNode} compact />
                          </div>
                        ))}
                      </div>
                    </>
                  )}
                </div>
              ))}
            </div>

          </div>
        </div>

      </div>
    </AppShell>
  );
}

// ── Tree Card Component ──────────────────────────────
function NodeCard({
  node,
  selected,
  highlighted,
  onClick,
  compact = false,
}: {
  node: OrgNode;
  selected: boolean;
  highlighted: boolean;
  onClick: (n: OrgNode) => void;
  compact?: boolean;
}) {
  return (
    <button
      onClick={() => onClick(node)}
      className={cn(
        "flex flex-col items-center rounded-xl border bg-card p-3 shadow-xs transition-all duration-200 w-44 hover:shadow-md hover:-translate-y-0.5",
        selected ? "border-primary ring-2 ring-primary/20 bg-accent/20" : "border-border",
        highlighted && "border-yellow-500 ring-2 ring-yellow-500/20 bg-yellow-500/5",
        compact ? "p-2 w-36" : "p-3 w-44"
      )}
    >
      <Avatar name={node.name} size={compact ? 24 : 32} className="mb-2" />
      <span className={cn("font-bold text-foreground truncate max-w-full block leading-none", compact ? "text-[11px]" : "text-xs")}>
        {node.name}
      </span>
      <span className={cn("text-muted-foreground truncate max-w-full block mt-1 leading-none font-medium", compact ? "text-[9px]" : "text-[10px]")}>
        {node.role}
      </span>
    </button>
  );
}
