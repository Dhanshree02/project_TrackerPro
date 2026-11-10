import { useState, useEffect, useMemo } from "react";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";
import { Modal } from "@/modules/projects/pages/projects-list-page";
import { SearchableSelect } from "@/components/creatable-catalog-select";
import { fetchCountries, fetchCities, fetchIndustries, type CatalogOption, type CityCatalogOption } from "@/lib/api/catalogs";
import { countryPhoneError } from "@/lib/form-validation";
import { updateClient, formatCustomerId } from "@/modules/customers/api/clients";
import type { Client } from "@/types";
import { cn } from "@/lib/utils";

const BILLING_MEDIUMS = ["Portal Based", "Manual Based"];

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

export interface EditCustomerInfoModalProps {
  client: Client;
  onClose: () => void;
  onSaved: () => void;
}

export function EditCustomerInfoModal({
  client,
  onClose,
  onSaved,
}: EditCustomerInfoModalProps) {
  const [billingMedium, setBillingMedium] = useState(client.billingMedium || "Manual Based");
  const [country, setCountry] = useState(client.country || "");
  const [city, setCity] = useState(client.city || "");
  const [groupSpocName, setGroupSpocName] = useState(client.groupSpocName || client.contactName || "");
  const [groupSpocContact, setGroupSpocContact] = useState(
    (client.groupSpocContact || client.contactPhone || "").replace(/\D/g, ""),
  );
  const [industry, setIndustry] = useState(client.industry || "");

  const [countries, setCountries] = useState<CatalogOption[]>([]);
  const [cities, setCities] = useState<CityCatalogOption[]>([]);
  const [industries, setIndustries] = useState<CatalogOption[]>([]);
  const [catalogsLoading, setCatalogsLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  useEffect(() => {
    let active = true;
    Promise.all([fetchCountries(), fetchIndustries()])
      .then(([coList, indList]) => {
        if (!active) return;
        setCountries(coList);
        setIndustries(indList);
      })
      .catch(() => {
        // Catalogs fallback gracefully
      })
      .finally(() => {
        if (active) setCatalogsLoading(false);
      });
    return () => {
      active = false;
    };
  }, []);

  // Fetch cities whenever selected country changes
  useEffect(() => {
    let active = true;
    const selected = countries.find((c) => c.name.toLowerCase() === country.toLowerCase());
    if (selected?.id) {
      fetchCities(selected.id)
        .then((cityList) => {
          if (!active) return;
          setCities(cityList);
        })
        .catch(() => {
          if (active) setCities([]);
        });
    } else {
      setCities([]);
    }
    return () => {
      active = false;
    };
  }, [country, countries]);

  const selectedCountry = useMemo(
    () => countries.find((c) => c.name.toLowerCase() === country.toLowerCase()),
    [country, countries],
  );

  const countryDialCode = selectedCountry?.phoneCode || client.groupSpocPhoneCode || "+91";
  const countryPhoneDigits = selectedCountry?.phoneDigits || 10;

  const groupSpocPhoneErr = useMemo(() => {
    if (!country) return submitted ? "Select country first" : undefined;
    if (!groupSpocContact && !submitted) return undefined;
    return countryPhoneError(groupSpocContact, {
      digits: countryPhoneDigits,
      phoneCode: countryDialCode,
      countryName: country,
      label: "Group SPOC Contact",
      required: true,
    });
  }, [groupSpocContact, country, countryPhoneDigits, countryDialCode, submitted]);

  const industryOptions = useMemo(() => {
    const list = industries.map((i) => ({ value: i.name, label: i.name }));
    if (industry && !list.some((o) => o.value.toLowerCase() === industry.toLowerCase())) {
      list.unshift({ value: industry, label: industry });
    }
    return list;
  }, [industries, industry]);

  const cityOptions = useMemo(() => {
    const list = cities.map((c) => ({ value: c.name, label: c.name }));
    if (city && !list.some((o) => o.value.toLowerCase() === city.toLowerCase())) {
      list.unshift({ value: city, label: city });
    }
    return list;
  }, [cities, city]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);

    if (!billingMedium.trim()) {
      toast.error("Please select a billing medium.");
      return;
    }
    if (!country.trim()) {
      toast.error("Please select a country / region.");
      return;
    }
    if (!city.trim()) {
      toast.error("Please enter or select a city.");
      return;
    }
    if (!groupSpocName.trim()) {
      toast.error("Please enter the Group SPOC name.");
      return;
    }
    if (!groupSpocContact.trim()) {
      toast.error("Please enter the Group SPOC contact number.");
      return;
    }
    if (groupSpocPhoneErr) {
      toast.error(groupSpocPhoneErr);
      return;
    }
    if (!industry.trim()) {
      toast.error("Please select an industry.");
      return;
    }

    setSubmitting(true);
    try {
      await updateClient(client.id, {
        billingMedium: billingMedium.trim(),
        country: country.trim(),
        city: city.trim(),
        groupSpocName: groupSpocName.trim(),
        groupSpocContact: groupSpocContact.trim(),
        groupSpocPhoneCode: countryDialCode,
        contactName: groupSpocName.trim(),
        contactPhone: groupSpocContact.trim(),
        industry: industry.trim(),
      });

      toast.success("Customer information updated successfully");
      onSaved();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to update customer information");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Modal
      title={`Edit Customer Information — ${client.name}`}
      onClose={onClose}
      wide
    >
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="rounded-lg border border-border/60 bg-muted/20 px-3 py-2 text-xs text-muted-foreground flex items-center justify-between">
          <span>Customer ID: <strong className="font-mono text-foreground">{client.clientCode || formatCustomerId(client.id)}</strong></span>
          <span>Customer: <strong className="text-foreground">{client.name}</strong></span>
        </div>

        <div className="grid gap-3 sm:grid-cols-2">
          {/* Billing Medium */}
          <Field
            label="Billing Medium"
            required
            error={submitted && !billingMedium ? "Billing medium is required" : undefined}
          >
            <select
              className={inputCls}
              value={billingMedium}
              onChange={(e) => setBillingMedium(e.target.value)}
            >
              <option value="">Select billing medium</option>
              {BILLING_MEDIUMS.map((bm) => (
                <option key={bm} value={bm}>
                  {bm}
                </option>
              ))}
            </select>
          </Field>

          {/* Industry */}
          <SearchableSelect
            label="Industry"
            required
            placeholder={catalogsLoading ? "Loading industries…" : "Select industry…"}
            searchPlaceholder="Search industry…"
            disabled={catalogsLoading}
            options={industryOptions}
            value={industry}
            onChange={(name) => setIndustry(name)}
            error={submitted && !industry ? "Industry is required" : undefined}
          />

          {/* Country / Region */}
          <SearchableSelect
            label="Country / Region"
            required
            placeholder={catalogsLoading ? "Loading countries…" : "Select country…"}
            searchPlaceholder="Search country…"
            disabled={catalogsLoading}
            options={countries.map((c) => ({ value: c.name, label: c.name }))}
            value={country}
            onChange={(next) => {
              setCountry(next);
              setCity("");
              setGroupSpocContact("");
            }}
            error={submitted && !country ? "Country / Region is required" : undefined}
          />

          {/* City */}
          <SearchableSelect
            label="City"
            required
            disabled={!country}
            disabledHint="Select country first"
            placeholder={country ? "Select or enter city…" : "Select country first"}
            searchPlaceholder="Search city…"
            options={cityOptions}
            value={city}
            onChange={(val) => setCity(val)}
            error={submitted && !city ? "City is required" : undefined}
          />

          {/* Group SPOC Name */}
          <Field
            label="Group SPOC Name"
            required
            error={submitted && !groupSpocName.trim() ? "Group SPOC Name is required" : undefined}
          >
            <input
              className={inputCls}
              value={groupSpocName}
              maxLength={150}
              placeholder="Full name"
              onChange={(e) => {
                const filtered = e.target.value
                  .replace(/[^a-zA-Z\s-']/g, "")
                  .slice(0, 150);
                setGroupSpocName(filtered);
              }}
            />
          </Field>

          {/* Group SPOC Contact */}
          <Field
            label="Group SPOC Contact"
            required
            error={groupSpocPhoneErr}
          >
            <div className="relative flex rounded-md">
              <span className="inline-flex items-center rounded-l-md border border-r-0 border-input bg-muted px-2.5 text-xs font-semibold text-muted-foreground select-none">
                {countryDialCode}
              </span>
              <input
                className={cn(
                  fieldInputCls(inputCls, Boolean(groupSpocPhoneErr)),
                  "rounded-l-none",
                )}
                type="tel"
                inputMode="numeric"
                maxLength={countryPhoneDigits}
                placeholder={country ? "9".repeat(countryPhoneDigits) : "Select country first"}
                value={groupSpocContact}
                disabled={!country}
                onChange={(e) => {
                  const digits = e.target.value.replace(/\D/g, "").slice(0, countryPhoneDigits);
                  setGroupSpocContact(digits);
                }}
              />
            </div>
          </Field>
        </div>

        <div className="flex items-center justify-end gap-2 pt-4 border-t border-border">
          <button
            type="button"
            onClick={onClose}
            disabled={submitting}
            className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium text-foreground hover:bg-accent cursor-pointer"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={submitting}
            className="inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50 cursor-pointer shadow-sm"
          >
            {submitting && <Loader2 className="h-3.5 w-3.5 animate-spin" />}
            Save Changes
          </button>
        </div>
      </form>
    </Modal>
  );
}
