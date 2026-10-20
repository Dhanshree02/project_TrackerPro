import { describe, expect, it } from "vitest";
import { countryPhoneError, phoneError, phoneStartMessage } from "./form-validation";

describe("country phone start digits", () => {
  it("keeps the Indian employee message", () => {
    expect(phoneError("5123456789", true)).toBe("Must start with 6, 7, 8, or 9");
  });

  it("shows the Indian start rule on a customer number", () => {
    expect(
      countryPhoneError("5123456789", { digits: 10, phoneCode: "+91", countryName: "India" }),
    ).toBe("Must start with 6, 7, 8, or 9");
    expect(phoneStartMessage(["6", "7", "8", "9"])).toBe("Must start with 6, 7, 8, or 9");
  });

  it("uses the selected country code instead of the Indian rule", () => {
    expect(
      countryPhoneError("612345678", { digits: 9, phoneCode: "+971", countryName: "United Arab Emirates" }),
    ).toBe("Must start with 5");
    expect(
      countryPhoneError("512345678", { digits: 9, phoneCode: "+971", countryName: "United Arab Emirates" }),
    ).toBeUndefined();
  });

  it("waits until a longer prefix can be judged", () => {
    expect(
      countryPhoneError("1", { digits: 11, phoneCode: "+49", countryName: "Germany" }),
    ).toBe("Phone must be exactly 11 digits for Germany");
    expect(
      countryPhoneError("12", { digits: 11, phoneCode: "+49", countryName: "Germany" }),
    ).toBe("Must start with 15, 16, or 17");
  });

  it("still checks length when the start digit is valid", () => {
    expect(
      countryPhoneError("98", { digits: 10, phoneCode: "+91", countryName: "India", label: "Group SPOC Contact" }),
    ).toBe("Group SPOC Contact must be exactly 10 digits for India");
  });
});
