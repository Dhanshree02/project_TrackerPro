import { useEffect, useMemo, useState } from "react";
import {
  Search,
  ArrowRight,
  X,
  Building2,
  Plus,
  ChevronRight,
  Check,
  Eye,
  FileText,
  UploadCloud,
  CheckCircle2,
  AlertCircle,
  MapPin,
  Users,
  ShieldCheck,
} from "lucide-react";
import { toast } from "sonner";
import { format } from "date-fns";
import { useRoleContext } from "@/lib/role-context";
import { type Client, type ClientSubVenture } from "@/lib/mock-data";
import {
  createClient,
  updateClient,
  type CreateClientInput,
} from "@/lib/api/clients";
import { fetchCities, fetchCountries, type CatalogOption, type CityCatalogOption } from "@/lib/api/catalogs";
import { Modal } from "@/routes/projects.index";
import { KycDocPreviewModal } from "@/components/kyc-preview-modal";
import { Field } from "@/components/form-row";
import { dhStore } from "@/lib/dh-store";
import { cn } from "@/lib/utils";
import {
  FIELD_MAX,
  emailError,
  phoneError,
  toEmailInput,
  toTenDigitPhone,
} from "@/lib/form-validation";

export interface ContactEntry {
  name: string;
  email: string;
  phone: string;
  designation: string;
  contactType?: string;
}

export interface NewClientState {
  clientName: string;
  subVentureName: string;
  customerId: string;
  engagementManager: string;
  salesManager: string;
  phoneNumber: string;
  city: string;
  country: string;
  industry: string;
  businessType: string;
  createdAt: string;
  createdBy: string;
  kycFile: File | null;
  contacts: ContactEntry[];
  notes: string;
}

const inputCls =
  "h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring transition-colors";

const Row = ({ label, v }: { label: string; v: string }) => (
  <div className="flex flex-col">
    <dt className="text-[11px] font-medium text-muted-foreground">{label}</dt>
    <dd className="font-semibold text-foreground text-xs">{v || "—"}</dd>
  </div>
);

export function EnhancedNewClientModal({
  apiClients,
  onClose,
  onCreated,
}: {
  apiClients: Client[] | null;
  onClose: () => void;
  onCreated: () => void;
}) {
  const { user } = useRoleContext();
  const [step, setStep] = useState(1);
  const [submitting, setSubmitting] = useState(false);
  const [touched, setTouched] = useState<Record<string, boolean>>({});
  const [isDragging, setIsDragging] = useState(false);

  const markTouched = (k: string) => setTouched((p) => ({ ...p, [k]: true }));

  const existingClients = useMemo(() => apiClients ?? [], [apiClients]);
  const [tkSearch, setTkSearch] = useState("");
  const [tkDropOpen, setTkDropOpen] = useState(false);
  const [selectedExisting, setSelectedExisting] = useState<(typeof existingClients)[0] | null>(
    null,
  );

  const [svSearch, setSvSearch] = useState("");
  const [svDropOpen, setSvDropOpen] = useState(false);
  const [svAlreadyExists, setSvAlreadyExists] = useState(false);

  const [countries, setCountries] = useState<CatalogOption[]>([]);
  const [cities, setCities] = useState<CityCatalogOption[]>([]);

  const filteredTk = existingClients.filter(
    (c) => tkSearch.trim() === "" || c.name.toLowerCase().includes(tkSearch.toLowerCase()),
  );

  const [s, setS] = useState<NewClientState>(() => ({
    clientName: "",
    subVentureName: "",
    customerId: "C" + String((apiClients?.length ?? 0) + 1).padStart(3, "0"),
    engagementManager: "",
    salesManager: "",
    phoneNumber: "",
    city: "",
    country: "",
    industry: "",
    businessType: "",
    createdAt: new Date().toISOString(),
    createdBy: user?.name ?? "Unknown",
    kycFile: null,
    contacts: [{ name: "", email: "", phone: "", designation: "", contactType: "" }],
    notes: "",
  }));
  const [previewKyc, setPreviewKyc] = useState(false);

  useEffect(() => {
    let cancelled = false;
    void fetchCountries()
      .then((rows) => {
        if (!cancelled) setCountries(rows);
      })
      .catch(() => {
        if (!cancelled) setCountries([]);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const selectedCountryId = countries.find((c) => c.name === s.country)?.id;

  useEffect(() => {
    if (!selectedCountryId) {
      setCities([]);
      return;
    }
    let cancelled = false;
    void fetchCities(selectedCountryId)
      .then((rows) => {
        if (!cancelled) setCities(rows);
      })
      .catch(() => {
        if (!cancelled) setCities([]);
      });
    return () => {
      cancelled = true;
    };
  }, [selectedCountryId]);

  const u = (k: keyof Omit<NewClientState, "contacts" | "kycFile">, v: string) => {
    setS((p) => ({ ...p, [k]: v }));
    markTouched(k);
  };

  const MAX_CONTACTS = 4;

  const addContact = () =>
    setS((p) =>
      p.contacts.length >= MAX_CONTACTS
        ? p
        : {
            ...p,
            contacts: [
              ...p.contacts,
              { name: "", email: "", phone: "", designation: "", contactType: "" },
            ],
          },
    );

  const removeContact = (idx: number) =>
    setS((p) => ({ ...p, contacts: p.contacts.filter((_, i) => i !== idx) }));

  const updateContact = (idx: number, field: keyof ContactEntry, val: string) => {
    setS((p) => ({
      ...p,
      contacts: p.contacts.map((c, i) => (i === idx ? { ...c, [field]: val } : c)),
    }));
    markTouched(`contact_${field}_${idx}`);
  };

  const selectedCountryObj = countries.find((c) => c.name === s.country);
  const countryDialCode = selectedCountryObj?.phoneCode || "+91";
  const countryPhoneDigits = selectedCountryObj?.phoneDigits || 10;

  const namesEq = (a: string, b: string) => a.trim().toLowerCase() === b.trim().toLowerCase();
  const matchingExistingClient =
    selectedExisting ??
    existingClients.find((c) => namesEq(c.name, s.clientName || tkSearch)) ??
    null;
  const duplicatePairExists = Boolean(
    matchingExistingClient &&
      s.subVentureName.trim() &&
      (matchingExistingClient.subVentures ?? []).some((sv) => namesEq(sv.name, s.subVentureName)),
  );

  const getClientNameError = () =>
    !s.clientName.trim() && !selectedExisting ? "TK Customer / Partner Name is required" : null;
  const getSubVentureError = () => (!s.subVentureName.trim() ? "End Customer / Sub-venture Name is required" : null);
  const getDuplicatePairError = () =>
    duplicatePairExists ? "Client and sub-venture already exist" : null;
  const getEngagementManagerError = () => (!s.engagementManager.trim() && !selectedExisting ? "Engagement Manager is required" : null);
  const getCountryError = () => (!s.country.trim() && !selectedExisting ? "Country is required" : null);
  const getCityError = () => (!s.city.trim() && !selectedExisting ? "City is required" : null);
  const getPhoneError = () => {
    if (selectedExisting) return null;
    if (!s.phoneNumber.trim()) return "Group SPOC Contact is required";
    const clean = s.phoneNumber.replace(/\D/g, "");
    if (clean.length !== countryPhoneDigits) {
      return `Must be exactly ${countryPhoneDigits} digits for ${s.country || "selected country"}`;
    }
    return null;
  };
  const getIndustryError = () => (!s.industry.trim() && !selectedExisting ? "Industry is required" : null);

  const getStep1Error = (): string | null => {
    return (
      getClientNameError() ||
      getSubVentureError() ||
      getDuplicatePairError() ||
      getIndustryError() ||
      getEngagementManagerError() ||
      getCountryError() ||
      getCityError() ||
      getPhoneError()
    );
  };

  const getStep2Error = (): string | null => {
    for (let i = 0; i < s.contacts.length; i++) {
      const c = s.contacts[i];
      const n = s.contacts.length > 1 ? ` (Contact ${i + 1})` : "";
      if (!c.name.trim()) return `Contact Name${n} is required`;
      if (!c.contactType?.trim()) return `Contact Type${n} is required`;
      const mailErr = emailError(c.email, true);
      if (mailErr) return `Contact Email${n} — ${mailErr}`;
      const phErr = phoneError(c.phone, true);
      if (phErr) return `Contact Phone${n} — ${phErr}`;
      if (!c.designation.trim()) return `Designation${n} is required`;
    }
    if (!s.kycFile) return "KYC Document is required";
    return null;
  };

  const handleNext = () => {
    if (step === 1) {
      setTouched((prev) => ({
        ...prev,
        clientName: true,
        subVentureName: true,
        industry: true,
        engagementManager: true,
        country: true,
        city: true,
        phoneNumber: true,
      }));
      const err = getStep1Error();
      if (err) {
        toast.error(err);
        return;
      }
    }
    if (step === 2) {
      setTouched((prev) => {
        const next = { ...prev, kycFile: true };
        s.contacts.forEach((_, idx) => {
          next[`contact_name_${idx}`] = true;
          next[`contact_type_${idx}`] = true;
          next[`contact_email_${idx}`] = true;
          next[`contact_phone_${idx}`] = true;
          next[`contact_designation_${idx}`] = true;
        });
        return next;
      });
      const err = getStep2Error();
      if (err) {
        toast.error(err);
        return;
      }
    }
    setStep((prev) => prev + 1);
  };

  const readOnlyCls = cn(inputCls, "bg-muted/60 text-muted-foreground cursor-not-allowed");

  const isApiError = (err: unknown): err is Error & { status?: number } =>
    err instanceof Error && "status" in err;
  const isSessionError = (err: unknown): boolean =>
    err instanceof Error && /not authenticated|unauthorized/i.test(err.message);

  const buildNewClientPayload = () => {
    const validContacts = s.contacts.filter((c) => c.name.trim() && c.email.trim());
    const primary = validContacts[0] ?? s.contacts[0];
    const name = (s.clientName || s.subVentureName).trim();
    const subVentureName = s.subVentureName?.trim() || null;
    const noteText = s.notes?.trim() || undefined;
    const subVentures: ClientSubVenture[] = subVentureName
      ? [{ name: subVentureName, contacts: validContacts, notes: noteText }]
      : [];
    return {
      api: {
        name,
        industry: (s.industry || "Other").trim(),
        clientType: "NEW" as const,
        contactEmail: primary?.email?.trim() || null,
        contactName: primary?.name?.trim() || null,
        contactPhone: primary?.phone?.trim() || s.phoneNumber?.trim() || null,
        contactDesignation: primary?.designation?.trim() || null,
        contactType: primary?.contactType || "Primary",
        city: s.city?.trim() || null,
        country: s.country?.trim() || null,
        businessType: s.businessType?.trim() || null,
        notes: null,
        kycDocumentName: s.kycFile?.name || null,
        engagementManager: s.engagementManager?.trim() || null,
        salesManager: s.salesManager?.trim() || null,
        subVentures,
        contacts: validContacts.map((c) => ({
          name: c.name.trim(),
          email: c.email.trim(),
          phone: c.phone.trim() || null,
          designation: c.designation.trim() || null,
          contactType: c.contactType || "Primary",
        })),
      } satisfies CreateClientInput,
      store: {
        name,
        industry: s.industry || "Other",
        contact: primary?.email ?? "",
        contactName: primary?.name ?? "",
        contactPhone: primary?.phone ?? "",
        contactDesignation: primary?.designation ?? "",
        contactType: primary?.contactType || "Primary",
        city: s.city,
        country: s.country,
        businessType: s.businessType,
        notes: undefined,
        kycDocumentName: s.kycFile?.name || undefined,
        contacts: validContacts.length > 0 ? validContacts : undefined,
        engagementManager: s.engagementManager,
        salesManager: s.salesManager,
        subVentures,
      },
    };
  };

  const submit = async () => {
    setSubmitting(true);
    try {
      const { api, store } = buildNewClientPayload();

      if (duplicatePairExists && matchingExistingClient) {
        toast.error("Client and sub-venture already exist", {
          description: `${s.subVentureName.trim()} is already under ${matchingExistingClient.name}.`,
        });
        return;
      }

      if (selectedExisting) {

        const isApiClient = apiClients?.some((c) => c.id === selectedExisting.id) ?? false;
        if (isApiClient) {
          try {
            await updateClient(selectedExisting.id, {
              subVentures: [
                ...(selectedExisting.subVentures ?? []),
                {
                  name: s.subVentureName.trim(),
                  contacts: store.contacts ?? [],
                  notes: s.notes?.trim() || undefined,
                },
              ],
            });
            toast.success("Sub-venture added", {
              description: `${s.subVentureName} added under ${selectedExisting.name} in the database.`,
            });
            onCreated();
            return;
          } catch (err) {
            if (isSessionError(err)) {
              toast.error("Your session has expired. Please sign in again.");
              return;
            }
            if (isApiError(err)) {
              toast.error(err.message || "Failed to save the sub-venture.");
              return;
            }
            dhStore.addSubVenture(selectedExisting.id, s.subVentureName.trim(), store.contacts, s.notes);
            toast.warning("Backend unreachable — sub-venture saved locally", {
              description: `${s.subVentureName} added under ${selectedExisting.name} in your local directory.`,
            });
            onCreated();
            return;
          }
        }

        dhStore.addSubVenture(selectedExisting.id, s.subVentureName.trim(), store.contacts, s.notes);
        toast.success("Sub-venture added", {
          description: `${s.subVentureName} added under ${selectedExisting.name}.`,
        });
        onCreated();
        return;
      }

      try {
        await createClient(api);
        toast.success("Customer onboarded", {
          description: `${api.name} successfully registered in the database.`,
        });
      } catch (err) {
        if (isSessionError(err)) {
          toast.error("Your session has expired. Please sign in again.");
          return;
        }
        if (isApiError(err)) {
          toast.error(err.message || "Failed to save the client.");
          return;
        }
        dhStore.addClient(store);
        toast.warning("Backend unreachable — client saved locally", {
          description: `${store.name} added to your local directory.`,
        });
      }
      onCreated();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Something went wrong while saving.");
    } finally {
      setSubmitting(false);
    }
  };

  const stepProgress = step === 1 ? "w-1/3" : step === 2 ? "w-2/3" : "w-full";

  return (
    <>
    <Modal title="New Customer Onboarding" onClose={onClose} wide draggable>
      {/* Visual Stepper */}
      <div className="mb-6">
        <div className="relative mb-3 h-1.5 w-full overflow-hidden rounded-full bg-muted">
          <div
            className={cn(
              "h-full bg-gradient-to-r from-primary via-info to-primary transition-all duration-300 ease-out",
              stepProgress,
            )}
          />
        </div>

        <div className="grid grid-cols-3 gap-2 text-xs">
          {[
            {
              n: 1,
              title: "Company Profile",
              desc: "Entity, Leadership & Location",
              icon: Building2,
            },
            {
              n: 2,
              title: "SPOCs & KYC",
              desc: "Contacts & Verification Document",
              icon: Users,
            },
            {
              n: 3,
              title: "Review & Submit",
              desc: "Verify Details & Confirm",
              icon: ShieldCheck,
            },
          ].map(({ n, title, desc, icon: Icon }) => {
            const active = step === n;
            const done = step > n;
            return (
              <button
                key={n}
                type="button"
                onClick={() => {
                  if (done) setStep(n);
                }}
                disabled={!done && !active}
                className={cn(
                  "flex items-start gap-2.5 rounded-lg border p-2.5 text-left transition-all",
                  active
                    ? "border-primary/50 bg-primary/5 shadow-2xs"
                    : done
                      ? "border-border bg-card hover:bg-accent/40 cursor-pointer"
                      : "border-border/50 bg-muted/20 opacity-60 cursor-not-allowed",
                )}
              >
                <div
                  className={cn(
                    "flex h-7 w-7 shrink-0 items-center justify-center rounded-md border text-xs font-semibold transition-colors",
                    done
                      ? "border-success bg-success text-success-foreground"
                      : active
                        ? "border-primary bg-primary text-primary-foreground"
                        : "border-border bg-muted text-muted-foreground",
                  )}
                >
                  {done ? <Check className="h-3.5 w-3.5" /> : <Icon className="h-3.5 w-3.5" />}
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center justify-between">
                    <span
                      className={cn(
                        "text-xs font-semibold truncate",
                        active ? "text-foreground" : "text-muted-foreground",
                      )}
                    >
                      {title}
                    </span>
                    <span className="text-[10px] font-mono text-muted-foreground">Step {n}/3</span>
                  </div>
                  <p className="truncate text-[11px] text-muted-foreground hidden sm:block">{desc}</p>
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* STEP 1: Company Profile */}
      {step === 1 && (
        <div className="space-y-4">
          <div className="rounded-lg border border-border bg-card p-3.5 shadow-2xs space-y-3">
            <div className="flex items-center justify-between border-b border-border/70 pb-2">
              <div className="flex items-center gap-2">
                <Building2 className="h-4 w-4 text-primary" />
                <h4 className="text-xs font-semibold text-foreground uppercase tracking-wide">
                  Organization Profile
                </h4>
              </div>
              <span className="text-[10px] font-medium text-muted-foreground">
                <span className="text-destructive">*</span> Required fields
              </span>
            </div>

            <div>
              <label className="mb-1 block text-xs font-medium text-muted-foreground">
                TK Customer / Partner Name <span className="text-destructive">*</span>
              </label>
              <div className="relative">
                <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <input
                  className={cn(
                    inputCls,
                    "pl-8 pr-8",
                    touched.clientName && getClientNameError() && "border-destructive focus-visible:ring-destructive",
                    touched.clientName && !getClientNameError() && s.clientName && "border-success/60",
                  )}
                  placeholder="Search existing TK customers or type a new company name…"
                  maxLength={FIELD_MAX.clientName}
                  value={tkSearch}
                  onFocus={() => setTkDropOpen(true)}
                  onChange={(e) => {
                    const filtered = e.target.value
                      .replace(/[^a-zA-Z\s-']/g, "")
                      .slice(0, FIELD_MAX.clientName);
                    setTkSearch(filtered);
                    setTkDropOpen(true);
                    markTouched("clientName");

                    if (selectedExisting && filtered !== selectedExisting.name) {
                      setSelectedExisting(null);
                      setSvSearch("");
                      setSvDropOpen(false);
                      setSvAlreadyExists(false);
                      setS((p) => ({
                        ...p,
                        clientName: filtered,
                        subVentureName: "",
                        engagementManager: "",
                        salesManager: "",
                        phoneNumber: "",
                        city: "",
                        country: "",
                        industry: "",
                        businessType: "",
                        customerId: "C" + String((apiClients?.length ?? 0) + 1).padStart(3, "0"),
                      }));
                    } else {
                      setS((p) => ({ ...p, clientName: filtered }));
                    }
                  }}
                  onBlur={() => {
                    markTouched("clientName");
                    setTimeout(() => setTkDropOpen(false), 150);
                  }}
                />
                {selectedExisting && (
                  <button
                    type="button"
                    className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground cursor-pointer"
                    onClick={() => {
                      setSelectedExisting(null);
                      setTkSearch("");
                      setS((p) => ({
                        ...p,
                        clientName: "",
                        engagementManager: "",
                        salesManager: "",
                        phoneNumber: "",
                        city: "",
                        country: "",
                        industry: "",
                        businessType: "",
                        customerId: "C" + String((apiClients?.length ?? 0) + 1).padStart(3, "0"),
                      }));
                      setSvSearch("");
                      setSvDropOpen(false);
                      setSvAlreadyExists(false);
                    }}
                    title="Clear selection"
                  >
                    <X className="h-3.5 w-3.5" />
                  </button>
                )}

                {tkDropOpen && (
                  <div className="absolute left-0 right-0 top-full z-50 mt-1 max-h-56 overflow-y-auto rounded-md border border-border bg-popover shadow-lg">
                    {filteredTk.length > 0 && (
                      <>
                        <div className="px-3 py-1.5 text-[10px] font-semibold uppercase tracking-wide text-muted-foreground">
                          Existing Customers
                        </div>
                        {filteredTk.map((c) => (
                          <button
                            key={c.id}
                            type="button"
                            className="flex w-full items-center gap-3 px-3 py-2 text-left text-sm hover:bg-accent cursor-pointer"
                            onMouseDown={() => {
                              setSelectedExisting(c);
                              setTkSearch(c.name);
                              setTkDropOpen(false);
                              setS((p) => ({
                                ...p,
                                clientName: c.name,
                                customerId: c.id,
                                engagementManager: c.engagementManager ?? p.engagementManager,
                                salesManager: c.salesManager ?? p.salesManager,
                                phoneNumber:
                                  (c as { phoneNumber?: string }).phoneNumber ?? p.phoneNumber,
                                city: c.city ?? p.city,
                                country: c.country ?? p.country,
                                industry: c.industry ?? p.industry,
                                businessType: c.businessType ?? p.businessType,
                                contacts: [
                                  {
                                    name: "",
                                    email: "",
                                    phone: "",
                                    designation: "",
                                    contactType: "",
                                  },
                                ],
                              }));
                            }}
                          >
                            <span className="flex h-7 w-7 items-center justify-center rounded-md bg-gradient-to-br from-primary to-info text-[11px] font-semibold text-primary-foreground shrink-0">
                              {c.logo}
                            </span>
                            <div className="min-w-0 flex-1">
                              <div className="truncate font-medium">{c.name}</div>
                              <div className="truncate text-[11px] text-muted-foreground">
                                {c.industry} · {c.id}
                              </div>
                            </div>
                            <span className="shrink-0 rounded-full bg-success/10 px-2 py-0.5 text-[10px] font-medium text-success">
                              Existing
                            </span>
                          </button>
                        ))}
                      </>
                    )}
                    {tkSearch.trim() && (
                      <button
                        type="button"
                        className="flex w-full items-center gap-2 border-t border-border px-3 py-2 text-left text-sm text-primary hover:bg-accent cursor-pointer"
                        onMouseDown={() => {
                          setSelectedExisting(null);
                          setSvSearch("");
                          setSvDropOpen(false);
                          setSvAlreadyExists(false);
                          setS((p) => ({ ...p, clientName: tkSearch.trim(), subVentureName: "" }));
                          setTkDropOpen(false);
                        }}
                      >
                        <Plus className="h-3.5 w-3.5" />
                        Add <span className="font-semibold">"{tkSearch.trim()}"</span> as new TK Customer
                      </button>
                    )}
                  </div>
                )}
              </div>
              {touched.clientName && getClientNameError() && (
                <p className="mt-1 flex items-center gap-1 text-[11px] text-destructive">
                  <AlertCircle className="h-3 w-3" /> {getClientNameError()}
                </p>
              )}
              {selectedExisting && (
                <p className="mt-1 text-[11px] text-success flex items-center gap-1">
                  <CheckCircle2 className="h-3 w-3" /> Existing customer selected — details auto-filled.
                </p>
              )}
            </div>

            {/* End Customer / Sub-venture Name */}
            <div>
              <label className="mb-1 block text-xs font-medium text-muted-foreground">
                End Customer Name / Sub-venture Name <span className="text-destructive">*</span>
              </label>
              {selectedExisting ? (
                <div>
                  <div className="relative">
                    <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                    <input
                      className={cn(
                        inputCls,
                        "pl-8",
                        touched.subVentureName && getSubVentureError() && "border-destructive focus-visible:ring-destructive",
                      )}
                      placeholder="Search existing sub-ventures or enter a new one…"
                      maxLength={FIELD_MAX.subVentureName}
                      value={svSearch || s.subVentureName}
                      onFocus={() => setSvDropOpen(true)}
                      onChange={(e) => {
                        const val = e.target.value.slice(0, FIELD_MAX.subVentureName);
                        setSvSearch(val);
                        setSvDropOpen(true);
                        const match = (selectedExisting.subVentures ?? []).find(
                          (sv) => sv.name.toLowerCase() === val.trim().toLowerCase(),
                        );
                        if (match) {
                          setSvAlreadyExists(true);
                          setS((p) => ({ ...p, subVentureName: match.name }));
                        } else {
                          setSvAlreadyExists(false);
                          setS((p) => ({ ...p, subVentureName: val }));
                        }
                        markTouched("subVentureName");
                      }}
                      onBlur={() => setTimeout(() => setSvDropOpen(false), 150)}
                    />
                  </div>
                  {duplicatePairExists && matchingExistingClient && (
                    <p className="mt-1 text-[11px] text-destructive flex items-center gap-1">
                      <AlertCircle className="h-3 w-3" /> Client and sub-venture already exist under {matchingExistingClient.name}.
                    </p>
                  )}
                  {!duplicatePairExists && s.subVentureName.trim() && (
                    <p className="mt-1 text-[11px] text-success flex items-center gap-1">
                      <CheckCircle2 className="h-3 w-3" /> New sub-venture will be registered under {selectedExisting.name}
                    </p>
                  )}
                </div>
              ) : (
                <div>
                  <input
                    className={cn(
                      inputCls,
                      touched.subVentureName && getSubVentureError() && "border-destructive focus-visible:ring-destructive",
                      touched.subVentureName && !getSubVentureError() && s.subVentureName && "border-success/60",
                    )}
                    value={s.subVentureName}
                    maxLength={FIELD_MAX.subVentureName}
                    onChange={(e) => u("subVentureName", e.target.value.slice(0, FIELD_MAX.subVentureName))}
                    placeholder="Enter end customer division or primary business unit…"
                  />
                  {touched.subVentureName && getSubVentureError() && (
                    <p className="mt-1 flex items-center gap-1 text-[11px] text-destructive">
                      <AlertCircle className="h-3 w-3" /> {getSubVentureError()}
                    </p>
                  )}
                  {duplicatePairExists && matchingExistingClient && (
                    <p className="mt-1 flex items-center gap-1 text-[11px] text-destructive">
                      <AlertCircle className="h-3 w-3" /> Client and sub-venture already exist under {matchingExistingClient.name}.
                    </p>
                  )}
                </div>
              )}
            </div>

            {!selectedExisting && (
              <div className="grid gap-3 sm:grid-cols-2">
                <Field label="Industry" required error={touched.industry ? getIndustryError() : null}>
                  <select
                    className={cn(
                      inputCls,
                      touched.industry && getIndustryError() && "border-destructive focus-visible:ring-destructive",
                    )}
                    value={s.industry}
                    onChange={(e) => u("industry", e.target.value)}
                  >
                    <option value="">Select industry</option>
                    {[
                      "Banking",
                      "Healthcare",
                      "Retail",
                      "Logistics",
                      "Energy",
                      "Manufacturing",
                      "Telecom",
                      "Media",
                      "Technology",
                    ].map((o) => (
                      <option key={o}>{o}</option>
                    ))}
                  </select>
                </Field>

                <Field label="Customer ID">
                  <input className={readOnlyCls} value={s.customerId} readOnly />
                </Field>
              </div>
            )}
          </div>

          {!selectedExisting && (
            <div className="rounded-lg border border-border bg-card p-3.5 shadow-2xs space-y-3">
              <div className="flex items-center gap-2 border-b border-border/70 pb-2">
                <Users className="h-4 w-4 text-primary" />
                <h4 className="text-xs font-semibold text-foreground uppercase tracking-wide">
                  Account Leadership & Ownership
                </h4>
              </div>

              <div className="grid gap-3 sm:grid-cols-2">
                <Field
                  label="Engagement Manager"
                  required
                  error={touched.engagementManager ? getEngagementManagerError() : null}
                >
                  <input
                    className={cn(
                      inputCls,
                      touched.engagementManager &&
                        getEngagementManagerError() &&
                        "border-destructive focus-visible:ring-destructive",
                      touched.engagementManager && !getEngagementManagerError() && s.engagementManager && "border-success/60",
                    )}
                    maxLength={FIELD_MAX.engagementManager}
                    value={s.engagementManager}
                    placeholder="e.g. Riya Kapoor"
                    onChange={(e) =>
                      u(
                        "engagementManager",
                        e.target.value.replace(/[^a-zA-Z\s-']/g, "").slice(0, FIELD_MAX.engagementManager),
                      )
                    }
                  />
                </Field>

                <Field label="Sales Manager">
                  <input
                    className={cn(
                      inputCls,
                      s.salesManager && "border-success/60",
                    )}
                    maxLength={FIELD_MAX.salesManager}
                    value={s.salesManager}
                    placeholder="e.g. Vikram Sharma"
                    onChange={(e) =>
                      u(
                        "salesManager",
                        e.target.value.replace(/[^a-zA-Z\s-']/g, "").slice(0, FIELD_MAX.salesManager),
                      )
                    }
                  />
                </Field>
              </div>
            </div>
          )}

          {!selectedExisting && (
            <div className="rounded-lg border border-border bg-card p-3.5 shadow-2xs space-y-3">
              <div className="flex items-center gap-2 border-b border-border/70 pb-2">
                <MapPin className="h-4 w-4 text-primary" />
                <h4 className="text-xs font-semibold text-foreground uppercase tracking-wide">
                  Geographic Presence & Group Contact
                </h4>
              </div>

              <div className="grid gap-3 sm:grid-cols-2">
                <Field label="Country / Region" required error={touched.country ? getCountryError() : null}>
                  <select
                    className={cn(
                      inputCls,
                      touched.country && getCountryError() && "border-destructive focus-visible:ring-destructive",
                    )}
                    value={s.country}
                    onChange={(e) => {
                      const next = e.target.value;
                      setS((p) => ({ ...p, country: next, city: "", phoneNumber: "" }));
                      markTouched("country");
                    }}
                  >
                    <option value="">Select country</option>
                    {countries.map((c) => (
                      <option key={c.id} value={c.name}>
                        {c.name}
                      </option>
                    ))}
                  </select>
                </Field>

                <Field label="City" required error={touched.city ? getCityError() : null}>
                  <select
                    className={cn(
                      inputCls,
                      touched.city && getCityError() && "border-destructive focus-visible:ring-destructive",
                    )}
                    value={s.city}
                    disabled={!s.country}
                    onChange={(e) => u("city", e.target.value)}
                  >
                    <option value="">
                      {s.country ? "Select city" : "Select country first"}
                    </option>
                    {cities.map((c) => (
                      <option key={c.id} value={c.name}>
                        {c.name}
                      </option>
                    ))}
                  </select>
                </Field>

                <div className="sm:col-span-2">
                  <Field
                    label="Group SPOC Contact"
                    required
                    error={touched.phoneNumber ? getPhoneError() : null}
                  >
                    <div className="relative flex rounded-md">
                      <span className="inline-flex items-center rounded-l-md border border-r-0 border-input bg-muted px-3 text-xs font-semibold text-muted-foreground select-none">
                        {countryDialCode}
                      </span>
                      <input
                        className={cn(
                          inputCls,
                          "rounded-l-none",
                          touched.phoneNumber && getPhoneError() && "border-destructive focus-visible:ring-destructive",
                          touched.phoneNumber && !getPhoneError() && s.phoneNumber && "border-success/60",
                        )}
                        type="tel"
                        inputMode="numeric"
                        maxLength={countryPhoneDigits}
                        placeholder={s.country ? `Enter ${countryPhoneDigits}-digit primary number` : "Select country first"}
                        value={s.phoneNumber}
                        disabled={!s.country}
                        onChange={(e) => {
                          const digits = e.target.value.replace(/\D/g, "").slice(0, countryPhoneDigits);
                          u("phoneNumber", digits);
                        }}
                      />
                      {s.phoneNumber && (
                        <span className="absolute right-3 top-1/2 -translate-y-1/2 text-[10px] font-mono text-muted-foreground">
                          {s.phoneNumber.length}/{countryPhoneDigits}
                        </span>
                      )}
                    </div>
                  </Field>
                </div>
              </div>
            </div>
          )}

          <div className="flex items-center justify-between text-[11px] text-muted-foreground px-1">
            <span>Created by: <span className="font-medium text-foreground">{s.createdBy}</span></span>
            <span>Registration Date: <span className="font-medium text-foreground">{format(new Date(s.createdAt), "dd MMM yyyy")}</span></span>
          </div>
        </div>
      )}

      {/* STEP 2: SPOC Contacts & KYC Upload */}
      {step === 2 && (
        <div className="space-y-4">
          <div className="space-y-3">
            <div className="flex items-center justify-between px-1">
              <div className="flex items-center gap-2">
                <Users className="h-4 w-4 text-primary" />
                <h4 className="text-xs font-semibold text-foreground uppercase tracking-wide">
                  Single Points of Contact (SPOCs)
                </h4>
              </div>
              <span className="text-[11px] text-muted-foreground">
                {s.contacts.length} of {MAX_CONTACTS} slots used
              </span>
            </div>

            {s.contacts.map((ct, idx) => (
              <div key={idx} className="rounded-lg border border-border bg-card p-3.5 shadow-2xs space-y-3">
                <div className="flex items-center justify-between border-b border-border/60 pb-2">
                  <span className="flex items-center gap-2 text-xs font-semibold text-foreground">
                    <span className="flex h-5 w-5 items-center justify-center rounded-full bg-primary/10 text-[10px] font-bold text-primary">
                      {idx + 1}
                    </span>
                    SPOC Person {idx === 0 ? "(Primary)" : `#${idx + 1}`}
                  </span>
                  {idx > 0 && (
                    <button
                      type="button"
                      onClick={() => removeContact(idx)}
                      className="inline-flex items-center gap-1 rounded border border-destructive/20 bg-destructive/5 px-2 py-0.5 text-[11px] font-medium text-destructive hover:bg-destructive/10 cursor-pointer"
                    >
                      <X className="h-3 w-3" /> Remove
                    </button>
                  )}
                </div>

                <div className="grid gap-3 sm:grid-cols-2">
                  <Field
                    label="Contact Person Name"
                    required
                    error={touched[`contact_name_${idx}`] && !ct.name.trim() ? "Name is required" : null}
                  >
                    <input
                      className={cn(
                        inputCls,
                        touched[`contact_name_${idx}`] && !ct.name.trim() && "border-destructive",
                        ct.name.trim() && "border-success/60",
                      )}
                      value={ct.name}
                      maxLength={FIELD_MAX.personName}
                      placeholder="e.g. Sameer Patel"
                      onChange={(e) => {
                        const filtered = e.target.value
                          .replace(/[^a-zA-Z\s-']/g, "")
                          .slice(0, FIELD_MAX.personName);
                        updateContact(idx, "name", filtered);
                      }}
                    />
                  </Field>

                  <Field
                    label="Contact Type / Department"
                    required
                    error={touched[`contact_type_${idx}`] && !ct.contactType ? "Contact type is required" : null}
                  >
                    <select
                      className={cn(
                        inputCls,
                        touched[`contact_type_${idx}`] && !ct.contactType && "border-destructive",
                      )}
                      value={ct.contactType}
                      onChange={(e) => updateContact(idx, "contactType", e.target.value)}
                    >
                      <option value="">Select contact role</option>
                      {["Primary", "Accounts", "Procurement", "Technical", "Legal", "Executive"].map((o) => (
                        <option key={o} value={o}>
                          {o}
                        </option>
                      ))}
                    </select>
                  </Field>

                  <Field
                    label="Email Address"
                    required
                    error={touched[`contact_email_${idx}`] ? emailError(ct.email, true) : null}
                  >
                    <input
                      type="text"
                      inputMode="email"
                      className={cn(
                        inputCls,
                        touched[`contact_email_${idx}`] && emailError(ct.email, true) && "border-destructive",
                        ct.email && !emailError(ct.email, true) && "border-success/60",
                      )}
                      value={ct.email}
                      maxLength={FIELD_MAX.email}
                      placeholder="contact@company.com"
                      onChange={(e) => updateContact(idx, "email", toEmailInput(e.target.value))}
                      onBlur={() => updateContact(idx, "email", ct.email.trim())}
                    />
                  </Field>

                  <Field
                    label="Mobile Phone"
                    required
                    error={touched[`contact_phone_${idx}`] ? phoneError(ct.phone) : null}
                  >
                    <div className="relative flex rounded-md">
                      <span className="inline-flex items-center rounded-l-md border border-r-0 border-input bg-muted px-2.5 text-xs font-semibold text-muted-foreground select-none">
                        +91
                      </span>
                      <input
                        className={cn(
                          inputCls,
                          "rounded-l-none",
                          touched[`contact_phone_${idx}`] && phoneError(ct.phone) && "border-destructive",
                          ct.phone && !phoneError(ct.phone) && "border-success/60",
                        )}
                        type="tel"
                        inputMode="numeric"
                        maxLength={FIELD_MAX.phone}
                        placeholder="9876543210"
                        value={ct.phone}
                        onChange={(e) => updateContact(idx, "phone", toTenDigitPhone(e.target.value))}
                      />
                    </div>
                  </Field>

                  <div className="sm:col-span-2">
                    <Field
                      label="Designation / Role"
                      required
                      error={touched[`contact_designation_${idx}`] && !ct.designation.trim() ? "Designation is required" : null}
                    >
                      <input
                        className={cn(
                          inputCls,
                          touched[`contact_designation_${idx}`] && !ct.designation.trim() && "border-destructive",
                          ct.designation.trim() && "border-success/60",
                        )}
                        maxLength={FIELD_MAX.designation}
                        placeholder="e.g. Head of Engineering / CISO / Procurement Lead"
                        value={ct.designation}
                        onChange={(e) =>
                          updateContact(idx, "designation", e.target.value.slice(0, FIELD_MAX.designation))
                        }
                      />
                    </Field>
                  </div>
                </div>
              </div>
            ))}

            {s.contacts.length < MAX_CONTACTS && (
              <button
                type="button"
                onClick={addContact}
                className="w-full flex items-center justify-center gap-1.5 rounded-lg border border-dashed border-primary/40 bg-primary/5 py-2.5 text-xs font-medium text-primary hover:bg-primary/10 transition-colors cursor-pointer"
              >
                <Plus className="h-3.5 w-3.5" /> Add Another Contact Person ({MAX_CONTACTS - s.contacts.length} slots remaining)
              </button>
            )}
          </div>

          {/* KYC Upload Dropzone */}
          <div className="rounded-lg border border-border bg-card p-3.5 shadow-2xs space-y-3">
            <div className="flex items-center justify-between border-b border-border/60 pb-2">
              <div className="flex items-center gap-2">
                <ShieldCheck className="h-4 w-4 text-primary" />
                <h4 className="text-xs font-semibold text-foreground uppercase tracking-wide">
                  KYC & Corporate Verification Document <span className="text-destructive">*</span>
                </h4>
              </div>
              <span className="text-[10px] text-muted-foreground">PDF, Images, DOCX up to 25MB</span>
            </div>

            <div
              onDragOver={(e) => {
                e.preventDefault();
                setIsDragging(true);
              }}
              onDragLeave={() => setIsDragging(false)}
              onDrop={(e) => {
                e.preventDefault();
                setIsDragging(false);
                const file = e.dataTransfer.files?.[0];
                if (file) {
                  setS((p) => ({ ...p, kycFile: file }));
                  markTouched("kycFile");
                }
              }}
              className={cn(
                "relative flex flex-col items-center justify-center rounded-lg border-2 border-dashed p-4 text-center transition-all",
                isDragging
                  ? "border-primary bg-primary/10 scale-[1.01]"
                  : s.kycFile
                    ? "border-success/50 bg-success/5"
                    : touched.kycFile && !s.kycFile
                      ? "border-destructive bg-destructive/5"
                      : "border-input bg-muted/20 hover:bg-muted/40",
              )}
            >
              <input
                type="file"
                accept="*/*"
                className="absolute inset-0 h-full w-full cursor-pointer opacity-0"
                onChange={(e) => {
                  setS((p) => ({ ...p, kycFile: e.target.files?.[0] ?? null }));
                  markTouched("kycFile");
                }}
              />

              {s.kycFile ? (
                <div className="flex w-full items-center justify-between gap-3 text-left">
                  <div className="flex items-center gap-3 min-w-0">
                    <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-success/15 text-success">
                      <FileText className="h-5 w-5" />
                    </span>
                    <div className="min-w-0">
                      <p className="truncate text-xs font-semibold text-foreground">{s.kycFile.name}</p>
                      <p className="text-[11px] text-muted-foreground">
                        {(s.kycFile.size / 1024).toFixed(0)} KB · Ready for verification
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-1.5 shrink-0">
                    <button
                      type="button"
                      onClick={(e) => {
                        e.preventDefault();
                        e.stopPropagation();
                        setS((p) => ({ ...p, kycFile: null }));
                      }}
                      className="rounded-md p-1 hover:bg-destructive/10 hover:text-destructive text-muted-foreground transition-colors cursor-pointer"
                      title="Remove file"
                    >
                      <X className="h-4 w-4" />
                    </button>
                  </div>
                </div>
              ) : (
                <div className="py-2 space-y-1">
                  <UploadCloud className="mx-auto h-8 w-8 text-primary/70 animate-pulse" />
                  <p className="text-xs font-medium text-foreground">
                    Drag and drop your KYC document here, or <span className="text-primary underline">browse</span>
                  </p>
                  <p className="text-[11px] text-muted-foreground">
                    Certificate of Incorporation, Tax Registration, or Business Verification File
                  </p>
                </div>
              )}
            </div>
            {touched.kycFile && !s.kycFile && (
              <p className="flex items-center gap-1 text-[11px] text-destructive">
                <AlertCircle className="h-3 w-3" /> KYC verification document is required.
              </p>
            )}
          </div>

          {/* Sub-venture Notes */}
          <div className="rounded-lg border border-border bg-card p-3.5 shadow-2xs space-y-2">
            <label className="block text-xs font-medium text-muted-foreground">
              Internal Onboarding Notes (Optional)
            </label>
            <textarea
              rows={2}
              maxLength={2000}
              className={cn(inputCls, "h-auto py-2")}
              value={s.notes}
              onChange={(e) => u("notes", e.target.value)}
              placeholder="Any operational guidelines, project context, or delivery SLA notes…"
            />
            <p className="text-right text-[10px] tabular-nums text-muted-foreground">
              {s.notes.length}/2000 characters
            </p>
          </div>
        </div>
      )}

      {/* STEP 3: Review & Submit */}
      {step === 3 && (
        <div className="space-y-4">
          <div className="rounded-lg border border-primary/20 bg-primary/5 p-3.5 text-xs text-primary flex items-start gap-2.5">
            <ShieldCheck className="h-4 w-4 shrink-0 mt-0.5" />
            <div>
              <p className="font-semibold">Review and Verify Onboarding Summary</p>
              <p className="text-[11px] opacity-90">
                Please double check customer entity details, account managers, and contacts before final confirmation.
              </p>
            </div>
          </div>

          <div className="rounded-lg border border-border bg-card p-4 shadow-2xs space-y-3">
            <h4 className="text-xs font-semibold text-foreground uppercase tracking-wide flex items-center gap-2 border-b border-border/70 pb-2">
              <Building2 className="h-3.5 w-3.5 text-primary" /> Customer Profile
            </h4>
            <dl className="grid grid-cols-2 gap-x-4 gap-y-2.5 text-xs">
              <Row label="TK Customer / Partner" v={s.clientName || selectedExisting?.name || "—"} />
              <Row label="Sub-venture Name" v={s.subVentureName} />
              <Row label="Customer ID" v={selectedExisting ? selectedExisting.id : s.customerId} />
              <Row label="Industry" v={s.industry || selectedExisting?.industry || "—"} />
              <Row label="Engagement Manager" v={s.engagementManager || selectedExisting?.engagementManager || "—"} />
              <Row label="Sales Manager" v={s.salesManager || selectedExisting?.salesManager || "—"} />
              <Row label="Operating Country" v={s.country || selectedExisting?.country || "—"} />
              <Row label="City" v={s.city || selectedExisting?.city || "—"} />
              <Row label="Group SPOC Contact" v={s.phoneNumber ? `${countryDialCode} ${s.phoneNumber}` : "—"} />
              <Row label="Created By" v={s.createdBy} />
            </dl>
          </div>

          <div className="rounded-lg border border-border bg-card p-4 shadow-2xs space-y-3">
            <h4 className="text-xs font-semibold text-foreground uppercase tracking-wide flex items-center gap-2 border-b border-border/70 pb-2">
              <Users className="h-3.5 w-3.5 text-primary" /> Assigned Contact Persons ({s.contacts.length})
            </h4>
            <div className="grid gap-2 sm:grid-cols-2">
              {s.contacts.map((ct, idx) => (
                <div key={idx} className="rounded-md border border-border/80 bg-muted/20 p-2.5 text-xs space-y-1">
                  <div className="flex items-center justify-between">
                    <span className="font-semibold text-foreground">{ct.name || "—"}</span>
                    <span className="rounded bg-primary/10 px-1.5 py-0.5 text-[10px] font-medium text-primary">
                      {ct.contactType || "Primary"}
                    </span>
                  </div>
                  <p className="text-[11px] text-muted-foreground">{ct.designation || "No designation"}</p>
                  <p className="text-[11px] text-muted-foreground font-mono">{ct.email || "—"}</p>
                  {ct.phone && <p className="text-[11px] text-muted-foreground font-mono">+91 {ct.phone}</p>}
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-lg border border-border bg-card p-3.5 shadow-2xs flex items-center justify-between">
            <div className="flex items-center gap-3">
              <span className="flex h-9 w-9 items-center justify-center rounded-lg bg-success/15 text-success">
                <FileText className="h-5 w-5" />
              </span>
              <div>
                <span className="text-[10px] text-muted-foreground block font-medium">Attached KYC Verification File</span>
                <span className="font-mono text-xs font-semibold text-foreground">{s.kycFile ? s.kycFile.name : "—"}</span>
              </div>
            </div>
            {s.kycFile && (
              <button
                type="button"
                onClick={() => setPreviewKyc(true)}
                className="inline-flex items-center gap-1 rounded-md border border-primary/30 bg-primary/10 px-3 py-1.5 text-xs font-semibold text-primary hover:bg-primary/20 transition-colors cursor-pointer shadow-2xs"
              >
                <Eye className="h-3.5 w-3.5" /> Preview KYC
              </button>
            )}
          </div>
        </div>
      )}

      {/* Modal Footer */}
      <div className="mt-6 flex items-center justify-between border-t border-border pt-4">
        <button
          type="button"
          onClick={() => (step === 1 ? onClose() : setStep(step - 1))}
          className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium text-foreground hover:bg-accent transition-colors cursor-pointer"
        >
          {step === 1 ? "Cancel" : "Back"}
        </button>

        {step < 3 ? (
          <button
            type="button"
            onClick={handleNext}
            className="inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-xs font-semibold text-primary-foreground hover:bg-primary/90 transition-colors shadow-2xs cursor-pointer"
          >
            Continue to {step === 1 ? "SPOCs & KYC" : "Summary Review"} <ArrowRight className="h-3.5 w-3.5" />
          </button>
        ) : (
          <button
            type="button"
            disabled={submitting}
            onClick={() => void submit()}
            className="inline-flex items-center gap-1.5 rounded-md bg-primary px-5 py-2 text-xs font-semibold text-primary-foreground hover:bg-primary/90 disabled:opacity-50 transition-colors shadow-2xs cursor-pointer"
          >
            {submitting ? (
              <>Saving Customer...</>
            ) : (
              <>
                <Check className="h-3.5 w-3.5" /> Confirm & Onboard Customer
              </>
            )}
          </button>
        )}
      </div>
    </Modal>
    <KycDocPreviewModal
      open={previewKyc && Boolean(s.kycFile)}
      onClose={() => setPreviewKyc(false)}
      file={s.kycFile}
      fileName={s.kycFile?.name}
      clientName={s.clientName || s.subVentureName || "New Customer"}
      subVentureName={s.subVentureName}
    />
    </>
  );
}
