import { useState, useEffect, useMemo } from "react";
import { Loader2, Plus, X, FileText, Check, Eye, Layers } from "lucide-react";
import { toast } from "sonner";
import { Modal } from "@/modules/projects/pages/projects-list-page";
import { SearchableSelect } from "@/components/creatable-catalog-select";
import { KycDocPreviewModal } from "@/modules/customers/components/kyc-preview-modal";
import {
  fetchCountries,
  fetchContactTypes,
  fetchContactDesignations,
  type CatalogOption,
} from "@/lib/api/catalogs";
import { countryPhoneError, emailError } from "@/lib/form-validation";
import {
  updateClient,
  uploadSubVentureKyc,
  getSubVentureKycUrl,
  formatCustomerId,
} from "@/modules/customers/api/clients";
import type { Client, ClientSubVenture } from "@/types";
import { cn } from "@/lib/utils";

const MAX_CONTACTS = 5;

const inputCls =
  "h-9 w-full rounded-md border border-input bg-card px-3 text-xs shadow-2xs outline-none transition-all placeholder:text-muted-foreground focus-visible:border-primary focus-visible:ring-2 focus-visible:ring-primary/20 disabled:cursor-not-allowed disabled:opacity-50 text-foreground";

function fieldInputCls(baseCls: string, hasError: boolean) {
  return cn(
    baseCls,
    hasError &&
      "border-destructive text-destructive placeholder:text-destructive/60 focus-visible:border-destructive focus-visible:ring-destructive/20",
  );
}

function Field({
  label,
  required,
  error,
  children,
  className,
}: {
  label: string;
  required?: boolean;
  error?: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("space-y-1.5", className)}>
      <label className="text-xs font-medium text-foreground">
        {label} {required && <span className="text-destructive">*</span>}
      </label>
      {children}
      {error && <p className="text-[11px] text-destructive">{error}</p>}
    </div>
  );
}

interface ContactItem {
  id?: string;
  name: string;
  contactType: string;
  country: string;
  phone: string;
  email: string;
  designation: string;
}

export interface EditSubVentureModalProps {
  client: Client;
  selectedSubVentureId?: string | null;
  onClose: () => void;
  onSaved: (editedSubVentureName: string) => void;
}

export function EditSubVentureModal({
  client,
  selectedSubVentureId,
  onClose,
  onSaved,
}: EditSubVentureModalProps) {
  const subVentures = useMemo(() => client.subVentures ?? [], [client.subVentures]);

  // Do not select any sub-venture initially so fields only show when selected
  const [activeSvId, setActiveSvId] = useState<string>("");

  const activeSv = useMemo(
    () => (activeSvId ? subVentures.find((s) => s.id === activeSvId) : undefined),
    [subVentures, activeSvId],
  );

  // Form state for currently active subventure
  const [contacts, setContacts] = useState<ContactItem[]>([]);
  const [notes, setNotes] = useState("");
  const [newKycFile, setNewKycFile] = useState<File | null>(null);
  const [previewKycOpen, setPreviewKycOpen] = useState(false);

  // Catalogs
  const [countries, setCountries] = useState<CatalogOption[]>([]);
  const [contactTypes, setContactTypes] = useState<CatalogOption[]>([]);
  const [designations, setDesignations] = useState<CatalogOption[]>([]);
  const [catalogsLoading, setCatalogsLoading] = useState(true);

  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  // Load catalogs once
  useEffect(() => {
    let active = true;
    Promise.all([fetchCountries(), fetchContactTypes(), fetchContactDesignations()])
      .then(([coList, ctList, desList]) => {
        if (!active) return;
        setCountries(coList);
        setContactTypes(ctList);
        setDesignations(desList);
      })
      .catch(() => {
        // Fallback gracefully
      })
      .finally(() => {
        if (active) setCatalogsLoading(false);
      });
    return () => {
      active = false;
    };
  }, []);

  // When active sub-venture changes, initialize its form data
  useEffect(() => {
    if (!activeSv) return;

    const svContacts: ContactItem[] = (activeSv.contacts ?? []).map((c) => ({
      name: c.name || "",
      contactType: c.contactType || "Primary",
      country: c.country || client.country || "India",
      phone: (c.phone || "").replace(/\D/g, ""),
      email: c.email || "",
      designation: c.designation || "",
    }));

    if (svContacts.length === 0) {
      svContacts.push({
        name: "",
        contactType: "Primary",
        country: client.country || "India",
        phone: "",
        email: "",
        designation: "",
      });
    }

    setContacts(svContacts);
    setNotes(activeSv.notes || "");
    setNewKycFile(null);
    setSubmitted(false);
  }, [activeSv, client.country]);

  // Sub-venture dropdown options
  const subVentureOptions = useMemo(
    () =>
      subVentures.map((sv) => ({
        value: sv.id,
        label: sv.name + (sv.subVentureCode ? ` (${sv.subVentureCode})` : ""),
      })),
    [subVentures],
  );

  const existingKycName = activeSv?.kycDocumentName || "";
  const existingKycUrl =
    activeSv?.kycDocumentPath && activeSv?.id && client.id
      ? getSubVentureKycUrl(client.id, activeSv.id)
      : undefined;

  const updateContact = (index: number, field: keyof ContactItem, val: string) => {
    setContacts((prev) => {
      const next = [...prev];
      next[index] = { ...next[index], [field]: val };
      return next;
    });
  };

  const addContact = () => {
    if (contacts.length >= MAX_CONTACTS) return;
    setContacts((prev) => [
      ...prev,
      {
        name: "",
        contactType: "Secondary",
        country: client.country || "India",
        phone: "",
        email: "",
        designation: "",
      },
    ]);
  };

  const removeContact = (index: number) => {
    if (contacts.length <= 1) return;
    setContacts((prev) => prev.filter((_, i) => i !== index));
  };

  // Validation
  const hasKycDoc = Boolean(newKycFile || existingKycName || activeSv?.kycDocumentPath);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);

    if (!activeSv) {
      toast.error("Please select a sub-venture.");
      return;
    }

    // Validate contacts
    if (contacts.length === 0) {
      toast.error("Please add at least one contact person.");
      return;
    }

    for (let i = 0; i < contacts.length; i++) {
      const c = contacts[i];
      const personLabel = `Contact Person ${i + 1}`;
      if (!c.name.trim()) {
        toast.error(`${personLabel}: Name is required.`);
        return;
      }
      if (!c.country.trim()) {
        toast.error(`${personLabel}: Country / Region is required.`);
        return;
      }
      const co = countries.find((item) => item.name.toLowerCase() === c.country.toLowerCase());
      const phoneDigits = co?.phoneDigits || 10;
      const phoneCode = co?.phoneCode || "+91";
      const pErr = countryPhoneError(c.phone, {
        digits: phoneDigits,
        phoneCode,
        countryName: c.country,
        label: `${personLabel} Phone`,
        required: true,
      });
      if (pErr) {
        toast.error(pErr);
        return;
      }

      if (!c.email.trim()) {
        toast.error(`${personLabel}: Email is required.`);
        return;
      }
      const eErr = emailError(c.email, true);
      if (eErr) {
        toast.error(`${personLabel}: ${eErr}`);
        return;
      }
    }

    if (!hasKycDoc) {
      toast.error("KYC Document is required for this sub-venture.");
      return;
    }

    setSubmitting(true);
    try {
      const validContacts = contacts.map((c) => {
        const co = countries.find((item) => item.name.toLowerCase() === c.country.toLowerCase());
        return {
          name: c.name.trim(),
          email: c.email.trim(),
          phone: c.phone.trim(),
          designation: c.designation.trim() || undefined,
          contactType: c.contactType.trim() || undefined,
          country: c.country.trim() || undefined,
          phoneCode: co?.phoneCode || "+91",
        };
      });

      const updatedSubVentures: ClientSubVenture[] = subVentures.map((sv) => {
        if (sv.id === activeSv.id) {
          return {
            id: sv.id,
            name: sv.name,
            subVentureCode: sv.subVentureCode,
            contacts: validContacts,
            notes: notes.trim() || undefined,
            kycDocumentName: newKycFile ? newKycFile.name : sv.kycDocumentName,
            kycDocumentPath: sv.kycDocumentPath,
          };
        }
        return {
          id: sv.id,
          name: sv.name,
          subVentureCode: sv.subVentureCode,
          contacts: sv.contacts,
          notes: sv.notes,
          kycDocumentName: sv.kycDocumentName,
          kycDocumentPath: sv.kycDocumentPath,
        };
      });

      await updateClient(client.id, {
        subVentures: updatedSubVentures,
        contacts: client.contacts, // Preserve client-level contacts
      });

      if (newKycFile && activeSv.id) {
        try {
          await uploadSubVentureKyc(client.id, activeSv.id, newKycFile);
        } catch (kycErr) {
          toast.warning("Sub-venture saved, but KYC document upload failed", {
            description:
              kycErr instanceof Error
                ? kycErr.message
                : "Please re-upload the KYC document from the customer page.",
          });
        }
      }

      toast.success("Sub-venture information updated successfully");
      onSaved(activeSv.name);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to update sub-venture information");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <>
      <Modal
        title={`Edit Sub-venture Information — ${client.name}`}
        onClose={onClose}
        extraWide
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Sub-venture Selector Banner */}
          <div className="rounded-xl border border-primary/20 bg-primary/5 p-4 space-y-3">
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
              <div>
                <h3 className="text-xs font-bold uppercase tracking-wider text-primary">
                  Select Sub-venture to Edit
                </h3>
                <p className="text-[11px] text-muted-foreground">
                  Changes made below will apply specifically to this sub-venture division.
                </p>
              </div>

              {activeSv && (
                <div className="flex items-center gap-2">
                  <span className="inline-flex items-center gap-1 rounded-md border border-border bg-card px-2.5 py-1 text-xs font-mono font-medium text-foreground">
                    Code: {activeSv.subVentureCode || "—"}
                  </span>
                </div>
              )}
            </div>

            <div className="w-full sm:max-w-md">
              <SearchableSelect
                placeholder="Select sub-venture to edit…"
                options={subVentureOptions}
                value={activeSvId}
                onChange={(id) => setActiveSvId(id)}
                required
              />
            </div>
          </div>

          {!activeSv ? (
            <div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-border/80 bg-muted/20 py-12 px-4 text-center space-y-2">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 text-primary">
                <Layers className="h-5 w-5" />
              </div>
              <p className="text-sm font-semibold text-foreground">Select a Sub-venture</p>
              <p className="text-xs text-muted-foreground max-w-sm">
                Please select a sub-venture from the dropdown above to view and edit its contact persons, KYC document, and notes.
              </p>
            </div>
          ) : (
            <div className="space-y-5">
              {/* ── 1. Contact Persons Section ── */}
              <div className="space-y-3">
                <div className="flex items-center justify-between border-b border-border pb-2">
                  <div>
                    <h4 className="text-xs font-semibold uppercase tracking-wide text-foreground">
                      Contact Persons ({contacts.length})
                    </h4>
                    <p className="text-[11px] text-muted-foreground">
                      Authorized representatives for {activeSv.name}
                    </p>
                  </div>
                  <button
                    type="button"
                    onClick={addContact}
                    disabled={contacts.length >= MAX_CONTACTS}
                    className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1 text-xs font-medium text-foreground hover:bg-accent disabled:opacity-50 cursor-pointer shadow-2xs"
                  >
                    <Plus className="h-3 w-3" /> Add Contact Person
                  </button>
                </div>

                <div className="space-y-3">
                  {contacts.map((ct, idx) => {
                    const contactCountry = countries.find(
                      (c) => c.name.toLowerCase() === ct.country.toLowerCase(),
                    );
                    const contactDigits = contactCountry?.phoneDigits || 10;
                    const contactPhoneCode = contactCountry?.phoneCode || "+91";

                    const phoneErr =
                      submitted || ct.phone
                        ? countryPhoneError(ct.phone, {
                            digits: contactDigits,
                            phoneCode: contactPhoneCode,
                            countryName: ct.country,
                            label: "Phone",
                            required: true,
                          })
                        : undefined;

                    const emErr =
                      submitted || ct.email.trim() ? emailError(ct.email, true) : undefined;

                    return (
                      <div
                        key={idx}
                        className="rounded-xl border border-border bg-card/60 p-3.5 space-y-3 shadow-2xs"
                      >
                        <div className="flex items-center justify-between">
                          <span className="text-xs font-semibold text-primary">
                            Contact Person #{idx + 1}
                          </span>
                          {contacts.length > 1 && (
                            <button
                              type="button"
                              onClick={() => removeContact(idx)}
                              className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2 py-0.5 text-xs text-muted-foreground hover:bg-destructive/10 hover:text-destructive cursor-pointer transition-colors"
                            >
                              <X className="h-3 w-3" /> Remove
                            </button>
                          )}
                        </div>

                        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                          {/* Contact Person Name */}
                          <Field
                            label="Contact Person Name"
                            required
                            error={submitted && !ct.name.trim() ? "Name is required" : undefined}
                          >
                            <input
                              className={inputCls}
                              value={ct.name}
                              maxLength={150}
                              placeholder="Full name"
                              onChange={(e) => {
                                const filtered = e.target.value
                                  .replace(/[^a-zA-Z\s-']/g, "")
                                  .slice(0, 150);
                                updateContact(idx, "name", filtered);
                              }}
                            />
                          </Field>

                          {/* Contact Type */}
                          <SearchableSelect
                            label="Contact Type"
                            placeholder={catalogsLoading ? "Loading…" : "Select contact type…"}
                            searchPlaceholder="Search contact type…"
                            disabled={catalogsLoading}
                            options={
                              contactTypes.length > 0
                                ? contactTypes.map((t) => ({ value: t.name, label: t.name }))
                                : [
                                    { value: "Primary", label: "Primary" },
                                    { value: "Secondary", label: "Secondary" },
                                    { value: "Billing", label: "Billing" },
                                    { value: "Technical", label: "Technical" },
                                  ]
                            }
                            value={ct.contactType}
                            onChange={(name) => updateContact(idx, "contactType", name)}
                          />

                          {/* Designation */}
                          <SearchableSelect
                            label="Designation"
                            placeholder={catalogsLoading ? "Loading…" : "Select designation…"}
                            searchPlaceholder="Search designation…"
                            disabled={catalogsLoading}
                            options={designations.map((d) => ({ value: d.name, label: d.name }))}
                            value={ct.designation}
                            onChange={(name) => updateContact(idx, "designation", name)}
                          />

                          {/* Country / Region */}
                          <SearchableSelect
                            label="Country / Region"
                            required
                            placeholder={catalogsLoading ? "Loading…" : "Select country…"}
                            searchPlaceholder="Search country…"
                            disabled={catalogsLoading}
                            options={countries.map((c) => ({ value: c.name, label: c.name }))}
                            value={ct.country}
                            onChange={(next) => {
                              updateContact(idx, "country", next);
                              updateContact(idx, "phone", "");
                            }}
                            error={submitted && !ct.country ? "Country is required" : undefined}
                          />

                          {/* Phone */}
                          <Field label="Phone" required error={phoneErr}>
                            <div className="relative flex rounded-md">
                              <span className="inline-flex items-center rounded-l-md border border-r-0 border-input bg-muted px-2.5 text-xs font-semibold text-muted-foreground select-none">
                                {contactPhoneCode}
                              </span>
                              <input
                                className={cn(
                                  fieldInputCls(inputCls, Boolean(phoneErr)),
                                  "rounded-l-none",
                                )}
                                type="tel"
                                inputMode="numeric"
                                maxLength={contactDigits}
                                placeholder={
                                  ct.country ? "9".repeat(contactDigits) : "Select country first"
                                }
                                value={ct.phone}
                                disabled={!ct.country}
                                onChange={(e) => {
                                  const digits = e.target.value
                                    .replace(/\D/g, "")
                                    .slice(0, contactDigits);
                                  updateContact(idx, "phone", digits);
                                }}
                              />
                            </div>
                          </Field>

                          {/* Email */}
                          <Field label="Email" required error={emErr}>
                            <input
                              type="email"
                              className={fieldInputCls(inputCls, Boolean(emErr))}
                              value={ct.email}
                              placeholder="name@company.com"
                              maxLength={150}
                              onChange={(e) => updateContact(idx, "email", e.target.value.trim())}
                            />
                          </Field>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* ── 2. KYC Document Section ── */}
              <div className="space-y-2 border-t border-border pt-4">
                <Field
                  label="KYC Document"
                  required
                  error={submitted && !hasKycDoc ? "KYC Document is required" : undefined}
                >
                  <div className="relative">
                    {newKycFile || existingKycName ? (
                      <div className="flex h-10 w-full items-center gap-2 rounded-lg border border-emerald-500/40 bg-emerald-500/5 px-3 text-sm">
                        <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-emerald-500/15 text-emerald-600 dark:text-emerald-400">
                          <Check className="h-3 w-3" />
                        </span>
                        <span className="min-w-0 flex-1 truncate text-xs font-medium text-foreground">
                          {newKycFile ? newKycFile.name : existingKycName}
                        </span>
                        <span className="shrink-0 text-[10px] text-muted-foreground">
                          {newKycFile
                            ? `${(newKycFile.size / 1024).toFixed(0)} KB`
                            : "On file (stored)"}
                        </span>
                        {(newKycFile || existingKycUrl) && (
                          <button
                            type="button"
                            onClick={() => setPreviewKycOpen(true)}
                            className="inline-flex shrink-0 items-center gap-1 rounded px-2 py-1 text-[11px] font-semibold text-primary hover:bg-primary/10 cursor-pointer"
                          >
                            <Eye className="h-3 w-3" /> Preview
                          </button>
                        )}
                        <label className="relative shrink-0 cursor-pointer rounded border border-input bg-card px-2 py-0.5 text-[11px] font-medium text-foreground hover:bg-accent">
                          Replace
                          <input
                            type="file"
                            accept="*/*"
                            className="absolute inset-0 cursor-pointer opacity-0"
                            onChange={(e) => setNewKycFile(e.target.files?.[0] ?? null)}
                          />
                        </label>
                        {newKycFile && (
                          <button
                            type="button"
                            onClick={() => setNewKycFile(null)}
                            className="rounded p-1 hover:bg-destructive/10 hover:text-destructive cursor-pointer"
                            aria-label="Remove new file"
                            title="Revert to original file"
                          >
                            <X className="h-3.5 w-3.5" />
                          </button>
                        )}
                      </div>
                    ) : (
                      <label className="flex h-12 w-full cursor-pointer items-center justify-center gap-2 rounded-lg border border-dashed border-input bg-card px-3 text-sm transition-colors hover:bg-accent/50">
                        <input
                          type="file"
                          accept="*/*"
                          className="absolute inset-0 h-full w-full cursor-pointer opacity-0"
                          onChange={(e) => setNewKycFile(e.target.files?.[0] ?? null)}
                        />
                        <FileText className="h-4 w-4 text-muted-foreground" />
                        <span className="text-xs text-muted-foreground">
                          Click to attach KYC document — any format accepted (PDF, Image, Word, etc.)
                        </span>
                      </label>
                    )}
                  </div>
                  <p className="text-[11px] text-muted-foreground">
                    {existingKycName
                      ? "Document is currently on file. Replace only if you want to upload a new document."
                      : "Required · Sub-venture regulatory or registration document"}
                  </p>
                </Field>
              </div>

              {/* ── 3. Notes (this sub-venture) Section ── */}
              <div className="space-y-1.5 border-t border-border pt-4">
                <Field label="Notes (this sub-venture)">
                  <textarea
                    rows={3}
                    maxLength={2000}
                    className={cn(inputCls, "h-auto py-2")}
                    value={notes}
                    onChange={(e) => setNotes(e.target.value)}
                    placeholder={`Onboarding or operational notes for ${activeSv.name}…`}
                  />
                  <p className="text-right text-[10px] tabular-nums text-muted-foreground">
                    {notes.length}/2000
                  </p>
                </Field>
              </div>
            </div>
          )}

          {/* Modal Actions */}
          <div className="flex items-center justify-end gap-2 pt-4 border-t border-border">
            <button
              type="button"
              onClick={onClose}
              disabled={submitting}
              className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium text-foreground hover:bg-accent cursor-pointer"
            >
              Cancel
            </button>
            {activeSv && (
              <button
                type="submit"
                disabled={submitting}
                className="inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50 cursor-pointer shadow-sm"
              >
                {submitting && <Loader2 className="h-3.5 w-3.5 animate-spin" />}
                Save Sub-venture Changes
              </button>
            )}
          </div>
        </form>
      </Modal>

      {/* KYC Preview Modal */}
      {previewKycOpen && (
        <KycDocPreviewModal
          open={previewKycOpen}
          onClose={() => setPreviewKycOpen(false)}
          file={newKycFile}
          previewUrl={existingKycUrl}
          fileName={newKycFile ? newKycFile.name : existingKycName}
          clientName={activeSv ? `${client.name} — ${activeSv.name}` : client.name}
          subVentureName={activeSv?.name}
        />
      )}
    </>
  );
}
