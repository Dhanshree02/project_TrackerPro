export interface RailwayStationOption {
  value: string;
  label: string;
  subLabel: string;
  line: string;
}

/** Live rows from master.mst_address_cities. Empty until the catalog API responds. */
let liveAddressCities: RailwayStationOption[] | null = null;

export function setLiveAddressCities(options: RailwayStationOption[] | null): void {
  liveAddressCities = options;
}

/** Dropdown source: strictly the database master table once loaded. */
export function addressCityOptions(): RailwayStationOption[] {
  return liveAddressCities ?? [];
}

export function addressCityToOption(row: { name: string; line?: string | null }): RailwayStationOption {
  const line = row.line?.trim() ?? "";
  const suffix = line ? ` (${line})` : "";
  const label =
    suffix && row.name.toLowerCase().endsWith(suffix.toLowerCase())
      ? row.name.slice(0, row.name.length - suffix.length)
      : row.name;
  return { value: row.name, label, subLabel: line, line };
}
