import { useEffect, useState } from "react";
import { Moon, Sun } from "lucide-react";
import { Switch } from "@/components/ui/switch";

const STORAGE_KEY = "pms-theme";

function isDark() {
  return document.documentElement.classList.contains("dark");
}

export function ThemeToggle() {
  const [dark, setDark] = useState(false);

  useEffect(() => {
    setDark(isDark());
  }, []);

  function toggle() {
    const next = !isDark();
    document.documentElement.classList.toggle("dark", next);
    localStorage.setItem(STORAGE_KEY, next ? "dark" : "light");
    setDark(next);
  }

  return (
    <label
      className="inline-flex items-center gap-1.5 text-muted-foreground"
      title={dark ? "Light mode" : "Dark mode"}
    >
      {dark ? <Moon className="h-4 w-4" /> : <Sun className="h-4 w-4" />}
      <Switch
        checked={dark}
        onCheckedChange={() => toggle()}
        aria-label={dark ? "Switch to light mode" : "Switch to dark mode"}
      />
    </label>
  );
}
