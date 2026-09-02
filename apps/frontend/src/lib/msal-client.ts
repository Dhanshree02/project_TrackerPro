import {
  PublicClientApplication,
  type Configuration,
  type AuthenticationResult,
  LogLevel,
} from "@azure/msal-browser";

export const MSAL_CLIENT_ID =
  (import.meta.env.VITE_AZURE_CLIENT_ID as string | undefined) ??
  "82de9f23-83ca-4719-99e9-1ce2d10aed22";

export const MSAL_TENANT_ID =
  (import.meta.env.VITE_AZURE_TENANT_ID as string | undefined) ??
  "fa511855-b479-4cc1-81d1-dddefa531df2";

const msalConfig: Configuration = {
  auth: {
    clientId: MSAL_CLIENT_ID,
    authority: `https://login.microsoftonline.com/${MSAL_TENANT_ID}`,
    redirectUri: typeof window !== "undefined" ? `${window.location.origin}/login` : "/login",
    navigateToLoginRequestUrl: false,
  },
  cache: {
    cacheLocation: "sessionStorage",
    storeAuthStateInCookie: false,
  },
  system: {
    allowNativeBroker: false,
    loggerOptions: {
      logLevel: LogLevel.Warning,
    },
  },
};

export const loginRequest = {
  scopes: ["openid", "profile", "email", "User.Read"],
  prompt: "select_account",
};

let msalInstance: PublicClientApplication | null = null;
let msalInitPromise: Promise<PublicClientApplication> | null = null;

export function getMsalInstance(): Promise<PublicClientApplication> {
  if (msalInstance) return Promise.resolve(msalInstance);

  if (!msalInitPromise) {
    msalInitPromise = (async () => {
      const instance = new PublicClientApplication(msalConfig);
      await instance.initialize();
      msalInstance = instance;
      return instance;
    })();
  }
  return msalInitPromise;
}

export async function handleMsalRedirectResult(): Promise<AuthenticationResult | null> {
  const msal = await getMsalInstance();
  return await msal.handleRedirectPromise();
}

export async function loginWithMicrosoftPopup(): Promise<AuthenticationResult> {
  const msal = await getMsalInstance();
  return await msal.loginPopup(loginRequest);
}

export async function loginWithMicrosoftRedirect(): Promise<void> {
  const msal = await getMsalInstance();
  await msal.loginRedirect(loginRequest);
}
