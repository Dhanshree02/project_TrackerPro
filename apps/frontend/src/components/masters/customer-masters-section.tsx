import { useState, useMemo } from "react";
import {
  Building2,
  Plus,
  Search,
  Pencil,
  Trash2,
  Globe,
  MapPin,
  Briefcase,
  UserCheck,
  Tag,
  AlertCircle,
  X,
  Layers,
  Filter,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { cn } from "@/lib/utils";
import type { CustomerMasterCategory, CustomerMastersState, SimpleMasterItem } from "@/lib/masters/types";

interface CustomerMastersSectionProps {
  canManage?: boolean;
  customerMasters: CustomerMastersState;
  onAdd: (
    category: CustomerMasterCategory,
    name: string,
    extra?: { code?: string; description?: string; countryId?: string; phoneCode?: string; phoneDigits?: number }
  ) => { success: boolean; error?: string } | Promise<{ success: boolean; error?: string }>;
  onUpdate: (
    category: CustomerMasterCategory,
    id: string,
    name: string,
    extra?: { code?: string; description?: string; countryId?: string; phoneCode?: string; phoneDigits?: number }
  ) => { success: boolean; error?: string } | Promise<{ success: boolean; error?: string }>;
  onDelete: (category: CustomerMasterCategory, id: string) => void | Promise<void>;
}

interface MasterCategoryConfig {
  id: CustomerMasterCategory;
  title: string;
  singular: string;
  placeholder: string;
  description: string;
  icon: typeof UserCheck;
  hasCode?: boolean;
  hasDescription?: boolean;
}

const CATEGORIES: MasterCategoryConfig[] = [
  {
    id: "designations",
    title: "Contact Designations",
    singular: "Designation",
    placeholder: "e.g. Managing Director, CEO, CTO",
    description: "Job titles and roles for customer contacts and stakeholder mapping",
    icon: UserCheck,
  },
  {
    id: "industries",
    title: "Industries",
    singular: "Industry",
    placeholder: "e.g. Information Technology, Healthcare, BFSI",
    description: "Industry verticals and business domains for client categorization",
    icon: Briefcase,
  },
  {
    id: "countries",
    title: "Countries",
    singular: "Country",
    placeholder: "e.g. India, United States, Germany",
    description: "Country list with ISO Alpha codes for client locations & billing",
    icon: Globe,
    hasCode: true,
  },
  {
    id: "cities",
    title: "Cities",
    singular: "City",
    placeholder: "e.g. Mumbai, Pune, Chicago, London",
    description: "Operational delivery locations linked directly to their parent Country",
    icon: MapPin,
    hasCode: true,
  },
  {
    id: "contactTypes",
    title: "Contact Types",
    singular: "Contact Type",
    placeholder: "e.g. Primary Contact, Billing Lead, Escalation",
    description: "Classification of stakeholder touchpoints and communications",
    icon: Tag,
    hasDescription: true,
  },
];

export function CustomerMastersSection({
  canManage = true,
  customerMasters,
  onAdd,
  onUpdate,
  onDelete,
}: CustomerMastersSectionProps) {
  // Active Category sub-tab (or "all" for side-by-side grid)
  const [activeCategory, setActiveCategory] = useState<CustomerMasterCategory | "all">("all");

  // Map country ID -> number of cities linked
  const citiesCountByCountry = useMemo(() => {
    const counts: Record<string, number> = {};
    for (const city of customerMasters.cities || []) {
      const cId = city.countryId || city.country;
      if (cId) {
        counts[cId] = (counts[cId] || 0) + 1;
      }
    }
    return counts;
  }, [customerMasters.cities]);

  return (
    <div className="space-y-6">
      {/* ── Sub-category selection bar ───────────────────────────────────── */}
      <div className="flex flex-wrap items-center gap-1.5 p-1 rounded-xl bg-muted/60 border border-border">
        <button
          onClick={() => setActiveCategory("all")}
          className={cn(
            "flex items-center gap-2 px-3.5 py-1.5 text-xs font-medium rounded-lg transition-all",
            activeCategory === "all"
              ? "bg-card text-foreground shadow-sm font-semibold border border-border/80"
              : "text-muted-foreground hover:text-foreground",
          )}
        >
          <Layers className="h-3.5 w-3.5" />
          <span>All Masters Overview</span>
        </button>

        {CATEGORIES.map((cat) => {
          const Icon = cat.icon;
          const count = customerMasters[cat.id]?.length || 0;
          return (
            <button
              key={cat.id}
              onClick={() => setActiveCategory(cat.id)}
              className={cn(
                "flex items-center gap-2 px-3.5 py-1.5 text-xs font-medium rounded-lg transition-all",
                activeCategory === cat.id
                  ? "bg-card text-foreground shadow-sm font-semibold border border-border/80"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              <Icon className="h-3.5 w-3.5" />
              <span>{cat.title}</span>
              <span
                className={cn(
                  "ml-0.5 rounded-full px-1.5 py-0.2 text-[10px]",
                  activeCategory === cat.id
                    ? "bg-primary/15 text-primary font-semibold"
                    : "bg-muted text-muted-foreground",
                )}
              >
                {count}
              </span>
            </button>
          );
        })}
      </div>

      {/* ── Cards Grid / Selected Category View ──────────────────────────── */}
      {activeCategory === "all" ? (
        <div className="grid grid-cols-1 gap-5 lg:grid-cols-2">
          {CATEGORIES.map((cat) => {
            if (cat.id === "cities") {
              return (
                <CityMastersCard
                  key="cities"
                  canManage={canManage}
                  cities={customerMasters.cities || []}
                  countries={customerMasters.countries || []}
                  onAddCity={(name, countryId, code) =>
                    onAdd("cities", name, { countryId, code })
                  }
                  onUpdateCity={(id, name, countryId, code) =>
                    onUpdate("cities", id, name, { countryId, code })
                  }
                  onDeleteCity={(id) => onDelete("cities", id)}
                  onSwitchToCountries={() => setActiveCategory("countries")}
                />
              );
            }

            return (
              <ReusableMasterCard
                key={cat.id}
                config={cat}
                canManage={canManage}
                items={customerMasters[cat.id] || []}
                citiesCountByCountry={cat.id === "countries" ? citiesCountByCountry : undefined}
                onAdd={(name, extra) => onAdd(cat.id, name, extra)}
                onUpdate={(id, name, extra) => onUpdate(cat.id, id, name, extra)}
                onDelete={(id) => onDelete(cat.id, id)}
              />
            );
          })}
        </div>
      ) : activeCategory === "cities" ? (
        <div className="max-w-4xl mx-auto">
          <CityMastersCard
            canManage={canManage}
            cities={customerMasters.cities || []}
            countries={customerMasters.countries || []}
            onAddCity={(name, countryId, code) =>
              onAdd("cities", name, { countryId, code })
            }
            onUpdateCity={(id, name, countryId, code) =>
              onUpdate("cities", id, name, { countryId, code })
            }
            onDeleteCity={(id) => onDelete("cities", id)}
            onSwitchToCountries={() => setActiveCategory("countries")}
            isExpandedView
          />
        </div>
      ) : (
        <div className="max-w-4xl mx-auto">
          {(() => {
            const cat = CATEGORIES.find((c) => c.id === activeCategory)!;
            return (
              <ReusableMasterCard
                config={cat}
                canManage={canManage}
                items={customerMasters[cat.id] || []}
                citiesCountByCountry={cat.id === "countries" ? citiesCountByCountry : undefined}
                onAdd={(name, extra) => onAdd(cat.id, name, extra)}
                onUpdate={(id, name, extra) => onUpdate(cat.id, id, name, extra)}
                onDelete={(id) => onDelete(cat.id, id)}
                isExpandedView
              />
            );
          })()}
        </div>
      )}
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// ─── Specialized City Masters Card (With Country Dependency) ────────────────
// ══════════════════════════════════════════════════════════════════════════════

interface CityMastersCardProps {
  canManage?: boolean;
  cities: SimpleMasterItem[];
  countries: SimpleMasterItem[];
  isExpandedView?: boolean;
  onAddCity: (name: string, countryId: string, code?: string) => { success: boolean; error?: string } | Promise<{ success: boolean; error?: string }>;
  onUpdateCity: (id: string, name: string, countryId: string, code?: string) => { success: boolean; error?: string } | Promise<{ success: boolean; error?: string }>;
  onDeleteCity: (id: string) => void | Promise<void>;
  onSwitchToCountries?: () => void;
}

function CityMastersCard({
  canManage = true,
  cities,
  countries,
  isExpandedView,
  onAddCity,
  onUpdateCity,
  onDeleteCity,
  onSwitchToCountries,
}: CityMastersCardProps) {
  // Add Form State
  const [cityName, setCityName] = useState("");
  const [cityCode, setCityCode] = useState("");
  const [selectedCountryId, setSelectedCountryId] = useState<string>("");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Filters State
  const [filterCountryId, setFilterCountryId] = useState<string>("all");
  const [searchQuery, setSearchQuery] = useState("");

  // Edit Modal State
  const [editingCity, setEditingCity] = useState<SimpleMasterItem | null>(null);
  const [editName, setEditName] = useState("");
  const [editCode, setEditCode] = useState("");
  const [editCountryId, setEditCountryId] = useState("");
  const [editError, setEditError] = useState<string | null>(null);

  // Delete State
  const [deletingId, setDeletingId] = useState<string | null>(null);

  // Quick lookup map: CountryId -> Country Name & Code
  const countryMap = useMemo(() => {
    const map = new Map<string, { name: string; code?: string }>();
    for (const c of countries) {
      map.set(c.id, { name: c.name, code: c.code });
    }
    return map;
  }, [countries]);

  // Set default selected country when countries load if none selected
  useMemo(() => {
    if (!selectedCountryId && countries.length > 0) {
      setSelectedCountryId(countries[0].id);
    }
  }, [countries, selectedCountryId]);

  // Filtered Cities list based on selected Country filter and Search query
  const filteredCities = useMemo(() => {
    return cities.filter((city) => {
      const cityCountryId = city.countryId || city.country || "";
      // Country filter
      if (filterCountryId !== "all" && cityCountryId !== filterCountryId) {
        return false;
      }
      // Search filter
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase();
        const cInfo = countryMap.get(cityCountryId);
        const countryName = cInfo?.name || city.countryName || "";
        const matchesName = city.name.toLowerCase().includes(q);
        const matchesCode = !!city.code && city.code.toLowerCase().includes(q);
        const matchesCountry = countryName.toLowerCase().includes(q);
        if (!matchesName && !matchesCode && !matchesCountry) {
          return false;
        }
      }
      return true;
    });
  }, [cities, filterCountryId, searchQuery, countryMap]);

  // Compute number of cities per country for dropdown stats
  const cityCountPerCountry = useMemo(() => {
    const map = new Map<string, number>();
    for (const city of cities) {
      const cId = city.countryId || city.country || "";
      if (cId) {
        map.set(cId, (map.get(cId) || 0) + 1);
      }
    }
    return map;
  }, [cities]);

  // Handle Add City
  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMsg(null);

    if (!selectedCountryId) {
      setErrorMsg("Please select a Country for this city.");
      return;
    }

    if (!cityName.trim()) {
      setErrorMsg("Please enter a city name.");
      return;
    }

    setIsSubmitting(true);
    try {
      const res = await onAddCity(cityName.trim(), selectedCountryId, cityCode.trim() || undefined);
      if (res.success) {
        setCityName("");
        setCityCode("");
        setErrorMsg(null);
      } else {
        setErrorMsg(res.error || "Failed to add city.");
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  // Open Edit Dialog
  const openEdit = (city: SimpleMasterItem) => {
    setEditingCity(city);
    setEditName(city.name);
    setEditCode(city.code || "");
    const currentCountryId = city.countryId || city.country || (countries.length > 0 ? countries[0].id : "");
    setEditCountryId(currentCountryId);
    setEditError(null);
  };

  // Submit Edit
  const handleEditSubmit = async () => {
    if (!editingCity) return;
    if (!editName.trim()) {
      setEditError("City name is required.");
      return;
    }
    if (!editCountryId) {
      setEditError("Please select a country.");
      return;
    }

    const res = await onUpdateCity(
      editingCity.id,
      editName.trim(),
      editCountryId,
      editCode.trim() || undefined,
    );

    if (res.success) {
      setEditingCity(null);
    } else {
      setEditError(res.error || "Failed to update city.");
    }
  };

  return (
    <div className="flex flex-col rounded-xl border border-border bg-card p-5 shadow-sm">
      {/* Header */}
      <div className="flex items-start justify-between pb-3.5 border-b border-border/70">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-500/10 text-emerald-600 dark:text-emerald-400">
            <MapPin className="h-4 w-4" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="text-sm font-semibold text-foreground">Cities</h3>
              <Badge variant="outline" className="text-[10px] bg-primary/5 text-primary border-primary/20">
                Country-Dependent
              </Badge>
            </div>
            <p className="text-[11px] text-muted-foreground">
              Operational delivery locations linked directly to their parent Country
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Badge variant="secondary" className="text-xs font-normal">
            {cities.length} Total
          </Badge>
        </div>
      </div>

      {/* Add Form (with Country dependency) */}
      {canManage && (
        <div className="mt-4">
          {countries.length === 0 ? (
            <div className="rounded-lg border border-amber-500/30 bg-amber-500/10 p-3 text-xs text-amber-800 dark:text-amber-300 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <AlertCircle className="h-4 w-4 shrink-0 text-amber-600 dark:text-amber-400" />
                <span>No countries configured yet. Cities require a parent country.</span>
              </div>
              {onSwitchToCountries && (
                <Button
                  size="sm"
                  variant="outline"
                  onClick={onSwitchToCountries}
                  className="h-7 text-xs border-amber-500/40 hover:bg-amber-500/20"
                >
                  Go to Countries
                </Button>
              )}
            </div>
          ) : (
            <form onSubmit={handleAdd} className="space-y-2.5">
              {errorMsg && (
                <div className="flex items-center gap-1.5 rounded-md border border-destructive/30 bg-destructive/10 px-2.5 py-1.5 text-xs text-destructive">
                  <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                  <span>{errorMsg}</span>
                </div>
              )}

              <div className="grid grid-cols-1 sm:grid-cols-12 gap-2 items-center">
                {/* 1. Country Selector (Primary Dependency) */}
                <div className="sm:col-span-4">
                  <Select value={selectedCountryId} onValueChange={setSelectedCountryId}>
                    <SelectTrigger className="h-8 text-xs bg-background">
                      <div className="flex items-center gap-1.5 truncate">
                        <Globe className="h-3.5 w-3.5 text-muted-foreground shrink-0" />
                        <SelectValue placeholder="Select Country *" />
                      </div>
                    </SelectTrigger>
                    <SelectContent>
                      {countries.map((c) => (
                        <SelectItem key={c.id} value={c.id} className="text-xs">
                          {c.name} {c.code ? `(${c.code})` : ""}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* 2. City Name */}
                <div className="sm:col-span-4">
                  <Input
                    placeholder="City name (e.g. Mumbai, Pune) *"
                    value={cityName}
                    onChange={(e) => setCityName(e.target.value)}
                    className="h-8 text-xs"
                  />
                </div>

                {/* 3. City Code (Optional) */}
                <div className="sm:col-span-2">
                  <Input
                    placeholder="Code (opt)"
                    value={cityCode}
                    onChange={(e) => setCityCode(e.target.value)}
                    className="h-8 text-xs uppercase"
                    maxLength={10}
                  />
                </div>

                {/* 4. Add Button */}
                <div className="sm:col-span-2">
                  <Button
                    type="submit"
                    size="sm"
                    disabled={isSubmitting}
                    className="h-8 text-xs gap-1 w-full shrink-0"
                  >
                    <Plus className="h-3.5 w-3.5" />
                    Add City
                  </Button>
                </div>
              </div>
            </form>
          )}
        </div>
      )}

      {/* Filter by Country & Search Bar */}
      <div className="mt-4 flex flex-col flex-1 space-y-2.5 pt-3 border-t border-border/60">
        <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-2">
          {/* Country filter dropdown */}
          <div className="flex items-center gap-2">
            <span className="text-xs font-medium text-muted-foreground shrink-0 flex items-center gap-1">
              <Filter className="h-3 w-3" />
              Country:
            </span>
            <Select value={filterCountryId} onValueChange={setFilterCountryId}>
              <SelectTrigger className="h-7 w-48 text-[11px] bg-muted/30">
                <SelectValue placeholder="All Countries" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all" className="text-xs">
                  All Countries ({cities.length})
                </SelectItem>
                {countries.map((c) => {
                  const count = cityCountPerCountry.get(c.id) || 0;
                  return (
                    <SelectItem key={c.id} value={c.id} className="text-xs">
                      {c.name} ({count})
                    </SelectItem>
                  );
                })}
              </SelectContent>
            </Select>
          </div>

          {/* Search box */}
          <div className="relative w-full sm:w-48">
            <Search className="absolute left-2 top-1/2 -translate-y-1/2 h-3 w-3 text-muted-foreground" />
            <Input
              placeholder="Search cities or countries..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="h-7 pl-7 text-[11px] bg-muted/20"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery("")}
                className="absolute right-1.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
              >
                <X className="h-3 w-3" />
              </button>
            )}
          </div>
        </div>

        {/* Cities List */}
        {filteredCities.length === 0 ? (
          <div className="rounded-lg border border-dashed border-border/80 py-6 text-center text-xs text-muted-foreground">
            {searchQuery || filterCountryId !== "all"
              ? "No matching cities found for the current filters."
              : "No cities configured yet."}
          </div>
        ) : (
          <div
            className={cn(
              "divide-y divide-border/60 rounded-lg border border-border/80 overflow-y-auto",
              isExpandedView ? "max-h-96" : "max-h-64",
            )}
          >
            {filteredCities.map((city) => {
              const cityCountryId = city.countryId || city.country || "";
              const cInfo = countryMap.get(cityCountryId);
              const countryName = cInfo?.name || city.countryName || "Unassigned Country";
              const countryCode = cInfo?.code;

              return (
                <div
                  key={city.id}
                  className="group flex items-center justify-between gap-3 px-3 py-2 text-xs hover:bg-muted/40 transition-colors"
                >
                  <div className="min-w-0 flex-1 flex items-center gap-2">
                    <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 shrink-0" />
                    <span className="font-medium text-foreground truncate">{city.name}</span>

                    {city.code && (
                      <Badge
                        variant="outline"
                        className="text-[10px] px-1.5 py-0 font-mono text-muted-foreground shrink-0"
                      >
                        {city.code}
                      </Badge>
                    )}

                    {/* Country Dependency Badge */}
                    <Badge
                      variant="secondary"
                      className="text-[10px] px-2 py-0 bg-primary/10 text-primary border border-primary/20 flex items-center gap-1 shrink-0"
                    >
                      <Globe className="h-2.5 w-2.5 shrink-0" />
                      <span>{countryName}</span>
                      {countryCode && <span className="opacity-75">[{countryCode}]</span>}
                    </Badge>
                  </div>

                  {canManage && (
                    <div className="flex items-center gap-1 opacity-80 group-hover:opacity-100 transition-opacity">
                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-6 w-6 text-muted-foreground hover:text-foreground"
                        onClick={() => openEdit(city)}
                        title="Edit city"
                      >
                        <Pencil className="h-3 w-3" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-6 w-6 text-muted-foreground hover:text-destructive"
                        onClick={() => setDeletingId(city.id)}
                        title="Delete city"
                      >
                        <Trash2 className="h-3 w-3" />
                      </Button>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Edit City Modal (allows updating country association) */}
      <Dialog open={!!editingCity} onOpenChange={(open) => !open && setEditingCity(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold">Edit City</DialogTitle>
            <DialogDescription className="text-xs">
              Modify the city name, code, or reassign its parent country.
            </DialogDescription>
          </DialogHeader>

          {editError && (
            <div className="flex items-center gap-1.5 rounded-md border border-destructive/30 bg-destructive/10 px-2.5 py-1.5 text-xs text-destructive">
              <AlertCircle className="h-3.5 w-3.5 shrink-0" />
              <span>{editError}</span>
            </div>
          )}

          <div className="space-y-3 py-2">
            {/* Country Selector in Edit */}
            <div className="space-y-1">
              <span className="text-xs font-medium text-foreground">Parent Country *</span>
              <Select value={editCountryId} onValueChange={setEditCountryId}>
                <SelectTrigger className="h-8 text-xs bg-background">
                  <div className="flex items-center gap-1.5 truncate">
                    <Globe className="h-3.5 w-3.5 text-muted-foreground shrink-0" />
                    <SelectValue placeholder="Select Country" />
                  </div>
                </SelectTrigger>
                <SelectContent>
                  {countries.map((c) => (
                    <SelectItem key={c.id} value={c.id} className="text-xs">
                      {c.name} {c.code ? `(${c.code})` : ""}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* City Name */}
            <div className="space-y-1">
              <span className="text-xs font-medium text-foreground">City Name *</span>
              <Input
                value={editName}
                onChange={(e) => setEditName(e.target.value)}
                className="h-8 text-xs"
                placeholder="e.g. Mumbai, Pune"
              />
            </div>

            {/* City Code */}
            <div className="space-y-1">
              <span className="text-xs font-medium text-foreground">City Code (Optional)</span>
              <Input
                value={editCode}
                onChange={(e) => setEditCode(e.target.value)}
                className="h-8 text-xs uppercase"
                placeholder="e.g. BOM, PUN"
                maxLength={10}
              />
            </div>
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="text-xs h-8"
              onClick={() => setEditingCity(null)}
            >
              Cancel
            </Button>
            <Button type="button" size="sm" className="text-xs h-8" onClick={handleEditSubmit}>
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Alert Dialog */}
      <AlertDialog open={!!deletingId} onOpenChange={(open) => !open && setDeletingId(null)}>
        <AlertDialogContent className="sm:max-w-md">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-sm font-semibold">Delete City</AlertDialogTitle>
            <AlertDialogDescription className="text-xs">
              Are you sure you want to delete this city? This operational location will be removed from masters.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="text-xs h-8">Cancel</AlertDialogCancel>
            <AlertDialogAction
              className="text-xs h-8 bg-destructive text-destructive-foreground hover:bg-destructive/90"
              onClick={async () => {
                if (deletingId) {
                  await onDeleteCity(deletingId);
                  setDeletingId(null);
                }
              }}
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// ─── Reusable Master Card Component (For Designations, Industries, Countries, Contact Types)
// ══════════════════════════════════════════════════════════════════════════════

interface ReusableMasterCardProps {
  canManage?: boolean;
  config: MasterCategoryConfig;
  items: SimpleMasterItem[];
  citiesCountByCountry?: Record<string, number>;
  isExpandedView?: boolean;
  onAdd: (name: string, extra?: { code?: string; description?: string }) => { success: boolean; error?: string } | Promise<{ success: boolean; error?: string }>;
  onUpdate: (id: string, name: string, extra?: { code?: string; description?: string }) => { success: boolean; error?: string } | Promise<{ success: boolean; error?: string }>;
  onDelete: (id: string) => void | Promise<void>;
}

function ReusableMasterCard({
  canManage = true,
  config,
  items,
  citiesCountByCountry,
  isExpandedView,
  onAdd,
  onUpdate,
  onDelete,
}: ReusableMasterCardProps) {
  const Icon = config.icon;
  const [inputName, setInputName] = useState("");
  const [inputCode, setInputCode] = useState("");
  const [inputDescription, setInputDescription] = useState("");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");

  // Edit modal state
  const [editingItem, setEditingItem] = useState<SimpleMasterItem | null>(null);
  const [editName, setEditName] = useState("");
  const [editCode, setEditCode] = useState("");
  const [editDescription, setEditDescription] = useState("");
  const [editError, setEditError] = useState<string | null>(null);

  // Delete dialog state
  const [deletingId, setDeletingId] = useState<string | null>(null);

  // Filtered list
  const filteredItems = useMemo(() => {
    if (!searchQuery.trim()) return items;
    const q = searchQuery.toLowerCase();
    return items.filter(
      (item) =>
        item.name.toLowerCase().includes(q) ||
        (item.code && item.code.toLowerCase().includes(q)) ||
        (item.description && item.description.toLowerCase().includes(q)),
    );
  }, [items, searchQuery]);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMsg(null);

    if (!inputName.trim()) {
      setErrorMsg(`Please enter a ${config.singular.toLowerCase()} name.`);
      return;
    }

    const res = await onAdd(inputName.trim(), {
      code: inputCode.trim() || undefined,
      description: inputDescription.trim() || undefined,
    });

    if (res.success) {
      setInputName("");
      setInputCode("");
      setInputDescription("");
      setErrorMsg(null);
    } else {
      setErrorMsg(res.error || "Failed to add item.");
    }
  };

  const openEdit = (item: SimpleMasterItem) => {
    setEditingItem(item);
    setEditName(item.name);
    setEditCode(item.code || "");
    setEditDescription(item.description || "");
    setEditError(null);
  };

  const handleEditSubmit = async () => {
    if (!editingItem) return;
    if (!editName.trim()) {
      setEditError("Name is required.");
      return;
    }

    const res = await onUpdate(editingItem.id, editName.trim(), {
      code: editCode.trim() || undefined,
      description: editDescription.trim() || undefined,
    });

    if (res.success) {
      setEditingItem(null);
    } else {
      setEditError(res.error || "Failed to update item.");
    }
  };

  return (
    <div className="flex flex-col rounded-xl border border-border bg-card p-5 shadow-sm">
      {/* Header */}
      <div className="flex items-start justify-between pb-3.5 border-b border-border/70">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary">
            <Icon className="h-4 w-4" />
          </div>
          <div>
            <h3 className="text-sm font-semibold text-foreground">{config.title}</h3>
            <p className="text-[11px] text-muted-foreground">{config.description}</p>
          </div>
        </div>
        <Badge variant="secondary" className="text-xs font-normal">
          {items.length} Total
        </Badge>
      </div>

      {/* Add Form */}
      {canManage && (
        <form onSubmit={handleAdd} className="mt-4 space-y-2.5">
          {errorMsg && (
            <div className="flex items-center gap-1.5 rounded-md border border-destructive/30 bg-destructive/10 px-2.5 py-1.5 text-xs text-destructive">
              <AlertCircle className="h-3.5 w-3.5 shrink-0" />
              <span>{errorMsg}</span>
            </div>
          )}

          <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
            <div className="flex-1">
              <Input
                placeholder={config.placeholder}
                value={inputName}
                onChange={(e) => setInputName(e.target.value)}
                className="h-8 text-xs"
              />
            </div>

            {config.hasCode && (
              <div className="w-full sm:w-28">
                <Input
                  placeholder="Code (opt)"
                  value={inputCode}
                  onChange={(e) => setInputCode(e.target.value)}
                  className="h-8 text-xs uppercase"
                  maxLength={8}
                />
              </div>
            )}

            <Button type="submit" size="sm" className="h-8 text-xs gap-1 shrink-0">
              <Plus className="h-3.5 w-3.5" />
              Add {config.singular}
            </Button>
          </div>

          {config.hasDescription && (
            <Input
              placeholder="Optional description / notes..."
              value={inputDescription}
              onChange={(e) => setInputDescription(e.target.value)}
              className="h-7 text-xs text-muted-foreground"
            />
          )}
        </form>
      )}

      {/* Search & Items List */}
      <div className="mt-4 flex flex-col flex-1 space-y-2.5 pt-3 border-t border-border/60">
        <div className="flex items-center justify-between gap-2">
          <span className="text-xs font-medium text-muted-foreground">
            Existing {config.title} ({filteredItems.length})
          </span>
          <div className="relative w-40 sm:w-48">
            <Search className="absolute left-2 top-1/2 -translate-y-1/2 h-3 w-3 text-muted-foreground" />
            <Input
              placeholder={`Filter ${config.title.toLowerCase()}...`}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="h-7 pl-7 text-[11px] bg-muted/20"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery("")}
                className="absolute right-1.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
              >
                <X className="h-3 w-3" />
              </button>
            )}
          </div>
        </div>

        {filteredItems.length === 0 ? (
          <div className="rounded-lg border border-dashed border-border/80 py-6 text-center text-xs text-muted-foreground">
            {searchQuery ? "No matching master items found" : `No ${config.title.toLowerCase()} configured yet.`}
          </div>
        ) : (
          <div
            className={cn(
              "divide-y divide-border/60 rounded-lg border border-border/80 overflow-y-auto",
              isExpandedView ? "max-h-96" : "max-h-64",
            )}
          >
            {filteredItems.map((item) => {
              const linkedCityCount = citiesCountByCountry ? citiesCountByCountry[item.id] || 0 : undefined;

              return (
                <div
                  key={item.id}
                  className="group flex items-center justify-between gap-3 px-3 py-2 text-xs hover:bg-muted/40 transition-colors"
                >
                  <div className="min-w-0 flex-1 flex items-center gap-2">
                    <span className="h-1.5 w-1.5 rounded-full bg-primary/60 shrink-0" />
                    <span className="font-medium text-foreground truncate">{item.name}</span>

                    {item.code && (
                      <Badge variant="outline" className="text-[10px] px-1.5 py-0 font-mono text-muted-foreground">
                        {item.code}
                      </Badge>
                    )}

                    {/* Show linked city count for countries */}
                    {linkedCityCount !== undefined && linkedCityCount > 0 && (
                      <Badge
                        variant="secondary"
                        className="text-[10px] px-1.5 py-0 bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20"
                      >
                        {linkedCityCount} {linkedCityCount === 1 ? "City" : "Cities"}
                      </Badge>
                    )}

                    {item.description && (
                      <span className="text-[11px] text-muted-foreground truncate hidden sm:inline">
                        — {item.description}
                      </span>
                    )}
                  </div>

                  {canManage && (
                    <div className="flex items-center gap-1 opacity-80 group-hover:opacity-100 transition-opacity">
                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-6 w-6 text-muted-foreground hover:text-foreground"
                        onClick={() => openEdit(item)}
                        title="Edit item"
                      >
                        <Pencil className="h-3 w-3" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-6 w-6 text-muted-foreground hover:text-destructive"
                        onClick={() => setDeletingId(item.id)}
                        title="Delete item"
                      >
                        <Trash2 className="h-3 w-3" />
                      </Button>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Edit Modal */}
      <Dialog open={!!editingItem} onOpenChange={(open) => !open && setEditingItem(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-sm font-semibold">Edit {config.singular}</DialogTitle>
            <DialogDescription className="text-xs">
              Modify the master name and parameters.
            </DialogDescription>
          </DialogHeader>

          {editError && (
            <div className="flex items-center gap-1.5 rounded-md border border-destructive/30 bg-destructive/10 px-2.5 py-1.5 text-xs text-destructive">
              <AlertCircle className="h-3.5 w-3.5 shrink-0" />
              <span>{editError}</span>
            </div>
          )}

          <div className="space-y-3 py-2">
            <div className="space-y-1">
              <span className="text-xs font-medium text-foreground">{config.singular} Name</span>
              <Input
                value={editName}
                onChange={(e) => setEditName(e.target.value)}
                className="h-8 text-xs"
              />
            </div>

            {config.hasCode && (
              <div className="space-y-1">
                <span className="text-xs font-medium text-foreground">Code (Optional)</span>
                <Input
                  value={editCode}
                  onChange={(e) => setEditCode(e.target.value)}
                  className="h-8 text-xs uppercase"
                  maxLength={8}
                />
              </div>
            )}

            {config.hasDescription && (
              <div className="space-y-1">
                <span className="text-xs font-medium text-foreground">Description (Optional)</span>
                <Input
                  value={editDescription}
                  onChange={(e) => setEditDescription(e.target.value)}
                  className="h-8 text-xs"
                />
              </div>
            )}
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="text-xs h-8"
              onClick={() => setEditingItem(null)}
            >
              Cancel
            </Button>
            <Button type="button" size="sm" className="text-xs h-8" onClick={handleEditSubmit}>
              Save Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Alert Dialog */}
      <AlertDialog open={!!deletingId} onOpenChange={(open) => !open && setDeletingId(null)}>
        <AlertDialogContent className="sm:max-w-md">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-sm font-semibold">Delete {config.singular}</AlertDialogTitle>
            <AlertDialogDescription className="text-xs">
              Are you sure you want to delete this master item?
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="text-xs h-8">Cancel</AlertDialogCancel>
            <AlertDialogAction
              className="text-xs h-8 bg-destructive text-destructive-foreground hover:bg-destructive/90"
              onClick={async () => {
                if (deletingId) {
                  await onDelete(deletingId);
                  setDeletingId(null);
                }
              }}
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
